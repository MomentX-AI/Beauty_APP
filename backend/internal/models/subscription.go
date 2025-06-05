package models

import (
	"encoding/json"
	"time"

	"gorm.io/gorm"
)

// SubscriptionStatus constants
const (
	SubscriptionStatusActive    = "active"
	SubscriptionStatusExpired   = "expired"
	SubscriptionStatusCancelled = "cancelled"
	SubscriptionStatusTrial     = "trial"
)

// PlanType constants
const (
	PlanTypeBasic    = "basic"
	PlanTypeBusiness = "business"
)

// SubscriptionPlan represents the subscription plan model
type SubscriptionPlan struct {
	ID                    string         `gorm:"primaryKey;type:varchar(36)" json:"id"`
	Type                  string         `gorm:"type:varchar(20);not null" json:"type"`
	Name                  string         `gorm:"type:varchar(100);not null" json:"name"`
	Description           string         `gorm:"type:text" json:"description"`
	PricePerStaffPerMonth float64        `gorm:"type:decimal(10,2);not null" json:"pricePerStaffPerMonth"`
	MaxBranches           int            `gorm:"not null" json:"maxBranches"` // -1 for unlimited
	Features              StringArray    `gorm:"type:json" json:"features"`
	IsActive              bool           `gorm:"default:true" json:"isActive"`
	CreatedAt             time.Time      `json:"created_at"`
	UpdatedAt             time.Time      `json:"updated_at"`
	DeletedAt             gorm.DeletedAt `gorm:"index" json:"-"`
}

// TableName specifies the table name for SubscriptionPlan model
func (SubscriptionPlan) TableName() string {
	return "subscription_plans"
}

// BeforeCreate hook to generate UUID for subscription plan ID
func (sp *SubscriptionPlan) BeforeCreate(tx *gorm.DB) error {
	if sp.ID == "" {
		sp.ID = generateUUID()
	}
	return nil
}

// Subscription represents the subscription model
type Subscription struct {
	ID            string         `gorm:"primaryKey;type:varchar(36)" json:"id"`
	BusinessID    string         `gorm:"type:varchar(36);not null;index" json:"businessId"`
	PlanID        string         `gorm:"type:varchar(36);not null;index" json:"planId"`
	Status        string         `gorm:"type:varchar(20);default:'trial'" json:"status"`
	StartDate     time.Time      `gorm:"not null" json:"startDate"`
	EndDate       time.Time      `gorm:"not null" json:"endDate"`
	CancelledDate *time.Time     `json:"cancelledDate,omitempty"`
	StaffCount    int            `gorm:"not null" json:"staffCount"`
	MonthlyAmount float64        `gorm:"type:decimal(10,2);not null" json:"monthlyAmount"`
	AutoRenewal   bool           `gorm:"default:true" json:"autoRenewal"`
	Metadata      *string        `gorm:"type:json" json:"metadata,omitempty"` // JSON string
	CreatedAt     time.Time      `json:"created_at"`
	UpdatedAt     time.Time      `json:"updated_at"`
	DeletedAt     gorm.DeletedAt `gorm:"index" json:"-"`

	// Relationships
	Business *Business         `gorm:"foreignKey:BusinessID" json:"business,omitempty"`
	Plan     *SubscriptionPlan `gorm:"foreignKey:PlanID" json:"plan,omitempty"`
}

// TableName specifies the table name for Subscription model
func (Subscription) TableName() string {
	return "subscriptions"
}

// BeforeCreate hook to generate UUID for subscription ID
func (s *Subscription) BeforeCreate(tx *gorm.DB) error {
	if s.ID == "" {
		s.ID = generateUUID()
	}
	return nil
}

// CreateSubscriptionRequest represents the create subscription request payload
type CreateSubscriptionRequest struct {
	BusinessID    string                 `json:"businessId" binding:"required"`
	PlanID        string                 `json:"planId" binding:"required"`
	Status        string                 `json:"status,omitempty"`
	StartDate     string                 `json:"startDate" binding:"required"` // YYYY-MM-DD format
	EndDate       string                 `json:"endDate" binding:"required"`   // YYYY-MM-DD format
	StaffCount    int                    `json:"staffCount" binding:"required,min=1"`
	MonthlyAmount float64                `json:"monthlyAmount" binding:"required,min=0"`
	AutoRenewal   bool                   `json:"autoRenewal,omitempty"`
	Metadata      map[string]interface{} `json:"metadata,omitempty"`
}

// UpdateSubscriptionRequest represents the update subscription request payload
type UpdateSubscriptionRequest struct {
	PlanID        string                 `json:"planId,omitempty"`
	Status        string                 `json:"status,omitempty"`
	EndDate       string                 `json:"endDate,omitempty"`
	StaffCount    int                    `json:"staffCount" binding:"omitempty,min=1"`
	MonthlyAmount float64                `json:"monthlyAmount" binding:"omitempty,min=0"`
	AutoRenewal   *bool                  `json:"autoRenewal,omitempty"`
	Metadata      map[string]interface{} `json:"metadata,omitempty"`
}

// ToModel converts CreateSubscriptionRequest to Subscription model
func (r *CreateSubscriptionRequest) ToModel() (*Subscription, error) {
	// Parse start date
	startDate, err := time.Parse("2006-01-02", r.StartDate)
	if err != nil {
		return nil, err
	}

	// Parse end date
	endDate, err := time.Parse("2006-01-02", r.EndDate)
	if err != nil {
		return nil, err
	}

	subscription := &Subscription{
		BusinessID:    r.BusinessID,
		PlanID:        r.PlanID,
		Status:        SubscriptionStatusTrial,
		StartDate:     startDate,
		EndDate:       endDate,
		StaffCount:    r.StaffCount,
		MonthlyAmount: r.MonthlyAmount,
		AutoRenewal:   r.AutoRenewal,
	}

	if r.Status != "" {
		subscription.Status = r.Status
	}

	// Convert metadata to JSON string if provided
	if r.Metadata != nil {
		metadataJSON, err := json.Marshal(r.Metadata)
		if err != nil {
			return nil, err
		}
		metadataStr := string(metadataJSON)
		subscription.Metadata = &metadataStr
	}

	return subscription, nil
}

// IsActive returns true if the subscription is active
func (s *Subscription) IsActive() bool {
	return s.Status == SubscriptionStatusActive
}

// IsExpired returns true if the subscription is expired
func (s *Subscription) IsExpired() bool {
	return s.Status == SubscriptionStatusExpired
}

// IsCancelled returns true if the subscription is cancelled
func (s *Subscription) IsCancelled() bool {
	return s.Status == SubscriptionStatusCancelled
}

// IsTrial returns true if the subscription is in trial
func (s *Subscription) IsTrial() bool {
	return s.Status == SubscriptionStatusTrial
}

// DaysUntilExpiry returns the number of days until the subscription expires
func (s *Subscription) DaysUntilExpiry() int {
	now := time.Now()
	if s.EndDate.Before(now) {
		return 0
	}
	return int(s.EndDate.Sub(now).Hours() / 24)
}

// IsExpiringSoon returns true if the subscription expires within 7 days
func (s *Subscription) IsExpiringSoon() bool {
	return s.DaysUntilExpiry() <= 7 && s.IsActive()
}

// CreatePredefinedPlans creates the predefined subscription plans
func CreatePredefinedPlans() []*SubscriptionPlan {
	basicFeatures := StringArray{
		"單一門店管理",
		"基礎預約管理",
		"客戶資料管理",
		"員工管理",
		"基礎報表分析",
		"AI 助理",
		"基礎技術支援",
	}

	businessFeatures := StringArray{
		"多門店管理",
		"進階預約管理",
		"客戶資料管理",
		"員工管理與排班",
		"進階報表分析",
		"AI 助理",
		"多門店庫存管理",
		"進階權限控制",
		"優先技術支援",
		"自訂報表",
	}

	return []*SubscriptionPlan{
		{
			ID:                    "basic",
			Type:                  PlanTypeBasic,
			Name:                  "Basic 基礎版",
			Description:           "適合單一門店的美容業者",
			PricePerStaffPerMonth: 300.0,
			MaxBranches:           1,
			Features:              basicFeatures,
			IsActive:              true,
		},
		{
			ID:                    "business",
			Type:                  PlanTypeBusiness,
			Name:                  "Business 商業版",
			Description:           "適合多門店連鎖美容業者",
			PricePerStaffPerMonth: 450.0,
			MaxBranches:           -1, // -1 for unlimited
			Features:              businessFeatures,
			IsActive:              true,
		},
	}
}
