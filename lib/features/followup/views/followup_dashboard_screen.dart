import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/followup_controller.dart';
import 'sub_views/employee_dashboard_view.dart';
import 'sub_views/admin_dashboard_view.dart';

class FollowupDashboardScreen extends StatelessWidget {
  const FollowupDashboardScreen({super.key});

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
          title: _buildRoleSwitcher(controller),
          centerTitle: true,
          actions: const [
            Icon(Iconsax.notification, color: AppColors.textColorPrimary),
            SizedBox(width: 16),
          ],
        ),
        body: role == 'Employee' 
            ? const EmployeeDashboardView() 
            : const AdminDashboardView(),
      );
    });
  }

  Widget _buildRoleSwitcher(FollowupController controller) {
    return Obx(() {
      final isEmployee = controller.selectedRole.value == 'Employee';

      return Container(
        height: 38,
        width: 210,
        decoration: BoxDecoration(
          color: AppColors.slate100,
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.all(3),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => controller.changeRole('Employee'),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isEmployee ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(11),
                    boxShadow: isEmployee
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            )
                          ]
                        : null,
                  ),
                  child: Center(
                    child: AppText(
                      'Employee',
                      fontSize: 12,
                      fontWeight: isEmployee ? FontWeight.bold : FontWeight.w600,
                      color: isEmployee ? AppColors.textColorPrimary : AppColors.textColorSecondary,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => controller.changeRole('Admin'),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: !isEmployee ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(11),
                    boxShadow: !isEmployee
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            )
                          ]
                        : null,
                  ),
                  child: Center(
                    child: AppText(
                      'Admin',
                      fontSize: 12,
                      fontWeight: !isEmployee ? FontWeight.bold : FontWeight.w600,
                      color: !isEmployee ? AppColors.textColorPrimary : AppColors.textColorSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
