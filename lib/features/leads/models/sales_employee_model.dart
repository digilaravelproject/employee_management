import 'admin_leads_response_model.dart';

class SalesEmployeesResponseModel {
  final bool status;
  final String message;
  final List<SalesEmployeeModel> data;

  SalesEmployeesResponseModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory SalesEmployeesResponseModel.fromJson(Map<String, dynamic> json) {
    return SalesEmployeesResponseModel(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      data: json['data'] is List
          ? (json['data'] as List)
              .map((item) => SalesEmployeeModel.fromJson(item as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}

class SalesEmployeeModel {
  final int id;
  final String name;
  final String? companyName;
  final String? mobileNumber;
  final String? alternateMobileNumber;
  final String? phone;
  final String? email;
  final String? department;
  final String? workMode;
  final String? employeeType;
  final String? team;
  final String? designation;
  final String? employeeId;
  final String? gender;
  final String? monthlySalary;
  final bool salesTargetEnabled;
  final double salesTarget;
  final String? avatar;
  final String? status;
  final String? role;
  final String? salesTargetMetricType;
  final String? salesTargetPeriod;
  final String? incentiveCommissionPercent;
  final int assignedLeadsCount;
  final int dealsClosedCount;
  final List<String> skills;

  SalesEmployeeModel({
    required this.id,
    required this.name,
    this.companyName,
    this.mobileNumber,
    this.alternateMobileNumber,
    this.phone,
    this.email,
    this.department,
    this.workMode,
    this.employeeType,
    this.team,
    this.designation,
    this.employeeId,
    this.gender,
    this.monthlySalary,
    this.salesTargetEnabled = false,
    this.salesTarget = 0.0,
    this.avatar,
    this.status,
    this.role,
    this.salesTargetMetricType,
    this.salesTargetPeriod,
    this.incentiveCommissionPercent,
    this.assignedLeadsCount = 0,
    this.dealsClosedCount = 0,
    this.skills = const [],
  });

  factory SalesEmployeeModel.fromJson(Map<String, dynamic> json) {
    return SalesEmployeeModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      companyName: json['company_name']?.toString(),
      mobileNumber: json['mobile_number']?.toString(),
      alternateMobileNumber: json['alternate_mobile_number']?.toString(),
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      department: json['department']?.toString(),
      workMode: json['work_mode']?.toString(),
      employeeType: json['employee_type']?.toString(),
      team: json['team']?.toString(),
      designation: json['designation']?.toString(),
      employeeId: json['employee_id']?.toString(),
      gender: json['gender']?.toString(),
      monthlySalary: json['monthly_salary']?.toString(),
      salesTargetEnabled: json['sales_target_enabled'] == true,
      salesTarget: double.tryParse(json['sales_target']?.toString() ?? '') ?? 0.0,
      avatar: json['avatar']?.toString(),
      status: json['status']?.toString(),
      role: json['role']?.toString(),
      salesTargetMetricType: json['sales_target_metric_type']?.toString(),
      salesTargetPeriod: json['sales_target_period']?.toString(),
      incentiveCommissionPercent: json['incentive_commission_percent']?.toString(),
      assignedLeadsCount: int.tryParse(json['assigned_leads_count']?.toString() ?? '') ?? 0,
      dealsClosedCount: int.tryParse(json['deals_closed_count']?.toString() ?? '') ?? 0,
      skills: json['skills'] is List
          ? (json['skills'] as List).map((e) => e.toString()).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'company_name': companyName,
      'mobile_number': mobileNumber,
      'alternate_mobile_number': alternateMobileNumber,
      'phone': phone,
      'email': email,
      'department': department,
      'work_mode': workMode,
      'employee_type': employeeType,
      'team': team,
      'designation': designation,
      'employee_id': employeeId,
      'gender': gender,
      'monthly_salary': monthlySalary,
      'sales_target_enabled': salesTargetEnabled,
      'sales_target': salesTarget,
      'avatar': avatar,
      'status': status,
      'role': role,
      'sales_target_metric_type': salesTargetMetricType,
      'sales_target_period': salesTargetPeriod,
      'incentive_commission_percent': incentiveCommissionPercent,
      'assigned_leads_count': assignedLeadsCount,
      'deals_closed_count': dealsClosedCount,
      'skills': skills,
    };
  }

  // Display Helpers
  String get displayName => name.isNotEmpty ? name : 'Employee #$id';
  String get displayDesignation => (designation != null && designation!.isNotEmpty) ? designation! : 'Sales Representative';
  String get displayEmployeeId => (employeeId != null && employeeId!.isNotEmpty) ? employeeId! : 'EMP-$id';
  String get displayPhone => (mobileNumber != null && mobileNumber!.isNotEmpty) ? mobileNumber! : (phone ?? '');
}

class SalesEmployeeLeadDetailsResponseModel {
  final bool status;
  final String message;
  final SalesEmployeeLeadDetailsData? data;

  SalesEmployeeLeadDetailsResponseModel({
    required this.status,
    required this.message,
    this.data,
  });

  factory SalesEmployeeLeadDetailsResponseModel.fromJson(Map<String, dynamic> json) {
    return SalesEmployeeLeadDetailsResponseModel(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? SalesEmployeeLeadDetailsData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class SalesEmployeeLeadDetailsData {
  final SalesEmployeeModel? employee;
  final SalesEmployeeLeadSummary? summary;
  final List<AdminLeadDataModel> leads;
  final AdminLeadsPaginationModel? pagination;

  SalesEmployeeLeadDetailsData({
    this.employee,
    this.summary,
    this.leads = const [],
    this.pagination,
  });

  factory SalesEmployeeLeadDetailsData.fromJson(Map<String, dynamic> json) {
    return SalesEmployeeLeadDetailsData(
      employee: json['employee'] != null && json['employee'] is Map<String, dynamic>
          ? SalesEmployeeModel.fromJson(json['employee'] as Map<String, dynamic>)
          : null,
      summary: json['summary'] != null && json['summary'] is Map<String, dynamic>
          ? SalesEmployeeLeadSummary.fromJson(json['summary'] as Map<String, dynamic>)
          : null,
      leads: json['leads'] is List
          ? (json['leads'] as List)
              .map((item) => AdminLeadDataModel.fromJson(item as Map<String, dynamic>))
              .toList()
          : [],
      pagination: json['pagination'] != null && json['pagination'] is Map<String, dynamic>
          ? AdminLeadsPaginationModel.fromJson(json['pagination'] as Map<String, dynamic>)
          : null,
    );
  }
}

class SalesEmployeeLeadSummary {
  final double revenue;
  final double target;
  final double targetAchievedPercentage;
  final int averageTalkSeconds;
  final int totalTalkSeconds;
  final int adminAssignedLeads;
  final int selfBroughtLeads;
  final int activeLeads;
  final int totalLeads;

  SalesEmployeeLeadSummary({
    this.revenue = 0.0,
    this.target = 0.0,
    this.targetAchievedPercentage = 0.0,
    this.averageTalkSeconds = 0,
    this.totalTalkSeconds = 0,
    this.adminAssignedLeads = 0,
    this.selfBroughtLeads = 0,
    this.activeLeads = 0,
    this.totalLeads = 0,
  });

  factory SalesEmployeeLeadSummary.fromJson(Map<String, dynamic> json) {
    return SalesEmployeeLeadSummary(
      revenue: double.tryParse(json['revenue']?.toString() ?? '') ?? 0.0,
      target: double.tryParse(json['target']?.toString() ?? '') ?? 0.0,
      targetAchievedPercentage: double.tryParse(json['target_achieved_percentage']?.toString() ?? '') ?? 0.0,
      averageTalkSeconds: int.tryParse(json['average_talk_seconds']?.toString() ?? '') ?? 0,
      totalTalkSeconds: int.tryParse(json['total_talk_seconds']?.toString() ?? '') ?? 0,
      adminAssignedLeads: int.tryParse(json['admin_assigned_leads']?.toString() ?? '') ?? 0,
      selfBroughtLeads: int.tryParse(json['self_brought_leads']?.toString() ?? '') ?? 0,
      activeLeads: int.tryParse(json['active_leads']?.toString() ?? '') ?? 0,
      totalLeads: int.tryParse(json['total_leads']?.toString() ?? '') ?? 0,
    );
  }

  String get totalTalkFormatted {
    final hours = totalTalkSeconds ~/ 3600;
    final minutes = (totalTalkSeconds % 3600) ~/ 60;
    return '${hours}h ${minutes}m';
  }

  String get avgTalkFormatted {
    final minutes = averageTalkSeconds ~/ 60;
    final seconds = averageTalkSeconds % 60;
    return '${minutes}m ${seconds}s';
  }
}
