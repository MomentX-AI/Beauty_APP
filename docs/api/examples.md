# BeautyAIGO API 示例

本文檔提供了一些常用API端點的請求和響應示例，幫助前端開發人員更好地理解如何使用API。

## 身份驗證

### 註冊用戶
```
POST /api/v1/auth/register
Content-Type: application/json

{
  "email": "user@example.com",
  "username": "testuser",
  "password": "password123",
  "first_name": "John",
  "last_name": "Doe"
}
```

**響應**:
```json
{
  "id": 1,
  "email": "user@example.com",
  "username": "testuser",
  "first_name": "John",
  "last_name": "Doe",
  "active": true,
  "created_at": "2025-05-07T12:00:00Z",
  "updated_at": "2025-05-07T12:00:00Z"
}
```

### 登錄
```
POST /api/v1/auth/login
Content-Type: application/json

{
  "username": "testuser",
  "password": "password123"
}
```

**響應**:
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expires_at": "2025-05-08T12:00:00Z",
  "user": {
    "id": 1,
    "email": "user@example.com",
    "username": "testuser"
  }
}
```

## 業務管理

### 創建業務
```
POST /api/v1/businesses
Content-Type: application/json
Authorization: Bearer YOUR_JWT_TOKEN

{
  "name": "Beauty Salon A",
  "description": "Premium beauty salon services",
  "address": "123 Main St, City",
  "phone": "+886912345678",
  "email": "info@beautysalona.com",
  "website": "https://beautysalona.com"
}
```

**響應**:
```json
{
  "id": 1,
  "name": "Beauty Salon A",
  "description": "Premium beauty salon services",
  "address": "123 Main St, City",
  "phone": "+886912345678",
  "email": "info@beautysalona.com",
  "website": "https://beautysalona.com",
  "logo_url": null,
  "is_active": true,
  "owner_id": 1,
  "created_at": "2025-05-07T12:30:00Z",
  "updated_at": "2025-05-07T12:30:00Z"
}
```

## 分店管理

### 創建分店（含營業時間）
```
POST /api/v1/branches?business_id=1
Content-Type: application/json
Authorization: Bearer YOUR_JWT_TOKEN

{
  "name": "Downtown Branch",
  "address": "456 Center St, City",
  "contact_phone": "+886923456789",
  "is_default": true,
  "operating_hours_start": "09:00",
  "operating_hours_end": "18:00"
}
```

**響應**:
```json
{
  "id": 1,
  "business_id": 1,
  "name": "Downtown Branch",
  "contact_phone": "+886923456789",
  "address": "456 Center St, City",
  "is_default": true,
  "status": "active",
  "operating_hours_start": "09:00",
  "operating_hours_end": "18:00",
  "created_at": "2025-05-07T13:00:00Z",
  "updated_at": "2025-05-07T13:00:00Z"
}
```

### 列出業務的所有分店
```
GET /api/v1/branches?business_id=1
Authorization: Bearer YOUR_JWT_TOKEN
```

**響應**:
```json
{
  "data": [
    {
      "id": 1,
      "business_id": 1,
      "name": "Downtown Branch",
      "contact_phone": "+886923456789",
      "address": "456 Center St, City",
      "is_default": true,
      "status": "active",
      "created_at": "2025-05-07T13:00:00Z",
      "updated_at": "2025-05-07T13:00:00Z"
    },
    {
      "id": 2,
      "business_id": 1,
      "name": "Uptown Branch",
      "contact_phone": "+886934567890",
      "address": "789 North St, City",
      "is_default": false,
      "status": "active",
      "created_at": "2025-05-07T13:15:00Z",
      "updated_at": "2025-05-07T13:15:00Z"
    }
  ],
  "pagination": {
    "current_page": 1,
    "per_page": 10,
    "total_items": 2,
    "total_pages": 1
  }
}
```

## 分店特殊營業日管理（新功能）

### 新增特殊營業日
```
POST /api/v1/branch-special-days
Content-Type: application/json
Authorization: Bearer YOUR_JWT_TOKEN

{
  "branch_id": 1,
  "date": "2025-05-20",
  "is_open": false,
  "operating_hours_start": "10:00",
  "operating_hours_end": "16:00",
  "reason": "端午節"
}
```

**響應**:
```json
{
  "id": "ksuid123...",
  "branch_id": 1,
  "date": "2025-05-20",
  "is_open": false,
  "operating_hours_start": "10:00",
  "operating_hours_end": "16:00",
  "reason": "端午節",
  "created_at": "2025-05-10T10:00:00Z",
  "updated_at": "2025-05-10T10:00:00Z"
}
```

### 查詢特殊營業日
```
GET /api/v1/branch-special-days?branch_id=1&date=2025-05-20
Authorization: Bearer YOUR_JWT_TOKEN
```

**響應**:
```json
{
  "id": "ksuid123...",
  "branch_id": 1,
  "date": "2025-05-20",
  "is_open": false,
  "operating_hours_start": "10:00",
  "operating_hours_end": "16:00",
  "reason": "端午節"
}
```

## 團隊成員管理

### 創建團隊成員
```
POST /api/v1/team-members
Content-Type: application/json
Authorization: Bearer YOUR_JWT_TOKEN

{
  "business_id": 1,
  "branch_id": 1,
  "user_id": 2,
  "display_name": "Alex Smith",
  "position": "Hair Stylist",
  "status": "active"
}
```

**響應**:
```json
{
  "id": 1,
  "business_id": 1,
  "branch_id": 1,
  "user_id": 2,
  "display_name": "Alex Smith",
  "position": "Hair Stylist",
  "status": "active",
  "created_at": "2025-05-07T14:00:00Z",
  "updated_at": "2025-05-07T14:00:00Z"
}
```

### 列出分店的所有團隊成員
```
GET /api/v1/team-members?branch_id=1
Authorization: Bearer YOUR_JWT_TOKEN
```

**響應**:
```json
{
  "data": [
    {
      "id": 1,
      "business_id": 1,
      "branch_id": 1,
      "user_id": 2,
      "display_name": "Alex Smith",
      "position": "Hair Stylist",
      "status": "active",
      "created_at": "2025-05-07T14:00:00Z",
      "updated_at": "2025-05-07T14:00:00Z"
    },
    {
      "id": 2,
      "business_id": 1,
      "branch_id": 1,
      "user_id": 3,
      "display_name": "Jamie Wilson",
      "position": "Makeup Artist",
      "status": "active",
      "created_at": "2025-05-07T14:15:00Z",
      "updated_at": "2025-05-07T14:15:00Z"
    }
  ],
  "pagination": {
    "current_page": 1,
    "per_page": 10,
    "total_items": 2,
    "total_pages": 1
  }
}
```

## 錯誤響應格式

當API遇到錯誤時，將返回適當的HTTP狀態碼和JSON格式的錯誤信息：

```json
{
  "error": "錯誤信息描述"
}
```

常見的錯誤狀態碼：
- 400 Bad Request - 請求參數無效
- 401 Unauthorized - 未提供有效的身份驗證憑據
- 403 Forbidden - 沒有權限訪問請求的資源
- 404 Not Found - 請求的資源不存在
- 409 Conflict - 請求與資源當前狀態衝突
- 500 Internal Server Error - 服務器內部錯誤 