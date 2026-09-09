import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/network/api_client.dart';
import '../../../../core/utils/logger.dart';
import '../models/admin_signup_request_model.dart';
import '../models/admin_signup_response_model.dart';
import 'admin_signup_repository_interface.dart';

class AdminSignupRepository implements AdminSignupRepositoryInterface {
  final ApiClient _apiClient;

  AdminSignupRepository(this._apiClient);

  @override
  Future<AdminSignupResponseModel> adminSignup(
      AdminSignupRequestModel request) async {
    try {
      Logger.d('AdminSignupRepository => Calling signup endpoint: ${AppConstants.adminSignupUrl}');
      Logger.d('AdminSignupRepository => Payload: ${request.toJson()}');

      final response = await _apiClient.post(
        AppConstants.adminSignupUrl,
        data: request.toJson(),
        handleError: false,
        showToaster: false,
      );

      Logger.d('AdminSignupRepository => Status: ${response.statusCode}, isSuccess: ${response.isSuccess}');
      Logger.d('AdminSignupRepository => Raw Json: ${response.json}');

      if (response.json != null) {
        return AdminSignupResponseModel.fromJson(response.json!);
      } else if (response.body is Map<String, dynamic>) {
        return AdminSignupResponseModel.fromJson(
            response.body as Map<String, dynamic>);
      } else {
        return AdminSignupResponseModel(
          status: response.isSuccess,
          message: response.message.isNotEmpty
              ? response.message
              : (response.isSuccess
                  ? 'Account created successfully.'
                  : 'Signup failed. Please try again.'),
        );
      }
    } catch (e, stackTrace) {
      Logger.e('AdminSignupRepository => Exception: $e');
      Logger.e('AdminSignupRepository => StackTrace: $stackTrace');
      return AdminSignupResponseModel(
        status: false,
        message: 'Something went wrong: ${e.toString()}',
      );
    }
  }

  @override
  Future<AdminSignupResponseModel> adminLogin(
      AdminLoginRequestModel request) async {
    try {
      Logger.d('AdminSignupRepository => Calling login endpoint: ${AppConstants.adminLoginUrl}');
      Logger.d('AdminSignupRepository => Payload: ${request.toJson()}');

      final response = await _apiClient.post(
        AppConstants.adminLoginUrl,
        data: request.toJson(),
        handleError: false,
        showToaster: false,
      );

      Logger.d('AdminSignupRepository => Login Status: ${response.statusCode}, isSuccess: ${response.isSuccess}');
      Logger.d('AdminSignupRepository => Login Raw Json: ${response.json}');

      if (response.json != null) {
        return AdminSignupResponseModel.fromJson(response.json!);
      } else if (response.body is Map<String, dynamic>) {
        return AdminSignupResponseModel.fromJson(
            response.body as Map<String, dynamic>);
      } else {
        return AdminSignupResponseModel(
          status: response.isSuccess,
          message: response.message.isNotEmpty
              ? response.message
              : (response.isSuccess
                  ? 'Login successful.'
                  : 'Invalid email address or password.'),
        );
      }
    } catch (e, stackTrace) {
      Logger.e('AdminSignupRepository => Login Exception: $e');
      Logger.e('AdminSignupRepository => StackTrace: $stackTrace');
      return AdminSignupResponseModel(
        status: false,
        message: 'Something went wrong: ${e.toString()}',
      );
    }
  }

  @override
  Future<AdminForgotPasswordResponseModel> adminForgotPassword(
      AdminForgotPasswordRequestModel request) async {
    try {
      Logger.d('AdminSignupRepository => Calling forgot-password endpoint: ${AppConstants.adminForgotPasswordUrl}');
      Logger.d('AdminSignupRepository => Payload: ${request.toJson()}');

      final response = await _apiClient.post(
        AppConstants.adminForgotPasswordUrl,
        data: request.toJson(),
        handleError: false,
        showToaster: false,
      );

      Logger.d('AdminSignupRepository => ForgotPassword Status: ${response.statusCode}, isSuccess: ${response.isSuccess}');
      Logger.d('AdminSignupRepository => ForgotPassword Raw Json: ${response.json}');

      if (response.json != null) {
        return AdminForgotPasswordResponseModel.fromJson(response.json!);
      } else if (response.body is Map<String, dynamic>) {
        return AdminForgotPasswordResponseModel.fromJson(
            response.body as Map<String, dynamic>);
      } else {
        return AdminForgotPasswordResponseModel(
          status: response.isSuccess,
          message: response.message.isNotEmpty
              ? response.message
              : (response.isSuccess
                  ? 'A verification code has been sent to your email.'
                  : 'Failed to process forgot password request.'),
        );
      }
    } catch (e, stackTrace) {
      Logger.e('AdminSignupRepository => ForgotPassword Exception: $e');
      Logger.e('AdminSignupRepository => StackTrace: $stackTrace');
      return AdminForgotPasswordResponseModel(
        status: false,
        message: 'Something went wrong: ${e.toString()}',
      );
    }
  }

  @override
  Future<AdminResetPasswordResponseModel> adminResetPassword(
      AdminResetPasswordRequestModel request) async {
    try {
      Logger.d('AdminSignupRepository => Calling reset-password endpoint: ${AppConstants.adminResetPasswordUrl}');
      Logger.d('AdminSignupRepository => Payload: ${request.toJson()}');

      final response = await _apiClient.post(
        AppConstants.adminResetPasswordUrl,
        data: request.toJson(),
        handleError: false,
        showToaster: false,
      );

      Logger.d('AdminSignupRepository => ResetPassword Status: ${response.statusCode}, isSuccess: ${response.isSuccess}');
      Logger.d('AdminSignupRepository => ResetPassword Raw Json: ${response.json}');

      if (response.json != null) {
        return AdminResetPasswordResponseModel.fromJson(response.json!);
      } else if (response.body is Map<String, dynamic>) {
        return AdminResetPasswordResponseModel.fromJson(
            response.body as Map<String, dynamic>);
      } else {
        return AdminResetPasswordResponseModel(
          status: response.isSuccess,
          message: response.message.isNotEmpty
              ? response.message
              : (response.isSuccess
                  ? 'Password updated successfully. Please login with your new password.'
                  : 'Failed to reset password.'),
        );
      }
    } catch (e, stackTrace) {
      Logger.e('AdminSignupRepository => ResetPassword Exception: $e');
      Logger.e('AdminSignupRepository => StackTrace: $stackTrace');
      return AdminResetPasswordResponseModel(
        status: false,
        message: 'Something went wrong: ${e.toString()}',
      );
    }
  }
}



