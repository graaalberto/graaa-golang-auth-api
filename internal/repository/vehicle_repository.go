package repository

import (
	"github.com/google/uuid"
	"gorm.io/gorm"

	"github.com/gjovanovicst/auth_api/internal/domain"
)

type VehicleRepository interface {
	Create(vehicle *domain.Vehicle) error
	ListByTenant(tenantID uuid.UUID) ([]domain.Vehicle, error)
	GetByID(vehicleID uuid.UUID) (*domain.Vehicle, error)
}

type vehicleRepository struct {
	db *gorm.DB
}

func NewVehicleRepository(db *gorm.DB) VehicleRepository {
	return &vehicleRepository{db: db}
}

func (r *vehicleRepository) Create(vehicle *domain.Vehicle) error {
	return r.db.Create(vehicle).Error
}

func (r *vehicleRepository) ListByTenant(tenantID uuid.UUID) ([]domain.Vehicle, error) {
	var vehicles []domain.Vehicle
	if err := r.db.Where("tenant_id = ?", tenantID).Order("created_at desc").Find(&vehicles).Error; err != nil {
		return nil, err
	}
	return vehicles, nil
}

func (r *vehicleRepository) GetByID(vehicleID uuid.UUID) (*domain.Vehicle, error) {
	var vehicle domain.Vehicle
	if err := r.db.Where("id = ?", vehicleID).First(&vehicle).Error; err != nil {
		return nil, err
	}
	return &vehicle, nil
}
