class PayrollRecord {
  final String id;
  final String employeeId;
  final String employeeName;
  final String designation;
  final String department;
  final String? profilePic;
  
  // Salary period and status
  final String salaryMonth; // e.g. "May 2024"
  final String status; // "Pending" or "Created"
  
  // Attendance metrics
  final int totalWorkingDays;
  final int presentDays;
  final int absentDays;
  final int paidLeaves;
  final int unpaidLeaves;
  final int halfDays;
  final int lateComingDays;
  final double overtimeHours;
  
  // Earnings breakdown
  final double basicSalary;
  final double hra;
  final double conveyance;
  final double specialAllowance;
  final double incentive;
  final double bonus;
  final double overtimeAmount;
  
  // Deductions breakdown
  final double leaveDeduction;
  final double lateDeduction;
  final double pf; // Provindent Fund
  final double esi; // Employee State Insurance
  final double loanAdvance;
  final double otherDeduction;

  // Payment processing details
  final String? paymentDate;
  final String? paymentMode;
  final String? bankName;
  final String? accountIfsc;
  final String? remarks;

  PayrollRecord({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.designation,
    required this.department,
    this.profilePic,
    required this.salaryMonth,
    required this.status,
    required this.totalWorkingDays,
    required this.presentDays,
    required this.absentDays,
    required this.paidLeaves,
    required this.unpaidLeaves,
    required this.halfDays,
    required this.lateComingDays,
    required this.overtimeHours,
    required this.basicSalary,
    required this.hra,
    required this.conveyance,
    required this.specialAllowance,
    required this.incentive,
    required this.bonus,
    required this.overtimeAmount,
    required this.leaveDeduction,
    required this.lateDeduction,
    required this.pf,
    required this.esi,
    required this.loanAdvance,
    required this.otherDeduction,
    this.paymentDate,
    this.paymentMode,
    this.bankName,
    this.accountIfsc,
    this.remarks,
  });

  // Calculate gross earnings
  double get grossEarnings =>
      basicSalary + hra + conveyance + specialAllowance + incentive + bonus + overtimeAmount;

  // Calculate total deductions
  double get totalDeductions =>
      leaveDeduction + lateDeduction + pf + esi + loanAdvance + otherDeduction;

  // Calculate net payable
  double get netPayable => grossEarnings - totalDeductions;

  // CopyWith helper
  PayrollRecord copyWith({
    String? id,
    String? employeeId,
    String? employeeName,
    String? designation,
    String? department,
    String? profilePic,
    String? salaryMonth,
    String? status,
    int? totalWorkingDays,
    int? presentDays,
    int? absentDays,
    int? paidLeaves,
    int? unpaidLeaves,
    int? halfDays,
    int? lateComingDays,
    double? overtimeHours,
    double? basicSalary,
    double? hra,
    double? conveyance,
    double? specialAllowance,
    double? incentive,
    double? bonus,
    double? overtimeAmount,
    double? leaveDeduction,
    double? lateDeduction,
    double? pf,
    double? esi,
    double? loanAdvance,
    double? otherDeduction,
    String? paymentDate,
    String? paymentMode,
    String? bankName,
    String? accountIfsc,
    String? remarks,
  }) {
    return PayrollRecord(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      designation: designation ?? this.designation,
      department: department ?? this.department,
      profilePic: profilePic ?? this.profilePic,
      salaryMonth: salaryMonth ?? this.salaryMonth,
      status: status ?? this.status,
      totalWorkingDays: totalWorkingDays ?? this.totalWorkingDays,
      presentDays: presentDays ?? this.presentDays,
      absentDays: absentDays ?? this.absentDays,
      paidLeaves: paidLeaves ?? this.paidLeaves,
      unpaidLeaves: unpaidLeaves ?? this.unpaidLeaves,
      halfDays: halfDays ?? this.halfDays,
      lateComingDays: lateComingDays ?? this.lateComingDays,
      overtimeHours: overtimeHours ?? this.overtimeHours,
      basicSalary: basicSalary ?? this.basicSalary,
      hra: hra ?? this.hra,
      conveyance: conveyance ?? this.conveyance,
      specialAllowance: specialAllowance ?? this.specialAllowance,
      incentive: incentive ?? this.incentive,
      bonus: bonus ?? this.bonus,
      overtimeAmount: overtimeAmount ?? this.overtimeAmount,
      leaveDeduction: leaveDeduction ?? this.leaveDeduction,
      lateDeduction: lateDeduction ?? this.lateDeduction,
      pf: pf ?? this.pf,
      esi: esi ?? this.esi,
      loanAdvance: loanAdvance ?? this.loanAdvance,
      otherDeduction: otherDeduction ?? this.otherDeduction,
      paymentDate: paymentDate ?? this.paymentDate,
      paymentMode: paymentMode ?? this.paymentMode,
      bankName: bankName ?? this.bankName,
      accountIfsc: accountIfsc ?? this.accountIfsc,
      remarks: remarks ?? this.remarks,
    );
  }
}
