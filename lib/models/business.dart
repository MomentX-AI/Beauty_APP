class Business {
  final String? id;
  final String name;
  final String description;
  final String address;
  final String phone;
  final String email;
  final String? logoUrl;
  final String? socialLinks;
  final String? taxId;
  final String? googleId;
  final String timezone;
  final DateTime? lastLoginAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Business({
    this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.phone,
    required this.email,
    this.logoUrl,
    this.socialLinks,
    this.taxId,
    this.googleId,
    String? timezone,
    this.lastLoginAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : timezone = timezone ?? 'Asia/Taipei',
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      address: json['address'],
      phone: json['phone'],
      email: json['email'],
      logoUrl: json['logo_url'],
      socialLinks: json['social_links'],
      taxId: json['tax_id'],
      googleId: json['google_id'],
      timezone: json['timezone'] ?? 'Asia/Taipei',
      lastLoginAt: json['last_login_at'] != null ? DateTime.parse(json['last_login_at']) : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'address': address,
      'phone': phone,
      'email': email,
      'logo_url': logoUrl,
      'social_links': socialLinks,
      'tax_id': taxId,
      'google_id': googleId,
      'timezone': timezone,
      'last_login_at': lastLoginAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Business copyWith({
    String? id,
    String? name,
    String? description,
    String? address,
    String? phone,
    String? email,
    String? logoUrl,
    String? socialLinks,
    String? taxId,
    String? googleId,
    String? timezone,
    DateTime? lastLoginAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Business(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      logoUrl: logoUrl ?? this.logoUrl,
      socialLinks: socialLinks ?? this.socialLinks,
      taxId: taxId ?? this.taxId,
      googleId: googleId ?? this.googleId,
      timezone: timezone ?? this.timezone,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 