import 'package:flutter/material.dart';

enum ShiftType {
  morning,    // 早班
  afternoon,  // 午班
  evening,    // 晚班
  full_day,   // 全日班
  off,        // 休假
}

enum ScheduleStatus {
  scheduled,  // 已排班
  confirmed,  // 已確認
  requested_off, // 申請休假
  sick_leave, // 病假
  personal_leave, // 事假
}

class StaffSchedule {
  final String id;
  final String staffId;
  final String branchId;
  final DateTime date;
  final ShiftType shiftType;
  final String? startTime; // 格式: "09:00"
  final String? endTime;   // 格式: "18:00"
  final ScheduleStatus status;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  // 關聯對象
  final String? staffName;
  final String? branchName;

  StaffSchedule({
    required this.id,
    required this.staffId,
    required this.branchId,
    required this.date,
    required this.shiftType,
    this.startTime,
    this.endTime,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.staffName,
    this.branchName,
  });

  factory StaffSchedule.fromJson(Map<String, dynamic> json) {
    return StaffSchedule(
      id: json['id'] as String,
      staffId: json['staff_id'] as String,
      branchId: json['branch_id'] as String,
      date: DateTime.parse(json['date'] as String),
      shiftType: _parseShiftType(json['shift_type'] as String),
      startTime: json['start_time'] as String?,
      endTime: json['end_time'] as String?,
      status: _parseScheduleStatus(json['status'] as String),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      staffName: json['staff_name'] as String?,
      branchName: json['branch_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'staff_id': staffId,
      'branch_id': branchId,
      'date': date.toIso8601String().split('T')[0], // 只保留日期部分
      'shift_type': _shiftTypeToString(shiftType),
      'start_time': startTime,
      'end_time': endTime,
      'status': _scheduleStatusToString(status),
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  static ShiftType _parseShiftType(String typeStr) {
    switch (typeStr) {
      case 'morning':
        return ShiftType.morning;
      case 'afternoon':
        return ShiftType.afternoon;
      case 'evening':
        return ShiftType.evening;
      case 'full_day':
        return ShiftType.full_day;
      case 'off':
        return ShiftType.off;
      default:
        return ShiftType.full_day;
    }
  }

  static ScheduleStatus _parseScheduleStatus(String statusStr) {
    switch (statusStr) {
      case 'scheduled':
        return ScheduleStatus.scheduled;
      case 'confirmed':
        return ScheduleStatus.confirmed;
      case 'requested_off':
        return ScheduleStatus.requested_off;
      case 'sick_leave':
        return ScheduleStatus.sick_leave;
      case 'personal_leave':
        return ScheduleStatus.personal_leave;
      default:
        return ScheduleStatus.scheduled;
    }
  }

  static String _shiftTypeToString(ShiftType type) {
    switch (type) {
      case ShiftType.morning:
        return 'morning';
      case ShiftType.afternoon:
        return 'afternoon';
      case ShiftType.evening:
        return 'evening';
      case ShiftType.full_day:
        return 'full_day';
      case ShiftType.off:
        return 'off';
    }
  }

  static String _scheduleStatusToString(ScheduleStatus status) {
    switch (status) {
      case ScheduleStatus.scheduled:
        return 'scheduled';
      case ScheduleStatus.confirmed:
        return 'confirmed';
      case ScheduleStatus.requested_off:
        return 'requested_off';
      case ScheduleStatus.sick_leave:
        return 'sick_leave';
      case ScheduleStatus.personal_leave:
        return 'personal_leave';
    }
  }

  StaffSchedule copyWith({
    String? id,
    String? staffId,
    String? branchId,
    DateTime? date,
    ShiftType? shiftType,
    String? startTime,
    String? endTime,
    ScheduleStatus? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? staffName,
    String? branchName,
  }) {
    return StaffSchedule(
      id: id ?? this.id,
      staffId: staffId ?? this.staffId,
      branchId: branchId ?? this.branchId,
      date: date ?? this.date,
      shiftType: shiftType ?? this.shiftType,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      staffName: staffName ?? this.staffName,
      branchName: branchName ?? this.branchName,
    );
  }

  // Helper getters
  String get shiftTypeText {
    switch (shiftType) {
      case ShiftType.morning:
        return '早班';
      case ShiftType.afternoon:
        return '午班';
      case ShiftType.evening:
        return '晚班';
      case ShiftType.full_day:
        return '全日班';
      case ShiftType.off:
        return '休假';
    }
  }

  String get statusText {
    switch (status) {
      case ScheduleStatus.scheduled:
        return '已排班';
      case ScheduleStatus.confirmed:
        return '已確認';
      case ScheduleStatus.requested_off:
        return '申請休假';
      case ScheduleStatus.sick_leave:
        return '病假';
      case ScheduleStatus.personal_leave:
        return '事假';
    }
  }

  Color get statusColor {
    switch (status) {
      case ScheduleStatus.scheduled:
        return Colors.blue;
      case ScheduleStatus.confirmed:
        return Colors.green;
      case ScheduleStatus.requested_off:
        return Colors.orange;
      case ScheduleStatus.sick_leave:
        return Colors.red;
      case ScheduleStatus.personal_leave:
        return Colors.purple;
    }
  }

  Color get shiftTypeColor {
    switch (shiftType) {
      case ShiftType.morning:
        return Colors.orange;
      case ShiftType.afternoon:
        return Colors.blue;
      case ShiftType.evening:
        return Colors.indigo;
      case ShiftType.full_day:
        return Colors.green;
      case ShiftType.off:
        return Colors.grey;
    }
  }

  String get timeRange {
    if (shiftType == ShiftType.off) return '休假';
    if (startTime != null && endTime != null) {
      return '$startTime - $endTime';
    }
    
    // 預設時間範圍
    switch (shiftType) {
      case ShiftType.morning:
        return '09:00 - 13:00';
      case ShiftType.afternoon:
        return '13:00 - 18:00';
      case ShiftType.evening:
        return '18:00 - 22:00';
      case ShiftType.full_day:
        return '09:00 - 18:00';
      case ShiftType.off:
        return '休假';
    }
  }

  bool get isWorkingDay => shiftType != ShiftType.off;
  bool get isOffDay => shiftType == ShiftType.off;
} 