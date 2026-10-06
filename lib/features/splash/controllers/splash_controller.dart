import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/storage/shared_prefs.dart';
import '../../../core/services/permission/permission_service.dart';
import '../../../routes/route_helper.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _handleStartup();
  }

  Future<void> _handleStartup() async {
    // Show splash branding for smooth UX
    await Future.delayed(const Duration(milliseconds: 1200));

    final isLoggedIn = SharedPrefs.getBool(AppConstants.isLoggedIn) ?? false;

    if (isLoggedIn) {
      final roleId = SharedPrefs.getRoleId() ?? SharedPrefs.getUserData()?.primaryRoleId;

      if (roleId != null) {
        await SharedPrefs.setRoleId(roleId);
        // Call permissions API with role_id right after splash
        await PermissionService.to.fetchPermissions(roleId: roleId);
      } else {
        // No role_id: call permissions API or run in Admin mode
        await PermissionService.to.fetchPermissions();
      }

      Get.offAllNamed(RouteHelper.getDashboardRoute());
    } else {
      Get.offAllNamed(RouteHelper.getIntroRoute());
    }
  }
}
