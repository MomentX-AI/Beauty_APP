# BeautyAI Backend Models

本目錄包含 BeautyAI 美容管理系統後端的所有資料模型，與前端 Flutter 應用的模型完全對應。

## 模型列表

### 核心業務模型

#### 1. User (用戶模型) - `user.go`
- 對應前端：`frontend/lib/models/user.dart`
- 描述：系統用戶，包含認證、權限管理
- 關鍵字段：
  - `business_id`: 關聯商家ID
  - `role`: 用戶角色 (owner/admin/manager/staff)
  - `email_verified`: 郵箱驗證狀態
- 包含模型：
  - `User`: 主要用戶模型
  - `UserResponse`: API響應格式
  - `AuthResponse`: 認證響應
  - `AuthData`: 認證數據

#### 2. Business (商家模型) - `business.go`
- 對應前端：`frontend/lib/models/business.dart`
- 描述：美容業者的商家信息
- 關鍵字段：
  - `logo_url`: 商家Logo
  - `timezone`: 時區設置
  - `social_links`: 社交媒體鏈接

#### 3. Branch (門店模型) - `branch.go`
- 對應前端：`frontend/lib/models/branch.dart`
- 描述：商家的分店信息
- 關鍵字段：
  - `is_default`: 是否為預設門店
  - `operating_hours_start/end`: 營業時間
  - `status`: 門店狀態 (active/inactive/closed)

#### 4. Staff (員工模型) - `staff.go`
- 對應前端：`frontend/lib/models/staff.dart`
- 描述：員工資料和權限管理
- 關鍵字段：
  - `role`: 職位 (owner/manager/senior_stylist/stylist/assistant/receptionist)
  - `branch_ids`: 可服務的門店列表 (JSON array)
  - `service_ids`: 可提供的服務列表 (JSON array)
  - `hire_date`: 僱用日期
- 特殊類型：
  - `StringArray`: 自訂類型處理 JSON 數組

#### 5. Customer (客戶模型) - `customer.go`
- 對應前端：`frontend/lib/models/customer.dart`
- 描述：客戶資料管理
- 關鍵字段：
  - `is_special_customer`: 是否為特殊客戶
  - `needs_merge`: 是否需要合併
  - `is_archived`: 是否已歸檔

#### 6. Service (服務模型) - `service.go`
- 對應前端：`frontend/lib/models/service.dart`
- 描述：美容服務項目
- 關鍵字段：
  - `category`: 服務分類 (lash/pmu/nail/hair/skin/other)
  - `duration`: 服務時長 (分鐘)
  - `revisit_period`: 回訪週期 (天)
  - `price/profit`: 價格和利潤

### 預約管理模型

#### 7. Appointment (預約模型) - `appointment.go`
- 對應前端：`frontend/lib/models/appointment.dart`
- 描述：客戶預約管理
- 關鍵字段：
  - `status`: 預約狀態 (booked/confirmed/checked_in/completed/cancelled/no_show)
  - `start_time/end_time`: 預約時間
  - `staff_id`: 指定員工 (可選)
- 關聯：關聯到客戶、服務、門店、員工

#### 8. BranchService (門店服務模型) - `branch_service.go`
- 對應前端：`frontend/lib/models/branch_service.dart`
- 描述：門店與服務的多對多關聯
- 關鍵字段：
  - `custom_price/custom_profit`: 門店特定價格/利潤
  - `is_available`: 服務是否可用

### 業務目標模型

#### 9. BusinessGoal (業務目標模型) - `business_goal.go`
- 對應前端：`frontend/lib/models/business_goal.dart`
- 描述：三層級業務目標管理
- 關鍵字段：
  - `level`: 目標層級 (business/branch/staff)
  - `type`: 目標類型 (revenue/customer/profit/custom)
  - `current_value/target_value`: 當前值/目標值
  - `branch_id/staff_id`: 關聯的門店/員工 (可選)

### 訂閱和計費模型

#### 10. SubscriptionPlan (訂閱方案模型) - `subscription.go`
- 對應前端：`frontend/lib/models/subscription_plan.dart`
- 描述：預定義的訂閱方案
- 關鍵字段：
  - `type`: 方案類型 (basic/business)
  - `price_per_staff_per_month`: 每員工每月價格
  - `max_branches`: 最大門店數 (-1為無限制)
  - `features`: 功能列表 (JSON array)

#### 11. Subscription (訂閱模型) - `subscription.go`
- 對應前端：`frontend/lib/models/subscription.dart`
- 描述：商家的訂閱狀態
- 關鍵字段：
  - `status`: 訂閱狀態 (active/expired/cancelled/trial)
  - `staff_count`: 員工數量
  - `auto_renewal`: 自動續約
  - `monthly_amount`: 月費金額

#### 12. Billing (帳單模型) - `billing.go`
- 對應前端：`frontend/lib/models/billing.dart`
- 描述：訂閱費用帳單
- 關鍵字段：
  - `status`: 帳單狀態 (pending/paid/overdue/cancelled/refunded)
  - `payment_method`: 付款方式 (creditCard/bankTransfer/cash/other)
  - `due_date/paid_date`: 到期日/付款日
  - `amount/tax_amount/total_amount`: 金額明細

### 分析報表模型

#### 13. Analytics (分析模型) - `analytics.go`
- 對應前端：`frontend/lib/models/staff_performance_analysis.dart` 等
- 描述：各種業務分析數據
- 包含模型：
  - `StaffPerformanceAnalysis`: 員工績效分析
  - `BranchPerformance`: 門店績效
  - `BusinessAnalytics`: 整體業務分析
  - `DashboardData`: 儀表板數據
  - `RevenueAnalysis`: 營收分析

## 資料庫關聯關係

```
User ──→ Business (多對一)
Business ──→ Branch (一對多)
Business ──→ Staff (一對多)
Business ──→ Customer (一對多)
Business ──→ Service (一對多)
Business ──→ Appointment (一對多)
Business ──→ Subscription (一對一)
Business ──→ BusinessGoal (一對多)

Branch ──→ Appointment (一對多)
Branch ──→ BranchService (一對多)
Service ──→ BranchService (一對多)

Staff ──→ Appointment (一對多，可選)
Customer ──→ Appointment (一對多)
Service ──→ Appointment (一對多)

Subscription ──→ SubscriptionPlan (多對一)
Subscription ──→ Billing (一對多)
```

## JSON 字段對應

所有模型的 JSON 標籤都與前端保持一致：

- **蛇形命名**: 資料庫字段使用 `snake_case` (如 `business_id`)
- **駝峰命名**: 某些API響應字段使用 `camelCase` (如 `businessId`)
- **時間格式**: 統一使用 ISO 8601 格式
- **可選字段**: 使用指標類型 `*string`, `*time.Time` 等

## 特殊處理

### StringArray 類型
- 用於存儲字符串數組到 JSON 字段
- 實現了 `driver.Valuer` 和 `sql.Scanner` 接口
- 用於 `staff.branch_ids`, `staff.service_ids`, `subscription_plan.features` 等

### UUID 生成
- 所有主鍵都使用 UUID
- 在 `BeforeCreate` hook 中自動生成
- 實現在 `utils.go` 中

### 軟刪除
- 所有模型都支持軟刪除 (`deleted_at` 字段)
- 使用 GORM 的 `DeletedAt` 類型

## 驗證規則

使用 Gin 的 binding 標籤進行輸入驗證：
- `required`: 必填字段
- `email`: 郵箱格式驗證
- `min/max`: 長度或數值範圍
- `omitempty`: 更新時可省略

## 使用範例

```go
// 創建用戶
user := &User{
    Email:        "user@example.com",
    Name:         "張三",
    BusinessName: "美麗髮廊",
    Role:         UserRoleOwner,
}
user.SetPassword("password123")

// 創建預約
appointment, err := request.ToModel()
if err != nil {
    return err
}

// 查詢關聯數據
db.Preload("Customer").Preload("Service").Find(&appointments)
```

## 遷移說明

所有模型都可以通過 GORM 自動遷移：

```go
db.AutoMigrate(
    &User{}, &Business{}, &Branch{}, &Staff{}, 
    &Customer{}, &Service{}, &Appointment{},
    &BusinessGoal{}, &SubscriptionPlan{}, 
    &Subscription{}, &Billing{}, &BranchService{},
)
```

注意：生產環境建議使用手動遷移文件。 