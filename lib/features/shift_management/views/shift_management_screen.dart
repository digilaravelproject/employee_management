import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import 'assign_shift_screen.dart';
import 'create_shift_screen.dart';
import 'shift_rotation_screen.dart';

class ShiftManagementScreen extends StatelessWidget {
  const ShiftManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textColorPrimary),
          onPressed: () => Get.back(),
        ),
        title: const AppText('Shift Management', fontSize: 18, fontWeight: FontWeight.bold),
        centerTitle: false,
        // actions: [
        //   IconButton(
        //     icon: const Icon(Iconsax.notification, color: AppColors.textColorPrimary),
        //     onPressed: () {},
        //   ),
        // ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildQuickAction(context, Iconsax.clipboard_text, 'Create Shift', Colors.purple, () => Get.to(() => const CreateShiftScreen())),
                _buildQuickAction(context, Iconsax.profile_2user, 'Assign Shift', Colors.green, () => Get.to(() => const AssignShiftScreen())),
                _buildQuickAction(context, Iconsax.repeate_music, 'Rotation', Colors.orange, () => Get.to(() => const ShiftRotationScreen())),
                _buildQuickAction(context, Iconsax.calendar_2, 'Roster', Colors.blue, () {}),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Today's Overview
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const AppText('Today\'s Overview', fontSize: 14, fontWeight: FontWeight.bold),
                AppText('View all', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryColor),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildOverviewStat('Total Shifts', '8', Colors.blue)),
                      _buildDivider(),
                      Expanded(child: _buildOverviewStat('Employees', '56', Colors.black)),
                      _buildDivider(),
                      Expanded(child: _buildOverviewStat('Present', '48', Colors.green)),
                      _buildDivider(),
                      Expanded(child: _buildOverviewStat('On Leave', '5', Colors.red)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const AppText('Updated: 20 May 2025, 10:30 AM', fontSize: 10, color: AppColors.textColorSecondary),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Today's Shifts
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const AppText('Today\'s Shifts', fontSize: 14, fontWeight: FontWeight.bold),
                AppText('View roster', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryColor),
              ],
            ),
            const SizedBox(height: 12),
            _buildShiftCard('Morning Shift', '09:00 AM - 06:00 PM', '22', Icons.wb_sunny_outlined, Colors.orange),
            const SizedBox(height: 12),
            _buildShiftCard('Evening Shift', '02:00 PM - 11:00 PM', '18', Icons.wb_twilight, Colors.purple),
            const SizedBox(height: 12),
            _buildShiftCard('Night Shift', '11:00 PM - 08:00 AM', '16', Icons.nights_stay_outlined, Colors.blue),
            
            const SizedBox(height: 24),
            
            // Upcoming Rotations
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const AppText('Upcoming Rotations', fontSize: 14, fontWeight: FontWeight.bold),
                AppText('View all', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryColor),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const AppText('Rotation - May 2025 - Week 3', fontSize: 14, fontWeight: FontWeight.bold),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const AppText('Active', fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const AppText('19 May 2025 - 25 May 2025', fontSize: 12, color: AppColors.textColorSecondary),
                  const SizedBox(height: 4),
                  const AppText('3 Shifts • 56 Employees', fontSize: 12, color: AppColors.textColorSecondary),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          AppText(label, fontSize: 11, fontWeight: FontWeight.w600),
        ],
      ),
    );
  }

  Widget _buildOverviewStat(String label, String value, Color valueColor) {
    return Column(
      children: [
        AppText(label, fontSize: 10, color: AppColors.textColorSecondary, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        AppText(value, fontSize: 20, fontWeight: FontWeight.bold, color: valueColor),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: AppColors.slate200,
    );
  }

  Widget _buildShiftCard(String title, String time, String employees, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(title, fontSize: 14, fontWeight: FontWeight.bold),
                const SizedBox(height: 4),
                AppText(time, fontSize: 12, color: AppColors.textColorSecondary),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AppText(employees, fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
              const AppText('Employees', fontSize: 10, color: AppColors.textColorSecondary),
            ],
          ),
        ],
      ),
    );
  }
}
