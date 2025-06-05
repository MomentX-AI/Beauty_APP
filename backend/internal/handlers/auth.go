package handlers

import (
	"errors"
	"net/http"

	"beautyai-backend/internal/models"
	"beautyai-backend/internal/services"
	"beautyai-backend/internal/utils"

	"github.com/gin-gonic/gin"
	"go.uber.org/zap"
	"gorm.io/gorm"
)

// AuthHandler handles authentication related requests
type AuthHandler struct {
	userService *services.UserService
	logger      *zap.Logger
}

// NewAuthHandler creates a new AuthHandler
func NewAuthHandler(db *gorm.DB, logger *zap.Logger) *AuthHandler {
	return &AuthHandler{
		userService: services.NewUserService(db),
		logger:      logger,
	}
}

// AuthResponse represents the authentication response
type AuthResponse struct {
	Success bool        `json:"success"`
	Message string      `json:"message,omitempty"`
	Data    interface{} `json:"data,omitempty"`
}

// LoginResponse represents login response data
type LoginResponse struct {
	User         *models.UserResponse `json:"user"`
	AccessToken  string               `json:"token"` // 前端期望的字段名
	RefreshToken string               `json:"refresh_token"`
	ExpiresAt    int64                `json:"expires_at"`
}

// Register godoc
// @Summary Register a new user
// @Description Register a new user account with business information
// @Tags Authentication
// @Accept json
// @Produce json
// @Param request body models.RegisterRequest true "Registration data"
// @Success 201 {object} AuthResponse
// @Failure 400 {object} AuthResponse
// @Failure 409 {object} AuthResponse
// @Failure 500 {object} AuthResponse
// @Router /auth/register [post]
func (h *AuthHandler) Register(c *gin.Context) {
	var req models.RegisterRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		h.logger.Error("Invalid registration request", zap.Error(err))
		c.JSON(http.StatusBadRequest, AuthResponse{
			Success: false,
			Message: "請求數據格式錯誤",
		})
		return
	}

	h.logger.Info("User registration attempt",
		zap.String("email", req.Email),
		zap.String("name", req.Name),
		zap.String("businessName", req.BusinessName))

	// Create user using service
	user, err := h.userService.Register(c.Request.Context(), &req)
	if err != nil {
		h.logger.Error("Failed to register user", zap.Error(err))

		// Handle specific errors
		switch {
		case errors.Is(err, models.ErrEmailAlreadyExists):
			c.JSON(http.StatusConflict, AuthResponse{
				Success: false,
				Message: "此電子郵件已被註冊",
			})
		case errors.Is(err, models.ErrInvalidName):
			c.JSON(http.StatusBadRequest, AuthResponse{
				Success: false,
				Message: "姓名長度必須在 2-50 字符之間",
			})
		case errors.Is(err, models.ErrInvalidBusinessName):
			c.JSON(http.StatusBadRequest, AuthResponse{
				Success: false,
				Message: "商家名稱長度必須在 2-100 字符之間",
			})
		case errors.Is(err, models.ErrPasswordTooShort):
			c.JSON(http.StatusBadRequest, AuthResponse{
				Success: false,
				Message: "密碼長度至少為 6 位",
			})
		default:
			c.JSON(http.StatusInternalServerError, AuthResponse{
				Success: false,
				Message: "註冊失敗，請稍後再試",
			})
		}
		return
	}

	// Generate JWT tokens
	tokens, err := utils.GenerateTokenPair(user.ID, user.Email, user.Role, user.IsActive)
	if err != nil {
		h.logger.Error("Failed to generate tokens", zap.Error(err))
		c.JSON(http.StatusInternalServerError, AuthResponse{
			Success: false,
			Message: "註冊成功，但生成令牌失敗，請重新登入",
		})
		return
	}

	h.logger.Info("User registered successfully", zap.String("user_id", user.ID))

	c.JSON(http.StatusCreated, AuthResponse{
		Success: true,
		Message: "註冊成功",
		Data: LoginResponse{
			User:         user,
			AccessToken:  tokens.AccessToken,
			RefreshToken: tokens.RefreshToken,
			ExpiresAt:    tokens.ExpiresAt,
		},
	})
}

// Login godoc
// @Summary Login user
// @Description Authenticate user and return JWT tokens
// @Tags Authentication
// @Accept json
// @Produce json
// @Param request body models.LoginRequest true "Login credentials"
// @Success 200 {object} AuthResponse
// @Failure 400 {object} AuthResponse
// @Failure 401 {object} AuthResponse
// @Failure 500 {object} AuthResponse
// @Router /auth/login [post]
func (h *AuthHandler) Login(c *gin.Context) {
	var req models.LoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		h.logger.Error("Invalid login request", zap.Error(err))
		c.JSON(http.StatusBadRequest, AuthResponse{
			Success: false,
			Message: "請求數據格式錯誤",
		})
		return
	}

	h.logger.Info("Login attempt", zap.String("email", req.Email))

	// Authenticate user using service
	user, err := h.userService.Login(c.Request.Context(), &req)
	if err != nil {
		h.logger.Error("Failed to authenticate user", zap.Error(err))

		// Handle specific errors
		switch {
		case errors.Is(err, models.ErrInvalidCredentials):
			c.JSON(http.StatusUnauthorized, AuthResponse{
				Success: false,
				Message: "電子郵件或密碼錯誤",
			})
		case errors.Is(err, models.ErrUserInactive):
			c.JSON(http.StatusUnauthorized, AuthResponse{
				Success: false,
				Message: "帳號已被停用，請聯繫管理員",
			})
		default:
			c.JSON(http.StatusInternalServerError, AuthResponse{
				Success: false,
				Message: "登入失敗，請稍後再試",
			})
		}
		return
	}

	// Generate JWT tokens
	tokens, err := utils.GenerateTokenPair(user.ID, user.Email, user.Role, user.IsActive)
	if err != nil {
		h.logger.Error("Failed to generate tokens", zap.Error(err))
		c.JSON(http.StatusInternalServerError, AuthResponse{
			Success: false,
			Message: "登入失敗，令牌生成錯誤",
		})
		return
	}

	h.logger.Info("User logged in successfully", zap.String("user_id", user.ID))

	c.JSON(http.StatusOK, AuthResponse{
		Success: true,
		Message: "登入成功",
		Data: LoginResponse{
			User:         user,
			AccessToken:  tokens.AccessToken,
			RefreshToken: tokens.RefreshToken,
			ExpiresAt:    tokens.ExpiresAt,
		},
	})
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
	userID := c.GetString("user_id")
	h.logger.Info("User logout", zap.String("user_id", userID))

	// TODO: Implement token blacklisting if needed
	// For now, just return success since JWT tokens are stateless

	c.JSON(http.StatusOK, AuthResponse{
		Success: true,
		Message: "登出成功",
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
// @Failure 404 {object} AuthResponse
// @Failure 500 {object} AuthResponse
// @Router /auth/me [get]
func (h *AuthHandler) GetProfile(c *gin.Context) {
	userID := c.GetString("user_id")
	h.logger.Info("Get user profile", zap.String("user_id", userID))

	user, err := h.userService.GetUserByID(c.Request.Context(), userID)
	if err != nil {
		h.logger.Error("Failed to get user profile", zap.Error(err))

		if errors.Is(err, models.ErrUserNotFound) {
			c.JSON(http.StatusNotFound, AuthResponse{
				Success: false,
				Message: "用戶不存在",
			})
		} else {
			c.JSON(http.StatusInternalServerError, AuthResponse{
				Success: false,
				Message: "獲取用戶信息失敗",
			})
		}
		return
	}

	c.JSON(http.StatusOK, AuthResponse{
		Success: true,
		Data:    user,
	})
}

// RefreshToken godoc
// @Summary Refresh access token
// @Description Refresh the JWT access token using refresh token
// @Tags Authentication
// @Accept json
// @Produce json
// @Param request body RefreshTokenRequest true "Refresh token"
// @Success 200 {object} AuthResponse
// @Failure 400 {object} AuthResponse
// @Failure 401 {object} AuthResponse
// @Failure 500 {object} AuthResponse
// @Router /auth/refresh [post]
func (h *AuthHandler) RefreshToken(c *gin.Context) {
	type RefreshTokenRequest struct {
		RefreshToken string `json:"refresh_token" binding:"required"`
	}

	var req RefreshTokenRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		h.logger.Error("Invalid refresh token request", zap.Error(err))
		c.JSON(http.StatusBadRequest, AuthResponse{
			Success: false,
			Message: "請求數據格式錯誤",
		})
		return
	}

	// Validate refresh token
	userID, err := utils.ValidateRefreshToken(req.RefreshToken)
	if err != nil {
		h.logger.Error("Invalid refresh token", zap.Error(err))
		c.JSON(http.StatusUnauthorized, AuthResponse{
			Success: false,
			Message: "刷新令牌無效或已過期",
		})
		return
	}

	// Get user information
	user, err := h.userService.GetUserByID(c.Request.Context(), userID)
	if err != nil {
		h.logger.Error("Failed to get user for token refresh", zap.Error(err))
		c.JSON(http.StatusUnauthorized, AuthResponse{
			Success: false,
			Message: "用戶不存在或已被停用",
		})
		return
	}

	// Generate new token pair
	tokens, err := utils.GenerateTokenPair(user.ID, user.Email, user.Role, user.IsActive)
	if err != nil {
		h.logger.Error("Failed to generate new tokens", zap.Error(err))
		c.JSON(http.StatusInternalServerError, AuthResponse{
			Success: false,
			Message: "令牌刷新失敗",
		})
		return
	}

	h.logger.Info("Token refreshed successfully", zap.String("user_id", userID))

	c.JSON(http.StatusOK, AuthResponse{
		Success: true,
		Message: "令牌刷新成功",
		Data: LoginResponse{
			User:         user,
			AccessToken:  tokens.AccessToken,
			RefreshToken: tokens.RefreshToken,
			ExpiresAt:    tokens.ExpiresAt,
		},
	})
}

// UpdateProfile godoc
// @Summary Update user profile
// @Description Update current user's profile information
// @Tags Authentication
// @Security BearerAuth
// @Accept json
// @Produce json
// @Param request body models.UpdateUserRequest true "Update data"
// @Success 200 {object} AuthResponse
// @Failure 400 {object} AuthResponse
// @Failure 401 {object} AuthResponse
// @Failure 404 {object} AuthResponse
// @Failure 500 {object} AuthResponse
// @Router /auth/profile [put]
func (h *AuthHandler) UpdateProfile(c *gin.Context) {
	userID := c.GetString("user_id")

	var req models.UpdateUserRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		h.logger.Error("Invalid update profile request", zap.Error(err))
		c.JSON(http.StatusBadRequest, AuthResponse{
			Success: false,
			Message: "請求數據格式錯誤",
		})
		return
	}

	h.logger.Info("Update user profile", zap.String("user_id", userID))

	user, err := h.userService.UpdateUser(c.Request.Context(), userID, &req)
	if err != nil {
		h.logger.Error("Failed to update user profile", zap.Error(err))

		if errors.Is(err, models.ErrUserNotFound) {
			c.JSON(http.StatusNotFound, AuthResponse{
				Success: false,
				Message: "用戶不存在",
			})
		} else {
			c.JSON(http.StatusInternalServerError, AuthResponse{
				Success: false,
				Message: "更新用戶信息失敗",
			})
		}
		return
	}

	c.JSON(http.StatusOK, AuthResponse{
		Success: true,
		Message: "用戶信息更新成功",
		Data:    user,
	})
}

// ChangePassword godoc
// @Summary Change user password
// @Description Change current user's password
// @Tags Authentication
// @Security BearerAuth
// @Accept json
// @Produce json
// @Param request body models.ChangePasswordRequest true "Password change data"
// @Success 200 {object} AuthResponse
// @Failure 400 {object} AuthResponse
// @Failure 401 {object} AuthResponse
// @Failure 404 {object} AuthResponse
// @Failure 500 {object} AuthResponse
// @Router /auth/change-password [post]
func (h *AuthHandler) ChangePassword(c *gin.Context) {
	userID := c.GetString("user_id")

	var req models.ChangePasswordRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		h.logger.Error("Invalid change password request", zap.Error(err))
		c.JSON(http.StatusBadRequest, AuthResponse{
			Success: false,
			Message: "請求數據格式錯誤",
		})
		return
	}

	h.logger.Info("Change user password", zap.String("user_id", userID))

	err := h.userService.ChangePassword(c.Request.Context(), userID, &req)
	if err != nil {
		h.logger.Error("Failed to change password", zap.Error(err))

		switch {
		case errors.Is(err, models.ErrUserNotFound):
			c.JSON(http.StatusNotFound, AuthResponse{
				Success: false,
				Message: "用戶不存在",
			})
		case errors.Is(err, models.ErrInvalidCredentials):
			c.JSON(http.StatusBadRequest, AuthResponse{
				Success: false,
				Message: "當前密碼錯誤",
			})
		default:
			c.JSON(http.StatusInternalServerError, AuthResponse{
				Success: false,
				Message: "密碼修改失敗",
			})
		}
		return
	}

	c.JSON(http.StatusOK, AuthResponse{
		Success: true,
		Message: "密碼修改成功",
	})
}
