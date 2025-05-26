
# 前端模組重構規劃：整合原設定頁功能至七大模組

---

## 1. 七大主類別（Top-level Modules）

```text
儀表板  |  預約管理  |  客戶管理  |  服務管理  |  業務分析報告  |  AI 助理  |  用戶管理
```

---

## 2. 各模組功能對應與 API 關聯

| 模組 | 子頁 / 功能 | 取代舊設定功能 | 對應 API |
|------|--------------|----------------|----------|
| **儀表板** | - 營收 / 預約 KPI 概覽<br>- 業務目標進度卡片 | 業務目標進度追蹤 | `/businesses/:id/goals` |
| **預約管理** | - 客戶預約日曆與時段<br>- 員工排程視圖 | 原預約管理功能 | `/appointments` |
| **客戶管理** | - 客戶資料 CRUD<br>- 服務歷史記錄 | 客戶資料與紀錄 | `/customers`、`/service-histories` |
| **服務管理** | - 服務項目設定<br>- 商家設定<br>- 分店設定<br>- 特殊營業日設定 | 舊設定中的：<br>- 商家清單<br>- 分店營業時間<br>- 特殊營業日管理 | `/services`、`/businesses`、`/branches`、`/branch-special-days` |
| **業務分析報告** | - 銷售統計圖表<br>- 客戶/服務使用分析 | 舊業績與顧客報表分析 | `/business-analysis`（假設） |
| **AI 助理** | - 推薦優化時段<br>- 熱門服務建議 | 智慧決策支援 | 串接 AI Gateway |
| **用戶管理** | - 使用者帳號管理<br>- 團隊成員 CRUD<br>- 角色與權限配置<br>- 偏好設定（語言 / 主題） | 原設定頁所有帳號與權限管理功能 | `/users`、`/team-members`、`/roles`、`/permissions`、`/user-roles` |

---

## 3. 建議路由設計（GoRouter）

```dart
GoRoute(
  path: '/',
  redirect: (_) => '/dashboard',
  routes: [
    GoRoute(path: 'dashboard',    builder: …),
    GoRoute(path: 'appointments', builder: …),
    GoRoute(path: 'customers',    builder: …),
    GoRoute(path: 'services',     builder: …, routes: [
      GoRoute(path: 'business', name: 'bizList', builder: …),
      GoRoute(path: 'branch',   name: 'branchList', builder: …),
      GoRoute(path: 'special',  name: 'specialDay', builder: …),
    ]),
    GoRoute(path: 'reports', builder: …),
    GoRoute(path: 'ai',      builder: …),
    GoRoute(path: 'admin',   builder: …, routes: [
      GoRoute(path: 'profile', builder: …),
      GoRoute(path: 'users',   builder: …),
      GoRoute(path: 'team',    builder: …),
      GoRoute(path: 'roles',   builder: …),
      GoRoute(path: 'perms',   builder: …),
      GoRoute(path: 'prefs',   builder: …),
    ]),
  ],
);
```

---

## 4. Sprint 建議規劃

| Sprint | 任務目標 |
|--------|----------|
| S1 | 整合商家/分店至服務管理，建立 `services/business` & `services/branch` 頁面 |
| S2 | 日曆元件顯示並串接 `/branch-special-days` 特殊營業日 |
| S3 | 將角色 / 權限 / 團隊元件從原設定頁重構為 `/admin` 內部子頁 |
| S4 | 儀表板整合業務目標進度，顯示於 KPI 卡片區域 |

---

## 5. 前端開發注意事項

- 保持 SideNav 七大主類別一致性，子頁用 TabBar 或 Drawer 呈現
- 權限守衛應於 router 與元件雙層設計（防止未授權進入）
- `authProvider.permissions` 驗證後動態隱藏/禁用功能
- 舊 `/settings/**` URL 可暫時 redirect 至新對應頁面

---

> 以上結構可作為新版設定頁模組整併與實作的依據，符合後端 API 並具良好擴充性。
