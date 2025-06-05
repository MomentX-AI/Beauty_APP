package services

import (
	"context"
	"strings"
	"time"

	"beautyai-backend/internal/models"

	"gorm.io/gorm"
)

// UserService handles user-related business logic
type UserService struct {
	db *gorm.DB
}

// NewUserService creates a new user service
func NewUserService(db *gorm.DB) *UserService {
	return &UserService{
		db: db,
	}
}

// Register creates a new user account
func (s *UserService) Register(ctx context.Context, req *models.RegisterRequest) (*models.UserResponse, error) {
	// Validate request
	if err := req.Validate(); err != nil {
		return nil, err
	}

	// Normalize email
	email := strings.ToLower(strings.TrimSpace(req.Email))

	// Check if email already exists
	var existingUser models.User
	err := s.db.WithContext(ctx).Where("email = ?", email).First(&existingUser).Error
	if err == nil {
		return nil, models.ErrEmailAlreadyExists
	}
	if err != gorm.ErrRecordNotFound {
		return nil, err
	}

	// Create new user
	user := req.ToUser()
	user.Email = email

	// Set password hash
	if err := user.SetPassword(req.Password); err != nil {
		return nil, err
	}

	// Save to database
	if err := s.db.WithContext(ctx).Create(user).Error; err != nil {
		return nil, err
	}

	return user.ToResponseUser(), nil
}

// Login authenticates a user
func (s *UserService) Login(ctx context.Context, req *models.LoginRequest) (*models.UserResponse, error) {
	// Normalize email
	email := strings.ToLower(strings.TrimSpace(req.Email))

	// Find user by email
	var user models.User
	err := s.db.WithContext(ctx).Where("email = ?", email).First(&user).Error
	if err != nil {
		if err == gorm.ErrRecordNotFound {
			return nil, models.ErrInvalidCredentials
		}
		return nil, err
	}

	// Check if user is active
	if !user.IsActive {
		return nil, models.ErrUserInactive
	}

	// Verify password
	if !user.CheckPassword(req.Password) {
		return nil, models.ErrInvalidCredentials
	}

	// Update last login time
	now := time.Now()
	user.LastLoginAt = &now
	s.db.WithContext(ctx).Model(&user).Update("last_login_at", now)

	return user.ToResponseUser(), nil
}

// GetUserByID retrieves a user by ID
func (s *UserService) GetUserByID(ctx context.Context, userID string) (*models.UserResponse, error) {
	var user models.User
	err := s.db.WithContext(ctx).Where("id = ? AND is_active = ?", userID, true).First(&user).Error
	if err != nil {
		if err == gorm.ErrRecordNotFound {
			return nil, models.ErrUserNotFound
		}
		return nil, err
	}

	return user.ToResponseUser(), nil
}

// GetUserByEmail retrieves a user by email
func (s *UserService) GetUserByEmail(ctx context.Context, email string) (*models.UserResponse, error) {
	email = strings.ToLower(strings.TrimSpace(email))

	var user models.User
	err := s.db.WithContext(ctx).Where("email = ? AND is_active = ?", email, true).First(&user).Error
	if err != nil {
		if err == gorm.ErrRecordNotFound {
			return nil, models.ErrUserNotFound
		}
		return nil, err
	}

	return user.ToResponseUser(), nil
}

// UpdateUser updates user information
func (s *UserService) UpdateUser(ctx context.Context, userID string, req *models.UpdateUserRequest) (*models.UserResponse, error) {
	var user models.User
	err := s.db.WithContext(ctx).Where("id = ? AND is_active = ?", userID, true).First(&user).Error
	if err != nil {
		if err == gorm.ErrRecordNotFound {
			return nil, models.ErrUserNotFound
		}
		return nil, err
	}

	// Update fields if provided
	updates := map[string]interface{}{}
	if req.Name != "" {
		updates["name"] = req.Name
	}
	if req.BusinessName != "" {
		updates["business_name"] = req.BusinessName
	}

	if len(updates) > 0 {
		updates["updated_at"] = time.Now()
		if err := s.db.WithContext(ctx).Model(&user).Updates(updates).Error; err != nil {
			return nil, err
		}
	}

	// Reload user with updates
	if err := s.db.WithContext(ctx).Where("id = ?", userID).First(&user).Error; err != nil {
		return nil, err
	}

	return user.ToResponseUser(), nil
}

// ChangePassword changes user password
func (s *UserService) ChangePassword(ctx context.Context, userID string, req *models.ChangePasswordRequest) error {
	var user models.User
	err := s.db.WithContext(ctx).Where("id = ? AND is_active = ?", userID, true).First(&user).Error
	if err != nil {
		if err == gorm.ErrRecordNotFound {
			return models.ErrUserNotFound
		}
		return err
	}

	// Verify current password
	if !user.CheckPassword(req.CurrentPassword) {
		return models.ErrInvalidCredentials
	}

	// Set new password
	if err := user.SetPassword(req.NewPassword); err != nil {
		return err
	}

	// Update password in database
	return s.db.WithContext(ctx).Model(&user).Updates(map[string]interface{}{
		"password_hash": user.PasswordHash,
		"updated_at":    time.Now(),
	}).Error
}

// DeactivateUser deactivates a user account
func (s *UserService) DeactivateUser(ctx context.Context, userID string) error {
	result := s.db.WithContext(ctx).Model(&models.User{}).
		Where("id = ?", userID).
		Updates(map[string]interface{}{
			"is_active":  false,
			"updated_at": time.Now(),
		})

	if result.Error != nil {
		return result.Error
	}

	if result.RowsAffected == 0 {
		return models.ErrUserNotFound
	}

	return nil
}

// ActivateUser activates a user account
func (s *UserService) ActivateUser(ctx context.Context, userID string) error {
	result := s.db.WithContext(ctx).Model(&models.User{}).
		Where("id = ?", userID).
		Updates(map[string]interface{}{
			"is_active":  true,
			"updated_at": time.Now(),
		})

	if result.Error != nil {
		return result.Error
	}

	if result.RowsAffected == 0 {
		return models.ErrUserNotFound
	}

	return nil
}

// VerifyEmail marks user email as verified
func (s *UserService) VerifyEmail(ctx context.Context, userID string) error {
	result := s.db.WithContext(ctx).Model(&models.User{}).
		Where("id = ?", userID).
		Updates(map[string]interface{}{
			"email_verified": true,
			"updated_at":     time.Now(),
		})

	if result.Error != nil {
		return result.Error
	}

	if result.RowsAffected == 0 {
		return models.ErrUserNotFound
	}

	return nil
}
