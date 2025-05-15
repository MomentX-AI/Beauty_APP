class ServiceHistory {
  final String id;
  final String customerId;
  final String serviceId;
  final String businessId;
  final DateTime serviceDate;
  final double price;
  final String photos; // JSON array of photo URLs
  final String feedback;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? customer;
  final Map<String, dynamic>? service;

  ServiceHistory({
    required this.id,
    required this.customerId,
    required this.serviceId,
    required this.businessId,
    required this.serviceDate,
    required this.price,
    required this.photos,
    required this.feedback,
    required this.createdAt,
    required this.updatedAt,
    this.customer,
    this.service,
  });

  factory ServiceHistory.fromJson(Map<String, dynamic> json) {
    return ServiceHistory(
      id: json['id'],
      customerId: json['customer_id'],
      serviceId: json['service_id'],
      businessId: json['business_id'],
      serviceDate: DateTime.parse(json['service_date']),
      price: json['price']?.toDouble() ?? 0.0,
      photos: json['photos'] ?? '[]',
      feedback: json['feedback'] ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : DateTime.now(),
      customer: json['customer'],
      service: json['service'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'service_id': serviceId,
      'business_id': businessId,
      'service_date': serviceDate.toIso8601String(),
      'price': price,
      'photos': photos,
      'feedback': feedback,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
} 