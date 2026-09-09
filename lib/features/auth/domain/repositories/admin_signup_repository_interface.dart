import '../models/admin_signup_request_model.dart';
import '../models/admin_signup_response_model.dart';

abstract class AdminSignupRepositoryInterface {
  Future<AdminSignupResponseModel> adminSignup(AdminSignupRequestModel request);
  Future<AdminSignupResponseModel> adminLogin(AdminLoginRequestModel request);
  Future<AdminForgotPasswordResponseModel> adminForgotPassword(
      AdminForgotPasswordRequestModel request);
  Future<AdminResetPasswordResponseModel> adminResetPassword(
      AdminResetPasswordRequestModel request);
}


