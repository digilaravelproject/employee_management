import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/storage/shared_prefs.dart';
import '../../../../core/services/storage/token_manger.dart';
import '../../../../core/utils/custom_snackbar.dart';
import '../../../../core/utils/logger.dart';
import '../../../../routes/route_helper.dart';
import '../domain/models/admin_signup_request_model.dart';
import '../domain/models/admin_signup_response_model.dart';
import '../domain/models/user_model.dart';
import '../domain/usecases/admin_signup_usecase.dart';

class AdminSignupController extends GetxController {
  final AdminSignupUseCase _adminSignupUseCase;
  final AdminLoginUseCase? _adminLoginUseCase;
  final AdminForgotPasswordUseCase? _adminForgotPasswordUseCase;
  final AdminResetPasswordUseCase? _adminResetPasswordUseCase;
  final AdminUpdatePasswordUseCase? _adminUpdatePasswordUseCase;

  AdminSignupController({
    required AdminSignupUseCase adminSignupUseCase,
    AdminLoginUseCase? adminLoginUseCase,
    AdminForgotPasswordUseCase? adminForgotPasswordUseCase,
    AdminResetPasswordUseCase? adminResetPasswordUseCase,
    AdminUpdatePasswordUseCase? adminUpdatePasswordUseCase,
  })  : _adminSignupUseCase = adminSignupUseCase,
        _adminLoginUseCase = adminLoginUseCase,
        _adminForgotPasswordUseCase = adminForgotPasswordUseCase,
        _adminResetPasswordUseCase = adminResetPasswordUseCase,
        _adminUpdatePasswordUseCase = adminUpdatePasswordUseCase;

  // ── Signup Form Key & Controllers ─────────────────────
  final signupFormKey = GlobalKey<FormState>();
  final companyNameController = TextEditingController();
  final ownerNameController = TextEditingController();
  final mobileNumberController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // ── Login Form Key & Controllers ──────────────────────
  final loginFormKey = GlobalKey<FormState>();
  final loginEmailController = TextEditingController();
  final loginPasswordController = TextEditingController();

  // ── Forgot Password Form Key & Controllers ────────────
  final forgotPasswordFormKey = GlobalKey<FormState>();
  final forgotEmailController = TextEditingController();

  // ── Reset Password Form Key & Controllers ─────────────
  final resetPasswordFormKey = GlobalKey<FormState>();
  final resetEmailController = TextEditingController();
  final resetOtpController = TextEditingController();
  final resetNewPasswordController = TextEditingController();
  final resetConfirmPasswordController = TextEditingController();

  // ── Update Password Form Key & Controllers ────────────
  final updatePasswordFormKey = GlobalKey<FormState>();
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmNewPasswordController = TextEditingController();

  // ── Observables ──────────────────────────────────────
  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;
  final agreedToTerms = false.obs;

  final isLoginLoading = false.obs;
  final isLoginPasswordVisible = false.obs;

  final isForgotPasswordLoading = false.obs;
  final forgotPasswordOtpDebug = ''.obs;

  final isResetPasswordLoading = false.obs;
  final isResetNewPasswordVisible = false.obs;
  final isResetConfirmPasswordVisible = false.obs;

  final isUpdatePasswordLoading = false.obs;
  final isCurrentPasswordVisible = false.obs;
  final isNewPasswordVisible = false.obs;
  final isConfirmNewPasswordVisible = false.obs;

  @override
  void onClose() {
    companyNameController.dispose();
    ownerNameController.dispose();
    mobileNumberController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    loginEmailController.dispose();
    loginPasswordController.dispose();
    forgotEmailController.dispose();
    resetEmailController.dispose();
    resetOtpController.dispose();
    resetNewPasswordController.dispose();
    resetConfirmPasswordController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmNewPasswordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  void toggleTermsAgreement(bool? value) {
    agreedToTerms.value = value ?? !agreedToTerms.value;
  }

  // ── Validators ───────────────────────────────────────
  String? validateCompanyName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your company name';
    }
    if (value.trim().length < 2) {
      return 'Company name must be at least 2 characters';
    }
    return null;
  }

  String? validateOwnerName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter owner name';
    }
    if (value.trim().length < 2) {
      return 'Owner name must be at least 2 characters';
    }
    return null;
  }

  String? validateMobileNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter mobile number';
    }
    final cleanNumber = value.trim();
    if (cleanNumber.length != 10 || !RegExp(r'^[0-9]+$').hasMatch(cleanNumber)) {
      return 'Enter a valid 10-digit mobile number';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email address';
    }
    final email = value.trim();
    if (!GetUtils.isEmail(email)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  // ── Main API Call ────────────────────────────────────
  Future<void> signup() async {
    // 1. Form validation
    if (!signupFormKey.currentState!.validate()) {
      return;
    }

    // 2. Terms agreement validation
    if (!agreedToTerms.value) {
      CustomSnackbar.showError('Please accept the Terms of Service and Privacy Policy to continue');
      return;
    }

    try {
      isLoading.value = true;

      // 3. Build request model
      final request = AdminSignupRequestModel(
        companyName: companyNameController.text.trim(),
        ownerName: ownerNameController.text.trim(),
        mobileNumber: mobileNumberController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
        passwordConfirmation: confirmPasswordController.text,
      );

      Logger.d('AdminSignupController => Submitting request: ${request.toJson()}');

      // 4. Call use case
      final AdminSignupResponseModel response =
          await _adminSignupUseCase.execute(request);

      Logger.d('AdminSignupController => Received response: status=${response.status}, msg=${response.message}');

      // 5. Handle response
      if (response.status) {
        // Success
        final successMsg = response.message.isNotEmpty
            ? response.message
            : 'Account created successfully.';

        // Save token
        if (response.accessToken != null && response.accessToken!.isNotEmpty) {
          await TokenManager.saveToken(response.accessToken!);
        }

        // Save user info
        if (response.data != null) {
          final userData = response.data!;
          final user = UserModel(
            id: userData.id ?? 0,
            name: userData.name ?? userData.ownerName ?? '',
            email: userData.email ?? request.email,
            phone: userData.mobileNumber ?? request.mobileNumber,
            role: userData.role ?? 'admin',
            companyName: userData.companyName ?? request.companyName,
            ownerName: userData.ownerName ?? request.ownerName,
          );
          await SharedPrefs.setString(AppConstants.userData, jsonEncode(user.toJson()));
          await SharedPrefs.setBool(AppConstants.isLoggedIn, true);
        }

        CustomSnackbar.showSuccess(successMsg);

        // Navigate to dashboard
        await Future.delayed(const Duration(milliseconds: 600));
        Get.offAllNamed(RouteHelper.getDashboardRoute());
      } else {
        // Validation / API Error
        // Extract the first error message from errors map array, as required by user:
        // { "errors": { "email": [ "This email address is already registered. Please login instead." ] } }
        final errorMessage = response.getFirstErrorMessage();
        Logger.w('AdminSignupController => Error: $errorMessage');
        CustomSnackbar.showError(errorMessage);
      }
    } catch (e) {
      Logger.e('AdminSignupController => Unexpected Exception: $e');
      CustomSnackbar.showError('An unexpected error occurred. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  // ── Login Methods & Validators ───────────────────────
  void toggleLoginPasswordVisibility() {
    isLoginPasswordVisible.value = !isLoginPasswordVisible.value;
  }

  String? validateLoginEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email address';
    }
    final email = value.trim();
    if (!GetUtils.isEmail(email)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? validateLoginPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  Future<void> login() async {
    // 1. Form validation
    if (!loginFormKey.currentState!.validate()) {
      return;
    }

    if (_adminLoginUseCase == null) {
      CustomSnackbar.showError('Login service is not configured');
      return;
    }

    try {
      isLoginLoading.value = true;

      // 2. Build request model
      final request = AdminLoginRequestModel(
        email: loginEmailController.text.trim(),
        password: loginPasswordController.text,
      );

      Logger.d('AdminSignupController => Submitting login request: ${request.toJson()}');

      // 3. Call usecase
      final AdminSignupResponseModel response =
          await _adminLoginUseCase.execute(request);

      Logger.d('AdminSignupController => Received login response: status=${response.status}, msg=${response.message}');

      // 4. Handle response
      if (response.status) {
        final successMsg = response.message.isNotEmpty
            ? response.message
            : 'Login successful.';

        // Save token
        if (response.accessToken != null && response.accessToken!.isNotEmpty) {
          await TokenManager.saveToken(response.accessToken!);
        }

        // Save user info
        if (response.data != null) {
          final userData = response.data!;
          final user = UserModel(
            id: userData.id ?? 0,
            name: userData.name ?? userData.ownerName ?? '',
            email: userData.email ?? request.email,
            phone: userData.mobileNumber ?? userData.phone,
            role: userData.role ?? 'admin',
            companyName: userData.companyName,
            ownerName: userData.ownerName,
          );
          await SharedPrefs.setString(
              AppConstants.userData, jsonEncode(user.toJson()));
          await SharedPrefs.setBool(AppConstants.isLoggedIn, true);
        }

        CustomSnackbar.showSuccess(successMsg);

        // Navigate to dashboard
        await Future.delayed(const Duration(milliseconds: 600));
        Get.offAllNamed(RouteHelper.getDashboardRoute());
      } else {
        // Validation / Auth Error
        final errorMessage = response.getFirstErrorMessage();
        Logger.w('AdminSignupController => Login Error: $errorMessage');
        CustomSnackbar.showError(errorMessage);
      }
    } catch (e) {
      Logger.e('AdminSignupController => Unexpected Login Exception: $e');
      CustomSnackbar.showError('An unexpected error occurred. Please try again.');
    } finally {
      isLoginLoading.value = false;
    }
  }

  // ── Forgot Password Methods & Validators ─────────────
  String? validateForgotEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email address';
    }
    final email = value.trim();
    if (!GetUtils.isEmail(email)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  Future<void> forgotPassword() async {
    // 1. Form validation
    if (!forgotPasswordFormKey.currentState!.validate()) {
      return;
    }

    if (_adminForgotPasswordUseCase == null) {
      CustomSnackbar.showError('Forgot password service is not configured');
      return;
    }

    try {
      isForgotPasswordLoading.value = true;

      // 2. Build request model
      final request = AdminForgotPasswordRequestModel(
        email: forgotEmailController.text.trim(),
      );

      Logger.d('AdminSignupController => Submitting forgot-password request: ${request.toJson()}');

      // 3. Call usecase
      final AdminForgotPasswordResponseModel response =
          await _adminForgotPasswordUseCase.execute(request);

      Logger.d('AdminSignupController => Received forgot-password response: status=${response.status}, msg=${response.message}, otp=${response.otpDebug}');

      // 4. Handle response
      if (response.status) {
        final successMsg = response.message.isNotEmpty
            ? response.message
            : 'A 6-digit verification code has been sent to your email address.';

        if (response.otpDebug != null && response.otpDebug!.isNotEmpty) {
          forgotPasswordOtpDebug.value = response.otpDebug!;
        }

        CustomSnackbar.showSuccess(successMsg);

        // Prepopulate reset fields
        resetEmailController.text = request.email;
        if (response.otpDebug != null && response.otpDebug!.isNotEmpty) {
          resetOtpController.text = response.otpDebug!;
        }

        // Navigate to Reset Password route
        await Future.delayed(const Duration(milliseconds: 600));
        Get.toNamed(
          RouteHelper.getResetPasswordRoute(),
          arguments: {
            'email': request.email,
            'otp': response.otpDebug,
          },
        );
      } else {
        // Validation / Error
        final errorMessage = response.getFirstErrorMessage();
        Logger.w('AdminSignupController => ForgotPassword Error: $errorMessage');
        CustomSnackbar.showError(errorMessage);
      }
    } catch (e) {
      Logger.e('AdminSignupController => Unexpected ForgotPassword Exception: $e');
      CustomSnackbar.showError('An unexpected error occurred. Please try again.');
    } finally {
      isForgotPasswordLoading.value = false;
    }
  }

  // ── Reset Password Methods & Validators ──────────────
  void toggleResetNewPasswordVisibility() {
    isResetNewPasswordVisible.value = !isResetNewPasswordVisible.value;
  }

  void toggleResetConfirmPasswordVisibility() {
    isResetConfirmPasswordVisible.value = !isResetConfirmPasswordVisible.value;
  }

  String? validateResetEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email address';
    }
    final email = value.trim();
    if (!GetUtils.isEmail(email)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? validateResetOtp(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter verification code';
    }
    final otp = value.trim();
    if (otp.length != 6) {
      return 'Please enter a valid 6-digit verification code';
    }
    return null;
  }

  String? validateResetNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter new password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? validateResetConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm password';
    }
    if (value != resetNewPasswordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> resetPassword() async {
    // 1. Form validation
    if (!resetPasswordFormKey.currentState!.validate()) {
      return;
    }

    if (_adminResetPasswordUseCase == null) {
      CustomSnackbar.showError('Reset password service is not configured');
      return;
    }

    try {
      isResetPasswordLoading.value = true;

      // 2. Build request model
      final request = AdminResetPasswordRequestModel(
        email: resetEmailController.text.trim(),
        otp: resetOtpController.text.trim(),
        password: resetNewPasswordController.text,
        passwordConfirmation: resetConfirmPasswordController.text,
      );

      Logger.d('AdminSignupController => Submitting reset-password request: ${request.toJson()}');

      // 3. Call usecase
      final AdminResetPasswordResponseModel response =
          await _adminResetPasswordUseCase.execute(request);

      Logger.d('AdminSignupController => Received reset-password response: status=${response.status}, msg=${response.message}');

      // 4. Handle response
      if (response.status) {
        final successMsg = response.message.isNotEmpty
            ? response.message
            : 'Password updated successfully. Please login with your new password.';

        // Green snackbar on success
        CustomSnackbar.showSuccess(successMsg);

        // Clear reset controllers
        resetEmailController.clear();
        resetOtpController.clear();
        resetNewPasswordController.clear();
        resetConfirmPasswordController.clear();

        // Navigate back to login screen as requested
        await Future.delayed(const Duration(milliseconds: 600));
        Get.offAllNamed(RouteHelper.getLoginRoute());
      } else {
        // Red snackbar on failure with specific error message
        final errorMessage = response.getFirstErrorMessage();
        Logger.w('AdminSignupController => ResetPassword Error: $errorMessage');
        CustomSnackbar.showError(errorMessage);
      }
    } catch (e) {
      Logger.e('AdminSignupController => Unexpected ResetPassword Exception: $e');
      CustomSnackbar.showError('An unexpected error occurred. Please try again.');
    } finally {
      isResetPasswordLoading.value = false;
    }
  }

  // ── Update Password Methods & Validators ─────────────
  void toggleCurrentPasswordVisibility() {
    isCurrentPasswordVisible.value = !isCurrentPasswordVisible.value;
  }

  void toggleNewPasswordVisibility() {
    isNewPasswordVisible.value = !isNewPasswordVisible.value;
  }

  void toggleConfirmNewPasswordVisibility() {
    isConfirmNewPasswordVisible.value = !isConfirmNewPasswordVisible.value;
  }

  String? validateCurrentPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your current password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your new password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? validateConfirmNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your new password';
    }
    if (value != newPasswordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> updatePassword() async {
    // 1. Form validation (checks only min 6 chars and match)
    if (!updatePasswordFormKey.currentState!.validate()) {
      return;
    }

    if (_adminUpdatePasswordUseCase == null) {
      CustomSnackbar.showError('Update password service is not configured');
      return;
    }

    try {
      isUpdatePasswordLoading.value = true;

      // 2. Build request model
      final request = AdminUpdatePasswordRequestModel(
        currentPassword: currentPasswordController.text,
        newPassword: newPasswordController.text,
        confirmPassword: confirmNewPasswordController.text,
      );

      Logger.d('AdminSignupController => Submitting update-password request: ${request.toJson()}');

      // 3. Call usecase
      final AdminUpdatePasswordResponseModel response =
          await _adminUpdatePasswordUseCase.execute(request);

      Logger.d('AdminSignupController => Received update-password response: status=${response.status}, msg=${response.message}');

      // 4. Handle response
      if (response.status) {
        final successMsg = response.message.isNotEmpty
            ? response.message
            : 'Password updated successfully.';

        // Green snackbar on success
        CustomSnackbar.showSuccess(successMsg);

        // Clear input fields
        currentPasswordController.clear();
        newPasswordController.clear();
        confirmNewPasswordController.clear();

        await Future.delayed(const Duration(milliseconds: 600));
        Get.back();
      } else {
        // Red snackbar on failure
        final errorMessage = response.getFirstErrorMessage();
        Logger.w('AdminSignupController => UpdatePassword Error: $errorMessage');
        CustomSnackbar.showError(errorMessage);
      }
    } catch (e) {
      Logger.e('AdminSignupController => Unexpected UpdatePassword Exception: $e');
      CustomSnackbar.showError('An unexpected error occurred. Please try again.');
    } finally {
      isUpdatePasswordLoading.value = false;
    }
  }
}



