import 'package:get/get.dart';
import 'dart:convert';
import '../services/storage/shared_prefs.dart';
import '../services/permission/permission_service.dart';
import '../constants/app_constants.dart';
import '../utils/logger.dart';

class AppController extends GetxController {
  // Store the selected role. 'admin' or 'employee'
  final RxString userRole = 'admin'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadRoleFromPrefs();
  }

  void _loadRoleFromPrefs() {
    final roleId = SharedPrefs.getRoleId() ?? SharedPrefs.getUserData()?.primaryRoleId;

    if (roleId != null) {
      PermissionService.to.loadCachedPermissions();
      PermissionService.to.fetchPermissions(roleId: roleId);
      Logger.d('AppController => Initialized for role_id=$roleId');
      return;
    }

    // Check userData if role string exists
    final userDataString = SharedPrefs.getString(AppConstants.userData);
    if (userDataString != null && userDataString.isNotEmpty) {
      try {
        final userData = jsonDecode(userDataString);
        if (userData['role'] != null) {
          final role = userData['role'].toString().toLowerCase().trim();
          if (role == 'admin' || role == 'superadmin' || role == 'super_admin') {
            userRole.value = 'admin';
            PermissionService.to.setAdminMode(true);
          } else {
            userRole.value = 'employee';
            PermissionService.to.setAdminMode(false);
          }
          return;
        }
      } catch (e) {
        Logger.e('AppController => Error loading role from prefs: $e');
      }
    }

    // Default to admin mode if role_id is not in shared preferences
    userRole.value = 'admin';
    PermissionService.to.setAdminMode(true);
  }

  void setRole(String role) {
    final normalized = role.toLowerCase().trim();
    if (normalized == 'admin' || normalized == 'superadmin' || normalized == 'super_admin') {
      userRole.value = 'admin';
      PermissionService.to.setAdminMode(true);
    } else {
      userRole.value = 'employee';
      PermissionService.to.setAdminMode(false);
    }
  }
}
