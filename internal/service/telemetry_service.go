package service

import (
	"errors"
	"fmt"
	"net/http"
	"net/url"
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"

	"github.com/gjovanovicst/auth_api/internal/domain"
	"github.com/gjovanovicst/auth_api/internal/repository"
)

type TelemetryService interface {
	RecordTelemetry(telemetry *domain.Telemetry) error
}

type telemetryService struct {
	repo         repository.TelemetryRepository
	vehicleRepo  repository.VehicleRepository
	alertURL     string
	httpClient   *http.Client
}

func NewTelemetryService(repo repository.TelemetryRepository, vehicleRepo repository.VehicleRepository, alertURL string) TelemetryService {
	return &telemetryService{
		repo:        repo,
		vehicleRepo: vehicleRepo,
		alertURL:    alertURL,
		httpClient: &http.Client{
			Timeout: 5 * time.Second,
		},
	}
}

func (s *telemetryService) RecordTelemetry(telemetry *domain.Telemetry) error {
	if telemetry.ID == uuid.Nil {
		telemetry.ID = uuid.New()
	}

	if telemetry.VehicleID == uuid.Nil {
		return fmt.Errorf("vehicle_id is required")
	}

	if telemetry.Timestamp.IsZero() {
		telemetry.Timestamp = time.Now().UTC()
	}

	vehicle, err := s.vehicleRepo.GetByID(telemetry.VehicleID)
	if err != nil {
		return fmt.Errorf("vehicle lookup failed: %w", err)
	}

	if telemetry.OdometerKm < 0 {
		return fmt.Errorf("odometer_km must be positive")
	}

	lastTelemetry, err := s.repo.LastForVehicle(telemetry.VehicleID)
	if err != nil && !errors.Is(err, gorm.ErrRecordNotFound) {
		return fmt.Errorf("telemetry lookup failed: %w", err)
	}

	if err := s.repo.Create(telemetry); err != nil {
		return err
	}

	if shouldTriggerMaintenance(lastTelemetry, telemetry.OdometerKm) {
		return s.triggerMaintenanceAlert(vehicle, telemetry)
	}

	return nil
}

func shouldTriggerMaintenance(lastTelemetry *domain.Telemetry, currentOdometer float64) bool {
	if currentOdometer < 5000 {
		return false
	}

	lastOdometer := 0.0
	if lastTelemetry != nil {
		lastOdometer = lastTelemetry.OdometerKm
	}

	lastStep := int(lastOdometer/5000)
	currentStep := int(currentOdometer/5000)

	return currentStep > lastStep
}

func (s *telemetryService) triggerMaintenanceAlert(vehicle *domain.Vehicle, telemetry *domain.Telemetry) error {
	message := fmt.Sprintf("vehicle %s reached %.0f km for maintenance", vehicle.Plate, telemetry.OdometerKm)
	alert := map[string]interface{}{
		"vehicle_id":    vehicle.ID.String(),
		"tenant_id":     vehicle.TenantID.String(),
		"plate":         vehicle.Plate,
		"odometer_km":   telemetry.OdometerKm,
		"timestamp":     telemetry.Timestamp.Format(time.RFC3339),
		"message":       message,
		"maintenance":   true,
	}

	if s.alertURL == "" {
		// Log structured alert if alert URL isn't configured
		fmt.Printf("maintenance alert: %+v\n", alert)
		return nil
	}

	parsed, err := url.Parse(s.alertURL)
	if err != nil {
		return fmt.Errorf("invalid alert URL: %w", err)
	}

	if parsed.Scheme != "http" && parsed.Scheme != "https" {
		return fmt.Errorf("alert URL must be http(s)")
	}

	resp, err := s.httpClient.PostForm(s.alertURL, url.Values{
		"vehicle_id":  {vehicle.ID.String()},
		"tenant_id":   {vehicle.TenantID.String()},
		"plate":       {vehicle.Plate},
		"odometer_km": {fmt.Sprintf("%.0f", telemetry.OdometerKm)},
		"timestamp":   {telemetry.Timestamp.Format(time.RFC3339)},
		"message":     {message},
	})
	if err != nil {
		return fmt.Errorf("failed to post maintenance alert: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode >= 300 {
		return fmt.Errorf("maintenance alert returned status %d", resp.StatusCode)
	}

	return nil
}
