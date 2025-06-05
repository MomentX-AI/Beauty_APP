package models

import (
	"time"

	"gorm.io/gorm"
)

// AppointmentStatus constants
const (
	AppointmentStatusBooked    = "booked"
	AppointmentStatusConfirmed = "confirmed"
	AppointmentStatusCheckedIn = "checked_in"
	AppointmentStatusCompleted = "completed"
	AppointmentStatusCancelled = "cancelled"
	AppointmentStatusNoShow    = "no_show"
)

// Appointment represents the appointment model
type Appointment struct {
	ID         string         `gorm:"primaryKey;type:varchar(36)" json:"id"`
	BusinessID string         `gorm:"type:varchar(36);not null;index" json:"business_id"`
	BranchID   string         `gorm:"type:varchar(36);not null;index" json:"branch_id"`
	CustomerID string         `gorm:"type:varchar(36);not null;index" json:"customer_id"`
	ServiceID  string         `gorm:"type:varchar(36);not null;index" json:"service_id"`
	StaffID    *string        `gorm:"type:varchar(36);index" json:"staff_id,omitempty"`
	StartTime  time.Time      `gorm:"not null;index" json:"start_time"`
	EndTime    time.Time      `gorm:"not null;index" json:"end_time"`
	Status     string         `gorm:"type:varchar(20);default:'booked'" json:"status"`
	Note       *string        `gorm:"type:text" json:"note,omitempty"`
	CreatedAt  time.Time      `json:"created_at"`
	UpdatedAt  time.Time      `json:"updated_at"`
	DeletedAt  gorm.DeletedAt `gorm:"index" json:"-"`

	// Relationships
	Business *Business `gorm:"foreignKey:BusinessID" json:"business,omitempty"`
	Branch   *Branch   `gorm:"foreignKey:BranchID" json:"branch,omitempty"`
	Customer *Customer `gorm:"foreignKey:CustomerID" json:"customer,omitempty"`
	Service  *Service  `gorm:"foreignKey:ServiceID" json:"service,omitempty"`
	Staff    *Staff    `gorm:"foreignKey:StaffID" json:"staff,omitempty"`
}

// TableName specifies the table name for Appointment model
func (Appointment) TableName() string {
	return "appointments"
}

// BeforeCreate hook to generate UUID for appointment ID
func (a *Appointment) BeforeCreate(tx *gorm.DB) error {
	if a.ID == "" {
		a.ID = generateUUID()
	}
	return nil
}

// CreateAppointmentRequest represents the create appointment request payload
type CreateAppointmentRequest struct {
	BusinessID string `json:"business_id" binding:"required"`
	BranchID   string `json:"branch_id" binding:"required"`
	CustomerID string `json:"customer_id" binding:"required"`
	ServiceID  string `json:"service_id" binding:"required"`
	StaffID    string `json:"staff_id,omitempty"`
	StartTime  string `json:"start_time" binding:"required"` // ISO 8601 format
	EndTime    string `json:"end_time" binding:"required"`   // ISO 8601 format
	Status     string `json:"status,omitempty"`
	Note       string `json:"note,omitempty"`
}

// UpdateAppointmentRequest represents the update appointment request payload
type UpdateAppointmentRequest struct {
	BranchID   string `json:"branch_id,omitempty"`
	CustomerID string `json:"customer_id,omitempty"`
	ServiceID  string `json:"service_id,omitempty"`
	StaffID    string `json:"staff_id,omitempty"`
	StartTime  string `json:"start_time,omitempty"`
	EndTime    string `json:"end_time,omitempty"`
	Status     string `json:"status,omitempty"`
	Note       string `json:"note,omitempty"`
}

// ToModel converts CreateAppointmentRequest to Appointment model
func (r *CreateAppointmentRequest) ToModel() (*Appointment, error) {
	// Parse start time
	startTime, err := time.Parse(time.RFC3339, r.StartTime)
	if err != nil {
		return nil, err
	}

	// Parse end time
	endTime, err := time.Parse(time.RFC3339, r.EndTime)
	if err != nil {
		return nil, err
	}

	appointment := &Appointment{
		BusinessID: r.BusinessID,
		BranchID:   r.BranchID,
		CustomerID: r.CustomerID,
		ServiceID:  r.ServiceID,
		StartTime:  startTime,
		EndTime:    endTime,
		Status:     AppointmentStatusBooked,
	}

	if r.StaffID != "" {
		appointment.StaffID = &r.StaffID
	}
	if r.Status != "" {
		appointment.Status = r.Status
	}
	if r.Note != "" {
		appointment.Note = &r.Note
	}

	return appointment, nil
}

// IsActive returns true if the appointment is not cancelled or completed
func (a *Appointment) IsActive() bool {
	return a.Status != AppointmentStatusCancelled && a.Status != AppointmentStatusCompleted
}

// CanBeCancelled returns true if the appointment can be cancelled
func (a *Appointment) CanBeCancelled() bool {
	return a.Status == AppointmentStatusBooked || a.Status == AppointmentStatusConfirmed
}

// CanBeConfirmed returns true if the appointment can be confirmed
func (a *Appointment) CanBeConfirmed() bool {
	return a.Status == AppointmentStatusBooked
}

// Duration returns the duration of the appointment in minutes
func (a *Appointment) Duration() int {
	return int(a.EndTime.Sub(a.StartTime).Minutes())
}
