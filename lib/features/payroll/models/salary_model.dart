import '../../../core/constants/app_constants.dart';
import 'payroll_record_model.dart';

class SalaryListResponseModel {
  final bool status;
  final String? message;
  final SalaryDataModel? data;

  SalaryListResponseModel({
    required this.status,
    this.message,
    this.data,
  });

  factory SalaryListResponseModel.fromJson(Map<String, dynamic> json) {
    return SalaryListResponseModel(
      status: json['status'] == true,
      message: json['message']?.toString(),
      data: json['data'] is Map<String, dynamic>
          ? SalaryDataModel.fromJson(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        if (data != null) 'data': data!.toJson(),
      };
}

class SalaryDataModel {
  final String month;
  final String monthLabel;
  final SalarySummaryModel? summary;
  final List<SalaryEmployeeRecord> employees;

  SalaryDataModel({
    required this.month,
    required this.monthLabel,
    this.summary,
    required this.employees,
  });

  factory SalaryDataModel.fromJson(Map<String, dynamic> json) {
    return SalaryDataModel(
      month: json['month']?.toString() ?? '',
      monthLabel: json['month_label']?.toString() ?? '',
      summary: json['summary'] is Map<String, dynamic>
          ? SalarySummaryModel.fromJson(json['summary'])
          : null,
      employees: json['employees'] is List
          ? (json['employees'] as List)
              .whereType<Map>()
              .map((e) => SalaryEmployeeRecord.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
        'month': month,
        'month_label': monthLabel,
        if (summary != null) 'summary': summary!.toJson(),
        'employees': employees.map((e) => e.toJson()).toList(),
      };
}

class SalarySummaryModel {
  final int totalEmployees;
  final int created;
  final int pending;

  SalarySummaryModel({
    required this.totalEmployees,
    required this.created,
    required this.pending,
  });

  factory SalarySummaryModel.fromJson(Map<String, dynamic> json) {
    return SalarySummaryModel(
      totalEmployees: _parseInt(json['total_employees']),
      created: _parseInt(json['created']),
      pending: _parseInt(json['pending']),
    );
  }

  Map<String, dynamic> toJson() => {
        'total_employees': totalEmployees,
        'created': created,
        'pending': pending,
      };

  static int _parseInt(dynamic val) {
    if (val is int) return val;
    if (val != null) return int.tryParse(val.toString()) ?? 0;
    return 0;
  }
}

class SalaryEmployeeRecord {
  final SalaryEmployeeInfo employee;
  final int? salaryId;
  final String salaryMonth;
  final num netPayable;
  final String status;
  final String? paymentStatus;
  final String? payslipUrl;

  SalaryEmployeeRecord({
    required this.employee,
    this.salaryId,
    required this.salaryMonth,
    required this.netPayable,
    required this.status,
    this.paymentStatus,
    this.payslipUrl,
  });

  factory SalaryEmployeeRecord.fromJson(Map<String, dynamic> json) {
    return SalaryEmployeeRecord(
      employee: json['employee'] is Map<String, dynamic>
          ? SalaryEmployeeInfo.fromJson(json['employee'])
          : (json['employee'] is Map
              ? SalaryEmployeeInfo.fromJson(Map<String, dynamic>.from(json['employee']))
              : SalaryEmployeeInfo.empty()),
      salaryId: json['salary_id'] != null
          ? int.tryParse(json['salary_id'].toString())
          : null,
      salaryMonth: json['salary_month']?.toString() ?? '',
      netPayable: json['net_payable'] is num
          ? json['net_payable']
          : num.tryParse(json['net_payable']?.toString() ?? '') ?? 0,
      status: json['status']?.toString() ?? 'Pending',
      paymentStatus: json['payment_status']?.toString(),
      payslipUrl: json['payslip_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'employee': employee.toJson(),
        'salary_id': salaryId,
        'salary_month': salaryMonth,
        'net_payable': netPayable,
        'status': status,
        'payment_status': paymentStatus,
        'payslip_url': payslipUrl,
      };

  /// Convert to [PayrollRecord] for seamless integration with existing detail & calculation screens
  PayrollRecord toPayrollRecord() {
    final double salaryVal = double.tryParse(employee.monthlySalary ?? '') ?? netPayable.toDouble();
    return PayrollRecord(
      id: salaryId != null ? 'SAL-$salaryId' : 'EMP-${employee.id}',
      employeeId: employee.employeeId ?? 'EMP-${employee.id}',
      employeeName: employee.name,
      designation: employee.designation ?? 'Employee',
      department: employee.department ?? 'General',
      profilePic: employee.safeAvatarUrl,
      salaryMonth: salaryMonth,
      status: status,
      totalWorkingDays: 26,
      presentDays: 24,
      absentDays: 2,
      paidLeaves: 0,
      unpaidLeaves: 0,
      halfDays: 0,
      lateComingDays: 0,
      overtimeHours: 0.0,
      basicSalary: salaryVal > 0 ? (salaryVal * 0.5) : netPayable.toDouble(),
      hra: salaryVal > 0 ? (salaryVal * 0.3) : 0.0,
      conveyance: salaryVal > 0 ? (salaryVal * 0.1) : 0.0,
      specialAllowance: salaryVal > 0 ? (salaryVal * 0.1) : 0.0,
      incentive: 0.0,
      bonus: 0.0,
      overtimeAmount: 0.0,
      leaveDeduction: 0.0,
      lateDeduction: 0.0,
      pf: 0.0,
      esi: 0.0,
      loanAdvance: 0.0,
      otherDeduction: 0.0,
    );
  }
}

class SalaryEmployeeInfo {
  final int id;
  final String? employeeId;
  final String name;
  final String? avatar;
  final String? designation;
  final String? department;
  final String? dateOfJoining;
  final String? salaryType;
  final String? monthlySalary;

  SalaryEmployeeInfo({
    required this.id,
    this.employeeId,
    required this.name,
    this.avatar,
    this.designation,
    this.department,
    this.dateOfJoining,
    this.salaryType,
    this.monthlySalary,
  });

  factory SalaryEmployeeInfo.empty() => SalaryEmployeeInfo(
        id: 0,
        name: 'Unknown',
      );

  factory SalaryEmployeeInfo.fromJson(Map<String, dynamic> json) {
    return SalaryEmployeeInfo(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      employeeId: json['employee_id']?.toString(),
      name: json['name']?.toString() ?? '',
      avatar: json['avatar']?.toString(),
      designation: json['designation']?.toString(),
      department: json['department']?.toString(),
      dateOfJoining: json['date_of_joining']?.toString(),
      salaryType: json['salary_type']?.toString(),
      monthlySalary: json['monthly_salary']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'employee_id': employeeId,
        'name': name,
        'avatar': avatar,
        'designation': designation,
        'department': department,
        'date_of_joining': dateOfJoining,
        'salary_type': salaryType,
        'monthly_salary': monthlySalary,
      };

  /// Returns a safe URL for the avatar, replacing localhost/127.0.0.1 with production baseUrl
  String? get safeAvatarUrl {
    if (avatar == null || avatar!.isEmpty) return null;
    if (avatar!.contains('127.0.0.1:8000') || avatar!.contains('localhost:8000')) {
      final path = avatar!.split('/storage/').last;
      return '${AppConstants.baseUrl}/storage/$path';
    }
    return avatar;
  }
}
