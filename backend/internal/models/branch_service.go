package models

import (
	"time"

	"gorm.io/gorm"
)

// BranchService represents the branch service model - linking branches with services
type BranchService struct {
	ID           string         `gorm:"primaryKey;type:varchar(36)" json:"id"`
	BranchID     string         `gorm:"type:varchar(36);not null;index" json:"branch_id"`
	ServiceID    string         `gorm:"type:varchar(36);not null;index" json:"service_id"`
	IsAvailable  bool           `gorm:"default:true" json:"is_available"`
	CustomPrice  *float64       `gorm:"type:decimal(10,2)" json:"custom_price,omitempty"`  // 分店特定價格
	CustomProfit *float64       `gorm:"type:decimal(10,2)" json:"custom_profit,omitempty"` // 分店特定利潤
	CreatedAt    time.Time      `json:"created_at"`
	UpdatedAt    time.Time      `json:"updated_at"`
	DeletedAt    gorm.DeletedAt `gorm:"index" json:"-"`

	// Relationships
	Branch  *Branch  `gorm:"foreignKey:BranchID" json:"branch,omitempty"`
	Service *Service `gorm:"foreignKey:ServiceID" json:"service,omitempty"`
}

// TableName specifies the table name for BranchService model
func (BranchService) TableName() string {
	return "branch_services"
}

// BeforeCreate hook to generate UUID for branch service ID
func (bs *BranchService) BeforeCreate(tx *gorm.DB) error {
	if bs.ID == "" {
		bs.ID = generateUUID()
	}
	return nil
}

// CreateBranchServiceRequest represents the create branch service request payload
type CreateBranchServiceRequest struct {
	BranchID     string  `json:"branch_id" binding:"required"`
	ServiceID    string  `json:"service_id" binding:"required"`
	IsAvailable  bool    `json:"is_available,omitempty"`
	CustomPrice  float64 `json:"custom_price,omitempty"`
	CustomProfit float64 `json:"custom_profit,omitempty"`
}

// UpdateBranchServiceRequest represents the update branch service request payload
type UpdateBranchServiceRequest struct {
	IsAvailable  *bool    `json:"is_available,omitempty"`
	CustomPrice  *float64 `json:"custom_price,omitempty"`
	CustomProfit *float64 `json:"custom_profit,omitempty"`
}

// ToModel converts CreateBranchServiceRequest to BranchService model
func (r *CreateBranchServiceRequest) ToModel() *BranchService {
	branchService := &BranchService{
		BranchID:    r.BranchID,
		ServiceID:   r.ServiceID,
		IsAvailable: true,
	}

	if !r.IsAvailable {
		branchService.IsAvailable = r.IsAvailable
	}

	if r.CustomPrice > 0 {
		branchService.CustomPrice = &r.CustomPrice
	}

	if r.CustomProfit > 0 {
		branchService.CustomProfit = &r.CustomProfit
	}

	return branchService
}

// GetEffectivePrice returns the effective price (custom price if set, otherwise service price)
func (bs *BranchService) GetEffectivePrice() float64 {
	if bs.CustomPrice != nil {
		return *bs.CustomPrice
	}
	if bs.Service != nil {
		return bs.Service.Price
	}
	return 0
}

// GetEffectiveProfit returns the effective profit (custom profit if set, otherwise service profit)
func (bs *BranchService) GetEffectiveProfit() float64 {
	if bs.CustomProfit != nil {
		return *bs.CustomProfit
	}
	if bs.Service != nil {
		return bs.Service.Profit
	}
	return 0
}
