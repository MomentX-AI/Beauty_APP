class BranchPerformance {
  final String branchId;
  final String branchName;
  final double monthlyRevenue;
  final int appointmentCount;
  final int customerCount;
  final double averageServicePrice;
  final double occupancyRate; // 預約率
  final int staffCount;
  final DateTime periodStart;
  final DateTime periodEnd;

  BranchPerformance({
    required this.branchId,
    required this.branchName,
    required this.monthlyRevenue,
    required this.appointmentCount,
    required this.customerCount,
    required this.averageServicePrice,
    required this.occupancyRate,
    required this.staffCount,
    required this.periodStart,
    required this.periodEnd,
  });

  factory BranchPerformance.fromJson(Map<String, dynamic> json) {
    return BranchPerformance(
      branchId: json['branch_id'] as String,
      branchName: json['branch_name'] as String,
      monthlyRevenue: (json['monthly_revenue'] as num).toDouble(),
      appointmentCount: json['appointment_count'] as int,
      customerCount: json['customer_count'] as int,
      averageServicePrice: (json['average_service_price'] as num).toDouble(),
      occupancyRate: (json['occupancy_rate'] as num).toDouble(),
      staffCount: json['staff_count'] as int,
      periodStart: DateTime.parse(json['period_start'] as String),
      periodEnd: DateTime.parse(json['period_end'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'branch_id': branchId,
      'branch_name': branchName,
      'monthly_revenue': monthlyRevenue,
      'appointment_count': appointmentCount,
      'customer_count': customerCount,
      'average_service_price': averageServicePrice,
      'occupancy_rate': occupancyRate,
      'staff_count': staffCount,
      'period_start': periodStart.toIso8601String(),
      'period_end': periodEnd.toIso8601String(),
    };
  }

  // 計算每員工平均營收
  double get revenuePerStaff => staffCount > 0 ? monthlyRevenue / staffCount : 0;

  // 計算每員工平均預約數
  double get appointmentsPerStaff => staffCount > 0 ? appointmentCount / staffCount : 0;
} 