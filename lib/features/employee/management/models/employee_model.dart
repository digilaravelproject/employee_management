class EmployeeDetailResponseModel {
  final bool status;
  final String message;
  final EmployeeModel? data;

  EmployeeDetailResponseModel({
    required this.status,
    required this.message,
    this.data,
  });

  factory EmployeeDetailResponseModel.fromJson(Map<String, dynamic> json) {
    return EmployeeDetailResponseModel(
      status: json['status'] == true ||
          json['status'] == 1 ||
          json['status']?.toString().toLowerCase() == 'true',
      message: json['message']?.toString() ?? '',
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? EmployeeModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class EmployeeListResponseModel {
  final bool status;
  final String message;
  final int total;
  final List<EmployeeModel> data;

  EmployeeListResponseModel({
    required this.status,
    required this.message,
    this.total = 0,
    required this.data,
  });

  factory EmployeeListResponseModel.fromJson(Map<String, dynamic> json) {
    List<EmployeeModel> employeesList = [];
    if (json['data'] is List) {
      employeesList = (json['data'] as List)
          .whereType<Map<String, dynamic>>()
          .map((item) => EmployeeModel.fromJson(item))
          .toList();
    } else if (json['employees'] is List) {
      employeesList = (json['employees'] as List)
          .whereType<Map<String, dynamic>>()
          .map((item) => EmployeeModel.fromJson(item))
          .toList();
    }

    return EmployeeListResponseModel(
      status: json['status'] == true ||
          json['status'] == 1 ||
          json['status']?.toString().toLowerCase() == 'true',
      message: json['message']?.toString() ?? '',
      total: int.tryParse(json['total']?.toString() ?? '') ?? employeesList.length,
      data: employeesList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'total': total,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}

class EmployeeModel {
  final String id;
  final String? designationId;
  final String? assignedShiftId;
  final String? reportingManagerId;
  final String? departmentId;
  final String employeeId;
  final String name;
  final String mobile;
  final String email;
  final String role;
  final String designation;
  final double salary;
  final List<String> skills;
  final String joiningDate;
  final String address;
  final String emergencyContact;
  final String? profilePic;
  final String gender;
  final String dob;
  final String maritalStatus;
  final String bloodGroup;
  final String alternateMobile;
  final String department;
  final String team;
  final String shift;
  final bool isActive;

  // Address details
  final String city;
  final String state;
  final String pincode;
  final String country;

  // Employment & Status Lifecycle
  final String workMode; // 'Office', 'Remote', 'Hybrid'
  final String employeeType; // 'Full-time', 'Part-time', 'Contract', 'Freelancer', 'Intern'
  final String reportingManager;
  final String employmentStatus; // 'Active', 'Probation', 'Notice Period', 'Terminated', 'Inactive'
  final String probationPeriod; // 'None', '1 Month', '3 Months', '6 Months'
  final String noticePeriod; // '15 Days', '30 Days', '60 Days', '90 Days'

  // Compensation & Target
  final String salaryType; // 'Monthly', 'Hourly', 'Weekly', 'Annual CTC'
  final bool hasSalesTarget;
  final String targetType; // 'Revenue', 'Deals Closed', 'Units Sold'
  final String targetAmount;
  final String targetPeriod; // 'Monthly', 'Quarterly', 'Yearly'
  final String incentivePercent;

  // Bank Details
  final String accountHolderName;
  final String bankName;
  final String accountNumber;
  final String ifscCode;
  final String branchName;

  // Timestamps
  final String? createdAt;
  final String? updatedAt;

  EmployeeModel({
    required this.id,
    this.designationId,
    this.assignedShiftId,
    this.reportingManagerId,
    this.departmentId,
    required this.employeeId,
    required this.name,
    required this.mobile,
    required this.email,
    this.role = 'employee',
    required this.designation,
    this.salary = 0.0,
    this.skills = const [],
    required this.joiningDate,
    required this.address,
    this.emergencyContact = '',
    this.profilePic,
    this.gender = '',
    this.dob = '',
    this.maritalStatus = '',
    this.bloodGroup = '',
    this.alternateMobile = '',
    this.department = '',
    this.team = '',
    this.shift = '',
    this.isActive = true,
    this.city = '',
    this.state = '',
    this.pincode = '',
    this.country = '',
    this.workMode = '',
    this.employeeType = '',
    this.reportingManager = '',
    this.employmentStatus = 'Active',
    this.probationPeriod = '',
    this.noticePeriod = '',
    this.salaryType = 'Monthly',
    this.hasSalesTarget = false,
    this.targetType = 'Revenue',
    this.targetAmount = '0',
    this.targetPeriod = 'Monthly',
    this.incentivePercent = '0',
    this.accountHolderName = '',
    this.bankName = '',
    this.accountNumber = '',
    this.ifscCode = '',
    this.branchName = '',
    this.createdAt,
    this.updatedAt,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    // Parse skills
    List<String> parsedSkills = [];
    if (json['skills'] is List) {
      parsedSkills = (json['skills'] as List)
          .where((s) => s != null)
          .map((s) => s.toString().trim())
          .where((s) => s.isNotEmpty)
          .toList();
    } else if (json['skills'] is String && json['skills'].toString().isNotEmpty) {
      parsedSkills = json['skills']
          .toString()
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }

    // Parse department
    String parsedDept = '';
    if (json['department'] != null && json['department'].toString().isNotEmpty) {
      parsedDept = json['department'].toString();
    } else if (json['department_details'] is Map && json['department_details']['name'] != null) {
      parsedDept = json['department_details']['name'].toString();
    }

    // Parse designation
    String parsedDesig = '';
    if (json['designation'] != null && json['designation'].toString().isNotEmpty) {
      parsedDesig = json['designation'].toString();
    } else if (json['designation_details'] is Map && json['designation_details']['name'] != null) {
      parsedDesig = json['designation_details']['name'].toString();
    }

    // Parse shift
    String parsedShift = '';
    if (json['assigned_shift'] is Map && json['assigned_shift']['name'] != null) {
      parsedShift = json['assigned_shift']['name'].toString();
    } else if (json['shift'] != null && json['shift'].toString().isNotEmpty) {
      parsedShift = json['shift'].toString();
    }

    // Parse reporting manager
    String parsedManager = '';
    if (json['reporting_manager'] is Map && json['reporting_manager']['name'] != null) {
      parsedManager = json['reporting_manager']['name'].toString();
    } else if (json['reporting_manager'] != null && json['reporting_manager'].toString().isNotEmpty) {
      parsedManager = json['reporting_manager'].toString();
    }

    // Parse status
    String rawStatus = json['employment_status']?.toString() ?? json['status']?.toString() ?? 'Active';
    bool activeFlag = rawStatus.toLowerCase() == 'active' || rawStatus.toLowerCase() == 'probation';

    double sal = 0.0;
    if (json['monthly_base_salary'] != null) {
      sal = double.tryParse(json['monthly_base_salary'].toString()) ?? 0.0;
    } else if (json['monthly_salary'] != null) {
      sal = double.tryParse(json['monthly_salary'].toString()) ?? 0.0;
    } else if (json['salary'] != null) {
      sal = double.tryParse(json['salary'].toString()) ?? 0.0;
    }

    bool salesTarget = json['sales_target_enabled'] == true ||
        json['sales_target_enabled'] == 1 ||
        json['sales_target_enabled']?.toString() == '1' ||
        json['sales_target_enabled']?.toString().toLowerCase() == 'true';

    // Parse address fallback
    String parsedAddress = json['address']?.toString() ?? json['street_address']?.toString() ?? '';

    // Mobile fallback
    String parsedMobile = json['mobile_number']?.toString() ?? json['phone']?.toString() ?? '';

    return EmployeeModel(
      id: json['id']?.toString() ?? '',
      designationId: json['designation_id']?.toString(),
      assignedShiftId: json['assigned_shift_id']?.toString(),
      reportingManagerId: json['reporting_manager_id']?.toString(),
      departmentId: json['department_id']?.toString(),
      employeeId: json['employee_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      mobile: parsedMobile,
      alternateMobile: json['alternate_mobile_number']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? 'employee',
      designation: parsedDesig,
      salary: sal,
      skills: parsedSkills,
      joiningDate: json['date_of_joining']?.toString() ?? '',
      address: parsedAddress,
      emergencyContact: json['emergency_contact']?.toString() ?? '',
      profilePic: json['avatar']?.toString() ?? json['profile_pic']?.toString(),
      gender: json['gender']?.toString() ?? '',
      dob: json['date_of_birth']?.toString() ?? json['dob']?.toString() ?? '',
      maritalStatus: json['marital_status']?.toString() ?? '',
      bloodGroup: json['blood_group']?.toString() ?? '',
      department: parsedDept,
      team: json['team']?.toString() ?? '',
      shift: parsedShift,
      isActive: activeFlag,
      city: json['city']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      pincode: json['postal_code']?.toString() ?? json['pincode']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      workMode: json['work_mode']?.toString() ?? '',
      employeeType: json['employee_type']?.toString() ?? '',
      reportingManager: parsedManager,
      employmentStatus: rawStatus,
      probationPeriod: json['probation_period']?.toString() ?? '',
      noticePeriod: json['notice_period']?.toString() ?? '',
      salaryType: json['salary_type']?.toString() ?? 'Monthly',
      hasSalesTarget: salesTarget,
      targetType: json['sales_target_metric_type']?.toString() ?? 'Revenue',
      targetAmount: json['sales_target']?.toString() ?? '0',
      targetPeriod: json['sales_target_period']?.toString() ?? 'Monthly',
      incentivePercent: json['incentive_commission_percent']?.toString() ?? '0',
      accountHolderName: json['account_holder_name']?.toString() ?? '',
      bankName: json['bank_name']?.toString() ?? '',
      accountNumber: json['account_number']?.toString() ?? '',
      ifscCode: json['ifsc_code']?.toString() ?? '',
      branchName: json['branch_name']?.toString() ?? '',
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'designation_id': designationId,
      'assigned_shift_id': assignedShiftId,
      'reporting_manager_id': reportingManagerId,
      'department_id': departmentId,
      'employee_id': employeeId,
      'name': name,
      'mobile_number': mobile,
      'alternate_mobile_number': alternateMobile,
      'phone': mobile,
      'email': email,
      'role': role,
      'designation': designation,
      'monthly_base_salary': salary.toString(),
      'monthly_salary': salary.toString(),
      'skills': skills,
      'date_of_joining': joiningDate,
      'address': address,
      'street_address': address,
      'emergency_contact': emergencyContact,
      'avatar': profilePic,
      'gender': gender,
      'date_of_birth': dob,
      'marital_status': maritalStatus,
      'blood_group': bloodGroup,
      'department': department,
      'team': team,
      'shift': shift,
      'status': employmentStatus,
      'employment_status': employmentStatus,
      'city': city,
      'state': state,
      'postal_code': pincode,
      'country': country,
      'work_mode': workMode,
      'employee_type': employeeType,
      'reporting_manager': reportingManager,
      'probation_period': probationPeriod,
      'notice_period': noticePeriod,
      'salary_type': salaryType,
      'sales_target_enabled': hasSalesTarget,
      'sales_target_metric_type': targetType,
      'sales_target': targetAmount,
      'sales_target_period': targetPeriod,
      'incentive_commission_percent': incentivePercent,
      'account_holder_name': accountHolderName,
      'bank_name': bankName,
      'account_number': accountNumber,
      'ifsc_code': ifscCode,
      'branch_name': branchName,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  EmployeeModel copyWith({
    String? id,
    String? designationId,
    String? assignedShiftId,
    String? reportingManagerId,
    String? departmentId,
    String? employeeId,
    String? name,
    String? mobile,
    String? email,
    String? role,
    String? designation,
    double? salary,
    List<String>? skills,
    String? joiningDate,
    String? address,
    String? emergencyContact,
    String? profilePic,
    String? gender,
    String? dob,
    String? alternateMobile,
    String? department,
    String? team,
    String? shift,
    bool? isActive,
    String? city,
    String? state,
    String? pincode,
    String? country,
    String? workMode,
    String? employeeType,
    String? reportingManager,
    String employmentStatus = '',
    String? probationPeriod,
    String? noticePeriod,
    String? salaryType,
    bool? hasSalesTarget,
    String? targetType,
    String? targetAmount,
    String? targetPeriod,
    String? incentivePercent,
    String? accountHolderName,
    String? bankName,
    String? accountNumber,
    String? ifscCode,
    String? branchName,
    String? maritalStatus,
    String? bloodGroup,
    String? createdAt,
    String? updatedAt,
  }) {
    return EmployeeModel(
      id: id ?? this.id,
      designationId: designationId ?? this.designationId,
      assignedShiftId: assignedShiftId ?? this.assignedShiftId,
      reportingManagerId: reportingManagerId ?? this.reportingManagerId,
      departmentId: departmentId ?? this.departmentId,
      employeeId: employeeId ?? this.employeeId,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      role: role ?? this.role,
      designation: designation ?? this.designation,
      salary: salary ?? this.salary,
      skills: skills ?? this.skills,
      joiningDate: joiningDate ?? this.joiningDate,
      address: address ?? this.address,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      profilePic: profilePic ?? this.profilePic,
      gender: gender ?? this.gender,
      dob: dob ?? this.dob,
      alternateMobile: alternateMobile ?? this.alternateMobile,
      department: department ?? this.department,
      team: team ?? this.team,
      shift: shift ?? this.shift,
      isActive: isActive ?? this.isActive,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      country: country ?? this.country,
      workMode: workMode ?? this.workMode,
      employeeType: employeeType ?? this.employeeType,
      reportingManager: reportingManager ?? this.reportingManager,
      employmentStatus: employmentStatus.isNotEmpty ? employmentStatus : this.employmentStatus,
      probationPeriod: probationPeriod ?? this.probationPeriod,
      noticePeriod: noticePeriod ?? this.noticePeriod,
      salaryType: salaryType ?? this.salaryType,
      hasSalesTarget: hasSalesTarget ?? this.hasSalesTarget,
      targetType: targetType ?? this.targetType,
      targetAmount: targetAmount ?? this.targetAmount,
      targetPeriod: targetPeriod ?? this.targetPeriod,
      incentivePercent: incentivePercent ?? this.incentivePercent,
      accountHolderName: accountHolderName ?? this.accountHolderName,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      ifscCode: ifscCode ?? this.ifscCode,
      branchName: branchName ?? this.branchName,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
