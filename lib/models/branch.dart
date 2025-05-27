class Branch {
  final String id;
  final String businessId;
  final String name;
  final String? contactPhone;
  final String? address;
  final bool isDefault;
  final String status; // active, inactive, closed
  final String? operatingHoursStart; // HH:MM format
  final String? operatingHoursEnd; // HH:MM format
  final DateTime createdAt;
  final DateTime updatedAt;

  Branch({
    required this.id,
    required this.businessId,
    required this.name,
    this.contactPhone,
    this.address,
    this.isDefault = false,
    this.status = 'active',
    this.operatingHoursStart,
    this.operatingHoursEnd,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['id'] as String,
      businessId: json['business_id'] as String,
      name: json['name'] as String,
      contactPhone: json['contact_phone'] as String?,
      address: json['address'] as String?,
      isDefault: json['is_default'] as bool? ?? false,
      status: json['status'] as String? ?? 'active',
      operatingHoursStart: json['operating_hours_start'] as String?,
      operatingHoursEnd: json['operating_hours_end'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_id': businessId,
      'name': name,
      'contact_phone': contactPhone,
      'address': address,
      'is_default': isDefault,
      'status': status,
      'operating_hours_start': operatingHoursStart,
      'operating_hours_end': operatingHoursEnd,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Branch copyWith({
    String? id,
    String? businessId,
    String? name,
    String? contactPhone,
    String? address,
    bool? isDefault,
    String? status,
    String? operatingHoursStart,
    String? operatingHoursEnd,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Branch(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      name: name ?? this.name,
      contactPhone: contactPhone ?? this.contactPhone,
      address: address ?? this.address,
      isDefault: isDefault ?? this.isDefault,
      status: status ?? this.status,
      operatingHoursStart: operatingHoursStart ?? this.operatingHoursStart,
      operatingHoursEnd: operatingHoursEnd ?? this.operatingHoursEnd,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 