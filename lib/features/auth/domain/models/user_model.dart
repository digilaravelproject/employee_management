import 'dart:convert';
import '../../../../core/constants/app_constants.dart';

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
      originalName: json['original_name']?.toString(),
      fileName: json['file_name']?.toString(),
      mimeType: json['mime_type']?.toString(),
      size: json['size'] != null ? int.tryParse(json['size'].toString()) : null,
      url: json['url']?.toString(),
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
  final int? salesTargetEnabled;
  final String? salesTarget;
  final String? accountHolderName;
  final String? bankName;
  final String? accountNumber;
  final String? ifscCode;
  final String? branchName;
  final String? skills;
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
  final List<UserDocument>? documents;

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
    this.accountHolderName,
    this.bankName,
    this.accountNumber,
    this.ifscCode,
    this.branchName,
    this.skills,
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
    this.documents,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    List<UserDocument>? parsedDocuments;
    if (json['documents'] != null && json['documents'] is List) {
      parsedDocuments = (json['documents'] as List).map((doc) => UserDocument.fromJson(doc)).toList();
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
      salesTargetEnabled: json['sales_target_enabled'] != null ? int.tryParse(json['sales_target_enabled'].toString()) : null,
      salesTarget: json['sales_target']?.toString(),
      accountHolderName: json['account_holder_name']?.toString(),
      bankName: json['bank_name']?.toString(),
      accountNumber: json['account_number']?.toString(),
      ifscCode: json['ifsc_code']?.toString(),
      branchName: json['branch_name']?.toString(),
      skills: json['skills']?.toString(),
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
      documents: parsedDocuments,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'company_name': companyName,
      'owner_name': ownerName,
      'mobile_number': mobileNumber,
      'alternate_mobile_number': alternateMobileNumber,
      'emergency_contact': emergencyContact,
      'phone': phone,
      'department': department,
      'department_id': departmentId,
      'work_mode': workMode,
      'employee_type': employeeType,
      'team': team,
      'assigned_shift_id': assignedShiftId,
      'reporting_manager_id': reportingManagerId,
      'designation': designation,
      'designation_id': designationId,
      'employee_id': employeeId,
      'gender': gender,
      'date_of_birth': dateOfBirth,
      'marital_status': maritalStatus,
      'blood_group': bloodGroup,
      'date_of_joining': dateOfJoining,
      'monthly_salary': monthlySalary,
      'salary_type': salaryType,
      'sales_target_enabled': salesTargetEnabled,
      'sales_target': salesTarget,
      'account_holder_name': accountHolderName,
      'bank_name': bankName,
      'account_number': accountNumber,
      'ifsc_code': ifscCode,
      'branch_name': branchName,
      'skills': skills,
      'address': address,
      'street_address': streetAddress,
      'city': city,
      'postal_code': postalCode,
      'state': state,
      'country': country,
      'avatar': avatar,
      'status': status,
      'employment_status': employmentStatus,
      'probation_period': probationPeriod,
      'notice_period': noticePeriod,
      'role': role,
      'email': email,
      'email_verified_at': emailVerifiedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
      if (documents != null) 'documents': documents!.map((doc) => doc.toJson()).toList(),
    };
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }

  static UserModel? fromJsonString(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) return null;
    try {
      return UserModel.fromJson(jsonDecode(jsonString));
    } catch (e) {
      print('Error parsing user from JSON string: $e');
      return null;
    }
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, role: $role, companyName: $companyName)';
  }
}
