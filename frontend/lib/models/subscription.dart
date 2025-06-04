import 'package:flutter/material.dart';
import 'subscription_plan.dart';

enum SubscriptionStatus {
  active,
  expired,
  cancelled,
  trial,
}

class Subscription {
  final String id;
  final String businessId;
  final String planId;
  final SubscriptionPlan plan;
  final SubscriptionStatus status;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime? cancelledDate;
  final int staffCount;
  final double monthlyAmount;
  final bool autoRenewal;
  final Map<String, dynamic>? metadata;

  const Subscription({
    required this.id,
    required this.businessId,
    required this.planId,
    required this.plan,
    required this.status,
    required this.startDate,
    required this.endDate,
    this.cancelledDate,
    required this.staffCount,
    required this.monthlyAmount,
    this.autoRenewal = true,
    this.metadata,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'],
      businessId: json['businessId'],
      planId: json['planId'],
      plan: SubscriptionPlan.fromJson(json['plan']),
      status: SubscriptionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SubscriptionStatus.active,
      ),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      cancelledDate: json['cancelledDate'] != null 
          ? DateTime.parse(json['cancelledDate']) 
          : null,
      staffCount: json['staffCount'],
      monthlyAmount: json['monthlyAmount'].toDouble(),
      autoRenewal: json['autoRenewal'] ?? true,
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'businessId': businessId,
      'planId': planId,
      'plan': plan.toJson(),
      'status': status.name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'cancelledDate': cancelledDate?.toIso8601String(),
      'staffCount': staffCount,
      'monthlyAmount': monthlyAmount,
      'autoRenewal': autoRenewal,
      'metadata': metadata,
    };
  }

  String get statusDisplayName {
    switch (status) {
      case SubscriptionStatus.active:
        return '活躍';
      case SubscriptionStatus.expired:
        return '已過期';
      case SubscriptionStatus.cancelled:
        return '已取消';
      case SubscriptionStatus.trial:
        return '試用中';
    }
  }

  Color get statusColor {
    switch (status) {
      case SubscriptionStatus.active:
        return const Color(0xFF4CAF50);
      case SubscriptionStatus.expired:
        return const Color(0xFFF44336);
      case SubscriptionStatus.cancelled:
        return const Color(0xFF9E9E9E);
      case SubscriptionStatus.trial:
        return const Color(0xFF2196F3);
    }
  }

  bool get isActive => status == SubscriptionStatus.active;
  bool get isExpired => status == SubscriptionStatus.expired;
  bool get isCancelled => status == SubscriptionStatus.cancelled;
  bool get isTrial => status == SubscriptionStatus.trial;

  int get daysUntilExpiry {
    final now = DateTime.now();
    if (endDate.isBefore(now)) return 0;
    return endDate.difference(now).inDays;
  }

  bool get isExpiringSoon => daysUntilExpiry <= 7 && isActive;

  String get formattedStartDate => '${startDate.year}/${startDate.month.toString().padLeft(2, '0')}/${startDate.day.toString().padLeft(2, '0')}';
  String get formattedEndDate => '${endDate.year}/${endDate.month.toString().padLeft(2, '0')}/${endDate.day.toString().padLeft(2, '0')}';

  Subscription copyWith({
    String? id,
    String? businessId,
    String? planId,
    SubscriptionPlan? plan,
    SubscriptionStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? cancelledDate,
    int? staffCount,
    double? monthlyAmount,
    bool? autoRenewal,
    Map<String, dynamic>? metadata,
  }) {
    return Subscription(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      planId: planId ?? this.planId,
      plan: plan ?? this.plan,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      cancelledDate: cancelledDate ?? this.cancelledDate,
      staffCount: staffCount ?? this.staffCount,
      monthlyAmount: monthlyAmount ?? this.monthlyAmount,
      autoRenewal: autoRenewal ?? this.autoRenewal,
      metadata: metadata ?? this.metadata,
    );
  }
} 