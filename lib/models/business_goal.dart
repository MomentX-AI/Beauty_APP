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
  final GoalType type;
  final double target;
  final double current;
  final double percentage;
  final DateTime deadline;
  final DateTime createdAt;
  final DateTime updatedAt;

  BusinessGoal({
    required this.id,
    required this.businessId,
    required this.type,
    required this.target,
    required this.current,
    required this.deadline,
    double? percentage,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : percentage = percentage ?? calculatePercentage(current, target),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  static double calculatePercentage(double current, double target) {
    if (target <= 0) return 0;
    double result = (current / target) * 100;
    return result > 100 ? 100 : result;
  }

  factory BusinessGoal.fromJson(Map<String, dynamic> json) {
    return BusinessGoal(
      id: json['id'],
      businessId: json['business_id'],
      type: GoalTypeExtension.fromString(json['type']),
      target: (json['target'] as num).toDouble(),
      current: (json['current'] as num).toDouble(),
      percentage: (json['percentage'] as num).toDouble(),
      deadline: DateTime.parse(json['deadline']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_id': businessId,
      'type': type.toJson(),
      'target': target,
      'current': current,
      'percentage': percentage,
      'deadline': deadline.toIso8601String().split('T').first, // Format as YYYY-MM-DD
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  BusinessGoal copyWith({
    String? id,
    String? businessId,
    GoalType? type,
    double? target,
    double? current,
    double? percentage,
    DateTime? deadline,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BusinessGoal(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      type: type ?? this.type,
      target: target ?? this.target,
      current: current ?? this.current,
      percentage: percentage ?? this.percentage,
      deadline: deadline ?? this.deadline,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Recalculate percentage based on current and target values
  BusinessGoal recalculatePercentage() {
    return copyWith(
      percentage: calculatePercentage(current, target),
    );
  }
} 