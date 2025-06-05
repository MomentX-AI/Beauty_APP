package models

import (
	"time"

	"gorm.io/gorm"
)

// Business represents the business model
type Business struct {
	ID          string         `gorm:"primaryKey;type:varchar(36)" json:"id"`
	Name        string         `gorm:"type:varchar(100);not null" json:"name"`
	Description string         `gorm:"type:text" json:"description"`
	Address     string         `gorm:"type:varchar(255)" json:"address"`
	Phone       string         `gorm:"type:varchar(20)" json:"phone"`
	Email       string         `gorm:"type:varchar(255)" json:"email"`
	LogoURL     *string        `gorm:"type:varchar(500)" json:"logo_url,omitempty"`
	SocialLinks *string        `gorm:"type:text" json:"social_links,omitempty"`
	TaxID       *string        `gorm:"type:varchar(20)" json:"tax_id,omitempty"`
	GoogleID    *string        `gorm:"type:varchar(100)" json:"google_id,omitempty"`
	Timezone    string         `gorm:"type:varchar(50);default:'Asia/Taipei'" json:"timezone"`
	LastLoginAt *time.Time     `json:"last_login_at,omitempty"`
	CreatedAt   time.Time      `json:"created_at"`
	UpdatedAt   time.Time      `json:"updated_at"`
	DeletedAt   gorm.DeletedAt `gorm:"index" json:"-"`
}

// TableName specifies the table name for Business model
func (Business) TableName() string {
	return "businesses"
}

// BeforeCreate hook to generate UUID for business ID
func (b *Business) BeforeCreate(tx *gorm.DB) error {
	if b.ID == "" {
		b.ID = generateUUID()
	}
	return nil
}

// CreateBusinessRequest represents the create business request payload
type CreateBusinessRequest struct {
	Name        string `json:"name" binding:"required,min=2,max=100"`
	Description string `json:"description" binding:"required"`
	Address     string `json:"address" binding:"required"`
	Phone       string `json:"phone" binding:"required"`
	Email       string `json:"email" binding:"required,email"`
	LogoURL     string `json:"logo_url,omitempty"`
	SocialLinks string `json:"social_links,omitempty"`
	TaxID       string `json:"tax_id,omitempty"`
	GoogleID    string `json:"google_id,omitempty"`
	Timezone    string `json:"timezone,omitempty"`
}

// UpdateBusinessRequest represents the update business request payload
type UpdateBusinessRequest struct {
	Name        string `json:"name" binding:"omitempty,min=2,max=100"`
	Description string `json:"description" binding:"omitempty"`
	Address     string `json:"address" binding:"omitempty"`
	Phone       string `json:"phone" binding:"omitempty"`
	Email       string `json:"email" binding:"omitempty,email"`
	LogoURL     string `json:"logo_url,omitempty"`
	SocialLinks string `json:"social_links,omitempty"`
	TaxID       string `json:"tax_id,omitempty"`
	GoogleID    string `json:"google_id,omitempty"`
	Timezone    string `json:"timezone,omitempty"`
}

// ToModel converts CreateBusinessRequest to Business model
func (r *CreateBusinessRequest) ToModel() *Business {
	business := &Business{
		Name:        r.Name,
		Description: r.Description,
		Address:     r.Address,
		Phone:       r.Phone,
		Email:       r.Email,
		Timezone:    "Asia/Taipei",
	}

	if r.LogoURL != "" {
		business.LogoURL = &r.LogoURL
	}
	if r.SocialLinks != "" {
		business.SocialLinks = &r.SocialLinks
	}
	if r.TaxID != "" {
		business.TaxID = &r.TaxID
	}
	if r.GoogleID != "" {
		business.GoogleID = &r.GoogleID
	}
	if r.Timezone != "" {
		business.Timezone = r.Timezone
	}

	return business
}
