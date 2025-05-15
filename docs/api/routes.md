# BeautyAIGO API 路由文檔

本文檔提供了BeautyAIGO API的所有路由端點，方便前端工程師理解和調用。所有端點均使用JSON格式進行數據交換。

## 基礎路徑
所有API路由都以 `/api/v1` 開頭。

## 服務狀態
- `GET /api/v1/health` - 檢查API服務器健康狀態

## 身份驗證
以下端點不需要JWT身份驗證：

- `POST /api/v1/auth/register` - 註冊新用戶
- `POST /api/v1/auth/login` - 登錄並獲取JWT令牌

## 用戶管理
以下端點需要JWT身份驗證：

- `GET /api/v1/users` - 列出所有用戶
- `GET /api/v1/users/:id` - 獲取特定用戶
- `PUT /api/v1/users/:id` - 更新用戶資料
- `PUT /api/v1/users/:id/password` - 變更用戶密碼
- `PUT /api/v1/users/:id/status` - 激活/停用用戶
- `DELETE /api/v1/users/:id` - 刪除用戶（軟刪除）

## 角色管理
以下端點需要JWT身份驗證：

- `POST /api/v1/roles` - 創建角色
- `GET /api/v1/roles` - 列出所有角色
- `GET /api/v1/roles/:id` - 獲取特定角色
- `PUT /api/v1/roles/:id` - 更新角色
- `DELETE /api/v1/roles/:id` - 刪除角色
- `POST /api/v1/roles/:id/permissions` - 為角色添加權限
- `DELETE /api/v1/roles/:id/permissions/:permID` - 從角色移除權限
- `GET /api/v1/roles/:id/permissions` - 獲取角色的所有權限

## 權限管理
以下端點需要JWT身份驗證：

- `POST /api/v1/permissions` - 創建權限
- `GET /api/v1/permissions` - 列出所有權限
- `GET /api/v1/permissions/:id` - 獲取特定權限
- `PUT /api/v1/permissions/:id` - 更新權限
- `DELETE /api/v1/permissions/:id` - 刪除權限

## 用戶角色管理
以下端點需要JWT身份驗證：

- `POST /api/v1/user-roles/:user_id` - 為用戶分配角色
- `DELETE /api/v1/user-roles/:user_id/:role_id` - 移除用戶的角色 (需要 `business_id` 查詢參數)
- `GET /api/v1/user-roles/:user_id` - 獲取用戶的所有角色 (可選 `business_id` 查詢參數進行過濾)

## 業務管理
以下端點需要JWT身份驗證：

- `POST /api/v1/businesses` - 創建新業務
- `GET /api/v1/businesses` - 列出用戶可訪問的業務 (支持分頁: `page`, `page_size`)
- `GET /api/v1/businesses/:id` - 獲取特定業務的詳細信息
- `PUT /api/v1/businesses/:id` - 更新業務信息
- `DELETE /api/v1/businesses/:id` - 刪除業務 (軟刪除)
- `GET /api/v1/businesses/:id/branches` - 獲取業務及其所有分店
- `GET /api/v1/businesses/owner/:ownerID` - 獲取特定所有者的業務

## 分店管理
以下端點需要JWT身份驗證：

- `POST /api/v1/branches` - 創建分店 (需要 business_id 查詢參數)
- `GET /api/v1/branches/:id` - 獲取特定分店（含營業時間欄位 operating_hours_start/end）
- `GET /api/v1/branches` - 列出業務的所有分店 (需要 business_id 查詢參數)
- `PUT /api/v1/branches/:id` - 更新分店資料（可更新營業時間）
- `DELETE /api/v1/branches/:id` - 刪除分店
- `PUT /api/v1/branches/:id/default` - 設置分店為業務的默認分店 (需要 business_id 查詢參數)
- `PUT /api/v1/branches/:id/status` - 更新分店狀態

## 分店特殊營業日管理（新功能）
以下端點需要JWT身份驗證：

- `POST /api/v1/branch-special-days` - 新增特殊營業日（需 branch_id, date, is_open, operating_hours_start/end, reason）
- `GET /api/v1/branch-special-days?branch_id=...&date=...` - 查詢特定分店某日特殊營業日
- `PUT /api/v1/branch-special-days/:id` - 更新特殊營業日
- `DELETE /api/v1/branch-special-days/:id` - 刪除特殊營業日

## 團隊成員管理
以下端點需要JWT身份驗證：

- `POST /api/v1/team-members` - 創建團隊成員
- `GET /api/v1/team-members` - 列出團隊成員 (可以通過 business_id 或 branch_id 查詢參數進行過濾)
- `GET /api/v1/team-members/:id` - 獲取特定團隊成員
- `PUT /api/v1/team-members/:id` - 更新團隊成員資料
- `PUT /api/v1/team-members/:id/status` - 更新團隊成員狀態
- `DELETE /api/v1/team-members/:id` - 刪除團隊成員

## 業務目標管理（路由優化，2025-05）
以下端點需要JWT身份驗證：

- `POST /api/v1/businesses/:id/goals` - 新增業務目標（id 為 business ID，路由已統一避免萬用字元衝突）
- `GET /api/v1/businesses/:id/goals` - 取得指定 business 的目標列表
- `GET /api/v1/business-goals/:goalID` - 取得單一目標
- `PUT /api/v1/business-goals/:goalID` - 更新目標
- `DELETE /api/v1/business-goals/:goalID` - 刪除目標
- `PUT /api/v1/business-goals/:goalID/progress` - 更新目標進度

## 參數格式說明

### 路徑參數
- `:id`, `:user_id`, `:role_id`, `:permID`, `:ownerID` - 整數ID

### 查詢參數
- `business_id` - 過濾特定業務的記錄
- `branch_id` - 過濾特定分店的記錄
- 分頁參數:
  - `page` - 頁碼，默認為1
  - `per_page` - 每頁記錄數，默認為10

### 請求/響應格式
所有請求和響應均使用JSON格式。詳細的數據結構可以參考API實現的相應handler文件。

## 授權規則

大多數API需要JWT授權。在請求頭中添加:
```
Authorization: Bearer YOUR_JWT_TOKEN
```

其中`YOUR_JWT_TOKEN`是通過`/api/v1/auth/login`獲得的JWT令牌。 