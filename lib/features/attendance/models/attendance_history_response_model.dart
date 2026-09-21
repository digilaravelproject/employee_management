import 'attendance_history_model.dart';

class AttendanceHistoryResponseModel {
  final bool status;
  final String message;
  final AttendanceHistoryData? data;

  AttendanceHistoryResponseModel({
    required this.status,
    required this.message,
    this.data,
  });

  factory AttendanceHistoryResponseModel.fromJson(Map<String, dynamic> json) {
    return AttendanceHistoryResponseModel(
      status: json['status'] == true || json['status'] == 1,
      message: json['message']?.toString() ?? '',
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? AttendanceHistoryData.fromJson(json['data'])
          : null,
    );
  }
}

class AttendanceHistoryData {
  final String? month;
  final String? monthLabel;
  final AttendanceSummary? summary;
  final List<AttendanceCalendarDay> calendar;
  final List<AttendanceCalendarDay> recentRecords;

  AttendanceHistoryData({
    this.month,
    this.monthLabel,
    this.summary,
    this.calendar = const [],
    this.recentRecords = const [],
  });

  factory AttendanceHistoryData.fromJson(Map<String, dynamic> json) {
    List<AttendanceCalendarDay> calList = [];
    if (json['calendar'] != null && json['calendar'] is List) {
      calList = (json['calendar'] as List)
          .map((item) => AttendanceCalendarDay.fromJson(item is Map<String, dynamic> ? item : {}))
          .toList();
    }

    List<AttendanceCalendarDay> recentList = [];
    if (json['recent_records'] != null && json['recent_records'] is List) {
      recentList = (json['recent_records'] as List)
          .map((item) => AttendanceCalendarDay.fromJson(item is Map<String, dynamic> ? item : {}))
          .toList();
    }

    return AttendanceHistoryData(
      month: json['month']?.toString(),
      monthLabel: json['month_label']?.toString(),
      summary: json['summary'] != null && json['summary'] is Map<String, dynamic>
          ? AttendanceSummary.fromJson(json['summary'])
          : null,
      calendar: calList,
      recentRecords: recentList,
    );
  }
}

class AttendanceSummary {
  final int present;
  final int halfDay;
  final int absent;
  final int leave;
  final int weekend;
  final int workingDays;
  final double attendancePercentage;

  AttendanceSummary({
    this.present = 0,
    this.halfDay = 0,
    this.absent = 0,
    this.leave = 0,
    this.weekend = 0,
    this.workingDays = 0,
    this.attendancePercentage = 0.0,
  });

  factory AttendanceSummary.fromJson(Map<String, dynamic> json) {
    return AttendanceSummary(
      present: int.tryParse(json['present']?.toString() ?? '0') ?? 0,
      halfDay: int.tryParse(json['half_day']?.toString() ?? '0') ?? 0,
      absent: int.tryParse(json['absent']?.toString() ?? '0') ?? 0,
      leave: int.tryParse(json['leave']?.toString() ?? '0') ?? 0,
      weekend: int.tryParse(json['weekend']?.toString() ?? '0') ?? 0,
      workingDays: int.tryParse(json['working_days']?.toString() ?? '0') ?? 0,
      attendancePercentage: double.tryParse(json['attendance_percentage']?.toString() ?? '0.0') ?? 0.0,
    );
  }
}

class AttendanceCalendarDay {
  final String date;
  final String? day;
  final String category;
  final String status;
  final String? checkIn;
  final String? checkOut;
  final int workingMinutes;
  final String workingHours;

  AttendanceCalendarDay({
    required this.date,
    this.day,
    required this.category,
    required this.status,
    this.checkIn,
    this.checkOut,
    this.workingMinutes = 0,
    this.workingHours = '00h 00m',
  });

  factory AttendanceCalendarDay.fromJson(Map<String, dynamic> json) {
    return AttendanceCalendarDay(
      date: json['date']?.toString() ?? '',
      day: json['day']?.toString(),
      category: json['category']?.toString() ?? 'upcoming',
      status: json['status']?.toString() ?? 'Upcoming',
      checkIn: json['check_in']?.toString(),
      checkOut: json['check_out']?.toString(),
      workingMinutes: int.tryParse(json['working_minutes']?.toString() ?? '0') ?? 0,
      workingHours: json['working_hours']?.toString() ?? '00h 00m',
    );
  }

  DateTime? get parsedDate => DateTime.tryParse(date);

  AttendanceRecord toAttendanceRecord() {
    final parsed = parsedDate ?? DateTime.now();
    return AttendanceRecord(
      date: parsed,
      status: status,
      checkIn: (checkIn != null && checkIn!.isNotEmpty) ? checkIn! : '--:-- --',
      checkOut: (checkOut != null && checkOut!.isNotEmpty) ? checkOut! : '--:-- --',
      workingHours: workingHours.isNotEmpty ? workingHours : '00h 00m',
      breakTime: '00h 00m',
      lateBy: '--',
      earlyLeave: '--',
      location: 'Office',
      remarks: status == 'Weekend' ? 'Weekly Off' : (status == 'Absent' ? 'Absent' : '--'),
    );
  }
}
