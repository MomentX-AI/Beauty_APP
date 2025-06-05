package models

import (
	"time"

	"gorm.io/gorm"
)

// Customer represents the customer model
type Customer struct {
	ID                string         `gorm:"primaryKey;type:varchar(36)" json:"id"`
	BusinessID        string         `gorm:"type:varchar(36);not null;index" json:"business_id"`
	Name              string         `gorm:"type:varchar(100);not null" json:"name"`
	Gender            *string        `gorm:"type:varchar(10)" json:"gender,omitempty"`
	Phone             *string        `gorm:"type:varchar(20);index" json:"phone,omitempty"`
	Email             *string        `gorm:"type:varchar(255);index" json:"email,omitempty"`
	IsArchived        bool           `gorm:"default:false" json:"is_archived"`
	NeedsMerge        bool           `gorm:"default:false" json:"needs_merge"`
	IsSpecialCustomer bool           `gorm:"default:false" json:"is_special_customer"`
	Source            *string        `gorm:"type:varchar(50)" json:"source,omitempty"`
	CreatedAt         time.Time      `json:"created_at"`
	UpdatedAt         time.Time      `json:"updated_at"`
	DeletedAt         gorm.DeletedAt `gorm:"index" json:"-"`

	// Relationships
	Business *Business `gorm:"foreignKey:BusinessID" json:"business,omitempty"`
}

// TableName specifies the table name for Customer model
func (Customer) TableName() string {
	return "customers"
}

// BeforeCreate hook to generate UUID for customer ID
func (c *Customer) BeforeCreate(tx *gorm.DB) error {
	if c.ID == "" {
		c.ID = generateUUID()
	}
	return nil
}

// CreateCustomerRequest represents the create customer request payload
type CreateCustomerRequest struct {
	BusinessID        string `json:"business_id" binding:"required"`
	Name              string `json:"name" binding:"required,min=2,max=100"`
	Gender            string `json:"gender,omitempty"`
	Phone             string `json:"phone,omitempty"`
	Email             string `json:"email,omitempty"`
	IsArchived        bool   `json:"is_archived,omitempty"`
	NeedsMerge        bool   `json:"needs_merge,omitempty"`
	IsSpecialCustomer bool   `json:"is_special_customer,omitempty"`
	Source            string `json:"source,omitempty"`
}

// UpdateCustomerRequest represents the update customer request payload
type UpdateCustomerRequest struct {
	Name              string `json:"name" binding:"omitempty,min=2,max=100"`
	Gender            string `json:"gender,omitempty"`
	Phone             string `json:"phone,omitempty"`
	Email             string `json:"email,omitempty"`
	IsArchived        *bool  `json:"is_archived,omitempty"`
	NeedsMerge        *bool  `json:"needs_merge,omitempty"`
	IsSpecialCustomer *bool  `json:"is_special_customer,omitempty"`
	Source            string `json:"source,omitempty"`
}

// ToModel converts CreateCustomerRequest to Customer model
func (r *CreateCustomerRequest) ToModel() *Customer {
	customer := &Customer{
		BusinessID:        r.BusinessID,
		Name:              r.Name,
		IsArchived:        r.IsArchived,
		NeedsMerge:        r.NeedsMerge,
		IsSpecialCustomer: r.IsSpecialCustomer,
	}

	if r.Gender != "" {
		customer.Gender = &r.Gender
	}
	if r.Phone != "" {
		customer.Phone = &r.Phone
	}
	if r.Email != "" {
		customer.Email = &r.Email
	}
	if r.Source != "" {
		customer.Source = &r.Source
	}

	return customer
}

// IsActive returns true if the customer is not archived
func (c *Customer) IsActive() bool {
	return !c.IsArchived
}
