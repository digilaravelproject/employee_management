import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import 'apply_leave_screen.dart';
import 'leave_calendar_screen.dart';

class MyLeavesScreen extends StatelessWidget {
  const MyLeavesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor, // Dark blue from the image
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top App Bar Area
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 16),
                      const AppText('Leaves', fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Iconsax.calendar_tick, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),
            
            // Subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20).copyWith(left: 60, bottom: 20),
              child: const AppText(
                'Manage your leaves and requests',
                fontSize: 13,
                color: Colors.white70,
              ),
            ),
            
            // Main Content Area
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Leave Balance Section
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.slate200, width: 0.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const AppText('Leave Balance Overview', fontSize: 16, fontWeight: FontWeight.bold),
                                Row(
                                  children: [
                                    const AppText('This Year', fontSize: 12, color: AppColors.textColorSecondary),
                                    const SizedBox(width: 4),
                                    const Icon(Iconsax.arrow_down_1, size: 14, color: AppColors.textColorSecondary),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _buildLeaveBalanceItem(
                              icon: Iconsax.tree,
                              iconColor: Colors.green,
                              iconBgColor: Colors.green.withValues(alpha: 0.1),
                              title: 'Casual Leave',
                              taken: 6,
                              remaining: 6,
                              total: 12,
                              progressColor: Colors.green,
                            ),
                            const Divider(height: 24, color: AppColors.borderColor),
                            _buildLeaveBalanceItem(
                              icon: Iconsax.health,
                              iconColor: Colors.teal,
                              iconBgColor: Colors.teal.withValues(alpha: 0.1),
                              title: 'Sick Leave',
                              taken: 2,
                              remaining: 8,
                              total: 10,
                              progressColor: Colors.teal,
                            ),
                            const Divider(height: 24, color: AppColors.borderColor),
                            _buildLeaveBalanceItem(
                              icon: Iconsax.wallet_money,
                              iconColor: Colors.purple,
                              iconBgColor: Colors.purple.withValues(alpha: 0.1),
                              title: 'Paid Leave',
                              taken: 5,
                              remaining: 10,
                              total: 15,
                              progressColor: Colors.purple,
                            ),
                            const Divider(height: 24, color: AppColors.borderColor),
                            _buildLeaveBalanceItem(
                              icon: Iconsax.clock,
                              iconColor: Colors.orange,
                              iconBgColor: Colors.orange.withValues(alpha: 0.1),
                              title: 'Comp Off',
                              taken: 1,
                              remaining: 4,
                              total: 5,
                              progressColor: Colors.orange,
                            ),
                            const Divider(height: 24, color: AppColors.borderColor),
                            _buildLeaveBalanceItem(
                              icon: Iconsax.user_octagon,
                              iconColor: Colors.pink,
                              iconBgColor: Colors.pink.withValues(alpha: 0.1),
                              title: 'Maternity Leave',
                              taken: 0,
                              remaining: 90,
                              total: 90,
                              progressColor: Colors.pink,
                            ),
                            const Divider(height: 24, color: AppColors.borderColor),
                            _buildLeaveBalanceItem(
                              icon: Iconsax.category,
                              iconColor: Colors.grey,
                              iconBgColor: Colors.grey.withValues(alpha: 0.2),
                              title: 'Other Leave',
                              taken: 1,
                              remaining: 9,
                              total: 10,
                              progressColor: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // 3 Buttons Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildActionCard(
                              icon: Iconsax.edit,
                              iconColor: Colors.white,
                              iconBgColor: AppColors.primaryColor,
                              title: 'Apply Leave',
                              subtitle: 'Request new leave',
                              onTap: () => Get.to(() => const ApplyLeaveScreen()),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildActionCard(
                              icon: Iconsax.calendar_1,
                              iconColor: AppColors.primaryColor,
                              iconBgColor: AppColors.primaryLight,
                              title: 'Leave Calendar',
                              subtitle: 'View calendar',
                              onTap: () => Get.to(() => const LeaveCalendarScreen()),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildActionCard(
                              icon: Iconsax.tick_square,
                              iconColor: Colors.white,
                              iconBgColor: Colors.green,
                              title: 'My Approvals',
                              subtitle: 'Approvals / History',
                              onTap: () {},
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Leave Requests
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const AppText('Leave Requests', fontSize: 16, fontWeight: FontWeight.bold),
                          TextButton(
                            onPressed: () {},
                            child: const AppText('View All', fontSize: 12, color: AppColors.primaryColor, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // Status Tabs
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildStatusTab('All', true),
                            const SizedBox(width: 8),
                            _buildStatusTab('Pending', false),
                            const SizedBox(width: 8),
                            _buildStatusTab('Approved', false),
                            const SizedBox(width: 8),
                            _buildStatusTab('Rejected', false),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Request List
                      _buildRequestItem(
                        title: 'Casual Leave',
                        dateRange: '20 May - 21 May 2025',
                        days: '2 Days',
                        status: 'Approved',
                        statusColor: Colors.green,
                        icon: Iconsax.tree,
                        iconColor: Colors.green,
                        iconBgColor: AppColors.slate100,
                        appliedOn: '18 May 2025',
                      ),
                      const SizedBox(height: 12),
                      _buildRequestItem(
                        title: 'Sick Leave',
                        dateRange: '10 Apr 2025',
                        days: '1 Day',
                        status: 'Approved',
                        statusColor: Colors.green,
                        icon: Iconsax.health,
                        iconColor: Colors.teal,
                        iconBgColor: AppColors.slate100,
                        appliedOn: '09 Apr 2025',
                      ),
                      const SizedBox(height: 12),
                      _buildRequestItem(
                        title: 'Paid Leave',
                        dateRange: '02 Apr - 05 Apr 2025',
                        days: '4 Days',
                        status: 'Rejected',
                        statusColor: Colors.red,
                        icon: Iconsax.wallet_money,
                        iconColor: Colors.purple,
                        iconBgColor: AppColors.slate100,
                        appliedOn: '28 Mar 2025',
                      ),
                      const SizedBox(height: 12),
                      _buildRequestItem(
                        title: 'Comp Off',
                        dateRange: '15 Mar 2025',
                        days: '1 Day',
                        status: 'Approved',
                        statusColor: Colors.green,
                        icon: Iconsax.clock,
                        iconColor: Colors.orange,
                        iconBgColor: AppColors.slate100,
                        appliedOn: '14 Mar 2025',
                      ),
                      const SizedBox(height: 12),
                      _buildRequestItem(
                        title: 'Sick Leave',
                        dateRange: '05 Mar 2025',
                        days: '1 Day',
                        status: 'Pending',
                        statusColor: Colors.orange,
                        icon: Iconsax.health,
                        iconColor: Colors.teal,
                        iconBgColor: AppColors.slate100,
                        appliedOn: '04 Mar 2025',
                      ),
                      const SizedBox(height: 100), // padding for bottom nav
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaveBalanceItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required int taken,
    required int remaining,
    required int total,
    required Color progressColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.slate100, // Matching the light grey background from the image
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText(title, fontSize: 13, fontWeight: FontWeight.bold),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      AppText('$total', fontSize: 16, fontWeight: FontWeight.bold),
                      const AppText(' Total', fontSize: 10, color: AppColors.textColorSecondary),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: taken / total,
                backgroundColor: AppColors.slate200,
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                minHeight: 4,
                borderRadius: BorderRadius.circular(2),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText('$taken Taken', fontSize: 11, color: AppColors.textColorSecondary),
                  AppText('$remaining Remaining', fontSize: 11, color: AppColors.textColorSecondary),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.slate200, width: 0.5),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(height: 12),
            AppText(title, fontSize: 11, fontWeight: FontWeight.bold, textAlign: TextAlign.center),
            const SizedBox(height: 4),
            AppText(subtitle, fontSize: 9, color: AppColors.textColorSecondary, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTab(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryColor : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isSelected ? AppColors.primaryColor : AppColors.borderColor),
      ),
      child: AppText(
        label,
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        color: isSelected ? Colors.white : AppColors.textColorPrimary,
      ),
    );
  }

  Widget _buildRequestItem({
    required String title,
    required String dateRange,
    required String days,
    required String status,
    required Color statusColor,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String appliedOn,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppText(title, fontSize: 14, fontWeight: FontWeight.bold),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: AppText(status, fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                AppText(dateRange, fontSize: 12, color: AppColors.textColorPrimary),
                const SizedBox(height: 4),
                AppText(days, fontSize: 11, color: AppColors.textColorSecondary),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const SizedBox(height: 30),
              const AppText('Applied on', fontSize: 9, color: AppColors.textColorHint),
              AppText(appliedOn, fontSize: 9, color: AppColors.textColorSecondary),
              const SizedBox(height: 4),
              const Icon(Icons.chevron_right, size: 16, color: AppColors.textColorHint),
            ],
          ),
        ],
      ),
    );
  }
}
