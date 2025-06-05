# BeautyAI 用戶註冊系統

本文檔說明 BeautyAI 美容管理系統的用戶註冊功能實現，包含前後端完整的數據結構和 API 接口。

## 系統架構

```
Frontend (Flutter) ←→ HTTP/JSON ←→ Backend (Go + Gin) ←→ PostgreSQL
                                         ↓
                                    JWT Token 認證
```

## 後端實現 (Go)

### 1. 數據模型 (`backend/internal/models/user.go`)

```go
type User struct {
    ID           string    `gorm:"primaryKey;type:varchar(36)" json:"id"`
    Email        string    `gorm:"uniqueIndex;type:varchar(255);not null" json:"email"`
    PasswordHash string    `gorm:"type:varchar(255);not null" json:"-"`
    Name         string    `gorm:"type:varchar(100);not null" json:"name"`
    BusinessName string    `gorm:"type:varchar(100);not null" json:"businessName"`
    Role         string    `gorm:"type:varchar(20);not null;default:'owner'" json:"role"`
    IsActive     bool      `gorm:"default:true" json:"isActive"`
    EmailVerified bool     `gorm:"default:false" json:"emailVerified"`
    LastLoginAt  *time.Time `json:"lastLoginAt,omitempty"`
    CreatedAt    time.Time `json:"createdAt"`
    UpdatedAt    time.Time `json:"updatedAt"`
    DeletedAt    gorm.DeletedAt `gorm:"index" json:"-"`
}
```

**特點：**
- 自動生成 UUID 作為主鍵
- 使用 bcrypt 加密密碼
- 支援軟刪除
- 自動時間戳管理

### 2. 服務層 (`backend/internal/services/user_service.go`)

**主要功能：**
- `Register()` - 用戶註冊
- `Login()` - 用戶登入
- `GetUserByID()` - 根據 ID 獲取用戶
- `UpdateUser()` - 更新用戶信息
- `ChangePassword()` - 修改密碼

**安全措施：**
- 電子郵件唯一性檢查
- 密碼強度驗證
- 數據驗證和清理

### 3. JWT 工具 (`backend/internal/utils/jwt.go`)

**功能：**
- 生成 Access Token 和 Refresh Token
- Token 驗證和解析
- 自動過期處理

**配置：**
- Access Token: 24 小時有效期
- Refresh Token: 7 天有效期
- 使用環境變數配置密鑰

### 4. API 路由 (`backend/internal/handlers/auth.go`)

#### 公開路由
- `POST /api/v1/auth/register` - 用戶註冊
- `POST /api/v1/auth/login` - 用戶登入
- `POST /api/v1/auth/refresh` - 刷新 Token

#### 需要認證的路由
- `POST /api/v1/auth/logout` - 用戶登出
- `GET /api/v1/auth/me` - 獲取當前用戶信息
- `PUT /api/v1/auth/profile` - 更新用戶資料
- `POST /api/v1/auth/change-password` - 修改密碼

## 前端實現 (Flutter)

### 1. 數據模型 (`frontend/lib/models/user.dart`)

```dart
class User {
  final String id;
  final String email;
  final String name;
  final String businessName;
  final String role;
  final bool isActive;
  final bool emailVerified;
  final DateTime? lastLoginAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // 構造函數、fromJson、toJson 等方法...
}
```

### 2. 認證服務 (`frontend/lib/services/auth_service.dart`)

**主要功能：**
- `register()` - 用戶註冊
- `login()` - 用戶登入
- `logout()` - 用戶登出
- `getProfile()` - 獲取用戶資料
- `updateProfile()` - 更新用戶資料
- 自動 Token 刷新機制

**使用範例：**
```dart
// 註冊
final success = await AuthService.register(
  name: '張三',
  email: 'user@example.com', 
  password: '123456',
  businessName: '美麗髮廊',
);

// 登入
final success = await AuthService.login('user@example.com', '123456');

// 獲取當前用戶
final user = AuthService.currentUser;
```

### 3. 註冊表單 (`frontend/lib/screens/register_screen.dart`)

**特點：**
- 即時表單驗證
- 用戶友好的錯誤提示
- 響應式設計
- 載入狀態管理

**驗證規則：**
- 姓名：必填，2-50 字符
- 商家名稱：必填，2-100 字符
- 電子郵件：必填，有效格式
- 密碼：必填，最少 6 位
- 確認密碼：必須與密碼一致

## API 文檔

### 註冊 API

**請求：**
```bash
POST /api/v1/auth/register
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "123456", 
  "name": "張三",
  "businessName": "美麗髮廊"
}
```

**成功回應 (201)：**
```json
{
  "success": true,
  "message": "註冊成功",
  "data": {
    "user": {
      "id": "uuid-string",
      "email": "user@example.com",
      "name": "張三",
      "businessName": "美麗髮廊",
      "role": "owner",
      "isActive": true,
      "emailVerified": false,
      "createdAt": "2024-01-01T10:00:00Z",
      "updatedAt": "2024-01-01T10:00:00Z"
    },
    "token": "jwt-access-token",
    "refresh_token": "jwt-refresh-token",
    "expires_at": 1704110400
  }
}
```

**錯誤回應：**
- `400` - 請求數據格式錯誤
- `409` - 電子郵件已被註冊
- `500` - 服務器內部錯誤

### 登入 API

**請求：**
```bash
POST /api/v1/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "123456"
}
```

**成功回應 (200)：**
```json
{
  "success": true,
  "message": "登入成功", 
  "data": {
    "user": { /* 用戶信息 */ },
    "token": "jwt-access-token",
    "refresh_token": "jwt-refresh-token",
    "expires_at": 1704110400
  }
}
```

## 資料庫結構

```sql
CREATE TABLE users (
    id VARCHAR(36) PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(100) NOT NULL,
    business_name VARCHAR(100) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'owner',
    is_active BOOLEAN DEFAULT TRUE,
    email_verified BOOLEAN DEFAULT FALSE,
    last_login_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL
);
```

**索引：**
- `idx_users_email` - 電子郵件唯一索引
- `idx_users_role` - 角色索引
- `idx_users_is_active` - 活躍狀態索引
- `idx_users_deleted_at` - 軟刪除索引

## 安全特性

### 1. 密碼安全
- 使用 bcrypt 進行密碼雜湊
- 最小密碼長度要求
- 密碼不會在 API 回應中返回

### 2. JWT 安全
- 使用強密鑰簽名
- 短期 Access Token (24小時)
- 長期 Refresh Token (7天)
- Token 自動刷新機制

### 3. 輸入驗證
- 後端嚴格驗證所有輸入
- 前端即時驗證提升用戶體驗
- SQL 注入防護 (GORM ORM)

### 4. CORS 配置
- 限制允許的來源域名
- 適當的 HTTP 標頭設置

## 部署指南

### 1. 環境變數配置

```bash
# .env 文件
DB_HOST=localhost
DB_PORT=5432
DB_NAME=beautyai
DB_USER=postgres
DB_PASSWORD=password
DB_SSLMODE=disable

JWT_SECRET=your-super-secret-jwt-key
JWT_EXPIRE=24h
JWT_REFRESH_SECRET=your-refresh-token-secret
JWT_REFRESH_EXPIRE=168h

PORT=3001
```

### 2. 啟動後端

```bash
cd backend
go mod tidy
go run cmd/server/main.go
```

### 3. 啟動前端

```bash
cd frontend  
flutter pub get
flutter run -d web --web-port 3001
```

### 4. 測試 API

```bash
chmod +x backend/test_register.sh
./backend/test_register.sh
```

## 監控和日誌

### 1. 日誌記錄
- 結構化日誌 (JSON 格式)
- 不同級別的日誌 (Debug, Info, Warn, Error)
- 敏感信息過濾

### 2. 錯誤處理
- 統一的錯誤回應格式
- 詳細的錯誤碼和訊息
- 中英文錯誤訊息支援

### 3. 監控指標
- API 回應時間
- 註冊成功率
- 登入失敗次數
- 資料庫連接狀態

## 未來增強

### 1. 電子郵件驗證
- 註冊後發送驗證郵件
- 郵件驗證狀態管理

### 2. 忘記密碼
- 密碼重設郵件
- 安全的密碼重設流程

### 3. 社群登入
- Google、Facebook 登入整合
- OAuth 2.0 支援

### 4. 多因素認證
- SMS 驗證碼
- TOTP 認證器支援

### 5. 帳號安全
- 登入異常檢測
- 設備管理
- 登入歷史記錄

## 故障排除

### 常見問題

1. **資料庫連接失敗**
   - 檢查 PostgreSQL 是否運行
   - 驗證環境變數配置
   - 確認資料庫存在

2. **JWT Token 無效**
   - 檢查密鑰配置
   - 確認時區設置
   - 驗證 Token 格式

3. **CORS 錯誤**
   - 檢查前端請求來源
   - 更新 CORS 配置
   - 確認請求標頭

4. **前端無法連接後端**
   - 檢查後端服務是否運行
   - 驗證 API 基礎 URL
   - 確認端口配置

### 開發工具

- **API 測試**: Postman 或 curl
- **資料庫管理**: pgAdmin 或 DBeaver  
- **日誌監控**: 控制台輸出或文件日誌
- **代碼品質**: golangci-lint (Go), flutter analyze (Flutter)

本用戶註冊系統提供了完整、安全、可擴展的認證解決方案，適合用於生產環境的美容管理系統。 