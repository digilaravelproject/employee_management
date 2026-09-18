class AdminSignupResponseModel {
  final bool status;
  final String message;
  final AdminUserData? data;
  final Map<String, dynamic>? rawData;
  final String? accessToken;
  final String? tokenType;
  final Map<String, List<String>>? errors;

  // ignore: non_constant_identifier_names
  String? get access_token => accessToken;
  // ignore: non_constant_identifier_names
  String? get token_type => tokenType;

  AdminSignupResponseModel({
    required this.status,
    required this.message,
    this.data,
    this.rawData,
    this.accessToken,
    this.tokenType,
    this.errors,
  });

  factory AdminSignupResponseModel.fromJson(Map<String, dynamic> json) {
    // Parse status
    bool isStatusSuccess = false;
    final statusVal = json['status'];
    if (statusVal is bool) {
      isStatusSuccess = statusVal;
    } else if (statusVal != null) {
      isStatusSuccess = statusVal.toString().toLowerCase() == 'true';
    } else if (json['success'] is bool) {
      isStatusSuccess = json['success'];
    }

    // Parse data
    AdminUserData? userData;
    if (json['data'] is Map<String, dynamic>) {
      userData = AdminUserData.fromJson(json['data'] as Map<String, dynamic>);
    }

    // Parse errors: { "email": [ "This email address is already registered. Please login instead." ] }
    Map<String, List<String>>? parsedErrors;
    if (json['errors'] is Map) {
      parsedErrors = {};
      final rawErrors = json['errors'] as Map;
      rawErrors.forEach((key, value) {
        if (value is List) {
          parsedErrors![key.toString()] =
              value.map((item) => item.toString()).toList();
        } else if (value != null) {
          parsedErrors![key.toString()] = [value.toString()];
        }
      });
    }

    return AdminSignupResponseModel(
      status: isStatusSuccess,
      message: json['message']?.toString() ??
          (isStatusSuccess ? 'Account created successfully.' : 'Validation error'),
      data: userData,
      rawData: json['data'] is Map<String, dynamic> ? json['data'] : null,
      accessToken: json['access_token']?.toString(),
      tokenType: json['token_type']?.toString(),
      errors: parsedErrors,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      if (data != null) 'data': data!.toJson(),
      if (accessToken != null) 'access_token': accessToken,
      if (tokenType != null) 'token_type': tokenType,
      if (errors != null) 'errors': errors,
    };
  }

  /// Extracts the first error message from errors map.
  /// If errors contains {"email": ["This email address..."]}, it extracts that string.
  String getFirstErrorMessage() {
    if (errors != null && errors!.isNotEmpty) {
      for (final messages in errors!.values) {
        if (messages.isNotEmpty) {
          return messages.first;
        }
      }
    }
    if (message.isNotEmpty) {
      return message;
    }
    return 'An unexpected error occurred. Please try again.';
  }
}

class AdminUserData {
  final int? id;
  final String? name;
  final String? companyName;
  final String? ownerName;
  final String? mobileNumber;
  final String? email;
  final String? role;
  final String? emergencyContact;
  final String? phone;
  final String? department;
  final String? designation;
  final String? designationId;
  final String? employeeId;
  final String? dateOfJoining;
  final String? monthlySalary;
  final String? skills;
  final String? address;
  final String? avatar;
  final String? userStatus;
  final String? emailVerifiedAt;
  final String? createdAt;
  final String? updatedAt;

  AdminUserData({
    this.id,
    this.name,
    this.companyName,
    this.ownerName,
    this.mobileNumber,
    this.email,
    this.role,
    this.emergencyContact,
    this.phone,
    this.department,
    this.designation,
    this.designationId,
    this.employeeId,
    this.dateOfJoining,
    this.monthlySalary,
    this.skills,
    this.address,
    this.avatar,
    this.userStatus,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory AdminUserData.fromJson(Map<String, dynamic> json) {
    return AdminUserData(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      name: json['name']?.toString(),
      companyName: json['company_name']?.toString(),
      ownerName: json['owner_name']?.toString(),
      mobileNumber: json['mobile_number']?.toString(),
      email: json['email']?.toString(),
      role: json['role']?.toString(),
      emergencyContact: json['emergency_contact']?.toString(),
      phone: json['phone']?.toString(),
      department: json['department']?.toString(),
      designation: json['designation']?.toString(),
      designationId: json['designation_id']?.toString(),
      employeeId: json['employee_id']?.toString(),
      dateOfJoining: json['date_of_joining']?.toString(),
      monthlySalary: json['monthly_salary']?.toString(),
      skills: json['skills']?.toString(),
      address: json['address']?.toString(),
      avatar: json['avatar']?.toString(),
      userStatus: json['status']?.toString(),
      emailVerifiedAt: json['email_verified_at']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'company_name': companyName,
      'owner_name': ownerName,
      'mobile_number': mobileNumber,
      'email': email,
      'role': role,
      'emergency_contact': emergencyContact,
      'phone': phone,
      'department': department,
      'designation': designation,
      'designation_id': designationId,
      'employee_id': employeeId,
      'date_of_joining': dateOfJoining,
      'monthly_salary': monthlySalary,
      'skills': skills,
      'address': address,
      'avatar': avatar,
      'status': userStatus,
      'email_verified_at': emailVerifiedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

typedef AdminLoginResponseModel = AdminSignupResponseModel;

class AdminForgotPasswordResponseModel {
  final bool status;
  final String message;
  final String? otpDebug;
  final Map<String, List<String>>? errors;

  AdminForgotPasswordResponseModel({
    required this.status,
    required this.message,
    this.otpDebug,
    this.errors,
  });

  factory AdminForgotPasswordResponseModel.fromJson(Map<String, dynamic> json) {
    bool isStatusSuccess = false;
    final statusVal = json['status'];
    if (statusVal is bool) {
      isStatusSuccess = statusVal;
    } else if (statusVal != null) {
      isStatusSuccess = statusVal.toString().toLowerCase() == 'true';
    } else if (json['success'] is bool) {
      isStatusSuccess = json['success'];
    }

    Map<String, List<String>>? parsedErrors;
    if (json['errors'] is Map) {
      parsedErrors = {};
      final rawErrors = json['errors'] as Map;
      rawErrors.forEach((key, value) {
        if (value is List) {
          parsedErrors![key.toString()] =
              value.map((item) => item.toString()).toList();
        } else if (value != null) {
          parsedErrors![key.toString()] = [value.toString()];
        }
      });
    }

    return AdminForgotPasswordResponseModel(
      status: isStatusSuccess,
      message: json['message']?.toString() ??
          (isStatusSuccess
              ? 'Verification code has been sent.'
              : 'Validation error'),
      otpDebug: json['otp_debug']?.toString(),
      errors: parsedErrors,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      if (otpDebug != null) 'otp_debug': otpDebug,
      if (errors != null) 'errors': errors,
    };
  }

  String getFirstErrorMessage() {
    if (errors != null && errors!.isNotEmpty) {
      for (final messages in errors!.values) {
        if (messages.isNotEmpty) {
          return messages.first;
        }
      }
    }
    if (message.isNotEmpty) {
      return message;
    }
    return 'An unexpected error occurred. Please try again.';
  }
}

class AdminResetPasswordResponseModel {
  final bool status;
  final String message;
  final Map<String, List<String>>? errors;

  AdminResetPasswordResponseModel({
    required this.status,
    required this.message,
    this.errors,
  });

  factory AdminResetPasswordResponseModel.fromJson(Map<String, dynamic> json) {
    bool isStatusSuccess = false;
    final statusVal = json['status'];
    if (statusVal is bool) {
      isStatusSuccess = statusVal;
    } else if (statusVal != null) {
      isStatusSuccess = statusVal.toString().toLowerCase() == 'true';
    } else if (json['success'] is bool) {
      isStatusSuccess = json['success'];
    }

    Map<String, List<String>>? parsedErrors;
    if (json['errors'] is Map) {
      parsedErrors = {};
      final rawErrors = json['errors'] as Map;
      rawErrors.forEach((key, value) {
        if (value is List) {
          parsedErrors![key.toString()] =
              value.map((item) => item.toString()).toList();
        } else if (value != null) {
          parsedErrors![key.toString()] = [value.toString()];
        }
      });
    }

    return AdminResetPasswordResponseModel(
      status: isStatusSuccess,
      message: json['message']?.toString() ??
          (isStatusSuccess
              ? 'Password updated successfully.'
              : 'Failed to reset password.'),
      errors: parsedErrors,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      if (errors != null) 'errors': errors,
    };
  }

  String getFirstErrorMessage() {
    if (errors != null && errors!.isNotEmpty) {
      for (final messages in errors!.values) {
        if (messages.isNotEmpty) {
          return messages.first;
        }
      }
    }
    if (message.isNotEmpty) {
      return message;
    }
    return 'An unexpected error occurred. Please try again.';
  }
}

class AdminUpdatePasswordResponseModel {
  final bool status;
  final String message;
  final Map<String, List<String>>? errors;

  AdminUpdatePasswordResponseModel({
    required this.status,
    required this.message,
    this.errors,
  });

  factory AdminUpdatePasswordResponseModel.fromJson(Map<String, dynamic> json) {
    bool isStatusSuccess = false;
    final statusVal = json['status'];
    if (statusVal is bool) {
      isStatusSuccess = statusVal;
    } else if (statusVal != null) {
      isStatusSuccess = statusVal.toString().toLowerCase() == 'true';
    } else if (json['success'] is bool) {
      isStatusSuccess = json['success'];
    }

    Map<String, List<String>>? parsedErrors;
    if (json['errors'] is Map) {
      parsedErrors = {};
      final rawErrors = json['errors'] as Map;
      rawErrors.forEach((key, value) {
        if (value is List) {
          parsedErrors![key.toString()] =
              value.map((item) => item.toString()).toList();
        } else if (value != null) {
          parsedErrors![key.toString()] = [value.toString()];
        }
      });
    }

    return AdminUpdatePasswordResponseModel(
      status: isStatusSuccess,
      message: json['message']?.toString() ??
          (isStatusSuccess
              ? 'Password updated successfully.'
              : 'Failed to update password.'),
      errors: parsedErrors,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      if (errors != null) 'errors': errors,
    };
  }

  String getFirstErrorMessage() {
    if (errors != null && errors!.isNotEmpty) {
      for (final messages in errors!.values) {
        if (messages.isNotEmpty) {
          return messages.first;
        }
      }
    }
    if (message.isNotEmpty) {
      return message;
    }
    return 'An unexpected error occurred. Please try again.';
  }
}




