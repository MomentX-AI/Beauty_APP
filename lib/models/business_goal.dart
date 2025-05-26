enum GoalType {
  revenue,
  revisit_rate,
  customer_count,
  service_count,
  profit_margin,
  custom,
}

extension GoalTypeExtension on GoalType {
  String get displayName {
    switch (this) {
      case GoalType.revenue:
        return '營業額';
      case GoalType.revisit_rate:
        return '回訪率';
      case GoalType.customer_count:
        return '客戶數';
      case GoalType.service_count:
        return '服務數';
      case GoalType.profit_margin:
        return '利潤率';
      case GoalType.custom:
        return '自定義';
    }
  }

  String toJson() {
    return toString().split('.').last;
  }
}

extension GoalTypeFromString on GoalType {
  static GoalType fromString(String value) {
    return GoalType.values.firstWhere(
      (type) => type.toString().split('.').last == value,
      orElse: () => GoalType.custom,
    );
  }
}

class BusinessGoal {
  final String id;
  final String businessId;
  final String title;
  final double currentValue;
  final double targetValue;
  final String unit;
  final DateTime startDate;
  final DateTime endDate;
  final GoalType type;

  BusinessGoal({
    required this.id,
    required this.businessId,
    required this.title,
    required this.currentValue,
    required this.targetValue,
    required this.unit,
    required this.startDate,
    required this.endDate,
    this.type = GoalType.custom,
  });

  factory BusinessGoal.fromJson(Map<String, dynamic> json) {
    return BusinessGoal(
      id: json['id'] as String,
      businessId: json['businessId'] as String,
      title: json['title'] as String,
      currentValue: (json['currentValue'] as num).toDouble(),
      targetValue: (json['targetValue'] as num).toDouble(),
      unit: json['unit'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      type: GoalTypeFromString.fromString(json['type'] as String? ?? 'custom'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'businessId': businessId,
      'title': title,
      'currentValue': currentValue,
      'targetValue': targetValue,
      'unit': unit,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'type': type.toJson(),
    };
  }

  BusinessGoal copyWith({
    String? id,
    String? businessId,
    String? title,
    double? currentValue,
    double? targetValue,
    String? unit,
    DateTime? startDate,
    DateTime? endDate,
    GoalType? type,
  }) {
    return BusinessGoal(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      title: title ?? this.title,
      currentValue: currentValue ?? this.currentValue,
      targetValue: targetValue ?? this.targetValue,
      unit: unit ?? this.unit,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      type: type ?? this.type,
    );
  }

  BusinessGoal recalculatePercentage() {
    // 如果目標值為0，避免除以0的錯誤
    if (targetValue == 0) {
      return this;
    }
    
    // 計算完成百分比
    final percentage = (currentValue / targetValue) * 100;
    
    // 如果完成百分比超過100%，則限制在100%
    final adjustedCurrentValue = percentage > 100 ? targetValue : currentValue;
    
    return copyWith(
      currentValue: adjustedCurrentValue,
    );
  }
} 