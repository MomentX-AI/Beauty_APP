# BeautyAIGO API 文檔

這個目錄包含了BeautyAIGO API的所有文檔，方便前端開發人員整合和使用API。

## 文檔目錄

1. [API路由列表](routes.md) - 所有可用API端點的詳細列表
2. [API請求/響應示例](examples.md) - 常用API端點的請求和響應示例
3. [API整合指南](integration_guide.md) - 前端應用程序與API整合的最佳實踐和指導

## 快速開始

1. 確保API服務器正在運行
2. 使用以下基礎URL訪問API端點：
   - 生產環境：`https://api.beautyaigo.com/api/v1`
   - 開發環境：`http://localhost:8080/api/v1`
3. 所有API請求和響應都使用JSON格式
4. 大多數API端點需要JWT身份驗證（通過`/api/v1/auth/login`獲取）

## 技術支持

如有技術問題，請聯繫開發團隊：dev@beautyaigo.com 

## 近期新增

- 分店營業時間（branches 新增 operating_hours_start/end 欄位）
- 分店特殊營業日（branch_special_operating_days CRUD）

詳細 API 路由與範例請見：
- [routes.md](routes.md)
- [examples.md](examples.md) 