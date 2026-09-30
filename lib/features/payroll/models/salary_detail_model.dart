import 'payroll_record_model.dart';
import 'salary_model.dart';

class SalaryDetailResponseModel {
  final bool status;
  final String? message;
  final SalaryDetailDataModel? data;

  SalaryDetailResponseModel({
    required this.status,
    this.message,
    this.data,
  });

  factory SalaryDetailResponseModel.fromJson(Map<String, dynamic> json) {
    return SalaryDetailResponseModel(
      status: json['status'] == true,
      message: json['message']?.toString(),
      data: json['data'] is Map<String, dynamic>
          ? SalaryDetailDataModel.fromJson(Map<String, dynamic>.from(json['data']))
          : (json['data'] is Map
              ? SalaryDetailDataModel.fromJson(Map<String, dynamic>.from(json['data']))
              : null),
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        if (data != null) 'data': data!.toJson(),
      };
}

class SalaryDetailDataModel {
  final SalaryEmployeeInfo employee;
  final String month;
  final String monthLabel;
  final bool salaryCreated;
  final int? salaryId;
  final SalaryAttendanceSummary attendanceSummary;
  final List<SalaryLineItem> earnings;
  final List<SalaryLineItem> deductions;
  final num grossEarnings;
  final num totalDeductions;
  final num netPayable;
  final SalaryPaymentDetails? paymentDetails;
  final String? payslipUrl;

  SalaryDetailDataModel({
    required this.employee,
    required this.month,
    required this.monthLabel,
    required this.salaryCreated,
    this.salaryId,
    required this.attendanceSummary,
    required this.earnings,
    required this.deductions,
    required this.grossEarnings,
    required this.totalDeductions,
    required this.netPayable,
    this.paymentDetails,
    this.payslipUrl,
  });

  factory SalaryDetailDataModel.fromJson(Map<String, dynamic> json) {
    return SalaryDetailDataModel(
      employee: json['employee'] is Map
          ? SalaryEmployeeInfo.fromJson(Map<String, dynamic>.from(json['employee']))
          : SalaryEmployeeInfo.empty(),
      month: json['month']?.toString() ?? '',
      monthLabel: json['month_label']?.toString() ?? '',
      salaryCreated: json['salary_created'] == true,
      salaryId: json['salary_id'] != null
          ? int.tryParse(json['salary_id'].toString())
          : null,
      attendanceSummary: json['attendance_summary'] is Map
          ? SalaryAttendanceSummary.fromJson(
              Map<String, dynamic>.from(json['attendance_summary']))
          : SalaryAttendanceSummary.empty(),
      earnings: json['earnings'] is List
          ? (json['earnings'] as List)
              .whereType<Map>()
              .map((e) => SalaryLineItem.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : [],
      deductions: json['deductions'] is List
          ? (json['deductions'] as List)
              .whereType<Map>()
              .map((e) => SalaryLineItem.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : [],
      grossEarnings: _parseNum(json['gross_earnings']),
      totalDeductions: _parseNum(json['total_deductions']),
      netPayable: _parseNum(json['net_payable']),
      paymentDetails: json['payment_details'] is Map
          ? SalaryPaymentDetails.fromJson(
              Map<String, dynamic>.from(json['payment_details']))
          : null,
      payslipUrl: json['payslip_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'employee': employee.toJson(),
        'month': month,
        'month_label': monthLabel,
        'salary_created': salaryCreated,
        'salary_id': salaryId,
        'attendance_summary': attendanceSummary.toJson(),
        'earnings': earnings.map((e) => e.toJson()).toList(),
        'deductions': deductions.map((e) => e.toJson()).toList(),
        'gross_earnings': grossEarnings,
        'total_deductions': totalDeductions,
        'net_payable': netPayable,
        if (paymentDetails != null) 'payment_details': paymentDetails!.toJson(),
        'payslip_url': payslipUrl,
      };

  static num _parseNum(dynamic val) {
    if (val is num) return val;
    if (val != null) return num.tryParse(val.toString()) ?? 0;
    return 0;
  }

  /// Converts detail data to [PayrollRecord] for backward compatibility with existing sub-screens
  PayrollRecord toPayrollRecord() {
    double basic = 0;
    double hra = 0;
    double conveyance = 0;
    double special = 0;
    double incentive = 0;
    double bonus = 0;
    double overtime = 0;

    for (final item in earnings) {
      final nameLower = item.name.toLowerCase();
      if (nameLower.contains('basic')) {
        basic += item.amount.toDouble();
      } else if (nameLower.contains('hra')) {
        hra += item.amount.toDouble();
      } else if (nameLower.contains('conveyance')) {
        conveyance += item.amount.toDouble();
      } else if (nameLower.contains('incentive')) {
        incentive += item.amount.toDouble();
      } else if (nameLower.contains('bonus')) {
        bonus += item.amount.toDouble();
      } else if (nameLower.contains('overtime')) {
        overtime += item.amount.toDouble();
      } else {
        special += item.amount.toDouble();
      }
    }

    double leaveDed = 0;
    double lateDed = 0;
    double pf = 0;
    double esi = 0;
    double advance = 0;
    double otherDed = 0;

    for (final item in deductions) {
      final nameLower = item.name.toLowerCase();
      if (nameLower.contains('leave') || nameLower.contains('lwp')) {
        leaveDed += item.amount.toDouble();
      } else if (nameLower.contains('late')) {
        lateDed += item.amount.toDouble();
      } else if (nameLower.contains('pf') || nameLower.contains('provident')) {
        pf += item.amount.toDouble();
      } else if (nameLower.contains('esi')) {
        esi += item.amount.toDouble();
      } else if (nameLower.contains('loan') || nameLower.contains('advance')) {
        advance += item.amount.toDouble();
      } else {
        otherDed += item.amount.toDouble();
      }
    }

    return PayrollRecord(
      id: salaryId != null ? 'SAL-$salaryId' : 'EMP-${employee.id}',
      employeeId: employee.employeeId ?? 'EMP-${employee.id}',
      employeeName: employee.name,
      designation: employee.designation ?? 'Employee',
      department: employee.department ?? 'General',
      profilePic: employee.safeAvatarUrl,
      salaryMonth: monthLabel.isNotEmpty ? monthLabel : month,
      status: salaryCreated ? 'Created' : 'Pending',
      totalWorkingDays: attendanceSummary.totalWorkingDays,
      presentDays: attendanceSummary.presentDays,
      absentDays: attendanceSummary.absentDays,
      paidLeaves: attendanceSummary.paidLeaves,
      unpaidLeaves: attendanceSummary.unpaidLeaves,
      halfDays: attendanceSummary.halfDays,
      lateComingDays: attendanceSummary.lateComingDays,
      overtimeHours: attendanceSummary.overtimeHours.toDouble(),
      basicSalary: basic > 0 ? basic : (grossEarnings.toDouble() * 0.5),
      hra: hra,
      conveyance: conveyance,
      specialAllowance: special,
      incentive: incentive,
      bonus: bonus,
      overtimeAmount: overtime,
      leaveDeduction: leaveDed,
      lateDeduction: lateDed,
      pf: pf,
      esi: esi,
      loanAdvance: advance,
      otherDeduction: otherDed,
    );
  }
}

class SalaryAttendanceSummary {
  final int totalWorkingDays;
  final int presentDays;
  final int absentDays;
  final int paidLeaves;
  final int unpaidLeaves;
  final int halfDays;
  final int lateComingDays;
  final num overtimeMinutes;
  final num overtimeHours;

  SalaryAttendanceSummary({
    required this.totalWorkingDays,
    required this.presentDays,
    required this.absentDays,
    required this.paidLeaves,
    required this.unpaidLeaves,
    required this.halfDays,
    required this.lateComingDays,
    required this.overtimeMinutes,
    required this.overtimeHours,
  });

  factory SalaryAttendanceSummary.empty() => SalaryAttendanceSummary(
        totalWorkingDays: 0,
        presentDays: 0,
        absentDays: 0,
        paidLeaves: 0,
        unpaidLeaves: 0,
        halfDays: 0,
        lateComingDays: 0,
        overtimeMinutes: 0,
        overtimeHours: 0,
      );

  factory SalaryAttendanceSummary.fromJson(Map<String, dynamic> json) {
    return SalaryAttendanceSummary(
      totalWorkingDays: _parseInt(json['total_working_days']),
      presentDays: _parseInt(json['present_days']),
      absentDays: _parseInt(json['absent_days']),
      paidLeaves: _parseInt(json['paid_leaves']),
      unpaidLeaves: _parseInt(json['unpaid_leaves']),
      halfDays: _parseInt(json['half_days']),
      lateComingDays: _parseInt(json['late_coming_days']),
      overtimeMinutes: _parseNum(json['overtime_minutes']),
      overtimeHours: _parseNum(json['overtime_hours']),
    );
  }

  Map<String, dynamic> toJson() => {
        'total_working_days': totalWorkingDays,
        'present_days': presentDays,
        'absent_days': absentDays,
        'paid_leaves': paidLeaves,
        'unpaid_leaves': unpaidLeaves,
        'half_days': halfDays,
        'late_coming_days': lateComingDays,
        'overtime_minutes': overtimeMinutes,
        'overtime_hours': overtimeHours,
      };

  static int _parseInt(dynamic val) {
    if (val is int) return val;
    if (val != null) return int.tryParse(val.toString()) ?? 0;
    return 0;
  }

  static num _parseNum(dynamic val) {
    if (val is num) return val;
    if (val != null) return num.tryParse(val.toString()) ?? 0;
    return 0;
  }
}

class SalaryLineItem {
  final String name;
  final num amount;

  SalaryLineItem({
    required this.name,
    required this.amount,
  });

  factory SalaryLineItem.fromJson(Map<String, dynamic> json) {
    return SalaryLineItem(
      name: json['name']?.toString() ?? '',
      amount: json['amount'] is num
          ? json['amount']
          : num.tryParse(json['amount']?.toString() ?? '') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'amount': amount,
      };
}

class SalaryPaymentDetails {
  final String? paymentDate;
  final String? paymentMode;
  final String? bankName;
  final String? accountUpiAddress;
  final String? remarks;
  final String? status;

  SalaryPaymentDetails({
    this.paymentDate,
    this.paymentMode,
    this.bankName,
    this.accountUpiAddress,
    this.remarks,
    this.status,
  });

  factory SalaryPaymentDetails.fromJson(Map<String, dynamic> json) {
    return SalaryPaymentDetails(
      paymentDate: json['payment_date']?.toString(),
      paymentMode: json['payment_mode']?.toString(),
      bankName: json['bank_name']?.toString(),
      accountUpiAddress: json['account_upi_address']?.toString(),
      remarks: json['remarks']?.toString(),
      status: json['status']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'payment_date': paymentDate,
        'payment_mode': paymentMode,
        'bank_name': bankName,
        'account_upi_address': accountUpiAddress,
        'remarks': remarks,
        'status': status,
      };
}

class CreateSalaryRequestModel {
  final String employeeId;
  final String salaryMonth;
  final String paymentDate;
  final String paymentMode;
  final String bankName;
  final String accountUpiAddress;
  final String remarks;
  final List<SalaryLineItem> earnings;
  final List<SalaryLineItem> deductions;
  final bool confirmed;

  CreateSalaryRequestModel({
    required this.employeeId,
    required this.salaryMonth,
    required this.paymentDate,
    required this.paymentMode,
    required this.bankName,
    required this.accountUpiAddress,
    required this.remarks,
    required this.earnings,
    required this.deductions,
    this.confirmed = true,
  });

  Map<String, dynamic> toJson() => {
        'employee_id': employeeId,
        'salary_month': salaryMonth,
        'payment_date': paymentDate,
        'payment_mode': paymentMode,
        'bank_name': bankName,
        'account_upi_address': accountUpiAddress,
        'remarks': remarks,
        'earnings': earnings.map((e) => e.toJson()).toList(),
        'deductions': deductions.map((e) => e.toJson()).toList(),
        'confirmed': confirmed,
      };
}

class CreateSalaryResponseModel {
  final bool status;
  final String? message;
  final dynamic data;

  CreateSalaryResponseModel({
    required this.status,
    this.message,
    this.data,
  });

  factory CreateSalaryResponseModel.fromJson(Map<String, dynamic> json) {
    return CreateSalaryResponseModel(
      status: json['status'] == true,
      message: json['message']?.toString(),
      data: json['data'],
    );
  }
}

