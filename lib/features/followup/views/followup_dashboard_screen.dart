import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/followup_controller.dart';
import 'sub_views/employee_dashboard_view.dart';
import 'sub_views/admin_dashboard_view.dart';

class FollowupDashboardScreen extends StatelessWidget {
  final bool isEmployeeOnly;
  const FollowupDashboardScreen({super.key, this.isEmployeeOnly = false});

  @override
  Widget build(BuildContext context) {
    // Instantiate or find controller
    final controller = Get.put(FollowupController());

    return Obx(() {
      final role = controller.selectedRole.value;

      return Scaffold(
        backgroundColor: AppColors.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.slate100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textColorPrimary, size: 18),
                onPressed: () => Get.back(),
              ),
            ),
          ),
          title: const AppText('Followups', fontSize: 16, fontWeight: FontWeight.bold),
          centerTitle: true,
          actions: const [
            Icon(Iconsax.notification, color: AppColors.textColorPrimary),
            SizedBox(width: 16),
          ],
        ),
        body: isEmployeeOnly 
            ? const EmployeeDashboardView() 
            : const AdminDashboardView(),
      );
    });
  }
}



