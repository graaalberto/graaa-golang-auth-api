package service

import (
	"github.com/google/uuid"

	"github.com/gjovanovicst/auth_api/internal/repository"
)

type TenantService interface {
	GetTenantID(appID uuid.UUID) (uuid.UUID, error)
}

type tenantService struct {
	repo repository.AppRepository
}

func NewTenantService(repo repository.AppRepository) TenantService {
	return &tenantService{repo: repo}
}

func (s *tenantService) GetTenantID(appID uuid.UUID) (uuid.UUID, error) {
	return s.repo.GetTenantIDByAppID(appID)
}
