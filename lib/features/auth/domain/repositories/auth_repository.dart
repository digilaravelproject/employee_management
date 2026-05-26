import 'dart:async';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/network/api_client.dart';
import '../../../../core/services/network/response_model.dart';
import 'auth_repository_interface.dart';

class AuthRepository implements AuthRepositoryInterface {
  final ApiClient _apiClient;

  AuthRepository(this._apiClient);

  @override
  Future<ResponseModel> sendOtp(String email) async {
    try {
      final response = await _apiClient.post(
        AppConstants.sendOtpUrl,
        data: {
          'email': email,
        },
        handleError: false,
        showToaster: false,
      );

      return response;
    } catch (e) {
      print('❌ Error in sendOtp repository: $e');
      return ResponseModel(
        isSuccess: false,
        message: 'Failed to send OTP',
        statusCode: 500,
      );
    }
  }

  @override
  Future<ResponseModel> resendOtp(String email) async {
    try {
      final response = await _apiClient.post(
        AppConstants.resendOtpUrl,
        data: {
          'email': email,
        },
        handleError: false,
        showToaster: false,
      );

      return response;
    } catch (e) {
      print('❌ Error in resendOtp repository: $e');
      return ResponseModel(
        isSuccess: false,
        message: 'Failed to resend OTP',
        statusCode: 500,
      );
    }
  }

  @override
  Future<ResponseModel> verifyLoginOtp(String email, String otp) async {
    try {
      final response = await _apiClient.post(
        AppConstants.verifyLoginOtpUrl,
        data: {
          'email': email,
          'otp': otp,
        },
        handleError: false,
        showToaster: false,
      );

      return response;
    } catch (e) {
      print('❌ Error in verifyLoginOtp repository: $e');
      return ResponseModel(
        isSuccess: false,
        message: 'Failed to verify OTP',
        statusCode: 500,
      );
    }
  }

  @override
  Future<ResponseModel> registerSendOtp({
    required String vendorName,
    required String ownerName,
    required String phone,
    required String email,
  }) async {
    try {
      final response = await _apiClient.post(
        AppConstants.registerSendOtpUrl,
        data: {
          'vendor_name': vendorName,
          'owner_name': ownerName,
          'phone': phone,
          'email': email,
        },
        handleError: false,
        showToaster: false,
      );

      return response;
    } catch (e) {
      print('❌ Error in registerSendOtp repository: $e');
      return ResponseModel(
        isSuccess: false,
        message: 'Failed to register',
        statusCode: 500,
      );
    }
  }

  @override
  Future<ResponseModel> signup(String name, String mobile) async {
    final response = await _apiClient.post(
      AppConstants.userSignupUrl,
      data: {
        'name': name,
        'mobile': mobile,
      },
    );

    return response;
  }

  @override
  Future<ResponseModel> login(String mobile) async {
    final response = await _apiClient.post(
      AppConstants.userLoginUrl,
      data: {
        'mobile': mobile,
      },
    );

    return response;
  }

  @override
  Future<ResponseModel> verifyOtp(String mobile, String otp) async {
    final response = await _apiClient.post(
      AppConstants.otpVerifyUrl,
      data: {
        'mobile': mobile,
        'otp': otp,
      },
    );

    return response;
  }

  @override
  Future<ResponseModel> logout() async {
    try {
      final response = await _apiClient.post(
        AppConstants.logoutUrl,
        handleError: false,
        showToaster: false,
      );

      return response;
    } catch (e) {
      print('❌ Error in logout repository: $e');
      return ResponseModel(
        isSuccess: false,
        message: 'Failed to logout',
        statusCode: 500,
      );
    }
  }
}
