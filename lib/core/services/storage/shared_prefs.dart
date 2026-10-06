import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/app_constants.dart';
import '../../../features/auth/domain/models/user_model.dart';

/// A simplified wrapper for SharedPreferences
class SharedPrefs {
  static SharedPreferences? _prefs;

  /// Initialize SharedPreferences instance
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Set a String value
  static Future<bool> setString(String key, String value) async {
    return await _prefs?.setString(key, value) ?? false;
  }

  /// Get a String value
  static String? getString(String key) {
    return _prefs?.getString(key);
  }

  /// Set an int value
  static Future<bool> setInt(String key, int value) async {
    return await _prefs?.setInt(key, value) ?? false;
  }

  /// Get an int value
  static int? getInt(String key) {
    return _prefs?.getInt(key);
  }

  /// Set a bool value
  static Future<bool> setBool(String key, bool value) async {
    return await _prefs?.setBool(key, value) ?? false;
  }

  /// Get a bool value
  static bool? getBool(String key) {
    return _prefs?.getBool(key);
  }

  /// Set a double value
  static Future<bool> setDouble(String key, double value) async {
    return await _prefs?.setDouble(key, value) ?? false;
  }

  /// Get a double value
  static double? getDouble(String key) {
    return _prefs?.getDouble(key);
  }

  /// Set a List<String> value
  static Future<bool> setStringList(String key, List<String> value) async {
    return await _prefs?.setStringList(key, value) ?? false;
  }

  /// Get a List<String> value
  static List<String>? getStringList(String key) {
    return _prefs?.getStringList(key);
  }

  /// Check if key exists
  static bool containsKey(String key) {
    return _prefs?.containsKey(key) ?? false;
  }

  /// Remove a key-value pair
  static Future<bool> remove(String key) async {
    return await _prefs?.remove(key) ?? false;
  }

  /// Clear all preferences
  static Future<bool> clear() async {
    return await _prefs?.clear() ?? false;
  }

  // ── Authentication & User Storage Helpers ──

  /// Save complete user data into SharedPreferences
  /// Accepts [UserModel], [Map<String, dynamic>], or a JSON string.
  static Future<bool> saveUserData(dynamic data) async {
    if (data == null) return false;
    try {
      String jsonString;
      int? extractedRoleId;

      if (data is String) {
        jsonString = data;
        try {
          final decoded = jsonDecode(data);
          if (decoded is Map<String, dynamic>) {
            extractedRoleId = UserModel.fromJson(decoded).primaryRoleId;
          }
        } catch (_) {}
      } else if (data is UserModel) {
        jsonString = jsonEncode(data.toJson());
        extractedRoleId = data.primaryRoleId;
      } else if (data is Map<String, dynamic>) {
        jsonString = jsonEncode(data);
        extractedRoleId = UserModel.fromJson(data).primaryRoleId;
      } else {
        jsonString = jsonEncode(data);
      }

      final success = await setString(AppConstants.userData, jsonString);
      await setBool(AppConstants.isLoggedIn, true);

      // Automatically sync role_id based on user model
      if (extractedRoleId != null) {
        await setInt(AppConstants.roleId, extractedRoleId);
      } else {
        await remove(AppConstants.roleId);
      }

      return success;
    } catch (e) {
      return false;
    }
  }

  /// Get parsed UserModel from SharedPreferences
  static UserModel? getUserData() {
    final str = getString(AppConstants.userData);
    if (str == null || str.isEmpty) return null;
    return UserModel.fromJsonString(str);
  }

  /// Get raw user data Map from SharedPreferences
  static Map<String, dynamic>? getUserDataMap() {
    final str = getString(AppConstants.userData);
    if (str == null || str.isEmpty) return null;
    try {
      final decoded = jsonDecode(str);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {}
    return null;
  }

  /// Get stored role_id if user is an employee / has assigned role
  static int? getRoleId() {
    final id = getInt(AppConstants.roleId);
    if (id != null) return id;
    final str = getString(AppConstants.roleId);
    if (str != null && str.isNotEmpty) {
      final parsed = int.tryParse(str);
      if (parsed != null) return parsed;
    }

    // Fallback: check stored user data
    final user = getUserData();
    if (user != null && user.primaryRoleId != null) {
      return user.primaryRoleId;
    }
    return null;
  }

  /// Explicitly save or remove role_id
  static Future<bool> setRoleId(int? roleId) async {
    if (roleId != null) {
      return await setInt(AppConstants.roleId, roleId);
    } else {
      return await remove(AppConstants.roleId);
    }
  }

  /// Check if user has an assigned employee role_id
  static bool hasRoleId() => getRoleId() != null;

  /// Clear all auth, role & user data from SharedPreferences
  static Future<void> clearUserData() async {
    await remove(AppConstants.userData);
    await remove(AppConstants.token);
    await remove(AppConstants.roleId);
    await remove(AppConstants.permissionsCache);
    await setBool(AppConstants.isLoggedIn, false);
  }
}
