class Customer {
  final String id;
  final String businessId;
  final String name;
  final String? gender; // 可選字段
  final String? phone; // 可選字段
  final String? email; // 可選字段
  final bool isArchived;
  final bool needsMerge;
  final bool isSpecialCustomer;
  final String? source;
  final DateTime createdAt;
  final DateTime updatedAt;

  Customer({
    required this.id,
    required this.businessId,
    required this.name,
    this.gender,
    this.phone,
    this.email,
    this.isArchived = false,
    this.needsMerge = false,
    this.isSpecialCustomer = false,
    this.source,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      businessId: json['business_id'],
      name: json['name'],
      gender: json['gender'],
      phone: json['phone'],
      email: json['email'],
      isArchived: json['is_archived'] ?? false,
      needsMerge: json['needs_merge'] ?? false,
      isSpecialCustomer: json['is_special_customer'] ?? false,
      source: json['source'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_id': businessId,
      'name': name,
      'gender': gender,
      'phone': phone,
      'email': email,
      'is_archived': isArchived,
      'needs_merge': needsMerge,
      'is_special_customer': isSpecialCustomer,
      'source': source,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
} 