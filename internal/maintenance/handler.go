package maintenance

import (
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type createWorkOrderRequest struct {
	VehicleID   string `json:"vehicle_id" binding:"required,uuid4"`
	Priority    string `json:"priority" binding:"required,oneof=LOW MEDIUM HIGH"`
	Description string `json:"description" binding:"required,min=10"`
}

type workOrderResponse struct {
	ID          uuid.UUID `json:"id"`
	VehicleID   uuid.UUID `json:"vehicle_id"`
	Priority    string    `json:"priority"`
	Status      string    `json:"status"`
	Description string    `json:"description"`
	TotalCost   float64   `json:"total_cost"`
	TenantID    uuid.UUID `json:"tenant_id"`
	CreatedAt   string    `json:"created_at"`
	CompletedAt string    `json:"completed_at,omitempty"`
}

type updateWorkOrderStatusRequest struct {
	Status string `json:"status" binding:"required,oneof=PENDING IN_PROGRESS COMPLETED CANCELLED"`
}

type addPartsRequest struct {
	Parts []struct {
		PartID       string `json:"part_id" binding:"required,uuid4"`
		QuantityUsed int    `json:"quantity_used" binding:"required,gt=0"`
	} `json:"parts" binding:"required,dive,required"`
}

type addPartsResponse struct {
	Alerts []string `json:"alerts,omitempty"`
}

type Handler struct {
	service Service
}

func NewHandler(service Service) *Handler {
	return &Handler{service: service}
}

func (h *Handler) CreateWorkOrder(c *gin.Context) {
	var req createWorkOrderRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	vehicleID, err := uuid.Parse(req.VehicleID)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid vehicle_id"})
		return
	}

	priority := WorkOrderPriority(req.Priority)
	if priority != WorkOrderPriorityLow && priority != WorkOrderPriorityMedium && priority != WorkOrderPriorityHigh {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid priority"})
		return
	}

	tenantID, err := GetTenantID(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": err.Error()})
		return
	}

	order, err := h.service.CreateWorkOrder(tenantID, vehicleID, priority, req.Description)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, workOrderResponse{
		ID:          order.ID,
		VehicleID:   order.VehicleID,
		Priority:    string(order.Priority),
		Status:      string(order.Status),
		Description: order.Description,
		TotalCost:   order.TotalCost,
		TenantID:    order.TenantID,
		CreatedAt:   order.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
		CompletedAt: formatNullableTime(order.CompletedAt),
	})
}

func (h *Handler) ListWorkOrders(c *gin.Context) {
	statusParam := c.Query("status")	
	vehicleIDParam := c.Query("vehicle_id")

	var status *WorkOrderStatus
	if statusParam != "" {
		tmp := WorkOrderStatus(statusParam)
		status = &tmp
	}

	var vehicleID *uuid.UUID
	if vehicleIDParam != "" {
		id, err := uuid.Parse(vehicleIDParam)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "invalid vehicle_id"})
			return
		}
		vehicleID = &id
	}

	tenantID, err := GetTenantID(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": err.Error()})
		return
	}

	orders, err := h.service.ListWorkOrders(tenantID, status, vehicleID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	response := make([]workOrderResponse, 0, len(orders))
	for _, order := range orders {
		response = append(response, workOrderResponse{
			ID:          order.ID,
			VehicleID:   order.VehicleID,
			Priority:    string(order.Priority),
			Status:      string(order.Status),
			Description: order.Description,
			TotalCost:   order.TotalCost,
			TenantID:    order.TenantID,
			CreatedAt:   order.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
			CompletedAt: formatNullableTime(order.CompletedAt),
		})
	}

	c.JSON(http.StatusOK, response)
}

func (h *Handler) UpdateWorkOrderStatus(c *gin.Context) {
	idParam := c.Param("id")
	workOrderID, err := uuid.Parse(idParam)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid work order id"})
		return
	}

	var req updateWorkOrderStatusRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	status := WorkOrderStatus(req.Status)
	if status != WorkOrderStatusPending && status != WorkOrderStatusInProgress && status != WorkOrderStatusCompleted && status != WorkOrderStatusCancelled {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid status"})
		return
	}

	tenantID, err := GetTenantID(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": err.Error()})
		return
	}

	if err := h.service.UpdateWorkOrderStatus(workOrderID, tenantID, status); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.Status(http.StatusNoContent)
}

func (h *Handler) AddPartsToWorkOrder(c *gin.Context) {
	idParam := c.Param("id")
	workOrderID, err := uuid.Parse(idParam)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid work order id"})
		return
	}

	var req addPartsRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if len(req.Parts) == 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "parts cannot be empty"})
		return
	}

	tenantID, err := GetTenantID(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": err.Error()})
		return
	}

	items := make([]AddPartRequest, 0, len(req.Parts))
	for _, item := range req.Parts {
		partID, err := uuid.Parse(item.PartID)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "invalid part_id"})
			return
		}
		items = append(items, AddPartRequest{PartID: partID, QuantityUsed: item.QuantityUsed})
	}

	alerts, err := h.service.AddPartsToWorkOrder(workOrderID, tenantID, items)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, addPartsResponse{Alerts: alerts})
}

func formatNullableTime(t *time.Time) string {
	if t == nil {
		return ""
	}
	return t.Format("2006-01-02T15:04:05Z07:00")
}
