package repository

import (
	"github.com/google/uuid"
	"gorm.io/gorm"

	"github.com/gjovanovicst/auth_api/internal/domain"
)

type TelemetryRepository interface {
	Create(telemetry *domain.Telemetry) error
	LastForVehicle(vehicleID uuid.UUID) (*domain.Telemetry, error)
}

type telemetryRepository struct {
	db *gorm.DB
}

func NewTelemetryRepository(db *gorm.DB) TelemetryRepository {
	return &telemetryRepository{db: db}
}

func (r *telemetryRepository) Create(telemetry *domain.Telemetry) error {
	return r.db.Create(telemetry).Error
}

func (r *telemetryRepository) LastForVehicle(vehicleID uuid.UUID) (*domain.Telemetry, error) {
	var telemetry domain.Telemetry
	if err := r.db.Where("vehicle_id = ?", vehicleID).Order("timestamp desc").First(&telemetry).Error; err != nil {
		return nil, err
	}
	return &telemetry, nil
}
