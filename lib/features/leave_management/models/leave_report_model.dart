import 'admin_leave_model.dart';

class LeaveReportPeriodModel {
  final String fromDate;
  final String toDate;

  LeaveReportPeriodModel({
    required this.fromDate,
    required this.toDate,
  });

  factory LeaveReportPeriodModel.fromJson(Map<String, dynamic> json) {
    return LeaveReportPeriodModel(
      fromDate: json['from_date']?.toString() ?? '',
      toDate: json['to_date']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'from_date': fromDate,
      'to_date': toDate,
    };
  }
}

class LeaveReportStatusSummary {
  final String status;
  final int requests;
  final double days;

  LeaveReportStatusSummary({
    required this.status,
    required this.requests,
    required this.days,
  });

  factory LeaveReportStatusSummary.fromJson(Map<String, dynamic> json) {
    return LeaveReportStatusSummary(
      status: json['status']?.toString() ?? '',
      requests: int.tryParse(json['requests']?.toString() ?? '0') ?? 0,
      days: double.tryParse(json['days']?.toString() ?? '0') ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'requests': requests,
      'days': days,
    };
  }
}

class LeaveReportTypeSummary {
  final int? id;
  final String name;
  final int requests;
  final double days;
  final double percentage;

  LeaveReportTypeSummary({
    this.id,
    required this.name,
    required this.requests,
    required this.days,
    required this.percentage,
  });

  factory LeaveReportTypeSummary.fromJson(Map<String, dynamic> json) {
    return LeaveReportTypeSummary(
      id: int.tryParse(json['id']?.toString() ?? ''),
      name: json['name']?.toString() ?? 'Other',
      requests: int.tryParse(json['requests']?.toString() ?? '0') ?? 0,
      days: double.tryParse(json['days']?.toString() ?? '0') ?? 0.0,
      percentage: double.tryParse(json['percentage']?.toString() ?? '0') ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'requests': requests,
      'days': days,
      'percentage': percentage,
    };
  }
}

class LeaveReportDepartmentSummary {
  final String department;
  final int requests;
  final double days;
  final int approved;
  final int rejected;
  final int pending;
  final int cancelled;

  LeaveReportDepartmentSummary({
    required this.department,
    required this.requests,
    required this.days,
    required this.approved,
    required this.rejected,
    required this.pending,
    required this.cancelled,
  });

  factory LeaveReportDepartmentSummary.fromJson(Map<String, dynamic> json) {
    return LeaveReportDepartmentSummary(
      department: json['department']?.toString() ?? 'Unknown',
      requests: int.tryParse(json['requests']?.toString() ?? '0') ?? 0,
      days: double.tryParse(json['days']?.toString() ?? '0') ?? 0.0,
      approved: int.tryParse(json['approved']?.toString() ?? '0') ?? 0,
      rejected: int.tryParse(json['rejected']?.toString() ?? '0') ?? 0,
      pending: int.tryParse(json['pending']?.toString() ?? '0') ?? 0,
      cancelled: int.tryParse(json['cancelled']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'department': department,
      'requests': requests,
      'days': days,
      'approved': approved,
      'rejected': rejected,
      'pending': pending,
      'cancelled': cancelled,
    };
  }
}

class LeaveReportSummaryModel {
  final int totalRequests;
  final double totalDays;
  final int approved;
  final int rejected;
  final int pending;
  final int cancelled;
  final List<LeaveReportStatusSummary> byStatus;
  final List<LeaveReportTypeSummary> byLeaveType;
  final List<LeaveReportDepartmentSummary> byDepartment;

  LeaveReportSummaryModel({
    required this.totalRequests,
    required this.totalDays,
    required this.approved,
    required this.rejected,
    required this.pending,
    required this.cancelled,
    required this.byStatus,
    required this.byLeaveType,
    required this.byDepartment,
  });

  factory LeaveReportSummaryModel.fromJson(Map<String, dynamic> json) {
    List<LeaveReportStatusSummary> statusList = [];
    if (json['by_status'] is List) {
      statusList = (json['by_status'] as List)
          .whereType<Map<String, dynamic>>()
          .map((i) => LeaveReportStatusSummary.fromJson(i))
          .toList();
    }

    List<LeaveReportTypeSummary> typeList = [];
    if (json['by_leave_type'] is List) {
      typeList = (json['by_leave_type'] as List)
          .whereType<Map<String, dynamic>>()
          .map((i) => LeaveReportTypeSummary.fromJson(i))
          .toList();
    }

    List<LeaveReportDepartmentSummary> deptList = [];
    if (json['by_department'] is List) {
      deptList = (json['by_department'] as List)
          .whereType<Map<String, dynamic>>()
          .map((i) => LeaveReportDepartmentSummary.fromJson(i))
          .toList();
    }

    return LeaveReportSummaryModel(
      totalRequests: int.tryParse(json['total_requests']?.toString() ?? '0') ?? 0,
      totalDays: double.tryParse(json['total_days']?.toString() ?? '0') ?? 0.0,
      approved: int.tryParse(json['approved']?.toString() ?? '0') ?? 0,
      rejected: int.tryParse(json['rejected']?.toString() ?? '0') ?? 0,
      pending: int.tryParse(json['pending']?.toString() ?? '0') ?? 0,
      cancelled: int.tryParse(json['cancelled']?.toString() ?? '0') ?? 0,
      byStatus: statusList,
      byLeaveType: typeList,
      byDepartment: deptList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_requests': totalRequests,
      'total_days': totalDays,
      'approved': approved,
      'rejected': rejected,
      'pending': pending,
      'cancelled': cancelled,
      'by_status': byStatus.map((e) => e.toJson()).toList(),
      'by_leave_type': byLeaveType.map((e) => e.toJson()).toList(),
      'by_department': byDepartment.map((e) => e.toJson()).toList(),
    };
  }
}

class LeaveReportResponseModel {
  final bool status;
  final String message;
  final LeaveReportPeriodModel? period;
  final LeaveReportSummaryModel? summary;
  final List<AdminLeaveItemModel> data;

  LeaveReportResponseModel({
    required this.status,
    required this.message,
    this.period,
    this.summary,
    required this.data,
  });

  factory LeaveReportResponseModel.fromJson(Map<String, dynamic> json) {
    List<AdminLeaveItemModel> items = [];
    if (json['data'] is List) {
      items = (json['data'] as List)
          .whereType<Map<String, dynamic>>()
          .map((i) => AdminLeaveItemModel.fromJson(i))
          .toList();
    }

    return LeaveReportResponseModel(
      status: json['status'] == true ||
          json['status'] == 1 ||
          json['status']?.toString().toLowerCase() == 'true',
      message: json['message']?.toString() ?? '',
      period: json['period'] is Map<String, dynamic>
          ? LeaveReportPeriodModel.fromJson(json['period'] as Map<String, dynamic>)
          : null,
      summary: json['summary'] is Map<String, dynamic>
          ? LeaveReportSummaryModel.fromJson(json['summary'] as Map<String, dynamic>)
          : null,
      data: items,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      if (period != null) 'period': period!.toJson(),
      if (summary != null) 'summary': summary!.toJson(),
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}
