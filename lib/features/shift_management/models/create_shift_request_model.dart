class CreateShiftRequestModel {
  final String name;
  final String code;
  final String shiftType;
  final bool status;
  final String? description;
  final String startTime;
  final String endTime;
  final bool crossMidnight;
  final bool breaksEnabled;
  final List<ShiftBreakRequestModel> breaks;
  final int gracePeriodMinutes;
  final int lateAfterMinutes;
  final int minimumWorkingMinutes;
  final bool earlyLeavingAllowed;
  final bool autoMarkLate;
  final bool autoMarkHalfDay;
  final int lateThresholdMinutes;
  final int halfDayAfterMinutes;
  final bool overtimeEnabled;
  final int overtimeStartsAfterMinutes;
  final int minimumOvertimeMinutes;
  final String overtimeCalculation;
  final bool overtimeApprovalRequired;
  final List<ShiftWorkingDayRequestModel> workingDays;
  final List<int> employeeIds;

  CreateShiftRequestModel({
    required this.name,
    required this.code,
    required this.shiftType,
    required this.status,
    this.description,
    required this.startTime,
    required this.endTime,
    required this.crossMidnight,
    required this.breaksEnabled,
    required this.breaks,
    required this.gracePeriodMinutes,
    required this.lateAfterMinutes,
    required this.minimumWorkingMinutes,
    required this.earlyLeavingAllowed,
    required this.autoMarkLate,
    required this.autoMarkHalfDay,
    required this.lateThresholdMinutes,
    required this.halfDayAfterMinutes,
    required this.overtimeEnabled,
    required this.overtimeStartsAfterMinutes,
    required this.minimumOvertimeMinutes,
    required this.overtimeCalculation,
    required this.overtimeApprovalRequired,
    required this.workingDays,
    required this.employeeIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'code': code,
      'shift_type': shiftType,
      'status': status,
      if (description != null && description!.isNotEmpty) 'description': description,
      'start_time': startTime,
      'end_time': endTime,
      'cross_midnight': crossMidnight,
      'breaks_enabled': breaksEnabled,
      'breaks': breaks.map((b) => b.toJson()).toList(),
      'grace_period_minutes': gracePeriodMinutes,
      'late_after_minutes': lateAfterMinutes,
      'minimum_working_minutes': minimumWorkingMinutes,
      'early_leaving_allowed': earlyLeavingAllowed,
      'auto_mark_late': autoMarkLate,
      'auto_mark_half_day': autoMarkHalfDay,
      'late_threshold_minutes': lateThresholdMinutes,
      'half_day_after_minutes': halfDayAfterMinutes,
      'overtime_enabled': overtimeEnabled,
      'overtime_starts_after_minutes': overtimeStartsAfterMinutes,
      'minimum_overtime_minutes': minimumOvertimeMinutes,
      'overtime_calculation': overtimeCalculation,
      'overtime_approval_required': overtimeApprovalRequired,
      'working_days': workingDays.map((w) => w.toJson()).toList(),
      'employee_ids': employeeIds,
    };
  }
}

class ShiftBreakRequestModel {
  final String name;
  final String type; // e.g. "Paid", "Unpaid"
  final String startTime; // e.g. "01:00 PM"
  final String endTime; // e.g. "02:00 PM"

  ShiftBreakRequestModel({
    required this.name,
    required this.type,
    required this.startTime,
    required this.endTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'start_time': startTime,
      'end_time': endTime,
    };
  }

  factory ShiftBreakRequestModel.fromJson(Map<String, dynamic> json) {
    return ShiftBreakRequestModel(
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? 'Paid',
      startTime: json['start_time']?.toString() ?? '',
      endTime: json['end_time']?.toString() ?? '',
    );
  }
}

class ShiftWorkingDayRequestModel {
  final String day; // e.g. "Monday"
  final bool enabled;
  final String startTime; // e.g. "10:00" (HH:mm)
  final String endTime; // e.g. "19:00" (HH:mm)

  ShiftWorkingDayRequestModel({
    required this.day,
    required this.enabled,
    required this.startTime,
    required this.endTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'enabled': enabled,
      'start_time': startTime,
      'end_time': endTime,
    };
  }

  factory ShiftWorkingDayRequestModel.fromJson(Map<String, dynamic> json) {
    return ShiftWorkingDayRequestModel(
      day: json['day']?.toString() ?? '',
      enabled: json['enabled'] == true || json['enabled'] == 1 || json['enabled']?.toString() == 'true',
      startTime: json['start_time']?.toString() ?? '10:00',
      endTime: json['end_time']?.toString() ?? '19:00',
    );
  }
}
