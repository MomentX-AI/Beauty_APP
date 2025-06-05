package models

import (
	"database/sql/driver"
	"encoding/json"
	"time"

	"gorm.io/gorm"
)

// StaffRole constants
const (
	StaffRoleOwner         = "owner"
	StaffRoleManager       = "manager"
	StaffRoleSeniorStylist = "senior_stylist"
	StaffRoleStylist       = "stylist"
	StaffRoleAssistant     = "assistant"
	StaffRoleReceptionist  = "receptionist"
)

// StaffStatus constants
const (
	StaffStatusActive   = "active"
	StaffStatusInactive = "inactive"
	StaffStatusOnLeave  = "on_leave"
)

// StringArray is a custom type for storing arrays as JSON
type StringArray []string

// Value implements the driver.Valuer interface
func (s StringArray) Value() (driver.Value, error) {
	if len(s) == 0 {
		return "[]", nil
	}
	return json.Marshal(s)
}

// Scan implements the sql.Scanner interface
func (s *StringArray) Scan(value interface{}) error {
	if value == nil {
		*s = []string{}
		return nil
	}

	switch v := value.(type) {
	case []byte:
		return json.Unmarshal(v, s)
	case string:
		return json.Unmarshal([]byte(v), s)
	}

	return nil
}

// Staff represents the staff model
type Staff struct {
	ID               string         `gorm:"primaryKey;type:varchar(36)" json:"id"`
	BusinessID       string         `gorm:"type:varchar(36);not null;index" json:"business_id"`
	Name             string         `gorm:"type:varchar(100);not null" json:"name"`
	Email            *string        `gorm:"type:varchar(255);index" json:"email,omitempty"`
	Phone            *string        `gorm:"type:varchar(20)" json:"phone,omitempty"`
	Role             string         `gorm:"type:varchar(20);not null" json:"role"`
	Status           string         `gorm:"type:varchar(20);default:'active'" json:"status"`
	AvatarURL        *string        `gorm:"type:varchar(500)" json:"avatar_url,omitempty"`
	BirthDate        *time.Time     `json:"birth_date,omitempty"`
	HireDate         time.Time      `json:"hire_date"`
	Address          *string        `gorm:"type:varchar(255)" json:"address,omitempty"`
	EmergencyContact *string        `gorm:"type:varchar(100)" json:"emergency_contact,omitempty"`
	EmergencyPhone   *string        `gorm:"type:varchar(20)" json:"emergency_phone,omitempty"`
	Notes            *string        `gorm:"type:text" json:"notes,omitempty"`
	BranchIDs        StringArray    `gorm:"type:json" json:"branch_ids"`
	ServiceIDs       StringArray    `gorm:"type:json" json:"service_ids"`
	CreatedAt        time.Time      `json:"created_at"`
	UpdatedAt        time.Time      `json:"updated_at"`
	DeletedAt        gorm.DeletedAt `gorm:"index" json:"-"`
}

// TableName specifies the table name for Staff model
func (Staff) TableName() string {
	return "staff"
}

// BeforeCreate hook to generate UUID for staff ID
func (s *Staff) BeforeCreate(tx *gorm.DB) error {
	if s.ID == "" {
		s.ID = generateUUID()
	}
	return nil
}

// CreateStaffRequest represents the create staff request payload
type CreateStaffRequest struct {
	BusinessID       string   `json:"business_id" binding:"required"`
	Name             string   `json:"name" binding:"required,min=2,max=100"`
	Email            string   `json:"email,omitempty"`
	Phone            string   `json:"phone,omitempty"`
	Role             string   `json:"role" binding:"required"`
	Status           string   `json:"status,omitempty"`
	AvatarURL        string   `json:"avatar_url,omitempty"`
	BirthDate        string   `json:"birth_date,omitempty"` // YYYY-MM-DD format
	HireDate         string   `json:"hire_date" binding:"required"`
	Address          string   `json:"address,omitempty"`
	EmergencyContact string   `json:"emergency_contact,omitempty"`
	EmergencyPhone   string   `json:"emergency_phone,omitempty"`
	Notes            string   `json:"notes,omitempty"`
	BranchIDs        []string `json:"branch_ids,omitempty"`
	ServiceIDs       []string `json:"service_ids,omitempty"`
}

// IsActive returns true if the staff is active
func (s *Staff) IsActive() bool {
	return s.Status == StaffStatusActive
}
