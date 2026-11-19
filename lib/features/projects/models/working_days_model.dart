class WorkingDaysModel {
  final bool status;
  final String message;
  final WorkingDaysData? data;

  WorkingDaysModel({
    required this.status,
    required this.message,
    this.data,
  });

  factory WorkingDaysModel.fromJson(Map<String, dynamic> json) {
    return WorkingDaysModel(
      status: json['status'] == true || json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: json['data'] is Map<String, dynamic> ? WorkingDaysData.fromJson(json['data']) : null,
    );
  }
}

class WorkingDaysData {
  final String startDate;
  final String endDate;
  final int calendarDays;
  final int workingDays;
  final WorkingDaysExcluded? excluded;
  final String rule;

  WorkingDaysData({
    required this.startDate,
    required this.endDate,
    required this.calendarDays,
    required this.workingDays,
    this.excluded,
    this.rule = '',
  });

  factory WorkingDaysData.fromJson(Map<String, dynamic> json) {
    return WorkingDaysData(
      startDate: json['start_date']?.toString() ?? '',
      endDate: json['end_date']?.toString() ?? '',
      calendarDays: (json['calendar_days'] as num?)?.toInt() ?? 0,
      workingDays: (json['working_days'] as num?)?.toInt() ?? 0,
      excluded: json['excluded'] is Map<String, dynamic>
          ? WorkingDaysExcluded.fromJson(json['excluded'] as Map<String, dynamic>)
          : null,
      rule: json['rule']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'start_date': startDate,
        'end_date': endDate,
        'calendar_days': calendarDays,
        'working_days': workingDays,
        'rule': rule,
      };
}

class WorkingDaysExcluded {
  final int sundays;
  final int allSaturdays;
  final int secondAndFourthSaturdays;
  final int holidays;
  final List<String> holidayDates;

  WorkingDaysExcluded({
    this.sundays = 0,
    this.allSaturdays = 0,
    this.secondAndFourthSaturdays = 0,
    this.holidays = 0,
    this.holidayDates = const [],
  });

  factory WorkingDaysExcluded.fromJson(Map<String, dynamic> json) {
    return WorkingDaysExcluded(
      sundays: (json['sundays'] as num?)?.toInt() ?? 0,
      allSaturdays: (json['all_saturdays'] as num?)?.toInt() ?? 0,
      secondAndFourthSaturdays: (json['second_and_fourth_saturdays'] as num?)?.toInt() ?? 0,
      holidays: (json['holidays'] as num?)?.toInt() ?? 0,
      holidayDates: (json['holiday_dates'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}
