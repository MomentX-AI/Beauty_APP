class StaffPerformance {
  final String staffId;
  final String staffName;
  final String role;
  final String? avatarUrl;
  final double monthlyRevenue;
  final int appointmentCount;
  final int customerCount;
  final double averageServicePrice;
  final double customerSatisfactionScore; // 客戶滿意度分數 (1-5)
  final int completedAppointments;
  final int cancelledAppointments;
  final double attendanceRate; // 出勤率
  final DateTime periodStart;
  final DateTime periodEnd;

  StaffPerformance({
    required this.staffId,
    required this.staffName,
    required this.role,
    this.avatarUrl,
    required this.monthlyRevenue,
    required this.appointmentCount,
    required this.customerCount,
    required this.averageServicePrice,
    required this.customerSatisfactionScore,
    required this.completedAppointments,
    required this.cancelledAppointments,
    required this.attendanceRate,
    required this.periodStart,
    required this.periodEnd,
  });

  factory StaffPerformance.fromJson(Map<String, dynamic> json) {
    return StaffPerformance(
      staffId: json['staff_id'] as String,
      staffName: json['staff_name'] as String,
      role: json['role'] as String,
      avatarUrl: json['avatar_url'] as String?,
      monthlyRevenue: (json['monthly_revenue'] as num).toDouble(),
      appointmentCount: json['appointment_count'] as int,
      customerCount: json['customer_count'] as int,
      averageServicePrice: (json['average_service_price'] as num).toDouble(),
      customerSatisfactionScore: (json['customer_satisfaction_score'] as num).toDouble(),
      completedAppointments: json['completed_appointments'] as int,
      cancelledAppointments: json['cancelled_appointments'] as int,
      attendanceRate: (json['attendance_rate'] as num).toDouble(),
      periodStart: DateTime.parse(json['period_start'] as String),
      periodEnd: DateTime.parse(json['period_end'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'staff_id': staffId,
      'staff_name': staffName,
      'role': role,
      'avatar_url': avatarUrl,
      'monthly_revenue': monthlyRevenue,
      'appointment_count': appointmentCount,
      'customer_count': customerCount,
      'average_service_price': averageServicePrice,
      'customer_satisfaction_score': customerSatisfactionScore,
      'completed_appointments': completedAppointments,
      'cancelled_appointments': cancelledAppointments,
      'attendance_rate': attendanceRate,
      'period_start': periodStart.toIso8601String(),
      'period_end': periodEnd.toIso8601String(),
    };
  }

  // 計算完成率
  double get completionRate {
    final totalAppointments = completedAppointments + cancelledAppointments;
    return totalAppointments > 0 ? completedAppointments / totalAppointments : 0;
  }

  // 計算平均日營收
  double get dailyAverageRevenue {
    final days = periodEnd.difference(periodStart).inDays;
    return days > 0 ? monthlyRevenue / days : 0;
  }

  // 獲取角色顯示名稱
  String get roleDisplayName {
    switch (role) {
      case 'owner':
        return '店主';
      case 'manager':
        return '經理';
      case 'senior_stylist':
        return '資深設計師';
      case 'stylist':
        return '設計師';
      case 'assistant':
        return '助理';
      case 'receptionist':
        return '櫃檯';
      default:
        return role;
    }
  }
} 