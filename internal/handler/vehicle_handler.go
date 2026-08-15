package handler

import (
	"fmt"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"

	"github.com/gjovanovicst/auth_api/internal/domain"
	"github.com/gjovanovicst/auth_api/internal/service"
)

type VehicleHandler struct {
	service       service.VehicleService
	tenantService service.TenantService
}

func NewVehicleHandler(service service.VehicleService, tenantService service.TenantService) *VehicleHandler {
	return &VehicleHandler{service: service, tenantService: tenantService}
}

type createVehicleRequest struct {
	Plate   string `json:"plate" binding:"required"`
	Chassis string `json:"chassis" binding:"required"`
	Model   string `json:"model" binding:"required"`
	Year    int    `json:"year" binding:"required,gt=1900"`
	Status  string `json:"status" binding:"omitempty,oneof=ACTIVE MAINTENANCE INACTIVE"`
}

type vehicleResponse struct {
	ID        uuid.UUID         `json:"id"`
	Plate     string            `json:"plate"`
	Chassis   string            `json:"chassis"`
	Model     string            `json:"model"`
	Year      int               `json:"year"`
	Status    domain.VehicleStatus `json:"status"`
	TenantID  uuid.UUID         `json:"tenant_id"`
	CreatedAt string            `json:"created_at"`
}

func (h *VehicleHandler) CreateVehicle(c *gin.Context) {
	var req createVehicleRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	tenantID, err := h.getTenantIDFromContext(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": err.Error()})
		return
	}

	vehicle := &domain.Vehicle{
		Plate:    req.Plate,
		Chassis:  req.Chassis,
		Model:    req.Model,
		Year:     req.Year,
		Status:   domain.VehicleStatus(req.Status),
		TenantID: tenantID,
	}

	if err := h.service.CreateVehicle(vehicle); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, vehicleResponse{
		ID:        vehicle.ID,
		Plate:     vehicle.Plate,
		Chassis:   vehicle.Chassis,
		Model:     vehicle.Model,
		Year:      vehicle.Year,
		Status:    vehicle.Status,
		TenantID:  vehicle.TenantID,
		CreatedAt: vehicle.CreatedAt.Format(time.RFC3339),
	})
}

func (h *VehicleHandler) ListVehicles(c *gin.Context) {
	parsedTenantID, err := h.getTenantIDFromContext(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": err.Error()})
		return
	}

	vehicles, err := h.service.ListVehicles(parsedTenantID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	response := make([]vehicleResponse, 0, len(vehicles))
	for _, vehicle := range vehicles {
		response = append(response, vehicleResponse{
			ID:        vehicle.ID,
			Plate:     vehicle.Plate,
			Chassis:   vehicle.Chassis,
			Model:     vehicle.Model,
			Year:      vehicle.Year,
			Status:    vehicle.Status,
			TenantID:  vehicle.TenantID,
			CreatedAt: vehicle.CreatedAt.Format(time.RFC3339),
		})
	}

	c.JSON(http.StatusOK, response)
}

func (h *VehicleHandler) getTenantIDFromContext(c *gin.Context) (uuid.UUID, error) {
	if tenantIDValue, exists := c.Get("tenant_id"); exists {
		if tenantIDStr, ok := tenantIDValue.(string); ok {
			parsed, err := uuid.Parse(tenantIDStr)
			if err == nil {
				return parsed, nil
			}
		}
	}

	if h.tenantService == nil {
		return uuid.Nil, fmt.Errorf("tenant_id missing from token claims")
	}

	appIDValue, exists := c.Get("app_id")
	if !exists {
		return uuid.Nil, fmt.Errorf("app_id missing from token claims")
	}

	appIDStr, ok := appIDValue.(string)
	if !ok {
		return uuid.Nil, fmt.Errorf("invalid app_id format")
	}

	appID, err := uuid.Parse(appIDStr)
	if err != nil {
		return uuid.Nil, fmt.Errorf("invalid app_id value")
	}

	return h.tenantService.GetTenantID(appID)
}
