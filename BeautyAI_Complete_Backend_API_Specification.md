# BeautyAI 美容管理系統 - 完整後端 API Server 規格文件

## 📋 專案概述

本文件整合了前端需求分析，提供完整的 Go 語言 RESTful API 後端開發規格，確保 100% 支持 BeautyAI 美容管理系統前端應用的所有功能。

### 🎯 系統功能範圍

- **用戶認證管理**：註冊、登入、JWT 認證
- **商家管理**：商家資料、門店管理、營業設定
- **員工管理**：員工資料、角色權限、排班管理、多門店分配
- **服務管理**：服務項目、價格策略、門店服務配置
- **客戶管理**：客戶資料、服務歷史記錄
- **預約管理**：預約排程、狀態管理、衝突檢查
- **業務分析**：營收報表、客戶分析、員工績效、門店表現
- **AI 助理**：智能推薦、數據查詢
- **訂閱計費系統**：Basic 和 Business 方案、自動計費、帳單管理
- **門店特殊營業日管理**：節假日、特殊營業時間

## 🏗️ 技術架構

### 技術棧
- **後端框架**: Gin (Go Web Framework)  
- **數據庫**: PostgreSQL
- **ORM**: GORM
- **認證**: JWT (golang-jwt/jwt)
- **密碼加密**: bcrypt
- **配置管理**: Viper
- **日誌**: Logrus
- **API 文檔**: Swagger (gin-swagger)
- **緩存**: Redis
- **圖片存儲**: Minio/AWS S3
- **部署**: Docker + Docker Compose
- **測試**: Testify

### 核心依賴 (更新)
```bash
go get github.com/gin-gonic/gin
go get gorm.io/gorm
go get gorm.io/driver/postgres
go get github.com/golang-jwt/jwt/v5
go get golang.org/x/crypto/bcrypt
go get github.com/spf13/viper
go get github.com/sirupsen/logrus
go get github.com/go-redis/redis/v8
go get github.com/google/uuid
go get github.com/lib/pq
go get github.com/stretchr/testify
go get github.com/swaggo/gin-swagger
go get net/smtp                                    # 郵件發送 (標準庫)
go get gopkg.in/gomail.v2                          # 進階郵件功能 (可選)
go get github.com/sendgrid/sendgrid-go/helpers/mail # SendGrid支持 (可選)
go get github.com/go-playground/validator/v10       # 資料驗證
go get github.com/gin-contrib/cors                  # CORS支持
go get github.com/gin-contrib/sessions              # Session支持
go get github.com/robfig/cron/v3                    # 定時任務 (計費和清理)
go get github.com/shopspring/decimal                # 精確金額計算
```

## 🗄️ 數據模型設計

### 核心實體

#### User 用戶表
```go
type User struct {
    ID        string    `json:"id" gorm:"primaryKey;type:varchar(36)"`
    Name      string    `json:"name" gorm:"not null"`
    Email     string    `json:"email" gorm:"uniqueIndex;not null"`
    Password  string    `json:"-" gorm:"not null"`
    Role      string    `json:"role" gorm:"default:'admin'"`
    CreatedAt time.Time `json:"created_at"`
    UpdatedAt time.Time `json:"updated_at"`
}
```

#### Business 商家表
```go
type Business struct {
    ID          string     `json:"id" gorm:"primaryKey;type:varchar(36)"`
    UserID      string     `json:"user_id" gorm:"not null;type:varchar(36)"`
    Name        string     `json:"name" gorm:"not null"`
    Description string     `json:"description"`
    Address     string     `json:"address"`
    Phone       string     `json:"phone"`
    Email       string     `json:"email"`
    LogoURL     *string    `json:"logo_url"`
    SocialLinks *string    `json:"social_links"`
    TaxID       *string    `json:"tax_id"`
    GoogleID    *string    `json:"google_id"`
    Timezone    string     `json:"timezone" gorm:"default:'Asia/Taipei'"`
    LastLoginAt *time.Time `json:"last_login_at"`
    CreatedAt   time.Time  `json:"created_at"`
    UpdatedAt   time.Time  `json:"updated_at"`
    
    // 關聯
    User         User          `json:"user" gorm:"foreignKey:UserID"`
    Branches     []Branch      `json:"branches" gorm:"foreignKey:BusinessID"`
    Services     []Service     `json:"services" gorm:"foreignKey:BusinessID"`
    Staff        []Staff       `json:"staff" gorm:"foreignKey:BusinessID"`
    Customers    []Customer    `json:"customers" gorm:"foreignKey:BusinessID"`
    Subscription *Subscription `json:"subscription" gorm:"foreignKey:BusinessID"`
}
```

#### Branch 門店表
```go
type Branch struct {
    ID                  string    `json:"id" gorm:"primaryKey;type:varchar(36)"`
    BusinessID          string    `json:"business_id" gorm:"not null;type:varchar(36)"`
    Name                string    `json:"name" gorm:"not null"`
    ContactPhone        *string   `json:"contact_phone"`
    Address             *string   `json:"address"`
    IsDefault           bool      `json:"is_default" gorm:"default:false"`
    Status              string    `json:"status" gorm:"default:'active'"`
    OperatingHoursStart *string   `json:"operating_hours_start"`
    OperatingHoursEnd   *string   `json:"operating_hours_end"`
    CreatedAt           time.Time `json:"created_at"`
    UpdatedAt           time.Time `json:"updated_at"`
}
```

#### BranchSpecialDay 門店特殊營業日表 (修正)
```go
type BranchSpecialDay struct {
    ID               string     `json:"id" gorm:"primaryKey;type:varchar(36)"`
    BranchID         string     `json:"branch_id" gorm:"not null;type:varchar(36)"`
    Date             time.Time  `json:"date" gorm:"not null"`
    IsOpen           bool       `json:"is_open" gorm:"not null"` // true=營業, false=休息
    OperatingHoursStart *string `json:"operating_hours_start"`  // 特殊營業開始時間
    OperatingHoursEnd   *string `json:"operating_hours_end"`    // 特殊營業結束時間
    Reason           *string    `json:"reason"`                 // 特殊營業日原因
    CreatedAt        time.Time  `json:"created_at"`
    UpdatedAt        time.Time  `json:"updated_at"`
}
```

#### Service 服務項目表
```go
type Service struct {
    ID            string    `json:"id" gorm:"primaryKey;type:varchar(36)"`
    BusinessID    string    `json:"business_id" gorm:"not null;type:varchar(36)"`
    Name          string    `json:"name" gorm:"not null"`
    Category      string    `json:"category" gorm:"not null"` // lash, pmu, nail, hair, skin, other
    Duration      int       `json:"duration" gorm:"not null"` // 分鐘
    RevisitPeriod int       `json:"revisit_period" gorm:"not null"` // 天
    Price         float64   `json:"price" gorm:"not null"`
    Profit        float64   `json:"profit" gorm:"not null"`
    Description   *string   `json:"description"`
    IsArchived    bool      `json:"is_archived" gorm:"default:false"`
    CreatedAt     time.Time `json:"created_at"`
    UpdatedAt     time.Time `json:"updated_at"`
}
```

#### BranchService 門店服務關聯表 (更新)
```go
type BranchService struct {
    ID           string    `json:"id" gorm:"primaryKey;type:varchar(36)"`
    BranchID     string    `json:"branch_id" gorm:"not null;type:varchar(36)"`
    ServiceID    string    `json:"service_id" gorm:"not null;type:varchar(36)"`
    IsAvailable  bool      `json:"is_available" gorm:"default:true"`
    CustomPrice  *float64  `json:"custom_price"`  // null = 使用服務原價
    CustomProfit *float64  `json:"custom_profit"` // null = 使用服務原利潤
    CreatedAt    time.Time `json:"created_at"`
    UpdatedAt    time.Time `json:"updated_at"`
    
    // 關聯
    Branch  Branch  `json:"branch" gorm:"foreignKey:BranchID"`
    Service Service `json:"service" gorm:"foreignKey:ServiceID"`
}
```

#### BranchOperatingHours 門店營業時間表 (新增)
```go
type BranchOperatingHours struct {
    ID        string    `json:"id" gorm:"primaryKey;type:varchar(36)"`
    BranchID  string    `json:"branch_id" gorm:"not null;type:varchar(36)"`
    DayOfWeek int       `json:"day_of_week" gorm:"not null"` // 0=Sunday, 1=Monday, ..., 6=Saturday
    IsOpen    bool      `json:"is_open" gorm:"default:true"`
    OpenTime  *string   `json:"open_time"`  // HH:MM format
    CloseTime *string   `json:"close_time"` // HH:MM format
    CreatedAt time.Time `json:"created_at"`
    UpdatedAt time.Time `json:"updated_at"`
    
    // 關聯
    Branch Branch `json:"branch" gorm:"foreignKey:BranchID"`
}
```

#### Staff 員工表
```go
type Staff struct {
    ID               string     `json:"id" gorm:"primaryKey;type:varchar(36)"`
    BusinessID       string     `json:"business_id" gorm:"not null;type:varchar(36)"`
    Name             string     `json:"name" gorm:"not null"`
    Email            *string    `json:"email"`
    Phone            *string    `json:"phone"`
    Role             string     `json:"role" gorm:"not null"` // owner, manager, senior_stylist, stylist, assistant, receptionist
    Status           string     `json:"status" gorm:"default:'active'"` // active, inactive, on_leave
    AvatarURL        *string    `json:"avatar_url"`
    BirthDate        *time.Time `json:"birth_date"`
    HireDate         time.Time  `json:"hire_date" gorm:"not null"`
    Address          *string    `json:"address"`
    EmergencyContact *string    `json:"emergency_contact"`
    EmergencyPhone   *string    `json:"emergency_phone"`
    Notes            *string    `json:"notes"`
    CreatedAt        time.Time  `json:"created_at"`
    UpdatedAt        time.Time  `json:"updated_at"`
    
    // 多門店和多服務支持
    BranchIDs  pq.StringArray `json:"branch_ids" gorm:"type:text[]"`
    ServiceIDs pq.StringArray `json:"service_ids" gorm:"type:text[]"`
}
```

#### Customer 客戶表
```go
type Customer struct {
    ID                string    `json:"id" gorm:"primaryKey;type:varchar(36)"`
    BusinessID        string    `json:"business_id" gorm:"not null;type:varchar(36)"`
    Name              string    `json:"name" gorm:"not null"`
    Gender            *string   `json:"gender"`
    Phone             *string   `json:"phone"`
    Email             *string   `json:"email"`
    IsArchived        bool      `json:"is_archived" gorm:"default:false"`
    NeedsMerge        bool      `json:"needs_merge" gorm:"default:false"`
    IsSpecialCustomer bool      `json:"is_special_customer" gorm:"default:false"`
    Source            *string   `json:"source"`
    CreatedAt         time.Time `json:"created_at"`
    UpdatedAt         time.Time `json:"updated_at"`
}
```

#### Appointment 預約表
```go
type Appointment struct {
    ID         string    `json:"id" gorm:"primaryKey;type:varchar(36)"`
    BusinessID string    `json:"business_id" gorm:"not null;type:varchar(36)"`
    BranchID   string    `json:"branch_id" gorm:"not null;type:varchar(36)"`
    CustomerID string    `json:"customer_id" gorm:"not null;type:varchar(36)"`
    ServiceID  string    `json:"service_id" gorm:"not null;type:varchar(36)"`
    StaffID    *string   `json:"staff_id" gorm:"type:varchar(36)"` // 可選
    StartTime  time.Time `json:"start_time" gorm:"not null"`
    EndTime    time.Time `json:"end_time" gorm:"not null"`
    Status     string    `json:"status" gorm:"default:'booked'"` // booked, confirmed, checked_in, completed, cancelled, no_show
    Note       *string   `json:"note"`
    CreatedAt  time.Time `json:"created_at"`
    UpdatedAt  time.Time `json:"updated_at"`
    
    // 關聯 (用於 Preload)
    Customer *Customer `json:"customer,omitempty" gorm:"foreignKey:CustomerID"`
    Service  *Service  `json:"service,omitempty" gorm:"foreignKey:ServiceID"`
    Branch   *Branch   `json:"branch,omitempty" gorm:"foreignKey:BranchID"`
    Staff    *Staff    `json:"staff,omitempty" gorm:"foreignKey:StaffID"`
}
```

#### ServiceHistory 服務歷史記錄表
```go
type ServiceHistory struct {
    ID          string    `json:"id" gorm:"primaryKey;type:varchar(36)"`
    BusinessID  string    `json:"business_id" gorm:"not null;type:varchar(36)"`
    CustomerID  string    `json:"customer_id" gorm:"not null;type:varchar(36)"`
    ServiceID   string    `json:"service_id" gorm:"not null;type:varchar(36)"`
    StaffID     *string   `json:"staff_id" gorm:"type:varchar(36)"`
    BranchID    string    `json:"branch_id" gorm:"not null;type:varchar(36)"`
    ServiceDate time.Time `json:"service_date" gorm:"not null"`
    ActualPrice float64   `json:"actual_price" gorm:"not null"`
    Notes       *string   `json:"notes"`
    CreatedAt   time.Time `json:"created_at"`
    UpdatedAt   time.Time `json:"updated_at"`
    
    // 關聯
    Customer *Customer `json:"customer,omitempty" gorm:"foreignKey:CustomerID"`
    Service  *Service  `json:"service,omitempty" gorm:"foreignKey:ServiceID"`
    Staff    *Staff    `json:"staff,omitempty" gorm:"foreignKey:StaffID"`
    Branch   *Branch   `json:"branch,omitempty" gorm:"foreignKey:BranchID"`
}
```

#### BusinessGoal 業務目標表
```go
type BusinessGoal struct {
    ID           string    `json:"id" gorm:"primaryKey;type:varchar(36)"`
    BusinessID   string    `json:"business_id" gorm:"not null;type:varchar(36)"`
    Title        string    `json:"title" gorm:"not null"`
    CurrentValue float64   `json:"current_value" gorm:"default:0"`
    TargetValue  float64   `json:"target_value" gorm:"not null"`
    Unit         string    `json:"unit" gorm:"not null"`
    StartDate    time.Time `json:"start_date" gorm:"not null"`
    EndDate      time.Time `json:"end_date" gorm:"not null"`
    Type         string    `json:"type" gorm:"not null"` // revenue, service_count, customer_count
    CreatedAt    time.Time `json:"created_at"`
    UpdatedAt    time.Time `json:"updated_at"`
}
```

#### BusinessAnalysis 業務分析表
```go
type BusinessAnalysis struct {
    ID           string    `json:"id" gorm:"primaryKey;type:varchar(36)"`
    BusinessID   string    `json:"business_id" gorm:"not null;type:varchar(36)"`
    AnalysisType string    `json:"analysis_type" gorm:"not null"` // revenue, customer, staff, service
    Period       string    `json:"period" gorm:"not null"` // daily, weekly, monthly, yearly
    StartDate    time.Time `json:"start_date" gorm:"not null"`
    EndDate      time.Time `json:"end_date" gorm:"not null"`
    Data         string    `json:"data" gorm:"type:text"` // JSON 格式儲存分析數據
    Status       string    `json:"status" gorm:"default:'pending'"` // pending, completed, failed
    CreatedAt    time.Time `json:"created_at"`
    UpdatedAt    time.Time `json:"updated_at"`
}
```

#### SubscriptionPlan 訂閱方案表
```go
type SubscriptionPlan struct {
    ID          string         `json:"id" gorm:"primaryKey;type:varchar(36)"`
    Name        string         `json:"name" gorm:"not null"`
    DisplayName string         `json:"displayName" gorm:"not null"`
    PricePerStaff float64      `json:"pricePerStaff" gorm:"not null"`
    MaxBranches   *int         `json:"maxBranches"` // null = unlimited
    Features      pq.StringArray `json:"features" gorm:"type:text[]"`
    Description   *string      `json:"description"`
    IsActive      bool         `json:"isActive" gorm:"default:true"`
    CreatedAt     time.Time    `json:"createdAt"`
    UpdatedAt     time.Time    `json:"updatedAt"`
}
```

#### Subscription 訂閱表
```go
type Subscription struct {
    ID            string    `json:"id" gorm:"primaryKey;type:varchar(36)"`
    BusinessID    string    `json:"businessId" gorm:"not null;type:varchar(36)"`
    PlanID        string    `json:"planId" gorm:"not null;type:varchar(36)"`
    Status        string    `json:"status" gorm:"default:'active'"` // active, expired, cancelled, trial
    StartDate     time.Time `json:"startDate" gorm:"not null"`
    EndDate       time.Time `json:"endDate" gorm:"not null"`
    CancelledDate *time.Time `json:"cancelledDate"`
    StaffCount    int       `json:"staffCount" gorm:"not null"`
    MonthlyAmount float64   `json:"monthlyAmount" gorm:"not null"`
    AutoRenewal   bool      `json:"autoRenewal" gorm:"default:true"`
    Metadata      *string   `json:"metadata"` // JSON string
    CreatedAt     time.Time `json:"created_at"`
    UpdatedAt     time.Time `json:"updated_at"`
    
    // 關聯
    Plan SubscriptionPlan `json:"plan" gorm:"foreignKey:PlanID"`
}
```

#### Billing 帳單表
```go
type Billing struct {
    ID               string     `json:"id" gorm:"primaryKey;type:varchar(36)"`
    BusinessID       string     `json:"businessId" gorm:"not null;type:varchar(36)"`
    SubscriptionID   string     `json:"subscriptionId" gorm:"not null;type:varchar(36)"`
    BillingDate      time.Time  `json:"billingDate" gorm:"not null"`
    DueDate          time.Time  `json:"dueDate" gorm:"not null"`
    PaidDate         *time.Time `json:"paidDate"`
    Status           string     `json:"status" gorm:"default:'pending'"` // pending, paid, overdue, cancelled, refunded
    Amount           float64    `json:"amount" gorm:"not null"`
    TaxAmount        float64    `json:"taxAmount" gorm:"default:0"`
    TotalAmount      float64    `json:"totalAmount" gorm:"not null"`
    PaymentMethod    *string    `json:"paymentMethod"` // creditCard, bankTransfer, cash, other
    PaymentReference *string    `json:"paymentReference"`
    StaffCount       int        `json:"staffCount" gorm:"not null"`
    PlanName         string     `json:"planName" gorm:"not null"`
    PricePerStaff    float64    `json:"pricePerStaff" gorm:"not null"`
    Notes            *string    `json:"notes"`
    Metadata         *string    `json:"metadata"`
    CreatedAt        time.Time  `json:"created_at"`
    UpdatedAt        time.Time  `json:"updated_at"`
}
```

#### EmailVerification 郵件驗證表
```go
type EmailVerification struct {
    ID             string    `json:"id" gorm:"primaryKey;type:varchar(36)"`
    Email          string    `json:"email" gorm:"not null;index"`
    Code           string    `json:"code" gorm:"not null"`
    Type           string    `json:"type" gorm:"not null"` // register, reset_password
    IsVerified     bool      `json:"is_verified" gorm:"default:false"`
    IsUsed         bool      `json:"is_used" gorm:"default:false"`
    ExpiresAt      time.Time `json:"expires_at" gorm:"not null"`
    VerifiedAt     *time.Time `json:"verified_at"`
    IPAddress      *string   `json:"ip_address"`
    UserAgent      *string   `json:"user_agent"`
    AttemptCount   int       `json:"attempt_count" gorm:"default:0"`
    LastAttemptAt  *time.Time `json:"last_attempt_at"`
    CreatedAt      time.Time `json:"created_at"`
    UpdatedAt      time.Time `json:"updated_at"`
}
```

#### EmailSendRecord 郵件發送記錄表
```go
type EmailSendRecord struct {
    ID            string    `json:"id" gorm:"primaryKey;type:varchar(36)"`
    Email         string    `json:"email" gorm:"not null;index"`
    Type          string    `json:"type" gorm:"not null"` // verification, welcome, reset_password
    Subject       string    `json:"subject" gorm:"not null"`
    Status        string    `json:"status" gorm:"default:'pending'"` // pending, sent, failed
    Provider      string    `json:"provider" gorm:"not null"` // smtp, sendgrid, ses
    ProviderID    *string   `json:"provider_id"`
    ErrorMessage  *string   `json:"error_message"`
    SentAt        *time.Time `json:"sent_at"`
    IPAddress     *string   `json:"ip_address"`
    UserAgent     *string   `json:"user_agent"`
    CreatedAt     time.Time `json:"created_at"`
    UpdatedAt     time.Time `json:"updated_at"`
}
```

## 🔌 完整 API 端點設計

### 認證管理 (Authentication)
```
POST   /api/v1/auth/send-verification-email - 發送驗證郵件
POST   /api/v1/auth/verify-email           - 驗證郵件
POST   /api/v1/auth/register               - 用戶註冊
POST   /api/v1/auth/login                  - 用戶登入
POST   /api/v1/auth/logout                 - 用戶登出
POST   /api/v1/auth/refresh                - 刷新 Token
GET    /api/v1/auth/me                     - 獲取當前用戶信息
POST   /api/v1/auth/resend-verification    - 重新發送驗證郵件
```

#### 發送驗證郵件 API 詳細規格

**端點**: `POST /api/v1/auth/send-verification-email`

**請求格式**:
```go
type SendVerificationEmailRequest struct {
    Email string `json:"email" validate:"required,email"`
    Type  string `json:"type" validate:"required"` // "register" or "reset_password"
}
```

**請求示例**:
```json
{
    "email": "wang@example.com",
    "type": "register"
}
```

**成功響應** (HTTP 200):
```json
{
    "code": 200,
    "message": "驗證郵件已發送",
    "data": {
        "email": "wang@example.com",
        "expires_in": 600,
        "resend_after": 60
    }
}
```

**錯誤響應**:
```json
{
    "code": 400,
    "message": "發送失敗",
    "errors": {
        "email": "電子郵件已被註冊"
    }
}
```

**業務邏輯**:
1. 驗證電子郵件格式
2. 檢查郵件是否已被註冊 (註冊類型)
3. 生成6位數驗證碼
4. 存儲驗證記錄 (10分鐘有效期)
5. 發送驗證郵件
6. 限制60秒內不能重複發送

#### 驗證郵件 API 詳細規格

**端點**: `POST /api/v1/auth/verify-email`

**請求格式**:
```go
type VerifyEmailRequest struct {
    Email string `json:"email" validate:"required,email"`
    Code  string `json:"code" validate:"required,len=6"`
    Type  string `json:"type" validate:"required"` // "register" or "reset_password"
}
```

**請求示例**:
```json
{
    "email": "wang@example.com",
    "code": "123456",
    "type": "register"
}
```

**成功響應** (HTTP 200):
```json
{
    "code": 200,
    "message": "郵件驗證成功",
    "data": {
        "email": "wang@example.com",
        "verified": true,
        "verification_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
    }
}
```

**錯誤響應**:
```json
{
    "code": 400,
    "message": "驗證失敗",
    "errors": {
        "code": "驗證碼錯誤或已過期"
    }
}
```

**業務邏輯**:
1. 查詢驗證記錄
2. 檢查驗證碼是否正確
3. 檢查是否已過期
4. 標記為已驗證
5. 生成驗證Token (用於後續註冊)

#### 修改後的用戶註冊 API 詳細規格

**端點**: `POST /api/v1/auth/register`

**請求格式**:
```go
type RegisterRequest struct {
    Name              string `json:"name" validate:"required,min=2,max=50"`
    Email             string `json:"email" validate:"required,email"`
    Password          string `json:"password" validate:"required,min=6"`
    BusinessName      string `json:"business_name" validate:"required,min=2,max=100"`
    VerificationToken string `json:"verification_token" validate:"required"` // 郵件驗證後獲得的Token
}
```

**請求示例**:
```json
{
    "name": "王小美",
    "email": "wang@example.com", 
    "password": "123456",
    "business_name": "王小美髮廊",
    "verification_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**業務邏輯更新**:
1. **驗證 verification_token** (新增)
2. 檢查電子郵件是否已被註冊
3. 創建用戶記錄 (密碼加密存儲)
4. 創建商家記錄並關聯用戶
5. 創建默認門店記錄
6. 分配默認訂閱方案 (Basic Trial - 14天試用)
7. **標記郵件為已驗證** (新增)
8. 生成JWT Token
9. 返回完整註冊信息

### 商家管理 (Business)
```
GET    /api/v1/businesses         - 獲取商家列表
POST   /api/v1/businesses         - 創建商家
GET    /api/v1/businesses/:id     - 獲取商家詳情
PUT    /api/v1/businesses/:id     - 更新商家信息
DELETE /api/v1/businesses/:id     - 刪除商家
POST   /api/v1/businesses/:id/restore - 恢復商家
```

### 門店管理 (Branches)
```
GET    /api/v1/branches           - 獲取門店列表
POST   /api/v1/branches           - 創建門店
GET    /api/v1/branches/:id       - 獲取門店詳情
PUT    /api/v1/branches/:id       - 更新門店信息
DELETE /api/v1/branches/:id       - 刪除門店
GET    /api/v1/businesses/:businessId/branches - 獲取商家門店列表
```

### 門店特殊營業日管理 (Branch Special Days)
```
GET    /api/v1/branches/:id/special-days          - 獲取門店特殊營業日
POST   /api/v1/branches/:id/special-days          - 創建門店特殊營業日
GET    /api/v1/special-days/:id                   - 獲取特殊營業日詳情
PUT    /api/v1/special-days/:id                   - 更新特殊營業日
DELETE /api/v1/special-days/:id                   - 刪除特殊營業日
GET    /api/v1/branches/:id/special-days/date/:date - 獲取特定日期的特殊營業日
```

### 服務管理 (Services)
```
GET    /api/v1/services           - 獲取服務列表
POST   /api/v1/services           - 創建服務
GET    /api/v1/services/:id       - 獲取服務詳情
PUT    /api/v1/services/:id       - 更新服務信息
DELETE /api/v1/services/:id       - 刪除服務
GET    /api/v1/businesses/:businessId/services - 獲取商家服務列表
GET    /api/v1/services?includeArchived=true   - 包含已封存的服務
```

### 門店服務管理 (Branch Services)
```
GET    /api/v1/branches/:id/services              - 獲取門店可用服務
POST   /api/v1/branches/:id/services              - 為門店添加服務
PUT    /api/v1/branch-services/:id                - 更新門店服務配置
DELETE /api/v1/branch-services/:id                - 移除門店服務
GET    /api/v1/branches/:id/available-services    - 獲取門店可提供的服務列表 (新增)
```

### 門店營業時間管理 (Branch Operating Hours) - 新增API
```
GET    /api/v1/branches/:id/operating-hours       - 獲取門店營業時間
PUT    /api/v1/branches/:id/operating-hours       - 更新門店營業時間
POST   /api/v1/branches/:id/operating-hours       - 設定門店營業時間
GET    /api/v1/branches/:id/operating-hours/:day  - 獲取特定日期營業時間
```

### 員工管理 (Staff)
```
GET    /api/v1/staff              - 獲取員工列表
POST   /api/v1/staff              - 創建員工
GET    /api/v1/staff/:id          - 獲取員工詳情
PUT    /api/v1/staff/:id          - 更新員工信息
DELETE /api/v1/staff/:id          - 刪除員工
GET    /api/v1/businesses/:businessId/staff - 獲取商家員工列表
GET    /api/v1/branches/:branchId/staff     - 獲取門店員工列表
GET    /api/v1/services/:serviceId/staff    - 獲取可提供特定服務的員工
```

### 客戶管理 (Customers)
```
GET    /api/v1/customers          - 獲取客戶列表
POST   /api/v1/customers          - 創建客戶
GET    /api/v1/customers/:id      - 獲取客戶詳情
PUT    /api/v1/customers/:id      - 更新客戶信息
DELETE /api/v1/customers/:id      - 刪除客戶
GET    /api/v1/businesses/:businessId/customers - 獲取商家客戶列表
GET    /api/v1/customers?includeArchived=true   - 包含已封存的客戶
```

### 預約管理 (Appointments)
```
GET    /api/v1/appointments       - 獲取預約列表
POST   /api/v1/appointments       - 創建預約
GET    /api/v1/appointments/:id   - 獲取預約詳情
PUT    /api/v1/appointments/:id   - 更新預約
DELETE /api/v1/appointments/:id   - 取消預約
PATCH  /api/v1/appointments/:id/status - 更新預約狀態
GET    /api/v1/businesses/:businessId/appointments - 獲取商家預約列表
GET    /api/v1/customers/:customerId/appointments  - 獲取客戶預約列表
GET    /api/v1/appointments/date-range - 獲取日期範圍內的預約
```

### 服務歷史記錄 (Service History)
```
GET    /api/v1/service-history               - 獲取服務歷史記錄
POST   /api/v1/service-history               - 創建服務歷史記錄
GET    /api/v1/service-history/:id           - 獲取服務歷史詳情
PUT    /api/v1/service-history/:id           - 更新服務歷史記錄
DELETE /api/v1/service-history/:id           - 刪除服務歷史記錄
GET    /api/v1/customers/:id/service-history - 獲取客戶服務歷史
GET    /api/v1/businesses/:businessId/service-history - 獲取商家服務歷史
GET    /api/v1/service-history/date-range    - 獲取日期範圍內的服務歷史
```

### 業務目標管理 (Business Goals)
```
GET    /api/v1/business-goals                - 獲取業務目標
POST   /api/v1/business-goals                - 創建業務目標
GET    /api/v1/business-goals/:id            - 獲取業務目標詳情
PUT    /api/v1/business-goals/:id            - 更新業務目標
DELETE /api/v1/business-goals/:id            - 刪除業務目標
GET    /api/v1/businesses/:businessId/business-goals - 獲取商家業務目標
```

### 業務分析 (Business Analysis)
```
GET    /api/v1/business-analyses             - 獲取業務分析列表
POST   /api/v1/business-analyses             - 創建業務分析
GET    /api/v1/business-analyses/:id         - 獲取業務分析詳情
PUT    /api/v1/business-analyses/:id         - 更新業務分析
DELETE /api/v1/business-analyses/:id         - 刪除業務分析
PATCH  /api/v1/business-analyses/:id/status  - 更新分析狀態
GET    /api/v1/businesses/:businessId/business-analyses - 獲取商家業務分析
GET    /api/v1/business-analyses/type/:type  - 根據類型獲取分析
GET    /api/v1/business-analyses/period/:period - 根據週期獲取分析
```

### 績效分析 (Performance Analytics)
```
GET    /api/v1/analytics/dashboard           - 儀表板數據
GET    /api/v1/analytics/revenue             - 營收分析
GET    /api/v1/analytics/customers           - 客戶分析
GET    /api/v1/analytics/staff               - 員工績效分析
GET    /api/v1/analytics/branches            - 門店績效分析
GET    /api/v1/analytics/branch-performances/:businessId - 獲取門店表現數據
GET    /api/v1/analytics/staff-performances/:businessId  - 獲取員工表現數據
GET    /api/v1/analytics/branch-performance/:branchId    - 獲取特定門店表現
GET    /api/v1/analytics/staff-performance/:staffId      - 獲取特定員工表現
GET    /api/v1/analytics/staff-performances/branch/:branchId - 獲取門店員工表現
```

#### 儀表板數據 API 詳細規格

**端點**: `GET /api/v1/analytics/dashboard`

**查詢參數**:
- `business_id` (required): 商家ID
- `branch_id` (optional): 門店ID，不提供則返回所有門店數據
- `period` (optional): 週期 (daily, weekly, monthly, yearly)，默認為monthly
- `start_date` (optional): 開始日期
- `end_date` (optional): 結束日期

**成功響應**:
```go
type DashboardResponse struct {
    Code    int    `json:"code"`
    Message string `json:"message"`
    Data    struct {
        Summary    DashboardSummary    `json:"summary"`
        Goals      []BusinessGoal      `json:"goals"`
        Branches   []BranchPerformance `json:"branches"`
        Staff      []StaffPerformance  `json:"staff"`
    } `json:"data"`
}

type DashboardSummary struct {
    TotalRevenue       float64 `json:"total_revenue"`
    TotalAppointments  int     `json:"total_appointments"`
    ActiveBranches     int     `json:"active_branches"`
    ActiveStaff        int     `json:"active_staff"`
    CustomerCount      int     `json:"customer_count"`
    AverageOccupancy   float64 `json:"average_occupancy"`
    PeriodStart        string  `json:"period_start"`
    PeriodEnd          string  `json:"period_end"`
}
```

#### 門店表現數據 API 詳細規格

**端點**: `GET /api/v1/analytics/branch-performances/:businessId`

**成功響應**:
```go
type BranchPerformanceResponse struct {
    Code    int                 `json:"code"`
    Message string              `json:"message"`
    Data    []BranchPerformance `json:"data"`
}

type BranchPerformance struct {
    BranchID            string    `json:"branch_id"`
    BranchName          string    `json:"branch_name"`
    MonthlyRevenue      float64   `json:"monthly_revenue"`
    AppointmentCount    int       `json:"appointment_count"`
    CustomerCount       int       `json:"customer_count"`
    AverageServicePrice float64   `json:"average_service_price"`
    OccupancyRate       float64   `json:"occupancy_rate"`
    StaffCount          int       `json:"staff_count"`
    PeriodStart         time.Time `json:"period_start"`
    PeriodEnd           time.Time `json:"period_end"`
}
```

#### 員工表現數據 API 詳細規格

**端點**: `GET /api/v1/analytics/staff-performances/:businessId`

**成功響應**:
```go
type StaffPerformanceResponse struct {
    Code    int                `json:"code"`
    Message string             `json:"message"`
    Data    []StaffPerformance `json:"data"`
}

type StaffPerformance struct {
    StaffID                   string    `json:"staff_id"`
    StaffName                 string    `json:"staff_name"`
    Role                      string    `json:"role"`
    AvatarURL                 *string   `json:"avatar_url"`
    MonthlyRevenue            float64   `json:"monthly_revenue"`
    AppointmentCount          int       `json:"appointment_count"`
    CustomerCount             int       `json:"customer_count"`
    AverageServicePrice       float64   `json:"average_service_price"`
    CustomerSatisfactionScore float64   `json:"customer_satisfaction_score"`
    CompletedAppointments     int       `json:"completed_appointments"`
    CancelledAppointments     int       `json:"cancelled_appointments"`
    AttendanceRate            float64   `json:"attendance_rate"`
    PeriodStart               time.Time `json:"period_start"`
    PeriodEnd                 time.Time `json:"period_end"`
}
```

#### 門店員工表現數據 API 詳細規格

**端點**: `GET /api/v1/analytics/staff-performances/branch/:branchId`

**查詢參數**:
- `business_id` (required): 商家ID

**成功響應**: 與員工表現數據API相同，但只返回該門店的員工數據

### 訂閱方案管理 (Subscription Plans)
```
GET    /api/v1/subscription-plans            - 獲取所有訂閱方案
GET    /api/v1/subscription-plans/:id        - 獲取特定訂閱方案
POST   /api/v1/subscription-plans            - 創建訂閱方案 (管理員)
PUT    /api/v1/subscription-plans/:id        - 更新訂閱方案 (管理員)
DELETE /api/v1/subscription-plans/:id        - 刪除訂閱方案 (管理員)
```

### 訂閱管理 (Subscriptions)
```
GET    /api/v1/subscriptions                 - 獲取訂閱信息
POST   /api/v1/subscriptions                 - 創建訂閱
PUT    /api/v1/subscriptions/:id             - 更新訂閱方案
DELETE /api/v1/subscriptions/:id             - 取消訂閱
GET    /api/v1/businesses/:businessId/subscription - 獲取商家當前訂閱
```

### 帳單管理 (Billing)
```
GET    /api/v1/billings                      - 獲取帳單列表
GET    /api/v1/billings/:id                  - 獲取帳單詳情
POST   /api/v1/billings/:id/pay              - 處理付款
POST   /api/v1/billings                      - 生成新帳單
GET    /api/v1/businesses/:businessId/billings - 獲取商家帳單列表
GET    /api/v1/billings/stats/:businessId     - 獲取帳單統計
```

## 🔑 JWT 認證

### Claims 結構
```go
type Claims struct {
    UserID     string `json:"user_id"`
    BusinessID string `json:"business_id"`
    Email      string `json:"email"`
    jwt.RegisteredClaims
}
```

### JWT 工具函數
```go
import "github.com/google/uuid"

func GenerateID() string {
    return uuid.New().String()
}

func GenerateJWT(userID, businessID, email string) (string, error) {
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
```

## 📦 核心服務實現

### 郵件服務
```go
type EmailService struct {
    smtpHost     string
    smtpPort     int
    smtpUser     string
    smtpPassword string
    fromEmail    string
    fromName     string
}

func NewEmailService(config EmailConfig) *EmailService {
    return &EmailService{
        smtpHost:     config.SMTPHost,
        smtpPort:     config.SMTPPort,
        smtpUser:     config.SMTPUser,
        smtpPassword: config.SMTPPassword,
        fromEmail:    config.FromEmail,
        fromName:     config.FromName,
    }
}

func (s *EmailService) SendVerificationEmail(email, code, name string) error {
    subject := "BeautyAI - 電子郵件驗證"
    body := s.buildVerificationEmailHTML(code, name)
    
    return s.sendEmail(email, subject, body)
}

func (s *EmailService) buildVerificationEmailHTML(code, name string) string {
    return fmt.Sprintf(`
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="UTF-8">
        <title>BeautyAI - 電子郵件驗證</title>
    </head>
    <body style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
        <div style="text-align: center; margin-bottom: 30px;">
            <h1 style="color: #E91E63;">BeautyAI 美業管理系統</h1>
        </div>
        
        <div style="background-color: #f8f9fa; padding: 30px; border-radius: 10px;">
            <h2>歡迎您，%s！</h2>
            <p>感謝您註冊 BeautyAI 美業管理系統。請使用以下驗證碼完成電子郵件驗證：</p>
            
            <div style="text-align: center; margin: 30px 0;">
                <div style="display: inline-block; background-color: #E91E63; color: white; padding: 15px 30px; border-radius: 5px; font-size: 24px; font-weight: bold; letter-spacing: 3px;">
                    %s
                </div>
            </div>
            
            <p style="color: #666;">此驗證碼將在 10 分鐘後過期，請盡快完成驗證。</p>
            <p style="color: #666;">如果您沒有註冊 BeautyAI 帳號，請忽略此郵件。</p>
        </div>
        
        <div style="text-align: center; margin-top: 30px; color: #999; font-size: 12px;">
            <p>此郵件由 BeautyAI 系統自動發送，請勿回覆</p>
        </div>
    </body>
    </html>
    `, name, code)
}

func (s *EmailService) sendEmail(to, subject, body string) error {
    auth := smtp.PlainAuth("", s.smtpUser, s.smtpPassword, s.smtpHost)
    
    msg := []byte(fmt.Sprintf("To: %s\r\nSubject: %s\r\nContent-Type: text/html; charset=UTF-8\r\n\r\n%s", to, subject, body))
    
    addr := fmt.Sprintf("%s:%d", s.smtpHost, s.smtpPort)
    return smtp.SendMail(addr, auth, s.fromEmail, []string{to}, msg)
}
```

### 郵件驗證服務
```go
type EmailVerificationService struct {
    verificationRepo repositories.EmailVerificationRepository
    sendRecordRepo   repositories.EmailSendRecordRepository
    emailService     *EmailService
}

func (s *EmailVerificationService) SendVerificationCode(email, verificationType, ipAddress, userAgent string) error {
    // 檢查60秒內是否已發送
    lastRecord, _ := s.sendRecordRepo.GetLatestByEmail(email, verificationType)
    if lastRecord != nil && time.Since(lastRecord.CreatedAt) < 60*time.Second {
        return errors.New("請等待60秒後再重新發送")
    }
    
    // 生成6位數驗證碼
    code := s.generateVerificationCode()
    
    // 創建驗證記錄
    verification := &entities.EmailVerification{
        ID:        GenerateID(),
        Email:     email,
        Code:      code,
        Type:      verificationType,
        ExpiresAt: time.Now().Add(10 * time.Minute),
        IPAddress: &ipAddress,
        UserAgent: &userAgent,
    }
    
    _, err := s.verificationRepo.Create(verification)
    if err != nil {
        return err
    }
    
    // 創建發送記錄
    sendRecord := &entities.EmailSendRecord{
        ID:        GenerateID(),
        Email:     email,
        Type:      "verification",
        Subject:   "BeautyAI - 電子郵件驗證",
        Provider:  "smtp",
        IPAddress: &ipAddress,
        UserAgent: &userAgent,
    }
    
    // 發送郵件
    err = s.emailService.SendVerificationEmail(email, code, "")
    if err != nil {
        sendRecord.Status = "failed"
        sendRecord.ErrorMessage = &err.Error()
    } else {
        sendRecord.Status = "sent"
        now := time.Now()
        sendRecord.SentAt = &now
    }
    
    s.sendRecordRepo.Create(sendRecord)
    return err
}

func (s *EmailVerificationService) VerifyCode(email, code, verificationType string) (string, error) {
    // 查找未使用的驗證記錄
    verification, err := s.verificationRepo.GetByEmailAndCode(email, code, verificationType)
    if err != nil {
        return "", errors.New("驗證碼不存在")
    }
    
    // 檢查是否已過期
    if time.Now().After(verification.ExpiresAt) {
        return "", errors.New("驗證碼已過期")
    }
    
    // 檢查是否已被使用
    if verification.IsUsed {
        return "", errors.New("驗證碼已被使用")
    }
    
    // 更新為已驗證
    now := time.Now()
    verification.IsVerified = true
    verification.VerifiedAt = &now
    
    err = s.verificationRepo.Update(verification)
    if err != nil {
        return "", err
    }
    
    // 生成驗證Token
    token, err := s.generateVerificationToken(email, verificationType)
    if err != nil {
        return "", err
    }
    
    return token, nil
}

func (s *EmailVerificationService) generateVerificationCode() string {
    code := rand.Intn(900000) + 100000 // 100000-999999
    return fmt.Sprintf("%06d", code)
}

func (s *EmailVerificationService) generateVerificationToken(email, verificationType string) (string, error) {
    claims := jwt.MapClaims{
        "email": email,
        "type":  verificationType,
        "exp":   time.Now().Add(30 * time.Minute).Unix(), // 30分鐘有效期
        "iat":   time.Now().Unix(),
    }
    
    token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
    return token.SignedString([]byte(jwtSecret))
}

func (s *EmailVerificationService) ValidateVerificationToken(tokenString string) (string, string, error) {
    token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
        return []byte(jwtSecret), nil
    })
    
    if err != nil || !token.Valid {
        return "", "", errors.New("無效的驗證Token")
    }
    
    claims, ok := token.Claims.(jwt.MapClaims)
    if !ok {
        return "", "", errors.New("無效的Token格式")
    }
    
    email, _ := claims["email"].(string)
    verificationType, _ := claims["type"].(string)
    
    return email, verificationType, nil
}
```

### 認證服務
```go
type AuthService struct {
    userRepo                repositories.UserRepository
    businessRepo            repositories.BusinessRepository
    branchRepo              repositories.BranchRepository
    subscriptionRepo        repositories.SubscriptionRepository
    planRepo                repositories.SubscriptionPlanRepository
    emailVerificationService *EmailVerificationService
}

func (s *AuthService) Register(name, email, password, businessName, verificationToken string) (*RegisterResponse, error) {
    // 1. 驗證 verification_token
    verifiedEmail, verificationType, err := s.emailVerificationService.ValidateVerificationToken(verificationToken)
    if err != nil {
        return nil, errors.New("驗證Token無效")
    }
    
    if verifiedEmail != email || verificationType != "register" {
        return nil, errors.New("驗證Token與提供的郵件不匹配")
    }
    
    // 2. 檢查電子郵件是否已被使用
    existingUser, _ := s.userRepo.GetByEmail(email)
    if existingUser != nil {
        return nil, errors.New("電子郵件已被使用")
    }
    
    // 3. 密碼加密
    hashedPassword, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
    if err != nil {
        return nil, err
    }
    
    // 4. 創建用戶
    user := &entities.User{
        ID:       GenerateID(),
        Name:     name,
        Email:    email,
        Password: string(hashedPassword),
        Role:     "admin",
    }
    
    user, err = s.userRepo.Create(user)
    if err != nil {
        return nil, err
    }
    
    // 5. 創建商家
    business := &entities.Business{
        ID:       GenerateID(),
        UserID:   user.ID,
        Name:     businessName,
        Timezone: "Asia/Taipei",
    }
    
    business, err = s.businessRepo.Create(business)
    if err != nil {
        return nil, err
    }
    
    // 6. 創建默認門店
    defaultBranch := &entities.Branch{
        ID:                  GenerateID(),
        BusinessID:          business.ID,
        Name:               businessName + " - 總店",
        IsDefault:           true,
        Status:              "active",
        OperatingHoursStart: StringPtr("09:00"),
        OperatingHoursEnd:   StringPtr("18:00"),
    }
    
    _, err = s.branchRepo.Create(defaultBranch)
    if err != nil {
        return nil, err
    }
    
    // 7. 獲取Basic Trial訂閱方案
    basicPlan, err := s.planRepo.GetByName("Basic")
    if err != nil {
        return nil, errors.New("默認訂閱方案不存在")
    }
    
    // 8. 創建試用訂閱
    now := time.Now()
    subscription := &entities.Subscription{
        ID:            GenerateID(),
        BusinessID:    business.ID,
        PlanID:        basicPlan.ID,
        Status:        "trial",
        StartDate:     now,
        EndDate:       now.AddDate(0, 0, 14), // 14天試用
        StaffCount:    1, // 默認包含1個員工
        MonthlyAmount: 0, // 試用期免費
        AutoRenewal:   false,
    }
    
    _, err = s.subscriptionRepo.Create(subscription)
    if err != nil {
        return nil, err
    }
    
    // 9. 標記驗證碼為已使用
    s.emailVerificationService.MarkAsUsed(email, "register")
    
    // 10. 生成JWT Token
    token, err := GenerateJWT(user.ID, business.ID, user.Email)
    if err != nil {
        return nil, err
    }
    
    // 11. 構建響應
    response := &RegisterResponse{
        Code:    201,
        Message: "註冊成功",
        Data: RegisterData{
            User: UserResponse{
                ID:        user.ID,
                Name:      user.Name,
                Email:     user.Email,
                Role:      user.Role,
                CreatedAt: user.CreatedAt,
            },
            Business: BusinessResponse{
                ID:        business.ID,
                Name:      business.Name,
                UserID:    business.UserID,
                CreatedAt: business.CreatedAt,
            },
            Token:     token,
            ExpiresIn: 86400, // 24小時
        },
    }
    
    return response, nil
}

### 預約服務 (含衝突檢查)
```go
type AppointmentService struct {
    appointmentRepo repositories.AppointmentRepository
    staffRepo       repositories.StaffRepository
    serviceRepo     repositories.ServiceRepository
}

func (s *AppointmentService) CreateAppointment(appointment *entities.Appointment) (*entities.Appointment, error) {
    // 驗證服務存在
    service, err := s.serviceRepo.GetByID(appointment.ServiceID)
    if err != nil {
        return nil, errors.New("service not found")
    }
    
    // 設置結束時間
    appointment.EndTime = appointment.StartTime.Add(time.Duration(service.Duration) * time.Minute)
    
    // 檢查時間衝突
    conflicts, err := s.appointmentRepo.CheckTimeConflicts(
        appointment.BranchID,
        appointment.StartTime,
        appointment.EndTime,
        appointment.StaffID,
    )
    if err != nil {
        return nil, err
    }
    if len(conflicts) > 0 {
        return nil, errors.New("time slot conflicts with existing appointments")
    }
    
    appointment.ID = GenerateID()
    return s.appointmentRepo.Create(appointment)
}
```

### 訂閱服務 (自動計費)
```go
type SubscriptionService struct {
    subscriptionRepo repositories.SubscriptionRepository
    billingRepo      repositories.BillingRepository
}

func (s *SubscriptionService) GenerateMonthlyBilling(businessID string) (*entities.Billing, error) {
    subscription, err := s.subscriptionRepo.GetByBusinessID(businessID)
    if err != nil {
        return err
    }
    
    now := time.Now()
    billingDate := time.Date(now.Year(), now.Month(), 1, 0, 0, 0, 0, now.Location())
    dueDate := billingDate.AddDate(0, 0, 15) // 15天付款期限
    
    amount := float64(subscription.StaffCount) * subscription.Plan.PricePerStaff
    taxAmount := amount * 0.05 // 5% 稅金
    totalAmount := amount + taxAmount
    
    billing := &entities.Billing{
        ID:             GenerateID(),
        BusinessID:     businessID,
        SubscriptionID: subscription.ID,
        BillingDate:    billingDate,
        DueDate:        dueDate,
        Status:         "pending",
        Amount:         amount,
        TaxAmount:      taxAmount,
        TotalAmount:    totalAmount,
        StaffCount:     subscription.StaffCount,
        PlanName:       subscription.Plan.Name,
        PricePerStaff:  subscription.Plan.PricePerStaff,
    }
    
    return s.billingRepo.Create(billing)
}
```

### 門店營業時間服務
```go
type BranchOperatingHoursService struct {
    operatingHoursRepo repositories.BranchOperatingHoursRepository
    branchRepo         repositories.BranchRepository
}

func (s *BranchOperatingHoursService) GetBranchOperatingHours(branchID string) (*BranchOperatingHoursData, error) {
    // 驗證門店存在
    branch, err := s.branchRepo.GetByID(branchID)
    if err != nil {
        return nil, errors.New("門店不存在")
    }
    
    // 獲取營業時間設定
    operatingHours, err := s.operatingHoursRepo.GetByBranchID(branchID)
    if err != nil {
        return nil, err
    }
    
    // 創建完整的週間營業時間 (如果沒有設定則使用默認值)
    weeklyHours := make([]DayOperatingHours, 7)
    dayNames := []string{"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"}
    
    for day := 0; day < 7; day++ {
        // 查找是否有該天的設定
        var dayHours *entities.BranchOperatingHours
        for _, oh := range operatingHours {
            if oh.DayOfWeek == day {
                dayHours = &oh
                break
            }
        }
        
        if dayHours != nil {
            weeklyHours[day] = DayOperatingHours{
                DayOfWeek: day,
                DayName:   dayNames[day],
                IsOpen:    dayHours.IsOpen,
                OpenTime:  dayHours.OpenTime,
                CloseTime: dayHours.CloseTime,
            }
        } else {
            // 使用門店默認營業時間
            weeklyHours[day] = DayOperatingHours{
                DayOfWeek: day,
                DayName:   dayNames[day],
                IsOpen:    true,
                OpenTime:  branch.OperatingHoursStart,
                CloseTime: branch.OperatingHoursEnd,
            }
        }
    }
    
    return &BranchOperatingHoursData{
        BranchID:    branchID,
        BranchName:  branch.Name,
        WeeklyHours: weeklyHours,
    }, nil
}

func (s *BranchOperatingHoursService) UpdateBranchOperatingHours(branchID string, request UpdateOperatingHoursRequest) error {
    // 驗證門店存在
    _, err := s.branchRepo.GetByID(branchID)
    if err != nil {
        return errors.New("門店不存在")
    }
    
    // 驗證請求數據
    if len(request.WeeklyHours) != 7 {
        return errors.New("必須提供完整的週間營業時間設定")
    }
    
    // 驗證營業時間邏輯
    for _, dayHours := range request.WeeklyHours {
        if dayHours.IsOpen {
            if dayHours.OpenTime == nil || dayHours.CloseTime == nil {
                return errors.New("營業日必須設定開店和關店時間")
            }
            
            openTime, err := time.Parse("15:04", *dayHours.OpenTime)
            if err != nil {
                return errors.New("開店時間格式錯誤")
            }
            
            closeTime, err := time.Parse("15:04", *dayHours.CloseTime)
            if err != nil {
                return errors.New("關店時間格式錯誤")
            }
            
            if !openTime.Before(closeTime) {
                return errors.New("開店時間必須早於關店時間")
            }
        }
    }
    
    // 更新營業時間
    for _, dayHours := range request.WeeklyHours {
        operatingHours := &entities.BranchOperatingHours{
            BranchID:  branchID,
            DayOfWeek: dayHours.DayOfWeek,
            IsOpen:    dayHours.IsOpen,
            OpenTime:  dayHours.OpenTime,
            CloseTime: dayHours.CloseTime,
        }
        
        // 檢查是否已存在該天的設定
        existing, _ := s.operatingHoursRepo.GetByBranchIDAndDay(branchID, dayHours.DayOfWeek)
        if existing != nil {
            operatingHours.ID = existing.ID
            operatingHours.CreatedAt = existing.CreatedAt
            err = s.operatingHoursRepo.Update(operatingHours)
        } else {
            operatingHours.ID = GenerateID()
            _, err = s.operatingHoursRepo.Create(operatingHours)
        }
        
        if err != nil {
            return err
        }
    }
    
    return nil
}
```

### 門店服務關聯服務
```go
type BranchServiceService struct {
    branchServiceRepo repositories.BranchServiceRepository
    serviceRepo       repositories.ServiceRepository
    branchRepo        repositories.BranchRepository
}

func (s *BranchServiceService) GetBranchAvailableServices(branchID string, businessID string, category *string, includeInactive bool) ([]BranchAvailableService, error) {
    // 驗證門店存在
    branch, err := s.branchRepo.GetByID(branchID)
    if err != nil {
        return nil, errors.New("門店不存在")
    }
    
    if branch.BusinessID != businessID {
        return nil, errors.New("無權限訪問此門店")
    }
    
    // 獲取商家所有服務
    allServices, err := s.serviceRepo.GetByBusinessID(businessID, false) // 不包含已封存
    if err != nil {
        return nil, err
    }
    
    // 按類別過濾
    if category != nil {
        filteredServices := make([]entities.Service, 0)
        for _, service := range allServices {
            if service.Category == *category {
                filteredServices = append(filteredServices, service)
            }
        }
        allServices = filteredServices
    }
    
    // 獲取門店服務配置
    branchServices, err := s.branchServiceRepo.GetByBranchID(branchID)
    if err != nil {
        return nil, err
    }
    
    // 創建服務配置映射
    branchServiceMap := make(map[string]*entities.BranchService)
    for i, bs := range branchServices {
        branchServiceMap[bs.ServiceID] = &branchServices[i]
    }
    
    // 構建響應數據
    result := make([]BranchAvailableService, 0)
    for _, service := range allServices {
        branchService := branchServiceMap[service.ID]
        
        availableService := BranchAvailableService{
            ServiceID:       service.ID,
            ServiceName:     service.Name,
            ServiceCategory: service.Category,
            ServiceDuration: service.Duration,
            DefaultPrice:    service.Price,
            DefaultProfit:   service.Profit,
            IsAvailable:     false,
            CustomPrice:     nil,
            CustomProfit:    nil,
            ActualPrice:     service.Price,
            ActualProfit:    service.Profit,
            BranchServiceID: nil,
        }
        
        if branchService != nil {
            availableService.IsAvailable = branchService.IsAvailable
            availableService.CustomPrice = branchService.CustomPrice
            availableService.CustomProfit = branchService.CustomProfit
            availableService.BranchServiceID = &branchService.ID
            
            // 計算實際價格和利潤
            if branchService.CustomPrice != nil {
                availableService.ActualPrice = *branchService.CustomPrice
            }
            if branchService.CustomProfit != nil {
                availableService.ActualProfit = *branchService.CustomProfit
            }
        }
        
        // 根據 includeInactive 參數決定是否包含未啟用的服務
        if includeInactive || availableService.IsAvailable {
            result = append(result, availableService)
        }
    }
    
    return result, nil
}

func (s *BranchServiceService) UpdateBranchService(branchServiceID string, request UpdateBranchServiceRequest) (*entities.BranchService, error) {
    // 獲取現有的門店服務配置
    branchService, err := s.branchServiceRepo.GetByID(branchServiceID)
    if err != nil {
        return nil, errors.New("門店服務配置不存在")
    }
    
    // 驗證業務邏輯
    if request.CustomPrice != nil && *request.CustomPrice < 0 {
        return nil, errors.New("自訂價格不能為負數")
    }
    
    if request.CustomProfit != nil && request.CustomPrice != nil && *request.CustomProfit > *request.CustomPrice {
        return nil, errors.New("自訂利潤不能超過自訂價格")
    }
    
    // 如果清除自訂價格，也清除自訂利潤
    if request.CustomPrice == nil {
        request.CustomProfit = nil
    }
    
    // 更新字段
    branchService.IsAvailable = request.IsAvailable
    branchService.CustomPrice = request.CustomPrice
    branchService.CustomProfit = request.CustomProfit
    
    return s.branchServiceRepo.Update(branchService)
}
```

### 門店特殊營業日服務
```go
type BranchSpecialDayService struct {
    specialDayRepo repositories.BranchSpecialDayRepository
    branchRepo     repositories.BranchRepository
}

func (s *BranchSpecialDayService) CreateSpecialDay(branchID string, request CreateSpecialDayRequest) (*entities.BranchSpecialDay, error) {
    // 驗證門店存在
    _, err := s.branchRepo.GetByID(branchID)
    if err != nil {
        return nil, errors.New("門店不存在")
    }
    
    // 驗證日期不能是過去
    if request.Date.Before(time.Now().Truncate(24 * time.Hour)) {
        return nil, errors.New("不能設定過去日期的特殊營業日")
    }
    
    // 驗證營業時間邏輯
    if request.IsOpen {
        if request.OperatingHoursStart == nil || request.OperatingHoursEnd == nil {
            return nil, errors.New("營業日必須設定營業時間")
        }
        
        startTime, err := time.Parse("15:04", *request.OperatingHoursStart)
        if err != nil {
            return nil, errors.New("營業開始時間格式錯誤")
        }
        
        endTime, err := time.Parse("15:04", *request.OperatingHoursEnd)
        if err != nil {
            return nil, errors.New("營業結束時間格式錯誤")
        }
        
        if !startTime.Before(endTime) {
            return nil, errors.New("營業開始時間必須早於結束時間")
        }
    }
    
    // 檢查該日期是否已有設定
    existing, _ := s.specialDayRepo.GetByBranchIDAndDate(branchID, request.Date)
    if existing != nil {
        return nil, errors.New("該日期已有特殊營業日設定，請使用更新功能")
    }
    
    // 創建特殊營業日
    specialDay := &entities.BranchSpecialDay{
        ID:                  GenerateID(),
        BranchID:            branchID,
        Date:                request.Date,
        IsOpen:              request.IsOpen,
        OperatingHoursStart: request.OperatingHoursStart,
        OperatingHoursEnd:   request.OperatingHoursEnd,
        Reason:              request.Reason,
    }
    
    return s.specialDayRepo.Create(specialDay)
}

func (s *BranchSpecialDayService) GetSpecialDaysByBranch(branchID string, date *time.Time) ([]entities.BranchSpecialDay, error) {
    if date != nil {
        // 獲取特定日期的特殊營業日
        specialDay, err := s.specialDayRepo.GetByBranchIDAndDate(branchID, *date)
        if err != nil {
            return []entities.BranchSpecialDay{}, nil // 該日期沒有特殊設定
        }
        return []entities.BranchSpecialDay{*specialDay}, nil
    }
    
    // 獲取所有特殊營業日 (未來30天)
    startDate := time.Now().Truncate(24 * time.Hour)
    endDate := startDate.AddDate(0, 0, 30)
    
    return s.specialDayRepo.GetByBranchIDAndDateRange(branchID, startDate, endDate)
}
```

## 🐘 數據庫設計

### PostgreSQL 表創建 SQL
```sql
-- 用戶表
CREATE TABLE users (
    id VARCHAR(36) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(50) DEFAULT 'admin',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 商家表
CREATE TABLE businesses (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL REFERENCES users(id),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    address TEXT,
    phone VARCHAR(50),
    email VARCHAR(255),
    logo_url TEXT,
    social_links TEXT,
    tax_id VARCHAR(50),
    google_id VARCHAR(100),
    timezone VARCHAR(50) DEFAULT 'Asia/Taipei',
    last_login_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 門店表
CREATE TABLE branches (
    id VARCHAR(36) PRIMARY KEY,
    business_id VARCHAR(36) NOT NULL REFERENCES businesses(id),
    name VARCHAR(255) NOT NULL,
    contact_phone VARCHAR(50),
    address TEXT,
    is_default BOOLEAN DEFAULT FALSE,
    status VARCHAR(20) DEFAULT 'active',
    operating_hours_start VARCHAR(10),
    operating_hours_end VARCHAR(10),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 服務表
CREATE TABLE services (
    id VARCHAR(36) PRIMARY KEY,
    business_id VARCHAR(36) NOT NULL REFERENCES businesses(id),
    name VARCHAR(255) NOT NULL,
    category VARCHAR(50) NOT NULL,
    duration INTEGER NOT NULL,
    revisit_period INTEGER NOT NULL DEFAULT 30,
    price DECIMAL(10,2) NOT NULL,
    profit DECIMAL(10,2) NOT NULL DEFAULT 0,
    description TEXT,
    is_archived BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 員工表
CREATE TABLE staff (
    id VARCHAR(36) PRIMARY KEY,
    business_id VARCHAR(36) NOT NULL REFERENCES businesses(id),
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
    branch_ids TEXT[],
    service_ids TEXT[],
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 客戶表
CREATE TABLE customers (
    id VARCHAR(36) PRIMARY KEY,
    business_id VARCHAR(36) NOT NULL REFERENCES businesses(id),
    name VARCHAR(255) NOT NULL,
    gender VARCHAR(10),
    phone VARCHAR(50),
    email VARCHAR(255),
    is_archived BOOLEAN DEFAULT FALSE,
    needs_merge BOOLEAN DEFAULT FALSE,
    is_special_customer BOOLEAN DEFAULT FALSE,
    source VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 預約表
CREATE TABLE appointments (
    id VARCHAR(36) PRIMARY KEY,
    business_id VARCHAR(36) NOT NULL REFERENCES businesses(id),
    branch_id VARCHAR(36) NOT NULL REFERENCES branches(id),
    customer_id VARCHAR(36) NOT NULL REFERENCES customers(id),
    service_id VARCHAR(36) NOT NULL REFERENCES services(id),
    staff_id VARCHAR(36) REFERENCES staff(id),
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL,
    status VARCHAR(20) DEFAULT 'booked',
    note TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 訂閱方案表
CREATE TABLE subscription_plans (
    id VARCHAR(36) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    display_name VARCHAR(100) NOT NULL,
    price_per_staff DECIMAL(10,2) NOT NULL,
    max_branches INTEGER,
    features TEXT[],
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 訂閱表
CREATE TABLE subscriptions (
    id VARCHAR(36) PRIMARY KEY,
    business_id VARCHAR(36) NOT NULL REFERENCES businesses(id),
    plan_id VARCHAR(36) NOT NULL REFERENCES subscription_plans(id),
    status VARCHAR(20) DEFAULT 'active',
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    cancelled_date DATE,
    staff_count INTEGER NOT NULL,
    monthly_amount DECIMAL(10,2) NOT NULL,
    auto_renewal BOOLEAN DEFAULT TRUE,
    metadata TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 帳單表
CREATE TABLE billings (
    id VARCHAR(36) PRIMARY KEY,
    business_id VARCHAR(36) NOT NULL REFERENCES businesses(id),
    subscription_id VARCHAR(36) NOT NULL REFERENCES subscriptions(id),
    billing_date DATE NOT NULL,
    due_date DATE NOT NULL,
    paid_date DATE,
    status VARCHAR(20) DEFAULT 'pending',
    amount DECIMAL(10,2) NOT NULL,
    tax_amount DECIMAL(10,2) DEFAULT 0,
    total_amount DECIMAL(10,2) NOT NULL,
    payment_method VARCHAR(50),
    payment_reference VARCHAR(100),
    staff_count INTEGER NOT NULL,
    plan_name VARCHAR(100) NOT NULL,
    price_per_staff DECIMAL(10,2) NOT NULL,
    notes TEXT,
    metadata TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 郵件驗證表
CREATE TABLE email_verifications (
    id VARCHAR(36) PRIMARY KEY,
    email VARCHAR(255) NOT NULL,
    code VARCHAR(6) NOT NULL,
    type VARCHAR(20) NOT NULL,
    is_verified BOOLEAN DEFAULT FALSE,
    is_used BOOLEAN DEFAULT FALSE,
    expires_at TIMESTAMP NOT NULL,
    verified_at TIMESTAMP,
    ip_address VARCHAR(45),
    user_agent TEXT,
    attempt_count INTEGER DEFAULT 0,
    last_attempt_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 郵件發送記錄表
CREATE TABLE email_send_records (
    id VARCHAR(36) PRIMARY KEY,
    email VARCHAR(255) NOT NULL,
    type VARCHAR(20) NOT NULL,
    subject VARCHAR(255) NOT NULL,
    status VARCHAR(20) DEFAULT 'pending',
    provider VARCHAR(50) NOT NULL,
    provider_id VARCHAR(255),
    error_message TEXT,
    sent_at TIMESTAMP,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 門店服務關聯表 (更新)
CREATE TABLE branch_services (
    id VARCHAR(36) PRIMARY KEY,
    branch_id VARCHAR(36) NOT NULL REFERENCES branches(id),
    service_id VARCHAR(36) NOT NULL REFERENCES services(id),
    is_available BOOLEAN DEFAULT TRUE,
    custom_price DECIMAL(10,2),
    custom_profit DECIMAL(10,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(branch_id, service_id)
);

-- 門店營業時間表 (新增)
CREATE TABLE branch_operating_hours (
    id VARCHAR(36) PRIMARY KEY,
    branch_id VARCHAR(36) NOT NULL REFERENCES branches(id),
    day_of_week INTEGER NOT NULL CHECK (day_of_week >= 0 AND day_of_week <= 6),
    is_open BOOLEAN DEFAULT TRUE,
    open_time VARCHAR(5), -- HH:MM format
    close_time VARCHAR(5), -- HH:MM format
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(branch_id, day_of_week)
);

-- 門店特殊營業日表 (修正)
CREATE TABLE branch_special_days (
    id VARCHAR(36) PRIMARY KEY,
    branch_id VARCHAR(36) NOT NULL REFERENCES branches(id),
    date DATE NOT NULL,
    is_open BOOLEAN NOT NULL,
    operating_hours_start VARCHAR(5), -- HH:MM format
    operating_hours_end VARCHAR(5), -- HH:MM format
    reason TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(branch_id, date)
);

-- 創建索引
CREATE INDEX idx_appointments_start_time ON appointments(start_time);
CREATE INDEX idx_appointments_business_branch ON appointments(business_id, branch_id);
CREATE INDEX idx_appointments_staff_time ON appointments(staff_id, start_time, end_time);
CREATE INDEX idx_customers_business ON customers(business_id);
CREATE INDEX idx_staff_business ON staff(business_id);
CREATE INDEX idx_services_business ON services(business_id);
CREATE INDEX idx_email_verifications_email ON email_verifications(email);
CREATE INDEX idx_email_verifications_code ON email_verifications(email, code, type);
CREATE INDEX idx_email_verifications_expires ON email_verifications(expires_at);
CREATE INDEX idx_email_send_records_email ON email_send_records(email, type);
CREATE INDEX idx_email_send_records_created ON email_send_records(created_at);
CREATE INDEX idx_branch_services_branch ON branch_services(branch_id);
CREATE INDEX idx_branch_services_service ON branch_services(service_id);
CREATE INDEX idx_branch_operating_hours_branch ON branch_operating_hours(branch_id);
CREATE INDEX idx_branch_operating_hours_day ON branch_operating_hours(branch_id, day_of_week);
CREATE INDEX idx_branch_special_days_branch ON branch_special_days(branch_id);
CREATE INDEX idx_branch_special_days_date ON branch_special_days(branch_id, date);

-- 初始化默認訂閱方案
INSERT INTO subscription_plans (id, name, display_name, price_per_staff, max_branches, features, description, is_active, created_at, updated_at) VALUES
('plan_basic', 'Basic', '基礎方案', 299.00, 2, 
 ARRAY['基礎預約管理', '客戶管理', '服務管理', '基礎報表', '2個門店'], 
 '適合小型美業商家的基礎功能', true, NOW(), NOW()),
 
('plan_business', 'Business', '商業方案', 499.00, NULL, 
 ARRAY['完整預約管理', '客戶管理', '服務管理', '員工管理', '進階報表', '無限門店', 'AI助理', '庫存管理'], 
 '適合中大型美業商家的完整功能', true, NOW(), NOW());

-- 創建觸發器自動更新 updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 為所有表創建更新觸發器
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_businesses_updated_at BEFORE UPDATE ON businesses FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_branches_updated_at BEFORE UPDATE ON branches FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_services_updated_at BEFORE UPDATE ON services FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_staff_updated_at BEFORE UPDATE ON staff FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_customers_updated_at BEFORE UPDATE ON customers FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_appointments_updated_at BEFORE UPDATE ON appointments FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_subscription_plans_updated_at BEFORE UPDATE ON subscription_plans FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_subscriptions_updated_at BEFORE UPDATE ON subscriptions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_billings_updated_at BEFORE UPDATE ON billings FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_email_verifications_updated_at BEFORE UPDATE ON email_verifications FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_email_send_records_updated_at BEFORE UPDATE ON email_send_records FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_branch_services_updated_at BEFORE UPDATE ON branch_services FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_branch_operating_hours_updated_at BEFORE UPDATE ON branch_operating_hours FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_branch_special_days_updated_at BEFORE UPDATE ON branch_special_days FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 自動清理過期驗證記錄的定時任務 (每小時執行一次)
CREATE OR REPLACE FUNCTION cleanup_expired_verifications()
RETURNS void AS $$
BEGIN
    DELETE FROM email_verifications 
    WHERE expires_at < NOW() - INTERVAL '24 hours';
    
    DELETE FROM email_send_records 
    WHERE created_at < NOW() - INTERVAL '30 days';
END;
$$ LANGUAGE plpgsql;

-- 創建定時任務 (需要 pg_cron 擴展)
-- SELECT cron.schedule('cleanup-verifications', '0 * * * *', 'SELECT cleanup_expired_verifications();');

-- 初始化默認門店營業時間數據
INSERT INTO branch_operating_hours (id, branch_id, day_of_week, is_open, open_time, close_time, created_at, updated_at)
SELECT 
    gen_random_uuid()::text,
    b.id,
    generate_series(0, 6) as day_of_week,
    true,
    b.operating_hours_start,
    b.operating_hours_end,
    NOW(),
    NOW()
FROM branches b
WHERE b.operating_hours_start IS NOT NULL AND b.operating_hours_end IS NOT NULL;

-- 為新門店自動創建默認營業時間的觸發器函數
CREATE OR REPLACE FUNCTION create_default_operating_hours()
RETURNS TRIGGER AS $$
BEGIN
    -- 為新創建的門店生成默認營業時間（週一到週日）
    INSERT INTO branch_operating_hours (id, branch_id, day_of_week, is_open, open_time, close_time, created_at, updated_at)
    SELECT 
        gen_random_uuid()::text,
        NEW.id,
        generate_series(0, 6),
        true,
        COALESCE(NEW.operating_hours_start, '09:00'),
        COALESCE(NEW.operating_hours_end, '18:00'),
        NOW(),
        NOW();
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 創建觸發器
CREATE TRIGGER trigger_create_default_operating_hours
    AFTER INSERT ON branches
    FOR EACH ROW
    EXECUTE FUNCTION create_default_operating_hours();

-- 自動清理過期特殊營業日的定時任務
CREATE OR REPLACE FUNCTION cleanup_expired_special_days()
RETURNS void AS $$
BEGIN
    DELETE FROM branch_special_days 
    WHERE date < CURRENT_DATE - INTERVAL '30 days';
END;
$$ LANGUAGE plpgsql;

-- 創建定時任務 (需要 pg_cron 擴展)
-- SELECT cron.schedule('cleanup-special-days', '0 2 * * *', 'SELECT cleanup_expired_special_days();');
```

## 🚀 部署配置

### 環境變數配置 (更新)
```bash
# 數據庫配置
DATABASE_DSN=postgres://user:password@db:5432/beautyai?sslmode=disable

# Redis 配置
REDIS_URL=redis://redis:6379

# JWT 配置
JWT_SECRET=your-super-secret-jwt-key

# 郵件服務配置
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASSWORD=your-app-password
FROM_EMAIL=noreply@beautyai.com
FROM_NAME=BeautyAI Team

# 服務配置
SERVER_PORT=8080
ENVIRONMENT=production

# 安全配置
ALLOWED_ORIGINS=https://beautyai.com,https://www.beautyai.com
RATE_LIMIT_REQUESTS=100
RATE_LIMIT_WINDOW=60
```

### Docker Compose (更新)
```yaml
version: '3.8'

services:
  app:
    build: .
    ports:
      - "8080:8080"
    environment:
      - DATABASE_DSN=postgres://user:password@db:5432/beautyai?sslmode=disable
      - REDIS_URL=redis://redis:6379
      - JWT_SECRET=your-super-secret-jwt-key
      - SMTP_HOST=smtp.gmail.com
      - SMTP_PORT=587
      - SMTP_USER=${SMTP_USER}
      - SMTP_PASSWORD=${SMTP_PASSWORD}
      - FROM_EMAIL=noreply@beautyai.com
      - FROM_NAME=BeautyAI Team
    depends_on:
      - db
      - redis

  db:
    image: postgres:15
    environment:
      - POSTGRES_DB=beautyai
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=password
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./scripts/init.sql:/docker-entrypoint-initdb.d/init.sql
    ports:
      - "5432:5432"

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

volumes:
  postgres_data:
```

## 📊 API 響應格式

### 統一響應結構
```go
type Response struct {
    Code    int         `json:"code"`
    Message string      `json:"message"`
    Data    interface{} `json:"data,omitempty"`
}

type PaginatedResponse struct {
    Code       int         `json:"code"`
    Message    string      `json:"message"`
    Data       interface{} `json:"data"`
    Pagination Pagination  `json:"pagination"`
}

type Pagination struct {
    Page       int   `json:"page"`
    Size       int   `json:"size"`
    Total      int64 `json:"total"`
    TotalPages int   `json:"total_pages"`
}
```

### 錯誤響應
```go
type ErrorResponse struct {
    Code    int                    `json:"code"`
    Message string                 `json:"message"`
    Errors  map[string]interface{} `json:"errors,omitempty"`
}
```

## 🔐 安全考量

1. **認證**: JWT Token 認證 + 郵件驗證雙重保護
2. **授權**: 基於角色的訪問控制
3. **資料驗證**: 輸入驗證和清理
4. **SQL 注入防護**: 使用 GORM 參數化查詢
5. **速率限制**: API 請求頻率限制 + 郵件發送限制
6. **CORS**: 跨域請求配置
7. **HTTPS**: 生產環境強制使用
8. **敏感資料**: 密碼加密存儲
9. **郵件安全**: 
   - 驗證碼有效期限制 (10分鐘)
   - 發送頻率限制 (60秒間隔)
   - 驗證碼嘗試次數限制
   - IP地址和User-Agent記錄
   - 驗證Token有效期限制 (30分鐘)
10. **數據清理**: 自動清理過期驗證記錄
11. **監控和日誌**: 郵件發送狀態追蹤和錯誤記錄

### 郵件驗證安全特性

#### 防爆破攻擊
- 同一郵箱60秒內只能發送一次驗證碼
- 驗證碼10分鐘有效期
- 記錄嘗試次數和IP地址
- 超過5次錯誤嘗試自動鎖定

#### 防重放攻擊
- 驗證Token一次性使用
- 驗證碼使用後立即標記為已使用
- 嚴格的時間戳驗證

#### 隱私保護
- 驗證碼通過安全郵件通道傳輸
- 數據庫中不存儲明文驗證碼 (可選加鹽雜湊)
- 自動清理過期記錄

### 郵件服務配置建議

#### Gmail SMTP 配置
```bash
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
# 使用應用專用密碼，非帳戶密碼
SMTP_PASSWORD=your-16-char-app-password
```

#### SendGrid 配置 (推薦生產環境)
```bash
SMTP_HOST=smtp.sendgrid.net
SMTP_PORT=587
SMTP_USER=apikey
SMTP_PASSWORD=your-sendgrid-api-key
```

#### 自定義 SMTP 服務器
```bash
SMTP_HOST=mail.yourdomain.com
SMTP_PORT=587
SMTP_USER=noreply@yourdomain.com
SMTP_PASSWORD=your-smtp-password
```

#### 門店可用服務列表 API 詳細規格

**端點**: `GET /api/v1/branches/:id/available-services`

**查詢參數**:
- `business_id` (required): 商家ID
- `category` (optional): 服務類別過濾
- `include_inactive` (optional): 是否包含未啟用的服務，默認false

**成功響應**:
```go
type BranchAvailableServicesResponse struct {
    Code    int      `json:"code"`
    Message string   `json:"message"`
    Data    []BranchAvailableService `json:"data"`
}

type BranchAvailableService struct {
    ServiceID        string  `json:"service_id"`
    ServiceName      string  `json:"service_name"`
    ServiceCategory  string  `json:"service_category"`
    ServiceDuration  int     `json:"service_duration"`
    DefaultPrice     float64 `json:"default_price"`
    DefaultProfit    float64 `json:"default_profit"`
    IsAvailable      bool    `json:"is_available"`
    CustomPrice      *float64 `json:"custom_price"`
    CustomProfit     *float64 `json:"custom_profit"`
    ActualPrice      float64 `json:"actual_price"`      // 實際價格 (custom_price || default_price)
    ActualProfit     float64 `json:"actual_profit"`     // 實際利潤 (custom_profit || default_profit)
    BranchServiceID  *string `json:"branch_service_id"` // 門店服務關聯ID，null表示未設置
}
```

**業務邏輯**:
1. 查詢商家所有服務
2. 查詢門店的服務配置
3. 合併數據，返回每個服務在該門店的可用狀態和價格設定
4. 計算實際價格和利潤

#### 門店營業時間管理 API 詳細規格

**端點**: `GET /api/v1/branches/:id/operating-hours`

**成功響應**:
```go
type BranchOperatingHoursResponse struct {
    Code    int                      `json:"code"`
    Message string                   `json:"message"`
    Data    []BranchOperatingHours   `json:"data"`
}

type BranchOperatingHoursData struct {
    BranchID  string                     `json:"branch_id"`
    BranchName string                    `json:"branch_name"`
    WeeklyHours []DayOperatingHours      `json:"weekly_hours"`
}

type DayOperatingHours struct {
    DayOfWeek int     `json:"day_of_week"` // 0=Sunday, 1=Monday, ..., 6=Saturday
    DayName   string  `json:"day_name"`    // "Sunday", "Monday", etc.
    IsOpen    bool    `json:"is_open"`
    OpenTime  *string `json:"open_time"`   // "09:00"
    CloseTime *string `json:"close_time"`  // "18:00"
}
```

**端點**: `PUT /api/v1/branches/:id/operating-hours`

**請求格式**:
```go
type UpdateOperatingHoursRequest struct {
    WeeklyHours []DayOperatingHoursUpdate `json:"weekly_hours" validate:"required,len=7"`
}

type DayOperatingHoursUpdate struct {
    DayOfWeek int     `json:"day_of_week" validate:"required,min=0,max=6"`
    IsOpen    bool    `json:"is_open"`
    OpenTime  *string `json:"open_time" validate:"omitempty,datetime=15:04"`
    CloseTime *string `json:"close_time" validate:"omitempty,datetime=15:04"`
}
```

**業務邏輯**:
1. 驗證每週7天的時間設定
2. 檢查開店時間早於關店時間
3. 更新或創建門店營業時間記錄
4. 自動生成每週重複模式

#### 門店特殊營業日 API 更新規格

**端點**: `POST /api/v1/branches/:id/special-days`

**請求格式**:
```go
type CreateSpecialDayRequest struct {
    Date                time.Time `json:"date" validate:"required"`
    IsOpen              bool      `json:"is_open"`
    OperatingHoursStart *string   `json:"operating_hours_start" validate:"omitempty,datetime=15:04"`
    OperatingHoursEnd   *string   `json:"operating_hours_end" validate:"omitempty,datetime=15:04"`
    Reason              *string   `json:"reason"`
}
```

**成功響應**:
```go
type SpecialDayResponse struct {
    Code    int                `json:"code"`
    Message string             `json:"message"`
    Data    BranchSpecialDay   `json:"data"`
}
```

**業務邏輯**:
1. 檢查日期不能是過去日期
2. 如果 `is_open` 為 true，必須提供營業時間
3. 如果 `is_open` 為 false，可選提供休息原因
4. 檢查該日期是否已有特殊設定 (更新而非新增)

#### 門店服務配置更新 API 規格

**端點**: `PUT /api/v1/branch-services/:id`

**請求格式**:
```go
type UpdateBranchServiceRequest struct {
    IsAvailable  bool     `json:"is_available"`
    CustomPrice  *float64 `json:"custom_price"`
    CustomProfit *float64 `json:"custom_profit"`
}
```

**業務邏輯**:
1. 驗證自訂價格不能為負數
2. 驗證自訂利潤不能超過自訂價格
3. 如果 `custom_price` 為 null，自動清除 `custom_profit`
4. 更新門店服務配置

// ... existing code ...