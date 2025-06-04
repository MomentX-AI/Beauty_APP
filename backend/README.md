# BeautyAI Backend API (Go + Gin)

這是 BeautyAI 美容管理系統的後端 API，使用 Go 語言和 Gin 框架構建，遵循最佳實踐。

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
│   └── server/          # 應用程式入口點
│       └── main.go
├── internal/            # 私有應用程式代碼
│   ├── config/          # 配置管理
│   ├── handlers/        # HTTP 處理器
│   ├── middleware/      # HTTP 中間件
│   ├── models/          # 數據模型
│   ├── repository/      # 數據存取層
│   ├── services/        # 業務邏輯層
│   └── utils/           # 工具函數
├── pkg/                 # 可重用的包
│   ├── database/        # 資料庫連接
│   ├── logger/          # 日誌工具
│   └── validator/       # 驗證工具
├── api/                 # API 定義
│   └── v1/              # API v1 規格
├── docs/                # 文檔和 Swagger 生成文件
├── migrations/          # 資料庫遷移
├── scripts/             # 腳本工具
├── .env.example         # 環境變數範本
├── Dockerfile           # Docker 配置
├── go.mod               # Go 模塊定義
└── go.sum               # Go 模塊校驗
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

# 安裝 Swagger 工具 (可選)
go install github.com/swaggo/swag/cmd/swag@latest
```

### 3. 配置環境

```bash
# 複製環境變數檔案
cp .env.example .env

# 編輯環境變數
vim .env
```

### 4. 啟動資料庫 (使用 Docker)

```bash
# 啟動 PostgreSQL 和 Redis
docker-compose up postgres redis -d

# 或啟動 MongoDB (替代方案)
docker-compose --profile mongodb up mongodb redis -d
```

### 5. 運行應用程式

```bash
# 開發模式
go run cmd/server/main.go

# 或使用 air 實現熱重載 (需要安裝 air)
air

# 建置生產版本
go build -o bin/server cmd/server/main.go
./bin/server
```

### 6. 生成 API 文檔

```bash
# 生成 Swagger 文檔
swag init -g cmd/server/main.go -o ./docs

# 訪問文檔: http://localhost:3000/swagger/index.html
```

## API 端點

### 健康檢查
- `GET /health` - 系統健康狀態

### 身份驗證
- `POST /api/v1/auth/register` - 用戶註冊
- `POST /api/v1/auth/login` - 用戶登入
- `POST /api/v1/auth/logout` - 用戶登出
- `GET /api/v1/auth/me` - 獲取當前用戶信息
- `POST /api/v1/auth/refresh` - 刷新 JWT Token

### 業務管理
- `GET /api/v1/business` - 獲取商家信息
- `PUT /api/v1/business` - 更新商家信息

### 門店管理
- `GET /api/v1/branches` - 獲取門店列表
- `POST /api/v1/branches` - 創建門店
- `GET /api/v1/branches/:id` - 獲取門店詳情
- `PUT /api/v1/branches/:id` - 更新門店
- `DELETE /api/v1/branches/:id` - 刪除門店

### 員工管理
- `GET /api/v1/staff` - 獲取員工列表
- `POST /api/v1/staff` - 創建員工
- `GET /api/v1/staff/:id` - 獲取員工詳情
- `PUT /api/v1/staff/:id` - 更新員工
- `DELETE /api/v1/staff/:id` - 刪除員工
- `GET /api/v1/staff/:id/performance` - 獲取員工績效

### 客戶管理
- `GET /api/v1/customers` - 獲取客戶列表
- `POST /api/v1/customers` - 創建客戶
- `GET /api/v1/customers/:id` - 獲取客戶詳情
- `PUT /api/v1/customers/:id` - 更新客戶
- `DELETE /api/v1/customers/:id` - 刪除客戶

### 服務管理
- `GET /api/v1/services` - 獲取服務列表
- `POST /api/v1/services` - 創建服務
- `GET /api/v1/services/:id` - 獲取服務詳情
- `PUT /api/v1/services/:id` - 更新服務
- `DELETE /api/v1/services/:id` - 刪除服務

### 預約管理
- `GET /api/v1/appointments` - 獲取預約列表
- `POST /api/v1/appointments` - 創建預約
- `GET /api/v1/appointments/:id` - 獲取預約詳情
- `PUT /api/v1/appointments/:id` - 更新預約
- `DELETE /api/v1/appointments/:id` - 刪除預約

### 數據分析
- `GET /api/v1/analytics/dashboard` - 獲取儀表板數據
- `GET /api/v1/analytics/performance` - 獲取績效分析
- `GET /api/v1/analytics/goals` - 獲取目標分析

### 訂閱管理
- `GET /api/v1/subscriptions` - 獲取訂閱信息
- `PUT /api/v1/subscriptions/plan` - 更新訂閱方案

### 帳單管理
- `GET /api/v1/billing` - 獲取帳單列表
- `GET /api/v1/billing/:id` - 獲取帳單詳情
- `POST /api/v1/billing/:id/pay` - 支付帳單

## 開發工具

### 測試

```bash
# 運行所有測試
go test ./...

# 運行測試並生成覆蓋率報告
go test -cover ./...

# 生成詳細覆蓋率報告
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out
```

### 代碼品質

```bash
# 代碼格式化
go fmt ./...

# 代碼檢查
go vet ./...

# 運行 linter (需要安裝 golangci-lint)
golangci-lint run
```

### 資料庫遷移

```bash
# 創建新的遷移檔案
migrate create -ext sql -dir migrations -seq create_users_table

# 運行遷移
migrate -path migrations -database "postgres://user:password@localhost/dbname?sslmode=disable" up

# 回滾遷移
migrate -path migrations -database "postgres://user:password@localhost/dbname?sslmode=disable" down
```

## 部署

### Docker 部署

```bash
# 建置並啟動所有服務
docker-compose up --build

# 生產環境部署
docker-compose --profile production up -d
```

### 手動部署

```bash
# 建置應用程式
go build -o bin/server cmd/server/main.go

# 設定生產環境變數
export NODE_ENV=production
export DATABASE_TYPE=postgres
export DB_HOST=your-db-host
# ... 其他環境變數

# 運行應用程式
./bin/server
```

## 架構設計

### 分層架構

1. **Handler Layer** - HTTP 請求處理
2. **Service Layer** - 業務邏輯處理
3. **Repository Layer** - 數據存取邏輯
4. **Model Layer** - 數據模型定義

### 設計原則

- **Clean Architecture** - 清晰的依賴關係
- **Dependency Injection** - 依賴注入
- **Interface Segregation** - 接口隔離
- **Single Responsibility** - 單一職責
- **SOLID Principles** - SOLID 設計原則

### 安全特性

- JWT 身份驗證
- CORS 配置
- 請求速率限制
- SQL 注入防護
- XSS 防護
- 安全標頭設定

## 貢獻指南

1. Fork 專案
2. 創建功能分支 (`git checkout -b feature/amazing-feature`)
3. 提交變更 (`git commit -m 'Add some amazing feature'`)
4. 推送到分支 (`git push origin feature/amazing-feature`)
5. 開啟 Pull Request

## 許可證

MIT License - 詳見 [LICENSE](../LICENSE) 檔案 