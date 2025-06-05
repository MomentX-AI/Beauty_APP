class User {
  final String id;
  final String email;
  final String name;
  final String businessName;
  final String role;
  final bool isActive;
  final bool emailVerified;
  final DateTime? lastLoginAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.businessName,
    required this.role,
    required this.isActive,
    required this.emailVerified,
    this.lastLoginAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      businessName: json['businessName'] as String,
      role: json['role'] as String,
      isActive: json['isActive'] as bool,
      emailVerified: json['emailVerified'] as bool? ?? false,
      lastLoginAt: json['lastLoginAt'] != null 
          ? DateTime.parse(json['lastLoginAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'businessName': businessName,
      'role': role,
      'isActive': isActive,
      'emailVerified': emailVerified,
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'User{id: $id, email: $email, name: $name, businessName: $businessName, role: $role}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// 註冊請求模型
class RegisterRequest {
  final String email;
  final String password;
  final String name;
  final String businessName;

  RegisterRequest({
    required this.email,
    required this.password,
    required this.name,
    required this.businessName,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'name': name,
      'businessName': businessName,
    };
  }
}

// 登入請求模型
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

// 認證響應模型
class AuthResponse {
  final bool success;
  final String? message;
  final AuthData? data;

  AuthResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      data: json['data'] != null ? AuthData.fromJson(json['data']) : null,
    );
  }
}

// 認證數據模型
class AuthData {
  final User user;
  final String token;           // 前端期望的字段名
  final String? refreshToken;
  final int? expiresAt;

  AuthData({
    required this.user,
    required this.token,
    this.refreshToken,
    this.expiresAt,
  });

  factory AuthData.fromJson(Map<String, dynamic> json) {
    return AuthData(
      user: User.fromJson(json['user']),
      token: json['token'] as String,
      refreshToken: json['refresh_token'] as String?,
      expiresAt: json['expires_at'] as int?,
    );
  }
}

// 更新用戶請求模型
class UpdateUserRequest {
  final String? name;
  final String? businessName;

  UpdateUserRequest({
    this.name,
    this.businessName,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    if (businessName != null) data['businessName'] = businessName;
    return data;
  }
}

// 修改密碼請求模型
class ChangePasswordRequest {
  final String currentPassword;
  final String newPassword;

  ChangePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    };
  }
}

// 用戶角色常量
class UserRole {
  static const String owner = 'owner';     // 店家老闆
  static const String admin = 'admin';     // 管理員
  static const String manager = 'manager'; // 店長
  static const String staff = 'staff';     // 員工
} 