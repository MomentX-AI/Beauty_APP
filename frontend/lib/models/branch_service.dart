class BranchService {
  final String id;
  final String branchId;
  final String serviceId;
  final bool isAvailable;
  final double? customPrice; // 分店特定價格，如果為null則使用服務的默認價格
  final double? customProfit; // 分店特定利潤，如果為null則使用服務的默認利潤
  final DateTime createdAt;
  final DateTime updatedAt;

  BranchService({
    required this.id,
    required this.branchId,
    required this.serviceId,
    this.isAvailable = true,
    this.customPrice,
    this.customProfit,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BranchService.fromJson(Map<String, dynamic> json) {
    return BranchService(
      id: json['id'] as String,
      branchId: json['branch_id'] as String,
      serviceId: json['service_id'] as String,
      isAvailable: json['is_available'] as bool? ?? true,
      customPrice: json['custom_price'] != null 
          ? (json['custom_price'] as num).toDouble() 
          : null,
      customProfit: json['custom_profit'] != null 
          ? (json['custom_profit'] as num).toDouble() 
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'branch_id': branchId,
      'service_id': serviceId,
      'is_available': isAvailable,
      'custom_price': customPrice,
      'custom_profit': customProfit,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  BranchService copyWith({
    String? id,
    String? branchId,
    String? serviceId,
    bool? isAvailable,
    double? customPrice,
    double? customProfit,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BranchService(
      id: id ?? this.id,
      branchId: branchId ?? this.branchId,
      serviceId: serviceId ?? this.serviceId,
      isAvailable: isAvailable ?? this.isAvailable,
      customPrice: customPrice ?? this.customPrice,
      customProfit: customProfit ?? this.customProfit,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 