# BeautyAI 美容管理系統 - Go API 後端開發文件

## 專案概述

本文件詳細說明如何使用 Go 語言開發一個完整的 RESTful API 後端服務，以支持 BeautyAI 美容管理系統前端應用的所有功能需求。

### 系統功能範圍

- **用戶認證管理**：註冊、登入、JWT 認證
- **商家管理**：商家資料、門店管理、營業設定
- **員工管理**：員工資料、角色權限、排班管理
- **服務管理**：服務項目、價格策略、門店服務配置
- **客戶管理**：客戶資料、服務歷史記錄
- **預約管理**：預約排程、狀態管理、衝突檢查
- **業務分析**：營收報表、客戶分析、員工績效
- **AI 助理**：智能推薦、數據查詢
- **方案管理與帳單系統**：Basic 和 Business 兩種方案、方案設計、數據模型擴展、API 端點設計、核心實現代碼、數據庫設計、Docker 部署、API 測試、性能優化建議、安全性考慮、總結

## 技術架構

### 技術棧
- **後端框架**: Gin (Go Web Framework)
- **數據庫**: PostgreSQL
- **ORM**: GORM
- **認證**: JWT (golang-jwt)
- **配置管理**: Viper
- **日誌**: Logrus
- **API 文檔**: Swagger
- **緩存**: Redis
- **部署**: Docker + Docker Compose

### 專案結構

```
beauty-ai-backend/
├── cmd/
│   └── api/
│       └── main.go
├── internal/
│   ├── api/
│   │   ├── handlers/
│   │   │   ├── auth.go
│   │   │   ├── business.go
│   │   │   ├── branch.go
│   │   │   ├── staff.go
│   │   │   ├── service.go
│   │   │   ├── customer.go
│   │   │   ├── appointment.go
│   │   │   ├── analysis.go
│   │   │   └── schedule.go
│   │   ├── middleware/
│   │   │   ├── auth.go
│   │   │   ├── cors.go
│   │   │   └── logging.go
│   │   └── routes/
│   │       └── routes.go
│   ├── domain/
│   │   ├── entities/
│   │   │   ├── user.go
│   │   │   ├── business.go
│   │   │   ├── branch.go
│   │   │   ├── staff.go
│   │   │   ├── service.go
│   │   │   ├── customer.go
│   │   │   ├── appointment.go
│   │   │   ├── analysis.go
│   │   │   └── schedule.go
│   │   └── repositories/
│   │       ├── user_repository.go
│   │       ├── business_repository.go
│   │       ├── branch_repository.go
│   │       ├── staff_repository.go
│   │       ├── service_repository.go
│   │       ├── customer_repository.go
│   │       ├── appointment_repository.go
│   │       ├── analysis_repository.go
│   │       └── schedule_repository.go
│   ├── services/
│   │   ├── auth_service.go
│   │   ├── business_service.go
│   │   ├── branch_service.go
│   │   ├── staff_service.go
│   │   ├── service_service.go
│   │   ├── customer_service.go
│   │   ├── appointment_service.go
│   │   ├── analysis_service.go
│   │   └── schedule_service.go
│   ├── infrastructure/
│   │   ├── database/
│   │   │   ├── postgres.go
│   │   │   └── migrations/
│   │   ├── cache/
│   │   │   └── redis.go
│   │   └── config/
│   │       └── config.go
│   └── utils/
│       ├── jwt.go
│       ├── validator.go
│       └── response.go
├── migrations/
├── docs/
├── docker-compose.yml
├── Dockerfile
├── go.mod
├── go.sum
└── README.md
```

## 數據模型設計

### 核心實體關係

```go
// User 用戶表
type User struct {
    ID        uint      `json:"id" gorm:"primaryKey"`
    Name      string    `json:"name" gorm:"not null"`
    Email     string    `json:"email" gorm:"uniqueIndex;not null"`
    Password  string    `json:"-" gorm:"not null"`
    Role      string    `json:"role" gorm:"default:'admin'"`
    CreatedAt time.Time `json:"created_at"`
    UpdatedAt time.Time `json:"updated_at"`
}

// Business 商家表
type Business struct {
    ID           uint                `json:"id" gorm:"primaryKey"`
    UserID       uint                `json:"user_id" gorm:"not null"`
    Name         string              `json:"name" gorm:"not null"`
    Description  string              `json:"description"`
    Address      string              `json:"address"`
    Phone        string              `json:"phone"`
    Email        string              `json:"email"`
    LogoURL      *string             `json:"logo_url"`
    SocialLinks  *string             `json:"social_links"`
    TaxID        *string             `json:"tax_id"`
    GoogleID     *string             `json:"google_id"`
    Timezone     string              `json:"timezone" gorm:"default:'Asia/Taipei'"`
    LastLoginAt  *time.Time          `json:"last_login_at"`
    CreatedAt    time.Time           `json:"created_at"`
    UpdatedAt    time.Time           `json:"updated_at"`
    
    // 關聯
    User         User                `json:"user" gorm:"foreignKey:UserID"`
    Branches     []Branch            `json:"branches" gorm:"foreignKey:BusinessID"`
    Services     []Service           `json:"services" gorm:"foreignKey:BusinessID"`
    Staff        []Staff             `json:"staff" gorm:"foreignKey:BusinessID"`
    Customers    []Customer          `json:"customers" gorm:"foreignKey:BusinessID"`
    Appointments []Appointment       `json:"appointments" gorm:"foreignKey:BusinessID"`
}

// Branch 門店表
type Branch struct {
    ID                  uint                `json:"id" gorm:"primaryKey"`
    BusinessID          uint                `json:"business_id" gorm:"not null"`
    Name                string              `json:"name" gorm:"not null"`
    ContactPhone        *string             `json:"contact_phone"`
    Address             *string             `json:"address"`
    IsDefault           bool                `json:"is_default" gorm:"default:false"`
    Status              string              `json:"status" gorm:"default:'active'"`
    OperatingHoursStart *string             `json:"operating_hours_start"`
    OperatingHoursEnd   *string             `json:"operating_hours_end"`
    CreatedAt           time.Time           `json:"created_at"`
    UpdatedAt           time.Time           `json:"updated_at"`
    
    // 關聯
    Business            Business            `json:"business" gorm:"foreignKey:BusinessID"`
    BranchServices      []BranchService     `json:"branch_services" gorm:"foreignKey:BranchID"`
    SpecialDays         []BranchSpecialDay  `json:"special_days" gorm:"foreignKey:BranchID"`
    Appointments        []Appointment       `json:"appointments" gorm:"foreignKey:BranchID"`
    StaffSchedules      []StaffSchedule     `json:"staff_schedules" gorm:"foreignKey:BranchID"`
}

// Staff 員工表
type Staff struct {
    ID               uint             `json:"id" gorm:"primaryKey"`
    BusinessID       uint             `json:"business_id" gorm:"not null"`
    Name             string           `json:"name" gorm:"not null"`
    Email            *string          `json:"email"`
    Phone            *string          `json:"phone"`
    Role             string           `json:"role" gorm:"not null"`
    Status           string           `json:"status" gorm:"default:'active'"`
    AvatarURL        *string          `json:"avatar_url"`
    BirthDate        *time.Time       `json:"birth_date"`
    HireDate         time.Time        `json:"hire_date" gorm:"not null"`
    Address          *string          `json:"address"`
    EmergencyContact *string          `json:"emergency_contact"`
    EmergencyPhone   *string          `json:"emergency_phone"`
    Notes            *string          `json:"notes"`
    CreatedAt        time.Time        `json:"created_at"`
    UpdatedAt        time.Time        `json:"updated_at"`
    
    // 多對多關聯
    Branches         []Branch         `json:"branches" gorm:"many2many:staff_branches"`
    Services         []Service        `json:"services" gorm:"many2many:staff_services"`
    
    // 一對多關聯
    Appointments     []Appointment    `json:"appointments" gorm:"foreignKey:StaffID"`
    Schedules        []StaffSchedule  `json:"schedules" gorm:"foreignKey:StaffID"`
}
```

## API 端點設計

### 認證相關 API

```
POST   /api/v1/auth/register      # 用戶註冊
POST   /api/v1/auth/login         # 用戶登入
POST   /api/v1/auth/logout        # 用戶登出
POST   /api/v1/auth/refresh       # 刷新 Token
GET    /api/v1/auth/me            # 獲取當前用戶資訊
```

### 商家管理 API

```
GET    /api/v1/businesses         # 獲取商家列表
POST   /api/v1/businesses         # 創建商家
GET    /api/v1/businesses/:id     # 獲取商家詳情
PUT    /api/v1/businesses/:id     # 更新商家
DELETE /api/v1/businesses/:id     # 刪除商家
POST   /api/v1/businesses/:id/restore  # 恢復商家
```

### 門店管理 API

```
GET    /api/v1/businesses/:businessId/branches        # 獲取門店列表
POST   /api/v1/businesses/:businessId/branches        # 創建門店
GET    /api/v1/branches/:id                           # 獲取門店詳情
PUT    /api/v1/branches/:id                           # 更新門店
DELETE /api/v1/branches/:id                           # 刪除門店

# 門店特殊營業日
GET    /api/v1/branches/:branchId/special-days        # 獲取特殊營業日
POST   /api/v1/branches/:branchId/special-days        # 創建特殊營業日
PUT    /api/v1/special-days/:id                       # 更新特殊營業日
DELETE /api/v1/special-days/:id                       # 刪除特殊營業日
```

### 服務管理 API

```
GET    /api/v1/services                               # 獲取服務列表
POST   /api/v1/services                               # 創建服務
GET    /api/v1/services/:id                           # 獲取服務詳情
PUT    /api/v1/services/:id                           # 更新服務
DELETE /api/v1/services/:id                           # 刪除服務

# 門店服務關聯
GET    /api/v1/branches/:branchId/services            # 獲取門店服務
POST   /api/v1/branches/:branchId/services            # 為門店添加服務
PUT    /api/v1/branch-services/:id                    # 更新門店服務
DELETE /api/v1/branch-services/:id                    # 刪除門店服務
```

### 員工管理 API

```
GET    /api/v1/businesses/:businessId/staff           # 獲取員工列表
POST   /api/v1/businesses/:businessId/staff           # 創建員工
GET    /api/v1/staff/:id                              # 獲取員工詳情
PUT    /api/v1/staff/:id                              # 更新員工
DELETE /api/v1/staff/:id                              # 刪除員工

# 員工排班
GET    /api/v1/staff/:staffId/schedules               # 獲取員工排班
POST   /api/v1/staff/:staffId/schedules               # 創建排班
PUT    /api/v1/schedules/:id                          # 更新排班
DELETE /api/v1/schedules/:id                          # 刪除排班
```

### 客戶管理 API

```
GET    /api/v1/customers                              # 獲取客戶列表
POST   /api/v1/customers                              # 創建客戶
GET    /api/v1/customers/:id                          # 獲取客戶詳情
PUT    /api/v1/customers/:id                          # 更新客戶
DELETE /api/v1/customers/:id                          # 刪除客戶

# 客戶服務歷史
GET    /api/v1/customers/:customerId/service-history # 獲取服務歷史
POST   /api/v1/customers/:customerId/service-history # 創建服務歷史
```

### 預約管理 API

```
GET    /api/v1/appointments                           # 獲取預約列表
POST   /api/v1/appointments                           # 創建預約
GET    /api/v1/appointments/:id                       # 獲取預約詳情
PUT    /api/v1/appointments/:id                       # 更新預約
DELETE /api/v1/appointments/:id                       # 刪除預約

# 預約查詢
GET    /api/v1/appointments/by-date-range             # 按日期範圍查詢
GET    /api/v1/appointments/by-customer/:customerId   # 按客戶查詢
GET    /api/v1/appointments/by-staff/:staffId         # 按員工查詢
GET    /api/v1/appointments/by-branch/:branchId       # 按門店查詢
```

### 業務分析 API

```
GET    /api/v1/businesses/:businessId/analyses        # 獲取分析報告
POST   /api/v1/businesses/:businessId/analyses        # 創建分析報告
GET    /api/v1/analyses/:id                           # 獲取分析詳情
PUT    /api/v1/analyses/:id                           # 更新分析
DELETE /api/v1/analyses/:id                           # 刪除分析

# 業務目標
GET    /api/v1/businesses/:businessId/goals           # 獲取業務目標
POST   /api/v1/businesses/:businessId/goals           # 創建業務目標
PUT    /api/v1/goals/:id                              # 更新業務目標
DELETE /api/v1/goals/:id                              # 刪除業務目標
```

### 方案管理與帳單系統

#### 方案設計

系統提供兩種訂閱方案：

#### Basic 方案
- **限制**：只能建立 1 個門店
- **定價**：每位員工月費 300 元台幣
- **適用對象**：個人工作室、小型美容院

#### Business 方案  
- **限制**：可建立多個門店（無限制）
- **定價**：每位員工月費 450 元台幣
- **適用對象**：連鎖美容院、大型美容集團

#### 數據模型擴展

#### 方案表 (Plans)

```go
type Plan struct {
    ID               uint    `json:"id" gorm:"primaryKey"`
    Name             string  `json:"name" gorm:"not null"` // "Basic", "Business"
    DisplayName      string  `json:"display_name" gorm:"not null"` // "基礎方案", "商業方案"
    Description      string  `json:"description"`
    PricePerStaff    int     `json:"price_per_staff" gorm:"not null"` // 每員工月費（分為單位）
    MaxBranches      *int    `json:"max_branches"` // null 表示無限制
    Features         string  `json:"features" gorm:"type:text"` // JSON 格式的功能列表
    IsActive         bool    `json:"is_active" gorm:"default:true"`
    CreatedAt        time.Time `json:"created_at"`
    UpdatedAt        time.Time `json:"updated_at"`
}
```

#### 訂閱表 (Subscriptions)

```go
type Subscription struct {
    ID              uint       `json:"id" gorm:"primaryKey"`
    BusinessID      uint       `json:"business_id" gorm:"not null"`
    PlanID          uint       `json:"plan_id" gorm:"not null"`
    Status          string     `json:"status" gorm:"default:'active'"` // active, cancelled, suspended, expired
    StartDate       time.Time  `json:"start_date" gorm:"not null"`
    EndDate         *time.Time `json:"end_date"`
    NextBillingDate time.Time  `json:"next_billing_date" gorm:"not null"`
    BillingCycle    string     `json:"billing_cycle" gorm:"default:'monthly'"` // monthly, yearly
    CreatedAt       time.Time  `json:"created_at"`
    UpdatedAt       time.Time  `json:"updated_at"`
    
    // 關聯
    Business        Business   `json:"business" gorm:"foreignKey:BusinessID"`
    Plan            Plan       `json:"plan" gorm:"foreignKey:PlanID"`
    Invoices        []Invoice  `json:"invoices" gorm:"foreignKey:SubscriptionID"`
}
```

#### 帳單表 (Invoices)

```go
type Invoice struct {
    ID             uint           `json:"id" gorm:"primaryKey"`
    BusinessID     uint           `json:"business_id" gorm:"not null"`
    SubscriptionID uint           `json:"subscription_id" gorm:"not null"`
    InvoiceNumber  string         `json:"invoice_number" gorm:"uniqueIndex;not null"`
    Status         string         `json:"status" gorm:"default:'pending'"` // pending, paid, overdue, cancelled
    IssueDate      time.Time      `json:"issue_date" gorm:"not null"`
    DueDate        time.Time      `json:"due_date" gorm:"not null"`
    PaidAt         *time.Time     `json:"paid_at"`
    BillingPeriodStart time.Time  `json:"billing_period_start" gorm:"not null"`
    BillingPeriodEnd   time.Time  `json:"billing_period_end" gorm:"not null"`
    SubtotalAmount int            `json:"subtotal_amount" gorm:"not null"` // 分為單位
    TaxAmount      int            `json:"tax_amount" gorm:"default:0"`
    TotalAmount    int            `json:"total_amount" gorm:"not null"`
    Currency       string         `json:"currency" gorm:"default:'TWD'"`
    Notes          *string        `json:"notes"`
    CreatedAt      time.Time      `json:"created_at"`
    UpdatedAt      time.Time      `json:"updated_at"`
    
    // 關聯
    Business       Business       `json:"business" gorm:"foreignKey:BusinessID"`
    Subscription   Subscription   `json:"subscription" gorm:"foreignKey:SubscriptionID"`
    InvoiceItems   []InvoiceItem  `json:"invoice_items" gorm:"foreignKey:InvoiceID"`
}
```

#### 帳單明細表 (Invoice Items)

```go
type InvoiceItem struct {
    ID          uint    `json:"id" gorm:"primaryKey"`
    InvoiceID   uint    `json:"invoice_id" gorm:"not null"`
    Description string  `json:"description" gorm:"not null"`
    Quantity    int     `json:"quantity" gorm:"not null"`
    UnitPrice   int     `json:"unit_price" gorm:"not null"` // 分為單位
    TotalPrice  int     `json:"total_price" gorm:"not null"` // 分為單位
    CreatedAt   time.Time `json:"created_at"`
    
    // 關聯
    Invoice     Invoice `json:"invoice" gorm:"foreignKey:InvoiceID"`
}
```

#### API 端點設計

#### 方案管理 API

```
GET    /api/v1/plans                              # 獲取所有可用方案
GET    /api/v1/plans/:id                          # 獲取方案詳情
POST   /api/v1/plans                              # 創建方案（管理員）
PUT    /api/v1/plans/:id                          # 更新方案（管理員）
DELETE /api/v1/plans/:id                          # 刪除方案（管理員）
```

#### 訂閱管理 API

```
GET    /api/v1/businesses/:businessId/subscription # 獲取商家訂閱資訊
POST   /api/v1/businesses/:businessId/subscription # 創建/更新訂閱
PUT    /api/v1/subscriptions/:id/cancel           # 取消訂閱
PUT    /api/v1/subscriptions/:id/renew            # 續訂
GET    /api/v1/subscriptions/:id/usage            # 獲取使用量統計
```

#### 帳單管理 API

```
GET    /api/v1/businesses/:businessId/invoices    # 獲取商家帳單列表
GET    /api/v1/invoices/:id                       # 獲取帳單詳情
POST   /api/v1/invoices/:id/pay                   # 標記帳單為已付款
GET    /api/v1/invoices/:id/download              # 下載帳單 PDF
POST   /api/v1/invoices/generate                  # 手動生成帳單（管理員）
```

#### 方案限制檢查 API

```
GET    /api/v1/businesses/:businessId/plan-limits # 檢查方案限制狀態
POST   /api/v1/businesses/:businessId/validate-action # 驗證操作是否允許
```

### 核心實現代碼

#### 方案服務 (internal/services/plan_service.go)

```go
package services

import (
    "errors"
    "beauty-ai-backend/internal/domain/entities"
    "beauty-ai-backend/internal/domain/repositories"
)

type PlanService struct {
    planRepo         repositories.PlanRepository
    subscriptionRepo repositories.SubscriptionRepository
    businessRepo     repositories.BusinessRepository
}

func NewPlanService(
    planRepo repositories.PlanRepository,
    subscriptionRepo repositories.SubscriptionRepository,
    businessRepo repositories.BusinessRepository,
) *PlanService {
    return &PlanService{
        planRepo:         planRepo,
        subscriptionRepo: subscriptionRepo,
        businessRepo:     businessRepo,
    }
}

func (s *PlanService) GetAllPlans() ([]entities.Plan, error) {
    return s.planRepo.FindAll()
}

func (s *PlanService) GetPlanByID(id uint) (*entities.Plan, error) {
    return s.planRepo.FindByID(id)
}

func (s *PlanService) CreatePlan(plan *entities.Plan) (*entities.Plan, error) {
    return s.planRepo.Create(plan)
}

func (s *PlanService) CheckPlanLimits(businessID uint, action string, additionalCount int) (*PlanLimitStatus, error) {
    subscription, err := s.subscriptionRepo.FindActiveByBusinessID(businessID)
    if err != nil {
        return nil, err
    }
    
    if subscription == nil {
        return &PlanLimitStatus{
            Allowed: false,
            Reason:  "No active subscription found",
        }, nil
    }
    
    plan, err := s.planRepo.FindByID(subscription.PlanID)
    if err != nil {
        return nil, err
    }
    
    switch action {
    case "create_branch":
        return s.checkBranchLimit(businessID, plan, additionalCount)
    case "create_staff":
        return s.checkStaffLimit(businessID, plan, additionalCount)
    default:
        return &PlanLimitStatus{Allowed: true}, nil
    }
}

func (s *PlanService) checkBranchLimit(businessID uint, plan *entities.Plan, additionalCount int) (*PlanLimitStatus, error) {
    if plan.MaxBranches == nil {
        return &PlanLimitStatus{Allowed: true}, nil
    }
    
    currentCount, err := s.businessRepo.CountBranches(businessID)
    if err != nil {
        return nil, err
    }
    
    if currentCount+additionalCount > *plan.MaxBranches {
        return &PlanLimitStatus{
            Allowed: false,
            Reason:  fmt.Sprintf("Branch limit exceeded. Current plan allows %d branches", *plan.MaxBranches),
            Current: currentCount,
            Limit:   plan.MaxBranches,
        }, nil
    }
    
    return &PlanLimitStatus{
        Allowed: true,
        Current: currentCount,
        Limit:   plan.MaxBranches,
    }, nil
}

type PlanLimitStatus struct {
    Allowed bool   `json:"allowed"`
    Reason  string `json:"reason,omitempty"`
    Current int    `json:"current,omitempty"`
    Limit   *int   `json:"limit,omitempty"`
}
```

#### 訂閱服務 (internal/services/subscription_service.go)

```go
package services

import (
    "fmt"
    "time"
    "beauty-ai-backend/internal/domain/entities"
    "beauty-ai-backend/internal/domain/repositories"
)

type SubscriptionService struct {
    subscriptionRepo repositories.SubscriptionRepository
    planRepo         repositories.PlanRepository
    businessRepo     repositories.BusinessRepository
    invoiceService   *InvoiceService
}

func NewSubscriptionService(
    subscriptionRepo repositories.SubscriptionRepository,
    planRepo repositories.PlanRepository,
    businessRepo repositories.BusinessRepository,
    invoiceService *InvoiceService,
) *SubscriptionService {
    return &SubscriptionService{
        subscriptionRepo: subscriptionRepo,
        planRepo:         planRepo,
        businessRepo:     businessRepo,
        invoiceService:   invoiceService,
    }
}

func (s *SubscriptionService) CreateSubscription(businessID, planID uint) (*entities.Subscription, error) {
    // 檢查是否已有活躍訂閱
    existingSub, _ := s.subscriptionRepo.FindActiveByBusinessID(businessID)
    if existingSub != nil {
        return nil, errors.New("business already has an active subscription")
    }
    
    plan, err := s.planRepo.FindByID(planID)
    if err != nil {
        return nil, err
    }
    
    now := time.Now()
    nextBilling := now.AddDate(0, 1, 0) // 下個月同一天
    
    subscription := &entities.Subscription{
        BusinessID:      businessID,
        PlanID:          planID,
        Status:          "active",
        StartDate:       now,
        NextBillingDate: nextBilling,
        BillingCycle:    "monthly",
    }
    
    createdSub, err := s.subscriptionRepo.Create(subscription)
    if err != nil {
        return nil, err
    }
    
    // 生成第一張帳單
    err = s.invoiceService.GenerateInvoiceForSubscription(createdSub.ID)
    if err != nil {
        // 記錄錯誤但不回滾訂閱創建
        log.Printf("Failed to generate initial invoice for subscription %d: %v", createdSub.ID, err)
    }
    
    return createdSub, nil
}

func (s *SubscriptionService) GetBusinessSubscription(businessID uint) (*entities.Subscription, error) {
    return s.subscriptionRepo.FindActiveByBusinessID(businessID)
}

func (s *SubscriptionService) CancelSubscription(subscriptionID uint) error {
    subscription, err := s.subscriptionRepo.FindByID(subscriptionID)
    if err != nil {
        return err
    }
    
    now := time.Now()
    subscription.Status = "cancelled"
    subscription.EndDate = &now
    
    return s.subscriptionRepo.Update(subscription)
}

func (s *SubscriptionService) GetUsageStats(businessID uint) (*UsageStats, error) {
    branchCount, err := s.businessRepo.CountBranches(businessID)
    if err != nil {
        return nil, err
    }
    
    staffCount, err := s.businessRepo.CountStaff(businessID)
    if err != nil {
        return nil, err
    }
    
    customerCount, err := s.businessRepo.CountCustomers(businessID)
    if err != nil {
        return nil, err
    }
    
    appointmentCount, err := s.businessRepo.CountAppointmentsThisMonth(businessID)
    if err != nil {
        return nil, err
    }
    
    return &UsageStats{
        BranchCount:      branchCount,
        StaffCount:       staffCount,
        CustomerCount:    customerCount,
        AppointmentCount: appointmentCount,
    }, nil
}

type UsageStats struct {
    BranchCount      int `json:"branch_count"`
    StaffCount       int `json:"staff_count"`
    CustomerCount    int `json:"customer_count"`
    AppointmentCount int `json:"appointment_count"`
}
```

#### 帳單服務 (internal/services/invoice_service.go)

```go
package services

import (
    "fmt"
    "time"
    "beauty-ai-backend/internal/domain/entities"
    "beauty-ai-backend/internal/domain/repositories"
)

type InvoiceService struct {
    invoiceRepo      repositories.InvoiceRepository
    subscriptionRepo repositories.SubscriptionRepository
    businessRepo     repositories.BusinessRepository
    planRepo         repositories.PlanRepository
}

func NewInvoiceService(
    invoiceRepo repositories.InvoiceRepository,
    subscriptionRepo repositories.SubscriptionRepository,
    businessRepo repositories.BusinessRepository,
    planRepo repositories.PlanRepository,
) *InvoiceService {
    return &InvoiceService{
        invoiceRepo:      invoiceRepo,
        subscriptionRepo: subscriptionRepo,
        businessRepo:     businessRepo,
        planRepo:         planRepo,
    }
}

func (s *InvoiceService) GenerateInvoiceForSubscription(subscriptionID uint) error {
    subscription, err := s.subscriptionRepo.FindByID(subscriptionID)
    if err != nil {
        return err
    }
    
    plan, err := s.planRepo.FindByID(subscription.PlanID)
    if err != nil {
        return err
    }
    
    // 計算帳單期間
    billingStart := time.Now()
    billingEnd := billingStart.AddDate(0, 1, 0).Add(-time.Second)
    
    // 獲取員工數量
    staffCount, err := s.businessRepo.CountActiveStaff(subscription.BusinessID)
    if err != nil {
        return err
    }
    
    // 計算費用
    unitPrice := plan.PricePerStaff
    subtotal := staffCount * unitPrice
    tax := int(float64(subtotal) * 0.05) // 5% 稅率
    total := subtotal + tax
    
    // 生成帳單編號
    invoiceNumber := s.generateInvoiceNumber()
    
    // 創建帳單
    invoice := &entities.Invoice{
        BusinessID:         subscription.BusinessID,
        SubscriptionID:     subscriptionID,
        InvoiceNumber:      invoiceNumber,
        Status:             "pending",
        IssueDate:          billingStart,
        DueDate:            billingStart.AddDate(0, 0, 7), // 7天付款期限
        BillingPeriodStart: billingStart,
        BillingPeriodEnd:   billingEnd,
        SubtotalAmount:     subtotal,
        TaxAmount:          tax,
        TotalAmount:        total,
        Currency:           "TWD",
    }
    
    createdInvoice, err := s.invoiceRepo.Create(invoice)
    if err != nil {
        return err
    }
    
    // 創建帳單明細
    invoiceItem := &entities.InvoiceItem{
        InvoiceID:   createdInvoice.ID,
        Description: fmt.Sprintf("%s - %d 位員工", plan.DisplayName, staffCount),
        Quantity:    staffCount,
        UnitPrice:   unitPrice,
        TotalPrice:  subtotal,
    }
    
    return s.invoiceRepo.CreateInvoiceItem(invoiceItem)
}

func (s *InvoiceService) GetBusinessInvoices(businessID uint, limit, offset int) ([]entities.Invoice, error) {
    return s.invoiceRepo.FindByBusinessID(businessID, limit, offset)
}

func (s *InvoiceService) GetInvoiceByID(id uint) (*entities.Invoice, error) {
    return s.invoiceRepo.FindByIDWithItems(id)
}

func (s *InvoiceService) MarkInvoiceAsPaid(invoiceID uint) error {
    invoice, err := s.invoiceRepo.FindByID(invoiceID)
    if err != nil {
        return err
    }
    
    now := time.Now()
    invoice.Status = "paid"
    invoice.PaidAt = &now
    
    return s.invoiceRepo.Update(invoice)
}

func (s *InvoiceService) generateInvoiceNumber() string {
    now := time.Now()
    return fmt.Sprintf("INV-%s-%d", now.Format("200601"), now.Unix())
}

// 定期任務：生成到期帳單
func (s *InvoiceService) GenerateDueInvoices() error {
    subscriptions, err := s.subscriptionRepo.FindDueForBilling()
    if err != nil {
        return err
    }
    
    for _, subscription := range subscriptions {
        err := s.GenerateInvoiceForSubscription(subscription.ID)
        if err != nil {
            log.Printf("Failed to generate invoice for subscription %d: %v", subscription.ID, err)
            continue
        }
        
        // 更新下次帳單日期
        nextBilling := subscription.NextBillingDate.AddDate(0, 1, 0)
        subscription.NextBillingDate = nextBilling
        s.subscriptionRepo.Update(&subscription)
    }
    
    return nil
}
```

#### 方案處理器 (internal/api/handlers/plan.go)

```go
package handlers

import (
    "net/http"
    "strconv"
    "beauty-ai-backend/internal/services"
    
    "github.com/gin-gonic/gin"
)

type PlanHandler struct {
    planService         *services.PlanService
    subscriptionService *services.SubscriptionService
}

func NewPlanHandler(planService *services.PlanService, subscriptionService *services.SubscriptionService) *PlanHandler {
    return &PlanHandler{
        planService:         planService,
        subscriptionService: subscriptionService,
    }
}

func (h *PlanHandler) GetPlans(c *gin.Context) {
    plans, err := h.planService.GetAllPlans()
    if err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{
            "error": "Failed to get plans",
            "details": err.Error(),
        })
        return
    }
    
    c.JSON(http.StatusOK, gin.H{
        "plans": plans,
    })
}

func (h *PlanHandler) GetPlanLimits(c *gin.Context) {
    businessID, err := strconv.ParseUint(c.Param("businessId"), 10, 32)
    if err != nil {
        c.JSON(http.StatusBadRequest, gin.H{
            "error": "Invalid business ID",
        })
        return
    }
    
    // 獲取當前使用量
    usageStats, err := h.subscriptionService.GetUsageStats(uint(businessID))
    if err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{
            "error": "Failed to get usage stats",
            "details": err.Error(),
        })
        return
    }
    
    // 檢查各項限制
    branchLimit, err := h.planService.CheckPlanLimits(uint(businessID), "create_branch", 0)
    if err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{
            "error": "Failed to check branch limits",
            "details": err.Error(),
        })
        return
    }
    
    c.JSON(http.StatusOK, gin.H{
        "usage": usageStats,
        "limits": gin.H{
            "branches": branchLimit,
        },
    })
}

func (h *PlanHandler) ValidateAction(c *gin.Context) {
    businessID, err := strconv.ParseUint(c.Param("businessId"), 10, 32)
    if err != nil {
        c.JSON(http.StatusBadRequest, gin.H{
            "error": "Invalid business ID",
        })
        return
    }
    
    var req struct {
        Action           string `json:"action" binding:"required"`
        AdditionalCount  int    `json:"additional_count"`
    }
    
    if err := c.ShouldBindJSON(&req); err != nil {
        c.JSON(http.StatusBadRequest, gin.H{
            "error": "Invalid request data",
            "details": err.Error(),
        })
        return
    }
    
    limitStatus, err := h.planService.CheckPlanLimits(uint(businessID), req.Action, req.AdditionalCount)
    if err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{
            "error": "Failed to validate action",
            "details": err.Error(),
        })
        return
    }
    
    if !limitStatus.Allowed {
        c.JSON(http.StatusForbidden, gin.H{
            "allowed": false,
            "reason": limitStatus.Reason,
            "current": limitStatus.Current,
            "limit": limitStatus.Limit,
        })
        return
    }
    
    c.JSON(http.StatusOK, gin.H{
        "allowed": true,
        "current": limitStatus.Current,
        "limit": limitStatus.Limit,
    })
}
```

### 中間件：方案限制檢查

```go
// internal/api/middleware/plan_limits.go
package middleware

import (
    "net/http"
    "strconv"
    "beauty-ai-backend/internal/services"
    
    "github.com/gin-gonic/gin"
)

func CheckPlanLimits(planService *services.PlanService, action string) gin.HandlerFunc {
    return func(c *gin.Context) {
        // 從路徑參數或請求體中獲取 businessID
        var businessID uint
        
        if businessIDParam := c.Param("businessId"); businessIDParam != "" {
            id, err := strconv.ParseUint(businessIDParam, 10, 32)
            if err != nil {
                c.JSON(http.StatusBadRequest, gin.H{
                    "error": "Invalid business ID",
                })
                c.Abort()
                return
            }
            businessID = uint(id)
        } else {
            // 從上下文中獲取用戶的商家ID
            userID, exists := c.Get("user_id")
            if !exists {
                c.JSON(http.StatusUnauthorized, gin.H{
                    "error": "User not authenticated",
                })
                c.Abort()
                return
            }
            
            // 這裡需要根據用戶ID獲取商家ID的邏輯
            // businessID = getUserBusinessID(userID.(uint))
        }
        
        limitStatus, err := planService.CheckPlanLimits(businessID, action, 1)
        if err != nil {
            c.JSON(http.StatusInternalServerError, gin.H{
                "error": "Failed to check plan limits",
                "details": err.Error(),
            })
            c.Abort()
            return
        }
        
        if !limitStatus.Allowed {
            c.JSON(http.StatusForbidden, gin.H{
                "error": "PLAN_LIMIT_EXCEEDED",
                "reason": limitStatus.Reason,
                "current": limitStatus.Current,
                "limit": limitStatus.Limit,
            })
            c.Abort()
            return
        }
        
        c.Next()
    }
}
```

### 數據庫遷移

```sql
-- 方案表
CREATE TABLE plans (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    display_name VARCHAR(100) NOT NULL,
    description TEXT,
    price_per_staff INTEGER NOT NULL, -- 分為單位
    max_branches INTEGER, -- NULL 表示無限制
    features TEXT, -- JSON 格式
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 訂閱表
CREATE TABLE subscriptions (
    id SERIAL PRIMARY KEY,
    business_id INTEGER REFERENCES businesses(id) ON DELETE CASCADE,
    plan_id INTEGER REFERENCES plans(id) ON DELETE RESTRICT,
    status VARCHAR(20) DEFAULT 'active',
    start_date TIMESTAMP NOT NULL,
    end_date TIMESTAMP,
    next_billing_date TIMESTAMP NOT NULL,
    billing_cycle VARCHAR(20) DEFAULT 'monthly',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 帳單表
CREATE TABLE invoices (
    id SERIAL PRIMARY KEY,
    business_id INTEGER REFERENCES businesses(id) ON DELETE CASCADE,
    subscription_id INTEGER REFERENCES subscriptions(id) ON DELETE CASCADE,
    invoice_number VARCHAR(50) UNIQUE NOT NULL,
    status VARCHAR(20) DEFAULT 'pending',
    issue_date TIMESTAMP NOT NULL,
    due_date TIMESTAMP NOT NULL,
    paid_at TIMESTAMP,
    billing_period_start TIMESTAMP NOT NULL,
    billing_period_end TIMESTAMP NOT NULL,
    subtotal_amount INTEGER NOT NULL,
    tax_amount INTEGER DEFAULT 0,
    total_amount INTEGER NOT NULL,
    currency VARCHAR(3) DEFAULT 'TWD',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 帳單明細表
CREATE TABLE invoice_items (
    id SERIAL PRIMARY KEY,
    invoice_id INTEGER REFERENCES invoices(id) ON DELETE CASCADE,
    description VARCHAR(255) NOT NULL,
    quantity INTEGER NOT NULL,
    unit_price INTEGER NOT NULL,
    total_price INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 插入預設方案
INSERT INTO plans (name, display_name, description, price_per_staff, max_branches, features) VALUES
('basic', '基礎方案', '適合個人工作室或小型美容院', 30000, 1, '{"max_branches":1,"support":"email","features":["appointment_management","customer_management","basic_reports"]}'),
('business', '商業方案', '適合連鎖美容院或大型美容集團', 45000, NULL, '{"max_branches":null,"support":"priority","features":["unlimited_branches","appointment_management","customer_management","advanced_reports","staff_management","business_analytics"]}');

-- 索引
CREATE INDEX idx_subscriptions_business_id ON subscriptions(business_id);
CREATE INDEX idx_subscriptions_status ON subscriptions(status);
CREATE INDEX idx_subscriptions_next_billing_date ON subscriptions(next_billing_date);
CREATE INDEX idx_invoices_business_id ON invoices(business_id);
CREATE INDEX idx_invoices_status ON invoices(status);
CREATE INDEX idx_invoices_due_date ON invoices(due_date);
```

### 路由設置更新

在現有的路由設置中添加新的端點：

```go
// internal/api/routes/routes.go 中添加
func setupPlanRoutes(r *gin.Engine, handlers *handlers.Handlers, middlewares *middleware.Middlewares) {
    planGroup := r.Group("/api/v1")
    planGroup.Use(middlewares.JWTAuth)
    
    // 方案管理
    planGroup.GET("/plans", handlers.Plan.GetPlans)
    planGroup.GET("/businesses/:businessId/plan-limits", handlers.Plan.GetPlanLimits)
    planGroup.POST("/businesses/:businessId/validate-action", handlers.Plan.ValidateAction)
    
    // 訂閱管理
    planGroup.GET("/businesses/:businessId/subscription", handlers.Subscription.GetSubscription)
    planGroup.POST("/businesses/:businessId/subscription", handlers.Subscription.CreateSubscription)
    planGroup.PUT("/subscriptions/:id/cancel", handlers.Subscription.CancelSubscription)
    planGroup.GET("/subscriptions/:id/usage", handlers.Subscription.GetUsageStats)
    
    // 帳單管理
    planGroup.GET("/businesses/:businessId/invoices", handlers.Invoice.GetInvoices)
    planGroup.GET("/invoices/:id", handlers.Invoice.GetInvoice)
    planGroup.POST("/invoices/:id/pay", handlers.Invoice.MarkAsPaid)
    planGroup.GET("/invoices/:id/download", handlers.Invoice.DownloadPDF)
}

// 在需要檢查方案限制的路由上添加中間件
func setupProtectedRoutes(r *gin.Engine, handlers *handlers.Handlers, middlewares *middleware.Middlewares) {
    protected := r.Group("/api/v1")
    protected.Use(middlewares.JWTAuth)
    
    // 門店創建需要檢查方案限制
    protected.POST("/businesses/:businessId/branches", 
        middlewares.CheckPlanLimits("create_branch"),
        handlers.Branch.CreateBranch)
    
    // 員工創建需要檢查方案限制
    protected.POST("/businesses/:businessId/staff",
        middlewares.CheckPlanLimits("create_staff"),
        handlers.Staff.CreateStaff)
}
```

### 定時任務設置

```go
// internal/tasks/billing_tasks.go
package tasks

import (
    "log"
    "time"
    "beauty-ai-backend/internal/services"
    
    "github.com/robfig/cron/v3"
)

type BillingTasks struct {
    invoiceService *services.InvoiceService
    cron          *cron.Cron
}

func NewBillingTasks(invoiceService *services.InvoiceService) *BillingTasks {
    return &BillingTasks{
        invoiceService: invoiceService,
        cron:          cron.New(),
    }
}

func (bt *BillingTasks) Start() {
    // 每天凌晨 1 點執行帳單生成
    bt.cron.AddFunc("0 1 * * *", func() {
        log.Println("Starting daily billing task...")
        err := bt.invoiceService.GenerateDueInvoices()
        if err != nil {
            log.Printf("Billing task failed: %v", err)
        } else {
            log.Println("Billing task completed successfully")
        }
    })
    
    // 每天凌晨 2 點檢查逾期帳單
    bt.cron.AddFunc("0 2 * * *", func() {
        log.Println("Starting overdue invoice check...")
        err := bt.checkOverdueInvoices()
        if err != nil {
            log.Printf("Overdue invoice check failed: %v", err)
        } else {
            log.Println("Overdue invoice check completed")
        }
    })
    
    bt.cron.Start()
    log.Println("Billing tasks started")
}

func (bt *BillingTasks) Stop() {
    bt.cron.Stop()
    log.Println("Billing tasks stopped")
}

func (bt *BillingTasks) checkOverdueInvoices() error {
    // 實現逾期帳單檢查邏輯
    // 可以發送提醒郵件、暫停服務等
    return nil
}
```

### 使用示例

```bash
# 獲取所有方案
curl -X GET http://localhost:8080/api/v1/plans \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"

# 創建訂閱
curl -X POST http://localhost:8080/api/v1/businesses/1/subscription \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "plan_id": 1
  }'

# 檢查方案限制
curl -X GET http://localhost:8080/api/v1/businesses/1/plan-limits \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"

# 驗證操作是否允許
curl -X POST http://localhost:8080/api/v1/businesses/1/validate-action \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "action": "create_branch",
    "additional_count": 1
  }'

# 獲取帳單列表
curl -X GET http://localhost:8080/api/v1/businesses/1/invoices \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

這個完整的方案管理和帳單系統提供了：

1. **彈性的方案設計**：Basic 和 Business 兩種方案，可根據需求調整
2. **自動帳單生成**：基於員工數量自動計算月費
3. **方案限制檢查**：防止超出方案限制的操作
4. **完整的帳單管理**：帳單生成、查看、付款狀態管理
5. **使用量統計**：實時監控資源使用情況
6. **定時任務**：自動化帳單生成和逾期檢查

系統具備良好的擴展性，未來可以輕鬆添加新的方案類型或調整計費邏輯。

## 快速開始

### 1. 環境要求

- Go 1.19+
- PostgreSQL 13+
- Redis 6+
- Docker & Docker Compose (可選)

### 2. 專案初始化

```bash
# 創建專案目錄
mkdir beauty-ai-backend
cd beauty-ai-backend

# 初始化 Go 模組
go mod init beauty-ai-backend

# 安裝依賴
go get github.com/gin-gonic/gin
go get gorm.io/gorm
go get gorm.io/driver/postgres
go get github.com/golang-jwt/jwt/v5
go get github.com/spf13/viper
go get github.com/sirupsen/logrus
go get github.com/go-redis/redis/v8
go get github.com/swaggo/gin-swagger
go get golang.org/x/crypto/bcrypt
```

### 3. 配置檔案

創建 `config/config.yaml`：

```yaml
server:
  host: "0.0.0.0"
  port: 8080
  mode: "debug" # debug, release

database:
  host: "localhost"
  port: 5432
  username: "beauty_ai"
  password: "password"
  dbname: "beauty_ai_db"
  sslmode: "disable"
  timezone: "Asia/Taipei"

redis:
  host: "localhost"
  port: 6379
  password: ""
  db: 0

jwt:
  secret: "your-super-secret-jwt-key"
  expire_hours: 24

cors:
  allowed_origins:
    - "http://localhost:3000"
    - "http://localhost:8080"
  allowed_methods:
    - "GET"
    - "POST"
    - "PUT"
    - "DELETE"
    - "OPTIONS"
  allowed_headers:
    - "Origin"
    - "Content-Length"
    - "Content-Type"
    - "Authorization"

logging:
  level: "info"
  format: "json"
``` 

### 4. 核心實現代碼

#### 主程序入口 (cmd/api/main.go)

```go
package main

import (
    "log"
    "beauty-ai-backend/internal/api/routes"
    "beauty-ai-backend/internal/infrastructure/config"
    "beauty-ai-backend/internal/infrastructure/database"
    "beauty-ai-backend/internal/infrastructure/cache"
    
    "github.com/gin-gonic/gin"
)

func main() {
    // 載入配置
    cfg := config.Load()
    
    // 初始化數據庫
    db := database.Init(cfg)
    
    // 初始化 Redis
    redis := cache.Init(cfg)
    
    // 設置 Gin 模式
    gin.SetMode(cfg.Server.Mode)
    
    // 初始化路由
    router := routes.Setup(db, redis, cfg)
    
    // 啟動服務器
    log.Printf("Server starting on %s:%d", cfg.Server.Host, cfg.Server.Port)
    log.Fatal(router.Run(fmt.Sprintf("%s:%d", cfg.Server.Host, cfg.Server.Port)))
}
```

#### 配置管理 (internal/infrastructure/config/config.go)

```go
package config

import (
    "github.com/spf13/viper"
    "log"
)

type Config struct {
    Server   ServerConfig   `mapstructure:"server"`
    Database DatabaseConfig `mapstructure:"database"`
    Redis    RedisConfig    `mapstructure:"redis"`
    JWT      JWTConfig      `mapstructure:"jwt"`
    CORS     CORSConfig     `mapstructure:"cors"`
    Logging  LoggingConfig  `mapstructure:"logging"`
}

type ServerConfig struct {
    Host string `mapstructure:"host"`
    Port int    `mapstructure:"port"`
    Mode string `mapstructure:"mode"`
}

type DatabaseConfig struct {
    Host     string `mapstructure:"host"`
    Port     int    `mapstructure:"port"`
    Username string `mapstructure:"username"`
    Password string `mapstructure:"password"`
    DBName   string `mapstructure:"dbname"`
    SSLMode  string `mapstructure:"sslmode"`
    Timezone string `mapstructure:"timezone"`
}

type RedisConfig struct {
    Host     string `mapstructure:"host"`
    Port     int    `mapstructure:"port"`
    Password string `mapstructure:"password"`
    DB       int    `mapstructure:"db"`
}

type JWTConfig struct {
    Secret      string `mapstructure:"secret"`
    ExpireHours int    `mapstructure:"expire_hours"`
}

type CORSConfig struct {
    AllowedOrigins []string `mapstructure:"allowed_origins"`
    AllowedMethods []string `mapstructure:"allowed_methods"`
    AllowedHeaders []string `mapstructure:"allowed_headers"`
}

type LoggingConfig struct {
    Level  string `mapstructure:"level"`
    Format string `mapstructure:"format"`
}

func Load() *Config {
    viper.SetConfigName("config")
    viper.SetConfigType("yaml")
    viper.AddConfigPath("./config")
    viper.AddConfigPath(".")
    
    if err := viper.ReadInConfig(); err != nil {
        log.Fatalf("Error reading config file: %v", err)
    }
    
    var config Config
    if err := viper.Unmarshal(&config); err != nil {
        log.Fatalf("Error unmarshaling config: %v", err)
    }
    
    return &config
}
```

#### 數據庫連接 (internal/infrastructure/database/postgres.go)

```go
package database

import (
    "fmt"
    "log"
    "beauty-ai-backend/internal/domain/entities"
    "beauty-ai-backend/internal/infrastructure/config"
    
    "gorm.io/driver/postgres"
    "gorm.io/gorm"
    "gorm.io/gorm/logger"
)

func Init(cfg *config.Config) *gorm.DB {
    dsn := fmt.Sprintf("host=%s user=%s password=%s dbname=%s port=%d sslmode=%s TimeZone=%s",
        cfg.Database.Host,
        cfg.Database.Username,
        cfg.Database.Password,
        cfg.Database.DBName,
        cfg.Database.Port,
        cfg.Database.SSLMode,
        cfg.Database.Timezone,
    )
    
    db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{
        Logger: logger.Default.LogMode(logger.Info),
    })
    
    if err != nil {
        log.Fatalf("Failed to connect to database: %v", err)
    }
    
    // 自動遷移
    if err := AutoMigrate(db); err != nil {
        log.Fatalf("Failed to auto migrate: %v", err)
    }
    
    log.Println("Database connected successfully")
    return db
}

func AutoMigrate(db *gorm.DB) error {
    return db.AutoMigrate(
        &entities.User{},
        &entities.Business{},
        &entities.Branch{},
        &entities.BranchSpecialDay{},
        &entities.Service{},
        &entities.BranchService{},
        &entities.Staff{},
        &entities.StaffSchedule{},
        &entities.Customer{},
        &entities.Appointment{},
        &entities.ServiceHistory{},
        &entities.BusinessGoal{},
        &entities.BusinessAnalysis{},
    )
}
```

#### JWT 認證中間件 (internal/api/middleware/auth.go)

```go
package middleware

import (
    "net/http"
    "strings"
    "beauty-ai-backend/internal/utils"
    
    "github.com/gin-gonic/gin"
)

func JWTAuthMiddleware(jwtSecret string) gin.HandlerFunc {
    return func(c *gin.Context) {
        authHeader := c.GetHeader("Authorization")
        if authHeader == "" {
            c.JSON(http.StatusUnauthorized, gin.H{
                "error": "Authorization header required",
            })
            c.Abort()
            return
        }
        
        // 檢查 Bearer token 格式
        tokenParts := strings.Split(authHeader, " ")
        if len(tokenParts) != 2 || tokenParts[0] != "Bearer" {
            c.JSON(http.StatusUnauthorized, gin.H{
                "error": "Invalid authorization header format",
            })
            c.Abort()
            return
        }
        
        token := tokenParts[1]
        claims, err := utils.ValidateJWT(token, jwtSecret)
        if err != nil {
            c.JSON(http.StatusUnauthorized, gin.H{
                "error": "Invalid token",
            })
            c.Abort()
            return
        }
        
        // 將用戶信息存儲到上下文中
        c.Set("user_id", claims.UserID)
        c.Set("email", claims.Email)
        c.Set("role", claims.Role)
        
        c.Next()
    }
}

func RequireRole(requiredRole string) gin.HandlerFunc {
    return func(c *gin.Context) {
        role, exists := c.Get("role")
        if !exists {
            c.JSON(http.StatusUnauthorized, gin.H{
                "error": "User role not found in context",
            })
            c.Abort()
            return
        }
        
        if role.(string) != requiredRole && role.(string) != "admin" {
            c.JSON(http.StatusForbidden, gin.H{
                "error": "Insufficient permissions",
            })
            c.Abort()
            return
        }
        
        c.Next()
    }
}
```

#### 認證處理器 (internal/api/handlers/auth.go)

```go
package handlers

import (
    "net/http"
    "time"
    "beauty-ai-backend/internal/services"
    "beauty-ai-backend/internal/utils"
    
    "github.com/gin-gonic/gin"
    "golang.org/x/crypto/bcrypt"
)

type AuthHandler struct {
    authService *services.AuthService
    jwtSecret   string
}

func NewAuthHandler(authService *services.AuthService, jwtSecret string) *AuthHandler {
    return &AuthHandler{
        authService: authService,
        jwtSecret:   jwtSecret,
    }
}

type RegisterRequest struct {
    Name         string `json:"name" binding:"required"`
    Email        string `json:"email" binding:"required,email"`
    Password     string `json:"password" binding:"required,min=6"`
    BusinessName string `json:"business_name" binding:"required"`
}

type LoginRequest struct {
    Email    string `json:"email" binding:"required,email"`
    Password string `json:"password" binding:"required"`
}

func (h *AuthHandler) Register(c *gin.Context) {
    var req RegisterRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        c.JSON(http.StatusBadRequest, gin.H{
            "error": "Invalid request data",
            "details": err.Error(),
        })
        return
    }
    
    // 檢查電子郵件是否已存在
    if h.authService.EmailExists(req.Email) {
        c.JSON(http.StatusConflict, gin.H{
            "error": "Email already exists",
        })
        return
    }
    
    // 加密密碼
    hashedPassword, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
    if err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{
            "error": "Failed to encrypt password",
        })
        return
    }
    
    // 創建用戶和商家
    user, business, err := h.authService.CreateUserWithBusiness(&services.CreateUserRequest{
        Name:         req.Name,
        Email:        req.Email,
        Password:     string(hashedPassword),
        BusinessName: req.BusinessName,
    })
    
    if err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{
            "error": "Failed to create user",
            "details": err.Error(),
        })
        return
    }
    
    c.JSON(http.StatusCreated, gin.H{
        "message": "User registered successfully",
        "user": gin.H{
            "id":       user.ID,
            "name":     user.Name,
            "email":    user.Email,
            "role":     user.Role,
        },
        "business": gin.H{
            "id":   business.ID,
            "name": business.Name,
        },
    })
}

func (h *AuthHandler) Login(c *gin.Context) {
    var req LoginRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        c.JSON(http.StatusBadRequest, gin.H{
            "error": "Invalid request data",
            "details": err.Error(),
        })
        return
    }
    
    // 驗證用戶憑證
    user, err := h.authService.ValidateCredentials(req.Email, req.Password)
    if err != nil {
        c.JSON(http.StatusUnauthorized, gin.H{
            "error": "Invalid credentials",
        })
        return
    }
    
    // 生成 JWT token
    token, err := utils.GenerateJWT(user.ID, user.Email, user.Role, h.jwtSecret, 24*time.Hour)
    if err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{
            "error": "Failed to generate token",
        })
        return
    }
    
    // 更新最後登入時間
    h.authService.UpdateLastLogin(user.ID)
    
    c.JSON(http.StatusOK, gin.H{
        "message": "Login successful",
        "token":   token,
        "user": gin.H{
            "id":    user.ID,
            "name":  user.Name,
            "email": user.Email,
            "role":  user.Role,
        },
    })
}

func (h *AuthHandler) GetProfile(c *gin.Context) {
    userID, _ := c.Get("user_id")
    
    user, err := h.authService.GetUserByID(userID.(uint))
    if err != nil {
        c.JSON(http.StatusNotFound, gin.H{
            "error": "User not found",
        })
        return
    }
    
    c.JSON(http.StatusOK, gin.H{
        "user": gin.H{
            "id":    user.ID,
            "name":  user.Name,
            "email": user.Email,
            "role":  user.Role,
        },
    })
}

func (h *AuthHandler) Logout(c *gin.Context) {
    // 在實際應用中，您可能需要將 token 加入黑名單
    c.JSON(http.StatusOK, gin.H{
        "message": "Logout successful",
    })
}
```

#### 預約處理器 (internal/api/handlers/appointment.go)

```go
package handlers

import (
    "net/http"
    "strconv"
    "time"
    "beauty-ai-backend/internal/services"
    "beauty-ai-backend/internal/domain/entities"
    
    "github.com/gin-gonic/gin"
)

type AppointmentHandler struct {
    appointmentService *services.AppointmentService
}

func NewAppointmentHandler(appointmentService *services.AppointmentService) *AppointmentHandler {
    return &AppointmentHandler{
        appointmentService: appointmentService,
    }
}

type CreateAppointmentRequest struct {
    BusinessID  uint      `json:"business_id" binding:"required"`
    BranchID    uint      `json:"branch_id" binding:"required"`
    CustomerID  uint      `json:"customer_id" binding:"required"`
    ServiceID   uint      `json:"service_id" binding:"required"`
    StaffID     *uint     `json:"staff_id"`
    StartTime   time.Time `json:"start_time" binding:"required"`
    EndTime     time.Time `json:"end_time" binding:"required"`
    Note        *string   `json:"note"`
}

func (h *AppointmentHandler) CreateAppointment(c *gin.Context) {
    var req CreateAppointmentRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        c.JSON(http.StatusBadRequest, gin.H{
            "error": "Invalid request data",
            "details": err.Error(),
        })
        return
    }
    
    // 檢查時間衝突
    if req.StaffID != nil {
        hasConflict, err := h.appointmentService.CheckScheduleConflict(*req.StaffID, req.StartTime, req.EndTime)
        if err != nil {
            c.JSON(http.StatusInternalServerError, gin.H{
                "error": "Failed to check schedule conflict",
            })
            return
        }
        
        if hasConflict {
            c.JSON(http.StatusConflict, gin.H{
                "error": "SCHEDULE_CONFLICT: The selected time slot conflicts with existing appointments",
            })
            return
        }
    }
    
    appointment := &entities.Appointment{
        BusinessID: req.BusinessID,
        BranchID:   req.BranchID,
        CustomerID: req.CustomerID,
        ServiceID:  req.ServiceID,
        StaffID:    req.StaffID,
        StartTime:  req.StartTime,
        EndTime:    req.EndTime,
        Status:     "booked",
        Note:       req.Note,
    }
    
    createdAppointment, err := h.appointmentService.CreateAppointment(appointment)
    if err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{
            "error": "Failed to create appointment",
            "details": err.Error(),
        })
        return
    }
    
    c.JSON(http.StatusCreated, gin.H{
        "message": "Appointment created successfully",
        "appointment": createdAppointment,
    })
}

func (h *AppointmentHandler) GetAppointments(c *gin.Context) {
    // 從查詢參數獲取過濾條件
    businessID := c.Query("business_id")
    branchID := c.Query("branch_id")
    customerID := c.Query("customer_id")
    staffID := c.Query("staff_id")
    status := c.Query("status")
    startDate := c.Query("start_date")
    endDate := c.Query("end_date")
    
    filters := make(map[string]interface{})
    
    if businessID != "" {
        if id, err := strconv.ParseUint(businessID, 10, 32); err == nil {
            filters["business_id"] = uint(id)
        }
    }
    
    if branchID != "" {
        if id, err := strconv.ParseUint(branchID, 10, 32); err == nil {
            filters["branch_id"] = uint(id)
        }
    }
    
    if customerID != "" {
        if id, err := strconv.ParseUint(customerID, 10, 32); err == nil {
            filters["customer_id"] = uint(id)
        }
    }
    
    if staffID != "" {
        if id, err := strconv.ParseUint(staffID, 10, 32); err == nil {
            filters["staff_id"] = uint(id)
        }
    }
    
    if status != "" {
        filters["status"] = status
    }
    
    var startTime, endTime *time.Time
    if startDate != "" {
        if t, err := time.Parse("2006-01-02", startDate); err == nil {
            startTime = &t
        }
    }
    
    if endDate != "" {
        if t, err := time.Parse("2006-01-02", endDate); err == nil {
            // 設置為當天結束時間
            endOfDay := t.Add(23*time.Hour + 59*time.Minute + 59*time.Second)
            endTime = &endOfDay
        }
    }
    
    appointments, err := h.appointmentService.GetAppointments(filters, startTime, endTime)
    if err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{
            "error": "Failed to get appointments",
            "details": err.Error(),
        })
        return
    }
    
    c.JSON(http.StatusOK, gin.H{
        "appointments": appointments,
        "count": len(appointments),
    })
}

func (h *AppointmentHandler) UpdateAppointmentStatus(c *gin.Context) {
    id, err := strconv.ParseUint(c.Param("id"), 10, 32)
    if err != nil {
        c.JSON(http.StatusBadRequest, gin.H{
            "error": "Invalid appointment ID",
        })
        return
    }
    
    var req struct {
        Status string `json:"status" binding:"required"`
    }
    
    if err := c.ShouldBindJSON(&req); err != nil {
        c.JSON(http.StatusBadRequest, gin.H{
            "error": "Invalid request data",
            "details": err.Error(),
        })
        return
    }
    
    // 驗證狀態轉換
    appointment, err := h.appointmentService.GetAppointmentByID(uint(id))
    if err != nil {
        c.JSON(http.StatusNotFound, gin.H{
            "error": "Appointment not found",
        })
        return
    }
    
    if !h.appointmentService.IsValidStatusTransition(appointment.Status, req.Status) {
        c.JSON(http.StatusBadRequest, gin.H{
            "error": "INVALID_STATUS_TRANSITION: Invalid status transition",
        })
        return
    }
    
    updatedAppointment, err := h.appointmentService.UpdateAppointmentStatus(uint(id), req.Status)
    if err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{
            "error": "Failed to update appointment status",
            "details": err.Error(),
        })
        return
    }
    
    c.JSON(http.StatusOK, gin.H{
        "message": "Appointment status updated successfully",
        "appointment": updatedAppointment,
    })
}
```

## 數據庫設計

### PostgreSQL 數據表結構

```sql
-- 用戶表
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(50) DEFAULT 'admin',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 商家表
CREATE TABLE businesses (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    address TEXT,
    phone VARCHAR(50),
    email VARCHAR(255),
    logo_url TEXT,
    social_links TEXT,
    tax_id VARCHAR(50),
    google_id VARCHAR(255),
    timezone VARCHAR(50) DEFAULT 'Asia/Taipei',
    last_login_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 門店表
CREATE TABLE branches (
    id SERIAL PRIMARY KEY,
    business_id INTEGER REFERENCES businesses(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    contact_phone VARCHAR(50),
    address TEXT,
    is_default BOOLEAN DEFAULT FALSE,
    status VARCHAR(20) DEFAULT 'active',
    operating_hours_start TIME,
    operating_hours_end TIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 服務項目表
CREATE TABLE services (
    id SERIAL PRIMARY KEY,
    business_id INTEGER REFERENCES businesses(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    category VARCHAR(50) NOT NULL,
    duration INTEGER NOT NULL, -- 分鐘
    revisit_period INTEGER NOT NULL, -- 天
    price DECIMAL(10,2) NOT NULL,
    profit DECIMAL(10,2) NOT NULL,
    description TEXT,
    is_archived BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 員工表
CREATE TABLE staff (
    id SERIAL PRIMARY KEY,
    business_id INTEGER REFERENCES businesses(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    phone VARCHAR(50),
    role VARCHAR(50) NOT NULL,
    status VARCHAR(20) DEFAULT 'active',
    avatar_url TEXT,
    birth_date DATE,
    hire_date DATE NOT NULL,
    address TEXT,
    emergency_contact VARCHAR(255),
    emergency_phone VARCHAR(50),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 員工門店關聯表 (多對多)
CREATE TABLE staff_branches (
    staff_id INTEGER REFERENCES staff(id) ON DELETE CASCADE,
    branch_id INTEGER REFERENCES branches(id) ON DELETE CASCADE,
    PRIMARY KEY (staff_id, branch_id)
);

-- 員工服務關聯表 (多對多)
CREATE TABLE staff_services (
    staff_id INTEGER REFERENCES staff(id) ON DELETE CASCADE,
    service_id INTEGER REFERENCES services(id) ON DELETE CASCADE,
    PRIMARY KEY (staff_id, service_id)
);

-- 客戶表
CREATE TABLE customers (
    id SERIAL PRIMARY KEY,
    business_id INTEGER REFERENCES businesses(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    gender VARCHAR(10),
    phone VARCHAR(50),
    email VARCHAR(255),
    is_archived BOOLEAN DEFAULT FALSE,
    needs_merge BOOLEAN DEFAULT FALSE,
    is_special_customer BOOLEAN DEFAULT FALSE,
    source VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 預約表
CREATE TABLE appointments (
    id SERIAL PRIMARY KEY,
    business_id INTEGER REFERENCES businesses(id) ON DELETE CASCADE,
    branch_id INTEGER REFERENCES branches(id) ON DELETE CASCADE,
    customer_id INTEGER REFERENCES customers(id) ON DELETE CASCADE,
    service_id INTEGER REFERENCES services(id) ON DELETE CASCADE,
    staff_id INTEGER REFERENCES staff(id) ON DELETE SET NULL,
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL,
    status VARCHAR(20) DEFAULT 'booked',
    note TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 員工排班表
CREATE TABLE staff_schedules (
    id SERIAL PRIMARY KEY,
    staff_id INTEGER REFERENCES staff(id) ON DELETE CASCADE,
    branch_id INTEGER REFERENCES branches(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    shift_type VARCHAR(20) NOT NULL,
    start_time TIME,
    end_time TIME,
    status VARCHAR(20) DEFAULT 'scheduled',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 索引設計
CREATE INDEX idx_appointments_start_time ON appointments(start_time);
CREATE INDEX idx_appointments_business_id ON appointments(business_id);
CREATE INDEX idx_appointments_staff_id ON appointments(staff_id);
CREATE INDEX idx_appointments_customer_id ON appointments(customer_id);
CREATE INDEX idx_staff_schedules_date ON staff_schedules(date);
CREATE INDEX idx_staff_schedules_staff_id ON staff_schedules(staff_id);
```

## Docker 部署

### Dockerfile

```dockerfile
# Build stage
FROM golang:1.19-alpine AS builder

WORKDIR /app

# 安裝依賴
COPY go.mod go.sum ./
RUN go mod download

# 複製源代碼
COPY . .

# 編譯應用
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main cmd/api/main.go

# Runtime stage
FROM alpine:latest

RUN apk --no-cache add ca-certificates tzdata
WORKDIR /root/

# 從 builder stage 複製編譯好的二進制檔案
COPY --from=builder /app/main .
COPY --from=builder /app/config ./config

EXPOSE 8080

CMD ["./main"]
```

### docker-compose.yml

```yaml
version: '3.8'

services:
  # PostgreSQL 數據庫
  postgres:
    image: postgres:13-alpine
    environment:
      POSTGRES_DB: beauty_ai_db
      POSTGRES_USER: beauty_ai
      POSTGRES_PASSWORD: password
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./migrations:/docker-entrypoint-initdb.d
    networks:
      - beauty-ai-network

  # Redis 緩存
  redis:
    image: redis:6-alpine
    ports:
      - "6379:6379"
    networks:
      - beauty-ai-network

  # API 服務
  api:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "8080:8080"
    environment:
      - SERVER_HOST=0.0.0.0
      - SERVER_PORT=8080
      - DB_HOST=postgres
      - DB_PORT=5432
      - DB_USER=beauty_ai
      - DB_PASSWORD=password
      - DB_NAME=beauty_ai_db
      - REDIS_HOST=redis
      - REDIS_PORT=6379
    depends_on:
      - postgres
      - redis
    networks:
      - beauty-ai-network
    volumes:
      - ./config:/root/config

volumes:
  postgres_data:

networks:
  beauty-ai-network:
    driver: bridge
```

## API 測試

### 使用 curl 測試基本功能

```bash
# 用戶註冊
curl -X POST http://localhost:8080/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "王小姐",
    "email": "wang@beauty.com",
    "password": "123456",
    "business_name": "王小美髮廊"
  }'

# 用戶登入
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "wang@beauty.com",
    "password": "123456"
  }'

# 創建預約 (需要 Bearer Token)
curl -X POST http://localhost:8080/api/v1/appointments \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "business_id": 1,
    "branch_id": 1,
    "customer_id": 1,
    "service_id": 1,
    "staff_id": 1,
    "start_time": "2024-03-25T10:00:00Z",
    "end_time": "2024-03-25T11:30Z",
    "note": "第一次來店"
  }'

# 獲取預約列表
curl -X GET "http://localhost:8080/api/v1/appointments?business_id=1&start_date=2024-03-01&end_date=2024-03-31" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

## 性能優化建議

### 1. 數據庫優化
- 合理設計索引，特別是查詢頻繁的字段
- 使用數據庫連接池
- 實現讀寫分離
- 定期分析和優化慢查詢

### 2. 緩存策略
- 使用 Redis 緩存熱點數據
- 實現分布式緩存
- 設置合理的緩存過期時間
- 使用緩存預熱和更新策略

### 3. API 性能
- 實現分頁查詢
- 使用字段過濾減少數據傳輸
- 實現 API 限流和熔斷
- 使用 HTTP/2 和 gRPC

### 4. 監控和日誌
- 集成 Prometheus 監控
- 使用 ELK 堆棧進行日誌分析
- 實現健康檢查端點
- 設置告警機制

## 安全性考慮

### 1. 認證和授權
- JWT Token 過期機制
- Token 刷新策略
- 角色權限控制
- API 訪問頻率限制

### 2. 數據安全
- 密碼加密存儲
- 敏感數據加密
- SQL 注入防護
- XSS 攻擊防護

### 3. 網絡安全
- HTTPS 強制使用
- CORS 策略配置
- API 網關配置
- 防火牆規則設置

## 總結

這份文件提供了一個完整的 Go 語言 API 後端開發指南，涵蓋了 BeautyAI 美容管理系統的所有核心功能。通過遵循這個指南，您可以：

1. **快速搭建**：使用提供的代碼架構快速啟動專案
2. **完整功能**：實現前端應用需要的所有 API 端點
3. **可擴展性**：基於微服務架構設計，便於後續擴展
4. **生產就緒**：包含安全性、性能優化和部署方案
5. **易於維護**：清晰的代碼結構和完整的文檔

建議按照以下步驟進行開發：
1. 設置開發環境和基礎配置
2. 實現核心的認證和用戶管理功能
3. 逐步添加業務模組 (商家、門店、員工等)
4. 實現複雜的業務邏輯 (預約管理、排班系統)
5. 添加分析和報表功能
6. 進行性能優化和安全加固
7. 部署到生產環境

這個後端 API 服務將完美支持您的 Flutter 前端應用，提供穩定、高效、安全的服務支持。 