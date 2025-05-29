enum PlanType {
  basic,
  business,
}

class SubscriptionPlan {
  final String id;
  final PlanType type;
  final String name;
  final String description;
  final double pricePerStaffPerMonth;
  final int maxBranches;
  final List<String> features;
  final bool isActive;

  const SubscriptionPlan({
    required this.id,
    required this.type,
    required this.name,
    required this.description,
    required this.pricePerStaffPerMonth,
    required this.maxBranches,
    required this.features,
    this.isActive = true,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'],
      type: PlanType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PlanType.basic,
      ),
      name: json['name'],
      description: json['description'],
      pricePerStaffPerMonth: json['pricePerStaffPerMonth'].toDouble(),
      maxBranches: json['maxBranches'],
      features: List<String>.from(json['features']),
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'name': name,
      'description': description,
      'pricePerStaffPerMonth': pricePerStaffPerMonth,
      'maxBranches': maxBranches,
      'features': features,
      'isActive': isActive,
    };
  }

  String get typeDisplayName {
    switch (type) {
      case PlanType.basic:
        return 'Basic';
      case PlanType.business:
        return 'Business';
    }
  }

  String get formattedPrice {
    return 'NT\$ ${pricePerStaffPerMonth.toInt()}';
  }

  static List<SubscriptionPlan> getAvailablePlans() {
    return [
      const SubscriptionPlan(
        id: 'basic',
        type: PlanType.basic,
        name: 'Basic 基礎版',
        description: '適合單一門店的美容業者',
        pricePerStaffPerMonth: 300.0,
        maxBranches: 1,
        features: [
          '單一門店管理',
          '基礎預約管理',
          '客戶資料管理',
          '員工管理',
          '基礎報表分析',
          'AI 助理',
          '基礎技術支援',
        ],
      ),
      const SubscriptionPlan(
        id: 'business',
        type: PlanType.business,
        name: 'Business 商業版',
        description: '適合多門店連鎖美容業者',
        pricePerStaffPerMonth: 450.0,
        maxBranches: -1, // -1 表示無限制
        features: [
          '多門店管理',
          '進階預約管理',
          '客戶資料管理',
          '員工管理與排班',
          '進階報表分析',
          'AI 助理',
          '多門店庫存管理',
          '進階權限控制',
          '優先技術支援',
          '自訂報表',
        ],
      ),
    ];
  }

  bool get isUnlimitedBranches => maxBranches == -1;

  String get branchLimitDescription {
    if (isUnlimitedBranches) {
      return '無限制門店';
    }
    return '$maxBranches 個門店';
  }
} 