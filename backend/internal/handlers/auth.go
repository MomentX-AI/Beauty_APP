package handlers

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"go.uber.org/zap"
)

// RegisterRequest represents the registration request payload
type RegisterRequest struct {
	Email        string `json:"email" binding:"required,email"`
	Password     string `json:"password" binding:"required,min=6"`
	Name         string `json:"name" binding:"required"`
	BusinessName string `json:"businessName" binding:"required"`
}

// LoginRequest represents the login request payload
type LoginRequest struct {
	Email    string `json:"email" binding:"required,email"`
	Password string `json:"password" binding:"required"`
}

// AuthResponse represents the authentication response
type AuthResponse struct {
	Success bool        `json:"success"`
	Message string      `json:"message,omitempty"`
	Data    interface{} `json:"data,omitempty"`
}

// UserData represents user information in responses
type UserData struct {
	ID           string `json:"id"`
	Email        string `json:"email"`
	Name         string `json:"name"`
	BusinessName string `json:"businessName"`
	Role         string `json:"role"`
	IsActive     bool   `json:"isActive"`
}

// Register godoc
// @Summary Register a new user
// @Description Register a new user account
// @Tags Authentication
// @Accept json
// @Produce json
// @Param request body RegisterRequest true "Registration data"
// @Success 201 {object} AuthResponse
// @Failure 400 {object} AuthResponse
// @Failure 409 {object} AuthResponse
// @Router /auth/register [post]
func (h *AuthHandler) Register(c *gin.Context) {
	var req RegisterRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		h.logger.Error("Invalid registration request", zap.Error(err))
		c.JSON(http.StatusBadRequest, AuthResponse{
			Success: false,
			Message: "Invalid request data",
		})
		return
	}

	// TODO: Implement actual registration logic
	// For now, return mock response
	h.logger.Info("User registration attempt", zap.String("email", req.Email))

	userData := UserData{
		ID:           "1",
		Email:        req.Email,
		Name:         req.Name,
		BusinessName: req.BusinessName,
		Role:         "owner",
		IsActive:     true,
	}

	c.JSON(http.StatusCreated, AuthResponse{
		Success: true,
		Message: "User registered successfully",
		Data: gin.H{
			"user":  userData,
			"token": "mock-jwt-token",
		},
	})
}

// Login godoc
// @Summary Login user
// @Description Authenticate user and return JWT token
// @Tags Authentication
// @Accept json
// @Produce json
// @Param request body LoginRequest true "Login credentials"
// @Success 200 {object} AuthResponse
// @Failure 400 {object} AuthResponse
// @Failure 401 {object} AuthResponse
// @Router /auth/login [post]
func (h *AuthHandler) Login(c *gin.Context) {
	var req LoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		h.logger.Error("Invalid login request", zap.Error(err))
		c.JSON(http.StatusBadRequest, AuthResponse{
			Success: false,
			Message: "Invalid request data",
		})
		return
	}

	// TODO: Implement actual authentication logic
	// For now, check mock credentials
	h.logger.Info("Login attempt", zap.String("email", req.Email))

	if req.Email == "admin@beauty.com" && req.Password == "123456" {
		userData := UserData{
			ID:           "1",
			Email:        "admin@beauty.com",
			Name:         "管理員",
			BusinessName: "BeautyAI 總店",
			Role:         "owner",
			IsActive:     true,
		}

		c.JSON(http.StatusOK, AuthResponse{
			Success: true,
			Message: "Login successful",
			Data: gin.H{
				"user":  userData,
				"token": "mock-jwt-token",
			},
		})
	} else {
		c.JSON(http.StatusUnauthorized, AuthResponse{
			Success: false,
			Message: "Invalid email or password",
		})
	}
}

// Logout godoc
// @Summary Logout user
// @Description Logout current user and invalidate token
// @Tags Authentication
// @Security BearerAuth
// @Produce json
// @Success 200 {object} AuthResponse
// @Router /auth/logout [post]
func (h *AuthHandler) Logout(c *gin.Context) {
	// TODO: Implement token blacklisting
	h.logger.Info("User logout", zap.String("user_id", c.GetString("user_id")))

	c.JSON(http.StatusOK, AuthResponse{
		Success: true,
		Message: "Logout successful",
	})
}

// GetProfile godoc
// @Summary Get current user profile
// @Description Get the profile of the currently authenticated user
// @Tags Authentication
// @Security BearerAuth
// @Produce json
// @Success 200 {object} AuthResponse
// @Failure 401 {object} AuthResponse
// @Router /auth/me [get]
func (h *AuthHandler) GetProfile(c *gin.Context) {
	userID := c.GetString("user_id")
	userEmail := c.GetString("user_email")
	userRole := c.GetString("user_role")

	// TODO: Fetch actual user data from database
	h.logger.Info("Get user profile", zap.String("user_id", userID))

	userData := UserData{
		ID:           userID,
		Email:        userEmail,
		Name:         "管理員",
		BusinessName: "BeautyAI 總店",
		Role:         userRole,
		IsActive:     true,
	}

	c.JSON(http.StatusOK, AuthResponse{
		Success: true,
		Data:    userData,
	})
}

// RefreshToken godoc
// @Summary Refresh access token
// @Description Refresh the JWT access token
// @Tags Authentication
// @Produce json
// @Success 200 {object} AuthResponse
// @Failure 401 {object} AuthResponse
// @Router /auth/refresh [post]
func (h *AuthHandler) RefreshToken(c *gin.Context) {
	// TODO: Implement actual token refresh logic
	h.logger.Info("Token refresh request")

	c.JSON(http.StatusOK, AuthResponse{
		Success: true,
		Message: "Token refreshed successfully",
		Data: gin.H{
			"token": "new-mock-jwt-token",
		},
	})
}
