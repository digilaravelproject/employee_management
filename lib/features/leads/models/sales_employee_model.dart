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
    };
  }

  // Display Helpers
  String get displayName => name.isNotEmpty ? name : 'Employee #$id';
  String get displayDesignation => (designation != null && designation!.isNotEmpty) ? designation! : 'Sales Representative';
  String get displayEmployeeId => (employeeId != null && employeeId!.isNotEmpty) ? employeeId! : 'EMP-$id';
  String get displayPhone => (mobileNumber != null && mobileNumber!.isNotEmpty) ? mobileNumber! : (phone ?? '');
}
