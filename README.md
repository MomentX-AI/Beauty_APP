# BeautyAIGO 美容管理系統

美容管理系統是一款專為美容沙龍和美容業者設計的Flutter應用，提供完整的美容業務管理解決方案。

## 功能概述

- **儀表板**：業務數據概覽和重要指標
- **預約管理**：客戶預約排程和管理
- **客戶管理**：客戶資料和服務歷史記錄
- **服務管理**：美容服務項目管理和定價
- **業務分析報告**：銷售、客戶和業務表現分析
- **AI 助理**：智能業務推薦和決策支持

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

## 專案結構

```
lib/
  ├── components/    # 通用UI組件
  ├── models/        # 數據模型
  ├── screens/       # 應用界面
  ├── services/      # API和業務邏輯服務
  ├── widgets/       # 可重用UI小部件
  └── main.dart      # 應用入口點
```

## API 文檔

API 相關文檔位於 `docs/api/` 目錄，包括：
- API路由列表
- 請求/響應示例
- API整合指南

## 技術堆疊

- **Frontend**: Flutter, Dart
- **圖表和數據可視化**: fl_chart
- **日期和日曆**: table_calendar, intl
- **媒體管理**: image_picker
- **其他工具**: uuid, path

## 開發團隊

有任何技術問題，請聯繫開發團隊：dev@beautyaigo.com
