import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/network/response_model.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../domain/models/user_model.dart';
import '../../../routes/route_helper.dart';
import '../domain/services/auth_service.dart';

class AuthController extends GetxController {
  final SendOtpUseCase _sendOtpUseCase;
  final ResendOtpUseCase _resendOtpUseCase;
  final VerifyLoginOtpUseCase _verifyLoginOtpUseCase;
  final RegisterSendOtpUseCase _registerSendOtpUseCase;
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final VerifyOtpUseCase _verifyOtpUseCase;
  final LogoutUseCase _logoutUseCase;
  final CheckLoginStatusUseCase _checkLoginStatusUseCase;
  final GetUserInfoUseCase _getUserInfoUseCase;
  var selectedCountryCode = '+91'.obs;


  AuthController({
    required SendOtpUseCase sendOtpUseCase,
    required ResendOtpUseCase resendOtpUseCase,
    required VerifyLoginOtpUseCase verifyLoginOtpUseCase,
    required RegisterSendOtpUseCase registerSendOtpUseCase,
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required VerifyOtpUseCase verifyOtpUseCase,
    required LogoutUseCase logoutUseCase,
    required CheckLoginStatusUseCase checkLoginStatusUseCase,
    required GetUserInfoUseCase getUserInfoUseCase,
  })  : _sendOtpUseCase = sendOtpUseCase,
        _resendOtpUseCase = resendOtpUseCase,
        _verifyLoginOtpUseCase = verifyLoginOtpUseCase,
        _registerSendOtpUseCase = registerSendOtpUseCase,
        _loginUseCase = loginUseCase,
        _registerUseCase = registerUseCase,
        _verifyOtpUseCase = verifyOtpUseCase,
        _logoutUseCase = logoutUseCase,
        _checkLoginStatusUseCase = checkLoginStatusUseCase,
        _getUserInfoUseCase = getUserInfoUseCase;

  final isLoading = false.obs;
  final currentMobile = ''.obs;
  Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  bool isForgotPasswordFlow = false;

  final loginFormKey = GlobalKey<FormState>();
  final signupFormKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final companyNameController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final otpController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }

  @override
  void onClose() {
    // When using fenix: true, GetX will recreate the controller
    // Don't dispose controllers here as they might still be in use during navigation
    // Let Dart's garbage collector handle them when no longer referenced
    super.onClose();
  }
  
  // Manual cleanup method if needed
  void disposeControllers() {
    emailController.dispose();
    passwordController.dispose();
    companyNameController.dispose();
    confirmPasswordController.dispose();
    nameController.dispose();
    phoneController.dispose();
    otpController.dispose();
  }

  Future<void> checkLoginStatus() async {
    final isLoggedIn = await _checkLoginStatusUseCase.execute();
    if (isLoggedIn) {
      final user = await _getUserInfoUseCase.execute();
      if (user != null) currentUser.value = user;
    }
  }

  Future<void> signup() async {
    if (!signupFormKey.currentState!.validate()) return;

    try {
      isLoading.value = true;
      final email = emailController.text.trim();
      currentMobile.value = email; // Store email for OTP verification
      // Note: Updating this to match transport management needs
      // For now, using what's available in the use case or updating the logic
      final user = await _registerUseCase.execute(
        companyNameController.text.trim(), // Using company name as name for now
        email, // Passing email to mobile spot or updating service
      );

      if (user != null) {
        currentUser.value = user;
        // currentMobile.value = emailController.text.trim(); // Optional: store email/mobile
        CustomSnackbar.showSuccess('Registration successful. Verify OTP.');
        Get.toNamed(RouteHelper.getOtpRoute());
      } else {
        CustomSnackbar.showError('Signup failed. Please try again.');
      }
    } catch (e) {
      CustomSnackbar.showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register() async {
    if (!signupFormKey.currentState!.validate()) return;
    try {
      isLoading.value = true;
      
      // Get form data
      final vendorName = companyNameController.text.trim();
      final ownerName = nameController.text.trim();
      final phone = phoneController.text.trim();
      final email = emailController.text.trim();
      
      // Validate fields
      if (vendorName.isEmpty) {
        CustomSnackbar.showError('Please enter vendor name');
        isLoading.value = false;
        return;
      }
      
      if (ownerName.isEmpty) {
        CustomSnackbar.showError('Please enter owner name');
        isLoading.value = false;
        return;
      }
      
      if (phone.isEmpty || phone.length != 10) {
        CustomSnackbar.showError('Please enter a valid 10-digit mobile number');
        isLoading.value = false;
        return;
      }
      
      if (email.isEmpty || !GetUtils.isEmail(email)) {
        CustomSnackbar.showError('Please enter a valid email address');
        isLoading.value = false;
        return;
      }
      
      // Store email for OTP verification
      currentMobile.value = email;
      
      // Call register API
      final response = await _registerSendOtpUseCase.execute(
        vendorName: vendorName,
        ownerName: ownerName,
        phone: phone,
        email: email,
      );

      print('📦 Register Response: $response');
      print('✅ isSuccess: ${response.isSuccess}');
      print('📨 message: ${response.message}');

      if (response.isSuccess) {
        CustomSnackbar.showSuccess(
          response.message ?? 'Registration successful! OTP has been sent to your email.'
        );
        // Navigate to OTP screen
        await Future.delayed(const Duration(milliseconds: 500));
        Get.toNamed(RouteHelper.getOtpRoute());
      } else {
        CustomSnackbar.showError(
          response.message ?? 'Registration failed. Please try again.'
        );
      }
    } catch (e) {
      print('❌ Error in register: $e');
      //CustomSnackbar.showError('Something went wrong. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> login() async {
    if (!loginFormKey.currentState!.validate()) return;
    try {
      isLoading.value = true;
      final email = emailController.text.trim();
      
      // Validate email
      if (email.isEmpty) {
        CustomSnackbar.showError('Please enter your email');
        isLoading.value = false;
        return;
      }
      
      if (!GetUtils.isEmail(email)) {
        CustomSnackbar.showError('Please enter a valid email address');
        isLoading.value = false;
        return;
      }
      
      currentMobile.value = email; // Store email for OTP verification
      
      // Call send-otp API
      final response = await _sendOtpUseCase.execute(email);

      print('📦 Login Response: $response');
      print('✅ isSuccess: ${response.isSuccess}');
      print('📨 message: ${response.message}');

      if (response.isSuccess) {
        CustomSnackbar.showSuccess(response.message);
        // Navigate to OTP screen
        Get.toNamed(RouteHelper.getOtpRoute());
      } else {
        // If user not found, navigate to signup
        if (response.statusCode == 404 || 
            response.message?.toLowerCase().contains('not found') == true ||
            response.message?.toLowerCase().contains('not registered') == true) {
          CustomSnackbar.showError('User not found. Please sign up first.');
          await Future.delayed(const Duration(milliseconds: 500));
          Get.toNamed(RouteHelper.getSignupRoute());
        } else {
          CustomSnackbar.showError(response.message ?? 'Failed to send OTP. Please try again.');
        }
      }
    } catch (e) {
      print('❌ Error in login: $e');
      CustomSnackbar.showError('Something went wrong. Please try again.');
      // On error, navigate to signup as fallback
      await Future.delayed(const Duration(milliseconds: 500));
      Get.toNamed(RouteHelper.getSignupRoute());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendOtp() async {
    try {
      isLoading.value = true;
      final email = currentMobile.value.trim();
      
      if (email.isEmpty) {
        CustomSnackbar.showError('Email not found. Please login again.');
        isLoading.value = false;
        return;
      }
      
      // Call resend-otp API
      final response = await _resendOtpUseCase.execute(email);

      if (response.isSuccess) {
        CustomSnackbar.showSuccess(response.message ?? 'OTP has been resent to your email. Please check your inbox.');
      } else {
        CustomSnackbar.showError(response.message ?? 'Failed to resend OTP. Please try again.');
      }
    } catch (e) {
      print('❌ Error in resendOtp: $e');
      CustomSnackbar.showError('Something went wrong. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> forgotPassword() async {
    Get.toNamed(RouteHelper.getResetPasswordRoute());
    if (emailController.text.isEmpty) {
      CustomSnackbar.showError('Please enter your email');
      return;
    }

    try {
      isLoading.value = true;
      // Store email for reset password flow
      currentMobile.value = emailController.text.trim();
      isForgotPasswordFlow = true;
      CustomSnackbar.showSuccess('OTP sent to your email');
      await Future.delayed(const Duration(milliseconds: 500));
      Get.toNamed(RouteHelper.getResetPasswordRoute());
    } catch (e) {
      CustomSnackbar.showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetPassword() async {
    if (otpController.text.isEmpty) {
      CustomSnackbar.showError('Please enter verification code');
      return;
    }
    if (otpController.text.length != 6) {
      CustomSnackbar.showError('Please enter a valid 6-digit verification code');
      return;
    }
    if (passwordController.text.isEmpty) {
      CustomSnackbar.showError('Please enter new password');
      return;
    }
    if (confirmPasswordController.text.isEmpty) {
      CustomSnackbar.showError('Please confirm password');
      return;
    }
    if (passwordController.text != confirmPasswordController.text) {
      CustomSnackbar.showError('Passwords do not match');
      return;
    }
    if (passwordController.text.length < 6) {
      CustomSnackbar.showError('Password must be at least 6 characters');
      return;
    }

    try {
      isLoading.value = true;
      // Implement reset password API call here
      CustomSnackbar.showSuccess('Password reset successfully');
      await Future.delayed(const Duration(milliseconds: 500));
      // Clear controllers
      passwordController.clear();
      confirmPasswordController.clear();
      otpController.clear();
      emailController.clear();
      // Navigate back to login
      Get.offAllNamed(RouteHelper.getLoginRoute());
    } catch (e) {
      CustomSnackbar.showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyOtp() async {
    if (otpController.text.isEmpty) {
      CustomSnackbar.showError('Please enter OTP');
      return;
    }

    if (otpController.text.length != 6) {
      CustomSnackbar.showError('Please enter a valid 6-digit OTP');
      return;
    }

    try {
      isLoading.value = true;
      final email = currentMobile.value.trim();
      
      if (email.isEmpty) {
        CustomSnackbar.showError('Email not found. Please login again.');
        isLoading.value = false;
        return;
      }
      
      // Call verify-login-otp API
      final response = await _verifyLoginOtpUseCase.execute(
        email,
        otpController.text.trim(),
      );

      if (response.isSuccess && response.body != null) {
        final body = response.body as Map<String, dynamic>;
        
        // Get user data
        final userData = body['user'];
        if (userData != null) {
          currentUser.value = UserModel.fromJson(userData);
          print('✅ User saved: ${currentUser.value}');
        }
        
        otpController.clear();
        
        // Show success message
        CustomSnackbar.showSuccess(response.message ?? 'Login successful. Welcome back!');
        
        // Navigate after a short delay
        await Future.delayed(const Duration(milliseconds: 500));
        
        if (isForgotPasswordFlow) {
          isForgotPasswordFlow = false;
          Get.offNamed(RouteHelper.getResetPasswordRoute());
        } else {
          Get.offAllNamed(RouteHelper.getDashboardRoute());
        }
      } else {
        CustomSnackbar.showError(response.message ?? 'Invalid OTP. Please try again.');
      }
    } catch (e) {
      print('❌ Error in verifyOtp: $e');
      CustomSnackbar.showError('Something went wrong. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;
      
      // Call logout API
      final response = await _logoutUseCase.execute();
      
      if (response.isSuccess) {
        // Clear user data
        currentUser.value = null;
        currentMobile.value = '';
        
        // Show success message
        CustomSnackbar.showSuccess(response.message ?? 'Logged out successfully');
        
        // Wait for snackbar to show
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Navigate to login screen - this will automatically clean up controllers
        // Don't manually delete controller, let GetX handle it
        Get.offAllNamed(RouteHelper.getLoginRoute());
      } else {
        CustomSnackbar.showError(response.message ?? 'Failed to logout');
      }
    } catch (e) {
      print('❌ Error in logout: $e');
      // Even if API fails, clear local data and navigate to login
      currentUser.value = null;
      currentMobile.value = '';
      
      CustomSnackbar.showError('Logged out locally');
      await Future.delayed(const Duration(milliseconds: 500));
      
      Get.offAllNamed(RouteHelper.getLoginRoute());
    } finally {
      isLoading.value = false;
    }
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? validateCompanyName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your company name';
    }
    return null;
  }
}


class SendOtpUseCase {
  final AuthService _authService;

  SendOtpUseCase(this._authService);

  Future<ResponseModel> execute(String email) async {
    return await _authService.sendOtp(email);
  }
}


class ResendOtpUseCase {
  final AuthService _authService;

  ResendOtpUseCase(this._authService);

  Future<ResponseModel> execute(String email) async {
    return await _authService.resendOtp(email);
  }
}


class VerifyLoginOtpUseCase {
  final AuthService _authService;

  VerifyLoginOtpUseCase(this._authService);

  Future<ResponseModel> execute(String email, String otp) async {
    return await _authService.verifyLoginOtp(email, otp);
  }
}


class RegisterSendOtpUseCase {
  final AuthService _authService;

  RegisterSendOtpUseCase(this._authService);

  Future<ResponseModel> execute({
    required String vendorName,
    required String ownerName,
    required String phone,
    required String email,
  }) async {
    return await _authService.registerSendOtp(
      vendorName: vendorName,
      ownerName: ownerName,
      phone: phone,
      email: email,
    );
  }
}


class LoginUseCase {
  final AuthService _authService;

  LoginUseCase(this._authService);

  Future<UserModel?> execute(String mobile) async {
    final response = await _authService.login(mobile);
    if (response.isSuccess && response.body != null) {
      return UserModel.fromJson(response.body);
    }
    return null;
  }
}


class VerifyOtpUseCase {
  final AuthService _authService;

  VerifyOtpUseCase(this._authService);

  Future<UserModel?> execute(String mobile, String otp) async {
    final response = await _authService.verifyOtp(mobile, otp);
    if (response.isSuccess && response.body != null) {
      return UserModel.fromJson(response.body);
    }
    return null;
  }
}



class LogoutUseCase {
  final AuthService _authService;

  LogoutUseCase(this._authService);

  Future<ResponseModel> execute() async {
    // Call logout API
    final response = await _authService.logout();
    
    // Clear local data regardless of API response
    await _authService.clearUserInfo();
    
    return response;
  }
}


class CheckLoginStatusUseCase {
  final AuthService _authService;

  CheckLoginStatusUseCase(this._authService);

  Future<bool> execute() async {
    return await _authService.isLoggedIn();
  }
}



class GetUserInfoUseCase {
  final AuthService _authService;

  GetUserInfoUseCase(this._authService);

  Future<UserModel?> execute() async {
    return await _authService.getUserInfo();
  }
}

class RegisterUseCase {
  final AuthService _authService;

  RegisterUseCase(this._authService);

  Future<UserModel?> execute(String name, String mobile) async {
    final response = await _authService.signup(name, mobile);

    if (response.isSuccess && response.body != null) {
      try {
        return UserModel.fromJson(response.body);
      } catch (e) {
        print('Error parsing user data: $e');
      }
    }

    return null;
  }
}



