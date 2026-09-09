import 'package:flutter_test/flutter_test.dart';
import 'package:attendence_tracking_app/features/auth/domain/models/admin_signup_request_model.dart';
import 'package:attendence_tracking_app/features/auth/domain/models/admin_signup_response_model.dart';
import 'package:attendence_tracking_app/features/auth/domain/repositories/admin_signup_repository_interface.dart';
import 'package:attendence_tracking_app/features/auth/domain/usecases/admin_signup_usecase.dart';

class MockAdminSignupRepository implements AdminSignupRepositoryInterface {
  final AdminSignupResponseModel mockResponse;

  MockAdminSignupRepository(this.mockResponse);

  @override
  Future<AdminSignupResponseModel> adminSignup(
      AdminSignupRequestModel request) async {
    return mockResponse;
  }

  @override
  Future<AdminSignupResponseModel> adminLogin(
      AdminLoginRequestModel request) async {
    return mockResponse;
  }

  @override
  Future<AdminForgotPasswordResponseModel> adminForgotPassword(
      AdminForgotPasswordRequestModel request) async {
    return AdminForgotPasswordResponseModel(
      status: mockResponse.status,
      message: mockResponse.message,
      otpDebug: '375833',
    );
  }

  @override
  Future<AdminResetPasswordResponseModel> adminResetPassword(
      AdminResetPasswordRequestModel request) async {
    return AdminResetPasswordResponseModel(
      status: mockResponse.status,
      message: mockResponse.message,
    );
  }

  @override
  Future<AdminUpdatePasswordResponseModel> adminUpdatePassword(
      AdminUpdatePasswordRequestModel request) async {
    return AdminUpdatePasswordResponseModel(
      status: mockResponse.status,
      message: mockResponse.message,
    );
  }
}

void main() {
  group('Admin Signup Clean Architecture Tests', () {
    test('AdminSignupRequestModel serializes correctly to JSON', () {
      final request = AdminSignupRequestModel(
        companyName: 'Acme Solutions',
        ownerName: 'Darshan Kondekar',
        mobileNumber: '9876543210',
        email: 'owner@acmesolutions.com',
        password: 'Password@123',
        passwordConfirmation: 'Password@123',
      );

      final json = request.toJson();

      expect(json['company_name'], 'Acme Solutions');
      expect(json['owner_name'], 'Darshan Kondekar');
      expect(json['mobile_number'], '9876543210');
      expect(json['email'], 'owner@acmesolutions.com');
      expect(json['password'], 'Password@123');
      expect(json['password_confirmation'], 'Password@123');
    });

    test('AdminSignupResponseModel successfully parses success response', () {
      final successJson = {
        "status": true,
        "message": "Account created successfully.",
        "data": {
          "name": "Darshan Kondekar",
          "company_name": "Acme Solutions",
          "owner_name": "Darshan Kondekar",
          "mobile_number": "9876543210",
          "email": "owner@acmesolution.com",
          "role": "admin",
          "updated_at": "2026-09-09T05:17:18.000000Z",
          "created_at": "2026-09-09T05:17:18.000000Z",
          "id": 8
        },
        "access_token": "9|OWe7qpSXOfn6v7nmZP4NxcmOKO5xblOKzWWT1pAQ878099a0",
        "token_type": "Bearer"
      };

      final response = AdminSignupResponseModel.fromJson(successJson);

      expect(response.status, true);
      expect(response.message, 'Account created successfully.');
      expect(response.accessToken,
          '9|OWe7qpSXOfn6v7nmZP4NxcmOKO5xblOKzWWT1pAQ878099a0');
      expect(response.token_type ?? response.tokenType, 'Bearer');
      expect(response.data?.id, 8);
      expect(response.data?.companyName, 'Acme Solutions');
      expect(response.data?.ownerName, 'Darshan Kondekar');
      expect(response.data?.email, 'owner@acmesolution.com');
      expect(response.data?.role, 'admin');
    });

    test(
        'AdminSignupResponseModel parses validation error and extracts first error message',
        () {
      final errorJson = {
        "status": false,
        "message": "Validation error",
        "errors": {
          "email": [
            "This email address is already registered. Please login instead."
          ]
        }
      };

      final response = AdminSignupResponseModel.fromJson(errorJson);

      expect(response.status, false);
      expect(response.message, 'Validation error');
      expect(response.errors != null, true);
      expect(response.errors!['email']?.first,
          'This email address is already registered. Please login instead.');

      // Test helper method to get the first error message for snackbar
      final extractedMessage = response.getFirstErrorMessage();
      expect(extractedMessage,
          'This email address is already registered. Please login instead.');
    });

    test('AdminSignupUseCase calls repository and returns response', () async {
      final expectedResponse = AdminSignupResponseModel(
        status: true,
        message: 'Account created successfully.',
      );
      final mockRepo = MockAdminSignupRepository(expectedResponse);
      final useCase = AdminSignupUseCase(mockRepo);

      final result = await useCase.execute(AdminSignupRequestModel(
        companyName: 'Acme Solutions',
        ownerName: 'Darshan Kondekar',
        mobileNumber: '9876543210',
        email: 'owner@acmesolutions.com',
        password: 'Password@123',
        passwordConfirmation: 'Password@123',
      ));

      expect(result.status, true);
      expect(result.message, 'Account created successfully.');
    });

    test('Validation error extracts first error message correctly for multiple fields', () {
      final errorJson = {
        "status": false,
        "message": "Validation error",
        "errors": {
          "company_name": ["The company name field is required."],
          "owner_name": ["The owner name field is required."],
          "mobile_number": ["The mobile number field is required."],
          "email": ["The email field must be a valid email address."],
          "password": ["The password field is required."]
        }
      };

      final response = AdminSignupResponseModel.fromJson(errorJson);
      expect(response.status, false);
      expect(response.getFirstErrorMessage(), "The company name field is required.");
    });

    test('AdminLoginRequestModel serializes correctly to JSON', () {
      final request = AdminLoginRequestModel(
        email: 'owner@acmesolution.com',
        password: 'Password@123',
      );

      final json = request.toJson();
      expect(json['email'], 'owner@acmesolution.com');
      expect(json['password'], 'Password@123');
    });

    test('AdminLoginResponseModel parses login success response correctly', () {
      final loginSuccessJson = {
        "status": true,
        "message": "Login successful.",
        "data": {
          "id": 8,
          "name": "Darshan Kondekar",
          "company_name": "Acme Solutions",
          "owner_name": "Darshan Kondekar",
          "mobile_number": "9876543210",
          "emergency_contact": null,
          "phone": null,
          "department": null,
          "designation": null,
          "designation_id": null,
          "employee_id": null,
          "date_of_joining": null,
          "monthly_salary": null,
          "skills": null,
          "address": null,
          "avatar": null,
          "status": "Active",
          "role": "admin",
          "email": "owner@acmesolution.com",
          "email_verified_at": null,
          "created_at": "2026-09-09T05:17:18.000000Z",
          "updated_at": "2026-09-09T05:17:18.000000Z"
        },
        "access_token": "11|4Vn542eCpYcYHgkldFCmOcz0zID11lMdcpqfvgABccd12c10",
        "token_type": "Bearer"
      };

      final response = AdminSignupResponseModel.fromJson(loginSuccessJson);

      expect(response.status, true);
      expect(response.message, 'Login successful.');
      expect(response.data?.id, 8);
      expect(response.data?.name, 'Darshan Kondekar');
      expect(response.data?.companyName, 'Acme Solutions');
      expect(response.data?.userStatus, 'Active');
      expect(response.accessToken,
          '11|4Vn542eCpYcYHgkldFCmOcz0zID11lMdcpqfvgABccd12c10');
      expect(response.tokenType, 'Bearer');
    });

    test('AdminLoginUseCase executes and returns response', () async {
      final expectedResponse = AdminSignupResponseModel(
        status: true,
        message: 'Login successful.',
      );
      final mockRepo = MockAdminSignupRepository(expectedResponse);
      final useCase = AdminLoginUseCase(mockRepo);

      final result = await useCase.execute(AdminLoginRequestModel(
        email: 'owner@acmesolution.com',
        password: 'Password@123',
      ));

      expect(result.status, true);
      expect(result.message, 'Login successful.');
    });

    test('Admin login invalid credentials response message extraction', () {
      final invalidCredentialsJson = {
        "status": false,
        "message": "Invalid email address or password."
      };

      final response = AdminSignupResponseModel.fromJson(invalidCredentialsJson);
      expect(response.status, false);
      expect(response.getFirstErrorMessage(),
          'Invalid email address or password.');
    });

    test('AdminForgotPasswordRequestModel serializes correctly to JSON', () {
      final request = AdminForgotPasswordRequestModel(
        email: 'owner@acmesolutions.com',
      );

      final json = request.toJson();
      expect(json['email'], 'owner@acmesolutions.com');
    });

    test('AdminForgotPasswordResponseModel parses success response correctly', () {
      final successJson = {
        "status": true,
        "message": "A 6-digit verification code has been sent to your email address.",
        "otp_debug": "375833"
      };

      final response = AdminForgotPasswordResponseModel.fromJson(successJson);
      expect(response.status, true);
      expect(response.message,
          "A 6-digit verification code has been sent to your email address.");
      expect(response.otpDebug, "375833");
    });

    test(
        'AdminForgotPasswordResponseModel parses non-existent email validation error',
        () {
      final errorJson = {
        "status": false,
        "message": "Validation error",
        "errors": {
          "email": [
            "We could not find an account registered with this email address."
          ]
        }
      };

      final response = AdminForgotPasswordResponseModel.fromJson(errorJson);
      expect(response.status, false);
      expect(response.getFirstErrorMessage(),
          "We could not find an account registered with this email address.");
    });

    test('AdminForgotPasswordUseCase executes and returns response', () async {
      final expectedResponse = AdminSignupResponseModel(
        status: true,
        message: 'A 6-digit verification code has been sent to your email address.',
      );
      final mockRepo = MockAdminSignupRepository(expectedResponse);
      final useCase = AdminForgotPasswordUseCase(mockRepo);

      final result = await useCase.execute(AdminForgotPasswordRequestModel(
        email: 'owner@acmesolutions.com',
      ));

      expect(result.status, true);
      expect(result.message,
          'A 6-digit verification code has been sent to your email address.');
      expect(result.otpDebug, '375833');
    });

    test('AdminResetPasswordRequestModel serializes correctly to JSON', () {
      final request = AdminResetPasswordRequestModel(
        email: 'owner@acmesolutions.com',
        otp: '956769',
        password: 'NewSecurePassword@123',
        passwordConfirmation: 'NewSecurePassword@123',
      );

      final json = request.toJson();
      expect(json['email'], 'owner@acmesolutions.com');
      expect(json['otp'], '956769');
      expect(json['password'], 'NewSecurePassword@123');
      expect(json['password_confirmation'], 'NewSecurePassword@123');
    });

    test('AdminResetPasswordResponseModel parses success response correctly', () {
      final successJson = {
        "status": true,
        "message": "Password updated successfully. Please login with your new password."
      };

      final response = AdminResetPasswordResponseModel.fromJson(successJson);
      expect(response.status, true);
      expect(response.message,
          "Password updated successfully. Please login with your new password.");
    });

    test('AdminResetPasswordResponseModel parses invalid verification code error', () {
      final errorJson = {
        "status": false,
        "message": "Invalid verification code."
      };

      final response = AdminResetPasswordResponseModel.fromJson(errorJson);
      expect(response.status, false);
      expect(response.getFirstErrorMessage(), "Invalid verification code.");
    });

    test('AdminResetPasswordResponseModel parses mismatched confirmation error', () {
      final errorJson = {
        "status": false,
        "message": "Validation error",
        "errors": {
          "password": ["The password field confirmation does not match."]
        }
      };

      final response = AdminResetPasswordResponseModel.fromJson(errorJson);
      expect(response.status, false);
      expect(response.getFirstErrorMessage(), "The password field confirmation does not match.");
    });

    test('AdminResetPasswordUseCase executes and returns response', () async {
      final expectedResponse = AdminSignupResponseModel(
        status: true,
        message: 'Password updated successfully. Please login with your new password.',
      );
      final mockRepo = MockAdminSignupRepository(expectedResponse);
      final useCase = AdminResetPasswordUseCase(mockRepo);

      final result = await useCase.execute(AdminResetPasswordRequestModel(
        email: 'owner@acmesolutions.com',
        otp: '956769',
        password: 'NewSecurePassword@123',
        passwordConfirmation: 'NewSecurePassword@123',
      ));

      expect(result.status, true);
      expect(result.message,
          'Password updated successfully. Please login with your new password.');
    });

    test('AdminUpdatePasswordRequestModel serializes correctly to JSON', () {
      final request = AdminUpdatePasswordRequestModel(
        currentPassword: '1NewSecurePassword@123',
        newPassword: 'Password@123',
        confirmPassword: 'Password@123',
      );

      final json = request.toJson();
      expect(json['current_password'], '1NewSecurePassword@123');
      expect(json['new_password'], 'Password@123');
      expect(json['confirm_password'], 'Password@123');
    });

    test('AdminUpdatePasswordResponseModel parses success response correctly', () {
      final successJson = {
        "status": true,
        "message": "Password updated successfully."
      };

      final response = AdminUpdatePasswordResponseModel.fromJson(successJson);
      expect(response.status, true);
      expect(response.message, "Password updated successfully.");
    });

    test('AdminUpdatePasswordResponseModel parses incorrect current password error correctly', () {
      final errorJson = {
        "status": false,
        "message": "The current password provided is incorrect."
      };

      final response = AdminUpdatePasswordResponseModel.fromJson(errorJson);
      expect(response.status, false);
      expect(response.message, "The current password provided is incorrect.");
      expect(response.getFirstErrorMessage(), "The current password provided is incorrect.");
    });

    test('AdminUpdatePasswordResponseModel parses validation error correctly', () {
      final errorJson = {
        "status": false,
        "message": "Validation error",
        "errors": {
          "new_password": ["New password and confirm password do not match."]
        }
      };

      final response = AdminUpdatePasswordResponseModel.fromJson(errorJson);
      expect(response.status, false);
      expect(response.getFirstErrorMessage(), "New password and confirm password do not match.");
    });

    test('AdminUpdatePasswordUseCase executes and returns response', () async {
      final expectedResponse = AdminSignupResponseModel(
        status: true,
        message: 'Password updated successfully.',
      );
      final mockRepo = MockAdminSignupRepository(expectedResponse);
      final useCase = AdminUpdatePasswordUseCase(mockRepo);

      final result = await useCase.execute(AdminUpdatePasswordRequestModel(
        currentPassword: '1NewSecurePassword@123',
        newPassword: 'Password@123',
        confirmPassword: 'Password@123',
      ));

      expect(result.status, true);
      expect(result.message, 'Password updated successfully.');
    });
  });
}
