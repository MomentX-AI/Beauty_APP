# BeautyAI 美容管理系統 (Full-Stack Application)

BeautyAI 是一款專為美容沙龍和美容業者設計的全棧應用，提供完整的美容業務管理解決方案。本專案採用現代化的技術架構，包含 Flutter 跨平台前端應用和 Go 語言後端 API 服務。

## 專案架構

```
BeautyAI/
├── frontend/                 # Flutter 跨平台應用
│   ├── lib/
│   │   ├── components/       # 通用UI組件
│   │   ├── models/          # 數據模型
│   │   ├── screens/         # 應用界面
│   │   ├── services/        # API和業務邏輯服務
│   │   └── main.dart        # 應用入口點
│   ├── android/             # Android 平台配置
│   ├── ios/                 # iOS 平台配置
│   ├── web/                 # Web 平台配置
│   └── pubspec.yaml         # Flutter 依賴配置
├── backend/                  # Go + Gin 後端 API
│   ├── cmd/server/          # 應用程式入口點
│   ├── internal/            # 私有應用程式代碼
│   │   ├── handlers/        # HTTP 處理器
│   │   ├── models/          # 數據模型
│   │   ├── services/        # 業務邏輯層
│   │   └── repository/      # 數據存取層
│   ├── pkg/                 # 可重用的包
│   ├── migrations/          # 資料庫遷移
│   └── go.mod               # Go 模塊定義
├── docs/                     # 專案文檔
│   ├── api/                 # API 文檔
│   └── database/            # 資料庫設計文檔
├── docker-compose.yml        # Docker 容器配置
└── README.md                # 專案說明文檔
```

## 技術棧

### 前端 (Flutter)
- **框架**: Flutter 3.0+ / Dart 3.0+
- **平台支持**: iOS、Android、Web、Desktop
- **UI 框架**: Material Design 3
- **路由管理**: go_router
- **圖表可視化**: fl_chart
- **狀態管理**: Provider / Riverpod

### 後端 (Go)
- **語言**: Go 1.21+
- **框架**: Gin (HTTP Web Framework)
- **資料庫**: PostgreSQL (主要) / MongoDB (可選)
- **快取**: Redis
- **ORM**: GORM (PostgreSQL) / MongoDB Driver
- **身份驗證**: JWT
- **文檔**: Swagger
- **容器化**: Docker & Docker Compose

### 基礎設施
- **資料庫**: PostgreSQL 14+ / MongoDB 6+
- **快取**: Redis 7+
- **容器化**: Docker & Docker Compose
- **部署**: Cloud platforms (AWS, GCP, Azure)

## 快速開始

### 環境需求

- **前端**: Flutter SDK >= 3.0.0, Dart SDK >= 3.0.0
- **後端**: Go 1.21+, PostgreSQL 14+, Redis 7+
- **工具**: Docker & Docker Compose (推薦)

### 快速部署 (Docker)

```bash
# 克隆專案
git clone https://github.com/yourusername/BeautyAI.git
cd BeautyAI

# 啟動所有服務 (資料庫、後端、前端)
docker-compose up --build

# 訪問應用
# 前端: http://localhost:3001
# 後端 API: http://localhost:3000
# API 文檔: http://localhost:3000/swagger/index.html
```

### 本地開發

1. **啟動資料庫服務**
   ```bash
   docker-compose up postgres redis -d
   ```

2. **啟動後端服務**
   ```bash
   cd backend
   cp .env.example .env
   # 編輯 .env 配置資料庫連線
   go run cmd/server/main.go
   ```

3. **啟動前端應用**
   ```bash
   cd frontend
   flutter pub get
   flutter run -d web --web-port 3001
   ```

## 系統功能

### 核心功能模塊

- **門店績效分析**: 營運數據概覽和重要指標分析
- **預約管理**: 客戶預約排程、員工指定和衝突檢查
- **客戶管理**: 客戶資料和服務歷史記錄管理
- **服務管理**: 美容服務項目管理和多門店定價
- **員工管理**: 員工資料、多門店分配、排班和績效管理
- **業務目標管理**: 三層級目標設定與追蹤 (企業/門店/員工)
- **AI 助理**: 智能業務推薦和決策支持
- **方案管理**: 訂閱方案選擇和升級管理
- **帳單管理**: 費用帳單查看和付款處理
- **用戶管理**: 多角色權限和身份驗證

### 訂閱方案

#### Basic 基礎版 (NT$ 300/員工/月)
- 適合單一門店的美容業者
- 單一門店管理、基礎預約管理
- 客戶資料管理、員工管理
- 基礎報表分析、AI 助理
- 基礎技術支援

#### Business 商業版 (NT$ 450/員工/月)
- 適合多門店連鎖美容業者
- 多門店管理（無限制）、進階預約管理
- 多門店庫存管理、進階權限控制
- 進階報表分析、自訂報表
- 優先技術支援

## 前後端整合

### API 通信架構

```
Flutter Frontend ←→ HTTP/JSON ←→ Go Gin Backend ←→ PostgreSQL/MongoDB
                                       ↓
                                    Redis Cache
```

### 認證流程

1. **用戶登入**: 前端發送登入請求到後端
2. **JWT 簽發**: 後端驗證成功後簽發 JWT Token
3. **Token 存儲**: 前端存儲 Token 並加入 HTTP Headers
4. **請求認證**: 所有 API 請求都攜帶 Token 進行身份驗證
5. **Token 刷新**: 自動刷新即將到期的 Token

### 數據同步

- **即時更新**: 使用 WebSocket 或 Server-Sent Events 進行即時數據推送
- **離線支持**: 前端本地快取，支持離線查看和操作
- **衝突解決**: 智能合併策略處理資料衝突

## 開發環境設置

### API 端點配置

開發和生產環境的 API 端點配置：

```dart
// frontend/lib/config/api_config.dart
class ApiConfig {
  static const String devBaseUrl = 'http://localhost:3000/api/v1';
  static const String prodBaseUrl = 'https://api.beautyai.com/api/v1';
}
```

### 環境變數

**後端環境變數 (.env)**:
```env
# 伺服器配置
PORT=3000
NODE_ENV=development

# 資料庫配置
DATABASE_TYPE=postgres
DB_HOST=localhost
DB_PORT=5432
DB_NAME=beautyai
DB_USER=postgres
DB_PASSWORD=password

# Redis 配置
REDIS_HOST=localhost
REDIS_PORT=6379

# JWT 配置
JWT_SECRET=your-secret-key
JWT_EXPIRES_IN=24h
```

## 部署指南

### 生產環境部署

1. **使用 Docker Compose**
   ```bash
   # 生產環境配置
   docker-compose --profile production up -d
   ```

2. **雲端部署**
   - **後端**: 部署到 Google Cloud Run / AWS ECS / Azure Container Instances
   - **前端**: 部署到 Netlify / Vercel / Firebase Hosting
   - **資料庫**: 使用雲端資料庫服務 (Cloud SQL, RDS, Atlas)

### CI/CD 流程

```yaml
# .github/workflows/deploy.yml
name: Deploy BeautyAI
on:
  push:
    branches: [main]
jobs:
  deploy-backend:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Deploy Backend
        run: |
          cd backend
          # Build and deploy Go backend
  
  deploy-frontend:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Deploy Frontend
        run: |
          cd frontend
          # Build and deploy Flutter web
```

## 監控和維護

### 系統監控

- **後端監控**: 使用 Prometheus + Grafana 監控 API 性能
- **前端監控**: 整合 Firebase Analytics / Google Analytics
- **錯誤追蹤**: Sentry 進行錯誤監控和報告
- **日誌管理**: ELK Stack (Elasticsearch, Logstash, Kibana)

### 效能優化

- **後端**: 資料庫索引優化、Redis 快取策略、API 響應壓縮
- **前端**: 代碼分割、圖片懶加載、離線快取策略
- **網路**: CDN 配置、GZIP 壓縮、HTTP/2 支援

## 開發團隊和貢獻

### 開發規範

- **代碼風格**: 
  - Go: `gofmt` + `golangci-lint`
  - Flutter: `dart format` + `flutter_lints`
- **提交規範**: 遵循 Conventional Commits
- **分支策略**: GitFlow 工作流程
- **代碼審查**: 所有 PR 都需要代碼審查

### 貢獻指南

1. Fork 專案並創建功能分支
2. 遵循代碼規範和測試覆蓋率要求
3. 更新相關文檔
4. 提交 Pull Request 並等待審查

## 技術支援

- **文檔**: 詳見 `docs/` 目錄
- **問題回報**: GitHub Issues
- **技術討論**: GitHub Discussions
- **聯繫方式**: dev@beautyai.com

## 許可證

MIT License - 詳見 [LICENSE](LICENSE) 檔案
