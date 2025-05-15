# ID 遷移指南：從整數 ID 到 KSUID

本文檔提供從整數 ID 切換到基於字符串的 KSUID 的詳細步驟和最佳實踐。

## 背景與預期

我們將所有主要實體的主鍵從整數（int）遷移到 KSUID 字符串（char(26)）。這包括：

- 用戶 (User)
- 業務 (Business)
- 分店 (Branch)
- 客戶 (Customer)
- 預約 (Appointment)
- 服務項目 (ServiceItem)
- 服務類別 (ServiceCategory)
- 業務目標 (BusinessGoal)
- 團隊成員 (TeamMember)
- 客戶服務記錄 (CustomerServiceRecord)

內部枚舉表（Role、Permission）保持整數 ID。

## 遷移工具

我們提供了幾個工具來協助遷移過程：

1. **GORM AutoMigrate**：用於開發環境的便捷工具
2. **SQL 遷移腳本**：用於生產環境的精確控制
3. **自定義遷移工具**：用於分階段執行和監控遷移

## 開發環境遷移步驟

對於開發環境，我們推薦使用 GORM AutoMigrate 進行直接遷移：

```bash
# 運行API服務器時會自動遷移
go run cmd/api/main.go
```

## 測試環境遷移步驟

1. **準備工作**

   ```bash
   # 構建遷移工具
   go build -o bin/migrate cmd/migrate/main.go
   
   # 生成測試數據（在空數據庫上）
   ./bin/migrate --script=scripts/migrations/003_generate_test_data.sql
   
   # 創建PostgreSQL輔助函數
   ./bin/migrate --phase=prepare
   ```

2. **執行測試遷移**

   ```bash
   # 運行測試遷移（不會提交更改）
   ./bin/migrate --phase=test
   
   # 檢查測試輸出以確認預期結果
   ```

3. **模擬全面遷移**

   ```bash
   # 模擬全量遷移（測試模式，不會提交更改）
   ./bin/migrate --test=true --phase=all
   ```

## 生產環境遷移步驟

對於生產環境，我們推薦以下分階段方法：

1. **準備階段**

   ```bash
   # 備份數據庫
   pg_dump -U username -d database_name -F c -f pre_migration_backup.dump
   
   # 創建輔助函數
   psql -U username -d database_name -f scripts/migrations/000_create_ksuid_function.sql
   ```

2. **小規模測試**

   ```bash
   # 在生產數據庫的副本上測試
   psql -U username -d database_copy -f scripts/migrations/002_test_migration.sql
   ```

3. **分階段遷移**

   ```bash
   # 遷移第一批表（低風險或小表）
   ./bin/migrate --test=false --phase=core --tables=users,businesses,branches
   
   # 在不同批次中遷移其餘表
   ./bin/migrate --test=false --phase=core --tables=customers,team_members
   ./bin/migrate --test=false --phase=core --tables=service_categories,service_items
   ./bin/migrate --test=false --phase=core --tables=appointments,customer_service_records,business_goals
   ```

4. **遷移完成後的驗證**

   ```bash
   # 驗證數據完整性和外鍵關係
   ./bin/migrate --script=scripts/migrations/verify_integrity.sql
   ```

## 回滾計劃

如果遷移過程中出現問題，回滾計劃如下：

1. 停止所有正在運行的服務
2. 使用預先準備的備份還原數據庫
3. 回退代碼到使用整數 ID 的版本
4. 重新啟動服務

## 監控與後續行動

遷移後的監控重點：

1. **性能監控**：關注查詢性能特別是那些涉及 ID 連接的查詢
2. **空間使用**：監控數據庫大小的變化
3. **錯誤率**：關注任何可能與 ID 類型相關的應用程序錯誤

## 附錄：遷移腳本概述

我們的遷移腳本遵循以下步驟：

1. 為每個表添加新的 KSUID 列（id_new, *_id_new）
2. 為每個記錄生成 KSUID 並填充新列
3. 更新所有外鍵關係
4. 交換列並重新創建主鍵/外鍵/索引
5. 驗證數據完整性

## 常見問題

**問：為什麼選擇 KSUID 而不是 UUID？**
答：KSUID 結合了時間順序和隨機性，保留了排序能力，同時避免了整數 ID 的局限性。

**問：這會影響性能嗎？**
答：字符串索引可能略慢於整數索引，但對於大多數操作來說差異很小。我們建議在測試環境中進行性能基准測試。

**問：前端應用需要做什麼變更？**
答：前端需要更新以處理字符串 ID，並確保所有 API 調用正確處理這些 ID。具體變更取決於前端實現。 