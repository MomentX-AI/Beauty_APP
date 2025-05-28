import 'customer.dart';
import 'service.dart';
import 'branch.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

enum AppointmentStatus {
  booked,
  confirmed,
  checked_in,
  completed,
  cancelled,
  no_show,
}

class Appointment {
  final String id;
  final String businessId;
  final String branchId;
  final String customerId;
  final String serviceId;
  final DateTime startTime;
  final DateTime endTime;
  final AppointmentStatus status;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Customer? customer;
  final Service? service;
  final Branch? branch;

  Appointment({
    required this.id,
    required this.businessId,
    required this.branchId,
    required this.customerId,
    required this.serviceId,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.note,
    required this.createdAt,
    required this.updatedAt,
    this.customer,
    this.service,
    this.branch,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    AppointmentStatus parseStatus(String statusStr) {
      // Convert snake_case to camelCase for matching with enum
      switch (statusStr) {
        case 'booked':
          return AppointmentStatus.booked;
        case 'confirmed':
          return AppointmentStatus.confirmed;
        case 'checked_in':
          return AppointmentStatus.checked_in;
        case 'completed':
          return AppointmentStatus.completed;
        case 'cancelled':
          return AppointmentStatus.cancelled;
        case 'no_show':
          return AppointmentStatus.no_show;
        default:
          return AppointmentStatus.booked; // Default fallback
      }
    }

    return Appointment(
      id: json['id'] as String,
      businessId: json['business_id'] as String,
      branchId: json['branch_id'] as String,
      customerId: json['customer_id'] as String,
      serviceId: json['service_id'] as String,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      status: parseStatus(json['status'] as String),
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      customer: json['customer'] != null ? Customer.fromJson(json['customer']) : null,
      service: json['service'] != null ? Service.fromJson(json['service']) : null,
      branch: json['branch'] != null ? Branch.fromJson(json['branch']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    String statusToString(AppointmentStatus status) {
      switch (status) {
        case AppointmentStatus.booked:
          return 'booked';
        case AppointmentStatus.confirmed:
          return 'confirmed';
        case AppointmentStatus.checked_in:
          return 'checked_in';
        case AppointmentStatus.completed:
          return 'completed';
        case AppointmentStatus.cancelled:
          return 'cancelled';
        case AppointmentStatus.no_show:
          return 'no_show';
        default:
          return 'booked';
      }
    }

    return {
      'id': id,
      'business_id': businessId,
      'branch_id': branchId,
      'customer_id': customerId,
      'service_id': serviceId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'status': statusToString(status),
      'note': note,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'customer': customer?.toJson(),
      'service': service?.toJson(),
      'branch': branch?.toJson(),
    };
  }

  Appointment copyWith({
    String? id,
    String? businessId,
    String? branchId,
    String? customerId,
    String? serviceId,
    DateTime? startTime,
    DateTime? endTime,
    AppointmentStatus? status,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
    Customer? customer,
    Service? service,
    Branch? branch,
  }) {
    return Appointment(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      branchId: branchId ?? this.branchId,
      customerId: customerId ?? this.customerId,
      serviceId: serviceId ?? this.serviceId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      customer: customer ?? this.customer,
      service: service ?? this.service,
      branch: branch ?? this.branch,
    );
  }

  String get statusText {
    switch (status) {
      case AppointmentStatus.booked:
        return '已預約';
      case AppointmentStatus.confirmed:
        return '已確認';
      case AppointmentStatus.checked_in:
        return '報到中';
      case AppointmentStatus.completed:
        return '已完成';
      case AppointmentStatus.cancelled:
        return '已取消';
      case AppointmentStatus.no_show:
        return '未到';
    }
  }

  Color get statusColor {
    switch (status) {
      case AppointmentStatus.booked:
        return Colors.blue;
      case AppointmentStatus.confirmed:
        return Colors.green.shade600;
      case AppointmentStatus.checked_in:
        return Colors.amber.shade600;
      case AppointmentStatus.completed:
        return Colors.grey;
      case AppointmentStatus.cancelled:
        return Colors.red;
      case AppointmentStatus.no_show:
        return Colors.orange;
    }
  }

  String get customerName => customer?.name ?? '未知客戶';
  String get serviceName => service?.name ?? '未知服務';
  String get branchName => branch?.name ?? '未知門店';
  bool get isSpecialCustomer => customer?.isSpecialCustomer ?? false;
} 