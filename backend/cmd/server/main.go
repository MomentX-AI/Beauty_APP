package main

import (
	"fmt"
	"log"
	"os"

	_ "beautyai-backend/docs" // swagger docs
	"beautyai-backend/internal/handlers"
	"beautyai-backend/internal/middleware"
	"beautyai-backend/internal/models"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
	swaggerFiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"
	"go.uber.org/zap"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

// @title BeautyAI API
// @version 1.0
// @description BeautyAI Beauty Management System API Documentation
// @termsOfService http://swagger.io/terms/

// @contact.name BeautyAI Team
// @contact.email dev@beautyaigo.com

// @license.name MIT
// @license.url https://opensource.org/licenses/MIT

// @host localhost:3001
// @BasePath /api/v1

// @securityDefinitions.apikey BearerAuth
// @in header
// @name Authorization
// @description Type "Bearer" followed by a space and JWT token.

func main() {
	// Load environment variables
	if err := godotenv.Load(); err != nil {
		log.Println("Warning: .env file not found")
	}

	// Initialize logger
	logger, err := zap.NewProduction()
	if err != nil {
		log.Fatal("Failed to initialize logger:", err)
	}
	defer logger.Sync()

	// Initialize database
	db, err := initDatabase(logger)
	if err != nil {
		logger.Fatal("Failed to initialize database", zap.Error(err))
	}

	// Auto migrate database schemas
	if err := autoMigrate(db, logger); err != nil {
		logger.Fatal("Failed to migrate database", zap.Error(err))
	}

	// Initialize Gin router
	router := gin.Default()

	// Setup middleware
	setupMiddleware(router, logger)

	// Setup routes
	setupRoutes(router, db, logger)

	// Get port from environment
	port := os.Getenv("PORT")
	if port == "" {
		port = "3001"
	}

	logger.Info("Starting server", zap.String("port", port))

	// Start server
	if err := router.Run(":" + port); err != nil {
		logger.Fatal("Failed to start server", zap.Error(err))
	}
}

// initDatabase initializes the database connection
func initDatabase(logger *zap.Logger) (*gorm.DB, error) {
	// Build database connection string
	dbHost := os.Getenv("DB_HOST")
	if dbHost == "" {
		dbHost = "localhost"
	}

	dbPort := os.Getenv("DB_PORT")
	if dbPort == "" {
		dbPort = "5432"
	}

	dbName := os.Getenv("DB_NAME")
	if dbName == "" {
		dbName = "beautyai"
	}

	dbUser := os.Getenv("DB_USER")
	if dbUser == "" {
		dbUser = "postgres"
	}

	dbPassword := os.Getenv("DB_PASSWORD")
	if dbPassword == "" {
		dbPassword = "password"
	}

	sslMode := os.Getenv("DB_SSLMODE")
	if sslMode == "" {
		sslMode = "disable"
	}

	dsn := fmt.Sprintf("host=%s user=%s password=%s dbname=%s port=%s sslmode=%s TimeZone=Asia/Taipei",
		dbHost, dbUser, dbPassword, dbName, dbPort, sslMode)

	logger.Info("Connecting to database", zap.String("host", dbHost), zap.String("port", dbPort), zap.String("database", dbName))

	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		return nil, fmt.Errorf("failed to connect database: %w", err)
	}

	logger.Info("Database connected successfully")
	return db, nil
}

// autoMigrate runs database migrations
func autoMigrate(db *gorm.DB, logger *zap.Logger) error {
	logger.Info("Running database migrations")

	// Migrate in correct order - referenced tables first
	err := db.AutoMigrate(
		&models.Business{},     // Business must be created first
		&models.User{},         // User references Business
		&models.Branch{},       // Branch references Business
		&models.Staff{},        // Staff references Business
		&models.Customer{},     // Customer references Business
		&models.Service{},      // Service references Business
		&models.Appointment{},  // Appointment references multiple tables
		&models.BusinessGoal{}, // BusinessGoal references Business, Branch, Staff
		&models.SubscriptionPlan{},
		&models.Subscription{},  // Subscription references Business and Plan
		&models.Billing{},       // Billing references Business and Subscription
		&models.BranchService{}, // BranchService references Branch and Service
	)

	if err != nil {
		return fmt.Errorf("failed to migrate database: %w", err)
	}

	logger.Info("Database migrations completed successfully")
	return nil
}

// setupMiddleware configures middleware for the router
func setupMiddleware(router *gin.Engine, logger *zap.Logger) {
	// CORS middleware
	config := cors.DefaultConfig()
	config.AllowOrigins = []string{
		"http://localhost:3000",
		"http://localhost:3001",
		"http://127.0.0.1:3000",
		"http://127.0.0.1:3001",
	}
	config.AllowHeaders = []string{
		"Origin",
		"Content-Type",
		"Accept",
		"Authorization",
		"X-Requested-With",
	}
	config.AllowCredentials = true
	router.Use(cors.New(config))

	// Request logging middleware
	router.Use(gin.Logger())

	// Recovery middleware
	router.Use(gin.Recovery())
}

// setupRoutes configures all API routes
func setupRoutes(router *gin.Engine, db *gorm.DB, logger *zap.Logger) {
	// Health check endpoint
	router.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"status":  "healthy",
			"service": "beautyai-backend",
			"version": "1.0.0",
		})
	})

	// Initialize handlers
	authHandler := handlers.NewAuthHandler(db, logger)

	// API v1 routes
	v1 := router.Group("/api/v1")
	{
		// Public authentication routes
		auth := v1.Group("/auth")
		{
			auth.POST("/register", authHandler.Register)
			auth.POST("/login", authHandler.Login)
			auth.POST("/refresh", authHandler.RefreshToken)
		}

		// Protected authentication routes
		authProtected := v1.Group("/auth")
		authProtected.Use(middleware.AuthMiddleware(logger))
		{
			authProtected.POST("/logout", authHandler.Logout)
			authProtected.GET("/me", authHandler.GetProfile)
			authProtected.PUT("/profile", authHandler.UpdateProfile)
			authProtected.POST("/change-password", authHandler.ChangePassword)
		}

		// TODO: Add other protected routes here
		// Protected routes for business management
		// protected := v1.Group("")
		// protected.Use(middleware.AuthMiddleware(logger))
		// {
		//     // Business routes
		//     protected.GET("/business", businessHandler.GetBusiness)
		//     protected.PUT("/business", businessHandler.UpdateBusiness)
		//
		//     // Branch routes
		//     protected.GET("/branches", branchHandler.GetBranches)
		//     protected.POST("/branches", branchHandler.CreateBranch)
		//
		//     // Staff routes
		//     protected.GET("/staff", staffHandler.GetStaff)
		//     protected.POST("/staff", staffHandler.CreateStaff)
		//
		//     // Customer routes
		//     protected.GET("/customers", customerHandler.GetCustomers)
		//     protected.POST("/customers", customerHandler.CreateCustomer)
		//
		//     // Service routes
		//     protected.GET("/services", serviceHandler.GetServices)
		//     protected.POST("/services", serviceHandler.CreateService)
		//
		//     // Appointment routes
		//     protected.GET("/appointments", appointmentHandler.GetAppointments)
		//     protected.POST("/appointments", appointmentHandler.CreateAppointment)
		// }
	}

	// Swagger documentation
	router.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))

	logger.Info("Routes configured successfully")
}
