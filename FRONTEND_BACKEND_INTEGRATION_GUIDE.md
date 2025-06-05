# BeautyAI 前後端串接實作指南

本指南基於 BeautyAI 專案的成功串接經驗，提供標準化的前後端整合流程，適用於所有新功能開發。

## 📋 目錄

1. [環境準備](#環境準備)
2. [後端 API 開發流程](#後端-api-開發流程)
3. [前端服務整合流程](#前端服務整合流程)
4. [測試驗證流程](#測試驗證流程)
5. [常見問題解決](#常見問題解決)
6. [最佳實務](#最佳實務)
7. [檢查清單](#檢查清單)

## 🚀 環境準備

### 1. 後端環境設置

```bash
# 1. 啟動數據庫服務
cd backend
docker compose up postgres redis -d

# 2. 檢查環境變數配置
cp .env.example .env
# 編輯 .env 文件，確保以下配置正確：
# PORT=3001
# DATABASE_TYPE=postgres
# DB_HOST=localhost
# DB_PORT=5432
# JWT_SECRET=your-secret-key

# 3. 啟動後端服務
go run cmd/server/main.go
```

### 2. 前端環境設置

```bash
# 1. 進入前端目錄
cd frontend

# 2. 安裝依賴
flutter pub get

# 3. 啟動前端服務
flutter run -d chrome --web-port 3000
```

### 3. 驗證環境

```bash
# 檢查後端健康狀態
curl http://localhost:3001/health

# 檢查前端可訪問性
curl http://localhost:3000/
```

## 🔧 後端 API 開發流程

### 1. 定義數據模型

```go
// internal/models/example.go
type ExampleModel struct {
    ID        string    `json:"id" gorm:"primaryKey"`
    Name      string    `json:"name" validate:"required"`
    Email     string    `json:"email" validate:"required,email"`
    CreatedAt time.Time `json:"createdAt"`
    UpdatedAt time.Time `json:"updatedAt"`
}
```

### 2. 創建服務層

```go
// internal/services/example_service.go
type ExampleService struct {
    repo ExampleRepository
}

func (s *ExampleService) CreateExample(ctx context.Context, req *CreateExampleRequest) (*ExampleModel, error) {
    // 業務邏輯實現
    example := &ExampleModel{
        ID:   uuid.New().String(),
        Name: req.Name,
        Email: req.Email,
    }
    
    return s.repo.Create(ctx, example)
}
```

### 3. 實現控制器

```go
// internal/handlers/example.go
type ExampleHandler struct {
    service *services.ExampleService
}

// @Summary 創建示例
// @Description 創建新的示例記錄
// @Tags examples
// @Accept json
// @Produce json
// @Param request body CreateExampleRequest true "創建請求"
// @Success 201 {object} APIResponse{data=ExampleModel}
// @Router /api/v1/examples [post]
func (h *ExampleHandler) CreateExample(c *gin.Context) {
    var req CreateExampleRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        utils.ErrorResponse(c, http.StatusBadRequest, "無效的請求參數")
        return
    }
    
    example, err := h.service.CreateExample(c.Request.Context(), &req)
    if err != nil {
        utils.HandleServiceError(c, err)
        return
    }
    
    utils.SuccessResponse(c, example)
}
```

### 4. 註冊路由

```go
// api/routes.go
func SetupRoutes(r *gin.Engine, deps *Dependencies) {
    api := r.Group("/api/v1")
    
    // 示例路由組
    examples := api.Group("/examples")
    {
        examples.POST("", deps.ExampleHandler.CreateExample)
        examples.GET("/:id", deps.ExampleHandler.GetExample)
        examples.PUT("/:id", deps.ExampleHandler.UpdateExample)
        examples.DELETE("/:id", deps.ExampleHandler.DeleteExample)
    }
}
```

### 5. 更新 Swagger 文檔

```bash
# 生成 Swagger 文檔
swag init -g cmd/server/main.go -o ./docs
```

## 📱 前端服務整合流程

### 1. 定義數據模型

```dart
// lib/models/example.dart
class Example {
  final String id;
  final String name;
  final String email;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Example({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Example.fromJson(Map<String, dynamic> json) {
    return Example(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
```

### 2. 創建 API 服務

```dart
// lib/services/example_service.dart
class ExampleService {
  static const String _baseUrl = 'http://localhost:3001/api/v1';
  
  static Future<Example> createExample({
    required String name,
    required String email,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/examples'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AuthService.accessToken}',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          return Example.fromJson(responseData['data']);
        }
      }
      
      throw Exception('創建失敗');
    } catch (e) {
      print('創建示例錯誤: $e');
      throw Exception('創建示例失敗: $e');
    }
  }

  static Future<List<Example>> getExamples() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/examples'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AuthService.accessToken}',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          final List<dynamic> data = responseData['data'];
          return data.map((json) => Example.fromJson(json)).toList();
        }
      }
      
      throw Exception('獲取列表失敗');
    } catch (e) {
      print('獲取示例列表錯誤: $e');
      throw Exception('獲取示例列表失敗: $e');
    }
  }
}
```

### 3. 實現 UI 組件

```dart
// lib/screens/example_screen.dart
class ExampleScreen extends StatefulWidget {
  @override
  _ExampleScreenState createState() => _ExampleScreenState();
}

class _ExampleScreenState extends State<ExampleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  List<Example> _examples = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadExamples();
  }

  Future<void> _loadExamples() async {
    setState(() => _isLoading = true);
    try {
      final examples = await ExampleService.getExamples();
      setState(() => _examples = examples);
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createExample() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final example = await ExampleService.createExample(
        name: _nameController.text,
        email: _emailController.text,
      );
      
      setState(() {
        _examples.add(example);
        _nameController.clear();
        _emailController.clear();
      });
      
      _showSuccess('創建成功');
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('示例管理')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 創建表單
                Form(
                  key: _formKey,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(labelText: '名稱'),
                        validator: (value) => value?.isEmpty == true ? '請輸入名稱' : null,
                      ),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(labelText: '郵箱'),
                        validator: (value) => value?.isEmpty == true ? '請輸入郵箱' : null,
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _createExample,
                        child: Text('創建'),
                      ),
                    ]),
                  ),
                ),
                // 列表展示
                Expanded(
                  child: ListView.builder(
                    itemCount: _examples.length,
                    itemBuilder: (context, index) {
                      final example = _examples[index];
                      return ListTile(
                        title: Text(example.name),
                        subtitle: Text(example.email),
                        trailing: Text(example.createdAt.toString()),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
```

## 🧪 測試驗證流程

### 1. 創建 API 測試腳本

```dart
// test_example_api.dart
import 'dart:convert';
import 'dart:io';

void main() async {
  print('🧪 測試示例 API...\n');
  
  try {
    final client = HttpClient();
    
    // 1. 測試創建
    print('1. 測試創建 API...');
    final createRequest = await client.postUrl(Uri.parse('http://localhost:3001/api/v1/examples'));
    createRequest.headers.contentType = ContentType.json;
    createRequest.write(jsonEncode({
      'name': 'Test Example',
      'email': 'test@example.com'
    }));
    
    final createResponse = await createRequest.close();
    final createResult = await createResponse.transform(utf8.decoder).join();
    print('   創建響應: $createResult\n');
    
    // 2. 測試列表獲取
    print('2. 測試獲取列表 API...');
    final listRequest = await client.getUrl(Uri.parse('http://localhost:3001/api/v1/examples'));
    final listResponse = await listRequest.close();
    final listResult = await listResponse.transform(utf8.decoder).join();
    print('   列表響應: $listResult\n');
    
    client.close();
    print('🎉 API 測試完成！');
    
  } catch (e) {
    print('❌ 錯誤: $e');
  }
}
```

### 2. 運行測試

```bash
# 測試後端 API
dart test_example_api.dart

# 測試前端服務
cd frontend && dart test_example_flutter.dart
```

### 3. 手動 UI 測試

1. 打開瀏覽器訪問 http://localhost:3000
2. 導航到新功能頁面
3. 測試創建、讀取、更新、刪除操作
4. 驗證錯誤處理和用戶反饋

## ❗ 常見問題解決

### 1. CORS 錯誤

**問題**: 前端請求被 CORS 政策阻止

**解決方案**:
```go
// 確保後端 CORS 中間件正確配置
func CORSMiddleware() gin.HandlerFunc {
    return cors.New(cors.Config{
        AllowOrigins:     []string{"http://localhost:3000"},
        AllowMethods:     []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
        AllowHeaders:     []string{"Origin", "Content-Type", "Authorization"},
        AllowCredentials: true,
    })
}
```

### 2. 認證 Token 問題

**問題**: API 返回 401 未授權錯誤

**解決方案**:
```dart
// 確保每個 API 請求都包含有效的 Token
headers: {
  'Content-Type': 'application/json',
  'Authorization': 'Bearer ${AuthService.accessToken}',
}

// 檢查 Token 是否過期
if (response.statusCode == 401) {
  // 嘗試刷新 Token 或重新登入
  await AuthService.refreshToken();
}
```

### 3. 數據格式不匹配

**問題**: JSON 序列化/反序列化失敗

**解決方案**:
- 確保前後端模型字段名稱一致
- 檢查日期時間格式 (使用 ISO 8601)
- 驗證必填字段和可選字段標記

### 4. API 響應格式不一致

**問題**: 不同端點返回不同的響應格式

**解決方案**:
```go
// 統一使用標準響應格式
type APIResponse struct {
    Success bool        `json:"success"`
    Message string      `json:"message,omitempty"`
    Data    interface{} `json:"data,omitempty"`
    Error   string      `json:"error,omitempty"`
}
```

## 💡 最佳實務

### 1. 命名規範

- **後端**: 使用 camelCase (Go) 和 snake_case (資料庫)
- **前端**: 使用 camelCase (Dart/Flutter)
- **API 端點**: 使用 kebab-case 或 snake_case

### 2. 錯誤處理

```dart
// 統一的錯誤處理模式
try {
  final result = await ApiService.someOperation();
  // 處理成功情況
} on ApiException catch (e) {
  // 處理 API 特定錯誤
  _showError(e.message);
} catch (e) {
  // 處理一般錯誤
  _showError('操作失敗，請稍後再試');
}
```

### 3. 狀態管理

```dart
// 使用統一的加載狀態管理
class _ScreenState extends State<Screen> {
  bool _isLoading = false;
  String? _error;
  
  void _setLoading(bool loading) {
    setState(() {
      _isLoading = loading;
      _error = null;
    });
  }
  
  void _setError(String error) {
    setState(() {
      _isLoading = false;
      _error = error;
    });
  }
}
```

### 4. API 版本管理

```go
// 使用版本化的 API 路徑
v1 := r.Group("/api/v1")
v2 := r.Group("/api/v2")
```

### 5. 日誌記錄

```go
// 後端 API 日誌
logger.Info("API request",
    zap.String("method", c.Request.Method),
    zap.String("path", c.Request.URL.Path),
    zap.String("user_id", userID),
)
```

```dart
// 前端 API 日誌
print('API Request: ${method} ${url}');
print('Response: ${response.statusCode} ${response.body}');
```

## ✅ 檢查清單

### 後端開發檢查清單

- [ ] 模型定義完整，包含所有必要字段
- [ ] 服務層實現業務邏輯
- [ ] 控制器處理 HTTP 請求/響應
- [ ] 路由正確註冊
- [ ] Swagger 文檔已更新
- [ ] 錯誤處理完善
- [ ] 認證授權正確實現
- [ ] 單元測試通過

### 前端開發檢查清單

- [ ] 數據模型與後端一致
- [ ] API 服務封裝完整
- [ ] UI 組件實現功能需求
- [ ] 錯誤處理和用戶反饋
- [ ] 加載狀態管理
- [ ] 表單驗證
- [ ] 響應式設計
- [ ] 集成測試通過

### 整合測試檢查清單

- [ ] 後端 API 獨立測試通過
- [ ] 前端服務獨立測試通過
- [ ] 端到端功能測試通過
- [ ] 錯誤場景測試通過
- [ ] 性能測試符合要求
- [ ] 安全性測試通過

## 📚 參考資源

- [Gin 框架文檔](https://gin-gonic.com/)
- [Flutter HTTP 請求](https://docs.flutter.dev/development/data-and-backend/networking)
- [Go API 設計最佳實務](https://github.com/golang-standards/project-layout)
- [Flutter 狀態管理](https://docs.flutter.dev/development/data-and-backend/state-mgmt)

---

*本指南會隨著專案發展持續更新，請定期檢查最新版本。* 