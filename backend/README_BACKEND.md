# BeautyAI Backend API (Go + Gin)

BeautyAI 美容管理系統的後端 API，使用 Go 語言和 Gin 框架構建，提供高效能、可擴展的 RESTful API 服務。

## 技術棧

- **語言**: Go 1.21+
- **框架**: Gin (HTTP Web Framework)
- **資料庫**: PostgreSQL (主要) / MongoDB (可選)
- **快取**: Redis
- **ORM**: GORM (PostgreSQL) / MongoDB Driver
- **身份驗證**: JWT
- **日誌**: Zap
- **文檔**: Swagger
- **配置**: Viper + 環境變數
- **容器化**: Docker & Docker Compose

## 專案結構

```
backend/
├── cmd/
│   └── server/                  # 應用程式入口點
│       └── main.go
├── internal/                    # 私有應用程式代碼
│   ├── config/                  # 配置管理
│   │   ├── config.go           # 配置結構和載入
│   │   └── database.go         # 資料庫配置
│   ├── handlers/                # HTTP 處理器 (Controllers)
│   │   ├── auth.go             # 身份驗證處理器
│   │   ├── appointments.go     # 預約管理處理器
│   │   ├── customers.go        # 客戶管理處理器
│   │   ├── staff.go            # 員工管理處理器
│   │   ├── services.go         # 服務管理處理器
│   │   ├── branches.go         # 門店管理處理器
│   │   ├── analytics.go        # 分析報表處理器
│   │   ├── goals.go            # 目標管理處理器
│   │   ├── subscriptions.go    # 訂閱管理處理器
│   │   └── billing.go          # 帳單管理處理器
│   ├── middleware/              # HTTP 中間件
│   │   ├── auth.go             # JWT 認證中間件
│   │   ├── cors.go             # CORS 中間件
│   │   ├── logging.go          # 日誌中間件
│   │   ├── rate_limit.go       # 速率限制中間件
│   │   └── recovery.go         # 錯誤恢復中間件
│   ├── models/                  # 數據模型
│   │   ├── user.go             # 用戶模型
│   │   ├── business.go         # 商家模型
│   │   ├── branch.go           # 門店模型
│   │   ├── staff.go            # 員工模型
│   │   ├── customer.go         # 客戶模型
│   │   ├── service.go          # 服務模型
│   │   ├── appointment.go      # 預約模型
│   │   ├── business_goal.go    # 業務目標模型
│   │   ├── subscription.go     # 訂閱模型
│   │   └── billing.go          # 帳單模型
│   ├── repository/              # 數據存取層
│   │   ├── interfaces/         # 儲存庫接口
│   │   ├── postgres/           # PostgreSQL 實現
│   │   └── mongodb/            # MongoDB 實現
│   ├── services/                # 業務邏輯層
│   │   ├── auth_service.go     # 認證業務邏輯
│   │   ├── appointment_service.go # 預約業務邏輯
│   │   ├── customer_service.go # 客戶業務邏輯
│   │   ├── staff_service.go    # 員工業務邏輯
│   │   ├── analytics_service.go # 分析業務邏輯
│   │   ├── goal_service.go     # 目標業務邏輯
│   │   └── subscription_service.go # 訂閱業務邏輯
│   └── utils/                   # 工具函數
│       ├── jwt.go              # JWT 工具
│       ├── validation.go       # 驗證工具
│       ├── password.go         # 密碼加密工具
│       └── response.go         # API 響應工具
├── pkg/                         # 可重用的包
│   ├── database/                # 資料庫連接
│   │   ├── postgres.go         # PostgreSQL 連接
│   │   ├── mongodb.go          # MongoDB 連接
│   │   └── redis.go            # Redis 連接
│   ├── logger/                  # 日誌工具
│   │   └── zap.go              # Zap 日誌配置
│   └── validator/               # 驗證工具
│       └── custom.go           # 自訂驗證規則
├── api/                         # API 定義
│   └── v1/                      # API v1 規格
│       ├── swagger.yaml        # Swagger 定義
│       └── routes.go           # 路由定義
├── docs/                        # 文檔和 Swagger 生成文件
│   ├── docs.go                 # Swagger 生成的文檔
│   ├── swagger.json            # Swagger JSON
│   └── swagger.yaml            # Swagger YAML
├── migrations/                  # 資料庫遷移
│   ├── postgres/               # PostgreSQL 遷移
│   └── mongodb/                # MongoDB 遷移
├── scripts/                     # 腳本工具
│   ├── build.sh               # 建置腳本
│   ├── deploy.sh              # 部署腳本
│   └── migrate.sh             # 遷移腳本
├── test/                        # 測試文件
│   ├── integration/            # 整合測試
│   ├── unit/                   # 單元測試
│   └── testdata/               # 測試數據
├── .env.example                 # 環境變數範本
├── Dockerfile                   # Docker 配置
├── docker-compose.yml           # Docker Compose 配置
├── go.mod                       # Go 模塊定義
├── go.sum                       # Go 模塊校驗
└── Makefile                     # 建置工具
```

## 快速開始

### 1. 環境需求

- Go 1.21 或更高版本
- PostgreSQL 14+ 或 MongoDB 6+
- Redis 7+
- Docker & Docker Compose (可選)

### 2. 安裝依賴

```bash
# 下載 Go 模塊
go mod download

# 安裝開發工具
go install github.com/swaggo/swag/cmd/swag@latest
go install github.com/golang-migrate/migrate/v4/cmd/migrate@latest
go install github.com/air-verse/air@latest
```

### 3. 配置環境

```bash
# 複製環境變數檔案
cp .env.example .env

# 編輯環境變數
vim .env
```

**環境變數配置範例**:
```env
# 伺服器配置
PORT=3000
GIN_MODE=debug
CORS_ORIGINS=http://localhost:3001,http://localhost:3000

# 資料庫配置
DATABASE_TYPE=postgres
DB_HOST=localhost
DB_PORT=5432
DB_NAME=beautyai
DB_USER=postgres
DB_PASSWORD=password
DB_SSLMODE=disable

# Redis 配置
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=
REDIS_DB=0

# JWT 配置
JWT_SECRET=your-super-secret-jwt-key
JWT_EXPIRES_IN=24h
JWT_REFRESH_EXPIRES_IN=168h

# 外部服務配置
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=your-email@gmail.com
SMTP_PASSWORD=your-app-password
```

### 4. 啟動資料庫 (使用 Docker)

```bash
# 啟動 PostgreSQL 和 Redis
docker-compose up postgres redis -d

# 或啟動 MongoDB (替代方案)
docker-compose --profile mongodb up mongodb redis -d
```

### 5. 資料庫遷移

```bash
# PostgreSQL 遷移
make migrate-up

# 或手動執行
migrate -path migrations/postgres -database "postgres://postgres:password@localhost:5432/beautyai?sslmode=disable" up
```

### 6. 運行應用程式

```bash
# 開發模式 (熱重載)
make dev
# 或
air

# 直接運行
make run
# 或
go run cmd/server/main.go

# 建置生產版本
make build
./bin/server
```

### 7. 生成 API 文檔

```bash
# 生成 Swagger 文檔
make swagger
# 或
swag init -g cmd/server/main.go -o ./docs

# 訪問文檔
# http://localhost:3000/swagger/index.html
```

## API 端點

### 健康檢查
- `GET /health` - 系統健康狀態
- `GET /ready` - 服務就緒狀態

### 身份驗證
- `POST /api/v1/auth/register` - 用戶註冊
- `POST /api/v1/auth/login` - 用戶登入
- `POST /api/v1/auth/logout` - 用戶登出
- `GET /api/v1/auth/me` - 獲取當前用戶信息
- `POST /api/v1/auth/refresh` - 刷新 JWT Token
- `POST /api/v1/auth/forgot-password` - 忘記密碼
- `POST /api/v1/auth/reset-password` - 重設密碼

### 業務管理
- `GET /api/v1/business` - 獲取商家信息
- `PUT /api/v1/business` - 更新商家信息
- `POST /api/v1/business/logo` - 上傳商家 Logo

### 門店管理
- `GET /api/v1/branches` - 獲取門店列表
- `POST /api/v1/branches` - 創建門店
- `GET /api/v1/branches/:id` - 獲取門店詳情
- `PUT /api/v1/branches/:id` - 更新門店
- `DELETE /api/v1/branches/:id` - 刪除門店
- `GET /api/v1/branches/:id/services` - 獲取門店服務列表
- `POST /api/v1/branches/:id/services` - 為門店添加服務

### 員工管理
- `GET /api/v1/staff` - 獲取員工列表
- `POST /api/v1/staff` - 創建員工
- `GET /api/v1/staff/:id` - 獲取員工詳情
- `PUT /api/v1/staff/:id` - 更新員工
- `DELETE /api/v1/staff/:id` - 刪除員工
- `GET /api/v1/staff/:id/performance` - 獲取員工績效
- `GET /api/v1/staff/:id/schedule` - 獲取員工排班
- `PUT /api/v1/staff/:id/schedule` - 更新員工排班

### 客戶管理
- `GET /api/v1/customers` - 獲取客戶列表
- `POST /api/v1/customers` - 創建客戶
- `GET /api/v1/customers/:id` - 獲取客戶詳情
- `PUT /api/v1/customers/:id` - 更新客戶
- `DELETE /api/v1/customers/:id` - 刪除客戶
- `GET /api/v1/customers/:id/history` - 獲取客戶服務歷史

### 服務管理
- `GET /api/v1/services` - 獲取服務列表
- `POST /api/v1/services` - 創建服務
- `GET /api/v1/services/:id` - 獲取服務詳情
- `PUT /api/v1/services/:id` - 更新服務
- `DELETE /api/v1/services/:id` - 刪除服務
- `GET /api/v1/services/categories` - 獲取服務分類

### 預約管理
- `GET /api/v1/appointments` - 獲取預約列表
- `POST /api/v1/appointments` - 創建預約
- `GET /api/v1/appointments/:id` - 獲取預約詳情
- `PUT /api/v1/appointments/:id` - 更新預約
- `DELETE /api/v1/appointments/:id` - 刪除預約
- `POST /api/v1/appointments/:id/confirm` - 確認預約
- `POST /api/v1/appointments/:id/cancel` - 取消預約

### 業務目標管理
- `GET /api/v1/goals` - 獲取目標列表
- `POST /api/v1/goals` - 創建目標
- `GET /api/v1/goals/:id` - 獲取目標詳情
- `PUT /api/v1/goals/:id` - 更新目標
- `DELETE /api/v1/goals/:id` - 刪除目標
- `GET /api/v1/goals/progress` - 獲取目標進度

### 數據分析
- `GET /api/v1/analytics/dashboard` - 獲取儀表板數據
- `GET /api/v1/analytics/performance` - 獲取績效分析
- `GET /api/v1/analytics/revenue` - 獲取營收分析
- `GET /api/v1/analytics/customer-insights` - 獲取客戶洞察
- `GET /api/v1/analytics/staff-performance` - 獲取員工績效分析

### 訂閱管理
- `GET /api/v1/subscriptions` - 獲取訂閱信息
- `POST /api/v1/subscriptions/upgrade` - 升級訂閱方案
- `POST /api/v1/subscriptions/downgrade` - 降級訂閱方案
- `POST /api/v1/subscriptions/cancel` - 取消訂閱

### 帳單管理
- `GET /api/v1/billing` - 獲取帳單列表
- `GET /api/v1/billing/:id` - 獲取帳單詳情
- `POST /api/v1/billing/:id/pay` - 支付帳單
- `GET /api/v1/billing/upcoming` - 獲取即將到期的帳單

## 開發工具

### Makefile 指令

```bash
# 開發相關
make dev          # 啟動開發模式 (熱重載)
make run          # 運行應用程式
make build        # 建置應用程式
make clean        # 清理建置文件

# 測試相關
make test         # 運行所有測試
make test-unit    # 運行單元測試
make test-integration # 運行整合測試
make coverage     # 生成測試覆蓋率報告

# 資料庫相關
make migrate-up   # 執行資料庫遷移
make migrate-down # 回滾資料庫遷移
make migrate-create NAME=create_table # 創建新的遷移檔案

# 代碼品質
make lint         # 運行代碼檢查
make fmt          # 格式化代碼
make vet          # 運行 go vet

# 文檔相關
make swagger      # 生成 Swagger 文檔
make docs         # 生成其他文檔

# Docker 相關
make docker-build # 建置 Docker 映像
make docker-run   # 運行 Docker 容器
```

### 測試

```bash
# 運行所有測試
go test ./...

# 運行測試並生成覆蓋率報告
go test -cover ./...

# 生成詳細覆蓋率報告
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out

# 運行基準測試
go test -bench=. ./...

# 運行特定包的測試
go test ./internal/services
```

### 代碼品質

```bash
# 代碼格式化
go fmt ./...

# 代碼檢查
go vet ./...

# 運行 linter
golangci-lint run

# 檢查安全性
gosec ./...

# 檢查依賴
go mod tidy
go mod verify
```

### 資料庫遷移

```bash
# 創建新的遷移檔案
migrate create -ext sql -dir migrations/postgres -seq create_users_table

# 運行遷移
migrate -path migrations/postgres -database "postgres://user:password@localhost/dbname?sslmode=disable" up

# 回滾遷移
migrate -path migrations/postgres -database "postgres://user:password@localhost/dbname?sslmode=disable" down

# 強制設定版本
migrate -path migrations/postgres -database "postgres://user:password@localhost/dbname?sslmode=disable" force 1
```

## 架構設計

### 分層架構

1. **Handler Layer** (controllers) - HTTP 請求處理
   - 負責處理 HTTP 請求和響應
   - 驗證請求參數
   - 調用業務邏輯層

2. **Service Layer** - 業務邏輯處理
   - 實現核心業務邏輯
   - 協調多個儲存庫操作
   - 處理業務規則和驗證

3. **Repository Layer** - 數據存取邏輯
   - 抽象化數據存取
   - 支持多種數據庫實現
   - 處理數據映射和查詢

4. **Model Layer** - 數據模型定義
   - 定義數據結構
   - 包含驗證規則
   - 支持 JSON 序列化

### 設計模式

- **Dependency Injection**: 使用接口進行依賴注入
- **Repository Pattern**: 抽象化數據存取層
- **Clean Architecture**: 清晰的依賴關係
- **Middleware Pattern**: 可組合的中間件
- **Factory Pattern**: 創建複雜對象

### 範例代碼結構

```go
// 儲存庫接口
type UserRepository interface {
    Create(ctx context.Context, user *models.User) error
    GetByID(ctx context.Context, id string) (*models.User, error)
    GetByEmail(ctx context.Context, email string) (*models.User, error)
    Update(ctx context.Context, user *models.User) error
    Delete(ctx context.Context, id string) error
}

// 服務層
type AuthService struct {
    userRepo UserRepository
    jwtUtil  *utils.JWTUtil
    logger   *zap.Logger
}

func (s *AuthService) Login(ctx context.Context, email, password string) (*LoginResponse, error) {
    user, err := s.userRepo.GetByEmail(ctx, email)
    if err != nil {
        return nil, err
    }
    
    if !utils.CheckPassword(password, user.HashedPassword) {
        return nil, ErrInvalidCredentials
    }
    
    token, err := s.jwtUtil.GenerateToken(user.ID)
    if err != nil {
        return nil, err
    }
    
    return &LoginResponse{
        User:  user,
        Token: token,
    }, nil
}

// 處理器層
type AuthHandler struct {
    authService *services.AuthService
    logger      *zap.Logger
}

func (h *AuthHandler) Login(c *gin.Context) {
    var req LoginRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        utils.ErrorResponse(c, http.StatusBadRequest, "Invalid request body")
        return
    }
    
    resp, err := h.authService.Login(c.Request.Context(), req.Email, req.Password)
    if err != nil {
        utils.HandleServiceError(c, err)
        return
    }
    
    utils.SuccessResponse(c, resp)
}
```

### 錯誤處理

```go
// 自訂錯誤類型
type AppError struct {
    Code    string `json:"code"`
    Message string `json:"message"`
    Details map[string]interface{} `json:"details,omitempty"`
}

func (e *AppError) Error() string {
    return e.Message
}

// 常見錯誤定義
var (
    ErrUserNotFound       = &AppError{Code: "USER_NOT_FOUND", Message: "User not found"}
    ErrInvalidCredentials = &AppError{Code: "INVALID_CREDENTIALS", Message: "Invalid email or password"}
    ErrUnauthorized       = &AppError{Code: "UNAUTHORIZED", Message: "Unauthorized access"}
)

// 錯誤處理中間件
func ErrorHandler() gin.HandlerFunc {
    return gin.CustomRecovery(func(c *gin.Context, recovered interface{}) {
        if err, ok := recovered.(error); ok {
            var appErr *AppError
            if errors.As(err, &appErr) {
                c.JSON(http.StatusBadRequest, gin.H{
                    "error": appErr,
                })
            } else {
                c.JSON(http.StatusInternalServerError, gin.H{
                    "error": map[string]string{
                        "code":    "INTERNAL_ERROR",
                        "message": "Internal server error",
                    },
                })
            }
        }
        c.Abort()
    })
}
```

## 安全特性

### 身份驗證和授權

- **JWT 認證**: 使用 JSON Web Tokens 進行無狀態認證
- **角色基礎權限**: 支持多角色權限控制
- **Token 刷新**: 自動刷新即將到期的 Token
- **密碼加密**: 使用 bcrypt 進行密碼雜湊

```go
// JWT 中間件
func JWTAuthMiddleware() gin.HandlerFunc {
    return func(c *gin.Context) {
        token := extractToken(c)
        if token == "" {
            c.JSON(http.StatusUnauthorized, gin.H{"error": "Missing token"})
            c.Abort()
            return
        }
        
        claims, err := validateToken(token)
        if err != nil {
            c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid token"})
            c.Abort()
            return
        }
        
        c.Set("user_id", claims.UserID)
        c.Set("role", claims.Role)
        c.Next()
    }
}
```

### 安全中間件

- **CORS**: 跨域請求控制
- **Rate Limiting**: 請求速率限制
- **Security Headers**: 安全標頭設定
- **Request Validation**: 輸入驗證和清理

```go
// CORS 中間件
func CORSMiddleware() gin.HandlerFunc {
    return cors.New(cors.Config{
        AllowOrigins:     []string{os.Getenv("CORS_ORIGINS")},
        AllowMethods:     []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
        AllowHeaders:     []string{"Origin", "Content-Type", "Authorization"},
        ExposeHeaders:    []string{"Content-Length"},
        AllowCredentials: true,
        MaxAge:           12 * time.Hour,
    })
}

// 速率限制中間件
func RateLimitMiddleware() gin.HandlerFunc {
    limiter := rate.NewLimiter(10, 100) // 每秒 10 個請求，突發 100 個
    return func(c *gin.Context) {
        if !limiter.Allow() {
            c.JSON(http.StatusTooManyRequests, gin.H{
                "error": "Rate limit exceeded",
            })
            c.Abort()
            return
        }
        c.Next()
    }
}
```

## 效能優化

### 資料庫優化

```go
// 資料庫連接池配置
func setupDatabase() *gorm.DB {
    dsn := buildDSN()
    db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{
        Logger: logger.Default.LogMode(logger.Info),
    })
    if err != nil {
        log.Fatal("Failed to connect to database")
    }
    
    sqlDB, _ := db.DB()
    sqlDB.SetMaxIdleConns(10)
    sqlDB.SetMaxOpenConns(100)
    sqlDB.SetConnMaxLifetime(time.Hour)
    
    return db
}

// 查詢優化範例
func (r *userRepository) GetUsersWithPagination(ctx context.Context, offset, limit int) ([]*models.User, error) {
    var users []*models.User
    
    err := r.db.WithContext(ctx).
        Select("id, name, email, created_at"). // 只選擇需要的欄位
        Offset(offset).
        Limit(limit).
        Order("created_at DESC").
        Find(&users).Error
        
    return users, err
}
```

### Redis 快取

```go
// Redis 快取服務
type CacheService struct {
    client *redis.Client
    ttl    time.Duration
}

func (c *CacheService) Set(ctx context.Context, key string, value interface{}) error {
    json, err := json.Marshal(value)
    if err != nil {
        return err
    }
    
    return c.client.Set(ctx, key, json, c.ttl).Err()
}

func (c *CacheService) Get(ctx context.Context, key string, dest interface{}) error {
    val, err := c.client.Get(ctx, key).Result()
    if err != nil {
        return err
    }
    
    return json.Unmarshal([]byte(val), dest)
}

// 在服務層使用快取
func (s *UserService) GetUser(ctx context.Context, id string) (*models.User, error) {
    cacheKey := fmt.Sprintf("user:%s", id)
    
    // 嘗試從快取獲取
    var user models.User
    if err := s.cache.Get(ctx, cacheKey, &user); err == nil {
        return &user, nil
    }
    
    // 從資料庫獲取
    user, err := s.userRepo.GetByID(ctx, id)
    if err != nil {
        return nil, err
    }
    
    // 存入快取
    s.cache.Set(ctx, cacheKey, user)
    
    return user, nil
}
```

## 部署

### Docker 部署

```dockerfile
# Dockerfile
FROM golang:1.21-alpine AS builder

WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main cmd/server/main.go

FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=builder /app/main .
COPY --from=builder /app/.env .

CMD ["./main"]
```

```yaml
# docker-compose.yml
version: '3.8'
services:
  backend:
    build: .
    ports:
      - "3000:3000"
    environment:
      - DATABASE_TYPE=postgres
      - DB_HOST=postgres
      - REDIS_HOST=redis
    depends_on:
      - postgres
      - redis
    
  postgres:
    image: postgres:15
    environment:
      POSTGRES_DB: beautyai
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: password
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"
      
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

volumes:
  postgres_data:
```

### 生產環境部署

```bash
# 建置生產映像
docker build -t beautyai-backend .

# 使用 Docker Compose 部署
docker-compose --profile production up -d

# 或手動部署
docker run -d \
  --name beautyai-backend \
  --env-file .env.production \
  -p 3000:3000 \
  beautyai-backend
```

### 健康檢查

```go
// 健康檢查端點
func (h *HealthHandler) Health(c *gin.Context) {
    health := map[string]interface{}{
        "status": "healthy",
        "timestamp": time.Now(),
        "version": os.Getenv("APP_VERSION"),
        "uptime": time.Since(startTime),
    }
    
    // 檢查資料庫連接
    if err := h.db.Ping(); err != nil {
        health["status"] = "unhealthy"
        health["database"] = "disconnected"
        c.JSON(http.StatusServiceUnavailable, health)
        return
    }
    
    health["database"] = "connected"
    
    // 檢查 Redis 連接
    if err := h.redis.Ping().Err(); err != nil {
        health["redis"] = "disconnected"
    } else {
        health["redis"] = "connected"
    }
    
    c.JSON(http.StatusOK, health)
}
```

## 監控和日誌

### 結構化日誌

```go
// 使用 Zap 進行結構化日誌
func setupLogger() *zap.Logger {
    config := zap.NewProductionConfig()
    config.OutputPaths = []string{"stdout", "/var/log/beautyai.log"}
    
    logger, err := config.Build()
    if err != nil {
        log.Fatal("Failed to setup logger")
    }
    
    return logger
}

// 在處理器中使用日誌
func (h *UserHandler) CreateUser(c *gin.Context) {
    h.logger.Info("Creating new user",
        zap.String("endpoint", "/api/v1/users"),
        zap.String("method", "POST"),
        zap.String("user_agent", c.GetHeader("User-Agent")),
    )
    
    // 處理邏輯...
    
    h.logger.Info("User created successfully",
        zap.String("user_id", user.ID),
        zap.Duration("duration", time.Since(start)),
    )
}
```

### Prometheus 指標

```go
// Prometheus 指標
var (
    httpRequestsTotal = prometheus.NewCounterVec(
        prometheus.CounterOpts{
            Name: "http_requests_total",
            Help: "Total number of HTTP requests",
        },
        []string{"method", "endpoint", "status"},
    )
    
    httpRequestDuration = prometheus.NewHistogramVec(
        prometheus.HistogramOpts{
            Name: "http_request_duration_seconds",
            Help: "HTTP request duration in seconds",
        },
        []string{"method", "endpoint"},
    )
)

// Prometheus 中間件
func PrometheusMiddleware() gin.HandlerFunc {
    return func(c *gin.Context) {
        start := time.Now()
        
        c.Next()
        
        duration := time.Since(start).Seconds()
        httpRequestsTotal.WithLabelValues(
            c.Request.Method,
            c.FullPath(),
            strconv.Itoa(c.Writer.Status()),
        ).Inc()
        
        httpRequestDuration.WithLabelValues(
            c.Request.Method,
            c.FullPath(),
        ).Observe(duration)
    }
}
```

## 貢獻指南

1. Fork 專案
2. 創建功能分支 (`git checkout -b feature/amazing-feature`)
3. 遵循代碼規範 (`make lint && make fmt`)
4. 編寫測試並確保通過 (`make test`)
5. 提交變更 (`git commit -m 'Add some amazing feature'`)
6. 推送到分支 (`git push origin feature/amazing-feature`)
7. 開啟 Pull Request

### 代碼規範

- 遵循 Go 官方編碼規範
- 使用 `gofmt` 格式化代碼
- 運行 `golangci-lint` 檢查代碼品質
- 編寫有意義的註釋和文檔
- 測試覆蓋率應達到 80% 以上

## 許可證

MIT License - 詳見 [LICENSE](../LICENSE) 檔案 