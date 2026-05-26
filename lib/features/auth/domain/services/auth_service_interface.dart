import '../../../../core/services/network/response_model.dart';
import '../models/user_model.dart';

abstract class AuthServiceInterface {
  Future<ResponseModel> sendOtp(String email);
  Future<ResponseModel> resendOtp(String email);
  Future<ResponseModel> verifyLoginOtp(String email, String otp);
  Future<ResponseModel> registerSendOtp({
    required String vendorName,
    required String ownerName,
    required String phone,
    required String email,
  });
  Future<ResponseModel> signup(String name, String mobile);
  Future<ResponseModel> login(String mobile);
  Future<ResponseModel> verifyOtp(String mobile, String otp);
  Future<ResponseModel> logout();
  Future<void> saveUserToken(String userToken);
  Future<void> saveUserInfo(UserModel user);
  Future<void> clearUserInfo();
  Future<bool> isLoggedIn();
  Future<UserModel?> getUserInfo();
}
