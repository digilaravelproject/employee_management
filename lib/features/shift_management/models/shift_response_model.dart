class ShiftListResponseModel {
  final bool status;
  final String message;
  final int total;
  final List<ShiftDataModel> data;

  ShiftListResponseModel({
    required this.status,
    required this.message,
    this.total = 0,
    required this.data,
  });

  factory ShiftListResponseModel.fromJson(Map<String, dynamic> json) {
    return ShiftListResponseModel(
      status: json['status'] == true || json['status'] == 1 || json['status']?.toString() == 'true',
      message: json['message']?.toString() ?? '',
      total: int.tryParse(json['total']?.toString() ?? '0') ?? 0,
      data: (json['data'] is List)
          ? (json['data'] as List).map((i) => ShiftDataModel.fromJson(i as Map<String, dynamic>)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'total': total,
      'data': data.map((d) => d.toJson()).toList(),
    };
  }
}

class ShiftResponseModel {
  final bool status;
  final String message;
  final ShiftDataModel? data;

  ShiftResponseModel({
    required this.status,
    required this.message,
    this.data,
  });

  factory ShiftResponseModel.fromJson(Map<String, dynamic> json) {
    return ShiftResponseModel(
      status: json['status'] == true || json['status'] == 1 || json['status']?.toString() == 'true',
      message: json['message']?.toString() ?? '',
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? ShiftDataModel.fromJson(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      if (data != null) 'data': data!.toJson(),
    };
  }
}

class ShiftDataModel {
  final int id;
  final String name;
  final String code;
  final String shiftType;
  final String startTime;
  final String endTime;
  final bool crossMidnight;
  final bool breaksEnabled;
  final List<ShiftBreakDataModel> breaks;
  final String? breakDuration;
  final String? totalDuration;
  final String? graceTimeLate;
  final int? gracePeriodMinutes;
  final int? lateAfterMinutes;
  final int? minimumWorkingMinutes;
  final bool? earlyLeavingAllowed;
  final bool? autoMarkLate;
  final bool? autoMarkHalfDay;
  final int? lateThresholdMinutes;
  final int? halfDayAfterMinutes;
  final String? overtimeAfter;
  final bool? overtimeEnabled;
  final int? overtimeStartsAfterMinutes;
  final int? minimumOvertimeMinutes;
  final String? overtimeCalculation;
  final bool? overtimeApprovalRequired;
  final List<ShiftWorkingDayDataModel> workingDays;
  final String? description;
  final String? status;
  final String? createdAt;
  final String? updatedAt;
  final String? grossDuration;
  final String? netWorkingDuration;
  final int assignedEmployeesCount;
  final List<ShiftAssignedEmployeeModel> assignedEmployees;

  ShiftDataModel({
    required this.id,
    required this.name,
    required this.code,
    required this.shiftType,
    required this.startTime,
    required this.endTime,
    required this.crossMidnight,
    required this.breaksEnabled,
    required this.breaks,
    this.breakDuration,
    this.totalDuration,
    this.graceTimeLate,
    this.gracePeriodMinutes,
    this.lateAfterMinutes,
    this.minimumWorkingMinutes,
    this.earlyLeavingAllowed,
    this.autoMarkLate,
    this.autoMarkHalfDay,
    this.lateThresholdMinutes,
    this.halfDayAfterMinutes,
    this.overtimeAfter,
    this.overtimeEnabled,
    this.overtimeStartsAfterMinutes,
    this.minimumOvertimeMinutes,
    this.overtimeCalculation,
    this.overtimeApprovalRequired,
    required this.workingDays,
    this.description,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.grossDuration,
    this.netWorkingDuration,
    this.assignedEmployeesCount = 0,
    this.assignedEmployees = const [],
  });

  factory ShiftDataModel.fromJson(Map<String, dynamic> json) {
    return ShiftDataModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      shiftType: json['shift_type']?.toString() ?? 'Fixed Shift',
      startTime: json['start_time']?.toString() ?? '',
      endTime: json['end_time']?.toString() ?? '',
      crossMidnight: json['cross_midnight'] == true || json['cross_midnight'] == 1 || json['cross_midnight']?.toString() == 'true',
      breaksEnabled: json['breaks_enabled'] == true || json['breaks_enabled'] == 1 || json['breaks_enabled']?.toString() == 'true',
      breaks: (json['breaks'] is List)
          ? (json['breaks'] as List).map((i) => ShiftBreakDataModel.fromJson(i as Map<String, dynamic>)).toList()
          : [],
      breakDuration: json['break_duration']?.toString(),
      totalDuration: json['total_duration']?.toString(),
      graceTimeLate: json['grace_time_late']?.toString(),
      gracePeriodMinutes: int.tryParse(json['grace_period_minutes']?.toString() ?? ''),
      lateAfterMinutes: int.tryParse(json['late_after_minutes']?.toString() ?? ''),
      minimumWorkingMinutes: int.tryParse(json['minimum_working_minutes']?.toString() ?? ''),
      earlyLeavingAllowed: json['early_leaving_allowed'] == true || json['early_leaving_allowed'] == 1,
      autoMarkLate: json['auto_mark_late'] == true || json['auto_mark_late'] == 1,
      autoMarkHalfDay: json['auto_mark_half_day'] == true || json['auto_mark_half_day'] == 1,
      lateThresholdMinutes: int.tryParse(json['late_threshold_minutes']?.toString() ?? ''),
      halfDayAfterMinutes: int.tryParse(json['half_day_after_minutes']?.toString() ?? ''),
      overtimeAfter: json['overtime_after']?.toString(),
      overtimeEnabled: json['overtime_enabled'] == true || json['overtime_enabled'] == 1,
      overtimeStartsAfterMinutes: int.tryParse(json['overtime_starts_after_minutes']?.toString() ?? ''),
      minimumOvertimeMinutes: int.tryParse(json['minimum_overtime_minutes']?.toString() ?? ''),
      overtimeCalculation: json['overtime_calculation']?.toString(),
      overtimeApprovalRequired: json['overtime_approval_required'] == true || json['overtime_approval_required'] == 1,
      workingDays: (json['working_days'] is List)
          ? (json['working_days'] as List).map((i) => ShiftWorkingDayDataModel.fromJson(i as Map<String, dynamic>)).toList()
          : [],
      description: json['description']?.toString(),
      status: json['status']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      grossDuration: json['gross_duration']?.toString(),
      netWorkingDuration: json['net_working_duration']?.toString(),
      assignedEmployeesCount: int.tryParse(json['assigned_employees_count']?.toString() ?? '0') ?? 0,
      assignedEmployees: (json['assigned_employees'] is List)
          ? (json['assigned_employees'] as List).map((e) => ShiftAssignedEmployeeModel.fromJson(e as Map<String, dynamic>)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'shift_type': shiftType,
      'start_time': startTime,
      'end_time': endTime,
      'cross_midnight': crossMidnight,
      'breaks_enabled': breaksEnabled,
      'breaks': breaks.map((b) => b.toJson()).toList(),
      'break_duration': breakDuration,
      'total_duration': totalDuration,
      'grace_time_late': graceTimeLate,
      'grace_period_minutes': gracePeriodMinutes,
      'late_after_minutes': lateAfterMinutes,
      'minimum_working_minutes': minimumWorkingMinutes,
      'early_leaving_allowed': earlyLeavingAllowed,
      'auto_mark_late': autoMarkLate,
      'auto_mark_half_day': autoMarkHalfDay,
      'late_threshold_minutes': lateThresholdMinutes,
      'half_day_after_minutes': halfDayAfterMinutes,
      'overtime_after': overtimeAfter,
      'overtime_enabled': overtimeEnabled,
      'overtime_starts_after_minutes': overtimeStartsAfterMinutes,
      'minimum_overtime_minutes': minimumOvertimeMinutes,
      'overtime_calculation': overtimeCalculation,
      'overtime_approval_required': overtimeApprovalRequired,
      'working_days': workingDays.map((w) => w.toJson()).toList(),
      'description': description,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'gross_duration': grossDuration,
      'net_working_duration': netWorkingDuration,
      'assigned_employees_count': assignedEmployeesCount,
      'assigned_employees': assignedEmployees.map((e) => e.toJson()).toList(),
    };
  }
}

class ShiftBreakDataModel {
  final String name;
  final String type;
  final String startTime;
  final String endTime;
  final int? durationMinutes;

  ShiftBreakDataModel({
    required this.name,
    required this.type,
    required this.startTime,
    required this.endTime,
    this.durationMinutes,
  });

  factory ShiftBreakDataModel.fromJson(Map<String, dynamic> json) {
    return ShiftBreakDataModel(
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? 'Paid',
      startTime: json['start_time']?.toString() ?? '',
      endTime: json['end_time']?.toString() ?? '',
      durationMinutes: int.tryParse(json['duration_minutes']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'start_time': startTime,
      'end_time': endTime,
      if (durationMinutes != null) 'duration_minutes': durationMinutes,
    };
  }
}

class ShiftWorkingDayDataModel {
  final String day;
  final bool enabled;
  final String startTime;
  final String endTime;

  ShiftWorkingDayDataModel({
    required this.day,
    required this.enabled,
    required this.startTime,
    required this.endTime,
  });

  factory ShiftWorkingDayDataModel.fromJson(Map<String, dynamic> json) {
    return ShiftWorkingDayDataModel(
      day: json['day']?.toString() ?? '',
      enabled: json['enabled'] == true || json['enabled'] == 1 || json['enabled']?.toString() == 'true',
      startTime: json['start_time']?.toString() ?? '10:00',
      endTime: json['end_time']?.toString() ?? '19:00',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'enabled': enabled,
      'start_time': startTime,
      'end_time': endTime,
    };
  }
}

class ShiftAssignedEmployeeModel {
  final int id;
  final String employeeId;
  final String name;
  final String email;
  final String? department;
  final String? designation;
  final String? avatar;
  final String? status;

  ShiftAssignedEmployeeModel({
    required this.id,
    required this.employeeId,
    required this.name,
    required this.email,
    this.department,
    this.designation,
    this.avatar,
    this.status,
  });

  factory ShiftAssignedEmployeeModel.fromJson(Map<String, dynamic> json) {
    return ShiftAssignedEmployeeModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      employeeId: json['employee_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      department: json['department']?.toString(),
      designation: json['designation']?.toString(),
      avatar: json['avatar']?.toString(),
      status: json['status']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'name': name,
      'email': email,
      if (department != null) 'department': department,
      if (designation != null) 'designation': designation,
      if (avatar != null) 'avatar': avatar,
      if (status != null) 'status': status,
    };
  }
}
