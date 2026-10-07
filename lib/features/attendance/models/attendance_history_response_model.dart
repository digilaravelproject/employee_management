import 'package:intl/intl.dart';
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

    final period = json['period'] is Map<String, dynamic>
        ? json['period'] as Map<String, dynamic>
        : null;

    return AttendanceHistoryData(
      month: json['month']?.toString() ?? period?['month']?.toString(),
      monthLabel: json['month_label']?.toString() ?? period?['label']?.toString(),
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
  final int late;
  final double attendancePercentage;

  AttendanceSummary({
    this.present = 0,
    this.halfDay = 0,
    this.absent = 0,
    this.leave = 0,
    this.weekend = 0,
    this.workingDays = 0,
    this.late = 0,
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
      late: int.tryParse(
              json['late']?.toString() ??
              json['late_days']?.toString() ??
              json['late_count']?.toString() ??
              '0') ??
          0,
      attendancePercentage: double.tryParse(
              json['attendance_percent']?.toString() ??
              json['attendance_percentage']?.toString() ??
              '0.0') ??
          0.0,
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
  final bool isLate;
  final String? lateBy;
  final String? holiday;

  AttendanceCalendarDay({
    required this.date,
    this.day,
    required this.category,
    required this.status,
    this.checkIn,
    this.checkOut,
    this.workingMinutes = 0,
    this.workingHours = '00h 00m',
    this.isLate = false,
    this.lateBy,
    this.holiday,
  });

  factory AttendanceCalendarDay.fromJson(Map<String, dynamic> json) {
    final statusStr = json['status']?.toString() ??
        (json['holiday'] != null ? 'Holiday' : 'Upcoming');
    final categoryStr = json['category']?.toString() ??
        (json['holiday'] != null ? 'holiday' : 'upcoming');
    final holidayStr = json['holiday']?.toString();

    String? checkInStr =
        json['check_in']?.toString() ?? json['check_in_at']?.toString();
    String? checkOutStr =
        json['check_out']?.toString() ?? json['check_out_at']?.toString();

    // Format ISO timestamps (e.g. 2026-10-06T06:02:01.000000Z) to readable local time format
    if (checkInStr != null && checkInStr.contains('T')) {
      final dt = DateTime.tryParse(checkInStr);
      if (dt != null) {
        checkInStr = DateFormat('hh:mm a').format(dt.toLocal());
      }
    }
    if (checkOutStr != null && checkOutStr.contains('T')) {
      final dt = DateTime.tryParse(checkOutStr);
      if (dt != null) {
        checkOutStr = DateFormat('hh:mm a').format(dt.toLocal());
      }
    }

    final dateStr = json['date']?.toString() ??
        json['attendance_date']?.toString() ??
        '';

    final lateByVal =
        json['late_by']?.toString() ?? json['late_minutes']?.toString();

    bool lateFlag = false;
    if (json['is_late'] == true ||
        json['is_late'] == 1 ||
        json['is_late'] == '1' ||
        json['is_late'] == 'true' ||
        json['late'] == true ||
        json['late'] == 1 ||
        json['late'] == '1' ||
        json['late'] == 'true') {
      lateFlag = true;
    } else if (statusStr.toLowerCase().contains('late') ||
        categoryStr.toLowerCase().contains('late')) {
      lateFlag = true;
    } else if (lateByVal != null &&
        lateByVal.isNotEmpty &&
        lateByVal != '--' &&
        lateByVal != '0' &&
        lateByVal != '00m' &&
        lateByVal != '0m') {
      lateFlag = true;
    } else if (checkInStr != null &&
        checkInStr.isNotEmpty &&
        checkInStr != '--:-- --') {
      lateFlag = _isLateTime(checkInStr);
    }

    String? computedLateBy = lateByVal;
    if ((computedLateBy == null ||
            computedLateBy.isEmpty ||
            computedLateBy == '--') &&
        lateFlag) {
      if (checkInStr != null && checkInStr.isNotEmpty) {
        computedLateBy = _computeLateDifference(checkInStr);
      } else {
        computedLateBy = 'Late';
      }
    }

    final wm = int.tryParse(json['working_minutes']?.toString() ?? '0') ?? 0;
    String wh = json['working_hours']?.toString() ?? '';
    if (wh.isEmpty || wh == '00h 00m') {
      if (wm > 0) {
        wh = '${(wm ~/ 60).toString().padLeft(2, '0')}h ${(wm % 60).toString().padLeft(2, '0')}m';
      } else {
        wh = '00h 00m';
      }
    }

    return AttendanceCalendarDay(
      date: dateStr,
      day: json['day']?.toString(),
      category: categoryStr,
      status: statusStr,
      checkIn: checkInStr,
      checkOut: checkOutStr,
      workingMinutes: wm,
      workingHours: wh,
      isLate: lateFlag,
      lateBy: computedLateBy,
      holiday: holidayStr,
    );
  }

  static bool _isLateTime(String checkInStr) {
    try {
      final clean = checkInStr.trim().toUpperCase();
      if (clean.contains('AM') || clean.contains('PM')) {
        final isPM = clean.contains('PM');
        final raw = clean.replaceAll('AM', '').replaceAll('PM', '').trim();
        final parts = raw.split(':');
        if (parts.isNotEmpty) {
          int hour = int.tryParse(parts[0].trim()) ?? 0;
          int min = parts.length > 1 ? (int.tryParse(parts[1].trim()) ?? 0) : 0;
          if (isPM && hour < 12) hour += 12;
          if (!isPM && hour == 12) hour = 0;
          final totalMinutes = hour * 60 + min;
          // Beyond 10:00 AM (600 mins) is considered late
          return totalMinutes > 600;
        }
      } else if (clean.contains(':')) {
        final parts = clean.split(':');
        final hour = int.tryParse(parts[0].trim()) ?? 0;
        final min = parts.length > 1 ? (int.tryParse(parts[1].trim()) ?? 0) : 0;
        final totalMinutes = hour * 60 + min;
        return totalMinutes > 600;
      }
    } catch (_) {}
    return false;
  }

  static String _computeLateDifference(String checkInStr) {
    try {
      final clean = checkInStr.trim().toUpperCase();
      if (clean.contains('AM') || clean.contains('PM')) {
        final isPM = clean.contains('PM');
        final raw = clean.replaceAll('AM', '').replaceAll('PM', '').trim();
        final parts = raw.split(':');
        if (parts.isNotEmpty) {
          int hour = int.tryParse(parts[0].trim()) ?? 0;
          int min = parts.length > 1 ? (int.tryParse(parts[1].trim()) ?? 0) : 0;
          if (isPM && hour < 12) hour += 12;
          if (!isPM && hour == 12) hour = 0;
          final totalMinutes = hour * 60 + min;
          if (totalMinutes > 600) {
            final diff = totalMinutes - 600;
            if (diff >= 60) {
              final h = diff ~/ 60;
              final m = diff % 60;
              return m > 0 ? '${h}h ${m}m' : '${h}h';
            }
            return '$diff mins';
          }
        }
      }
    } catch (_) {}
    return 'Late';
  }

  DateTime? get parsedDate => DateTime.tryParse(date);

  AttendanceRecord toAttendanceRecord() {
    final parsed = parsedDate ?? DateTime.now();
    final remarkText = holiday != null && holiday!.isNotEmpty
        ? holiday!
        : (status == 'Weekend'
            ? 'Weekly Off'
            : (status == 'Absent' ? 'Absent' : '--'));

    return AttendanceRecord(
      date: parsed,
      status: status,
      checkIn: (checkIn != null && checkIn!.isNotEmpty) ? checkIn! : '--:-- --',
      checkOut: (checkOut != null && checkOut!.isNotEmpty) ? checkOut! : '--:-- --',
      workingHours: workingHours.isNotEmpty ? workingHours : '00h 00m',
      breakTime: '00h 00m',
      lateBy: (lateBy != null && lateBy!.isNotEmpty) ? lateBy! : (isLate ? 'Late' : '--'),
      earlyLeave: '--',
      location: 'Office',
      remarks: remarkText,
      isLate: isLate,
    );
  }
}
