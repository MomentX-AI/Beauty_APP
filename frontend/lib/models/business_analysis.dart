import 'dart:convert';

enum AnalysisType {
  revenue,
  customer,
  service,
  profit,
}

extension AnalysisTypeExtension on AnalysisType {
  String get displayName {
    switch (this) {
      case AnalysisType.revenue:
        return '營業額分析';
      case AnalysisType.customer:
        return '客戶分析';
      case AnalysisType.service:
        return '服務分析';
      case AnalysisType.profit:
        return '利潤分析';
    }
  }

  String toJson() {
    return toString().split('.').last;
  }

  static AnalysisType fromString(String value) {
    return AnalysisType.values.firstWhere(
      (type) => type.toString().split('.').last == value,
      orElse: () => AnalysisType.revenue,
    );
  }
}

enum AnalysisPeriod {
  daily,
  weekly,
  monthly,
  yearly,
}

extension AnalysisPeriodExtension on AnalysisPeriod {
  String get displayName {
    switch (this) {
      case AnalysisPeriod.daily:
        return '每日';
      case AnalysisPeriod.weekly:
        return '每週';
      case AnalysisPeriod.monthly:
        return '每月';
      case AnalysisPeriod.yearly:
        return '每年';
    }
  }

  String toJson() {
    return toString().split('.').last;
  }

  static AnalysisPeriod fromString(String value) {
    return AnalysisPeriod.values.firstWhere(
      (period) => period.toString().split('.').last == value,
      orElse: () => AnalysisPeriod.monthly,
    );
  }
}

enum AnalysisStatus {
  in_progress,
  completed,
  cancelled,
}

extension AnalysisStatusExtension on AnalysisStatus {
  String get displayName {
    switch (this) {
      case AnalysisStatus.in_progress:
        return '進行中';
      case AnalysisStatus.completed:
        return '已完成';
      case AnalysisStatus.cancelled:
        return '已取消';
    }
  }

  String toJson() {
    return toString().split('.').last;
  }

  static AnalysisStatus fromString(String value) {
    return AnalysisStatus.values.firstWhere(
      (status) => status.toString().split('.').last == value,
      orElse: () => AnalysisStatus.in_progress,
    );
  }
}

class BusinessAnalysis {
  final String id;
  final String businessId;
  final AnalysisType analysisType;
  final AnalysisPeriod period;
  final DateTime startDate;
  final DateTime endDate;
  final Map<String, dynamic> data;
  final AnalysisStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  BusinessAnalysis({
    required this.id,
    required this.businessId,
    required this.analysisType,
    required this.period,
    required this.startDate,
    required this.endDate,
    required this.data,
    required this.status,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory BusinessAnalysis.fromJson(Map<String, dynamic> json) {
    return BusinessAnalysis(
      id: json['id'] as String,
      businessId: json['business_id'] as String,
      analysisType: AnalysisTypeExtension.fromString(json['analysis_type'] as String),
      period: AnalysisPeriodExtension.fromString(json['period'] as String),
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      data: json['data'] != null 
          ? (json['data'] is String 
              ? jsonDecode(json['data'] as String) 
              : json['data'] as Map<String, dynamic>)
          : {},
      status: AnalysisStatusExtension.fromString(json['status'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_id': businessId,
      'analysis_type': analysisType.toJson(),
      'period': period.toJson(),
      'start_date': startDate.toIso8601String().split('T').first,
      'end_date': endDate.toIso8601String().split('T').first,
      'data': data,
      'status': status.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  BusinessAnalysis copyWith({
    String? id,
    String? businessId,
    AnalysisType? analysisType,
    AnalysisPeriod? period,
    DateTime? startDate,
    DateTime? endDate,
    Map<String, dynamic>? data,
    AnalysisStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BusinessAnalysis(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      analysisType: analysisType ?? this.analysisType,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      data: data ?? this.data,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 