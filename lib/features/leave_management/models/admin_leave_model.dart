import 'package:intl/intl.dart';

class AdminLeaveCountsModel {
  final int all;
  final int pending;
  final int approved;
  final int rejected;
  final int cancelled;

  AdminLeaveCountsModel({
    this.all = 0,
    this.pending = 0,
    this.approved = 0,
    this.rejected = 0,
    this.cancelled = 0,
  });

  factory AdminLeaveCountsModel.fromJson(Map<String, dynamic> json) {
    return AdminLeaveCountsModel(
      all: int.tryParse(json['all']?.toString() ?? '0') ?? 0,
      pending: int.tryParse(json['pending']?.toString() ?? '0') ?? 0,
      approved: int.tryParse(json['approved']?.toString() ?? '0') ?? 0,
      rejected: int.tryParse(json['rejected']?.toString() ?? '0') ?? 0,
      cancelled: int.tryParse(json['cancelled']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'all': all,
      'pending': pending,
      'approved': approved,
      'rejected': rejected,
      'cancelled': cancelled,
    };
  }
}

class AdminLeavePaginationModel {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  AdminLeavePaginationModel({
    this.currentPage = 1,
    this.lastPage = 1,
    this.perPage = 15,
    this.total = 0,
  });

  factory AdminLeavePaginationModel.fromJson(Map<String, dynamic> json) {
    return AdminLeavePaginationModel(
      currentPage: int.tryParse(json['current_page']?.toString() ?? '1') ?? 1,
      lastPage: int.tryParse(json['last_page']?.toString() ?? '1') ?? 1,
      perPage: int.tryParse(json['per_page']?.toString() ?? '15') ?? 15,
      total: int.tryParse(json['total']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'last_page': lastPage,
      'per_page': perPage,
      'total': total,
    };
  }
}

class LeaveBalanceOverviewModel {
  final int leaveTypeId;
  final String name;
  final String code;
  final int total;
  final int taken;
  final int pending;
  final int remaining;

  LeaveBalanceOverviewModel({
    required this.leaveTypeId,
    required this.name,
    required this.code,
    required this.total,
    required this.taken,
    required this.pending,
    required this.remaining,
  });

  factory LeaveBalanceOverviewModel.fromJson(Map<String, dynamic> json) {
    return LeaveBalanceOverviewModel(
      leaveTypeId: int.tryParse(json['leave_type_id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      total: int.tryParse(json['total']?.toString() ?? '0') ?? 0,
      taken: int.tryParse(json['taken']?.toString() ?? '0') ?? 0,
      pending: int.tryParse(json['pending']?.toString() ?? '0') ?? 0,
      remaining: int.tryParse(json['remaining']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'leave_type_id': leaveTypeId,
      'name': name,
      'code': code,
      'total': total,
      'taken': taken,
      'pending': pending,
      'remaining': remaining,
    };
  }
}

class AdminLeaveListResponseModel {
  final bool status;
  final String message;
  final int total;
  final AdminLeaveCountsModel? counts;
  final AdminLeavePaginationModel? pagination;
  final List<AdminLeaveItemModel> data;
  final List<LeaveBalanceOverviewModel> leaveBalances;

  AdminLeaveListResponseModel({
    required this.status,
    required this.message,
    this.total = 0,
    this.counts,
    this.pagination,
    required this.data,
    this.leaveBalances = const [],
  });

  factory AdminLeaveListResponseModel.fromJson(Map<String, dynamic> json) {
    List<AdminLeaveItemModel> items = [];
    if (json['data'] is List) {
      items = (json['data'] as List)
          .whereType<Map<String, dynamic>>()
          .map((i) => AdminLeaveItemModel.fromJson(i))
          .toList();
    } else if (json['leaves'] is List) {
      items = (json['leaves'] as List)
          .whereType<Map<String, dynamic>>()
          .map((i) => AdminLeaveItemModel.fromJson(i))
          .toList();
    }

    AdminLeaveCountsModel? counts;
    if (json['counts'] is Map<String, dynamic>) {
      counts = AdminLeaveCountsModel.fromJson(json['counts'] as Map<String, dynamic>);
    }

    AdminLeavePaginationModel? pagination;
    if (json['pagination'] is Map<String, dynamic>) {
      pagination = AdminLeavePaginationModel.fromJson(json['pagination'] as Map<String, dynamic>);
    }

    List<LeaveBalanceOverviewModel> balances = [];
    if (json['leave_balances'] is List) {
      balances = (json['leave_balances'] as List)
          .whereType<Map<String, dynamic>>()
          .map((b) => LeaveBalanceOverviewModel.fromJson(b))
          .toList();
    }

    return AdminLeaveListResponseModel(
      status: json['status'] == true ||
          json['status'] == 1 ||
          json['status']?.toString().toLowerCase() == 'true',
      message: json['message']?.toString() ?? '',
      total: int.tryParse(json['total']?.toString() ?? '') ??
          (pagination?.total ?? (counts?.all ?? items.length)),
      counts: counts,
      pagination: pagination,
      data: items,
      leaveBalances: balances,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'total': total,
      if (counts != null) 'counts': counts!.toJson(),
      if (pagination != null) 'pagination': pagination!.toJson(),
      'data': data.map((d) => d.toJson()).toList(),
      'leave_balances': leaveBalances.map((b) => b.toJson()).toList(),
    };
  }
}

class AdminLeaveDetailResponseModel {
  final bool status;
  final String message;
  final AdminLeaveDetailDataModel? data;

  AdminLeaveDetailResponseModel({
    required this.status,
    required this.message,
    this.data,
  });

  factory AdminLeaveDetailResponseModel.fromJson(Map<String, dynamic> json) {
    return AdminLeaveDetailResponseModel(
      status: json['status'] == true ||
          json['status'] == 1 ||
          json['status']?.toString().toLowerCase() == 'true',
      message: json['message']?.toString() ?? '',
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? AdminLeaveDetailDataModel.fromJson(json['data'] as Map<String, dynamic>)
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

class AdminLeaveEmployeeModel {
  final int id;
  final String employeeId;
  final String name;
  final String email;
  final String phone;
  final String? avatar;
  final String department;
  final String designation;
  final String role;
  final String status;
  final String? address;
  final String? dateOfJoining;
  final String? companyName;

  AdminLeaveEmployeeModel({
    required this.id,
    required this.employeeId,
    required this.name,
    required this.email,
    this.phone = '',
    this.avatar,
    this.department = 'General',
    this.designation = 'Employee',
    this.role = 'Employee',
    this.status = 'Active',
    this.address,
    this.dateOfJoining,
    this.companyName,
  });

  factory AdminLeaveEmployeeModel.fromJson(Map<String, dynamic> json) {
    String parsedDept = 'General';
    if (json['department_details'] is Map) {
      parsedDept = json['department_details']['name']?.toString() ?? 'General';
    } else if (json['department'] is Map) {
      parsedDept = json['department']['name']?.toString() ?? 'General';
    } else if (json['department'] != null) {
      parsedDept = json['department'].toString();
    } else if (json['department_name'] != null) {
      parsedDept = json['department_name'].toString();
    }

    String parsedDesig = 'Employee';
    if (json['designation_details'] is Map) {
      parsedDesig = json['designation_details']['name']?.toString() ?? 'Employee';
    } else if (json['designation'] is Map) {
      parsedDesig = json['designation']['name']?.toString() ?? 'Employee';
    } else if (json['designation'] != null) {
      parsedDesig = json['designation'].toString();
    } else if (json['designation_name'] != null) {
      parsedDesig = json['designation_name'].toString();
    }

    return AdminLeaveEmployeeModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      employeeId: json['employee_id']?.toString() ??
          json['emp_id']?.toString() ??
          json['code']?.toString() ??
          '',
      name: json['name']?.toString() ??
          json['full_name']?.toString() ??
          json['employee_name']?.toString() ??
          json['user_name']?.toString() ??
          'Unknown Employee',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ??
          json['mobile_number']?.toString() ??
          json['mobile']?.toString() ??
          '',
      avatar: json['avatar']?.toString() ??
          json['profile_image']?.toString() ??
          json['image']?.toString(),
      department: parsedDept.isNotEmpty ? parsedDept : 'General',
      designation: parsedDesig.isNotEmpty ? parsedDesig : 'Employee',
      role: json['role']?.toString() ?? 'Employee',
      status: json['status']?.toString() ?? 'Active',
      address: json['address']?.toString(),
      dateOfJoining: json['date_of_joining']?.toString(),
      companyName: json['company_name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'name': name,
      'email': email,
      'phone': phone,
      if (avatar != null) 'avatar': avatar,
      'department': department,
      'designation': designation,
      'role': role,
      'status': status,
      if (address != null) 'address': address,
      if (dateOfJoining != null) 'date_of_joining': dateOfJoining,
      if (companyName != null) 'company_name': companyName,
    };
  }
}

class AdminLeaveItemModel {
  final int id;
  final AdminLeaveEmployeeModel employee;
  final String leaveType;
  final int? leaveTypeId;
  final DateTime? startDate;
  final DateTime? endDate;
  final double totalDays;
  final String duration;
  final String sessionType;
  final String reason;
  final String status;
  final DateTime? appliedAt;
  final String? rejectionReason;
  final String? approvedBy;
  final String? documentUrl;
  final String? createdAt;
  final String? updatedAt;
  final String leaveTypeCode;
  final String? assigneeName;
  final String? contactDuringLeave;
  final String? addressDuringLeave;

  AdminLeaveItemModel({
    required this.id,
    required this.employee,
    required this.leaveType,
    this.leaveTypeId,
    this.startDate,
    this.endDate,
    required this.totalDays,
    required this.duration,
    this.sessionType = 'Full Day',
    this.reason = '',
    required this.status,
    this.appliedAt,
    this.rejectionReason,
    this.approvedBy,
    this.documentUrl,
    this.createdAt,
    this.updatedAt,
    this.leaveTypeCode = '',
    this.assigneeName,
    this.contactDuringLeave,
    this.addressDuringLeave,
  });

  factory AdminLeaveItemModel.fromJson(Map<String, dynamic> json) {
    AdminLeaveEmployeeModel emp;
    if (json['employee'] is Map<String, dynamic>) {
      emp = AdminLeaveEmployeeModel.fromJson(json['employee']);
    } else if (json['user'] is Map<String, dynamic>) {
      emp = AdminLeaveEmployeeModel.fromJson(json['user']);
    } else {
      emp = AdminLeaveEmployeeModel.fromJson(json);
    }

    String parsedLeaveType = 'Casual Leave';
    int? parsedLeaveTypeId;
    if (json['leave_type'] is Map) {
      parsedLeaveType = json['leave_type']['name']?.toString() ?? 'Casual Leave';
      parsedLeaveTypeId = int.tryParse(json['leave_type']['id']?.toString() ?? '');
    } else if (json['leave_type'] != null) {
      parsedLeaveType = json['leave_type'].toString();
    } else if (json['type'] != null) {
      parsedLeaveType = json['type'].toString();
    }

    DateTime? parseDate(dynamic dateVal) {
      if (dateVal == null) return null;
      if (dateVal is DateTime) return dateVal;
      try {
        return DateTime.parse(dateVal.toString());
      } catch (_) {
        try {
          return DateFormat('yyyy-MM-dd').parse(dateVal.toString());
        } catch (_) {
          return null;
        }
      }
    }

    final sDate = parseDate(json['from_date'] ?? json['start_date'] ?? json['startDate']);
    final eDate = parseDate(json['to_date'] ?? json['end_date'] ?? json['endDate'] ?? sDate);
    final appAt = parseDate(json['created_at'] ?? json['applied_at'] ?? json['applied_on']);

    double days = 1.0;
    if (json['total_days'] != null) {
      days = double.tryParse(json['total_days'].toString()) ?? 1.0;
    } else if (json['days'] != null) {
      days = double.tryParse(json['days'].toString()) ?? 1.0;
    } else if (sDate != null && eDate != null) {
      days = (eDate.difference(sDate).inDays + 1).toDouble();
      if (days <= 0) days = 1.0;
    }

    String durString = json['duration']?.toString() ?? '';
    if (durString.isEmpty) {
      if (days == 1.0) {
        durString = '1 Day';
      } else if (days == 0.5) {
        durString = '0.5 Day';
      } else {
        durString = '${days % 1 == 0 ? days.toInt() : days} Days';
      }
    }

    String rawStatus = json['status']?.toString().toLowerCase().trim() ?? 'pending';
    String normStatus = 'Pending';
    if (rawStatus == 'approved' || rawStatus == 'approve') {
      normStatus = 'Approved';
    } else if (rawStatus == 'rejected' || rawStatus == 'reject' || rawStatus == 'declined') {
      normStatus = 'Rejected';
    } else if (rawStatus == 'cancelled' || rawStatus == 'cancel') {
      normStatus = 'Cancelled';
    }

    String lCode = '';
    if (json['leave_type'] is Map) {
      lCode = json['leave_type']['code']?.toString() ?? '';
    }
    String? aName;
    if (json['assignee'] is Map) {
      aName = json['assignee']['name']?.toString();
    }

    return AdminLeaveItemModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      employee: emp,
      leaveType: parsedLeaveType,
      leaveTypeId: parsedLeaveTypeId,
      startDate: sDate,
      endDate: eDate,
      totalDays: days,
      duration: durString,
      sessionType: json['session']?.toString() ?? json['session_type']?.toString() ?? 'Full Day',
      reason: json['reason']?.toString() ?? '',
      status: normStatus,
      appliedAt: appAt,
      rejectionReason: json['review_note']?.toString() ?? json['rejection_reason']?.toString(),
      approvedBy: json['reviewed_by_user_id']?.toString(),
      documentUrl: json['attachment_path']?.toString() ?? json['document']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      leaveTypeCode: lCode,
      assigneeName: aName,
      contactDuringLeave: json['contact_during_leave']?.toString(),
      addressDuringLeave: json['address_during_leave']?.toString(),
    );
  }

  String get formattedDates {
    if (startDate == null) return 'N/A';
    if (endDate == null || startDate == endDate) {
      return DateFormat('dd MMM yyyy').format(startDate!);
    }
    if (startDate!.year == endDate!.year && startDate!.month == endDate!.month) {
      return '${DateFormat('dd').format(startDate!)} - ${DateFormat('dd MMM yyyy').format(endDate!)}';
    }
    if (startDate!.year == endDate!.year) {
      return '${DateFormat('dd MMM').format(startDate!)} - ${DateFormat('dd MMM yyyy').format(endDate!)}';
    }
    return '${DateFormat('dd MMM yyyy').format(startDate!)} - ${DateFormat('dd MMM yyyy').format(endDate!)}';
  }

  String get formattedAppliedOn {
    if (appliedAt != null) {
      return DateFormat('dd MMM yyyy').format(appliedAt!);
    }
    return 'Recently';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee': employee.toJson(),
      'leave_type': leaveType,
      if (leaveTypeId != null) 'leave_type_id': leaveTypeId,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'total_days': totalDays,
      'duration': duration,
      'session_type': sessionType,
      'reason': reason,
      'status': status,
      'applied_at': appliedAt?.toIso8601String(),
      if (rejectionReason != null) 'rejection_reason': rejectionReason,
      if (approvedBy != null) 'approved_by': approvedBy,
      if (documentUrl != null) 'document': documentUrl,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  Map<String, dynamic> toViewMap() {
    return {
      'id': id,
      'name': employee.name,
      'employee_id': employee.employeeId,
      'role': employee.role,
      'designation': employee.designation,
      'department': employee.department,
      'image': employee.avatar ?? 'assets/images/user1.png',
      'type': leaveType,
      'status': status,
      'startDate': startDate ?? DateTime.now(),
      'endDate': endDate ?? DateTime.now(),
      'dates': formattedDates,
      'duration': duration,
      'appliedOn': formattedAppliedOn,
      'reason': reason,
      'rejectionReason': rejectionReason,
      'sessionType': sessionType,
      'email': employee.email,
      'phone': employee.phone,
    };
  }
}

class AdminLeaveDetailDataModel {
  final int id;
  final int userId;
  final int leaveTypeId;
  final DateTime? fromDate;
  final DateTime? toDate;
  final double totalDays;
  final String reason;
  final String contactDuringLeave;
  final String? attachmentName;
  final String? attachmentPath;
  final String status;
  final String? reviewNote;
  final int? reviewedByUserId;
  final DateTime? reviewedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final AdminLeaveEmployeeModel employee;
  final AdminLeaveTypeDetailModel leaveType;
  final AdminLeaveReviewerModel? reviewer;
  final List<AdminLeaveActionModel> actions;
  final AdminLeaveBalanceModel leaveBalance;
  final String session;
  final String? addressDuringLeave;
  final String? assigneeName;
  final String? assigneeDesignation;

  AdminLeaveDetailDataModel({
    required this.id,
    required this.userId,
    required this.leaveTypeId,
    this.fromDate,
    this.toDate,
    required this.totalDays,
    required this.reason,
    this.contactDuringLeave = '',
    this.attachmentName,
    this.attachmentPath,
    required this.status,
    this.reviewNote,
    this.reviewedByUserId,
    this.reviewedAt,
    this.createdAt,
    this.updatedAt,
    required this.employee,
    required this.leaveType,
    this.reviewer,
    this.actions = const [],
    required this.leaveBalance,
    this.session = 'Full Day',
    this.addressDuringLeave,
    this.assigneeName,
    this.assigneeDesignation,
  });

  factory AdminLeaveDetailDataModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic dateVal) {
      if (dateVal == null) return null;
      if (dateVal is DateTime) return dateVal;
      try {
        return DateTime.parse(dateVal.toString());
      } catch (_) {
        try {
          return DateFormat('yyyy-MM-dd').parse(dateVal.toString());
        } catch (_) {
          return null;
        }
      }
    }

    final fDate = parseDate(json['from_date'] ?? json['start_date']);
    final tDate = parseDate(json['to_date'] ?? json['end_date'] ?? fDate);
    final cDate = parseDate(json['created_at']);
    final rDate = parseDate(json['reviewed_at']);
    final uDate = parseDate(json['updated_at']);

    double days = 1.0;
    if (json['total_days'] != null) {
      days = double.tryParse(json['total_days'].toString()) ?? 1.0;
    } else if (fDate != null && tDate != null) {
      days = (tDate.difference(fDate).inDays + 1).toDouble();
      if (days <= 0) days = 1.0;
    }

    String rawStatus = json['status']?.toString().toLowerCase().trim() ?? 'pending';
    String normStatus = 'Pending';
    if (rawStatus == 'approved' || rawStatus == 'approve') {
      normStatus = 'Approved';
    } else if (rawStatus == 'rejected' || rawStatus == 'reject' || rawStatus == 'declined') {
      normStatus = 'Rejected';
    } else if (rawStatus == 'cancelled' || rawStatus == 'cancel') {
      normStatus = 'Cancelled';
    }

    AdminLeaveEmployeeModel emp;
    if (json['employee'] is Map<String, dynamic>) {
      emp = AdminLeaveEmployeeModel.fromJson(json['employee']);
    } else {
      emp = AdminLeaveEmployeeModel.fromJson(json);
    }

    AdminLeaveTypeDetailModel lt;
    if (json['leave_type'] is Map<String, dynamic>) {
      lt = AdminLeaveTypeDetailModel.fromJson(json['leave_type']);
    } else {
      lt = AdminLeaveTypeDetailModel(
        id: int.tryParse(json['leave_type_id']?.toString() ?? '1') ?? 1,
        name: json['leave_type']?.toString() ?? 'Casual Leave',
        code: 'CL',
        annualAllowance: 12,
      );
    }

    AdminLeaveReviewerModel? rev;
    if (json['reviewer'] is Map<String, dynamic>) {
      rev = AdminLeaveReviewerModel.fromJson(json['reviewer']);
    }

    List<AdminLeaveActionModel> actList = [];
    if (json['actions'] is List) {
      actList = (json['actions'] as List)
          .whereType<Map<String, dynamic>>()
          .map((a) => AdminLeaveActionModel.fromJson(a))
          .toList();
    }

    AdminLeaveBalanceModel bal;
    if (json['leave_balance'] is Map<String, dynamic>) {
      bal = AdminLeaveBalanceModel.fromJson(json['leave_balance']);
    } else {
      bal = AdminLeaveBalanceModel(
        total: 12,
        taken: days.toInt(),
        pending: 0,
        remaining: (12 - days.toInt()) > 0 ? (12 - days.toInt()) : 0,
      );
    }

    return AdminLeaveDetailDataModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      userId: int.tryParse(json['user_id']?.toString() ?? '0') ?? 0,
      leaveTypeId: int.tryParse(json['leave_type_id']?.toString() ?? '0') ?? 0,
      fromDate: fDate,
      toDate: tDate,
      totalDays: days,
      reason: json['reason']?.toString() ?? '',
      contactDuringLeave: json['contact_during_leave']?.toString() ?? '',
      attachmentName: json['attachment_name']?.toString(),
      attachmentPath: json['attachment_path']?.toString(),
      status: normStatus,
      reviewNote: json['review_note']?.toString(),
      reviewedByUserId: int.tryParse(json['reviewed_by_user_id']?.toString() ?? ''),
      reviewedAt: rDate,
      createdAt: cDate,
      updatedAt: uDate,
      employee: emp,
      leaveType: lt,
      reviewer: rev,
      actions: actList,
      leaveBalance: bal,
      session: json['session']?.toString() ?? json['session_type']?.toString() ?? 'Full Day',
      addressDuringLeave: json['address_during_leave']?.toString(),
      assigneeName: json['assignee'] is Map ? json['assignee']['name']?.toString() : null,
      assigneeDesignation: json['assignee'] is Map ? json['assignee']['designation']?.toString() : null,
    );
  }

  String get formattedDates {
    if (fromDate == null) return 'N/A';
    if (toDate == null || fromDate == toDate) {
      return '${DateFormat('dd MMM yyyy').format(fromDate!)} (${DateFormat('EEE').format(fromDate!)})';
    }
    return '${DateFormat('dd MMM yyyy').format(fromDate!)} (${DateFormat('EEE').format(fromDate!)}) - ${DateFormat('dd MMM yyyy').format(toDate!)} (${DateFormat('EEE').format(toDate!)})';
  }

  String get formattedFromDate {
    if (fromDate == null) return 'N/A';
    return '${DateFormat('dd MMM yyyy').format(fromDate!)} (${DateFormat('EEE').format(fromDate!)})';
  }

  String get formattedToDate {
    if (toDate == null) return 'N/A';
    return '${DateFormat('dd MMM yyyy').format(toDate!)} (${DateFormat('EEE').format(toDate!)})';
  }

  String get durationString {
    if (totalDays == 1.0) return '1 Day';
    if (totalDays == 0.5) return '0.5 Day';
    return '${totalDays % 1 == 0 ? totalDays.toInt() : totalDays} Days';
  }

  String get formattedAppliedOn {
    if (createdAt != null) {
      return DateFormat('dd MMM yyyy, hh:mm a').format(createdAt!);
    }
    return 'Recently';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'leave_type_id': leaveTypeId,
      'from_date': fromDate?.toIso8601String(),
      'to_date': toDate?.toIso8601String(),
      'total_days': totalDays,
      'reason': reason,
      'contact_during_leave': contactDuringLeave,
      if (attachmentName != null) 'attachment_name': attachmentName,
      if (attachmentPath != null) 'attachment_path': attachmentPath,
      'status': status,
      if (reviewNote != null) 'review_note': reviewNote,
      if (reviewedByUserId != null) 'reviewed_by_user_id': reviewedByUserId,
      if (reviewedAt != null) 'reviewed_at': reviewedAt?.toIso8601String(),
      if (createdAt != null) 'created_at': createdAt?.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt?.toIso8601String(),
      'employee': employee.toJson(),
      'leave_type': leaveType.toJson(),
      if (reviewer != null) 'reviewer': reviewer!.toJson(),
      'actions': actions.map((a) => a.toJson()).toList(),
      'leave_balance': leaveBalance.toJson(),
    };
  }
}

class AdminLeaveTypeDetailModel {
  final int id;
  final String name;
  final String code;
  final String? description;
  final int annualAllowance;
  final bool isPaid;
  final bool requiresAttachment;
  final String status;

  AdminLeaveTypeDetailModel({
    required this.id,
    required this.name,
    required this.code,
    this.description,
    this.annualAllowance = 12,
    this.isPaid = true,
    this.requiresAttachment = false,
    this.status = 'Active',
  });

  factory AdminLeaveTypeDetailModel.fromJson(Map<String, dynamic> json) {
    return AdminLeaveTypeDetailModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? 'Casual Leave',
      code: json['code']?.toString() ?? 'CL',
      description: json['description']?.toString(),
      annualAllowance: int.tryParse(json['annual_allowance']?.toString() ?? '12') ?? 12,
      isPaid: json['is_paid'] == true || json['is_paid'] == 1 || json['is_paid']?.toString() == 'true',
      requiresAttachment: json['requires_attachment'] == true || json['requires_attachment'] == 1,
      status: json['status']?.toString() ?? 'Active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      if (description != null) 'description': description,
      'annual_allowance': annualAllowance,
      'is_paid': isPaid,
      'requires_attachment': requiresAttachment,
      'status': status,
    };
  }
}

class AdminLeaveReviewerModel {
  final int id;
  final String name;
  final String email;

  AdminLeaveReviewerModel({
    required this.id,
    required this.name,
    required this.email,
  });

  factory AdminLeaveReviewerModel.fromJson(Map<String, dynamic> json) {
    return AdminLeaveReviewerModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? 'Administrator',
      email: json['email']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}

class AdminLeaveActionModel {
  final int id;
  final String action;
  final String? note;
  final DateTime? createdAt;
  final AdminLeaveReviewerModel? actor;

  AdminLeaveActionModel({
    required this.id,
    required this.action,
    this.note,
    this.createdAt,
    this.actor,
  });

  factory AdminLeaveActionModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic dateVal) {
      if (dateVal == null) return null;
      if (dateVal is DateTime) return dateVal;
      try {
        return DateTime.parse(dateVal.toString());
      } catch (_) {
        return null;
      }
    }

    return AdminLeaveActionModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      action: json['action']?.toString() ?? 'Submitted',
      note: json['note']?.toString(),
      createdAt: parseDate(json['created_at']),
      actor: json['actor'] is Map<String, dynamic>
          ? AdminLeaveReviewerModel.fromJson(json['actor'])
          : null,
    );
  }

  String get formattedCreatedAt {
    if (createdAt != null) {
      return DateFormat('dd MMM yyyy, hh:mm a').format(createdAt!);
    }
    return 'Recently';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'action': action,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt?.toIso8601String(),
      if (actor != null) 'actor': actor!.toJson(),
    };
  }
}

class AdminLeaveBalanceModel {
  final int total;
  final int taken;
  final int pending;
  final int remaining;

  AdminLeaveBalanceModel({
    required this.total,
    required this.taken,
    required this.pending,
    required this.remaining,
  });

  factory AdminLeaveBalanceModel.fromJson(Map<String, dynamic> json) {
    return AdminLeaveBalanceModel(
      total: int.tryParse(json['total']?.toString() ?? '0') ?? 0,
      taken: int.tryParse(json['taken']?.toString() ?? '0') ?? 0,
      pending: int.tryParse(json['pending']?.toString() ?? '0') ?? 0,
      remaining: int.tryParse(json['remaining']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'taken': taken,
      'pending': pending,
      'remaining': remaining,
    };
  }
}
