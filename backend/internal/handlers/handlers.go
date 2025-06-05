package handlers

import (
	"beautyai-backend/internal/config"
	"beautyai-backend/pkg/database"

	"go.uber.org/zap"
)

// AuthHandler definition is in auth.go file

// BusinessHandler handles business related requests
type BusinessHandler struct {
	db     database.Database
	config *config.Config
	logger *zap.Logger
}

// BranchHandler handles branch related requests
type BranchHandler struct {
	db     database.Database
	config *config.Config
	logger *zap.Logger
}

// StaffHandler handles staff related requests
type StaffHandler struct {
	db     database.Database
	config *config.Config
	logger *zap.Logger
}

// CustomerHandler handles customer related requests
type CustomerHandler struct {
	db     database.Database
	config *config.Config
	logger *zap.Logger
}

// ServiceHandler handles service related requests
type ServiceHandler struct {
	db     database.Database
	config *config.Config
	logger *zap.Logger
}

// AppointmentHandler handles appointment related requests
type AppointmentHandler struct {
	db     database.Database
	config *config.Config
	logger *zap.Logger
}

// AnalyticsHandler handles analytics related requests
type AnalyticsHandler struct {
	db     database.Database
	config *config.Config
	logger *zap.Logger
}

// SubscriptionHandler handles subscription related requests
type SubscriptionHandler struct {
	db     database.Database
	config *config.Config
	logger *zap.Logger
}

// BillingHandler handles billing related requests
type BillingHandler struct {
	db     database.Database
	config *config.Config
	logger *zap.Logger
}

// Constructor functions
// NewAuthHandler definition is in auth.go file

func NewBusinessHandler(db database.Database, config *config.Config, logger *zap.Logger) *BusinessHandler {
	return &BusinessHandler{db: db, config: config, logger: logger}
}

func NewBranchHandler(db database.Database, config *config.Config, logger *zap.Logger) *BranchHandler {
	return &BranchHandler{db: db, config: config, logger: logger}
}

func NewStaffHandler(db database.Database, config *config.Config, logger *zap.Logger) *StaffHandler {
	return &StaffHandler{db: db, config: config, logger: logger}
}

func NewCustomerHandler(db database.Database, config *config.Config, logger *zap.Logger) *CustomerHandler {
	return &CustomerHandler{db: db, config: config, logger: logger}
}

func NewServiceHandler(db database.Database, config *config.Config, logger *zap.Logger) *ServiceHandler {
	return &ServiceHandler{db: db, config: config, logger: logger}
}

func NewAppointmentHandler(db database.Database, config *config.Config, logger *zap.Logger) *AppointmentHandler {
	return &AppointmentHandler{db: db, config: config, logger: logger}
}

func NewAnalyticsHandler(db database.Database, config *config.Config, logger *zap.Logger) *AnalyticsHandler {
	return &AnalyticsHandler{db: db, config: config, logger: logger}
}

func NewSubscriptionHandler(db database.Database, config *config.Config, logger *zap.Logger) *SubscriptionHandler {
	return &SubscriptionHandler{db: db, config: config, logger: logger}
}

func NewBillingHandler(db database.Database, config *config.Config, logger *zap.Logger) *BillingHandler {
	return &BillingHandler{db: db, config: config, logger: logger}
}
