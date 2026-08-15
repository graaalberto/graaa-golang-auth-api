package main

import (
	"fmt"
	"log"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
	"github.com/spf13/viper"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"

	"github.com/gjovanovicst/auth_api/internal/domain"
	"github.com/gjovanovicst/auth_api/internal/handler"
	"github.com/gjovanovicst/auth_api/internal/middleware"
	"github.com/gjovanovicst/auth_api/internal/repository"
	"github.com/gjovanovicst/auth_api/internal/service"
)

func main() {
	if err := godotenv.Load(); err != nil {
		log.Println("No .env file found, using environment variables")
	}

	viper.AutomaticEnv()
	viper.SetDefault("FLEET_API_PORT", "8081")
	viper.SetDefault("DATABASE_URL", "")
	viper.SetDefault("DB_HOST", "localhost")
	viper.SetDefault("DB_PORT", "5432")
	viper.SetDefault("DB_USER", "postgres")
	viper.SetDefault("DB_PASSWORD", "root")
	viper.SetDefault("DB_NAME", "auth_db")
	viper.SetDefault("FLEET_API_JWT_SECRET", "change-me")
	viper.SetDefault("MAINTENANCE_ALERT_URL", "")
	viper.SetDefault("GIN_MODE", "release")

	port := viper.GetString("FLEET_API_PORT")
	databaseURL := viper.GetString("DATABASE_URL")
	if databaseURL == "" {
		databaseURL = fmt.Sprintf("postgres://%s:%s@%s:%s/%s?sslmode=disable",
			viper.GetString("DB_USER"),
			viper.GetString("DB_PASSWORD"),
			viper.GetString("DB_HOST"),
			viper.GetString("DB_PORT"),
			viper.GetString("DB_NAME"),
		)
	}

	alertURL := viper.GetString("MAINTENANCE_ALERT_URL")

	gin.SetMode(viper.GetString("GIN_MODE"))

	db, err := gorm.Open(postgres.Open(databaseURL), &gorm.Config{})
	if err != nil {
		log.Fatalf("failed to connect to PostgreSQL: %v", err)
	}

	vehicleRepo := repository.NewVehicleRepository(db)
	telemetryRepo := repository.NewTelemetryRepository(db)
	appRepo := repository.NewAppRepository(db)

	vehicleService := service.NewVehicleService(vehicleRepo)
	telemetryService := service.NewTelemetryService(telemetryRepo, vehicleRepo, alertURL)
	tenantService := service.NewTenantService(appRepo)

	vehicleHandler := handler.NewVehicleHandler(vehicleService, tenantService)
	telemetryHandler := handler.NewTelemetryHandler(telemetryService)

	router := gin.New()
	router.Use(gin.Recovery(), gin.Logger())

	api := router.Group("/api/v1")
	api.Use(middleware.FleetAuthMiddleware())
	{
		api.POST("/vehicles", middleware.RequireAdminRole(), vehicleHandler.CreateVehicle)
		api.GET("/vehicles", vehicleHandler.ListVehicles)
		api.POST("/telemetry", telemetryHandler.RecordTelemetry)
	}

	router.GET("/healthz", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{"status": "ok"})
	})

	log.Printf("fleet-api listening on :%s", port)
	if err := router.Run(":" + port); err != nil {
		log.Fatalf("server error: %v", err)
	}
}

func ensureFleetSchema(db *gorm.DB) error {
	return db.AutoMigrate(&domain.Vehicle{}, &domain.Telemetry{})
}
