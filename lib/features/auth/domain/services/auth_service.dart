import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/storage/shared_prefs.dart';
import '../../../../core/services/network/response_model.dart';
import '../../../../core/services/storage/token_manger.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';
import 'auth_service_interface.dart';

class AuthService implements AuthServiceInterface {
  final AuthRepository _authRepository;

  AuthService(this._authRepository);

  @override
  Future<ResponseModel> sendOtp(String email) async {
    return await _authRepository.sendOtp(email);
  }

  @override
  Future<ResponseModel> resendOtp(String email) async {
    return await _authRepository.resendOtp(email);
  }

  @override
  Future<ResponseModel> verifyLoginOtp(String email, String otp) async {
    final response = await _authRepository.verifyLoginOtp(email, otp);

    // Auto-save token and user if success
    if (response.isSuccess && response.body != null) {
      try {
        final body = response.body as Map<String, dynamic>;

        // Save token
        final token = body['token'];
        if (token != null && token.toString().isNotEmpty) {
          await saveUserToken(token.toString());
        }

        // Save user
        final userData = body['user'];
        if (userData != null) {
          final user = UserModel.fromJson(userData);
          await saveUserInfo(user);
          await SharedPrefs.setBool(AppConstants.isLoggedIn, true);
        }
      } catch (e) {
        print('Error saving user data: $e');
      }
    }

    return response;
  }

  @override
  Future<ResponseModel> registerSendOtp({
    required String vendorName,
    required String ownerName,
    required String phone,
    required String email,
  }) async {
    return await _authRepository.registerSendOtp(
      vendorName: vendorName,
      ownerName: ownerName,
      phone: phone,
      email: email,
    );
  }

  @override
  Future<ResponseModel> signup(String name, String mobile) async {
    return await _authRepository.signup(name, mobile);
  }

  @override
  Future<ResponseModel> login(String mobile) async {
    return await _authRepository.login(mobile);
  }

  @override
  Future<ResponseModel> verifyOtp(String mobile, String otp) async {
    final response = await _authRepository.verifyOtp(mobile, otp);

    // Auto-save token and user if success
    if (response.isSuccess && response.body != null) {
      try {
        final body = response.body as Map<String, dynamic>;

        // Save token
        final token = body['token'] ?? body['access_token'];
        if (token != null && token.toString().isNotEmpty) {
          await saveUserToken(token.toString());
        }

        // Save user
        final userData = body['data'] ?? body['user'] ?? body;
        final user = UserModel.fromJson(userData);
        await saveUserInfo(user);
        await SharedPrefs.setBool(AppConstants.isLoggedIn, true);
      } catch (e) {
        print('Error saving user data: $e');
      }
    }

    return response;
  }

  @override
  Future<void> saveUserInfo(UserModel user) async {
    await SharedPrefs.setString(AppConstants.userData, user.toJsonString());
  }

  @override
  Future<void> saveUserToken(String userToken) async {
    await TokenManager.saveToken(userToken);
  }

  @override
  Future<void> clearUserInfo() async {
    await SharedPrefs.remove(AppConstants.userData);
    await TokenManager.clearToken();
    await SharedPrefs.setBool(AppConstants.isLoggedIn, false);
  }

  @override
  Future<ResponseModel> logout() async {
    return await _authRepository.logout();
  }

  @override
  Future<bool> isLoggedIn() async {
    return SharedPrefs.getBool(AppConstants.isLoggedIn) ?? false;
  }

  @override
  Future<UserModel?> getUserInfo() async {
    final userJsonString = SharedPrefs.getString(AppConstants.userData);
    if (userJsonString == null || userJsonString.isEmpty) {
      return null;
    }
    return UserModel.fromJsonString(userJsonString);
  }
}