package models

import (
	"time"

	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

// User represents the user model
type User struct {
	ID            string         `gorm:"primaryKey;type:varchar(36)" json:"id"`
	BusinessID    *string        `gorm:"type:varchar(36);index" json:"business_id,omitempty"`
	Email         string         `gorm:"uniqueIndex;type:varchar(255);not null" json:"email"`
	PasswordHash  string         `gorm:"type:varchar(255);not null" json:"-"`
	Name          string         `gorm:"type:varchar(100);not null" json:"name"`
	BusinessName  string         `gorm:"type:varchar(100);not null" json:"businessName"`
	Role          string         `gorm:"type:varchar(20);not null;default:'owner'" json:"role"`
	IsActive      bool           `gorm:"default:true" json:"isActive"`
	EmailVerified bool           `gorm:"default:false" json:"emailVerified"`
	LastLoginAt   *time.Time     `json:"lastLoginAt,omitempty"`
	CreatedAt     time.Time      `json:"createdAt"`
	UpdatedAt     time.Time      `json:"updatedAt"`
	DeletedAt     gorm.DeletedAt `gorm:"index" json:"-"`

	// Relationships
	Business *Business `gorm:"foreignKey:BusinessID" json:"business,omitempty"`
}

// UserRole constants
const (
	UserRoleOwner   = "owner"   // 店家老闆
	UserRoleAdmin   = "admin"   // 管理員
	UserRoleManager = "manager" // 店長
	UserRoleStaff   = "staff"   // 員工
)

// TableName specifies the table name for User model
func (User) TableName() string {
	return "users"
}

// BeforeCreate hook to generate UUID for user ID
func (u *User) BeforeCreate(tx *gorm.DB) error {
	if u.ID == "" {
		// Generate UUID for user ID
		u.ID = generateUUID()
	}
	return nil
}

// SetPassword hashes and sets the user password
func (u *User) SetPassword(password string) error {
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		return err
	}
	u.PasswordHash = string(hashedPassword)
	return nil
}

// CheckPassword compares the given password with the user's hashed password
func (u *User) CheckPassword(password string) bool {
	err := bcrypt.CompareHashAndPassword([]byte(u.PasswordHash), []byte(password))
	return err == nil
}

// ToResponseUser converts User model to response format (without sensitive data)
func (u *User) ToResponseUser() *UserResponse {
	return &UserResponse{
		ID:            u.ID,
		Email:         u.Email,
		Name:          u.Name,
		BusinessName:  u.BusinessName,
		Role:          u.Role,
		IsActive:      u.IsActive,
		EmailVerified: u.EmailVerified,
		LastLoginAt:   u.LastLoginAt,
		CreatedAt:     u.CreatedAt,
		UpdatedAt:     u.UpdatedAt,
	}
}

// AuthResponse represents the authentication response payload
type AuthResponse struct {
	Success bool      `json:"success"`
	Message *string   `json:"message,omitempty"`
	Data    *AuthData `json:"data,omitempty"`
}

// AuthData represents the authentication data
type AuthData struct {
	User         *UserResponse `json:"user"`
	Token        string        `json:"token"` // 前端期望的字段名
	RefreshToken *string       `json:"refresh_token,omitempty"`
	ExpiresAt    *int64        `json:"expires_at,omitempty"`
}

// UserResponse represents user data for API responses
type UserResponse struct {
	ID            string     `json:"id"`
	Email         string     `json:"email"`
	Name          string     `json:"name"`
	BusinessName  string     `json:"businessName"`
	Role          string     `json:"role"`
	IsActive      bool       `json:"isActive"`
	EmailVerified bool       `json:"emailVerified"`
	LastLoginAt   *time.Time `json:"lastLoginAt,omitempty"`
	CreatedAt     time.Time  `json:"createdAt"`
	UpdatedAt     time.Time  `json:"updatedAt"`
}

// RegisterRequest represents the registration request payload
type RegisterRequest struct {
	Email        string `json:"email" binding:"required,email" example:"user@example.com"`
	Password     string `json:"password" binding:"required,min=6" example:"password123"`
	Name         string `json:"name" binding:"required,min=2,max=50" example:"張三"`
	BusinessName string `json:"businessName" binding:"required,min=2,max=100" example:"美麗髮廊"`
}

// LoginRequest represents the login request payload
type LoginRequest struct {
	Email    string `json:"email" binding:"required,email" example:"user@example.com"`
	Password string `json:"password" binding:"required" example:"password123"`
}

// UpdateUserRequest represents the update user request payload
type UpdateUserRequest struct {
	Name         string `json:"name" binding:"omitempty,min=2,max=50"`
	BusinessName string `json:"businessName" binding:"omitempty,min=2,max=100"`
}

// ChangePasswordRequest represents the change password request payload
type ChangePasswordRequest struct {
	CurrentPassword string `json:"currentPassword" binding:"required"`
	NewPassword     string `json:"newPassword" binding:"required,min=6"`
}

// Validate validates the register request
func (r *RegisterRequest) Validate() error {
	if len(r.Name) < 2 || len(r.Name) > 50 {
		return ErrInvalidName
	}
	if len(r.BusinessName) < 2 || len(r.BusinessName) > 100 {
		return ErrInvalidBusinessName
	}
	if len(r.Password) < 6 {
		return ErrPasswordTooShort
	}
	return nil
}

// ToUser converts RegisterRequest to User model
func (r *RegisterRequest) ToUser() *User {
	return &User{
		Email:        r.Email,
		Name:         r.Name,
		BusinessName: r.BusinessName,
		Role:         UserRoleOwner, // 新註冊用戶默認為店家老闆
		IsActive:     true,
	}
}
