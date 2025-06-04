class BranchSpecialDay {
  final String id;
  final String branchId;
  final DateTime date;
  final bool isOpen;
  final String? operatingHoursStart; // HH:MM format
  final String? operatingHoursEnd; // HH:MM format
  final String? reason;
  final DateTime createdAt;
  final DateTime updatedAt;

  BranchSpecialDay({
    required this.id,
    required this.branchId,
    required this.date,
    required this.isOpen,
    this.operatingHoursStart,
    this.operatingHoursEnd,
    this.reason,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BranchSpecialDay.fromJson(Map<String, dynamic> json) {
    return BranchSpecialDay(
      id: json['id'] as String,
      branchId: json['branch_id'] as String,
      date: DateTime.parse(json['date'] as String),
      isOpen: json['is_open'] as bool,
      operatingHoursStart: json['operating_hours_start'] as String?,
      operatingHoursEnd: json['operating_hours_end'] as String?,
      reason: json['reason'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'branch_id': branchId,
      'date': date.toIso8601String().split('T')[0], // YYYY-MM-DD format
      'is_open': isOpen,
      'operating_hours_start': operatingHoursStart,
      'operating_hours_end': operatingHoursEnd,
      'reason': reason,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  BranchSpecialDay copyWith({
    String? id,
    String? branchId,
    DateTime? date,
    bool? isOpen,
    String? operatingHoursStart,
    String? operatingHoursEnd,
    String? reason,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BranchSpecialDay(
      id: id ?? this.id,
      branchId: branchId ?? this.branchId,
      date: date ?? this.date,
      isOpen: isOpen ?? this.isOpen,
      operatingHoursStart: operatingHoursStart ?? this.operatingHoursStart,
      operatingHoursEnd: operatingHoursEnd ?? this.operatingHoursEnd,
      reason: reason ?? this.reason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 