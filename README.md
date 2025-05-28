# BeautyAIGO 美容管理系統

美容管理系統是一款專為美容沙龍和美容業者設計的Flutter應用，提供完整的美容業務管理解決方案。

## 功能概述

- **儀表板**：業務數據概覽和重要指標
- **預約管理**：客戶預約排程和管理
- **客戶管理**：客戶資料和服務歷史記錄
- **服務管理**：美容服務項目管理和定價
- **業務分析報告**：銷售、客戶和業務表現分析
- **AI 助理**：智能業務推薦和決策支持
- **用戶管理**：用戶註冊、登入和權限管理

## 功能實作進度

| 功能模塊 | 狀態 | 實作程度 |
|---------|------|---------|
| 登入/註冊 | ✅ 完成 | 具備基本的表單驗證，使用模擬數據服務 |
| 儀表板導航 | ✅ 完成 | 包含側邊欄及所有功能模塊入口，支持折疊展開 |
| AI 助理 | ✅ 完成 | 實現基本對話功能，支持預約查詢、客戶信息查詢和快速回复 |
| 預約管理 | ✅ 完成 | 預約列表展示、新增預約表單 |
| 服務管理 | ✅ 完成 | 服務項目列表、新增/編輯服務 |
| 門店服務管理 | ✅ 完成 | 可選擇門店並為每個門店設定服務項目，支持自訂價格 |
| 客戶管理 | ✅ 完成 | 客戶列表、詳細信息查看 |
| 業務報表 | ✅ 完成 | 營收報表、客戶分析圖表 |
| 主理人資料 | ✅ 完成 | 商家資料編輯、營業目標設定 |

## 系統架構

### 數據模型

目前實現的數據模型包括：
- `Appointment`: 客戶預約
- `Business`: 商家信息
- `Branch`: 門店信息
- `BranchService`: 門店服務關聯
- `BranchSpecialDay`: 門店特殊營業日
- `BusinessAnalysis`: 業務分析數據
- `BusinessGoal`: 業務目標
- `Customer`: 客戶資料
- `Service`: 服務項目
- `ServiceHistory`: 服務歷史記錄
- `User`: 用戶資料

### 模擬數據

系統提供豐富的模擬數據供開發測試使用：
- **6 個門店**: 涵蓋不同地區和客群定位（總店、信義、西門、板橋、天母、內湖）
- **26 項服務**: 包含美髮、美甲、睫毛、護膚、半永久化妝、其他等 6 大類別
- **99 個門店服務配置**: 每個門店都有不同的服務組合和定價策略

詳細的模擬數據說明請參考 [模擬數據指南](docs/mock_data_guide.md)。

### 服務層

- `AuthService`: 處理用戶認證和身份驗證
- `MockApiService`: 模擬API服務，用於開發階段
- `MockDataService`: 提供模擬數據

### 組件層

- `AppointmentFormDialog`: 預約表單彈窗組件
- `BranchServiceFormDialog`: 門店服務表單彈窗組件
- `ServiceFormDialog`: 服務項目表單彈窗組件

## 系統需求

- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- 支持 iOS、Android、Web、macOS、Windows 和 Linux

## 開始使用

### 安裝

1. 確保已安裝 Flutter 開發環境：
   ```
   flutter doctor
   ```

2. 複製專案：
   ```
   git clone https://github.com/yourusername/BeautyAI_Front.git
   cd BeautyAI_Front
   ```

3. 安裝依賴：
   ```
   flutter pub get
   ```

4. 執行應用：
   ```
   flutter run
   ```

### 配置

編輯 `lib/services/mock_api_service.dart` 連接到正確的 API 後端：

- 開發環境：`http://localhost:8080/api/v1`
- 生產環境：`https://api.beautyaigo.com/api/v1`

### 帳號管理

- **登入**：使用現有帳號登入系統
- **註冊**：新用戶可以自行註冊帳號，提供姓名、店家名稱、電子郵件和密碼
- **測試帳號**：
  - 管理員：admin@beauty.com / 123456
  - 員工：staff@beauty.com / 123456

## 專案結構

```
lib/
  ├── components/    # 通用UI組件
  ├── models/        # 數據模型
  ├── screens/       # 應用界面
  ├── services/      # API和業務邏輯服務
  ├── widgets/       # 可重用UI小部件
  ├── routes/        # 路由配置
  └── main.dart      # 應用入口點
```

## 依賴項

- **UI和交互**: 
  - Flutter Material Design
  - cupertino_icons: ^1.0.2
- **路由管理**: 
  - go_router: ^14.6.2
- **圖表和數據可視化**: 
  - fl_chart: ^0.66.2
- **日期和日曆**: 
  - table_calendar: ^3.1.3
  - intl: ^0.19.0
- **媒體管理**: 
  - image_picker: ^1.0.7
- **其他工具**: 
  - uuid: ^4.3.3
  - path: ^1.8.3

## 技術堆疊

- **前端框架**: Flutter, Dart
- **路由管理**: go_router
- **UI組件**: Material Design, Cupertino Icons
- **圖表和數據可視化**: fl_chart
- **日期和日曆**: table_calendar, intl
- **媒體管理**: image_picker
- **開發工具**: flutter_lints

## 開發團隊

有任何技術問題，請聯繫開發團隊：dev@beautyaigo.com

## 後續開發計劃

- 整合真實API後端
- 改進AI助理功能，增加更多智能推薦
- 優化UI/UX設計
- 實現通知系統
- 多語言支持
- 雲端同步備份
- 實現離線模式
- 優化性能
- 增加更多數據分析功能
