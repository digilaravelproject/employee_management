class EmployeeDashboardResponseModel {
  final bool status;
  final String message;
  final EmployeeDashboardData? data;

  EmployeeDashboardResponseModel({
    required this.status,
    required this.message,
    this.data,
  });

  factory EmployeeDashboardResponseModel.fromJson(Map<String, dynamic> json) {
    return EmployeeDashboardResponseModel(
      status: json['status'] == true || json['status'] == 1,
      message: json['message']?.toString() ?? '',
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? EmployeeDashboardData.fromJson(json['data'])
          : null,
    );
  }
}

class EmployeeDashboardData {
  final String? greeting;
  final String? date;
  final String? day;
  final DashboardEmployee? employee;
  final DashboardCurrentShift? currentShift;
  final DashboardAttendance? attendance;
  final List<DashboardBirthday> todaysBirthdays;
  final DashboardTodaysSummary? todaysSummary;

  EmployeeDashboardData({
    this.greeting,
    this.date,
    this.day,
    this.employee,
    this.currentShift,
    this.attendance,
    this.todaysBirthdays = const [],
    this.todaysSummary,
  });

  factory EmployeeDashboardData.fromJson(Map<String, dynamic> json) {
    List<DashboardBirthday> birthdays = [];
    if (json['todays_birthdays'] != null && json['todays_birthdays'] is List) {
      birthdays = (json['todays_birthdays'] as List)
          .map((b) => DashboardBirthday.fromJson(b is Map<String, dynamic> ? b : {}))
          .toList();
    }

    return EmployeeDashboardData(
      greeting: json['greeting']?.toString(),
      date: json['date']?.toString(),
      day: json['day']?.toString(),
      employee: json['employee'] != null && json['employee'] is Map<String, dynamic>
          ? DashboardEmployee.fromJson(json['employee'])
          : null,
      currentShift: json['current_shift'] != null && json['current_shift'] is Map<String, dynamic>
          ? DashboardCurrentShift.fromJson(json['current_shift'])
          : null,
      attendance: json['attendance'] != null && json['attendance'] is Map<String, dynamic>
          ? DashboardAttendance.fromJson(json['attendance'])
          : null,
      todaysBirthdays: birthdays,
      todaysSummary: json['todays_summary'] != null && json['todays_summary'] is Map<String, dynamic>
          ? DashboardTodaysSummary.fromJson(json['todays_summary'])
          : null,
    );
  }
}

class DashboardEmployee {
  final int? id;
  final String? employeeId;
  final String? name;
  final String? email;
  final String? avatar;
  final String? designation;
  final String? department;

  DashboardEmployee({
    this.id,
    this.employeeId,
    this.name,
    this.email,
    this.avatar,
    this.designation,
    this.department,
  });

  factory DashboardEmployee.fromJson(Map<String, dynamic> json) {
    return DashboardEmployee(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      employeeId: json['employee_id']?.toString(),
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      avatar: json['avatar']?.toString(),
      designation: json['designation']?.toString(),
      department: json['department']?.toString(),
    );
  }
}

class DashboardCurrentShift {
  final int? id;
  final String? name;
  final String? code;
  final String? startTime;
  final String? endTime;
  final String? date;
  final bool isOngoing;

  DashboardCurrentShift({
    this.id,
    this.name,
    this.code,
    this.startTime,
    this.endTime,
    this.date,
    this.isOngoing = false,
  });

  factory DashboardCurrentShift.fromJson(Map<String, dynamic> json) {
    return DashboardCurrentShift(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      name: json['name']?.toString(),
      code: json['code']?.toString(),
      startTime: json['start_time']?.toString(),
      endTime: json['end_time']?.toString(),
      date: json['date']?.toString(),
      isOngoing: json['is_ongoing'] == true || json['is_ongoing'] == 1,
    );
  }
}

class DashboardAttendance {
  final String? checkIn;
  final String? checkOut;
  final String? status;

  DashboardAttendance({
    this.checkIn,
    this.checkOut,
    this.status,
  });

  factory DashboardAttendance.fromJson(Map<String, dynamic> json) {
    return DashboardAttendance(
      checkIn: json['check_in']?.toString(),
      checkOut: json['check_out']?.toString(),
      status: json['status']?.toString(),
    );
  }
}

class DashboardBirthday {
  final int? id;
  final String? name;
  final String? designation;
  final String? avatar;
  final String? date;

  DashboardBirthday({
    this.id,
    this.name,
    this.designation,
    this.avatar,
    this.date,
  });

  factory DashboardBirthday.fromJson(Map<String, dynamic> json) {
    return DashboardBirthday(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      name: json['name']?.toString(),
      designation: json['designation']?.toString() ?? json['role']?.toString(),
      avatar: json['avatar']?.toString(),
      date: json['date']?.toString(),
    );
  }
}

class DashboardTodaysSummary {
  final int? workingMinutes;
  final String? workingHours;
  final int? breakMinutes;
  final String? breakHours;
  final int? overtimeMinutes;
  final String? overtime;
  final String? status;

  DashboardTodaysSummary({
    this.workingMinutes,
    this.workingHours,
    this.breakMinutes,
    this.breakHours,
    this.overtimeMinutes,
    this.overtime,
    this.status,
  });

  factory DashboardTodaysSummary.fromJson(Map<String, dynamic> json) {
    return DashboardTodaysSummary(
      workingMinutes: json['working_minutes'] != null ? int.tryParse(json['working_minutes'].toString()) : null,
      workingHours: json['working_hours']?.toString(),
      breakMinutes: json['break_minutes'] != null ? int.tryParse(json['break_minutes'].toString()) : null,
      breakHours: json['break_hours']?.toString(),
      overtimeMinutes: json['overtime_minutes'] != null ? int.tryParse(json['overtime_minutes'].toString()) : null,
      overtime: json['overtime']?.toString(),
      status: json['status']?.toString(),
    );
  }
}
