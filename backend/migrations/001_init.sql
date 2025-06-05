-- BeautyAI Database Initialization
-- This file will be executed when PostgreSQL container starts for the first time

-- Create database if not exists (handled by POSTGRES_DB environment variable)

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create initial schema placeholder
-- Note: Actual table migrations should be handled by your Go application
CREATE TABLE IF NOT EXISTS migration_log (
    id SERIAL PRIMARY KEY,
    version VARCHAR(255) NOT NULL,
    executed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO migration_log (version) VALUES ('001_init') ON CONFLICT DO NOTHING; 