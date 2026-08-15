package maintenance

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
	"gorm.io/gorm/clause"
)

type Repository struct {
	db *gorm.DB
}

func NewRepository(db *gorm.DB) *Repository {
	return &Repository{db: db}
}

func (r *Repository) AutoMigrate() error {
	return r.db.AutoMigrate(&WorkOrder{}, &SparePart{}, &WorkOrderPart{})
}

func (r *Repository) CreateWorkOrder(order *WorkOrder) error {
	return r.db.Create(order).Error
}

func (r *Repository) ListWorkOrders(tenantID uuid.UUID, status *WorkOrderStatus, vehicleID *uuid.UUID) ([]WorkOrder, error) {
	var orders []WorkOrder
	query := r.db.Where("tenant_id = ?", tenantID)
	if status != nil {
		query = query.Where("status = ?", *status)
	}
	if vehicleID != nil {
		query = query.Where("vehicle_id = ?", *vehicleID)
	}
	if err := query.Order("created_at desc").Find(&orders).Error; err != nil {
		return nil, err
	}
	return orders, nil
}

func (r *Repository) GetWorkOrderByID(id uuid.UUID) (*WorkOrder, error) {
	var order WorkOrder
	if err := r.db.Where("id = ?", id).First(&order).Error; err != nil {
		return nil, err
	}
	return &order, nil
}

func (r *Repository) GetWorkOrderByIDForUpdate(tx *gorm.DB, id uuid.UUID) (*WorkOrder, error) {
	var order WorkOrder
	if err := tx.Clauses(clause.Locking{Strength: "UPDATE"}).Where("id = ?", id).First(&order).Error; err != nil {
		return nil, err
	}
	return &order, nil
}

func (r *Repository) UpdateWorkOrderStatus(id uuid.UUID, status WorkOrderStatus, completedAt *time.Time) error {
	updates := map[string]interface{}{"status": status}
	if completedAt != nil {
		updates["completed_at"] = completedAt
	}
	return r.db.Model(&WorkOrder{}).Where("id = ?", id).Updates(updates).Error
}

func (r *Repository) GetSparePartByIDForUpdate(tx *gorm.DB, id uuid.UUID) (*SparePart, error) {
	var part SparePart
	if err := tx.Clauses(clause.Locking{Strength: "UPDATE"}).Where("id = ?", id).First(&part).Error; err != nil {
		return nil, err
	}
	return &part, nil
}

func (r *Repository) SaveSparePart(tx *gorm.DB, part *SparePart) error {
	return tx.Save(part).Error
}

func (r *Repository) CreateWorkOrderParts(tx *gorm.DB, parts []WorkOrderPart) error {
	return tx.Create(&parts).Error
}

func (r *Repository) SaveWorkOrder(tx *gorm.DB, order *WorkOrder) error {
	return tx.Save(order).Error
}
