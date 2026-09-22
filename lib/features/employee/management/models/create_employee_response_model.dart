class CreateEmployeeResponseModel {
  final bool status;
  final String message;
  final CreateEmployeeData? data;
  final Map<String, dynamic>? errors;

  CreateEmployeeResponseModel({
    required this.status,
    required this.message,
    this.data,
    this.errors,
  });

  factory CreateEmployeeResponseModel.fromJson(Map<String, dynamic> json) {
    String parsedMessage = json['message']?.toString() ?? '';

    // Handle nested errors message if main message is generic
    if (json['errors'] is Map<String, dynamic> && (json['errors'] as Map).isNotEmpty) {
      final errorMap = json['errors'] as Map<String, dynamic>;
      final firstError = errorMap.values.first;
      if (firstError is List && firstError.isNotEmpty) {
        parsedMessage = '$parsedMessage: ${firstError.first}';
      } else if (firstError is String) {
        parsedMessage = '$parsedMessage: $firstError';
      }
    }

    return CreateEmployeeResponseModel(
      status: json['status'] == true || json['status'] == 1 || json['status']?.toString() == 'true',
      message: parsedMessage,
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? CreateEmployeeData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      errors: json['errors'] is Map<String, dynamic> ? (json['errors'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      if (data != null) 'data': data!.toJson(),
      if (errors != null) 'errors': errors,
    };
  }
}

class CreateEmployeeData {
  final int? id;
  final String? employeeId;
  final String? name;
  final String? email;
  final String? mobileNumber;
  final String? alternateMobileNumber;
  final String? emergencyContact;
  final String? gender;
  final String? dateOfBirth;
  final String? maritalStatus;
  final String? bloodGroup;
  final String? department;
  final dynamic designationId;
  final String? designation;
  final String? workMode;
  final String? employeeType;
  final String? team;
  final dynamic assignedShiftId;
  final String? dateOfJoining;
  final String? employmentStatus;
  final String? probationPeriod;
  final String? noticePeriod;
  final String? salaryType;
  final dynamic monthlyBaseSalary;
  final bool? salesTargetEnabled;
  final String? salesTargetMetricType;
  final dynamic salesTarget;
  final String? salesTargetPeriod;
  final dynamic incentiveCommissionPercent;
  final String? streetAddress;
  final String? city;
  final String? state;
  final String? postalCode;
  final String? country;
  final String? accountHolderName;
  final String? bankName;
  final String? accountNumber;
  final String? ifscCode;
  final String? branchName;
  final List<String> skills;
  final String? avatar;

  CreateEmployeeData({
    this.id,
    this.employeeId,
    this.name,
    this.email,
    this.mobileNumber,
    this.alternateMobileNumber,
    this.emergencyContact,
    this.gender,
    this.dateOfBirth,
    this.maritalStatus,
    this.bloodGroup,
    this.department,
    this.designationId,
    this.designation,
    this.workMode,
    this.employeeType,
    this.team,
    this.assignedShiftId,
    this.dateOfJoining,
    this.employmentStatus,
    this.probationPeriod,
    this.noticePeriod,
    this.salaryType,
    this.monthlyBaseSalary,
    this.salesTargetEnabled,
    this.salesTargetMetricType,
    this.salesTarget,
    this.salesTargetPeriod,
    this.incentiveCommissionPercent,
    this.streetAddress,
    this.city,
    this.state,
    this.postalCode,
    this.country,
    this.accountHolderName,
    this.bankName,
    this.accountNumber,
    this.ifscCode,
    this.branchName,
    this.skills = const [],
    this.avatar,
  });

  factory CreateEmployeeData.fromJson(Map<String, dynamic> json) {
    List<String> parsedSkills = [];
    if (json['skills'] is List) {
      parsedSkills = (json['skills'] as List).map((s) => s.toString()).toList();
    } else if (json['skills'] is String) {
      parsedSkills = (json['skills'] as String).split(',').map((s) => s.trim()).toList();
    }

    return CreateEmployeeData(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      employeeId: json['employee_id']?.toString(),
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      mobileNumber: json['mobile_number']?.toString() ?? json['phone']?.toString(),
      alternateMobileNumber: json['alternate_mobile_number']?.toString(),
      emergencyContact: json['emergency_contact']?.toString(),
      gender: json['gender']?.toString(),
      dateOfBirth: json['date_of_birth']?.toString(),
      maritalStatus: json['marital_status']?.toString(),
      bloodGroup: json['blood_group']?.toString(),
      department: json['department']?.toString(),
      designationId: json['designation_id'],
      designation: json['designation']?.toString(),
      workMode: json['work_mode']?.toString(),
      employeeType: json['employee_type']?.toString(),
      team: json['team']?.toString(),
      assignedShiftId: json['assigned_shift_id'],
      dateOfJoining: json['date_of_joining']?.toString(),
      employmentStatus: json['employment_status']?.toString(),
      probationPeriod: json['probation_period']?.toString(),
      noticePeriod: json['notice_period']?.toString(),
      salaryType: json['salary_type']?.toString(),
      monthlyBaseSalary: json['monthly_base_salary'] ?? json['monthly_salary'],
      salesTargetEnabled: json['sales_target_enabled'] == true ||
          json['sales_target_enabled'] == 1 ||
          json['sales_target_enabled']?.toString() == '1' ||
          json['sales_target_enabled']?.toString() == 'true',
      salesTargetMetricType: json['sales_target_metric_type']?.toString(),
      salesTarget: json['sales_target'],
      salesTargetPeriod: json['sales_target_period']?.toString(),
      incentiveCommissionPercent: json['incentive_commission_percent'],
      streetAddress: json['street_address']?.toString() ?? json['address']?.toString(),
      city: json['city']?.toString(),
      state: json['state']?.toString(),
      postalCode: json['postal_code']?.toString() ?? json['pincode']?.toString(),
      country: json['country']?.toString(),
      accountHolderName: json['account_holder_name']?.toString(),
      bankName: json['bank_name']?.toString(),
      accountNumber: json['account_number']?.toString(),
      ifscCode: json['ifsc_code']?.toString(),
      branchName: json['branch_name']?.toString(),
      skills: parsedSkills,
      avatar: json['avatar']?.toString() ?? json['avtar']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'name': name,
      'email': email,
      'mobile_number': mobileNumber,
      'alternate_mobile_number': alternateMobileNumber,
      'emergency_contact': emergencyContact,
      'gender': gender,
      'date_of_birth': dateOfBirth,
      'marital_status': maritalStatus,
      'blood_group': bloodGroup,
      'department': department,
      'designation_id': designationId,
      'designation': designation,
      'work_mode': workMode,
      'employee_type': employeeType,
      'team': team,
      'assigned_shift_id': assignedShiftId,
      'date_of_joining': dateOfJoining,
      'employment_status': employmentStatus,
      'probation_period': probationPeriod,
      'notice_period': noticePeriod,
      'salary_type': salaryType,
      'monthly_base_salary': monthlyBaseSalary,
      'sales_target_enabled': salesTargetEnabled,
      'sales_target_metric_type': salesTargetMetricType,
      'sales_target': salesTarget,
      'sales_target_period': salesTargetPeriod,
      'incentive_commission_percent': incentiveCommissionPercent,
      'street_address': streetAddress,
      'city': city,
      'state': state,
      'postal_code': postalCode,
      'country': country,
      'account_holder_name': accountHolderName,
      'bank_name': bankName,
      'account_number': accountNumber,
      'ifsc_code': ifscCode,
      'branch_name': branchName,
      'skills': skills,
      'avatar': avatar,
    };
  }
}
