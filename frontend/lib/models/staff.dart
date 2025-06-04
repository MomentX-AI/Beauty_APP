import 'package:flutter/material.dart';

enum StaffRole {
  owner,
  manager,
  senior_stylist,
  stylist,
  assistant,
  receptionist,
}

enum StaffStatus {
  active,
  inactive,
  on_leave,
}

class Staff {
  final String id;
  final String businessId;
  final String name;
  final String? email;
  final String? phone;
  final StaffRole role;
  final StaffStatus status;
  final String? avatarUrl;
  final DateTime? birthDate;
  final DateTime hireDate;
  final String? address;
  final String? emergencyContact;
  final String? emergencyPhone;
  final String? notes;
  final List<String> branchIds; // 員工可服務的分店ID列表
  final List<String> serviceIds; // 員工可提供的服務ID列表
  final DateTime createdAt;
  final DateTime updatedAt;

  Staff({
    required this.id,
    required this.businessId,
    required this.name,
    this.email,
    this.phone,
    required this.role,
    this.status = StaffStatus.active,
    this.avatarUrl,
    this.birthDate,
    required this.hireDate,
    this.address,
    this.emergencyContact,
    this.emergencyPhone,
    this.notes,
    this.branchIds = const [],
    this.serviceIds = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      id: json['id'] as String,
      businessId: json['business_id'] as String,
      name: json['name'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      role: _parseRole(json['role'] as String),
      status: _parseStatus(json['status'] as String),
      avatarUrl: json['avatar_url'] as String?,
      birthDate: json['birth_date'] != null ? DateTime.parse(json['birth_date'] as String) : null,
      hireDate: DateTime.parse(json['hire_date'] as String),
      address: json['address'] as String?,
      emergencyContact: json['emergency_contact'] as String?,
      emergencyPhone: json['emergency_phone'] as String?,
      notes: json['notes'] as String?,
      branchIds: List<String>.from(json['branch_ids'] ?? []),
      serviceIds: List<String>.from(json['service_ids'] ?? []),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_id': businessId,
      'name': name,
      'email': email,
      'phone': phone,
      'role': _roleToString(role),
      'status': _statusToString(status),
      'avatar_url': avatarUrl,
      'birth_date': birthDate?.toIso8601String(),
      'hire_date': hireDate.toIso8601String(),
      'address': address,
      'emergency_contact': emergencyContact,
      'emergency_phone': emergencyPhone,
      'notes': notes,
      'branch_ids': branchIds,
      'service_ids': serviceIds,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Staff copyWith({
    String? id,
    String? businessId,
    String? name,
    String? email,
    String? phone,
    StaffRole? role,
    StaffStatus? status,
    String? avatarUrl,
    DateTime? birthDate,
    DateTime? hireDate,
    String? address,
    String? emergencyContact,
    String? emergencyPhone,
    String? notes,
    List<String>? branchIds,
    List<String>? serviceIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Staff(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      status: status ?? this.status,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      birthDate: birthDate ?? this.birthDate,
      hireDate: hireDate ?? this.hireDate,
      address: address ?? this.address,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      emergencyPhone: emergencyPhone ?? this.emergencyPhone,
      notes: notes ?? this.notes,
      branchIds: branchIds ?? this.branchIds,
      serviceIds: serviceIds ?? this.serviceIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static StaffRole _parseRole(String roleStr) {
    switch (roleStr) {
      case 'owner':
        return StaffRole.owner;
      case 'manager':
        return StaffRole.manager;
      case 'senior_stylist':
        return StaffRole.senior_stylist;
      case 'stylist':
        return StaffRole.stylist;
      case 'assistant':
        return StaffRole.assistant;
      case 'receptionist':
        return StaffRole.receptionist;
      default:
        return StaffRole.stylist;
    }
  }

  static StaffStatus _parseStatus(String statusStr) {
    switch (statusStr) {
      case 'active':
        return StaffStatus.active;
      case 'inactive':
        return StaffStatus.inactive;
      case 'on_leave':
        return StaffStatus.on_leave;
      default:
        return StaffStatus.active;
    }
  }

  static String _roleToString(StaffRole role) {
    switch (role) {
      case StaffRole.owner:
        return 'owner';
      case StaffRole.manager:
        return 'manager';
      case StaffRole.senior_stylist:
        return 'senior_stylist';
      case StaffRole.stylist:
        return 'stylist';
      case StaffRole.assistant:
        return 'assistant';
      case StaffRole.receptionist:
        return 'receptionist';
    }
  }

  static String _statusToString(StaffStatus status) {
    switch (status) {
      case StaffStatus.active:
        return 'active';
      case StaffStatus.inactive:
        return 'inactive';
      case StaffStatus.on_leave:
        return 'on_leave';
    }
  }

  String get roleText {
    switch (role) {
      case StaffRole.owner:
        return '店主';
      case StaffRole.manager:
        return '經理';
      case StaffRole.senior_stylist:
        return '資深設計師';
      case StaffRole.stylist:
        return '設計師';
      case StaffRole.assistant:
        return '助理';
      case StaffRole.receptionist:
        return '接待員';
    }
  }

  String get statusText {
    switch (status) {
      case StaffStatus.active:
        return '在職';
      case StaffStatus.inactive:
        return '離職';
      case StaffStatus.on_leave:
        return '請假';
    }
  }

  Color get statusColor {
    switch (status) {
      case StaffStatus.active:
        return Colors.green;
      case StaffStatus.inactive:
        return Colors.red;
      case StaffStatus.on_leave:
        return Colors.orange;
    }
  }

  Color get roleColor {
    switch (role) {
      case StaffRole.owner:
        return Colors.purple;
      case StaffRole.manager:
        return Colors.blue;
      case StaffRole.senior_stylist:
        return Colors.teal;
      case StaffRole.stylist:
        return Colors.green;
      case StaffRole.assistant:
        return Colors.orange;
      case StaffRole.receptionist:
        return Colors.grey;
    }
  }
} 