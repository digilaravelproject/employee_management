import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/role_permissions_controller.dart';
import 'edit_role_screen.dart';

class RolePermissionsScreen extends StatelessWidget {
  const RolePermissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RolePermissionsController>();
    final role = controller.selectedRole.value;

    if (role == null) {
      return const Scaffold(
        body: Center(child: AppText('No role selected')),
      );
    }

    return EditRoleScreen(role: role);
  }
}
