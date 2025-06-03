# BeautyAI 後端設置與部署指南

## 專案初始化

### 1. 創建專案結構
```bash
mkdir beauty-ai-backend
cd beauty-ai-backend

# 初始化 Go 模組
go mod init beauty-ai-backend

# 創建目錄結構
mkdir -p cmd/api
mkdir -p internal/{api/{handlers,middleware,routes},domain/{entities,repositories},services,infrastructure/{database,cache,config},utils}
mkdir -p migrations
mkdir -p docs
mkdir -p tests
```

### 2. 安裝依賴
```bash
# Web 框架
go get github.com/gin-gonic/gin

# 數據庫相關
go get gorm.io/gorm
go get gorm.io/driver/postgres

# JWT 認證
go get github.com/golang-jwt/jwt/v5

# 密碼加密
go get golang.org/x/crypto/bcrypt

# 配置管理
go get github.com/spf13/viper

# 日誌
go get github.com/sirupsen/logrus

# Redis
go get github.com/go-redis/redis/v8

# 測試
go get github.com/stretchr/testify

# API 文檔
go get github.com/swaggo/gin-swagger
go get github.com/swaggo/files
go get github.com/swaggo/swag/cmd/swag

# 速率限制
go get golang.org/x/time/rate

# 圖片處理
go get github.com/minio/minio-go/v7

# 驗證
go get github.com/go-playground/validator/v10

# UUID
go get github.com/google/uuid
```

### 3. 配置文件設置

#### config.yaml
```yaml
server:
  port: "8080"
  mode: "debug" # debug, release, test

database:
  dsn: "postgres://username:password@localhost:5432/beauty_ai?sslmode=disable"

jwt:
  secret: "your-super-secret-jwt-key"
  expiry: 24 # hours

redis:
  url: "redis://localhost:6379"

storage:
  type: "local" # local, s3, minio
  path: "./uploads"
  
logging:
  level: "info"
  file: "app.log"
```

### 4. 環境變量設置

#### .env
```bash
# 數據庫配置
DB_HOST=localhost
DB_PORT=5432
DB_NAME=beauty_ai
DB_USER=postgres
DB_PASSWORD=password

# JWT 配置
JWT_SECRET=your-super-secret-jwt-key

# Redis 配置
REDIS_HOST=localhost
REDIS_PORT=6379

# 服務配置
PORT=8080
GIN_MODE=debug

# 文件上傳配置
UPLOAD_PATH=./uploads
MAX_FILE_SIZE=10485760 # 10MB
```

## JWT 工具實現

### utils/jwt.go
```go
package utils

import (
    "errors"
    "time"
    
    "github.com/golang-jwt/jwt/v5"
)

type Claims struct {
    UserID     uint   `json:"user_id"`
    BusinessID uint   `json:"business_id"`
    Email      string `json:"email"`
    jwt.RegisteredClaims
}

var jwtSecret = []byte("your-super-secret-jwt-key")

func GenerateJWT(userID, businessID uint, email string) (string, error) {
    claims := Claims{
        UserID:     userID,
        BusinessID: businessID,
        Email:      email,
        RegisteredClaims: jwt.RegisteredClaims{
            ExpiresAt: jwt.NewNumericDate(time.Now().Add(24 * time.Hour)),
            IssuedAt:  jwt.NewNumericDate(time.Now()),
            NotBefore: jwt.NewNumericDate(time.Now()),
        },
    }

    token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
    return token.SignedString(jwtSecret)
}

func ValidateJWT(tokenString string) (*Claims, error) {
    token, err := jwt.ParseWithClaims(tokenString, &Claims{}, func(token *jwt.Token) (interface{}, error) {
        return jwtSecret, nil
    })

    if err != nil {
        return nil, err
    }

    if claims, ok := token.Claims.(*Claims); ok && token.Valid {
        return claims, nil
    }

    return nil, errors.New("invalid token")
}
```

### utils/response.go
```go
package utils

import (
    "net/http"
    "github.com/gin-gonic/gin"
)

type Response struct {
    Code    int         `json:"code"`
    Message string      `json:"message"`
    Data    interface{} `json:"data,omitempty"`
}

func Success(c *gin.Context, data interface{}) {
    c.JSON(http.StatusOK, Response{
        Code:    http.StatusOK,
        Message: "success",
        Data:    data,
    })
}

func Error(c *gin.Context, code int, message string) {
    c.JSON(code, Response{
        Code:    code,
        Message: message,
    })
}

func BadRequest(c *gin.Context, message string) {
    Error(c, http.StatusBadRequest, message)
}

func Unauthorized(c *gin.Context, message string) {
    Error(c, http.StatusUnauthorized, message)
}

func NotFound(c *gin.Context, message string) {
    Error(c, http.StatusNotFound, message)
}

func InternalServerError(c *gin.Context, message string) {
    Error(c, http.StatusInternalServerError, message)
}
```

### utils/validator.go
```go
package utils

import (
    "github.com/go-playground/validator/v10"
)

var validate *validator.Validate

func init() {
    validate = validator.New()
}

func ValidateStruct(s interface{}) error {
    return validate.Struct(s)
}

func GetValidationErrors(err error) map[string]string {
    errors := make(map[string]string)
    
    if validationErrors, ok := err.(validator.ValidationErrors); ok {
        for _, fieldError := range validationErrors {
            errors[fieldError.Field()] = getErrorMessage(fieldError)
        }
    }
    
    return errors
}

func getErrorMessage(fe validator.FieldError) string {
    switch fe.Tag() {
    case "required":
        return "This field is required"
    case "email":
        return "Invalid email format"
    case "min":
        return "Value too short"
    case "max":
        return "Value too long"
    default:
        return "Invalid value"
    }
}
```

## 數據庫初始化

### infrastructure/database/postgres.go
```go
package database

import (
    "log"
    
    "gorm.io/driver/postgres"
    "gorm.io/gorm"
    "gorm.io/gorm/logger"
)

func InitDB(dsn string) *gorm.DB {
    db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{
        Logger: logger.Default.LogMode(logger.Info),
    })
    
    if err != nil {
        log.Fatalf("Failed to connect to database: %v", err)
    }
    
    // 配置連接池
    sqlDB, err := db.DB()
    if err != nil {
        log.Fatalf("Failed to get database instance: %v", err)
    }
    
    sqlDB.SetMaxIdleConns(10)
    sqlDB.SetMaxOpenConns(100)
    
    return db
}
```

## 測試實現

### tests/user_test.go
```go
package tests

import (
    "bytes"
    "encoding/json"
    "net/http"
    "net/http/httptest"
    "testing"
    
    "github.com/gin-gonic/gin"
    "github.com/stretchr/testify/assert"
    "beauty-ai-backend/internal/api/handlers"
    "beauty-ai-backend/internal/services"
)

func TestUserRegistration(t *testing.T) {
    // 設置測試環境
    gin.SetMode(gin.TestMode)
    
    // 模擬服務
    authService := &MockAuthService{}
    handler := handlers.NewAuthHandler(authService)
    
    // 設置路由
    router := gin.New()
    router.POST("/register", handler.Register)
    
    // 準備測試數據
    user := map[string]interface{}{
        "name":     "Test User",
        "email":    "test@example.com",
        "password": "password123",
    }
    
    jsonData, _ := json.Marshal(user)
    
    // 創建請求
    req, _ := http.NewRequest("POST", "/register", bytes.NewBuffer(jsonData))
    req.Header.Set("Content-Type", "application/json")
    
    // 執行請求
    w := httptest.NewRecorder()
    router.ServeHTTP(w, req)
    
    // 驗證結果
    assert.Equal(t, http.StatusCreated, w.Code)
    
    var response map[string]interface{}
    err := json.Unmarshal(w.Body.Bytes(), &response)
    assert.NoError(t, err)
    assert.Contains(t, response, "user")
    assert.Contains(t, response, "token")
}

// 模擬服務
type MockAuthService struct{}

func (m *MockAuthService) Register(name, email, password string) (*entities.User, error) {
    return &entities.User{
        ID:    1,
        Name:  name,
        Email: email,
        Role:  "admin",
    }, nil
}

func (m *MockAuthService) Login(email, password string) (*entities.User, error) {
    return &entities.User{
        ID:    1,
        Email: email,
        Role:  "admin",
    }, nil
}
```

### tests/appointment_test.go
```go
package tests

import (
    "testing"
    "time"
    
    "github.com/stretchr/testify/assert"
    "beauty-ai-backend/internal/domain/entities"
    "beauty-ai-backend/internal/services"
)

func TestCreateAppointment(t *testing.T) {
    // 模擬 repositories
    appointmentRepo := &MockAppointmentRepository{}
    staffRepo := &MockStaffRepository{}
    serviceRepo := &MockServiceRepository{}
    
    // 創建服務
    service := services.NewAppointmentService(appointmentRepo, staffRepo, serviceRepo)
    
    // 準備測試數據
    appointment := &entities.Appointment{
        BusinessID: 1,
        BranchID:   1,
        CustomerID: 1,
        ServiceID:  1,
        StartTime:  time.Now().Add(24 * time.Hour),
    }
    
    // 執行測試
    result, err := service.CreateAppointment(appointment)
    
    // 驗證結果
    assert.NoError(t, err)
    assert.NotNil(t, result)
    assert.Equal(t, appointment.CustomerID, result.CustomerID)
}

// 模擬 repositories
type MockAppointmentRepository struct{}

func (m *MockAppointmentRepository) Create(appointment *entities.Appointment) (*entities.Appointment, error) {
    appointment.ID = 1
    return appointment, nil
}

func (m *MockAppointmentRepository) CheckTimeConflicts(branchID uint, startTime, endTime time.Time, staffID *uint) ([]*entities.Appointment, error) {
    return []*entities.Appointment{}, nil
}

type MockStaffRepository struct{}

func (m *MockStaffRepository) GetSchedule(staffID uint, date string) (*entities.StaffSchedule, error) {
    return &entities.StaffSchedule{
        StartTime: "09:00",
        EndTime:   "18:00",
    }, nil
}

type MockServiceRepository struct{}

func (m *MockServiceRepository) GetByID(id uint) (*entities.Service, error) {
    return &entities.Service{
        ID:       id,
        Duration: 60,
    }, nil
}
```

## API 文檔生成

### 安裝 Swagger
```bash
go install github.com/swaggo/swag/cmd/swag@latest
```

### 在 handler 中添加註解
```go
// Register godoc
// @Summary      註冊新用戶
// @Description  創建新的用戶帳戶
// @Tags         auth
// @Accept       json
// @Produce      json
// @Param        user body RegisterRequest true "用戶註冊信息"
// @Success      201  {object}  RegisterResponse
// @Failure      400  {object}  ErrorResponse
// @Router       /auth/register [post]
func (h *AuthHandler) Register(c *gin.Context) {
    // 實現代碼
}
```

### 生成文檔
```bash
# 在專案根目錄執行
swag init -g cmd/api/main.go
```

## 容器化部署

### Dockerfile
```dockerfile
# 多階段構建
FROM golang:1.21-alpine AS builder

# 設置工作目錄
WORKDIR /app

# 複製依賴文件
COPY go.mod go.sum ./
RUN go mod download

# 複製源代碼
COPY . .

# 構建應用
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main cmd/api/main.go

# 最終階段
FROM alpine:latest

# 安裝必要的包
RUN apk --no-cache add ca-certificates tzdata

# 設置時區
ENV TZ=Asia/Taipei

# 創建非 root 用戶
RUN addgroup -g 1001 appgroup && adduser -u 1001 -G appgroup -s /bin/sh -D appuser

# 設置工作目錄
WORKDIR /app

# 從 builder 階段複製二進制文件
COPY --from=builder /app/main .
COPY --from=builder /app/config.yaml .

# 創建上傳目錄
RUN mkdir -p uploads && chown -R appuser:appgroup /app

# 切換到非 root 用戶
USER appuser

# 暴露端口
EXPOSE 8080

# 設置健康檢查
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8080/health || exit 1

# 運行應用
CMD ["./main"]
```

### docker-compose.yml
```yaml
version: '3.8'

services:
  app:
    build: .
    container_name: beauty-ai-backend
    ports:
      - "8080:8080"
    environment:
      - DB_HOST=postgres
      - DB_PORT=5432
      - DB_NAME=beauty_ai
      - DB_USER=postgres
      - DB_PASSWORD=password
      - REDIS_HOST=redis
      - REDIS_PORT=6379
      - JWT_SECRET=your-super-secret-jwt-key
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    volumes:
      - ./uploads:/app/uploads
    restart: unless-stopped
    networks:
      - beauty-ai-network

  postgres:
    image: postgres:15-alpine
    container_name: beauty-ai-postgres
    environment:
      - POSTGRES_DB=beauty_ai
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=password
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5
    restart: unless-stopped
    networks:
      - beauty-ai-network

  redis:
    image: redis:7-alpine
    container_name: beauty-ai-redis
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    command: redis-server --appendonly yes
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 3s
      retries: 5
    restart: unless-stopped
    networks:
      - beauty-ai-network

  nginx:
    image: nginx:alpine
    container_name: beauty-ai-nginx
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/nginx/ssl
    depends_on:
      - app
    restart: unless-stopped
    networks:
      - beauty-ai-network

volumes:
  postgres_data:
  redis_data:

networks:
  beauty-ai-network:
    driver: bridge
```

### nginx.conf
```nginx
events {
    worker_connections 1024;
}

http {
    upstream backend {
        server app:8080;
    }

    server {
        listen 80;
        server_name api.beautyai.com;

        # HTTP to HTTPS redirect
        return 301 https://$server_name$request_uri;
    }

    server {
        listen 443 ssl http2;
        server_name api.beautyai.com;

        ssl_certificate /etc/nginx/ssl/cert.pem;
        ssl_certificate_key /etc/nginx/ssl/key.pem;

        location / {
            proxy_pass http://backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        location /uploads/ {
            alias /app/uploads/;
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
    }
}
```

## 部署腳本

### deploy.sh
```bash
#!/bin/bash

# 設置變量
APP_NAME="beauty-ai-backend"
DOCKER_REGISTRY="your-registry.com"
VERSION=${1:-latest}

echo "Building Docker image..."
docker build -t $DOCKER_REGISTRY/$APP_NAME:$VERSION .

echo "Pushing to registry..."
docker push $DOCKER_REGISTRY/$APP_NAME:$VERSION

echo "Deploying to production..."
docker-compose down
docker-compose pull
docker-compose up -d

echo "Checking health..."
sleep 10
curl -f http://localhost:8080/health || exit 1

echo "Deployment completed successfully!"
```

## 監控和日誌

### 添加健康檢查端點
```go
func (r *Routes) SetupRoutes() *gin.Engine {
    router := gin.New()
    
    // 健康檢查
    router.GET("/health", func(c *gin.Context) {
        c.JSON(200, gin.H{
            "status": "ok",
            "timestamp": time.Now(),
        })
    })
    
    // 其他路由...
    return router
}
```

### Makefile
```makefile
.PHONY: build run test clean docker-build docker-run

# 變量
APP_NAME=beauty-ai-backend
DOCKER_IMAGE=beauty-ai-backend:latest

# 構建
build:
	go build -o bin/$(APP_NAME) cmd/api/main.go

# 運行
run:
	go run cmd/api/main.go

# 測試
test:
	go test -v ./...

# 測試覆蓋率
test-coverage:
	go test -v -coverprofile=coverage.out ./...
	go tool cover -html=coverage.out

# 清理
clean:
	rm -rf bin/
	rm -f coverage.out

# Docker 構建
docker-build:
	docker build -t $(DOCKER_IMAGE) .

# Docker 運行
docker-run:
	docker-compose up -d

# Docker 停止
docker-stop:
	docker-compose down

# 生成 API 文檔
docs:
	swag init -g cmd/api/main.go

# 安裝依賴
deps:
	go mod download
	go mod tidy

# 代碼格式化
fmt:
	go fmt ./...

# 代碼檢查
lint:
	golangci-lint run

# 數據庫遷移
migrate-up:
	migrate -path migrations -database "postgres://user:password@localhost:5432/beauty_ai?sslmode=disable" up

migrate-down:
	migrate -path migrations -database "postgres://user:password@localhost:5432/beauty_ai?sslmode=disable" down
```

這份設置指南提供了完整的項目初始化、開發、測試和部署流程，可以幫助快速建立一個生產就緒的 Go API 後端服務。 