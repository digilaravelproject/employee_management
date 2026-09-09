class AdminSignupRequestModel {
  final String companyName;
  final String ownerName;
  final String mobileNumber;
  final String email;
  final String password;
  final String passwordConfirmation;

  AdminSignupRequestModel({
    required this.companyName,
    required this.ownerName,
    required this.mobileNumber,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
  });

  Map<String, dynamic> toJson() {
    return {
      'company_name': companyName,
      'owner_name': ownerName,
      'mobile_number': mobileNumber,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
    };
  }

  factory AdminSignupRequestModel.fromJson(Map<String, dynamic> json) {
    return AdminSignupRequestModel(
      companyName: json['company_name']?.toString() ?? '',
      ownerName: json['owner_name']?.toString() ?? '',
      mobileNumber: json['mobile_number']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      password: json['password']?.toString() ?? '',
      passwordConfirmation: json['password_confirmation']?.toString() ?? '',
    );
  }

  AdminSignupRequestModel copyWith({
    String? companyName,
    String? ownerName,
    String? mobileNumber,
    String? email,
    String? password,
    String? passwordConfirmation,
  }) {
    return AdminSignupRequestModel(
      companyName: companyName ?? this.companyName,
      ownerName: ownerName ?? this.ownerName,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      email: email ?? this.email,
      password: password ?? this.password,
      passwordConfirmation: passwordConfirmation ?? this.passwordConfirmation,
    );
  }
}

class AdminLoginRequestModel {
  final String email;
  final String password;

  AdminLoginRequestModel({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }

  factory AdminLoginRequestModel.fromJson(Map<String, dynamic> json) {
    return AdminLoginRequestModel(
      email: json['email']?.toString() ?? '',
      password: json['password']?.toString() ?? '',
    );
  }

  AdminLoginRequestModel copyWith({
    String? email,
    String? password,
  }) {
    return AdminLoginRequestModel(
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }
}

class AdminForgotPasswordRequestModel {
  final String email;

  AdminForgotPasswordRequestModel({
    required this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }

  factory AdminForgotPasswordRequestModel.fromJson(Map<String, dynamic> json) {
    return AdminForgotPasswordRequestModel(
      email: json['email']?.toString() ?? '',
    );
  }

  AdminForgotPasswordRequestModel copyWith({
    String? email,
  }) {
    return AdminForgotPasswordRequestModel(
      email: email ?? this.email,
    );
  }
}

class AdminResetPasswordRequestModel {
  final String email;
  final String otp;
  final String password;
  final String passwordConfirmation;

  AdminResetPasswordRequestModel({
    required this.email,
    required this.otp,
    required this.password,
    required this.passwordConfirmation,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'otp': otp,
      'password': password,
      'password_confirmation': passwordConfirmation,
    };
  }

  factory AdminResetPasswordRequestModel.fromJson(Map<String, dynamic> json) {
    return AdminResetPasswordRequestModel(
      email: json['email']?.toString() ?? '',
      otp: json['otp']?.toString() ?? '',
      password: json['password']?.toString() ?? '',
      passwordConfirmation: json['password_confirmation']?.toString() ?? '',
    );
  }

  AdminResetPasswordRequestModel copyWith({
    String? email,
    String? otp,
    String? password,
    String? passwordConfirmation,
  }) {
    return AdminResetPasswordRequestModel(
      email: email ?? this.email,
      otp: otp ?? this.otp,
      password: password ?? this.password,
      passwordConfirmation: passwordConfirmation ?? this.passwordConfirmation,
    );
  }
}

class AdminUpdatePasswordRequestModel {
  final String currentPassword;
  final String newPassword;
  final String confirmPassword;

  AdminUpdatePasswordRequestModel({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'current_password': currentPassword,
      'new_password': newPassword,
      'confirm_password': confirmPassword,
    };
  }

  factory AdminUpdatePasswordRequestModel.fromJson(Map<String, dynamic> json) {
    return AdminUpdatePasswordRequestModel(
      currentPassword: json['current_password']?.toString() ?? '',
      newPassword: json['new_password']?.toString() ?? '',
      confirmPassword: json['confirm_password']?.toString() ?? '',
    );
  }

  AdminUpdatePasswordRequestModel copyWith({
    String? currentPassword,
    String? newPassword,
    String? confirmPassword,
  }) {
    return AdminUpdatePasswordRequestModel(
      currentPassword: currentPassword ?? this.currentPassword,
      newPassword: newPassword ?? this.newPassword,
      confirmPassword: confirmPassword ?? this.confirmPassword,
    );
  }
}



