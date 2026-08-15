package maintenance
package maintenance

import (
	"time"

	"github.com/google/uuid"
)

type WorkOrderPriority string

type WorkOrderStatus string

const (
	WorkOrderPriorityLow    WorkOrderPriority = "LOW"
	WorkOrderPriorityMedium WorkOrderPriority = "MEDIUM"
	WorkOrderPriorityHigh   WorkOrderPriority = "HIGH"

	WorkOrderStatusPending    WorkOrderStatus = "PENDING"
	WorkOrderStatusInProgress WorkOrderStatus = "IN_PROGRESS"
	WorkOrderStatusCompleted  WorkOrderStatus = "COMPLETED"
	WorkOrderStatusCancelled  WorkOrderStatus = "CANCELLED"
)

type WorkOrder struct {
	ID          uuid.UUID        `gorm:"type:uuid;primaryKey" json:"id"`
	VehicleID   uuid.UUID        `gorm:"type:uuid;not null;index" json:"vehicle_id"`
	Priority    WorkOrderPriority `gorm:"type:text;not null;default:'MEDIUM'" json:"priority"`
	Status      WorkOrderStatus   `gorm:"type:text;not null;default:'PENDING'" json:"status"`
	Description string           `gorm:"type:text;not null" json:"description"`
	TotalCost   float64          `gorm:"type:numeric(12,2);not null;default:0" json:"total_cost"`
	TenantID    uuid.UUID        `gorm:"type:uuid;not null;index" json:"tenant_id"`
	CreatedAt   time.Time        `gorm:"autoCreateTime" json:"created_at"`
	CompletedAt *time.Time       `gorm:"" json:"completed_at,omitempty"`
}

type SparePart struct {
	ID            uuid.UUID `gorm:"type:uuid;primaryKey" json:"id"`
	Name          string    `gorm:"type:text;not null" json:"name"`
	StockCode     string    `gorm:"type:varchar(64);not null;uniqueIndex" json:"stock_code"`
	StockQuantity int       `gorm:"not null;default:0" json:"stock_quantity"`
	UnitPrice     float64   `gorm:"type:numeric(12,2);not null;default:0" json:"unit_price"`
}

type WorkOrderPart struct {
	WorkOrderID uuid.UUID `gorm:"type:uuid;primaryKey" json:"work_order_id"`
	PartID      uuid.UUID `gorm:"type:uuid;primaryKey" json:"part_id"`
	QuantityUsed int      `gorm:"not null" json:"quantity_used"`
	CreatedAt   time.Time `gorm:"autoCreateTime" json:"created_at"`
}
