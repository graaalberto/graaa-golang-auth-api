package handler

import (
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"

	"github.com/gjovanovicst/auth_api/internal/domain"
	"github.com/gjovanovicst/auth_api/internal/service"
)

type TelemetryHandler struct {
	service service.TelemetryService
}

func NewTelemetryHandler(service service.TelemetryService) *TelemetryHandler {
	return &TelemetryHandler{service: service}
}

type telemetryRequest struct {
	VehicleID     string  `json:"vehicle_id" binding:"required,uuid4"`
	Latitude      float64 `json:"latitude" binding:"required"`
	Longitude     float64 `json:"longitude" binding:"required"`
	Speed         float64 `json:"speed" binding:"required"`
	FuelLevel     float64 `json:"fuel_level" binding:"required,gte=0,lte=100"`
	OdometerKm    float64 `json:"odometer_km" binding:"required,gte=0"`
	Timestamp     string  `json:"timestamp" binding:"omitempty,datetime=2006-01-02T15:04:05Z07:00"`
}

type telemetryResponse struct {
	ID           uuid.UUID `json:"id"`
	VehicleID    uuid.UUID `json:"vehicle_id"`
	Latitude     float64   `json:"latitude"`
	Longitude    float64   `json:"longitude"`
	Speed        float64   `json:"speed"`
	FuelLevel    float64   `json:"fuel_level"`
	OdometerKm   float64   `json:"odometer_km"`
	Timestamp    string    `json:"timestamp"`
}

func (h *TelemetryHandler) RecordTelemetry(c *gin.Context) {
	var req telemetryRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	vehicleID, err := uuid.Parse(req.VehicleID)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid vehicle_id"})
		return
	}

	timestamp := time.Now().UTC()
	if req.Timestamp != "" {
		parsed, err := time.Parse(time.RFC3339, req.Timestamp)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "timestamp must be RFC3339"})
			return
		}
		timestamp = parsed.UTC()
	}

	telemetry := &domain.Telemetry{
		VehicleID:  vehicleID,
		Latitude:   req.Latitude,
		Longitude:  req.Longitude,
		Speed:      req.Speed,
		FuelLevel:  req.FuelLevel,
		OdometerKm: req.OdometerKm,
		Timestamp:  timestamp,
	}

	if err := h.service.RecordTelemetry(telemetry); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, telemetryResponse{
		ID:         telemetry.ID,
		VehicleID:  telemetry.VehicleID,
		Latitude:   telemetry.Latitude,
		Longitude:  telemetry.Longitude,
		Speed:      telemetry.Speed,
		FuelLevel:  telemetry.FuelLevel,
		OdometerKm: telemetry.OdometerKm,
		Timestamp:  telemetry.Timestamp.Format(time.RFC3339),
	})
}
