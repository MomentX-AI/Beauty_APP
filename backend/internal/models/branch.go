package models

import (
	"time"

	"gorm.io/gorm"
)

// Branch represents the branch model
type Branch struct {
	ID                  string         `gorm:"primaryKey;type:varchar(36)" json:"id"`
	BusinessID          string         `gorm:"type:varchar(36);not null;index" json:"business_id"`
	Name                string         `gorm:"type:varchar(100);not null" json:"name"`
	ContactPhone        *string        `gorm:"type:varchar(20)" json:"contact_phone,omitempty"`
	Address             *string        `gorm:"type:varchar(255)" json:"address,omitempty"`
	IsDefault           bool           `gorm:"default:false" json:"is_default"`
	Status              string         `gorm:"type:varchar(20);default:'active'" json:"status"`
	OperatingHoursStart *string        `gorm:"type:varchar(5)" json:"operating_hours_start,omitempty"` // HH:MM format
	OperatingHoursEnd   *string        `gorm:"type:varchar(5)" json:"operating_hours_end,omitempty"`   // HH:MM format
	CreatedAt           time.Time      `json:"created_at"`
	UpdatedAt           time.Time      `json:"updated_at"`
	DeletedAt           gorm.DeletedAt `gorm:"index" json:"-"`

	// Relationships
	Business *Business `gorm:"foreignKey:BusinessID" json:"business,omitempty"`
}

// Branch status constants
const (
	BranchStatusActive   = "active"
	BranchStatusInactive = "inactive"
	BranchStatusClosed   = "closed"
)

// TableName specifies the table name for Branch model
func (Branch) TableName() string {
	return "branches"
}

// BeforeCreate hook to generate UUID for branch ID
func (b *Branch) BeforeCreate(tx *gorm.DB) error {
	if b.ID == "" {
		b.ID = generateUUID()
	}
	return nil
}

// CreateBranchRequest represents the create branch request payload
type CreateBranchRequest struct {
	BusinessID          string `json:"business_id" binding:"required"`
	Name                string `json:"name" binding:"required,min=2,max=100"`
	ContactPhone        string `json:"contact_phone,omitempty"`
	Address             string `json:"address,omitempty"`
	IsDefault           bool   `json:"is_default,omitempty"`
	Status              string `json:"status,omitempty"`
	OperatingHoursStart string `json:"operating_hours_start,omitempty"`
	OperatingHoursEnd   string `json:"operating_hours_end,omitempty"`
}

// UpdateBranchRequest represents the update branch request payload
type UpdateBranchRequest struct {
	Name                string `json:"name" binding:"omitempty,min=2,max=100"`
	ContactPhone        string `json:"contact_phone,omitempty"`
	Address             string `json:"address,omitempty"`
	IsDefault           *bool  `json:"is_default,omitempty"`
	Status              string `json:"status,omitempty"`
	OperatingHoursStart string `json:"operating_hours_start,omitempty"`
	OperatingHoursEnd   string `json:"operating_hours_end,omitempty"`
}

// ToModel converts CreateBranchRequest to Branch model
func (r *CreateBranchRequest) ToModel() *Branch {
	branch := &Branch{
		BusinessID: r.BusinessID,
		Name:       r.Name,
		IsDefault:  r.IsDefault,
		Status:     BranchStatusActive,
	}

	if r.ContactPhone != "" {
		branch.ContactPhone = &r.ContactPhone
	}
	if r.Address != "" {
		branch.Address = &r.Address
	}
	if r.Status != "" {
		branch.Status = r.Status
	}
	if r.OperatingHoursStart != "" {
		branch.OperatingHoursStart = &r.OperatingHoursStart
	}
	if r.OperatingHoursEnd != "" {
		branch.OperatingHoursEnd = &r.OperatingHoursEnd
	}

	return branch
}

// IsActive returns true if the branch is active
func (b *Branch) IsActive() bool {
	return b.Status == BranchStatusActive
}
