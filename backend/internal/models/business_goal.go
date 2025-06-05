package models

import (
	"time"

	"gorm.io/gorm"
)

// GoalType constants
const (
	GoalTypeRevenue  = "revenue"
	GoalTypeCustomer = "customer"
	GoalTypeProfit   = "profit"
	GoalTypeCustom   = "custom"
)

// GoalLevel constants
const (
	GoalLevelBusiness = "business"
	GoalLevelBranch   = "branch"
	GoalLevelStaff    = "staff"
)

// BusinessGoal represents the business goal model
type BusinessGoal struct {
	ID           string         `gorm:"primaryKey;type:varchar(36)" json:"id"`
	BusinessID   string         `gorm:"type:varchar(36);not null;index" json:"businessId"`
	Title        string         `gorm:"type:varchar(200);not null" json:"title"`
	CurrentValue float64        `gorm:"type:decimal(15,2);default:0" json:"currentValue"`
	TargetValue  float64        `gorm:"type:decimal(15,2);not null" json:"targetValue"`
	Unit         string         `gorm:"type:varchar(20);not null" json:"unit"`
	StartDate    time.Time      `gorm:"not null" json:"startDate"`
	EndDate      time.Time      `gorm:"not null" json:"endDate"`
	Type         string         `gorm:"type:varchar(20);default:'custom'" json:"type"`
	Level        string         `gorm:"type:varchar(20);default:'business'" json:"level"`
	BranchID     *string        `gorm:"type:varchar(36);index" json:"branchId,omitempty"`
	StaffID      *string        `gorm:"type:varchar(36);index" json:"staffId,omitempty"`
	Description  *string        `gorm:"type:text" json:"description,omitempty"`
	CreatedAt    time.Time      `json:"created_at"`
	UpdatedAt    time.Time      `json:"updated_at"`
	DeletedAt    gorm.DeletedAt `gorm:"index" json:"-"`

	// Relationships
	Business *Business `gorm:"foreignKey:BusinessID" json:"business,omitempty"`
	Branch   *Branch   `gorm:"foreignKey:BranchID" json:"branch,omitempty"`
	Staff    *Staff    `gorm:"foreignKey:StaffID" json:"staff,omitempty"`
}

// TableName specifies the table name for BusinessGoal model
func (BusinessGoal) TableName() string {
	return "business_goals"
}

// BeforeCreate hook to generate UUID for business goal ID
func (bg *BusinessGoal) BeforeCreate(tx *gorm.DB) error {
	if bg.ID == "" {
		bg.ID = generateUUID()
	}
	return nil
}

// CreateBusinessGoalRequest represents the create business goal request payload
type CreateBusinessGoalRequest struct {
	BusinessID   string  `json:"businessId" binding:"required"`
	Title        string  `json:"title" binding:"required,min=2,max=200"`
	CurrentValue float64 `json:"currentValue,omitempty"`
	TargetValue  float64 `json:"targetValue" binding:"required,min=0"`
	Unit         string  `json:"unit" binding:"required"`
	StartDate    string  `json:"startDate" binding:"required"` // YYYY-MM-DD format
	EndDate      string  `json:"endDate" binding:"required"`   // YYYY-MM-DD format
	Type         string  `json:"type,omitempty"`
	Level        string  `json:"level,omitempty"`
	BranchID     string  `json:"branchId,omitempty"`
	StaffID      string  `json:"staffId,omitempty"`
	Description  string  `json:"description,omitempty"`
}

// UpdateBusinessGoalRequest represents the update business goal request payload
type UpdateBusinessGoalRequest struct {
	Title        string  `json:"title" binding:"omitempty,min=2,max=200"`
	CurrentValue float64 `json:"currentValue,omitempty"`
	TargetValue  float64 `json:"targetValue" binding:"omitempty,min=0"`
	Unit         string  `json:"unit,omitempty"`
	StartDate    string  `json:"startDate,omitempty"`
	EndDate      string  `json:"endDate,omitempty"`
	Type         string  `json:"type,omitempty"`
	Level        string  `json:"level,omitempty"`
	BranchID     string  `json:"branchId,omitempty"`
	StaffID      string  `json:"staffId,omitempty"`
	Description  string  `json:"description,omitempty"`
}

// ToModel converts CreateBusinessGoalRequest to BusinessGoal model
func (r *CreateBusinessGoalRequest) ToModel() (*BusinessGoal, error) {
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

	goal := &BusinessGoal{
		BusinessID:   r.BusinessID,
		Title:        r.Title,
		CurrentValue: r.CurrentValue,
		TargetValue:  r.TargetValue,
		Unit:         r.Unit,
		StartDate:    startDate,
		EndDate:      endDate,
		Type:         GoalTypeCustom,
		Level:        GoalLevelBusiness,
	}

	if r.Type != "" {
		goal.Type = r.Type
	}
	if r.Level != "" {
		goal.Level = r.Level
	}
	if r.BranchID != "" {
		goal.BranchID = &r.BranchID
	}
	if r.StaffID != "" {
		goal.StaffID = &r.StaffID
	}
	if r.Description != "" {
		goal.Description = &r.Description
	}

	return goal, nil
}

// ProgressPercentage calculates the progress percentage towards the target
func (bg *BusinessGoal) ProgressPercentage() float64 {
	if bg.TargetValue == 0 {
		return 0
	}
	progress := (bg.CurrentValue / bg.TargetValue) * 100
	if progress > 100 {
		return 100
	}
	return progress
}

// IsActive returns true if the goal is within its active period
func (bg *BusinessGoal) IsActive() bool {
	now := time.Now()
	return now.After(bg.StartDate) && now.Before(bg.EndDate)
}

// RemainingDays returns the number of days remaining until the goal end date
func (bg *BusinessGoal) RemainingDays() int {
	now := time.Now()
	if now.After(bg.EndDate) {
		return 0
	}
	return int(bg.EndDate.Sub(now).Hours() / 24)
}
