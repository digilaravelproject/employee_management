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
      status: json['status'] == true || json['status'] == 1 || json['status'] == 'true',
      message: json['message']?.toString() ?? '',
      data: json['data'] != null && json['data'] is Map
          ? AdminAttendanceData.fromJson(Map<String, dynamic>.from(json['data'] as Map))
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
    // 1. Parse dateCards safely
    List<AdminAttendanceDateCard> parsedDateCards = [];
    if (json['date_cards'] != null && json['date_cards'] is List) {
      for (final e in (json['date_cards'] as List)) {
        if (e is Map) {
          try {
            parsedDateCards.add(AdminAttendanceDateCard.fromJson(Map<String, dynamic>.from(e)));
          } catch (_) {}
        }
      }
    }

    // 2. Parse employees safely (supports List, paginated Map with 'data', or alternative keys)
    List<AdminAttendanceEmployeeItem> parsedEmployees = [];
    dynamic rawEmployees = json['employees'];
    if (rawEmployees == null) {
      if (json['data'] is List) {
        rawEmployees = json['data'];
      } else if (json['attendances'] != null) {
        rawEmployees = json['attendances'];
      } else if (json['employee_attendances'] != null) {
        rawEmployees = json['employee_attendances'];
      }
    }

    // Check if rawEmployees is paginated map: { "data": [ ... ], "current_page": ... }
    if (rawEmployees is Map) {
      if (rawEmployees['data'] is List) {
        rawEmployees = rawEmployees['data'];
      } else if (rawEmployees['employees'] is List) {
        rawEmployees = rawEmployees['employees'];
      }
    }

    if (rawEmployees is List) {
      for (final e in rawEmployees) {
        if (e is Map) {
          try {
            parsedEmployees.add(AdminAttendanceEmployeeItem.fromJson(Map<String, dynamic>.from(e)));
          } catch (_) {}
        }
      }
    }

    return AdminAttendanceData(
      date: json['date']?.toString(),
      summary: json['summary'] != null && json['summary'] is Map
          ? AdminAttendanceSummary.fromJson(Map<String, dynamic>.from(json['summary'] as Map))
          : null,
      dateCards: parsedDateCards,
      employees: parsedEmployees,
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
  final bool isLate;
  final String? lateBy;

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
    this.isLate = false,
    this.lateBy,
  });

  factory AdminAttendanceEmployeeItem.fromJson(Map<String, dynamic> json) {
    // 1. Employee info: support nested 'employee', 'user', or flat root properties
    AdminAttendanceEmployeeInfo? empInfo;
    if (json['employee'] is Map) {
      empInfo = AdminAttendanceEmployeeInfo.fromJson(Map<String, dynamic>.from(json['employee'] as Map));
    } else if (json['user'] is Map) {
      empInfo = AdminAttendanceEmployeeInfo.fromJson(Map<String, dynamic>.from(json['user'] as Map));
    } else if (json['name'] != null || json['employee_id'] != null || json['first_name'] != null) {
      empInfo = AdminAttendanceEmployeeInfo.fromJson(json);
    }

    final categoryStr = json['category']?.toString();
    final checkInStr = json['check_in']?.toString();
    final checkOutStr = json['check_out']?.toString();

    // 2. Status resolution
    String statusStr = json['status']?.toString() ?? '';
    if (statusStr.isEmpty) {
      statusStr = json['attendance_status']?.toString() ??
          json['type']?.toString() ??
          json['state']?.toString() ??
          '';
    }
    if (statusStr.isEmpty) {
      if (checkInStr != null && checkInStr.isNotEmpty && checkInStr != '--:-- --' && checkInStr != '--') {
        statusStr = 'Present';
      } else {
        statusStr = 'Absent';
      }
    }

    final lateByVal = json['late_by']?.toString() ?? json['late_minutes']?.toString();

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
        (categoryStr != null && categoryStr.toLowerCase().contains('late'))) {
      lateFlag = true;
    } else if (lateByVal != null &&
        lateByVal.isNotEmpty &&
        lateByVal != '--' &&
        lateByVal != '0' &&
        lateByVal != '00m' &&
        lateByVal != '0m') {
      lateFlag = true;
    } else if (checkInStr != null && checkInStr.isNotEmpty && checkInStr != '--:-- --') {
      lateFlag = _isLateTime(checkInStr);
    }

    String? computedLateBy = lateByVal;
    if ((computedLateBy == null || computedLateBy.isEmpty || computedLateBy == '--') && lateFlag) {
      if (checkInStr != null && checkInStr.isNotEmpty) {
        computedLateBy = _computeLateDiff(checkInStr);
      } else {
        computedLateBy = 'Late';
      }
    }

    return AdminAttendanceEmployeeItem(
      employee: empInfo,
      date: json['date']?.toString(),
      attendanceId: json['attendance_id'] is num
          ? (json['attendance_id'] as num).toInt()
          : int.tryParse(json['attendance_id']?.toString() ?? json['id']?.toString() ?? ''),
      status: statusStr,
      category: categoryStr,
      checkIn: checkInStr,
      checkOut: checkOutStr,
      workingMinutes: json['working_minutes'] is num
          ? (json['working_minutes'] as num).toInt()
          : int.tryParse(json['working_minutes']?.toString() ?? '0') ?? 0,
      workingHours: json['working_hours']?.toString() ?? '00h 00m',
      isLate: lateFlag,
      lateBy: computedLateBy,
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

  static String _computeLateDiff(String checkInStr) {
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
    String nameStr = json['name']?.toString() ?? '';
    if (nameStr.isEmpty) {
      final fName = json['first_name']?.toString() ?? '';
      final lName = json['last_name']?.toString() ?? '';
      nameStr = '$fName $lName'.trim();
    }
    if (nameStr.isEmpty) {
      nameStr = json['full_name']?.toString() ?? 'Employee';
    }

    String? desig;
    if (json['designation'] is Map) {
      desig = json['designation']['name']?.toString();
    } else {
      desig = json['designation']?.toString() ?? json['designation_name']?.toString();
    }

    String? dept;
    if (json['department'] is Map) {
      dept = json['department']['name']?.toString();
    } else {
      dept = json['department']?.toString() ?? json['department_name']?.toString();
    }

    return AdminAttendanceEmployeeInfo(
      id: json['id'] is num ? (json['id'] as num).toInt() : int.tryParse(json['id']?.toString() ?? ''),
      employeeId: json['employee_id']?.toString() ?? json['emp_id']?.toString(),
      name: nameStr,
      avatar: json['avatar']?.toString() ?? json['profile_image']?.toString() ?? json['image']?.toString(),
      designation: desig,
      department: dept,
    );
  }
}
