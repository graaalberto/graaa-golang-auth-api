package service

import (
	"errors"
	"github.com/google/uuid"

	"github.com/gjovanovicst/auth_api/internal/domain"
	"github.com/gjovanovicst/auth_api/internal/repository"
)

type VehicleService interface {
	CreateVehicle(vehicle *domain.Vehicle) error
	ListVehicles(tenantID uuid.UUID) ([]domain.Vehicle, error)
}

type vehicleService struct {
	repo repository.VehicleRepository
}

func NewVehicleService(repo repository.VehicleRepository) VehicleService {
	return &vehicleService{repo: repo}
}

func (s *vehicleService) CreateVehicle(vehicle *domain.Vehicle) error {
	if vehicle.ID == uuid.Nil {
		vehicle.ID = uuid.New()
	}

	if vehicle.Plate == "" || vehicle.Chassis == "" || vehicle.Model == "" || vehicle.Year == 0 {
		return errors.New("vehicle data is incomplete")
	}

	if vehicle.Status == "" {
		vehicle.Status = domain.VehicleStatusActive
	}

	return s.repo.Create(vehicle)
}

func (s *vehicleService) ListVehicles(tenantID uuid.UUID) ([]domain.Vehicle, error) {
	return s.repo.ListByTenant(tenantID)
}
