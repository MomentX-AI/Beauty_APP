package utils

import (
	"errors"
	"os"
	"time"

	"github.com/golang-jwt/jwt/v5"
)

// JWTClaims represents the JWT claims
type JWTClaims struct {
	UserID   string `json:"user_id"`
	Email    string `json:"email"`
	Role     string `json:"role"`
	IsActive bool   `json:"is_active"`
	jwt.RegisteredClaims
}

// TokenPair represents access and refresh tokens
type TokenPair struct {
	AccessToken  string `json:"access_token"`
	RefreshToken string `json:"refresh_token"`
	ExpiresAt    int64  `json:"expires_at"`
}

var (
	// ErrInvalidToken is returned when token is invalid
	ErrInvalidToken = errors.New("invalid token")
	// ErrTokenExpired is returned when token is expired
	ErrTokenExpired = errors.New("token expired")
)

// getJWTSecret returns the JWT secret from environment variable
func getJWTSecret() string {
	secret := os.Getenv("JWT_SECRET")
	if secret == "" {
		secret = "your-super-secret-jwt-key" // fallback for development
	}
	return secret
}

// getJWTRefreshSecret returns the JWT refresh secret from environment variable
func getJWTRefreshSecret() string {
	secret := os.Getenv("JWT_REFRESH_SECRET")
	if secret == "" {
		secret = "your-refresh-token-secret" // fallback for development
	}
	return secret
}

// getTokenExpiry returns the token expiry duration
func getTokenExpiry() time.Duration {
	expiry := os.Getenv("JWT_EXPIRE")
	if expiry == "" {
		expiry = "24h" // default to 24 hours
	}

	duration, err := time.ParseDuration(expiry)
	if err != nil {
		duration = 24 * time.Hour // fallback to 24 hours
	}

	return duration
}

// getRefreshTokenExpiry returns the refresh token expiry duration
func getRefreshTokenExpiry() time.Duration {
	expiry := os.Getenv("JWT_REFRESH_EXPIRE")
	if expiry == "" {
		expiry = "168h" // default to 7 days
	}

	duration, err := time.ParseDuration(expiry)
	if err != nil {
		duration = 168 * time.Hour // fallback to 7 days
	}

	return duration
}

// GenerateTokenPair generates access and refresh tokens for a user
func GenerateTokenPair(userID, email, role string, isActive bool) (*TokenPair, error) {
	// Generate access token
	accessToken, expiresAt, err := GenerateAccessToken(userID, email, role, isActive)
	if err != nil {
		return nil, err
	}

	// Generate refresh token
	refreshToken, err := GenerateRefreshToken(userID)
	if err != nil {
		return nil, err
	}

	return &TokenPair{
		AccessToken:  accessToken,
		RefreshToken: refreshToken,
		ExpiresAt:    expiresAt,
	}, nil
}

// GenerateAccessToken generates an access token for a user
func GenerateAccessToken(userID, email, role string, isActive bool) (string, int64, error) {
	expiry := getTokenExpiry()
	expiresAt := time.Now().Add(expiry)

	claims := &JWTClaims{
		UserID:   userID,
		Email:    email,
		Role:     role,
		IsActive: isActive,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(expiresAt),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
			NotBefore: jwt.NewNumericDate(time.Now()),
			Issuer:    "beautyai-backend",
			Subject:   userID,
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	tokenString, err := token.SignedString([]byte(getJWTSecret()))
	if err != nil {
		return "", 0, err
	}

	return tokenString, expiresAt.Unix(), nil
}

// GenerateRefreshToken generates a refresh token for a user
func GenerateRefreshToken(userID string) (string, error) {
	expiry := getRefreshTokenExpiry()
	expiresAt := time.Now().Add(expiry)

	claims := &jwt.RegisteredClaims{
		ExpiresAt: jwt.NewNumericDate(expiresAt),
		IssuedAt:  jwt.NewNumericDate(time.Now()),
		NotBefore: jwt.NewNumericDate(time.Now()),
		Issuer:    "beautyai-backend",
		Subject:   userID,
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	tokenString, err := token.SignedString([]byte(getJWTRefreshSecret()))
	if err != nil {
		return "", err
	}

	return tokenString, nil
}

// ValidateAccessToken validates an access token and returns the claims
func ValidateAccessToken(tokenString string) (*JWTClaims, error) {
	token, err := jwt.ParseWithClaims(tokenString, &JWTClaims{}, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, ErrInvalidToken
		}
		return []byte(getJWTSecret()), nil
	})

	if err != nil {
		if errors.Is(err, jwt.ErrTokenExpired) {
			return nil, ErrTokenExpired
		}
		return nil, ErrInvalidToken
	}

	claims, ok := token.Claims.(*JWTClaims)
	if !ok || !token.Valid {
		return nil, ErrInvalidToken
	}

	return claims, nil
}

// ValidateRefreshToken validates a refresh token and returns the user ID
func ValidateRefreshToken(tokenString string) (string, error) {
	token, err := jwt.ParseWithClaims(tokenString, &jwt.RegisteredClaims{}, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, ErrInvalidToken
		}
		return []byte(getJWTRefreshSecret()), nil
	})

	if err != nil {
		if errors.Is(err, jwt.ErrTokenExpired) {
			return "", ErrTokenExpired
		}
		return "", ErrInvalidToken
	}

	claims, ok := token.Claims.(*jwt.RegisteredClaims)
	if !ok || !token.Valid {
		return "", ErrInvalidToken
	}

	return claims.Subject, nil
}

// ExtractTokenFromHeader extracts JWT token from Authorization header
func ExtractTokenFromHeader(authHeader string) string {
	if len(authHeader) > 7 && authHeader[:7] == "Bearer " {
		return authHeader[7:]
	}
	return ""
}
