package domain

import (
	"time"

	"github.com/google/uuid"
)

type VehicleStatus string

const (
	VehicleStatusActive      VehicleStatus = "ACTIVE"
	VehicleStatusMaintenance VehicleStatus = "MAINTENANCE"
	VehicleStatusInactive    VehicleStatus = "INACTIVE"
)

type Vehicle struct {
	ID        uuid.UUID     `gorm:"type:uuid;primaryKey" json:"id"`
	Plate     string        `gorm:"type:varchar(16);not null" json:"plate"`
	Chassis   string        `gorm:"type:varchar(64);not null;uniqueIndex" json:"chassis"`
	Model     string        `gorm:"type:varchar(128);not null" json:"model"`
	Year      int           `gorm:"not null" json:"year"`
	Status    VehicleStatus `gorm:"type:text;not null;default:'ACTIVE'" json:"status"`
	TenantID  uuid.UUID     `gorm:"type:uuid;not null;index" json:"tenant_id"`
	CreatedAt time.Time     `gorm:"autoCreateTime" json:"created_at"`
}

type Telemetry struct {
	ID         uuid.UUID `gorm:"type:uuid;primaryKey" json:"id"`
	VehicleID  uuid.UUID `gorm:"type:uuid;not null;index" json:"vehicle_id"`
	Latitude   float64   `gorm:"not null" json:"latitude"`
	Longitude  float64   `gorm:"not null" json:"longitude"`
	Speed      float64   `gorm:"not null" json:"speed"`
	FuelLevel  float64   `gorm:"not null" json:"fuel_level"`
	OdometerKm float64   `gorm:"not null" json:"odometer_km"`
	Timestamp  time.Time `gorm:"not null" json:"timestamp"`
}

func (Telemetry) TableName() string {
	return "telemetry"
}
