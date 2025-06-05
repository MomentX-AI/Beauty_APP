package models

import (
	"time"

	"gorm.io/gorm"
)

// ServiceCategory constants
const (
	ServiceCategoryLash  = "lash"
	ServiceCategoryPMU   = "pmu"
	ServiceCategoryNail  = "nail"
	ServiceCategoryHair  = "hair"
	ServiceCategorySkin  = "skin"
	ServiceCategoryOther = "other"
)

// Service represents the service model
type Service struct {
	ID            string         `gorm:"primaryKey;type:varchar(36)" json:"id"`
	BusinessID    string         `gorm:"type:varchar(36);not null;index" json:"business_id"`
	Name          string         `gorm:"type:varchar(100);not null" json:"name"`
	Category      string         `gorm:"type:varchar(20);not null" json:"category"`
	Duration      int            `gorm:"not null" json:"duration"`       // 分鐘
	RevisitPeriod int            `gorm:"not null" json:"revisit_period"` // 天
	Price         float64        `gorm:"type:decimal(10,2);not null" json:"price"`
	Profit        float64        `gorm:"type:decimal(10,2);not null" json:"profit"`
	Description   *string        `gorm:"type:text" json:"description,omitempty"`
	IsArchived    bool           `gorm:"default:false" json:"is_archived"`
	CreatedAt     time.Time      `json:"created_at"`
	UpdatedAt     time.Time      `json:"updated_at"`
	DeletedAt     gorm.DeletedAt `gorm:"index" json:"-"`

	// Relationships
	Business *Business `gorm:"foreignKey:BusinessID" json:"business,omitempty"`
}

// TableName specifies the table name for Service model
func (Service) TableName() string {
	return "services"
}

// BeforeCreate hook to generate UUID for service ID
func (s *Service) BeforeCreate(tx *gorm.DB) error {
	if s.ID == "" {
		s.ID = generateUUID()
	}
	return nil
}

// CreateServiceRequest represents the create service request payload
type CreateServiceRequest struct {
	BusinessID    string  `json:"business_id" binding:"required"`
	Name          string  `json:"name" binding:"required,min=2,max=100"`
	Category      string  `json:"category" binding:"required"`
	Duration      int     `json:"duration" binding:"required,min=1"`
	RevisitPeriod int     `json:"revisit_period" binding:"required,min=0"`
	Price         float64 `json:"price" binding:"required,min=0"`
	Profit        float64 `json:"profit" binding:"required,min=0"`
	Description   string  `json:"description,omitempty"`
	IsArchived    bool    `json:"is_archived,omitempty"`
}

// UpdateServiceRequest represents the update service request payload
type UpdateServiceRequest struct {
	Name          string  `json:"name" binding:"omitempty,min=2,max=100"`
	Category      string  `json:"category,omitempty"`
	Duration      int     `json:"duration" binding:"omitempty,min=1"`
	RevisitPeriod int     `json:"revisit_period" binding:"omitempty,min=0"`
	Price         float64 `json:"price" binding:"omitempty,min=0"`
	Profit        float64 `json:"profit" binding:"omitempty,min=0"`
	Description   string  `json:"description,omitempty"`
	IsArchived    *bool   `json:"is_archived,omitempty"`
}

// ToModel converts CreateServiceRequest to Service model
func (r *CreateServiceRequest) ToModel() *Service {
	service := &Service{
		BusinessID:    r.BusinessID,
		Name:          r.Name,
		Category:      r.Category,
		Duration:      r.Duration,
		RevisitPeriod: r.RevisitPeriod,
		Price:         r.Price,
		Profit:        r.Profit,
		IsArchived:    r.IsArchived,
	}

	if r.Description != "" {
		service.Description = &r.Description
	}

	return service
}

// IsActive returns true if the service is not archived
func (s *Service) IsActive() bool {
	return !s.IsArchived
}

// ServiceCategoryResponse represents service category information
type ServiceCategoryResponse struct {
	Key         string `json:"key"`
	DisplayName string `json:"display_name"`
}

// GetServiceCategories returns all available service categories
func GetServiceCategories() []ServiceCategoryResponse {
	return []ServiceCategoryResponse{
		{Key: ServiceCategoryLash, DisplayName: "睫毛"},
		{Key: ServiceCategoryPMU, DisplayName: "半永久化妝"},
		{Key: ServiceCategoryNail, DisplayName: "美甲"},
		{Key: ServiceCategoryHair, DisplayName: "美髮"},
		{Key: ServiceCategorySkin, DisplayName: "美容"},
		{Key: ServiceCategoryOther, DisplayName: "其他"},
	}
}
