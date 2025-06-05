# BeautyAI 快速參考卡片

## 🚀 快速啟動

```bash
# 1. 啟動後端
cd backend && docker compose up postgres redis -d
go run cmd/server/main.go

# 2. 啟動前端  
cd frontend && flutter run -d chrome --web-port 3000

# 3. 驗證
curl http://localhost:3001/health  # 後端健康檢查
curl http://localhost:3000/        # 前端可訪問性
```

## 🔧 新功能開發流程

### 後端 (Go)
1. **模型** → `internal/models/` 
2. **服務** → `internal/services/`
3. **控制器** → `internal/handlers/`
4. **路由** → 註冊到 `api/routes.go`
5. **文檔** → `swag init`

### 前端 (Flutter)
1. **模型** → `lib/models/`
2. **服務** → `lib/services/`
3. **UI** → `lib/screens/` 或 `lib/components/`

## 📝 關鍵規範

### API 響應格式
```json
{
  "success": true,
  "message": "操作成功",
  "data": {...}
}
```

### 前端 HTTP 請求
```dart
final response = await http.post(
  Uri.parse('$baseUrl/api/v1/endpoint'),
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${AuthService.accessToken}',
  },
  body: jsonEncode(data),
);
```

### 錯誤處理模式
```dart
try {
  final result = await ApiService.operation();
  // 成功處理
} catch (e) {
  _showError('操作失敗：$e');
}
```

## 🧪 測試命令

```bash
# 後端測試
curl -X POST http://localhost:3001/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user@test.com","password":"password123"}'

# 前端測試 
dart test_api.dart
```

## 📚 重要文檔

- 📖 [完整串接指南](FRONTEND_BACKEND_INTEGRATION_GUIDE.md)
- 📊 [API 測試報告](API_INTEGRATION_TEST_REPORT.md)
- 🌐 [Swagger 文檔](http://localhost:3001/swagger/index.html)

---
💡 **提示**: 開發前請先閱讀完整的串接指南！ 