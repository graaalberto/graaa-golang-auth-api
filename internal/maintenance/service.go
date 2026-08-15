package maintenance

import (
	"errors"
	"fmt"
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type Service interface {
	CreateWorkOrder(tenantID, vehicleID uuid.UUID, priority WorkOrderPriority, description string) (*WorkOrder, error)
	ListWorkOrders(tenantID uuid.UUID, status *WorkOrderStatus, vehicleID *uuid.UUID) ([]WorkOrder, error)
	UpdateWorkOrderStatus(id, tenantID uuid.UUID, status WorkOrderStatus) error
	AddPartsToWorkOrder(id, tenantID uuid.UUID, items []AddPartRequest) ([]string, error)
}

type AddPartRequest struct {
	PartID       uuid.UUID
	QuantityUsed int
}

type service struct {
	repo *Repository
	db   *gorm.DB
}

func NewService(repo *Repository) Service {
	return &service{repo: repo, db: repo.db}
}

func (s *service) CreateWorkOrder(tenantID, vehicleID uuid.UUID, priority WorkOrderPriority, description string) (*WorkOrder, error) {
	order := &WorkOrder{
		ID:          uuid.New(),
		VehicleID:   vehicleID,
		Priority:    priority,
		Status:      WorkOrderStatusPending,
		Description: description,
		TotalCost:   0,
		TenantID:    tenantID,
	}

	if err := s.repo.CreateWorkOrder(order); err != nil {
		return nil, err
	}

	return order, nil
}

func (s *service) ListWorkOrders(tenantID uuid.UUID, status *WorkOrderStatus, vehicleID *uuid.UUID) ([]WorkOrder, error) {
	return s.repo.ListWorkOrders(tenantID, status, vehicleID)
}

func (s *service) UpdateWorkOrderStatus(id, tenantID uuid.UUID, status WorkOrderStatus) error {
	order, err := s.repo.GetWorkOrderByID(id)
	if err != nil {
		return err
	}
	if order.TenantID != tenantID {
		return errors.New("work order does not belong to tenant")
	}

	var completedAt *time.Time
	if status == WorkOrderStatusCompleted {
		now := time.Now().UTC()
		completedAt = &now
	}

	return s.repo.UpdateWorkOrderStatus(id, status, completedAt)
}

func (s *service) AddPartsToWorkOrder(id, tenantID uuid.UUID, items []AddPartRequest) ([]string, error) {
	var lowStockAlerts []string

	err := s.db.Transaction(func(tx *gorm.DB) error {
		order, err := s.repo.GetWorkOrderByIDForUpdate(tx, id)
		if err != nil {
			return err
		}
		if order.TenantID != tenantID {
			return errors.New("work order does not belong to tenant")
		}
		if order.Status == WorkOrderStatusCancelled {
			return errors.New("cannot add parts to a cancelled work order")
		}

		workOrderParts := make([]WorkOrderPart, 0, len(items))
		totalCost := order.TotalCost

		for _, item := range items {
			part, err := s.repo.GetSparePartByIDForUpdate(tx, item.PartID)
			if err != nil {
				return err
			}
			if item.QuantityUsed <= 0 {
				return errors.New("quantity_used must be greater than zero")
			}
			if part.StockQuantity < item.QuantityUsed {
				return fmt.Errorf("insufficient stock for part %s", part.ID)
			}

			part.StockQuantity -= item.QuantityUsed
			if err := s.repo.SaveSparePart(tx, part); err != nil {
				return err
			}

			workOrderParts = append(workOrderParts, WorkOrderPart{
				WorkOrderID:  order.ID,
				PartID:       part.ID,
				QuantityUsed: item.QuantityUsed,
			})

			totalCost += float64(item.QuantityUsed) * part.UnitPrice
			if part.StockQuantity < 5 {
				lowStockAlerts = append(lowStockAlerts, fmt.Sprintf("Spare part '%s' stock low: %d remaining", part.Name, part.StockQuantity))
			}
		}

		if err := s.repo.CreateWorkOrderParts(tx, workOrderParts); err != nil {
			return err
		}

		order.TotalCost = totalCost
		if err := s.repo.SaveWorkOrder(tx, order); err != nil {
			return err
		}

		return nil
	})

	return lowStockAlerts, err
}
