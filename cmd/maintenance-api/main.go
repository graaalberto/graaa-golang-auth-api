package main

import (
	"fmt"
	"log"

	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
	"github.com/spf13/viper"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"

	"github.com/gjovanovicst/auth_api/internal/maintenance"
)

func main() {
	if err := godotenv.Load(); err != nil {
		log.Println("No .env file found, using environment variables")
	}

	viper.AutomaticEnv()
	viper.SetDefault("MAINTENANCE_API_PORT", "8083")
	viper.SetDefault("DB_HOST", "localhost")
	viper.SetDefault("DB_PORT", "5432")
	viper.SetDefault("DB_USER", "postgres")
	viper.SetDefault("DB_PASSWORD", "root")
	viper.SetDefault("DB_NAME", "maintenance_db")
	viper.SetDefault("GIN_MODE", "release")

	port := viper.GetString("MAINTENANCE_API_PORT")
	databaseURL := fmt.Sprintf("postgres://%s:%s@%s:%s/%s?sslmode=disable",
		viper.GetString("DB_USER"),
		viper.GetString("DB_PASSWORD"),
		viper.GetString("DB_HOST"),
		viper.GetString("DB_PORT"),
		viper.GetString("DB_NAME"),
	)

	gin.SetMode(viper.GetString("GIN_MODE"))

	db, err := gorm.Open(postgres.Open(databaseURL), &gorm.Config{})
	if err != nil {
		log.Fatalf("failed to connect to PostgreSQL: %v", err)
	}

	repo := maintenance.NewRepository(db)
	if err := repo.AutoMigrate(); err != nil {
		log.Fatalf("failed to migrate maintenance schema: %v", err)
	}

	service := maintenance.NewService(repo)
	handler := maintenance.NewHandler(service)

	router := gin.New()
	router.Use(gin.Recovery(), gin.Logger())

	api := router.Group("/api/v1")
	api.Use(maintenance.JWTMiddleware())
	{
		api.POST("/work-orders", handler.CreateWorkOrder)
		api.GET("/work-orders", handler.ListWorkOrders)
		api.PATCH("/work-orders/:id/status", handler.UpdateWorkOrderStatus)
		api.POST("/work-orders/:id/parts", handler.AddPartsToWorkOrder)
	}

	router.GET("/healthz", func(c *gin.Context) {
		c.JSON(200, gin.H{"status": "ok"})
	})

	log.Printf("maintenance-api listening on :%s", port)
	if err := router.Run(":" + port); err != nil {
		log.Fatalf("server error: %v", err)
	}
}
