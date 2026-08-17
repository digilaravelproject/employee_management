import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/controllers/app_controller.dart';
import '../controllers/dashboard_controller.dart';
import 'home_screen.dart';
import '../../attendance/views/attendance_screen.dart';
import '../../profile/views/profile_screen.dart';
import 'all_modules_screen.dart';
import 'employee_more_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DashboardController());
    final appController = Get.find<AppController>();

    return Obx(() {
      final isAdmin = appController.userRole.value == 'admin';

      final List<Widget> screens = [
        const HomeScreen(),
        const AttendanceScreen(),
        isAdmin ? const AllModulesScreen() : const EmployeeMoreScreen(),
        const ProfileScreen(),
      ];

      return Scaffold(
        extendBody: false, // Content does not flow behind the floating bar
        body: screens[controller.currentIndex.value],
        bottomNavigationBar: _CustomBottomNavBar(controller: controller, isAdmin: isAdmin),
      );
    });
  }
}

class _CustomBottomNavBar extends StatelessWidget {
  final DashboardController controller;
  final bool isAdmin;
  const _CustomBottomNavBar({required this.controller, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 25,
            spreadRadius: 0,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Obx(
        () => Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: Iconsax.home_1,
              activeIcon: Iconsax.home5,
              label: 'Dashboard',
              isSelected: controller.currentIndex.value == 0,
              onTap: () => controller.changeIndex(0),
            ),
            _NavItem(
              icon: Iconsax.calendar_tick,
              activeIcon: Iconsax.calendar_tick5,
              label: 'Attendance',
              isSelected: controller.currentIndex.value == 1,
              onTap: () => controller.changeIndex(1),
            ),
            _NavItem(
              icon: isAdmin ? Iconsax.element_4 : Iconsax.category,
              activeIcon: isAdmin ? Iconsax.element_4 : Iconsax.category5,
              label: 'More',
              isSelected: controller.currentIndex.value == 2,
              onTap: () => controller.changeIndex(2),
            ),
            _NavItem(
              icon: Iconsax.user,
              activeIcon: Iconsax.user,
              label: 'Profile',
              isSelected: controller.currentIndex.value == 3,
              onTap: () => controller.changeIndex(3),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppColors.primaryColor : AppColors.textColorHint,
              size: 22,
            ),
            const SizedBox(height: 4),
            AppText(
              label,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AppColors.primaryColor : AppColors.textColorHint,
            ),
            const SizedBox(height: 2),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 3,
              width: isSelected ? 12 : 0,
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ComingSoonScreen extends StatelessWidget {
  final String title;
  const ComingSoonScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppText(title, fontSize: 18, fontWeight: FontWeight.w700),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.timer_1, size: 80, color: AppColors.primaryColor.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            AppText('$title Coming Soon', fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textColorSecondary),
          ],
        ),
      ),
    );
  }
}
