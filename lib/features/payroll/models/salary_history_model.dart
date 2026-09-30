class SalaryHistoryResponseModel {
  final bool status;
  final String? message;
  final SalaryHistoryDataModel? data;

  SalaryHistoryResponseModel({
    required this.status,
    this.message,
    this.data,
  });

  factory SalaryHistoryResponseModel.fromJson(Map<String, dynamic> json) {
    return SalaryHistoryResponseModel(
      status: json['status'] == true,
      message: json['message']?.toString(),
      data: json['data'] is Map<String, dynamic>
          ? SalaryHistoryDataModel.fromJson(Map<String, dynamic>.from(json['data']))
          : (json['data'] is Map
              ? SalaryHistoryDataModel.fromJson(Map<String, dynamic>.from(json['data']))
              : null),
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        if (data != null) 'data': data!.toJson(),
      };
}

class SalaryHistoryDataModel {
  final num currentMonthlyCtc;
  final CurrentCtcBreakdownModel? currentCtcBreakdown;
  final List<RecentPayslipModel> recentPayslips;

  SalaryHistoryDataModel({
    required this.currentMonthlyCtc,
    this.currentCtcBreakdown,
    required this.recentPayslips,
  });

  factory SalaryHistoryDataModel.fromJson(Map<String, dynamic> json) {
    return SalaryHistoryDataModel(
      currentMonthlyCtc: _parseNum(json['current_monthly_ctc']),
      currentCtcBreakdown: json['current_ctc_breakdown'] is Map
          ? CurrentCtcBreakdownModel.fromJson(
              Map<String, dynamic>.from(json['current_ctc_breakdown']))
          : null,
      recentPayslips: json['recent_payslips'] is List
          ? (json['recent_payslips'] as List)
              .whereType<Map>()
              .map((e) => RecentPayslipModel.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
        'current_monthly_ctc': currentMonthlyCtc,
        if (currentCtcBreakdown != null)
          'current_ctc_breakdown': currentCtcBreakdown!.toJson(),
        'recent_payslips': recentPayslips.map((e) => e.toJson()).toList(),
      };
}

class CurrentCtcBreakdownModel {
  final num basic;
  final num hra;
  final num allowances;

  CurrentCtcBreakdownModel({
    required this.basic,
    required this.hra,
    required this.allowances,
  });

  factory CurrentCtcBreakdownModel.fromJson(Map<String, dynamic> json) {
    return CurrentCtcBreakdownModel(
      basic: _parseNum(json['basic']),
      hra: _parseNum(json['hra']),
      allowances: _parseNum(json['allowances']),
    );
  }

  Map<String, dynamic> toJson() => {
        'basic': basic,
        'hra': hra,
        'allowances': allowances,
      };
}

class RecentPayslipModel {
  final int id;
  final dynamic employee;
  final String salaryMonth;
  final String monthLabel;
  final SalaryHistoryAttendanceSummary attendanceSummary;
  final List<SalaryHistoryItemComponent> earnings;
  final List<SalaryHistoryItemComponent> deductions;
  final num grossEarnings;
  final num totalDeductions;
  final num netPayable;
  final String? paymentDate;
  final String? paymentMode;
  final String? bankName;
  final String? accountUpiAddress;
  final String? remarks;
  final String status;
  final String? payslipUrl;

  RecentPayslipModel({
    required this.id,
    this.employee,
    required this.salaryMonth,
    required this.monthLabel,
    required this.attendanceSummary,
    required this.earnings,
    required this.deductions,
    required this.grossEarnings,
    required this.totalDeductions,
    required this.netPayable,
    this.paymentDate,
    this.paymentMode,
    this.bankName,
    this.accountUpiAddress,
    this.remarks,
    required this.status,
    this.payslipUrl,
  });

  factory RecentPayslipModel.fromJson(Map<String, dynamic> json) {
    return RecentPayslipModel(
      id: _parseInt(json['id']),
      employee: json['employee'],
      salaryMonth: json['salary_month']?.toString() ?? '',
      monthLabel: json['month_label']?.toString() ?? '',
      attendanceSummary: json['attendance_summary'] is Map
          ? SalaryHistoryAttendanceSummary.fromJson(
              Map<String, dynamic>.from(json['attendance_summary']))
          : SalaryHistoryAttendanceSummary.empty(),
      earnings: json['earnings'] is List
          ? (json['earnings'] as List)
              .whereType<Map>()
              .map((e) =>
                  SalaryHistoryItemComponent.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : [],
      deductions: json['deductions'] is List
          ? (json['deductions'] as List)
              .whereType<Map>()
              .map((e) =>
                  SalaryHistoryItemComponent.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : [],
      grossEarnings: _parseNum(json['gross_earnings']),
      totalDeductions: _parseNum(json['total_deductions']),
      netPayable: _parseNum(json['net_payable']),
      paymentDate: json['payment_date']?.toString(),
      paymentMode: json['payment_mode']?.toString(),
      bankName: json['bank_name']?.toString(),
      accountUpiAddress: json['account_upi_address']?.toString(),
      remarks: json['remarks']?.toString(),
      status: json['status']?.toString() ?? 'Pending',
      payslipUrl: json['payslip_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'employee': employee,
        'salary_month': salaryMonth,
        'month_label': monthLabel,
        'attendance_summary': attendanceSummary.toJson(),
        'earnings': earnings.map((e) => e.toJson()).toList(),
        'deductions': deductions.map((e) => e.toJson()).toList(),
        'gross_earnings': grossEarnings,
        'total_deductions': totalDeductions,
        'net_payable': netPayable,
        'payment_date': paymentDate,
        'payment_mode': paymentMode,
        'bank_name': bankName,
        'account_upi_address': accountUpiAddress,
        'remarks': remarks,
        'status': status,
        'payslip_url': payslipUrl,
      };
}

class SalaryHistoryAttendanceSummary {
  final int totalWorkingDays;
  final int presentDays;
  final int absentDays;
  final int paidLeaves;
  final int unpaidLeaves;
  final int halfDays;
  final int lateComingDays;
  final num overtimeMinutes;
  final num overtimeHours;

  SalaryHistoryAttendanceSummary({
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

  factory SalaryHistoryAttendanceSummary.empty() => SalaryHistoryAttendanceSummary(
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

  factory SalaryHistoryAttendanceSummary.fromJson(Map<String, dynamic> json) {
    return SalaryHistoryAttendanceSummary(
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
}

class SalaryHistoryItemComponent {
  final String name;
  final num amount;

  SalaryHistoryItemComponent({
    required this.name,
    required this.amount,
  });

  factory SalaryHistoryItemComponent.fromJson(Map<String, dynamic> json) {
    return SalaryHistoryItemComponent(
      name: json['name']?.toString() ?? '',
      amount: _parseNum(json['amount']),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'amount': amount,
      };
}

num _parseNum(dynamic val) {
  if (val is num) return val;
  if (val != null) return num.tryParse(val.toString()) ?? 0;
  return 0;
}

int _parseInt(dynamic val) {
  if (val is int) return val;
  if (val != null) return int.tryParse(val.toString()) ?? 0;
  return 0;
}
