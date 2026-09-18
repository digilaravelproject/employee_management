import 'package:get/get.dart';
import 'dart:convert';
import '../services/storage/shared_prefs.dart';
import '../constants/app_constants.dart';
import '../../features/auth/domain/models/user_model.dart';

class AppController extends GetxController {
  // Store the selected role. 'admin' or 'employee'
  final RxString userRole = 'admin'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadRoleFromPrefs();
  }

  void _loadRoleFromPrefs() {
    final userDataString = SharedPrefs.getString(AppConstants.userData);
    if (userDataString != null && userDataString.isNotEmpty) {
      try {
        final userData = jsonDecode(userDataString);
        if (userData['role'] != null) {
          userRole.value = userData['role'];
        }
      } catch (e) {
        print('Error loading role from prefs: $e');
      }
    }
  }

  void setRole(String role) {
    userRole.value = role;
  }
}
