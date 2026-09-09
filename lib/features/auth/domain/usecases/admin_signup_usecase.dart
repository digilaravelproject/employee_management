import '../models/admin_signup_request_model.dart';
import '../models/admin_signup_response_model.dart';
import '../repositories/admin_signup_repository_interface.dart';

class AdminSignupUseCase {
  final AdminSignupRepositoryInterface _repository;

  AdminSignupUseCase(this._repository);

  Future<AdminSignupResponseModel> execute(AdminSignupRequestModel request) async {
    return await _repository.adminSignup(request);
  }
}

class AdminLoginUseCase {
  final AdminSignupRepositoryInterface _repository;

  AdminLoginUseCase(this._repository);

  Future<AdminSignupResponseModel> execute(AdminLoginRequestModel request) async {
    return await _repository.adminLogin(request);
  }
}

class AdminForgotPasswordUseCase {
  final AdminSignupRepositoryInterface _repository;

  AdminForgotPasswordUseCase(this._repository);

  Future<AdminForgotPasswordResponseModel> execute(
      AdminForgotPasswordRequestModel request) async {
    return await _repository.adminForgotPassword(request);
  }
}

class AdminResetPasswordUseCase {
  final AdminSignupRepositoryInterface _repository;

  AdminResetPasswordUseCase(this._repository);

  Future<AdminResetPasswordResponseModel> execute(
      AdminResetPasswordRequestModel request) async {
    return await _repository.adminResetPassword(request);
  }
}



