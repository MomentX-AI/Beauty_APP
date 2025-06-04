package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"beautyai-backend/internal/config"
	"beautyai-backend/internal/handlers"
	"beautyai-backend/internal/middleware"
	"beautyai-backend/pkg/database"
	"beautyai-backend/pkg/logger"

	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
	"go.uber.org/zap"
)

// @title BeautyAI API
// @version 1.0
// @description BeautyAI Beauty Management System API Documentation
// @termsOfService http://swagger.io/terms/

// @contact.name BeautyAI Team
// @contact.email dev@beautyaigo.com

// @license.name MIT
// @license.url https://opensource.org/licenses/MIT

// @host localhost:3000
// @BasePath /api/v1

// @securityDefinitions.apikey BearerAuth
// @in header
// @name Authorization
// @description Type "Bearer" followed by a space and JWT token.

func main() {
	// Load environment variables
	if err := godotenv.Load(); err != nil {
		log.Println("No .env file found, using environment variables")
	}

	// Initialize configuration
	cfg := config.Load()

	// Initialize logger
	logger := logger.New(cfg.Log.Level, cfg.Log.Format)
	defer logger.Sync()

	// Set Gin mode
	if cfg.App.Environment == "production" {
		gin.SetMode(gin.ReleaseMode)
	}

	// Initialize database
	db, err := database.NewConnection(cfg)
	if err != nil {
		logger.Fatal("Failed to connect to database", zap.Error(err))
	}

	// Initialize Gin router
	router := gin.New()

	// Add middleware
	router.Use(middleware.Logger(logger))
	router.Use(middleware.Recovery(logger))
	router.Use(middleware.CORS(cfg))
	router.Use(middleware.RequestID())
	router.Use(middleware.Security())

	// Health check endpoint
	router.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"status":      "OK",
			"timestamp":   time.Now().UTC(),
			"environment": cfg.App.Environment,
			"version":     "1.0.0",
		})
	})

	// API routes
	v1 := router.Group("/api/v1")
	{
		// Initialize handlers
		authHandler := handlers.NewAuthHandler(db, cfg, logger)
		businessHandler := handlers.NewBusinessHandler(db, cfg, logger)
		branchHandler := handlers.NewBranchHandler(db, cfg, logger)
		staffHandler := handlers.NewStaffHandler(db, cfg, logger)
		customerHandler := handlers.NewCustomerHandler(db, cfg, logger)
		serviceHandler := handlers.NewServiceHandler(db, cfg, logger)
		appointmentHandler := handlers.NewAppointmentHandler(db, cfg, logger)
		analyticsHandler := handlers.NewAnalyticsHandler(db, cfg, logger)
		subscriptionHandler := handlers.NewSubscriptionHandler(db, cfg, logger)
		billingHandler := handlers.NewBillingHandler(db, cfg, logger)

		// Auth routes
		auth := v1.Group("/auth")
		{
			auth.POST("/register", authHandler.Register)
			auth.POST("/login", authHandler.Login)
			auth.POST("/logout", middleware.AuthRequired(), authHandler.Logout)
			auth.GET("/me", middleware.AuthRequired(), authHandler.GetProfile)
			auth.POST("/refresh", authHandler.RefreshToken)
		}

		// Protected routes
		protected := v1.Group("/")
		protected.Use(middleware.AuthRequired())
		{
			// Business routes
			business := protected.Group("/business")
			{
				business.GET("/", businessHandler.GetBusiness)
				business.PUT("/", businessHandler.UpdateBusiness)
			}

			// Branch routes
			branches := protected.Group("/branches")
			{
				branches.GET("/", branchHandler.GetBranches)
				branches.POST("/", branchHandler.CreateBranch)
				branches.GET("/:id", branchHandler.GetBranch)
				branches.PUT("/:id", branchHandler.UpdateBranch)
				branches.DELETE("/:id", branchHandler.DeleteBranch)
			}

			// Staff routes
			staff := protected.Group("/staff")
			{
				staff.GET("/", staffHandler.GetStaff)
				staff.POST("/", staffHandler.CreateStaff)
				staff.GET("/:id", staffHandler.GetStaffMember)
				staff.PUT("/:id", staffHandler.UpdateStaff)
				staff.DELETE("/:id", staffHandler.DeleteStaff)
				staff.GET("/:id/performance", staffHandler.GetStaffPerformance)
			}

			// Customer routes
			customers := protected.Group("/customers")
			{
				customers.GET("/", customerHandler.GetCustomers)
				customers.POST("/", customerHandler.CreateCustomer)
				customers.GET("/:id", customerHandler.GetCustomer)
				customers.PUT("/:id", customerHandler.UpdateCustomer)
				customers.DELETE("/:id", customerHandler.DeleteCustomer)
			}

			// Service routes
			services := protected.Group("/services")
			{
				services.GET("/", serviceHandler.GetServices)
				services.POST("/", serviceHandler.CreateService)
				services.GET("/:id", serviceHandler.GetService)
				services.PUT("/:id", serviceHandler.UpdateService)
				services.DELETE("/:id", serviceHandler.DeleteService)
			}

			// Appointment routes
			appointments := protected.Group("/appointments")
			{
				appointments.GET("/", appointmentHandler.GetAppointments)
				appointments.POST("/", appointmentHandler.CreateAppointment)
				appointments.GET("/:id", appointmentHandler.GetAppointment)
				appointments.PUT("/:id", appointmentHandler.UpdateAppointment)
				appointments.DELETE("/:id", appointmentHandler.DeleteAppointment)
			}

			// Analytics routes
			analytics := protected.Group("/analytics")
			{
				analytics.GET("/dashboard", analyticsHandler.GetDashboard)
				analytics.GET("/performance", analyticsHandler.GetPerformance)
				analytics.GET("/goals", analyticsHandler.GetGoals)
			}

			// Subscription routes
			subscriptions := protected.Group("/subscriptions")
			{
				subscriptions.GET("/", subscriptionHandler.GetSubscription)
				subscriptions.PUT("/plan", subscriptionHandler.UpdatePlan)
			}

			// Billing routes
			billing := protected.Group("/billing")
			{
				billing.GET("/", billingHandler.GetBills)
				billing.GET("/:id", billingHandler.GetBill)
				billing.POST("/:id/pay", billingHandler.PayBill)
			}
		}
	}

	// Swagger documentation
	router.Static("/docs", "./docs")

	// Start server
	srv := &http.Server{
		Addr:    fmt.Sprintf(":%s", cfg.Server.Port),
		Handler: router,
	}

	// Graceful shutdown
	go func() {
		logger.Info(fmt.Sprintf("🚀 BeautyAI API Server starting on port %s", cfg.Server.Port))
		logger.Info(fmt.Sprintf("📝 API Documentation: http://localhost:%s/docs", cfg.Server.Port))
		logger.Info(fmt.Sprintf("🏥 Health Check: http://localhost:%s/health", cfg.Server.Port))
		logger.Info(fmt.Sprintf("🌍 Environment: %s", cfg.App.Environment))

		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			logger.Fatal("Failed to start server", zap.Error(err))
		}
	}()

	// Wait for interrupt signal to gracefully shutdown
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit

	logger.Info("🛑 Shutting down server...")

	// Graceful shutdown with timeout
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	if err := srv.Shutdown(ctx); err != nil {
		logger.Fatal("Server forced to shutdown", zap.Error(err))
	}

	logger.Info("✅ Server exited gracefully")
}
