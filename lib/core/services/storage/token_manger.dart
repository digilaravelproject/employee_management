import '../storage/shared_prefs.dart';
import '../../constants/app_constants.dart';

class TokenManager {
  static Future<String> getToken() async {
    return SharedPrefs.getString(AppConstants.token) ?? '';
  }

  static Future<void> saveToken(String token) async {
    await SharedPrefs.setString(AppConstants.token, token);
  }

  static Future<void> clearToken() async {
    await SharedPrefs.remove(AppConstants.token);
  }
}
