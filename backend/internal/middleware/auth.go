package middleware

import (
	"net/http"

	"beautyai-backend/internal/utils"

	"github.com/gin-gonic/gin"
	"go.uber.org/zap"
)

// AuthMiddleware creates a JWT authentication middleware
func AuthMiddleware(logger *zap.Logger) gin.HandlerFunc {
	return func(c *gin.Context) {
		// Get authorization header
		authHeader := c.GetHeader("Authorization")
		if authHeader == "" {
			logger.Warn("Missing authorization header")
			c.JSON(http.StatusUnauthorized, gin.H{
				"success": false,
				"message": "未提供認證令牌",
			})
			c.Abort()
			return
		}

		// Extract token from header
		token := utils.ExtractTokenFromHeader(authHeader)
		if token == "" {
			logger.Warn("Invalid authorization header format")
			c.JSON(http.StatusUnauthorized, gin.H{
				"success": false,
				"message": "認證令牌格式錯誤",
			})
			c.Abort()
			return
		}

		// Validate token
		claims, err := utils.ValidateAccessToken(token)
		if err != nil {
			logger.Error("Token validation failed", zap.Error(err))

			var message string
			switch err {
			case utils.ErrTokenExpired:
				message = "認證令牌已過期"
			case utils.ErrInvalidToken:
				message = "認證令牌無效"
			default:
				message = "認證失敗"
			}

			c.JSON(http.StatusUnauthorized, gin.H{
				"success": false,
				"message": message,
			})
			c.Abort()
			return
		}

		// Check if user is active
		if !claims.IsActive {
			logger.Warn("Inactive user attempting access", zap.String("user_id", claims.UserID))
			c.JSON(http.StatusUnauthorized, gin.H{
				"success": false,
				"message": "帳號已被停用",
			})
			c.Abort()
			return
		}

		// Set user information in context
		c.Set("user_id", claims.UserID)
		c.Set("user_email", claims.Email)
		c.Set("user_role", claims.Role)
		c.Set("user_is_active", claims.IsActive)

		logger.Debug("User authenticated successfully",
			zap.String("user_id", claims.UserID),
			zap.String("email", claims.Email),
			zap.String("role", claims.Role))

		c.Next()
	}
}

// RequireRole creates a middleware that requires specific roles
func RequireRole(requiredRoles ...string) gin.HandlerFunc {
	return func(c *gin.Context) {
		userRole := c.GetString("user_role")
		if userRole == "" {
			c.JSON(http.StatusUnauthorized, gin.H{
				"success": false,
				"message": "未授權訪問",
			})
			c.Abort()
			return
		}

		// Check if user has required role
		hasPermission := false
		for _, role := range requiredRoles {
			if userRole == role {
				hasPermission = true
				break
			}
		}

		if !hasPermission {
			c.JSON(http.StatusForbidden, gin.H{
				"success": false,
				"message": "權限不足",
			})
			c.Abort()
			return
		}

		c.Next()
	}
}

// OptionalAuth creates a middleware for optional authentication
// If token is provided, it validates it; if not, continues without authentication
func OptionalAuth(logger *zap.Logger) gin.HandlerFunc {
	return func(c *gin.Context) {
		authHeader := c.GetHeader("Authorization")
		if authHeader == "" {
			// No token provided, continue without authentication
			c.Next()
			return
		}

		token := utils.ExtractTokenFromHeader(authHeader)
		if token == "" {
			// Invalid header format, continue without authentication
			c.Next()
			return
		}

		// Try to validate token
		claims, err := utils.ValidateAccessToken(token)
		if err != nil {
			// Invalid token, log warning but continue without authentication
			logger.Warn("Optional auth token validation failed", zap.Error(err))
			c.Next()
			return
		}

		// Valid token, set user information in context
		if claims.IsActive {
			c.Set("user_id", claims.UserID)
			c.Set("user_email", claims.Email)
			c.Set("user_role", claims.Role)
			c.Set("user_is_active", claims.IsActive)
		}

		c.Next()
	}
}
