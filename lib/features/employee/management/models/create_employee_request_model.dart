import 'dart:io';
import 'package:dio/dio.dart';

class CreateEmployeeRequestModel {
  final String name;
  final String employeeId;
  final String gender;
  final String dateOfBirth; // YYYY-MM-DD
  final String maritalStatus;
  final String bloodGroup;
  final String mobileNumber;
  final String? alternateMobileNumber;
  final String email;
  final String? emergencyContact;
  final String? streetAddress;
  final String? city;
  final String? postalCode;
  final String? state;
  final String? country;
  final String workMode;
  final String employeeType;
  final String department;
  final String designationId;
  final String? team;
  final String? assignedShiftId;
  final String dateOfJoining; // YYYY-MM-DD
  final String employmentStatus;
  final String? probationPeriod;
  final String? noticePeriod;
  final String salaryType;
  final String monthlyBaseSalary;
  final String salesTargetEnabled; // "0" or "1"
  final String? accountHolderName;
  final String? bankName;
  final String? accountNumber;
  final String? ifscCode;
  final String? branchName;
  final List<String> skills;
  final List<int> roleIds;
  final String? avatarPath;

  CreateEmployeeRequestModel({
    required this.name,
    required this.employeeId,
    required this.gender,
    required this.dateOfBirth,
    required this.maritalStatus,
    required this.bloodGroup,
    required this.mobileNumber,
    this.alternateMobileNumber,
    required this.email,
    this.emergencyContact,
    this.streetAddress,
    this.city,
    this.postalCode,
    this.state,
    this.country,
    required this.workMode,
    required this.employeeType,
    required this.department,
    required this.designationId,
    this.team,
    this.assignedShiftId,
    required this.dateOfJoining,
    required this.employmentStatus,
    this.probationPeriod,
    this.noticePeriod,
    required this.salaryType,
    required this.monthlyBaseSalary,
    this.salesTargetEnabled = '0',
    this.accountHolderName,
    this.bankName,
    this.accountNumber,
    this.ifscCode,
    this.branchName,
    this.skills = const [],
    this.roleIds = const [9],
    this.avatarPath,
  });

  Future<FormData> toFormData() async {
    final Map<String, dynamic> map = {
      'name': name,
      'employee_id': employeeId,
      'gender': gender,
      'date_of_birth': dateOfBirth,
      'marital_status': maritalStatus,
      'blood_group': bloodGroup,
      'mobile_number': mobileNumber,
      'email': email,
      'work_mode': workMode,
      'employee_type': employeeType,
      'department': department,
      'designation_id': designationId,
      'date_of_joining': dateOfJoining,
      'employment_status': employmentStatus,
      'salary_type': salaryType,
      'monthly_base_salary': monthlyBaseSalary,
      'sales_target_enabled': salesTargetEnabled,
    };

    if (alternateMobileNumber != null && alternateMobileNumber!.trim().isNotEmpty) {
      map['alternate_mobile_number'] = alternateMobileNumber!.trim();
    }
    if (emergencyContact != null && emergencyContact!.trim().isNotEmpty) {
      map['emergency_contact'] = emergencyContact!.trim();
    }
    if (streetAddress != null && streetAddress!.trim().isNotEmpty) {
      map['street_address'] = streetAddress!.trim();
    }
    if (city != null && city!.trim().isNotEmpty) {
      map['city'] = city!.trim();
    }
    if (postalCode != null && postalCode!.trim().isNotEmpty) {
      map['postal_code'] = postalCode!.trim();
    }
    if (state != null && state!.trim().isNotEmpty) {
      map['state'] = state!.trim();
    }
    if (country != null && country!.trim().isNotEmpty) {
      map['country'] = country!.trim();
    }
    if (team != null && team!.trim().isNotEmpty) {
      map['team'] = team!.trim();
    }
    if (assignedShiftId != null && assignedShiftId!.trim().isNotEmpty) {
      map['assigned_shift_id'] = assignedShiftId!.trim();
    }
    if (probationPeriod != null && probationPeriod!.trim().isNotEmpty) {
      map['probation_period'] = probationPeriod!.trim();
    }
    if (noticePeriod != null && noticePeriod!.trim().isNotEmpty) {
      map['notice_period'] = noticePeriod!.trim();
    }
    if (accountHolderName != null && accountHolderName!.trim().isNotEmpty) {
      map['account_holder_name'] = accountHolderName!.trim();
    }
    if (bankName != null && bankName!.trim().isNotEmpty) {
      map['bank_name'] = bankName!.trim();
    }
    if (accountNumber != null && accountNumber!.trim().isNotEmpty) {
      map['account_number'] = accountNumber!.trim();
    }
    if (ifscCode != null && ifscCode!.trim().isNotEmpty) {
      map['ifsc_code'] = ifscCode!.trim();
    }
    if (branchName != null && branchName!.trim().isNotEmpty) {
      map['branch_name'] = branchName!.trim();
    }

    // Role IDs: e.g. " [9]"
    if (roleIds.isNotEmpty) {
      map['role_ids'] = ' [${roleIds.join(', ')}]';
    }

    final formData = FormData.fromMap(map);

    // Skills array: skills[]
    for (final skill in skills) {
      if (skill.trim().isNotEmpty) {
        formData.fields.add(MapEntry('skills[]', skill.trim()));
      }
    }

    // Avatar upload if present
    if (avatarPath != null && avatarPath!.trim().isNotEmpty) {
      final file = File(avatarPath!);
      if (await file.exists()) {
        final filename = avatarPath!.split(Platform.pathSeparator).last;
        formData.files.add(
          MapEntry(
            'avtar',
            await MultipartFile.fromFile(
              avatarPath!,
              filename: filename,
            ),
          ),
        );
      }
    }

    return formData;
  }
}
