class StaffPerformanceByBranch {
  final String branchId;
  final String branchName;
  final double revenue;
  final int appointmentCount;
  final int customerCount;
  final double averageServicePrice;
  final List<ServicePerformance> servicePerformances;

  StaffPerformanceByBranch({
    required this.branchId,
    required this.branchName,
    required this.revenue,
    required this.appointmentCount,
    required this.customerCount,
    required this.averageServicePrice,
    required this.servicePerformances,
  });

  factory StaffPerformanceByBranch.fromJson(Map<String, dynamic> json) {
    return StaffPerformanceByBranch(
      branchId: json['branch_id'] as String,
      branchName: json['branch_name'] as String,
      revenue: (json['revenue'] as num).toDouble(),
      appointmentCount: json['appointment_count'] as int,
      customerCount: json['customer_count'] as int,
      averageServicePrice: (json['average_service_price'] as num).toDouble(),
      servicePerformances: (json['service_performances'] as List<dynamic>)
          .map((e) => ServicePerformance.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'branch_id': branchId,
      'branch_name': branchName,
      'revenue': revenue,
      'appointment_count': appointmentCount,
      'customer_count': customerCount,
      'average_service_price': averageServicePrice,
      'service_performances': servicePerformances.map((e) => e.toJson()).toList(),
    };
  }
}

class ServicePerformance {
  final String serviceId;
  final String serviceName;
  final String serviceCategory;
  final double revenue;
  final int appointmentCount;
  final double averagePrice;
  final double revenuePercentage; // 在该员工总收入中的占比

  ServicePerformance({
    required this.serviceId,
    required this.serviceName,
    required this.serviceCategory,
    required this.revenue,
    required this.appointmentCount,
    required this.averagePrice,
    required this.revenuePercentage,
  });

  factory ServicePerformance.fromJson(Map<String, dynamic> json) {
    return ServicePerformance(
      serviceId: json['service_id'] as String,
      serviceName: json['service_name'] as String,
      serviceCategory: json['service_category'] as String,
      revenue: (json['revenue'] as num).toDouble(),
      appointmentCount: json['appointment_count'] as int,
      averagePrice: (json['average_price'] as num).toDouble(),
      revenuePercentage: (json['revenue_percentage'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'service_id': serviceId,
      'service_name': serviceName,
      'service_category': serviceCategory,
      'revenue': revenue,
      'appointment_count': appointmentCount,
      'average_price': averagePrice,
      'revenue_percentage': revenuePercentage,
    };
  }
}

class StaffPerformanceAnalysis {
  final String staffId;
  final String staffName;
  final String role;
  final String? avatarUrl;
  final double totalRevenue;
  final int totalAppointmentCount;
  final int totalCustomerCount;
  final double averageServicePrice;
  final DateTime periodStart;
  final DateTime periodEnd;
  
  // 按门店分解的绩效
  final List<StaffPerformanceByBranch> branchPerformances;
  
  // 总体服务绩效（跨所有门店）
  final List<ServicePerformance> overallServicePerformances;

  StaffPerformanceAnalysis({
    required this.staffId,
    required this.staffName,
    required this.role,
    this.avatarUrl,
    required this.totalRevenue,
    required this.totalAppointmentCount,
    required this.totalCustomerCount,
    required this.averageServicePrice,
    required this.periodStart,
    required this.periodEnd,
    required this.branchPerformances,
    required this.overallServicePerformances,
  });

  factory StaffPerformanceAnalysis.fromJson(Map<String, dynamic> json) {
    return StaffPerformanceAnalysis(
      staffId: json['staff_id'] as String,
      staffName: json['staff_name'] as String,
      role: json['role'] as String,
      avatarUrl: json['avatar_url'] as String?,
      totalRevenue: (json['total_revenue'] as num).toDouble(),
      totalAppointmentCount: json['total_appointment_count'] as int,
      totalCustomerCount: json['total_customer_count'] as int,
      averageServicePrice: (json['average_service_price'] as num).toDouble(),
      periodStart: DateTime.parse(json['period_start'] as String),
      periodEnd: DateTime.parse(json['period_end'] as String),
      branchPerformances: (json['branch_performances'] as List<dynamic>)
          .map((e) => StaffPerformanceByBranch.fromJson(e as Map<String, dynamic>))
          .toList(),
      overallServicePerformances: (json['overall_service_performances'] as List<dynamic>)
          .map((e) => ServicePerformance.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'staff_id': staffId,
      'staff_name': staffName,
      'role': role,
      'avatar_url': avatarUrl,
      'total_revenue': totalRevenue,
      'total_appointment_count': totalAppointmentCount,
      'total_customer_count': totalCustomerCount,
      'average_service_price': averageServicePrice,
      'period_start': periodStart.toIso8601String(),
      'period_end': periodEnd.toIso8601String(),
      'branch_performances': branchPerformances.map((e) => e.toJson()).toList(),
      'overall_service_performances': overallServicePerformances.map((e) => e.toJson()).toList(),
    };
  }

  // 获取主要收入来源门店
  StaffPerformanceByBranch? get topRevenueBranch {
    if (branchPerformances.isEmpty) return null;
    return branchPerformances.reduce((a, b) => a.revenue > b.revenue ? a : b);
  }

  // 获取主要收入来源服务
  ServicePerformance? get topRevenueService {
    if (overallServicePerformances.isEmpty) return null;
    return overallServicePerformances.reduce((a, b) => a.revenue > b.revenue ? a : b);
  }

  // 计算门店收入分布百分比
  List<BranchRevenueDistribution> get branchRevenueDistribution {
    if (totalRevenue == 0) return [];
    
    return branchPerformances.map((branch) {
      return BranchRevenueDistribution(
        branchId: branch.branchId,
        branchName: branch.branchName,
        revenue: branch.revenue,
        percentage: (branch.revenue / totalRevenue) * 100,
      );
    }).toList()
      ..sort((a, b) => b.revenue.compareTo(a.revenue));
  }

  // 获取角色显示名称
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

class BranchRevenueDistribution {
  final String branchId;
  final String branchName;
  final double revenue;
  final double percentage;

  BranchRevenueDistribution({
    required this.branchId,
    required this.branchName,
    required this.revenue,
    required this.percentage,
  });
} 