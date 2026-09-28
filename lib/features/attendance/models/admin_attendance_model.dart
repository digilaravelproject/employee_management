class AdminAttendanceResponseModel {
  final bool status;
  final String message;
  final AdminAttendanceData? data;

  AdminAttendanceResponseModel({
    required this.status,
    required this.message,
    this.data,
  });

  factory AdminAttendanceResponseModel.fromJson(Map<String, dynamic> json) {
    return AdminAttendanceResponseModel(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? AdminAttendanceData.fromJson(json['data'])
          : null,
    );
  }
}

class AdminAttendanceData {
  final String? date;
  final AdminAttendanceSummary? summary;
  final List<AdminAttendanceDateCard> dateCards;
  final List<AdminAttendanceEmployeeItem> employees;

  AdminAttendanceData({
    this.date,
    this.summary,
    this.dateCards = const [],
    this.employees = const [],
  });

  factory AdminAttendanceData.fromJson(Map<String, dynamic> json) {
    return AdminAttendanceData(
      date: json['date']?.toString(),
      summary: json['summary'] != null && json['summary'] is Map<String, dynamic>
          ? AdminAttendanceSummary.fromJson(json['summary'])
          : null,
      dateCards: json['date_cards'] != null && json['date_cards'] is List
          ? (json['date_cards'] as List)
              .map((e) => AdminAttendanceDateCard.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
      employees: json['employees'] != null && json['employees'] is List
          ? (json['employees'] as List)
              .map((e) => AdminAttendanceEmployeeItem.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
    );
  }
}

class AdminAttendanceSummary {
  final int totalEmployees;
  final int present;
  final int absent;
  final int onLeave;
  final num presentPercentage;
  final num absentPercentage;

  AdminAttendanceSummary({
    this.totalEmployees = 0,
    this.present = 0,
    this.absent = 0,
    this.onLeave = 0,
    this.presentPercentage = 0,
    this.absentPercentage = 0,
  });

  factory AdminAttendanceSummary.fromJson(Map<String, dynamic> json) {
    return AdminAttendanceSummary(
      totalEmployees: _parseInt(json['total_employees']),
      present: _parseInt(json['present']),
      absent: _parseInt(json['absent']),
      onLeave: _parseInt(json['on_leave']),
      presentPercentage: _parseNum(json['present_percentage']),
      absentPercentage: _parseNum(json['absent_percentage']),
    );
  }

  static int _parseInt(dynamic val) {
    if (val == null) return 0;
    if (val is int) return val;
    if (val is num) return val.toInt();
    return int.tryParse(val.toString()) ?? 0;
  }

  static num _parseNum(dynamic val) {
    if (val == null) return 0;
    if (val is num) return val;
    return num.tryParse(val.toString()) ?? 0;
  }
}

class AdminAttendanceDateCard {
  final String date;
  final String day;
  final int attendanceCount;

  AdminAttendanceDateCard({
    required this.date,
    required this.day,
    this.attendanceCount = 0,
  });

  factory AdminAttendanceDateCard.fromJson(Map<String, dynamic> json) {
    return AdminAttendanceDateCard(
      date: json['date']?.toString() ?? '',
      day: json['day']?.toString() ?? '',
      attendanceCount: json['attendance_count'] is num
          ? (json['attendance_count'] as num).toInt()
          : int.tryParse(json['attendance_count']?.toString() ?? '0') ?? 0,
    );
  }
}

class AdminAttendanceEmployeeItem {
  final AdminAttendanceEmployeeInfo? employee;
  final String? date;
  final int? attendanceId;
  final String status;
  final String? category;
  final String? checkIn;
  final String? checkOut;
  final int workingMinutes;
  final String workingHours;

  AdminAttendanceEmployeeItem({
    this.employee,
    this.date,
    this.attendanceId,
    this.status = 'Absent',
    this.category,
    this.checkIn,
    this.checkOut,
    this.workingMinutes = 0,
    this.workingHours = '00h 00m',
  });

  factory AdminAttendanceEmployeeItem.fromJson(Map<String, dynamic> json) {
    return AdminAttendanceEmployeeItem(
      employee: json['employee'] != null && json['employee'] is Map<String, dynamic>
          ? AdminAttendanceEmployeeInfo.fromJson(json['employee'])
          : null,
      date: json['date']?.toString(),
      attendanceId: json['attendance_id'] is num ? (json['attendance_id'] as num).toInt() : null,
      status: json['status']?.toString() ?? 'Absent',
      category: json['category']?.toString(),
      checkIn: json['check_in']?.toString(),
      checkOut: json['check_out']?.toString(),
      workingMinutes: json['working_minutes'] is num
          ? (json['working_minutes'] as num).toInt()
          : int.tryParse(json['working_minutes']?.toString() ?? '0') ?? 0,
      workingHours: json['working_hours']?.toString() ?? '00h 00m',
    );
  }
}

class AdminAttendanceEmployeeInfo {
  final int? id;
  final String? employeeId;
  final String name;
  final String? avatar;
  final String? designation;
  final String? department;

  AdminAttendanceEmployeeInfo({
    this.id,
    this.employeeId,
    required this.name,
    this.avatar,
    this.designation,
    this.department,
  });

  factory AdminAttendanceEmployeeInfo.fromJson(Map<String, dynamic> json) {
    return AdminAttendanceEmployeeInfo(
      id: json['id'] is num ? (json['id'] as num).toInt() : null,
      employeeId: json['employee_id']?.toString(),
      name: json['name']?.toString() ?? 'Employee',
      avatar: json['avatar']?.toString(),
      designation: json['designation']?.toString(),
      department: json['department']?.toString(),
    );
  }
}
