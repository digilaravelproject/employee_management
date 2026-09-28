class AdminDashboardResponseModel {
  final bool status;
  final String message;
  final AdminDashboardData? data;

  AdminDashboardResponseModel({
    required this.status,
    required this.message,
    this.data,
  });

  factory AdminDashboardResponseModel.fromJson(Map<String, dynamic> json) {
    return AdminDashboardResponseModel(
      status: json['status'] == true || json['status'] == 1 || json['status'] == 'true',
      message: json['message']?.toString() ?? '',
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? AdminDashboardData.fromJson(json['data'])
          : null,
    );
  }
}

class AdminDashboardData {
  final String? greeting;
  final String? companyName;
  final String? date;
  final String? day;
  final int? unreadNotifications;
  final AdminTodaysSummary? todaysSummary;
  final AdminCurrentShift? currentShift;

  AdminDashboardData({
    this.greeting,
    this.companyName,
    this.date,
    this.day,
    this.unreadNotifications,
    this.todaysSummary,
    this.currentShift,
  });

  factory AdminDashboardData.fromJson(Map<String, dynamic> json) {
    return AdminDashboardData(
      greeting: json['greeting']?.toString(),
      companyName: json['company_name']?.toString(),
      date: json['date']?.toString(),
      day: json['day']?.toString(),
      unreadNotifications: json['unread_notifications'] != null
          ? int.tryParse(json['unread_notifications'].toString())
          : null,
      todaysSummary: json['todays_summary'] != null && json['todays_summary'] is Map<String, dynamic>
          ? AdminTodaysSummary.fromJson(json['todays_summary'])
          : null,
      currentShift: json['current_shift'] != null && json['current_shift'] is Map<String, dynamic>
          ? AdminCurrentShift.fromJson(json['current_shift'])
          : null,
    );
  }
}

class AdminTodaysSummary {
  final int totalEmployees;
  final int present;
  final int absent;
  final int onLeave;
  final num presentPercentage;
  final num absentPercentage;
  final num onLeavePercentage;

  AdminTodaysSummary({
    this.totalEmployees = 0,
    this.present = 0,
    this.absent = 0,
    this.onLeave = 0,
    this.presentPercentage = 0,
    this.absentPercentage = 0,
    this.onLeavePercentage = 0,
  });

  factory AdminTodaysSummary.fromJson(Map<String, dynamic> json) {
    return AdminTodaysSummary(
      totalEmployees: _parseInt(json['total_employees']),
      present: _parseInt(json['present']),
      absent: _parseInt(json['absent']),
      onLeave: _parseInt(json['on_leave']),
      presentPercentage: _parseNum(json['present_percentage']),
      absentPercentage: _parseNum(json['absent_percentage']),
      onLeavePercentage: _parseNum(json['on_leave_percentage']),
    );
  }

  static int _parseInt(dynamic val) {
    if (val == null) return 0;
    if (val is int) return val;
    return int.tryParse(val.toString()) ?? 0;
  }

  static num _parseNum(dynamic val) {
    if (val == null) return 0;
    if (val is num) return val;
    return num.tryParse(val.toString()) ?? 0;
  }
}

class AdminCurrentShift {
  final int? id;
  final String? name;
  final String? code;
  final String? status;
  final String? startTime;
  final String? endTime;
  final ShiftWindow? checkInWindow;
  final ShiftWindow? checkOutWindow;

  AdminCurrentShift({
    this.id,
    this.name,
    this.code,
    this.status,
    this.startTime,
    this.endTime,
    this.checkInWindow,
    this.checkOutWindow,
  });

  factory AdminCurrentShift.fromJson(Map<String, dynamic> json) {
    return AdminCurrentShift(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      name: json['name']?.toString(),
      code: json['code']?.toString(),
      status: json['status']?.toString(),
      startTime: json['start_time']?.toString(),
      endTime: json['end_time']?.toString(),
      checkInWindow: json['check_in_window'] != null && json['check_in_window'] is Map<String, dynamic>
          ? ShiftWindow.fromJson(json['check_in_window'])
          : null,
      checkOutWindow: json['check_out_window'] != null && json['check_out_window'] is Map<String, dynamic>
          ? ShiftWindow.fromJson(json['check_out_window'])
          : null,
    );
  }
}

class ShiftWindow {
  final String? from;
  final String? to;

  ShiftWindow({this.from, this.to});

  factory ShiftWindow.fromJson(Map<String, dynamic> json) {
    return ShiftWindow(
      from: json['from']?.toString(),
      to: json['to']?.toString(),
    );
  }
}
