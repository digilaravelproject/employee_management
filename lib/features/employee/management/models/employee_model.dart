class EmployeeModel {
  final String id;
  final String employeeId;
  final String name;
  final String mobile;
  final String email;
  final String designation;
  final double salary;
  final List<String> skills;
  final String joiningDate;
  final String address;
  final String emergencyContact;
  final String? profilePic;
  final String gender;
  final String dob;
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

  EmployeeModel({
    required this.id,
    required this.employeeId,
    required this.name,
    required this.mobile,
    required this.email,
    required this.designation,
    this.salary = 0.0,
    this.skills = const [],
    required this.joiningDate,
    required this.address,
    this.emergencyContact = '',
    this.profilePic,
    this.gender = 'Male',
    this.dob = '',
    this.alternateMobile = '',
    this.department = 'Engineering',
    this.team = 'Team Alpha',
    this.shift = 'Morning Shift',
    this.isActive = true,
    this.city = '',
    this.state = '',
    this.pincode = '',
    this.country = 'India',
    this.workMode = 'Office',
    this.employeeType = 'Full-time',
    this.reportingManager = '',
    this.employmentStatus = 'Active',
    this.probationPeriod = '3 Months',
    this.noticePeriod = '30 Days',
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
  });

  EmployeeModel copyWith({
    String? id,
    String? employeeId,
    String? name,
    String? mobile,
    String? email,
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
  }) {
    return EmployeeModel(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
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
    );
  }
}

