enum ServiceCategory {
  lash,
  pmu,
  nail,
  hair,
  skin,
  other,
}

extension ServiceCategoryExtension on ServiceCategory {
  String get displayName {
    switch (this) {
      case ServiceCategory.lash:
        return '睫毛';
      case ServiceCategory.pmu:
        return '半永久化妝';
      case ServiceCategory.nail:
        return '美甲';
      case ServiceCategory.hair:
        return '美髮';
      case ServiceCategory.skin:
        return '美容';
      case ServiceCategory.other:
        return '其他';
    }
  }

  String toJson() {
    return toString().split('.').last;
  }

  static ServiceCategory fromString(String value) {
    return ServiceCategory.values.firstWhere(
      (category) => category.toString().split('.').last == value,
      orElse: () => ServiceCategory.other,
    );
  }
}

class Service {
  final String id;
  final String businessId;
  final String name;
  final ServiceCategory category;
  final int duration; // 分鐘
  final int revisitPeriod; // 天
  final double price;
  final double profit;
  final String? description;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  Service({
    required this.id,
    required this.businessId,
    required this.name,
    required this.category,
    required this.duration,
    required this.revisitPeriod,
    required this.price,
    required this.profit,
    this.description,
    this.isArchived = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] as String,
      businessId: json['business_id'] as String,
      name: json['name'] as String,
      category: ServiceCategoryExtension.fromString(json['category'] as String),
      duration: json['duration'] as int,
      revisitPeriod: json['revisit_period'] as int,
      price: (json['price'] as num).toDouble(),
      profit: (json['profit'] as num).toDouble(),
      description: json['description'] as String?,
      isArchived: json['is_archived'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_id': businessId,
      'name': name,
      'category': category.toJson(),
      'duration': duration,
      'revisit_period': revisitPeriod,
      'price': price,
      'profit': profit,
      'description': description,
      'is_archived': isArchived,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Service copyWith({
    String? id,
    String? businessId,
    String? name,
    ServiceCategory? category,
    int? duration,
    int? revisitPeriod,
    double? price,
    double? profit,
    String? description,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Service(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      name: name ?? this.name,
      category: category ?? this.category,
      duration: duration ?? this.duration,
      revisitPeriod: revisitPeriod ?? this.revisitPeriod,
      price: price ?? this.price,
      profit: profit ?? this.profit,
      description: description ?? this.description,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 