import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/app_controller.dart';
import '../../features/role_permissions/models/role_permission_models.dart';

/// Centralized Role-Based Access Control (RBAC) Permission Manager.
class AppPermissionManager extends GetxService {
  final Rxn<Role> activeRole = Rxn<Role>();
  final RxSet<String> grantedKeys = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _loadDefaultPermissions();
  }

  void _loadDefaultPermissions() {
    // By default, if user is admin, admin has full access.
    // Otherwise populate from activeRole.
    if (activeRole.value != null) {
      _syncGrantedKeysFromRole(activeRole.value!);
    }
  }

  void setActiveRole(Role role) {
    activeRole.value = role;
    _syncGrantedKeysFromRole(role);
  }

  void _syncGrantedKeysFromRole(Role role) {
    final keys = <String>{};
    for (final group in role.permissionGroups) {
      for (final perm in group.permissions) {
        if (perm.isGranted) {
          keys.add(perm.key);
        }
      }
    }
    grantedKeys.assignAll(keys);
  }

  /// Check if the currently logged-in user or active role has permission.
  bool can(String permissionKey) {
    // Admin always has bypass access to all operations
    if (Get.isRegistered<AppController>()) {
      final appController = Get.find<AppController>();
      if (appController.userRole.value.toLowerCase() == 'admin') {
        return true;
      }
    }

    // If no role explicitly set yet, allow by default or check grantedKeys
    if (activeRole.value == null) {
      return true; // Graceful default during testing
    }

    return grantedKeys.contains(permissionKey);
  }

  /// Check if an entire module has any granted permission
  bool hasModuleAccess(String moduleId) {
    if (Get.isRegistered<AppController>()) {
      final appController = Get.find<AppController>();
      if (appController.userRole.value.toLowerCase() == 'admin') {
        return true;
      }
    }

    if (activeRole.value == null) return true;

    final group = activeRole.value!.permissionGroups
        .firstWhereOrNull((g) => g.moduleId == moduleId);
    return group != null && group.grantedCount > 0;
  }
}

/// A reactive widget that conditionally renders [child] if the current user
/// has [permission]. Otherwise renders [fallback] (defaults to SizedBox.shrink()).
class PermissionGuard extends StatelessWidget {
  final String permission;
  final Widget child;
  final Widget fallback;

  const PermissionGuard({
    super.key,
    required this.permission,
    required this.child,
    this.fallback = const SizedBox.shrink(),
  });

  @override
  Widget build(BuildContext context) {
    final manager = Get.put(AppPermissionManager());
    return Obx(() {
      if (manager.can(permission)) {
        return child;
      }
      return fallback;
    });
  }
}
