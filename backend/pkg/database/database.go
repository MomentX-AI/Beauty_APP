package database

import (
	"context"
	"fmt"
	"time"

	"beautyai-backend/internal/config"

	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

// Database interface for abstraction
type Database interface {
	GetGormDB() *gorm.DB
	GetMongoDB() *mongo.Database
	Close() error
	Ping() error
}

// PostgreSQLDB implements Database for PostgreSQL
type PostgreSQLDB struct {
	db *gorm.DB
}

// MongoDB implements Database for MongoDB
type MongoDB struct {
	client *mongo.Client
	db     *mongo.Database
}

// NewConnection creates a new database connection based on configuration
func NewConnection(cfg *config.Config) (Database, error) {
	switch cfg.Database.Type {
	case "postgres":
		return NewPostgreSQL(cfg)
	case "mongodb":
		return NewMongoDB(cfg)
	default:
		return nil, fmt.Errorf("unsupported database type: %s", cfg.Database.Type)
	}
}

// NewPostgreSQL creates a new PostgreSQL connection
func NewPostgreSQL(cfg *config.Config) (*PostgreSQLDB, error) {
	dsn := cfg.Database.GetDSN()

	gormConfig := &gorm.Config{}

	// Set log level based on environment
	if cfg.App.Environment == "development" {
		gormConfig.Logger = logger.Default.LogMode(logger.Info)
	} else {
		gormConfig.Logger = logger.Default.LogMode(logger.Silent)
	}

	db, err := gorm.Open(postgres.Open(dsn), gormConfig)
	if err != nil {
		return nil, fmt.Errorf("failed to connect to PostgreSQL: %w", err)
	}

	// Get underlying sql.DB for connection pool configuration
	sqlDB, err := db.DB()
	if err != nil {
		return nil, fmt.Errorf("failed to get underlying sql.DB: %w", err)
	}

	// Configure connection pool
	sqlDB.SetMaxOpenConns(25)
	sqlDB.SetMaxIdleConns(25)
	sqlDB.SetConnMaxLifetime(5 * time.Minute)

	return &PostgreSQLDB{db: db}, nil
}

// NewMongoDB creates a new MongoDB connection
func NewMongoDB(cfg *config.Config) (*MongoDB, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	client, err := mongo.Connect(ctx, options.Client().ApplyURI(cfg.Database.URI))
	if err != nil {
		return nil, fmt.Errorf("failed to connect to MongoDB: %w", err)
	}

	// Ping the database to verify connection
	if err := client.Ping(ctx, nil); err != nil {
		return nil, fmt.Errorf("failed to ping MongoDB: %w", err)
	}

	db := client.Database(cfg.Database.Name)

	return &MongoDB{
		client: client,
		db:     db,
	}, nil
}

// PostgreSQL methods
func (p *PostgreSQLDB) GetGormDB() *gorm.DB {
	return p.db
}

func (p *PostgreSQLDB) GetMongoDB() *mongo.Database {
	return nil
}

func (p *PostgreSQLDB) Close() error {
	sqlDB, err := p.db.DB()
	if err != nil {
		return err
	}
	return sqlDB.Close()
}

func (p *PostgreSQLDB) Ping() error {
	sqlDB, err := p.db.DB()
	if err != nil {
		return err
	}
	return sqlDB.Ping()
}

// MongoDB methods
func (m *MongoDB) GetGormDB() *gorm.DB {
	return nil
}

func (m *MongoDB) GetMongoDB() *mongo.Database {
	return m.db
}

func (m *MongoDB) Close() error {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	return m.client.Disconnect(ctx)
}

func (m *MongoDB) Ping() error {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	return m.client.Ping(ctx, nil)
}
