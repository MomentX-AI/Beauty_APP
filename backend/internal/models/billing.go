package models

import (
	"encoding/json"
	"time"

	"gorm.io/gorm"
)

// BillingStatus constants
const (
	BillingStatusPending   = "pending"
	BillingStatusPaid      = "paid"
	BillingStatusOverdue   = "overdue"
	BillingStatusCancelled = "cancelled"
	BillingStatusRefunded  = "refunded"
)

// PaymentMethod constants
const (
	PaymentMethodCreditCard   = "creditCard"
	PaymentMethodBankTransfer = "bankTransfer"
	PaymentMethodCash         = "cash"
	PaymentMethodOther        = "other"
)

// Billing represents the billing model
type Billing struct {
	ID               string         `gorm:"primaryKey;type:varchar(36)" json:"id"`
	BusinessID       string         `gorm:"type:varchar(36);not null;index" json:"businessId"`
	SubscriptionID   string         `gorm:"type:varchar(36);not null;index" json:"subscriptionId"`
	BillingDate      time.Time      `gorm:"not null" json:"billingDate"`
	DueDate          time.Time      `gorm:"not null" json:"dueDate"`
	PaidDate         *time.Time     `json:"paidDate,omitempty"`
	Status           string         `gorm:"type:varchar(20);default:'pending'" json:"status"`
	Amount           float64        `gorm:"type:decimal(10,2);not null" json:"amount"`
	TaxAmount        float64        `gorm:"type:decimal(10,2);default:0" json:"taxAmount"`
	TotalAmount      float64        `gorm:"type:decimal(10,2);not null" json:"totalAmount"`
	PaymentMethod    *string        `gorm:"type:varchar(20)" json:"paymentMethod,omitempty"`
	PaymentReference *string        `gorm:"type:varchar(100)" json:"paymentReference,omitempty"`
	StaffCount       int            `gorm:"not null" json:"staffCount"`
	PlanName         string         `gorm:"type:varchar(100);not null" json:"planName"`
	PricePerStaff    float64        `gorm:"type:decimal(10,2);not null" json:"pricePerStaff"`
	Notes            *string        `gorm:"type:text" json:"notes,omitempty"`
	Metadata         *string        `gorm:"type:json" json:"metadata,omitempty"` // JSON string
	CreatedAt        time.Time      `json:"created_at"`
	UpdatedAt        time.Time      `json:"updated_at"`
	DeletedAt        gorm.DeletedAt `gorm:"index" json:"-"`

	// Relationships
	Business     *Business     `gorm:"foreignKey:BusinessID" json:"business,omitempty"`
	Subscription *Subscription `gorm:"foreignKey:SubscriptionID" json:"subscription,omitempty"`
}

// TableName specifies the table name for Billing model
func (Billing) TableName() string {
	return "billings"
}

// BeforeCreate hook to generate UUID for billing ID
func (b *Billing) BeforeCreate(tx *gorm.DB) error {
	if b.ID == "" {
		b.ID = generateUUID()
	}
	return nil
}

// CreateBillingRequest represents the create billing request payload
type CreateBillingRequest struct {
	BusinessID     string                 `json:"businessId" binding:"required"`
	SubscriptionID string                 `json:"subscriptionId" binding:"required"`
	BillingDate    string                 `json:"billingDate" binding:"required"` // YYYY-MM-DD format
	DueDate        string                 `json:"dueDate" binding:"required"`     // YYYY-MM-DD format
	Amount         float64                `json:"amount" binding:"required,min=0"`
	TaxAmount      float64                `json:"taxAmount" binding:"omitempty,min=0"`
	TotalAmount    float64                `json:"totalAmount" binding:"required,min=0"`
	StaffCount     int                    `json:"staffCount" binding:"required,min=1"`
	PlanName       string                 `json:"planName" binding:"required"`
	PricePerStaff  float64                `json:"pricePerStaff" binding:"required,min=0"`
	Notes          string                 `json:"notes,omitempty"`
	Metadata       map[string]interface{} `json:"metadata,omitempty"`
}

// UpdateBillingRequest represents the update billing request payload
type UpdateBillingRequest struct {
	Status           string                 `json:"status,omitempty"`
	PaidDate         string                 `json:"paidDate,omitempty"` // YYYY-MM-DD format
	PaymentMethod    string                 `json:"paymentMethod,omitempty"`
	PaymentReference string                 `json:"paymentReference,omitempty"`
	Notes            string                 `json:"notes,omitempty"`
	Metadata         map[string]interface{} `json:"metadata,omitempty"`
}

// ToModel converts CreateBillingRequest to Billing model
func (r *CreateBillingRequest) ToModel() (*Billing, error) {
	// Parse billing date
	billingDate, err := time.Parse("2006-01-02", r.BillingDate)
	if err != nil {
		return nil, err
	}

	// Parse due date
	dueDate, err := time.Parse("2006-01-02", r.DueDate)
	if err != nil {
		return nil, err
	}

	billing := &Billing{
		BusinessID:     r.BusinessID,
		SubscriptionID: r.SubscriptionID,
		BillingDate:    billingDate,
		DueDate:        dueDate,
		Status:         BillingStatusPending,
		Amount:         r.Amount,
		TaxAmount:      r.TaxAmount,
		TotalAmount:    r.TotalAmount,
		StaffCount:     r.StaffCount,
		PlanName:       r.PlanName,
		PricePerStaff:  r.PricePerStaff,
	}

	if r.Notes != "" {
		billing.Notes = &r.Notes
	}

	// Convert metadata to JSON string if provided
	if r.Metadata != nil {
		metadataJSON, err := json.Marshal(r.Metadata)
		if err != nil {
			return nil, err
		}
		metadataStr := string(metadataJSON)
		billing.Metadata = &metadataStr
	}

	return billing, nil
}

// IsPaid returns true if the billing is paid
func (b *Billing) IsPaid() bool {
	return b.Status == BillingStatusPaid
}

// IsPending returns true if the billing is pending
func (b *Billing) IsPending() bool {
	return b.Status == BillingStatusPending
}

// IsOverdue returns true if the billing is overdue
func (b *Billing) IsOverdue() bool {
	return b.Status == BillingStatusOverdue
}

// DaysUntilDue returns the number of days until the billing is due
func (b *Billing) DaysUntilDue() int {
	now := time.Now()
	if b.DueDate.Before(now) {
		return 0
	}
	return int(b.DueDate.Sub(now).Hours() / 24)
}

// DaysOverdue returns the number of days the billing is overdue
func (b *Billing) DaysOverdue() int {
	now := time.Now()
	if b.DueDate.After(now) {
		return 0
	}
	return int(now.Sub(b.DueDate).Hours() / 24)
}
