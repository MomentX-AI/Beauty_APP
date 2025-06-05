import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class AuthService {
  // API 基礎 URL - 根據環境配置
  static const String _baseUrl = 'http://localhost:3001/api/v1';
  
  // 當前登入的用戶
  static User? _currentUser;
  static String? _accessToken;
  static String? _refreshToken;
  
  // 獲取當前用戶
  static User? get currentUser => _currentUser;
  static String? get accessToken => _accessToken;
  static bool get isLoggedIn => _currentUser != null && _accessToken != null;
  
  // 便捷方法
  static String? get userEmail => _currentUser?.email;
  static String? get userRole => _currentUser?.role;
  static String? get userName => _currentUser?.name;
  static String? get businessName => _currentUser?.businessName;

  // 註冊
  static Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String businessName,
  }) async {
    try {
      final request = RegisterRequest(
        email: email,
        password: password,
        name: name,
        businessName: businessName,
      );

      final response = await http.post(
        Uri.parse('$_baseUrl/auth/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      final responseData = jsonDecode(response.body);
      final authResponse = AuthResponse.fromJson(responseData);

      if ((response.statusCode == 201 || response.statusCode == 200) && authResponse.success) {
        // 註冊成功，自動設置登入信息
        if (authResponse.data != null) {
          _currentUser = authResponse.data!.user;
          _accessToken = authResponse.data!.token;
          _refreshToken = authResponse.data!.refreshToken;
          
          // TODO: 存儲到本地持久化存儲 (SharedPreferences)
        }
        return true;
      } else {
        print('註冊失敗: ${authResponse.message}');
        return false;
      }
    } catch (e) {
      print('註冊錯誤: $e');
      return false;
    }
  }

  // 登入
  static Future<bool> login(String email, String password) async {
    try {
      final request = LoginRequest(
        email: email,
        password: password,
      );

      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      final responseData = jsonDecode(response.body);
      final authResponse = AuthResponse.fromJson(responseData);

      if (response.statusCode == 200 && authResponse.success) {
        if (authResponse.data != null) {
          _currentUser = authResponse.data!.user;
          _accessToken = authResponse.data!.token;
          _refreshToken = authResponse.data!.refreshToken;
          
          // TODO: 存儲到本地持久化存儲 (SharedPreferences)
        }
        return true;
      } else {
        print('登入失敗: ${authResponse.message}');
        return false;
      }
    } catch (e) {
      print('登入錯誤: $e');
      return false;
    }
  }

  // 登出
  static Future<void> logout() async {
    try {
      if (_accessToken != null) {
        await http.post(
          Uri.parse('$_baseUrl/auth/logout'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_accessToken',
          },
        );
      }
    } catch (e) {
      print('登出請求錯誤: $e');
    } finally {
      // 清除本地狀態
      _currentUser = null;
      _accessToken = null;
      _refreshToken = null;
      
      // TODO: 清除本地持久化存儲
    }
  }

  // 獲取用戶資料
  static Future<User?> getProfile() async {
    if (_accessToken == null) return null;
    
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/auth/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        if (responseData['success'] == true && responseData['data'] != null) {
          // /auth/me 端點直接返回用戶資料，不是包裹在 AuthData 中
          _currentUser = User.fromJson(responseData['data']);
          return _currentUser;
        }
      } else if (response.statusCode == 401) {
        // Token 可能已過期，嘗試刷新
        if (await _refreshAccessToken()) {
          return await getProfile(); // 遞歸調用
        }
      }
    } catch (e) {
      print('獲取用戶資料錯誤: $e');
    }
    
    return null;
  }

  // 更新用戶資料
  static Future<bool> updateProfile({
    String? name,
    String? businessName,
  }) async {
    if (_accessToken == null) return false;
    
    try {
      final request = UpdateUserRequest(
        name: name,
        businessName: businessName,
      );

      final response = await http.put(
        Uri.parse('$_baseUrl/auth/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final authResponse = AuthResponse.fromJson(responseData);
        
        if (authResponse.success && authResponse.data != null) {
          _currentUser = authResponse.data!.user;
          return true;
        }
      }
    } catch (e) {
      print('更新用戶資料錯誤: $e');
    }
    
    return false;
  }

  // 修改密碼
  static Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_accessToken == null) return false;
    
    try {
      final request = ChangePasswordRequest(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      final response = await http.post(
        Uri.parse('$_baseUrl/auth/change-password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        },
        body: jsonEncode(request.toJson()),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('修改密碼錯誤: $e');
      return false;
    }
  }

  // 刷新 Access Token
  static Future<bool> _refreshAccessToken() async {
    if (_refreshToken == null) return false;
    
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/refresh'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'refresh_token': _refreshToken,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final authResponse = AuthResponse.fromJson(responseData);
        
        if (authResponse.success && authResponse.data != null) {
          _accessToken = authResponse.data!.token;
          _refreshToken = authResponse.data!.refreshToken;
          _currentUser = authResponse.data!.user;
          
          // TODO: 更新本地持久化存儲
          return true;
        }
      }
    } catch (e) {
      print('刷新 Token 錯誤: $e');
    }
    
    return false;
  }

  // 檢查 Token 是否有效
  static Future<bool> validateToken() async {
    if (_accessToken == null) return false;
    
    final user = await getProfile();
    return user != null;
  }

  // 初始化服務 (從本地存儲恢復狀態)
  static Future<void> init() async {
    // TODO: 從 SharedPreferences 恢復登入狀態
    // _accessToken = await prefs.getString('access_token');
    // _refreshToken = await prefs.getString('refresh_token');
    // if (_accessToken != null) {
    //   await getProfile();
    // }
  }

  // 獲取當前用戶 (向後兼容)
  static User? getCurrentUser() {
    return _currentUser;
  }
} 