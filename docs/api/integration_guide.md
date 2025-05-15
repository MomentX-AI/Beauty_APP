# BeautyAIGO API 整合指南

本文檔提供了前端應用程序與BeautyAIGO API整合的最佳實踐和指導。

## 基本設置

### 基礎URL
所有API請求都應該使用以下基礎URL：

```
https://api.beautyaigo.com/api/v1
```

對於本地開發環境，使用：

```
http://localhost:8080/api/v1
```

### 內容類型
所有API請求和響應均使用JSON格式。每個請求都應包含以下標頭：

```
Content-Type: application/json
Accept: application/json
```

## 身份驗證流程

BeautyAIGO API使用JWT（JSON Web Token）進行身份驗證。

### 1. 註冊和登錄

1. 用戶註冊：使用 `POST /auth/register` 創建新賬戶
2. 用戶登錄：使用 `POST /auth/login` 獲取JWT令牌
3. 存儲令牌：在前端安全地存儲JWT令牌（如localStorage或更安全的方式）

### 2. 使用令牌進行身份驗證

所有已驗證的API請求都應在HTTP標頭中包含JWT令牌：

```
Authorization: Bearer YOUR_JWT_TOKEN
```

### 3. 處理令牌過期

JWT令牌有有效期。當令牌過期時，API會返回401 Unauthorized錯誤。前端應處理此錯誤並引導用戶重新登錄。

## 業務上下文

BeautyAIGO是一個多租戶系統，大多數操作都在特定業務上下文中執行。

### 業務選擇

1. 用戶登錄後，使用 `GET /businesses` 獲取用戶可訪問的業務列表
2. 用戶選擇一個業務後，前端應存儲當前業務ID並在相關API請求中使用它
3. 對於涉及分店、團隊成員等實體的操作，始終使用業務ID或分店ID作為查詢參數

## 錯誤處理

### 統一錯誤處理

建立一個統一的錯誤處理機制，能夠：

1. 解析API錯誤響應中的錯誤信息
2. 顯示用戶友好的錯誤消息
3. 處理特定錯誤情況（如身份驗證失敗、權限不足、資源未找到等）

### 示例錯誤處理函數

```javascript
async function callApi(url, options = {}) {
  try {
    // 確保包含認證標頭
    const headers = {
      'Content-Type': 'application/json',
      ...options.headers
    };
    
    if (localStorage.getItem('jwt_token')) {
      headers['Authorization'] = `Bearer ${localStorage.getItem('jwt_token')}`;
    }
    
    const response = await fetch(url, {
      ...options,
      headers
    });
    
    // 檢查HTTP狀態
    if (!response.ok) {
      const errorData = await response.json();
      throw {
        status: response.status,
        message: errorData.error || '發生未知錯誤',
        data: errorData
      };
    }
    
    return await response.json();
  } catch (error) {
    // 處理特定錯誤
    if (error.status === 401) {
      // 清除過期的令牌並重定向到登錄頁面
      localStorage.removeItem('jwt_token');
      window.location.href = '/login';
    }
    
    // 重新拋出錯誤供組件處理
    throw error;
  }
}
```

## 分頁處理

許多GET請求支持分頁。前端應該：

1. 處理分頁響應中的 `pagination` 對象
2. 實現分頁控件以允許用戶導航多頁結果
3. 允許用戶調整每頁項目數（通過 `per_page` 參數）

### 示例分頁組件

```jsx
function PaginationControls({ pagination, onPageChange }) {
  return (
    <div className="pagination">
      <button 
        disabled={pagination.current_page <= 1}
        onClick={() => onPageChange(pagination.current_page - 1)}
      >
        上一頁
      </button>
      
      <span>
        第 {pagination.current_page} 頁，共 {pagination.total_pages} 頁
      </span>
      
      <button 
        disabled={pagination.current_page >= pagination.total_pages}
        onClick={() => onPageChange(pagination.current_page + 1)}
      >
        下一頁
      </button>
    </div>
  );
}
```

## 狀態管理

對於複雜的前端應用，建議使用狀態管理庫（如Redux、Vuex或MobX）來管理：

1. 用戶認證狀態和JWT令牌
2. 當前選定的業務和分店
3. 已獲取的數據（用戶、角色、權限等）

## 實時數據

BeautyAIGO API目前不提供WebSocket或其他實時數據功能。前端應實現適當的輪詢策略或用戶觸發的刷新機制來保持數據最新。

## API版本控制

API URL中包含版本號（`/api/v1/`）。未來的API版本可能會使用新的版本路徑。請設計前端應用程序以支持API版本切換。

## 支持與幫助

如果您遇到API整合問題，請聯繫我們的開發團隊：

- Email: dev@beautyaigo.com
- 開發者社區: https://community.beautyaigo.com

## 分店營業時間與特殊營業日（新功能）

- 分店（Branch）物件新增 `operating_hours_start`、`operating_hours_end` 欄位，格式為 HH:MM（如 "09:00"）。
- 特殊營業日（BranchSpecialOperatingDay）API 支援 CRUD，需傳入 branch_id、date、is_open、operating_hours_start/end、reason。
- 查詢分店時，前端應顯示並允許編輯營業時間。
- 查詢特殊營業日時，前端可根據 is_open 與營業時段自動調整 UI。 