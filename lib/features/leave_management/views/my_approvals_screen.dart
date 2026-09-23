import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/my_leaves_controller.dart';
import '../models/admin_leave_model.dart';
import 'leave_approval_screen.dart';

class MyApprovalsScreen extends StatelessWidget {
  const MyApprovalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Controller instance
    final controller = Get.put(MyLeavesController(), tag: 'approvals');

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
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textColorPrimary, size: 20),
              onPressed: () => Get.back(),
            ),
          ),
        ),
        title: const AppText('My Approvals', fontSize: 18, fontWeight: FontWeight.bold),
        centerTitle: true,
        actions: [
          // Year Selector
          Obx(() => Container(
            margin: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.slate100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Iconsax.calendar_1, size: 14, color: AppColors.primaryColor),
                const SizedBox(width: 4),
                AppText('${controller.selectedYear.value}', fontSize: 12, fontWeight: FontWeight.bold),
              ],
            ),
          )),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.fetchLeaveRequests(),
        color: AppColors.primaryColor,
        child: Column(
          children: [
            // Status Tabs
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Obx(() {
                final c = controller.counts.value;
                final allCount = c?.all ?? controller.leaveRequests.length;
                final pendingCount = c?.pending ?? 0;
                final approvedCount = c?.approved ?? 0;
                final rejectedCount = c?.rejected ?? 0;

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildTab('All', allCount, controller.selectedStatus.value == 'All', () => controller.setStatus('All')),
                      const SizedBox(width: 8),
                      _buildTab('Pending', pendingCount, controller.selectedStatus.value == 'Pending', () => controller.setStatus('Pending'), color: Colors.orange),
                      const SizedBox(width: 8),
                      _buildTab('Approved', approvedCount, controller.selectedStatus.value == 'Approved', () => controller.setStatus('Approved'), color: Colors.green),
                      const SizedBox(width: 8),
                      _buildTab('Rejected', rejectedCount, controller.selectedStatus.value == 'Rejected', () => controller.setStatus('Rejected'), color: Colors.red),
                    ],
                  ),
                );
              }),
            ),

            const Divider(height: 1, color: AppColors.slate200),

            // Requests List
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primaryColor),
                  );
                }

                if (controller.leaveRequests.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.slate100,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Iconsax.clipboard_close, size: 40, color: AppColors.textColorHint),
                        ),
                        const SizedBox(height: 16),
                        const AppText('No Leave Requests', fontSize: 16, fontWeight: FontWeight.bold),
                        const SizedBox(height: 6),
                        AppText(
                          'No ${controller.selectedStatus.value.toLowerCase()} requests found.',
                          fontSize: 12,
                          color: AppColors.textColorSecondary,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.leaveRequests.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final item = controller.leaveRequests[index];
                    return _buildApprovalCard(context, item, controller);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, int count, bool isSelected, VoidCallback onTap, {Color? color}) {
    final activeColor = color ?? AppColors.primaryColor;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : AppColors.slate100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? activeColor : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            AppText(
              label,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.textColorSecondary,
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withValues(alpha: 0.25) : AppColors.slate200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: AppText(
                '$count',
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppColors.textColorPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApprovalCard(BuildContext context, AdminLeaveItemModel item, MyLeavesController controller) {
    Color statusBgColor;
    Color statusTextColor;
    switch (item.status.toLowerCase()) {
      case 'approved':
        statusBgColor = Colors.green.withValues(alpha: 0.12);
        statusTextColor = Colors.green[800]!;
        break;
      case 'rejected':
        statusBgColor = Colors.red.withValues(alpha: 0.12);
        statusTextColor = Colors.red[800]!;
        break;
      case 'cancelled':
        statusBgColor = Colors.grey.withValues(alpha: 0.12);
        statusTextColor = Colors.grey[800]!;
        break;
      default:
        statusBgColor = Colors.orange.withValues(alpha: 0.12);
        statusTextColor = Colors.orange[800]!;
    }

    return InkWell(
      onTap: () {
        Get.to(() => LeaveApprovalScreen(leaveId: item.id));
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: AppColors.slate200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Employee details & Status
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primaryLight,
                  backgroundImage: item.employee.avatar != null && item.employee.avatar!.isNotEmpty
                      ? NetworkImage(item.employee.avatar!)
                      : null,
                  child: item.employee.avatar == null || item.employee.avatar!.isEmpty
                      ? AppText(
                          item.employee.name.isNotEmpty ? item.employee.name[0].toUpperCase() : 'E',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(item.employee.name, fontSize: 14, fontWeight: FontWeight.bold),
                      const SizedBox(height: 2),
                      AppText(
                        '${item.employee.employeeId} • ${item.employee.designation.isNotEmpty ? item.employee.designation : item.employee.department}',
                        fontSize: 11,
                        color: AppColors.textColorSecondary,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: AppText(
                    item.status,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: statusTextColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(color: AppColors.slate100, height: 1),
            const SizedBox(height: 12),

            // Leave Details
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: AppText(
                    item.leaveTypeCode.isNotEmpty ? item.leaveTypeCode : 'CL',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
                const SizedBox(width: 8),
                AppText(item.leaveType, fontSize: 13, fontWeight: FontWeight.bold),
                const Spacer(),
                AppText(
                  item.duration,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryColor,
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Date Range & Session
            Row(
              children: [
                const Icon(Iconsax.calendar_1, size: 14, color: AppColors.textColorSecondary),
                const SizedBox(width: 6),
                AppText(item.formattedDates, fontSize: 12, color: AppColors.textColorPrimary, fontWeight: FontWeight.w600),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.slate100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: AppText(item.sessionType, fontSize: 10, color: AppColors.textColorSecondary),
                ),
              ],
            ),

            if (item.reason.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.slate50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: AppText(
                  item.reason,
                  fontSize: 12,
                  color: AppColors.textColorSecondary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],

            if (item.assigneeName != null && item.assigneeName!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Iconsax.user_tag, size: 14, color: AppColors.textColorHint),
                  const SizedBox(width: 6),
                  AppText(
                    'Handover / Assigned to: ${item.assigneeName!}',
                    fontSize: 11,
                    color: AppColors.textColorSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ],
              ),
            ],

          ],
        ),
      ),
    );
  }
}
