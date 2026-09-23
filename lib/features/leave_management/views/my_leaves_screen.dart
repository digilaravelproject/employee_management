import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/my_leaves_controller.dart';
import 'apply_leave_screen.dart';
import 'leave_approval_screen.dart';
import 'leave_calendar_screen.dart';
import 'my_approvals_screen.dart';

class MyLeavesScreen extends StatelessWidget {
  const MyLeavesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller for fetching dynamic leave requests & balances
    final controller = Get.put(MyLeavesController());

    return Scaffold(
      backgroundColor: AppColors.primaryColor,
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
                child: RefreshIndicator(
                  onRefresh: () => controller.fetchLeaveRequests(),
                  color: AppColors.primaryColor,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
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
                                      Obx(() => AppText('Year ${controller.selectedYear.value}', fontSize: 12, color: AppColors.textColorSecondary, fontWeight: FontWeight.w600)),
                                      const SizedBox(width: 4),
                                      const Icon(Iconsax.arrow_down_1, size: 14, color: AppColors.textColorSecondary),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Dynamic Leave Balances from API
                              Obx(() {
                                if (controller.leaveBalances.isNotEmpty) {
                                  return Column(
                                    children: controller.leaveBalances.map((b) {
                                      final isLast = b == controller.leaveBalances.last;
                                      Color pColor = Colors.green;
                                      IconData icon = Iconsax.tree;
                                      final lName = b.name.toLowerCase();
                                      if (lName.contains('sick')) {
                                        pColor = Colors.teal;
                                        icon = Iconsax.health;
                                      } else if (lName.contains('paid')) {
                                        pColor = Colors.purple;
                                        icon = Iconsax.wallet_money;
                                      } else if (lName.contains('comp')) {
                                        pColor = Colors.orange;
                                        icon = Iconsax.clock;
                                      }

                                      return Column(
                                        children: [
                                          _buildLeaveBalanceItem(
                                            icon: icon,
                                            iconColor: pColor,
                                            iconBgColor: pColor.withValues(alpha: 0.1),
                                            title: b.name,
                                            taken: b.taken,
                                            remaining: b.remaining,
                                            total: b.total,
                                            progressColor: pColor,
                                          ),
                                          if (!isLast) const Divider(height: 24, color: AppColors.borderColor),
                                        ],
                                      );
                                    }).toList(),
                                  );
                                }

                                // Default/Fallback display while loading
                                return Column(
                                  children: [
                                    _buildLeaveBalanceItem(
                                      icon: Iconsax.tree,
                                      iconColor: Colors.green,
                                      iconBgColor: Colors.green.withValues(alpha: 0.1),
                                      title: 'Casual Leave',
                                      taken: 0,
                                      remaining: 12,
                                      total: 12,
                                      progressColor: Colors.green,
                                    ),
                                    const Divider(height: 24, color: AppColors.borderColor),
                                    _buildLeaveBalanceItem(
                                      icon: Iconsax.health,
                                      iconColor: Colors.teal,
                                      iconBgColor: Colors.teal.withValues(alpha: 0.1),
                                      title: 'Sick Leave',
                                      taken: 0,
                                      remaining: 10,
                                      total: 10,
                                      progressColor: Colors.teal,
                                    ),
                                  ],
                                );
                              }),
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
                                onTap: () async {
                                  final res = await Get.to(() => const ApplyLeaveScreen());
                                  if (res == true) {
                                    controller.fetchLeaveRequests();
                                  }
                                },
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
                                onTap: () => Get.to(() => const MyApprovalsScreen()),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Leave Requests Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const AppText('Leave Requests', fontSize: 16, fontWeight: FontWeight.bold),
                            TextButton(
                              onPressed: () => Get.to(() => const MyApprovalsScreen()),
                              child: const AppText('View All', fontSize: 12, color: AppColors.primaryColor, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Status Tabs
                        Obx(() {
                          final c = controller.counts.value;
                          final allCount = c?.all ?? controller.leaveRequests.length;
                          final pendingCount = c?.pending ?? 0;
                          final approvedCount = c?.approved ?? 0;
                          final rejectedCount = c?.rejected ?? 0;

                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildStatusTab('All', allCount, controller.selectedStatus.value == 'All', () => controller.setStatus('All')),
                                const SizedBox(width: 8),
                                _buildStatusTab('Pending', pendingCount, controller.selectedStatus.value == 'Pending', () => controller.setStatus('Pending'), color: Colors.orange),
                                const SizedBox(width: 8),
                                _buildStatusTab('Approved', approvedCount, controller.selectedStatus.value == 'Approved', () => controller.setStatus('Approved'), color: Colors.green),
                                const SizedBox(width: 8),
                                _buildStatusTab('Rejected', rejectedCount, controller.selectedStatus.value == 'Rejected', () => controller.setStatus('Rejected'), color: Colors.red),
                              ],
                            ),
                          );
                        }),

                        const SizedBox(height: 16),

                        // Dynamic Leave Requests List from API
                        Obx(() {
                          if (controller.isLoading.value) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 36),
                              child: Center(
                                child: CircularProgressIndicator(color: AppColors.primaryColor),
                              ),
                            );
                          }

                          if (controller.leaveRequests.isEmpty) {
                            return Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.slate200),
                              ),
                              child: Column(
                                children: [
                                  const Icon(Iconsax.clipboard_close, size: 36, color: AppColors.textColorHint),
                                  const SizedBox(height: 10),
                                  AppText(
                                    'No ${controller.selectedStatus.value.toLowerCase()} leave requests found',
                                    fontSize: 13,
                                    color: AppColors.textColorSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ],
                              ),
                            );
                          }

                          return Column(
                            children: controller.leaveRequests.map((item) {
                              Color statusColor = Colors.orange;
                              switch (item.status.toLowerCase()) {
                                case 'approved':
                                  statusColor = Colors.green;
                                  break;
                                case 'rejected':
                                  statusColor = Colors.red;
                                  break;
                                case 'cancelled':
                                  statusColor = Colors.grey;
                                  break;
                              }

                              IconData iconData = Iconsax.tree;
                              Color iconColor = Colors.green;
                              final lName = item.leaveType.toLowerCase();
                              if (lName.contains('sick')) {
                                iconData = Iconsax.health;
                                iconColor = Colors.teal;
                              } else if (lName.contains('paid')) {
                                iconData = Iconsax.wallet_money;
                                iconColor = Colors.purple;
                              } else if (lName.contains('comp')) {
                                iconData = Iconsax.clock;
                                iconColor = Colors.orange;
                              }

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildRequestItem(
                                  title: item.leaveType,
                                  dateRange: item.formattedDates,
                                  days: item.duration,
                                  status: item.status,
                                  statusColor: statusColor,
                                  icon: iconData,
                                  iconColor: iconColor,
                                  iconBgColor: iconColor.withValues(alpha: 0.1),
                                  appliedOn: item.formattedAppliedOn,
                                  session: item.sessionType,
                                  reason: item.reason,
                                  onTap: () {
                                    Get.to(() => LeaveApprovalScreen(leaveId: item.id));
                                  },
                                ),
                              );
                            }).toList(),
                          );
                        }),

                        const SizedBox(height: 100), // padding for bottom nav
                      ],
                    ),
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
    final progress = total > 0 ? (taken / total).clamp(0.0, 1.0) : 0.0;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.slate100,
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
                value: progress,
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

  Widget _buildStatusTab(String label, int count, bool isSelected, VoidCallback onTap, {Color? color}) {
    final activeColor = color ?? AppColors.primaryColor;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? activeColor : AppColors.slate200),
        ),
        child: Row(
          children: [
            AppText(
              label,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.textColorPrimary,
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withValues(alpha: 0.25) : AppColors.slate100,
                borderRadius: BorderRadius.circular(6),
              ),
              child: AppText(
                '$count',
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppColors.textColorSecondary,
              ),
            ),
          ],
        ),
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
    String? session,
    String? reason,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
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
                  Row(
                    children: [
                      AppText(dateRange, fontSize: 12, color: AppColors.textColorPrimary, fontWeight: FontWeight.w500),
                      if (session != null && session.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.slate100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: AppText(session, fontSize: 9, color: AppColors.textColorSecondary),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  AppText(days, fontSize: 11, color: AppColors.textColorSecondary),
                  if (reason != null && reason.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    AppText(
                      reason,
                      fontSize: 11,
                      color: AppColors.textColorHint,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(height: 24),
                const AppText('Applied on', fontSize: 9, color: AppColors.textColorHint),
                AppText(appliedOn, fontSize: 9, color: AppColors.textColorSecondary),
                const SizedBox(height: 4),
                const Icon(Icons.chevron_right, size: 16, color: AppColors.textColorHint),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
