import 'package:flutter/material.dart';

enum BillingStatus {
  pending,
  paid,
  overdue,
  cancelled,
  refunded,
}

enum PaymentMethod {
  creditCard,
  bankTransfer,
  cash,
  other,
}

class Billing {
  final String id;
  final String businessId;
  final String subscriptionId;
  final DateTime billingDate;
  final DateTime dueDate;
  final DateTime? paidDate;
  final BillingStatus status;
  final double amount;
  final double taxAmount;
  final double totalAmount;
  final PaymentMethod? paymentMethod;
  final String? paymentReference;
  final int staffCount;
  final String planName;
  final double pricePerStaff;
  final String? notes;
  final Map<String, dynamic>? metadata;

  const Billing({
    required this.id,
    required this.businessId,
    required this.subscriptionId,
    required this.billingDate,
    required this.dueDate,
    this.paidDate,
    required this.status,
    required this.amount,
    required this.taxAmount,
    required this.totalAmount,
    this.paymentMethod,
    this.paymentReference,
    required this.staffCount,
    required this.planName,
    required this.pricePerStaff,
    this.notes,
    this.metadata,
  });

  factory Billing.fromJson(Map<String, dynamic> json) {
    return Billing(
      id: json['id'],
      businessId: json['businessId'],
      subscriptionId: json['subscriptionId'],
      billingDate: DateTime.parse(json['billingDate']),
      dueDate: DateTime.parse(json['dueDate']),
      paidDate: json['paidDate'] != null ? DateTime.parse(json['paidDate']) : null,
      status: BillingStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => BillingStatus.pending,
      ),
      amount: json['amount'].toDouble(),
      taxAmount: json['taxAmount'].toDouble(),
      totalAmount: json['totalAmount'].toDouble(),
      paymentMethod: json['paymentMethod'] != null
          ? PaymentMethod.values.firstWhere(
              (e) => e.name == json['paymentMethod'],
              orElse: () => PaymentMethod.other,
            )
          : null,
      paymentReference: json['paymentReference'],
      staffCount: json['staffCount'],
      planName: json['planName'],
      pricePerStaff: json['pricePerStaff'].toDouble(),
      notes: json['notes'],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'businessId': businessId,
      'subscriptionId': subscriptionId,
      'billingDate': billingDate.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'paidDate': paidDate?.toIso8601String(),
      'status': status.name,
      'amount': amount,
      'taxAmount': taxAmount,
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod?.name,
      'paymentReference': paymentReference,
      'staffCount': staffCount,
      'planName': planName,
      'pricePerStaff': pricePerStaff,
      'notes': notes,
      'metadata': metadata,
    };
  }

  String get statusDisplayName {
    switch (status) {
      case BillingStatus.pending:
        return '待付款';
      case BillingStatus.paid:
        return '已付款';
      case BillingStatus.overdue:
        return '逾期未付';
      case BillingStatus.cancelled:
        return '已取消';
      case BillingStatus.refunded:
        return '已退款';
    }
  }

  Color get statusColor {
    switch (status) {
      case BillingStatus.pending:
        return const Color(0xFFFF9800);
      case BillingStatus.paid:
        return const Color(0xFF4CAF50);
      case BillingStatus.overdue:
        return const Color(0xFFF44336);
      case BillingStatus.cancelled:
        return const Color(0xFF9E9E9E);
      case BillingStatus.refunded:
        return const Color(0xFF2196F3);
    }
  }

  String get paymentMethodDisplayName {
    if (paymentMethod == null) return '未設定';
    switch (paymentMethod!) {
      case PaymentMethod.creditCard:
        return '信用卡';
      case PaymentMethod.bankTransfer:
        return '銀行轉帳';
      case PaymentMethod.cash:
        return '現金';
      case PaymentMethod.other:
        return '其他';
    }
  }

  bool get isPaid => status == BillingStatus.paid;
  bool get isPending => status == BillingStatus.pending;
  bool get isOverdue => status == BillingStatus.overdue;

  int get daysUntilDue {
    final now = DateTime.now();
    if (dueDate.isBefore(now)) return 0;
    return dueDate.difference(now).inDays;
  }

  int get daysOverdue {
    final now = DateTime.now();
    if (dueDate.isAfter(now)) return 0;
    return now.difference(dueDate).inDays;
  }

  String get formattedBillingDate => '${billingDate.year}/${billingDate.month.toString().padLeft(2, '0')}/${billingDate.day.toString().padLeft(2, '0')}';
  String get formattedDueDate => '${dueDate.year}/${dueDate.month.toString().padLeft(2, '0')}/${dueDate.day.toString().padLeft(2, '0')}';
  String get formattedPaidDate => paidDate != null ? '${paidDate!.year}/${paidDate!.month.toString().padLeft(2, '0')}/${paidDate!.day.toString().padLeft(2, '0')}' : '';

  String get formattedAmount => 'NT\$ ${amount.toInt()}';
  String get formattedTaxAmount => 'NT\$ ${taxAmount.toInt()}';
  String get formattedTotalAmount => 'NT\$ ${totalAmount.toInt()}';

  Billing copyWith({
    String? id,
    String? businessId,
    String? subscriptionId,
    DateTime? billingDate,
    DateTime? dueDate,
    DateTime? paidDate,
    BillingStatus? status,
    double? amount,
    double? taxAmount,
    double? totalAmount,
    PaymentMethod? paymentMethod,
    String? paymentReference,
    int? staffCount,
    String? planName,
    double? pricePerStaff,
    String? notes,
    Map<String, dynamic>? metadata,
  }) {
    return Billing(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      subscriptionId: subscriptionId ?? this.subscriptionId,
      billingDate: billingDate ?? this.billingDate,
      dueDate: dueDate ?? this.dueDate,
      paidDate: paidDate ?? this.paidDate,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      taxAmount: taxAmount ?? this.taxAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentReference: paymentReference ?? this.paymentReference,
      staffCount: staffCount ?? this.staffCount,
      planName: planName ?? this.planName,
      pricePerStaff: pricePerStaff ?? this.pricePerStaff,
      notes: notes ?? this.notes,
      metadata: metadata ?? this.metadata,
    );
  }
} 