import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';

class ShiftRotationScreen extends StatelessWidget {
  const ShiftRotationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textColorPrimary),
          onPressed: () => Get.back(),
        ),
        title: const AppText('Shift Rotation', fontSize: 18, fontWeight: FontWeight.bold),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.textColorPrimary),
            onPressed: () {},
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          // Month Selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.keyboard_arrow_left, color: AppColors.textColorPrimary),
                  onPressed: () {},
                ),
                const AppText('May 2025', fontSize: 16, fontWeight: FontWeight.bold),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.keyboard_arrow_right, color: AppColors.slate300),
                      onPressed: () {},
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.borderColor),
                      ),
                      child: const Icon(Iconsax.calendar, size: 18, color: AppColors.textColorPrimary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Stats Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(child: _buildStatCard('Total Rotations', '4', Colors.blue)),
                const SizedBox(width: 8),
                Expanded(child: _buildStatCard('Active', '2', Colors.green)),
                const SizedBox(width: 8),
                Expanded(child: _buildStatCard('Completed', '1', Colors.grey)),
                const SizedBox(width: 8),
                Expanded(child: _buildStatCard('Upcoming', '1', Colors.orange)),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // List Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const AppText('Rotation List', fontSize: 14, fontWeight: FontWeight.bold),
                AppText('View Calendar', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryColor),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildRotationCard(
                  'Rotation - May 2025 - Week 1',
                  '28 Apr - 04 May 2025',
                  '3 Shifts • 54 Employees',
                  'Completed',
                  Colors.green,
                ),
                _buildRotationCard(
                  'Rotation - May 2025 - Week 2',
                  '05 May - 11 May 2025',
                  '3 Shifts • 56 Employees',
                  'Completed',
                  Colors.green,
                ),
                _buildRotationCard(
                  'Rotation - May 2025 - Week 3',
                  '12 May - 18 May 2025',
                  '3 Shifts • 56 Employees',
                  'Active',
                  AppColors.primaryColor,
                ),
                _buildRotationCard(
                  'Rotation - May 2025 - Week 4',
                  '19 May - 25 May 2025',
                  '3 Shifts • 56 Employees',
                  'Upcoming',
                  Colors.orange,
                ),
                const SizedBox(height: 80), // Fab space
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          AppText(label, fontSize: 9, color: AppColors.textColorSecondary, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          AppText(value, fontSize: 20, fontWeight: FontWeight.bold, color: color),
        ],
      ),
    );
  }

  Widget _buildRotationCard(String title, String dates, String details, String status, Color statusColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: AppText(title, fontSize: 14, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: AppText(status, fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AppText(dates, fontSize: 12, color: AppColors.textColorSecondary),
          const SizedBox(height: 4),
          AppText(details, fontSize: 12, color: AppColors.textColorSecondary),
        ],
      ),
    );
  }
}
