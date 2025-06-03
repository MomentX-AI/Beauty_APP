enum GoalType {
  revenue,
  revisit_rate,
  customer_count,
  service_count,
  profit_margin,
  custom,
}

enum GoalLevel {
  business,
  branch,
  staff,
}

extension GoalLevelExtension on GoalLevel {
  String get displayName {
    switch (this) {
      case GoalLevel.business:
        return '企業目標';
      case GoalLevel.branch:
        return '門店目標';
      case GoalLevel.staff:
        return '員工目標';
    }
  }

  String toJson() {
    return toString().split('.').last;
  }
}

extension GoalLevelFromString on GoalLevel {
  static GoalLevel fromString(String value) {
    return GoalLevel.values.firstWhere(
      (level) => level.toString().split('.').last == value,
      orElse: () => GoalLevel.business,
    );
  }
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
  final GoalLevel level;
  final String? branchId;  // 門店目標時使用
  final String? staffId;   // 員工目標時使用
  final String? description;

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
    this.level = GoalLevel.business,
    this.branchId,
    this.staffId,
    this.description,
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
      level: GoalLevelFromString.fromString(json['level'] as String? ?? 'business'),
      branchId: json['branchId'] as String?,
      staffId: json['staffId'] as String?,
      description: json['description'] as String?,
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
      'level': level.toJson(),
      if (branchId != null) 'branchId': branchId,
      if (staffId != null) 'staffId': staffId,
      if (description != null) 'description': description,
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
    GoalLevel? level,
    String? branchId,
    String? staffId,
    String? description,
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
      level: level ?? this.level,
      branchId: branchId ?? this.branchId,
      staffId: staffId ?? this.staffId,
      description: description ?? this.description,
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