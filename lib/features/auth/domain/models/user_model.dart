import 'dart:convert';

class UserDocument {
  final int? id;
  final String? originalName;
  final String? fileName;
  final String? mimeType;
  final int? size;
  final String? url;
  final String? createdAt;

  UserDocument({
    this.id,
    this.originalName,
    this.fileName,
    this.mimeType,
    this.size,
    this.url,
    this.createdAt,
  });

  factory UserDocument.fromJson(Map<String, dynamic> json) {
    return UserDocument(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      originalName: json['original_name']?.toString() ??
          json['name']?.toString() ??
          json['title']?.toString(),
      fileName: json['file_name']?.toString() ?? json['file']?.toString(),
      mimeType: json['mime_type']?.toString(),
      size: json['size'] != null ? int.tryParse(json['size'].toString()) : null,
      url: json['url']?.toString() ??
          json['path']?.toString() ??
          json['file_path']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'original_name': originalName,
      'file_name': fileName,
      'mime_type': mimeType,
      'size': size,
      'url': url,
      'created_at': createdAt,
    };
  }
}

class UserRole {
  final int? id;
  final String? name;
  final String? department;
  final String? description;
  final bool? status;

  UserRole({
    this.id,
    this.name,
    this.department,
    this.description,
    this.status,
  });

  factory UserRole.fromJson(Map<String, dynamic> json) {
    return UserRole(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      name: json['name']?.toString(),
      department: json['department']?.toString(),
      description: json['description']?.toString(),
      status: json['status'] is bool
          ? json['status']
          : (json['status']?.toString() == '1' ||
              json['status']?.toString().toLowerCase() == 'true'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'department': department,
      'description': description,
      'status': status,
    };
  }
}

class DesignationDetails {
  final int? id;
  final String? name;
  final String? hierarchyLevel;
  final List<String>? skills;
  final String? rawSkills;
  final String? createdAt;
  final String? updatedAt;

  DesignationDetails({
    this.id,
    this.name,
    this.hierarchyLevel,
    this.skills,
    this.rawSkills,
    this.createdAt,
    this.updatedAt,
  });

  factory DesignationDetails.fromJson(Map<String, dynamic> json) {
    List<String>? parsedSkills;
    final rawSkillsVal = json['skills'];
    if (rawSkillsVal is List) {
      parsedSkills = rawSkillsVal.map((e) => e.toString().trim()).toList();
    } else if (rawSkillsVal is String && rawSkillsVal.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawSkillsVal);
        if (decoded is List) {
          parsedSkills = decoded.map((e) => e.toString().trim()).toList();
        }
      } catch (_) {
        parsedSkills = rawSkillsVal
            .replaceAll('[', '')
            .replaceAll(']', '')
            .replaceAll('"', '')
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
    }

    return DesignationDetails(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      name: json['name']?.toString(),
      hierarchyLevel: json['hierarchy_level']?.toString(),
      skills: parsedSkills,
      rawSkills: rawSkillsVal?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'hierarchy_level': hierarchyLevel,
      'skills': rawSkills ?? (skills != null ? jsonEncode(skills) : null),
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class DepartmentDetails {
  final int? id;
  final String? name;
  final String? code;
  final String? description;
  final String? status;
  final String? createdAt;
  final String? updatedAt;

  DepartmentDetails({
    this.id,
    this.name,
    this.code,
    this.description,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory DepartmentDetails.fromJson(Map<String, dynamic> json) {
    return DepartmentDetails(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      name: json['name']?.toString(),
      code: json['code']?.toString(),
      description: json['description']?.toString(),
      status: json['status']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'description': description,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class ShiftBreak {
  final String? name;
  final String? type;
  final String? startTime;
  final String? endTime;
  final int? durationMinutes;

  ShiftBreak({
    this.name,
    this.type,
    this.startTime,
    this.endTime,
    this.durationMinutes,
  });

  factory ShiftBreak.fromJson(Map<String, dynamic> json) {
    return ShiftBreak(
      name: json['name']?.toString(),
      type: json['type']?.toString(),
      startTime: json['start_time']?.toString(),
      endTime: json['end_time']?.toString(),
      durationMinutes: json['duration_minutes'] != null
          ? int.tryParse(json['duration_minutes'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'start_time': startTime,
      'end_time': endTime,
      'duration_minutes': durationMinutes,
    };
  }
}

class ShiftWorkingDay {
  final String? day;
  final bool? enabled;
  final String? startTime;
  final String? endTime;

  ShiftWorkingDay({
    this.day,
    this.enabled,
    this.startTime,
    this.endTime,
  });

  factory ShiftWorkingDay.fromJson(Map<String, dynamic> json) {
    return ShiftWorkingDay(
      day: json['day']?.toString(),
      enabled: json['enabled'] is bool
          ? json['enabled']
          : (json['enabled']?.toString().toLowerCase() == 'true' ||
              json['enabled']?.toString() == '1'),
      startTime: json['start_time']?.toString(),
      endTime: json['end_time']?.toString(),
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

class AssignedShift {
  final int? id;
  final String? name;
  final String? code;
  final String? shiftType;
  final String? startTime;
  final String? endTime;
  final int? crossMidnight;
  final int? breaksEnabled;
  final List<ShiftBreak>? breaks;
  final String? rawBreaks;
  final String? breakDuration;
  final String? totalDuration;
  final String? graceTimeLate;
  final int? gracePeriodMinutes;
  final int? lateAfterMinutes;
  final int? minimumWorkingMinutes;
  final int? earlyLeavingAllowed;
  final int? autoMarkLate;
  final int? autoMarkHalfDay;
  final int? lateThresholdMinutes;
  final int? halfDayAfterMinutes;
  final String? overtimeAfter;
  final int? overtimeEnabled;
  final int? overtimeStartsAfterMinutes;
  final int? minimumOvertimeMinutes;
  final String? overtimeCalculation;
  final int? overtimeApprovalRequired;
  final List<ShiftWorkingDay>? workingDays;
  final String? rawWorkingDays;
  final String? description;
  final String? status;
  final String? createdAt;
  final String? updatedAt;

  AssignedShift({
    this.id,
    this.name,
    this.code,
    this.shiftType,
    this.startTime,
    this.endTime,
    this.crossMidnight,
    this.breaksEnabled,
    this.breaks,
    this.rawBreaks,
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
    this.workingDays,
    this.rawWorkingDays,
    this.description,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory AssignedShift.fromJson(Map<String, dynamic> json) {
    List<ShiftBreak>? parsedBreaks;
    final rawBreaksVal = json['breaks'];
    if (rawBreaksVal is List) {
      parsedBreaks = rawBreaksVal
          .whereType<Map>()
          .map((b) => ShiftBreak.fromJson(Map<String, dynamic>.from(b)))
          .toList();
    } else if (rawBreaksVal is String && rawBreaksVal.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawBreaksVal);
        if (decoded is List) {
          parsedBreaks = decoded
              .whereType<Map>()
              .map((b) => ShiftBreak.fromJson(Map<String, dynamic>.from(b)))
              .toList();
        }
      } catch (_) {}
    }

    List<ShiftWorkingDay>? parsedDays;
    final rawDaysVal = json['working_days'];
    if (rawDaysVal is List) {
      parsedDays = rawDaysVal
          .whereType<Map>()
          .map((d) => ShiftWorkingDay.fromJson(Map<String, dynamic>.from(d)))
          .toList();
    } else if (rawDaysVal is String && rawDaysVal.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawDaysVal);
        if (decoded is List) {
          parsedDays = decoded
              .whereType<Map>()
              .map((d) => ShiftWorkingDay.fromJson(Map<String, dynamic>.from(d)))
              .toList();
        }
      } catch (_) {}
    }

    return AssignedShift(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      name: json['name']?.toString(),
      code: json['code']?.toString(),
      shiftType: json['shift_type']?.toString(),
      startTime: json['start_time']?.toString(),
      endTime: json['end_time']?.toString(),
      crossMidnight: json['cross_midnight'] != null
          ? int.tryParse(json['cross_midnight'].toString())
          : null,
      breaksEnabled: json['breaks_enabled'] != null
          ? int.tryParse(json['breaks_enabled'].toString())
          : null,
      breaks: parsedBreaks,
      rawBreaks: rawBreaksVal?.toString(),
      breakDuration: json['break_duration']?.toString(),
      totalDuration: json['total_duration']?.toString(),
      graceTimeLate: json['grace_time_late']?.toString(),
      gracePeriodMinutes: json['grace_period_minutes'] != null
          ? int.tryParse(json['grace_period_minutes'].toString())
          : null,
      lateAfterMinutes: json['late_after_minutes'] != null
          ? int.tryParse(json['late_after_minutes'].toString())
          : null,
      minimumWorkingMinutes: json['minimum_working_minutes'] != null
          ? int.tryParse(json['minimum_working_minutes'].toString())
          : null,
      earlyLeavingAllowed: json['early_leaving_allowed'] != null
          ? int.tryParse(json['early_leaving_allowed'].toString())
          : null,
      autoMarkLate: json['auto_mark_late'] != null
          ? int.tryParse(json['auto_mark_late'].toString())
          : null,
      autoMarkHalfDay: json['auto_mark_half_day'] != null
          ? int.tryParse(json['auto_mark_half_day'].toString())
          : null,
      lateThresholdMinutes: json['late_threshold_minutes'] != null
          ? int.tryParse(json['late_threshold_minutes'].toString())
          : null,
      halfDayAfterMinutes: json['half_day_after_minutes'] != null
          ? int.tryParse(json['half_day_after_minutes'].toString())
          : null,
      overtimeAfter: json['overtime_after']?.toString(),
      overtimeEnabled: json['overtime_enabled'] != null
          ? int.tryParse(json['overtime_enabled'].toString())
          : null,
      overtimeStartsAfterMinutes: json['overtime_starts_after_minutes'] != null
          ? int.tryParse(json['overtime_starts_after_minutes'].toString())
          : null,
      minimumOvertimeMinutes: json['minimum_overtime_minutes'] != null
          ? int.tryParse(json['minimum_overtime_minutes'].toString())
          : null,
      overtimeCalculation: json['overtime_calculation']?.toString(),
      overtimeApprovalRequired: json['overtime_approval_required'] != null
          ? int.tryParse(json['overtime_approval_required'].toString())
          : null,
      workingDays: parsedDays,
      rawWorkingDays: rawDaysVal?.toString(),
      description: json['description']?.toString(),
      status: json['status']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
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
      'breaks': rawBreaks ??
          (breaks != null
              ? jsonEncode(breaks!.map((b) => b.toJson()).toList())
              : null),
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
      'working_days': rawWorkingDays ??
          (workingDays != null
              ? jsonEncode(workingDays!.map((d) => d.toJson()).toList())
              : null),
      'description': description,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class UserModel {
  final int id;
  final String name;
  final String? companyName;
  final String? ownerName;
  final String? mobileNumber;
  final String? alternateMobileNumber;
  final String? emergencyContact;
  final String? phone;
  final String? department;
  final String? departmentId;
  final String? workMode;
  final String? employeeType;
  final String? team;
  final String? assignedShiftId;
  final String? reportingManagerId;
  final String? designation;
  final String? designationId;
  final String? employeeId;
  final String? gender;
  final String? dateOfBirth;
  final String? maritalStatus;
  final String? bloodGroup;
  final String? dateOfJoining;
  final String? monthlySalary;
  final String? salaryType;
  final dynamic salesTargetEnabled;
  final String? salesTarget;
  final String? salesTargetMetricType;
  final String? salesTargetPeriod;
  final String? incentiveCommissionPercent;
  final String? accountHolderName;
  final String? bankName;
  final String? accountNumber;
  final String? ifscCode;
  final String? branchName;
  final String? skills;
  final List<String>? skillsList;
  final String? address;
  final String? streetAddress;
  final String? city;
  final String? postalCode;
  final String? state;
  final String? country;
  final String? avatar;
  final String? status;
  final String? employmentStatus;
  final String? probationPeriod;
  final String? noticePeriod;
  final String role;
  final String email;
  final String? emailVerifiedAt;
  final String? createdAt;
  final String? updatedAt;
  final DesignationDetails? designationDetails;
  final DepartmentDetails? departmentDetails;
  final AssignedShift? assignedShift;
  final List<UserRole>? roles;
  final List<int>? roleIds;
  final List<UserDocument>? documents;
  final Map<String, dynamic>? rawJson;

  UserModel({
    required this.id,
    required this.name,
    this.companyName,
    this.ownerName,
    this.mobileNumber,
    this.alternateMobileNumber,
    this.emergencyContact,
    this.phone,
    this.department,
    this.departmentId,
    this.workMode,
    this.employeeType,
    this.team,
    this.assignedShiftId,
    this.reportingManagerId,
    this.designation,
    this.designationId,
    this.employeeId,
    this.gender,
    this.dateOfBirth,
    this.maritalStatus,
    this.bloodGroup,
    this.dateOfJoining,
    this.monthlySalary,
    this.salaryType,
    this.salesTargetEnabled,
    this.salesTarget,
    this.salesTargetMetricType,
    this.salesTargetPeriod,
    this.incentiveCommissionPercent,
    this.accountHolderName,
    this.bankName,
    this.accountNumber,
    this.ifscCode,
    this.branchName,
    this.skills,
    this.skillsList,
    this.address,
    this.streetAddress,
    this.city,
    this.postalCode,
    this.state,
    this.country,
    this.avatar,
    this.status,
    this.employmentStatus,
    this.probationPeriod,
    this.noticePeriod,
    required this.role,
    required this.email,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
    this.designationDetails,
    this.departmentDetails,
    this.assignedShift,
    this.roles,
    this.roleIds,
    this.documents,
    this.rawJson,
  });

  bool get isSalesTargetEnabled =>
      salesTargetEnabled == true ||
      salesTargetEnabled == 1 ||
      salesTargetEnabled?.toString() == '1' ||
      salesTargetEnabled?.toString().toLowerCase() == 'true';

  int get salesTargetEnabledInt => isSalesTargetEnabled ? 1 : 0;

  String get skillsDisplay =>
      skillsList != null && skillsList!.isNotEmpty
          ? skillsList!.join(', ')
          : (skills ?? '');

  String get primaryRoleTitle =>
      roles != null && roles!.isNotEmpty
          ? (roles!.first.name ?? role)
          : role;

  int? get primaryRoleId {
    if (roleIds != null && roleIds!.isNotEmpty) {
      return roleIds!.first;
    }
    if (roles != null && roles!.isNotEmpty && roles!.first.id != null) {
      return roles!.first.id;
    }
    if (rawJson != null) {
      final directRoleId = rawJson!['role_id'];
      if (directRoleId != null) {
        return int.tryParse(directRoleId.toString());
      }
      if (rawJson!['role_ids'] is List && (rawJson!['role_ids'] as List).isNotEmpty) {
        return int.tryParse((rawJson!['role_ids'] as List).first.toString());
      }
      if (rawJson!['role'] is Map && rawJson!['role']['id'] != null) {
        return int.tryParse(rawJson!['role']['id'].toString());
      }
      if (rawJson!['role'] is int) {
        return rawJson!['role'] as int;
      }
      if (rawJson!['user'] is Map) {
        final u = rawJson!['user'] as Map;
        if (u['role_id'] != null) {
          return int.tryParse(u['role_id'].toString());
        }
        if (u['role'] is Map && u['role']['id'] != null) {
          return int.tryParse(u['role']['id'].toString());
        }
      }
    }
    return null;
  }

  String get shiftDisplay => assignedShift != null
      ? '${assignedShift!.name ?? 'Shift'} (${assignedShift!.startTime ?? ''} - ${assignedShift!.endTime ?? ''})'
      : '';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Parse documents
    List<UserDocument>? parsedDocuments;
    final rawDocs = json['documents'] ?? json['documnts'];
    if (rawDocs != null && rawDocs is List) {
      parsedDocuments = rawDocs
          .whereType<Map>()
          .map((doc) => UserDocument.fromJson(Map<String, dynamic>.from(doc)))
          .toList();
    }

    // Parse skills
    List<String> parsedSkillsList = [];
    final rawSkills = json['skills'];
    if (rawSkills is List) {
      parsedSkillsList = rawSkills
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
    } else if (rawSkills is String && rawSkills.isNotEmpty) {
      final str = rawSkills.trim();
      if (str.startsWith('[') && str.endsWith(']')) {
        try {
          final decoded = jsonDecode(str);
          if (decoded is List) {
            parsedSkillsList = decoded
                .map((e) => e.toString().trim())
                .where((e) => e.isNotEmpty)
                .toList();
          }
        } catch (_) {
          parsedSkillsList = str
              .replaceAll('[', '')
              .replaceAll(']', '')
              .replaceAll('"', '')
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
        }
      } else {
        parsedSkillsList = str
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
    }

    final String? skillsFormatted = parsedSkillsList.isNotEmpty
        ? parsedSkillsList.join(', ')
        : (rawSkills is String ? rawSkills : null);

    // Parse designation details
    DesignationDetails? designationDetails;
    if (json['designation_details'] is Map) {
      designationDetails = DesignationDetails.fromJson(
          Map<String, dynamic>.from(json['designation_details']));
    }

    // Parse department details
    DepartmentDetails? departmentDetails;
    if (json['department_details'] is Map) {
      departmentDetails = DepartmentDetails.fromJson(
          Map<String, dynamic>.from(json['department_details']));
    }

    // Parse assigned shift
    AssignedShift? assignedShift;
    if (json['assigned_shift'] is Map) {
      assignedShift = AssignedShift.fromJson(
          Map<String, dynamic>.from(json['assigned_shift']));
    }

    // Parse roles
    List<UserRole>? parsedRoles;
    if (json['roles'] is List) {
      parsedRoles = (json['roles'] as List)
          .whereType<Map>()
          .map((r) => UserRole.fromJson(Map<String, dynamic>.from(r)))
          .toList();
    }

    // Parse role_ids
    List<int>? parsedRoleIds;
    if (json['role_ids'] is List) {
      parsedRoleIds = (json['role_ids'] as List)
          .map((id) => int.tryParse(id.toString()))
          .whereType<int>()
          .toList();
    }

    return UserModel(
      id: json['id'] != null ? int.parse(json['id'].toString()) : 0,
      name: json['name']?.toString() ?? '',
      companyName: json['company_name']?.toString(),
      ownerName: json['owner_name']?.toString(),
      mobileNumber: json['mobile_number']?.toString(),
      alternateMobileNumber: json['alternate_mobile_number']?.toString(),
      emergencyContact: json['emergency_contact']?.toString(),
      phone: json['phone']?.toString(),
      department: json['department']?.toString(),
      departmentId: json['department_id']?.toString(),
      workMode: json['work_mode']?.toString(),
      employeeType: json['employee_type']?.toString(),
      team: json['team']?.toString(),
      assignedShiftId: json['assigned_shift_id']?.toString(),
      reportingManagerId: json['reporting_manager_id']?.toString(),
      designation: json['designation']?.toString(),
      designationId: json['designation_id']?.toString(),
      employeeId: json['employee_id']?.toString(),
      gender: json['gender']?.toString(),
      dateOfBirth: json['date_of_birth']?.toString(),
      maritalStatus: json['marital_status']?.toString(),
      bloodGroup: json['blood_group']?.toString(),
      dateOfJoining: json['date_of_joining']?.toString(),
      monthlySalary: json['monthly_salary']?.toString(),
      salaryType: json['salary_type']?.toString(),
      salesTargetEnabled: json['sales_target_enabled'],
      salesTarget: json['sales_target']?.toString(),
      salesTargetMetricType: json['sales_target_metric_type']?.toString(),
      salesTargetPeriod: json['sales_target_period']?.toString(),
      incentiveCommissionPercent:
          json['incentive_commission_percent']?.toString(),
      accountHolderName: json['account_holder_name']?.toString(),
      bankName: json['bank_name']?.toString(),
      accountNumber: json['account_number']?.toString(),
      ifscCode: json['ifsc_code']?.toString(),
      branchName: json['branch_name']?.toString(),
      skills: skillsFormatted,
      skillsList: parsedSkillsList.isNotEmpty ? parsedSkillsList : null,
      address: json['address']?.toString(),
      streetAddress: json['street_address']?.toString(),
      city: json['city']?.toString(),
      postalCode: json['postal_code']?.toString(),
      state: json['state']?.toString(),
      country: json['country']?.toString(),
      avatar: json['avatar']?.toString(),
      status: json['status']?.toString(),
      employmentStatus: json['employment_status']?.toString(),
      probationPeriod: json['probation_period']?.toString(),
      noticePeriod: json['notice_period']?.toString(),
      role: json['role']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      emailVerifiedAt: json['email_verified_at']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      designationDetails: designationDetails,
      departmentDetails: departmentDetails,
      assignedShift: assignedShift,
      roles: parsedRoles,
      roleIds: parsedRoleIds,
      documents: parsedDocuments,
      rawJson: json,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = {};

    // 1. Preserve original raw keys so no extra API fields are lost
    if (rawJson != null) {
      result.addAll(rawJson!);
    }

    // 2. Override with current model fields
    result['id'] = id;
    result['name'] = name;
    result['company_name'] = companyName;
    result['owner_name'] = ownerName;
    result['mobile_number'] = mobileNumber;
    result['alternate_mobile_number'] = alternateMobileNumber;
    result['emergency_contact'] = emergencyContact;
    result['phone'] = phone;
    result['department'] = department;
    result['department_id'] = departmentId;
    result['work_mode'] = workMode;
    result['employee_type'] = employeeType;
    result['team'] = team;
    result['assigned_shift_id'] = assignedShiftId != null
        ? int.tryParse(assignedShiftId!) ?? assignedShiftId
        : null;
    result['reporting_manager_id'] = reportingManagerId;
    result['designation'] = designation;
    result['designation_id'] = designationId != null
        ? int.tryParse(designationId!) ?? designationId
        : null;
    result['employee_id'] = employeeId;
    result['gender'] = gender;
    result['date_of_birth'] = dateOfBirth;
    result['marital_status'] = maritalStatus;
    result['blood_group'] = bloodGroup;
    result['date_of_joining'] = dateOfJoining;
    result['monthly_salary'] = monthlySalary;
    result['salary_type'] = salaryType;
    result['sales_target_enabled'] = isSalesTargetEnabled;
    result['sales_target'] = salesTarget;
    result['sales_target_metric_type'] = salesTargetMetricType;
    result['sales_target_period'] = salesTargetPeriod;
    result['incentive_commission_percent'] = incentiveCommissionPercent;
    result['account_holder_name'] = accountHolderName;
    result['bank_name'] = bankName;
    result['account_number'] = accountNumber;
    result['ifsc_code'] = ifscCode;
    result['branch_name'] = branchName;
    result['skills'] = skillsList ?? (skills != null ? [skills!] : <String>[]);
    result['address'] = address;
    result['street_address'] = streetAddress;
    result['city'] = city;
    result['postal_code'] = postalCode;
    result['state'] = state;
    result['country'] = country;
    result['avatar'] = avatar;
    result['status'] = status;
    result['employment_status'] = employmentStatus;
    result['probation_period'] = probationPeriod;
    result['notice_period'] = noticePeriod;
    result['role'] = role;
    result['email'] = email;
    result['email_verified_at'] = emailVerifiedAt;
    result['created_at'] = createdAt;
    result['updated_at'] = updatedAt;

    if (designationDetails != null) {
      result['designation_details'] = designationDetails!.toJson();
    }
    if (departmentDetails != null) {
      result['department_details'] = departmentDetails!.toJson();
    }
    if (assignedShift != null) {
      result['assigned_shift'] = assignedShift!.toJson();
    }
    if (roles != null) {
      result['roles'] = roles!.map((r) => r.toJson()).toList();
    }
    if (roleIds != null) {
      result['role_ids'] = roleIds;
    }
    if (documents != null) {
      result['documents'] = documents!.map((doc) => doc.toJson()).toList();
    }

    return result;
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }

  static UserModel? fromJsonString(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) return null;
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is Map<String, dynamic>) {
        return UserModel.fromJson(decoded);
      }
      return null;
    } catch (e) {
      print('Error parsing user from JSON string: $e');
      return null;
    }
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, role: $role, designation: $designation, companyName: $companyName)';
  }
}
