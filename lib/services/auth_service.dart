import 'package:flutter/foundation.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String role;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
    };
  }
}

class AuthService {
  // 模擬用戶數據
  static final Map<String, Map<String, dynamic>> _mockUsers = {
    'admin@beauty.com': {
      'email': 'admin@beauty.com',
      'password': '123456',
      'name': '王小姐',
      'businessName': '王小美髮廊',
      'role': 'admin',
    },
    'staff@beauty.com': {
      'email': 'staff@beauty.com',
      'password': '123456',
      'name': '李小姐',
      'businessName': '李小姐美容院',
      'role': 'staff',
    },
  };

  // 當前登入的用戶
  static User? _currentUser;
  static final _storage = <String, dynamic>{};

  // 獲取當前用戶
  static User? get currentUser => _currentUser;

  static bool _isLoggedIn = false;
  static String? _userEmail;
  static String? _userRole;

  static bool get isLoggedIn => _isLoggedIn;
  static String? get userEmail => _userEmail;
  static String? get userRole => _userRole;

  // 登入
  static Future<bool> login(String email, String password) async {
    // TODO: Implement actual API call
    // For now, just simulate a successful login
    await Future.delayed(const Duration(seconds: 1));
    
    if (email.isNotEmpty && password.isNotEmpty) {
      _isLoggedIn = true;
      _userEmail = email;
      _userRole = 'admin'; // TODO: Get actual role from API
      _currentUser = User(
        id: '1',
        name: '測試用戶',
        email: email,
        role: 'admin',
      );
      _storage['token'] = 'mock_token';
      return true;
    }
    return false;
  }

  // 登出
  static Future<void> logout() async {
    // TODO: Implement actual API call
    await Future.delayed(const Duration(milliseconds: 500));
    _isLoggedIn = false;
    _userEmail = null;
    _userRole = null;
    _currentUser = null;
    _storage.clear();
  }

  // 獲取用戶名稱
  static String? get userName => _currentUser?.name;

  // 獲取商家名稱
  static String? get businessName => _currentUser?.name;

  static User? getCurrentUser() {
    return _currentUser;
  }
} 