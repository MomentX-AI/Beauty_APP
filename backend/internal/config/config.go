package config

import (
	"fmt"
	"os"
	"strconv"
	"time"
)

// Config holds all configuration for our application
type Config struct {
	App      AppConfig
	Server   ServerConfig
	Database DatabaseConfig
	JWT      JWTConfig
	Redis    RedisConfig
	Log      LogConfig
	Mail     MailConfig
	Storage  StorageConfig
}

// AppConfig holds application-specific configuration
type AppConfig struct {
	Name        string
	Environment string
	Version     string
}

// ServerConfig holds server configuration
type ServerConfig struct {
	Port         string
	Host         string
	ReadTimeout  time.Duration
	WriteTimeout time.Duration
	IdleTimeout  time.Duration
}

// DatabaseConfig holds database configuration
type DatabaseConfig struct {
	Type     string // "postgres" or "mongodb"
	Host     string
	Port     string
	Name     string
	User     string
	Password string
	SSLMode  string
	URI      string // For MongoDB
}

// JWTConfig holds JWT configuration
type JWTConfig struct {
	Secret                string
	ExpirationTime        time.Duration
	RefreshSecret         string
	RefreshExpirationTime time.Duration
}

// RedisConfig holds Redis configuration
type RedisConfig struct {
	Host     string
	Port     string
	Password string
	DB       int
}

// LogConfig holds logging configuration
type LogConfig struct {
	Level  string
	Format string
}

// MailConfig holds email configuration
type MailConfig struct {
	Host     string
	Port     int
	User     string
	Password string
	From     string
}

// StorageConfig holds file storage configuration
type StorageConfig struct {
	Type      string // "local" or "cloudinary"
	LocalPath string
	// Cloudinary
	CloudinaryCloudName string
	CloudinaryAPIKey    string
	CloudinaryAPISecret string
}

// Load loads configuration from environment variables
func Load() *Config {
	return &Config{
		App: AppConfig{
			Name:        getEnv("APP_NAME", "BeautyAI API"),
			Environment: getEnv("NODE_ENV", "development"),
			Version:     getEnv("APP_VERSION", "1.0.0"),
		},
		Server: ServerConfig{
			Port:         getEnv("PORT", "3000"),
			Host:         getEnv("HOST", "localhost"),
			ReadTimeout:  getDurationEnv("READ_TIMEOUT", 15*time.Second),
			WriteTimeout: getDurationEnv("WRITE_TIMEOUT", 15*time.Second),
			IdleTimeout:  getDurationEnv("IDLE_TIMEOUT", 60*time.Second),
		},
		Database: DatabaseConfig{
			Type:     getEnv("DATABASE_TYPE", "postgres"),
			Host:     getEnv("DB_HOST", "localhost"),
			Port:     getEnv("DB_PORT", "5432"),
			Name:     getEnv("DB_NAME", "beautyai"),
			User:     getEnv("DB_USER", "postgres"),
			Password: getEnv("DB_PASSWORD", "password"),
			SSLMode:  getEnv("DB_SSLMODE", "disable"),
			URI:      getEnv("MONGODB_URI", "mongodb://localhost:27017/beautyai"),
		},
		JWT: JWTConfig{
			Secret:                getEnv("JWT_SECRET", "your-super-secret-jwt-key"),
			ExpirationTime:        getDurationEnv("JWT_EXPIRE", 24*time.Hour),
			RefreshSecret:         getEnv("JWT_REFRESH_SECRET", "your-refresh-secret"),
			RefreshExpirationTime: getDurationEnv("JWT_REFRESH_EXPIRE", 7*24*time.Hour),
		},
		Redis: RedisConfig{
			Host:     getEnv("REDIS_HOST", "localhost"),
			Port:     getEnv("REDIS_PORT", "6379"),
			Password: getEnv("REDIS_PASSWORD", ""),
			DB:       getIntEnv("REDIS_DB", 0),
		},
		Log: LogConfig{
			Level:  getEnv("LOG_LEVEL", "info"),
			Format: getEnv("LOG_FORMAT", "json"),
		},
		Mail: MailConfig{
			Host:     getEnv("EMAIL_HOST", "smtp.gmail.com"),
			Port:     getIntEnv("EMAIL_PORT", 587),
			User:     getEnv("EMAIL_USER", ""),
			Password: getEnv("EMAIL_PASSWORD", ""),
			From:     getEnv("EMAIL_FROM", "noreply@beautyai.com"),
		},
		Storage: StorageConfig{
			Type:                getEnv("STORAGE_TYPE", "local"),
			LocalPath:           getEnv("UPLOAD_PATH", "./uploads"),
			CloudinaryCloudName: getEnv("CLOUDINARY_CLOUD_NAME", ""),
			CloudinaryAPIKey:    getEnv("CLOUDINARY_API_KEY", ""),
			CloudinaryAPISecret: getEnv("CLOUDINARY_API_SECRET", ""),
		},
	}
}

// GetDSN returns database connection string for PostgreSQL
func (c *DatabaseConfig) GetDSN() string {
	return fmt.Sprintf("host=%s port=%s user=%s password=%s dbname=%s sslmode=%s",
		c.Host, c.Port, c.User, c.Password, c.Name, c.SSLMode)
}

// GetRedisAddr returns Redis address
func (c *RedisConfig) GetAddr() string {
	return fmt.Sprintf("%s:%s", c.Host, c.Port)
}

// Helper functions
func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}

func getIntEnv(key string, defaultValue int) int {
	if value := os.Getenv(key); value != "" {
		if intValue, err := strconv.Atoi(value); err == nil {
			return intValue
		}
	}
	return defaultValue
}

func getDurationEnv(key string, defaultValue time.Duration) time.Duration {
	if value := os.Getenv(key); value != "" {
		if duration, err := time.ParseDuration(value); err == nil {
			return duration
		}
	}
	return defaultValue
}
