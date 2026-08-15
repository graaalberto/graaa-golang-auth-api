package repository

import (
	"github.com/google/uuid"
	"gorm.io/gorm"

	"github.com/gjovanovicst/auth_api/pkg/models"
)

type AppRepository interface {
	GetTenantIDByAppID(appID uuid.UUID) (uuid.UUID, error)
}

type appRepository struct {
	db *gorm.DB
}

func NewAppRepository(db *gorm.DB) AppRepository {
	return &appRepository{db: db}
}

func (r *appRepository) GetTenantIDByAppID(appID uuid.UUID) (uuid.UUID, error) {
	var app models.Application
	if err := r.db.Select("tenant_id").First(&app, "id = ?", appID).Error; err != nil {
		return uuid.Nil, err
	}
	return app.TenantID, nil
}
