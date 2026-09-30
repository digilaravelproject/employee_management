import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/payroll_controller.dart';
import '../models/payroll_record_model.dart';
import 'salary_overview_screen.dart';

class SalaryEmployeeListScreen extends StatelessWidget {
  const SalaryEmployeeListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Put controller in memory if not already registered
    final controller = Get.isRegistered<PayrollController>()
        ? Get.find<PayrollController>()
        : Get.put(PayrollController());

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
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.textColorPrimary,
                size: 20,
              ),
              onPressed: () => Get.back(),
            ),
          ),
        ),
        title: const AppText(
          'Salary',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textColorPrimary,
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.textColorPrimary),
            tooltip: 'Refresh',
            onPressed: () => controller.fetchSalaries(isRefresh: true),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.fetchSalaries(isRefresh: true),
        color: AppColors.primaryColor,
        child: Column(
          children: [
            // ── Period Picker Row ──
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => _showMonthPicker(context, controller),
                    child: Obx(() {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.slate50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.slate200),
                        ),
                        child: Row(
                          children: [
                            AppText(
                              controller.selectedMonthLabel.value,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textColorPrimary,
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.keyboard_arrow_down,
                              color: AppColors.textColorSecondary,
                              size: 18,
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.slate50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.slate200),
                    ),
                    child: const Icon(Iconsax.calendar_1, color: AppColors.textColorSecondary, size: 18),
                  ),
                ],
              ),
            ),

            // ── Search Field Section ──
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.slate50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.slate100),
                      ),
                      child: TextField(
                        onChanged: (value) => controller.searchQuery.value = value,
                        decoration: const InputDecoration(
                          hintText: 'Search employee...',
                          hintStyle: TextStyle(color: AppColors.textColorHint, fontSize: 14),
                          prefixIcon: Icon(Iconsax.search_normal, color: AppColors.textColorHint, size: 18),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Symmetrical Interactive Stats Deck ──
            const SizedBox(height: 12),
            SizedBox(
              height: 84,
              child: Obx(() {
                return ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildStatCard(
                      title: 'Total Employees',
                      value: '${controller.totalEmployeesCount}',
                      color: AppColors.indigo500,
                      isSelected: controller.selectedFilter.value == 'All',
                      onTap: () => controller.onFilterChanged('All'),
                    ),
                    _buildStatCard(
                      title: 'Created',
                      value: '${controller.createdCount}',
                      color: AppColors.successColor,
                      isSelected: controller.selectedFilter.value == 'Created',
                      onTap: () => controller.onFilterChanged('Created'),
                    ),
                    _buildStatCard(
                      title: 'Pending',
                      value: '${controller.pendingCount}',
                      color: AppColors.warningColor,
                      isSelected: controller.selectedFilter.value == 'Pending',
                      onTap: () => controller.onFilterChanged('Pending'),
                    ),
                  ],
                );
              }),
            ),
            const SizedBox(height: 14),

            // ── Employee List Section ──
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: AppText(
                  'EMPLOYEE LIST',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColorHint,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.payrollRecords.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primaryColor),
                  );
                }

                if (controller.errorMessage.value.isNotEmpty && controller.payrollRecords.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Iconsax.info_circle, size: 48, color: Colors.orange),
                          const SizedBox(height: 12),
                          AppText(
                            controller.errorMessage.value,
                            fontSize: 14,
                            color: AppColors.textColorSecondary,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => controller.fetchSalaries(),
                            icon: const Icon(Icons.refresh, size: 16, color: Colors.white),
                            label: const AppText('Try Again', fontSize: 13, color: Colors.white),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final list = controller.filteredPayrollRecords;
                if (list.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Iconsax.empty_wallet, size: 64, color: AppColors.textColorHint.withValues(alpha: 0.3)),
                        const SizedBox(height: 16),
                        const AppText('No Payroll Records Found', fontSize: 16, fontWeight: FontWeight.bold),
                        const SizedBox(height: 4),
                        AppText(
                          controller.searchQuery.value.isNotEmpty
                              ? 'Try refining your search terms'
                              : 'No payroll records available for this filter',
                          fontSize: 12,
                          color: AppColors.textColorHint,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  physics: const BouncingScrollPhysics(),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final record = list[index];
                    return _EmployeeSalaryListItem(record: record);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 114,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.06) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? color : AppColors.slate200,
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.015),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AppText(
              title,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isSelected ? color : AppColors.textColorSecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            AppText(
              value,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: isSelected ? color : AppColors.textColorPrimary,
            ),
          ],
        ),
      ),
    );
  }

  void _showMonthPicker(BuildContext context, PayrollController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.slate300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const AppText('Select Salary Month', fontSize: 16, fontWeight: FontWeight.bold),
              const SizedBox(height: 12),
              ...controller.availableMonthOptions.map((opt) {
                final isSelected = controller.selectedMonth.value == opt.code;
                return ListTile(
                  title: AppText(
                    opt.label,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? AppColors.primaryColor : AppColors.textColorPrimary,
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: AppColors.primaryColor)
                      : null,
                  onTap: () {
                    controller.changeMonth(opt.code, opt.label);
                    Get.back();
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _EmployeeSalaryListItem extends StatelessWidget {
  final PayrollRecord record;
  const _EmployeeSalaryListItem({required this.record});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PayrollController>();
    final isCreated = record.status.toLowerCase() == 'created';
    final statusColor = isCreated ? AppColors.successColor : AppColors.warningColor;
    final formattedValue = "₹${_formatSalary(record.netPayable.toInt())}";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.slate200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            controller.selectedRecord.value = record;
            controller.fetchEmployeeSalaryDetails(
              record.employeeId,
              month: controller.selectedMonth.value,
            );
            Get.to(() => const SalaryOverviewScreen());
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Avatar Left with Soft Borders
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.slate100, width: 1.5),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(23),
                    child: record.profilePic != null && record.profilePic!.isNotEmpty
                        ? Image.network(
                            record.profilePic!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => _buildFallbackAvatar(),
                          )
                        : _buildFallbackAvatar(),
                  ),
                ),
                const SizedBox(width: 14),

                // Info Center
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        record.employeeName,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColorPrimary,
                      ),
                      const SizedBox(height: 2),
                      AppText(
                        '${record.employeeId} • ${record.department}',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColorSecondary,
                      ),
                      const SizedBox(height: 6),
                      // Status pill
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: AppText(
                              record.status,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                          if (record.paymentMode != null && record.paymentMode!.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.slate100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: AppText(
                                record.paymentMode!,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textColorSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Salary Info Right
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    AppText(
                      formattedValue,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textColorPrimary,
                    ),
                    const SizedBox(height: 6),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: AppColors.textColorHint,
                      size: 14,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackAvatar() {
    final initials = record.employeeName.isNotEmpty
        ? record.employeeName.substring(0, 1).toUpperCase()
        : 'E';
    return Container(
      color: AppColors.primaryColor.withValues(alpha: 0.1),
      child: Center(
        child: AppText(
          initials,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryColor,
        ),
      ),
    );
  }

  String _formatSalary(int amount) {
    if (amount < 1000) return amount.toString();
    final str = amount.toString();
    var result = '';
    var count = 0;
    for (var i = str.length - 1; i >= 0; i--) {
      result = str[i] + result;
      count++;
      if (count == 3 && i > 0) {
        result = ',$result';
        count = 0;
      } else if (count == 2 && i > 0 && result.contains(',')) {
        result = ',$result';
        count = 0;
      }
    }
    return result;
  }
}
