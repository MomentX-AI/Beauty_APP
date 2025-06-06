# 變更日誌

## 2024-12-19 - 命名統一化更新

### 主要變更
- 將所有"分店"相關命名統一改為"門店"
- 重新組織服務管理功能結構
- 新增服務項目總覽功能
- 創建專門的門店設置界面

### 具體修改

#### 1. 界面標籤重命名
- "服務項目" → "服務項目總覽" (顯示所有門店的服務使用情況)
- "分店服務" → "門店服務"
- "商家設定" → "門店設置" (用於設定門店基本信息)
- "分店設定" → "門店管理" (用於管理門店營業時間和特殊營業日)

#### 2. 界面標題更新
- `BranchServiceScreen`: "分店服務管理" → "門店服務管理"
- `BranchSettingsScreen`: "分店設定" → "門店管理"

#### 3. 用戶界面文字更新
- "選擇分店" → "選擇門店"
- "請先選擇分店" → "請先選擇門店"
- "所有服務項目都已添加到此分店" → "所有服務項目都已添加到此門店"
- "確定要從分店「XXX」移除服務" → "確定要從門店「XXX」移除服務"
- "編輯分店服務" → "編輯門店服務"
- "新增分店服務" → "新增門店服務"
- "為此分店設定特殊價格" → "為此門店設定特殊價格"
- "載入分店資料失敗" → "載入門店資料失敗"

#### 4. 模擬數據更新
- "信義分店" → "信義門店"
- "西門分店" → "西門門店"
- 註釋中的"分店"改為"門店"

#### 5. 文檔更新
- README.md 中的功能描述更新
- 數據模型描述更新
- 組件描述更新

### 功能結構重組
1. **服務項目總覽**: 查看所有門店的服務項目使用情況，支持搜尋和篩選
2. **門店服務**: 為每個門店設定可用的服務項目，支持自訂價格
3. **門店設置**: 設定門店基本信息（名稱、電話、地址等）
4. **門店管理**: 管理門店營業時間和特殊營業日

### 新增功能

#### 服務項目總覽
- 顯示所有服務項目及其在各門店的使用情況
- 可展開查看每個服務在各門店的詳細配置
- 支持按服務名稱和描述搜尋
- 支持按服務類別篩選
- 顯示門店使用統計（如：3/5 門店）
- 顯示自訂價格標識

#### 門店設置界面
- 專門的門店基本信息管理界面
- 支持編輯門店名稱、聯絡電話、地址
- 顯示門店狀態（營業中/暫停營業）
- 支持新增和刪除門店（總店不可刪除）
- 與門店管理界面的門店列表保持一致

### 技術細節
- 保持所有API接口和數據模型不變
- 僅更新用戶界面顯示文字
- 維持現有功能邏輯完整性 