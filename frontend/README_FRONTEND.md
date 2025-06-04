# BeautyAI Frontend (Flutter)

BeautyAI 前端是使用 Flutter 框架開發的跨平台美容管理應用，支持 iOS、Android、Web 和桌面平台。本應用提供直觀的用戶界面和豐富的功能，幫助美容業者有效管理業務。

## 技術棧

- **框架**: Flutter 3.0+ / Dart 3.0+
- **平台支持**: iOS、Android、Web、macOS、Windows、Linux
- **UI 設計**: Material Design 3
- **路由管理**: go_router ^14.6.2
- **圖表可視化**: fl_chart ^0.66.2
- **日期處理**: table_calendar ^3.1.3, intl ^0.19.0
- **媒體處理**: image_picker ^1.0.7
- **狀態管理**: Provider / Built-in State Management

## 專案結構

```
frontend/
├── lib/
│   ├── components/              # 可重用UI組件
│   │   ├── cards/              # 卡片組件
│   │   ├── dialogs/            # 彈窗組件
│   │   ├── forms/              # 表單組件
│   │   └── charts/             # 圖表組件
│   ├── models/                 # 數據模型
│   │   ├── appointment.dart    # 預約模型
│   │   ├── business.dart       # 商家模型
│   │   ├── branch.dart         # 門店模型
│   │   ├── staff.dart          # 員工模型
│   │   ├── customer.dart       # 客戶模型
│   │   ├── service.dart        # 服務模型
│   │   └── subscription.dart   # 訂閱模型
│   ├── screens/                # 主要頁面
│   │   ├── auth/               # 認證相關頁面
│   │   ├── dashboard/          # 儀表板
│   │   ├── appointments/       # 預約管理
│   │   ├── customers/          # 客戶管理
│   │   ├── staff/              # 員工管理
│   │   ├── services/           # 服務管理
│   │   ├── goals/              # 目標管理
│   │   ├── analytics/          # 分析報表
│   │   ├── billing/            # 帳單管理
│   │   └── settings/           # 設定頁面
│   ├── services/               # 業務邏輯服務
│   │   ├── auth_service.dart   # 認證服務
│   │   ├── api_service.dart    # API 服務
│   │   └── mock_services/      # 模擬數據服務
│   ├── widgets/                # 小型UI組件
│   │   ├── common/             # 通用組件
│   │   ├── navigation/         # 導航組件
│   │   └── form_fields/        # 表單字段組件
│   ├── routes/                 # 路由配置
│   │   └── app_router.dart     # 應用路由
│   ├── config/                 # 配置文件
│   │   ├── api_config.dart     # API 配置
│   │   └── app_config.dart     # 應用配置
│   ├── utils/                  # 工具函數
│   │   ├── date_utils.dart     # 日期工具
│   │   ├── format_utils.dart   # 格式化工具
│   │   └── validation_utils.dart # 驗證工具
│   └── main.dart               # 應用入口點
├── assets/                     # 靜態資源
│   ├── images/                 # 圖片資源
│   ├── icons/                  # 圖標資源
│   └── fonts/                  # 字體資源
├── test/                       # 測試文件
├── android/                    # Android 平台配置
├── ios/                        # iOS 平台配置
├── web/                        # Web 平台配置
├── windows/                    # Windows 平台配置
├── macos/                      # macOS 平台配置
├── linux/                      # Linux 平台配置
└── pubspec.yaml               # Flutter 依賴配置
```

## 功能實作進度

| 功能模塊 | 狀態 | 實作程度 | 說明 |
|---------|------|---------|------|
| 用戶認證 | ✅ 完成 | 100% | 登入/註冊、表單驗證、JWT Token 管理 |
| 門店績效分析 | ✅ 完成 | 100% | 完整的營運數據分析、KPI 指標、側邊欄導航 |
| 門店篩選功能 | ✅ 完成 | 100% | 支持單一門店或全部門店數據查看 |
| 業務目標展示 | ✅ 完成 | 100% | 三層級目標追蹤、達成率視覺化 |
| AI 助理 | ✅ 完成 | 90% | 基本對話功能、預約查詢、客戶信息查詢 |
| 預約管理 | ✅ 完成 | 100% | 預約 CRUD、員工指定、排班衝突檢查 |
| 服務管理 | ✅ 完成 | 100% | 服務項目管理、分類管理、多門店定價 |
| 門店服務管理 | ✅ 完成 | 100% | 門店服務配置、自訂價格 |
| 員工管理 | ✅ 完成 | 100% | 員工 CRUD、多門店分配、技能管理、排班 |
| 員工績效分析 | ✅ 完成 | 100% | 跨門店績效追蹤、收益分析、圖表展示 |
| 客戶管理 | ✅ 完成 | 100% | 客戶 CRUD、服務歷史、詳細信息 |
| 業務目標管理 | ✅ 完成 | 100% | 目標設定、進度追蹤、三層級管理 |
| 商家資料管理 | ✅ 完成 | 100% | 商家信息編輯、營業目標設定 |
| 方案管理 | ✅ 完成 | 100% | 訂閱方案選擇、升級、比較功能 |
| 帳單管理 | ✅ 完成 | 100% | 帳單列表、付款處理、統計報表 |
| 響應式設計 | ✅ 完成 | 95% | 適配手機、平板、桌面等不同螢幕尺寸 |

## 快速開始

### 環境需求

- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- Android Studio / VS Code (推薦)
- Xcode (iOS 開發)

### 安裝和運行

1. **檢查 Flutter 環境**
   ```bash
   flutter doctor
   ```

2. **安裝依賴**
   ```bash
   cd frontend
   flutter pub get
   ```

3. **運行應用**
   ```bash
   # 在指定平台運行
   flutter run                    # 預設平台
   flutter run -d chrome         # Web 瀏覽器
   flutter run -d windows        # Windows 桌面
   flutter run -d macos          # macOS 桌面
   
   # 指定 Web 端口
   flutter run -d web --web-port 3001
   ```

4. **建置發布版本**
   ```bash
   # Web 版本
   flutter build web
   
   # Android APK
   flutter build apk
   
   # iOS 版本 (需要 macOS)
   flutter build ios
   
   # Windows 版本
   flutter build windows
   ```

## 開發配置

### API 端點配置

編輯 `lib/config/api_config.dart` 設定 API 連接：

```dart
class ApiConfig {
  static const String _devBaseUrl = 'http://localhost:3000/api/v1';
  static const String _prodBaseUrl = 'https://api.beautyai.com/api/v1';
  
  static String get baseUrl {
    return const bool.fromEnvironment('dart.vm.product') 
        ? _prodBaseUrl 
        : _devBaseUrl;
  }
}
```

### 主題配置

應用使用 Material Design 3 主題，可在 `lib/config/app_config.dart` 中自訂：

```dart
class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
    ),
  );
  
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.dark,
    ),
  );
}
```

## 核心功能詳解

### 1. 認證系統

- **JWT Token 管理**: 自動存儲、刷新和驗證 Token
- **表單驗證**: 即時驗證用戶輸入
- **多角色支持**: 管理員、員工等不同權限

```dart
// 使用認證服務
final authService = AuthService();
final result = await authService.login(email, password);
if (result.success) {
  // 登入成功，導航到主頁
  router.go('/dashboard');
}
```

### 2. 門店績效分析

- **KPI 指標**: 營收、預約率、客戶滿意度等
- **圖表展示**: 使用 fl_chart 提供豐富的視覺化
- **門店篩選**: 支持單一門店或全部門店數據查看

```dart
// 績效分析組件
class BranchPerformanceCard extends StatelessWidget {
  final BranchPerformance performance;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // KPI 指標展示
            _buildKPIIndicators(),
            // 圖表展示
            _buildPerformanceChart(),
          ],
        ),
      ),
    );
  }
}
```

### 3. 員工績效分析

- **跨門店分析**: 員工在多個門店的績效追蹤
- **收益分析**: 服務收益分布和占比分析
- **視覺化展示**: 圓餅圖、柱狀圖等多種圖表類型

### 4. 業務目標管理

- **三層級目標**: 企業、門店、員工目標管理
- **進度追蹤**: 即時計算達成率
- **視覺化指示**: 顏色編碼表示達成狀況

### 5. 預約管理

- **日曆視圖**: 使用 table_calendar 提供直觀的預約檢視
- **員工指定**: 支持指定特定員工進行服務
- **衝突檢查**: 自動檢查排班和時間衝突

```dart
// 預約表單對話框
class AppointmentFormDialog extends StatefulWidget {
  final Appointment? appointment;
  
  @override
  _AppointmentFormDialogState createState() => _AppointmentFormDialogState();
}
```

## 狀態管理

應用使用多種狀態管理方式：

### 1. StatefulWidget (本地狀態)
用於簡單的 UI 狀態管理：

```dart
class _MyWidgetState extends State<MyWidget> {
  bool _isLoading = false;
  
  void _loadData() {
    setState(() {
      _isLoading = true;
    });
    // 載入數據...
  }
}
```

### 2. Provider (全局狀態)
用於跨組件的狀態共享：

```dart
// 狀態提供者
class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  
  User? get currentUser => _currentUser;
  
  void setUser(User user) {
    _currentUser = user;
    notifyListeners();
  }
}

// 使用狀態
Consumer<AuthProvider>(
  builder: (context, authProvider, child) {
    return Text(authProvider.currentUser?.name ?? 'Guest');
  },
)
```

## UI/UX 設計

### 設計原則

- **Material Design 3**: 遵循最新的 Material Design 設計規範
- **響應式設計**: 適配不同螢幕尺寸和設備類型
- **無障礙性**: 支持螢幕閱讀器和鍵盤導航
- **一致性**: 統一的顏色、字體和間距規範

### 組件化設計

```dart
// 可重用的卡片組件
class InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? color;
  
  const InfoCard({
    required this.title,
    required this.value,
    required this.icon,
    this.color,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color),
            SizedBox(height: 8),
            Text(title, style: Theme.of(context).textTheme.bodySmall),
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
          ],
        ),
      ),
    );
  }
}
```

### 顏色系統

```dart
class AppColors {
  // 主要顏色
  static const Color primary = Color(0xFF2196F3);
  static const Color secondary = Color(0xFF03DAC6);
  
  // 狀態顏色
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  
  // 目標達成率顏色
  static const Color goalExcellent = Color(0xFF4CAF50);  // >= 90%
  static const Color goalGood = Color(0xFFFF9800);       // >= 70%
  static const Color goalPoor = Color(0xFFF44336);       // < 70%
}
```

## 數據模型

### 核心模型定義

```dart
// 預約模型
class Appointment {
  final String id;
  final String customerId;
  final String? staffId;
  final String branchId;
  final String serviceId;
  final DateTime dateTime;
  final Duration duration;
  final AppointmentStatus status;
  
  const Appointment({
    required this.id,
    required this.customerId,
    this.staffId,
    required this.branchId,
    required this.serviceId,
    required this.dateTime,
    required this.duration,
    required this.status,
  });
  
  // JSON 序列化
  factory Appointment.fromJson(Map<String, dynamic> json) => _$AppointmentFromJson(json);
  Map<String, dynamic> toJson() => _$AppointmentToJson(this);
}

// 員工績效分析模型
class StaffPerformanceAnalysis {
  final Staff staff;
  final Map<String, BranchRevenue> branchRevenues;
  final Map<String, ServiceRevenue> serviceRevenues;
  final int totalAppointments;
  final int totalCustomers;
  final double totalRevenue;
  final double averageServicePrice;
  
  // 構造函數和方法...
}
```

## 測試

### 單元測試

```bash
# 運行所有測試
flutter test

# 運行特定測試文件
flutter test test/models/appointment_test.dart

# 生成測試覆蓋率報告
flutter test --coverage
```

### 範例測試

```dart
// test/models/appointment_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:beauty_ai/models/appointment.dart';

void main() {
  group('Appointment Model Tests', () {
    test('should create appointment from JSON', () {
      final json = {
        'id': '1',
        'customerId': 'customer1',
        'staffId': 'staff1',
        'branchId': 'branch1',
        'serviceId': 'service1',
        'dateTime': '2024-01-01T10:00:00Z',
        'duration': 60,
        'status': 'confirmed',
      };
      
      final appointment = Appointment.fromJson(json);
      
      expect(appointment.id, '1');
      expect(appointment.customerId, 'customer1');
      expect(appointment.status, AppointmentStatus.confirmed);
    });
  });
}
```

### Widget 測試

```dart
// test/widgets/info_card_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:beauty_ai/components/cards/info_card.dart';

void main() {
  testWidgets('InfoCard displays correct information', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InfoCard(
            title: 'Total Revenue',
            value: '\$1,000',
            icon: Icons.monetization_on,
          ),
        ),
      ),
    );
    
    expect(find.text('Total Revenue'), findsOneWidget);
    expect(find.text('\$1,000'), findsOneWidget);
    expect(find.byIcon(Icons.monetization_on), findsOneWidget);
  });
}
```

## 效能優化

### 1. 圖片優化

```dart
// 使用快取網路圖片
CachedNetworkImage(
  imageUrl: imageUrl,
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
)
```

### 2. 清單優化

```dart
// 使用 ListView.builder 進行懶加載
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ListTile(
      title: Text(items[index].title),
    );
  },
)
```

### 3. 狀態優化

```dart
// 避免不必要的重建
class OptimizedWidget extends StatelessWidget {
  final String data;
  
  const OptimizedWidget({Key? key, required this.data}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return const SizedBox(); // 僅在 data 改變時重建
  }
}
```

## 部署

### Web 部署

```bash
# 建置 Web 版本
flutter build web --release

# 部署到 Firebase Hosting
firebase deploy --only hosting

# 部署到 Netlify
# 將 build/web 目錄上傳到 Netlify
```

### 行動應用部署

```bash
# Android Play Store
flutter build appbundle --release

# iOS App Store (需要 macOS)
flutter build ios --release
```

## 常見問題

### Q: 如何切換到後端 API？

A: 編輯 `lib/services/api_service.dart`，將模擬服務替換為真實的 HTTP 請求：

```dart
// 從模擬服務切換到真實 API
class ApiService {
  static const String baseUrl = 'http://localhost:3000/api/v1';
  
  Future<List<Appointment>> getAppointments() async {
    final response = await http.get(Uri.parse('$baseUrl/appointments'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Appointment.fromJson(json)).toList();
    }
    throw Exception('Failed to load appointments');
  }
}
```

### Q: 如何添加新的功能模塊？

A: 遵循現有的專案結構：

1. 在 `lib/models/` 中定義數據模型
2. 在 `lib/services/` 中創建服務層
3. 在 `lib/screens/` 中創建頁面
4. 在 `lib/components/` 中創建可重用組件
5. 更新路由配置

### Q: 如何自訂主題？

A: 修改 `lib/config/app_config.dart` 中的主題配置，或在 `main.dart` 中設定自訂主題。

## 貢獻指南

1. Fork 專案
2. 創建功能分支：`git checkout -b feature/新功能`
3. 遵循代碼規範：`dart format lib/ && flutter analyze`
4. 運行測試：`flutter test`
5. 提交變更：`git commit -m "添加新功能"`
6. 推送分支：`git push origin feature/新功能`
7. 提交 Pull Request

## 技術支援

- **Flutter 文檔**: https://docs.flutter.dev/
- **Dart 文檔**: https://dart.dev/guides
- **Material Design**: https://m3.material.io/
- **專案 Issues**: GitHub Issues 頁面

## 許可證

MIT License - 詳見 [LICENSE](../LICENSE) 檔案
