import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'dart:math' as math;
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/leave_reports_controller.dart';
import '../models/admin_leave_model.dart';
import '../models/leave_report_model.dart';
import 'leave_approval_screen.dart';

class LeaveReportsScreen extends StatelessWidget {
  const LeaveReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<LeaveReportsController>()
        ? Get.find<LeaveReportsController>()
        : Get.put(LeaveReportsController());

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textColorPrimary, size: 20),
                onPressed: () => Get.back(),
              )
            : null,
        title: const AppText(
          'Leave Reports',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textColorPrimary,
        ),
        centerTitle: false,
        actions: [
          Obx(() {
            if (controller.hasActiveFilters) {
              return TextButton.icon(
                onPressed: controller.resetAllFilters,
                icon: const Icon(Icons.refresh_rounded, size: 16, color: AppColors.errorColor),
                label: const Text(
                  'Reset',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.errorColor,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          IconButton(
            tooltip: 'Refresh Report',
            icon: const Icon(Icons.refresh_rounded, color: AppColors.textColorSecondary, size: 22),
            onPressed: () => controller.fetchLeaveReport(isRefresh: true),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Obx(() {
        final report = controller.reportResponse.value;
        final summary = report?.summary;
        final leaveRecords = report?.data ?? [];

        return RefreshIndicator(
          onRefresh: () => controller.fetchLeaveReport(isRefresh: true),
          color: AppColors.primaryColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── FILTERS SECTION ──
                _buildFiltersCard(context, controller),

                const SizedBox(height: 16),

                // Error Message if any
                if (controller.errorMessage.value.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: AppText(
                            controller.errorMessage.value,
                            fontSize: 13,
                            color: Colors.red.shade700,
                          ),
                        ),
                        TextButton(
                          onPressed: () => controller.fetchLeaveReport(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Loading Shimmer or Progress
                if (controller.isLoading.value && !controller.isRefreshing.value)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.primaryColor, strokeWidth: 2.5),
                    ),
                  )
                else ...[
                  // ── OVERVIEW STATS CARDS ──
                  _buildStatsOverview(summary),

                  const SizedBox(height: 20),

                  // ── LEAVE TYPE BREAKDOWN (DONUT CHART) ──
                  if (summary != null && summary.byLeaveType.isNotEmpty)
                    _buildLeaveTypeDonutSection(summary),

                  const SizedBox(height: 20),

                  // ── DEPARTMENT BREAKDOWN ──
                  if (summary != null && summary.byDepartment.isNotEmpty)
                    _buildDepartmentSummarySection(summary),

                  const SizedBox(height: 20),

                  // ── LEAVE RECORDS LIST (DATA) ──
                  _buildLeaveRecordsSection(context, leaveRecords, controller),

                  const SizedBox(height: 30),
                ],
              ],
            ),
          ),
        );
      }),
    );
  }

  // ── 1. Interactive Filters Card ─────────────────────────────────
  Widget _buildFiltersCard(BuildContext context, LeaveReportsController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 1. Date Range
          _buildFilterRow(
            icon: Iconsax.calendar_1,
            label: 'Date Range',
            value: controller.formattedDisplayDateRange,
            isFiltered: controller.selectedDateRangePreset.value != 'This Month',
            onTap: () => _showDateRangePickerBottomSheet(context, controller),
          ),
          _buildDivider(),

          // 2. Department
          _buildFilterRow(
            icon: Iconsax.building,
            label: 'Department',
            value: controller.selectedDepartmentName.value,
            isFiltered: controller.selectedDepartmentId.value != null,
            onTap: () => _showDepartmentPicker(context, controller),
          ),
          _buildDivider(),

          // 3. Leave Type
          _buildFilterRow(
            icon: Iconsax.edit_2,
            label: 'Leave Type',
            value: controller.selectedLeaveTypeName.value,
            isFiltered: controller.selectedLeaveTypeId.value != null,
            onTap: () => _showLeaveTypePicker(context, controller),
          ),
          _buildDivider(),

          // 4. Status
          _buildFilterRow(
            icon: Iconsax.menu_board,
            label: 'Status',
            value: controller.selectedStatus.value == 'all'
                ? 'All Status'
                : controller.selectedStatus.value.capitalizeFirst ?? controller.selectedStatus.value,
            isFiltered: controller.selectedStatus.value != 'all',
            onTap: () => _showStatusPicker(context, controller),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isFiltered,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
        child: Row(
          children: [
            Icon(icon, color: isFiltered ? AppColors.primaryColor : AppColors.slate400, size: 18),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: AppText(
                label,
                fontSize: 13,
                fontWeight: isFiltered ? FontWeight.bold : FontWeight.w500,
                color: isFiltered ? AppColors.primaryColor : AppColors.textColorSecondary,
              ),
            ),
            Expanded(
              flex: 3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: Container(
                      padding: isFiltered
                          ? const EdgeInsets.symmetric(horizontal: 8, vertical: 3)
                          : EdgeInsets.zero,
                      decoration: isFiltered
                          ? BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(6),
                            )
                          : null,
                      child: AppText(
                        value,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: isFiltered ? AppColors.primaryColor : AppColors.textColorPrimary,
                        textAlign: TextAlign.right,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.keyboard_arrow_down, color: AppColors.slate400, size: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(color: AppColors.slate100, height: 1);
  }

  // ── 2. Overview Stats Cards ─────────────────────────────────────
  Widget _buildStatsOverview(LeaveReportSummaryModel? summary) {
    final totalRequests = summary?.totalRequests ?? 0;
    final totalDays = summary?.totalDays ?? 0.0;
    final approved = summary?.approved ?? 0;
    final rejected = summary?.rejected ?? 0;
    final pending = summary?.pending ?? 0;

    final daysStr = totalDays % 1 == 0 ? totalDays.toInt().toString() : totalDays.toStringAsFixed(1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText(
          'Summary Overview',
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: AppColors.textColorPrimary,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildStatCard('Total Requests', '$totalRequests', AppColors.primaryColor)),
            const SizedBox(width: 8),
            Expanded(child: _buildStatCard('Total Days', daysStr, const Color(0xFF6366F1))),
            const SizedBox(width: 8),
            Expanded(child: _buildStatCard('Approved', '$approved', Colors.green)),
            const SizedBox(width: 8),
            Expanded(child: _buildStatCard('Pending', '$pending', Colors.orange)),
            const SizedBox(width: 8),
            Expanded(child: _buildStatCard('Rejected', '$rejected', Colors.red)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.slate200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          AppText(
            label,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.textColorSecondary,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          AppText(
            value,
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ],
      ),
    );
  }

  // ── 3. Donut Chart Section (By Leave Type) ──────────────────────
  Widget _buildLeaveTypeDonutSection(LeaveReportSummaryModel summary) {
    final types = summary.byLeaveType;
    final totalRequests = summary.totalRequests;

    final chartColors = [
      const Color(0xFF2563EB), // Blue
      const Color(0xFF10B981), // Emerald
      const Color(0xFFF59E0B), // Amber
      const Color(0xFF8B5CF6), // Violet
      const Color(0xFFEC4899), // Pink
      const Color(0xFF06B6D4), // Cyan
    ];

    final chartValues = types.map((e) => e.percentage).toList();
    final sliceColors = List.generate(
      types.length,
      (i) => chartColors[i % chartColors.length],
    );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText(
            'Leave Types Distribution',
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.textColorPrimary,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Donut Chart
              SizedBox(
                width: 110,
                height: 110,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(110, 110),
                      painter: DynamicDonutChartPainter(
                        values: chartValues,
                        colors: sliceColors,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppText(
                          '$totalRequests',
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColorPrimary,
                        ),
                        const AppText('Requests', fontSize: 10, color: AppColors.textColorSecondary),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),

              // Legend
              Expanded(
                child: Column(
                  children: types.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final item = entry.value;
                    final color = sliceColors[idx % sliceColors.length];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: AppText(
                              item.name,
                              fontSize: 12,
                              color: AppColors.textColorPrimary,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          AppText(
                            '${item.requests} (${item.percentage.toStringAsFixed(0)}%)',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColorPrimary,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── 4. Department Summary Section ───────────────────────────────
  Widget _buildDepartmentSummarySection(LeaveReportSummaryModel summary) {
    final depts = summary.byDepartment;
    int maxTotal = 1;
    for (var d in depts) {
      if (d.requests > maxTotal) maxTotal = d.requests;
    }

    final deptPalette = [
      const Color(0xFF2563EB),
      const Color(0xFF10B981),
      const Color(0xFF8B5CF6),
      const Color(0xFFF59E0B),
      const Color(0xFFEC4899),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText(
            'Department Summary',
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.textColorPrimary,
          ),
          const SizedBox(height: 14),
          const Row(
            children: [
              Expanded(flex: 3, child: AppText('Department', fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textColorSecondary)),
              Expanded(child: AppText('Approved', fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green, textAlign: TextAlign.center)),
              Expanded(child: AppText('Rejected', fontSize: 11, fontWeight: FontWeight.bold, color: Colors.red, textAlign: TextAlign.center)),
              Expanded(child: AppText('Pending', fontSize: 11, fontWeight: FontWeight.bold, color: Colors.orange, textAlign: TextAlign.center)),
            ],
          ),
          const Divider(color: AppColors.slate100, height: 16),
          ...depts.asMap().entries.map((entry) {
            final idx = entry.key;
            final dept = entry.value;
            final color = deptPalette[idx % deptPalette.length];
            final factor = maxTotal > 0 ? (dept.requests / maxTotal) : 0.0;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          dept.department,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColorPrimary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: factor > 0 ? factor.clamp(0.04, 1.0) : 0.04,
                                child: Container(
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            AppText(
                              '${dept.requests} req (${dept.days}d)',
                              fontSize: 10,
                              color: AppColors.textColorSecondary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: AppText(
                      '${dept.approved}',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: AppText(
                      '${dept.rejected}',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: AppText(
                      '${dept.pending}',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── 5. Detailed Leave Records (Data List) ───────────────────────
  Widget _buildLeaveRecordsSection(
    BuildContext context,
    List<AdminLeaveItemModel> records,
    LeaveReportsController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const AppText(
              'Leave Records',
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textColorPrimary,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: AppText(
                '${records.length} ${records.length == 1 ? 'Record' : 'Records'}',
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (records.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.slate200),
            ),
            child: Column(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.slate100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Iconsax.document_text, color: AppColors.slate400, size: 26),
                ),
                const SizedBox(height: 12),
                const AppText(
                  'No Leave Records Found',
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColorPrimary,
                ),
                const SizedBox(height: 4),
                const AppText(
                  'There are no leave requests matching the selected filters.',
                  fontSize: 12,
                  color: AppColors.textColorSecondary,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: records.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final leave = records[index];
              return _buildLeaveRecordCard(context, leave, controller);
            },
          ),
      ],
    );
  }

  Widget _buildLeaveRecordCard(
    BuildContext context,
    AdminLeaveItemModel leave,
    LeaveReportsController controller,
  ) {
    final statusColor = controller.getStatusColor(leave.status);
    final avatarUrl = leave.employee.fullAvatarUrl;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Avatar, Name, ID, Status
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Avatar
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 44,
                    height: 44,
                    color: AppColors.primaryLight,
                    child: avatarUrl != null && avatarUrl.isNotEmpty
                        ? Image.network(
                            avatarUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => _buildAvatarFallback(leave.employee.name),
                          )
                        : _buildAvatarFallback(leave.employee.name),
                  ),
                ),
                const SizedBox(width: 12),

                // Name & Designation
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: AppText(
                              leave.employee.name,
                              fontSize: 14.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textColorPrimary,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (leave.employee.employeeId.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppColors.slate100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                leave.employee.employeeId,
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.slate600),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${leave.employee.designation} • ${leave.employee.department}',
                        style: const TextStyle(fontSize: 11.5, color: AppColors.textColorSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 5.5, height: 5.5, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
                      const SizedBox(width: 4),
                      Text(
                        leave.status,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 1, color: AppColors.slate100),

          // Chips Row: Leave Type, Duration, Date Span
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _buildInfoBadge(Iconsax.calendar_tick, leave.leaveType, AppColors.primaryColor),
                _buildInfoBadge(Iconsax.clock, '${leave.duration} (${leave.sessionType})', AppColors.slate700),
                _buildInfoBadge(Iconsax.calendar_1, leave.formattedDates, AppColors.slate700),
              ],
            ),
          ),

          // Reason Box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.slate50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.slate200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Iconsax.note_text, size: 13, color: AppColors.primaryColor),
                      SizedBox(width: 5),
                      Text('Reason:', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.slate600)),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    leave.reason.isNotEmpty ? leave.reason : 'No reason provided.',
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, color: AppColors.textColorPrimary),
                  ),
                ],
              ),
            ),
          ),

          // Review Note / Note from Manager
          if (leave.rejectionReason != null && leave.rejectionReason!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: Row(
                children: [
                  const Icon(Iconsax.info_circle, size: 13, color: AppColors.slate400),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      'Review Note: ${leave.rejectionReason}',
                      style: const TextStyle(fontSize: 11.5, fontStyle: FontStyle.italic, color: AppColors.textColorSecondary),
                    ),
                  ),
                ],
              ),
            ),

          // Action Button
          Padding(
            padding: const EdgeInsets.only(left: 14, right: 14, top: 6, bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () {
                    Get.to(() => LeaveApprovalScreen(leaveId: leave.id));
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.2)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'View Request',
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward_rounded, size: 13, color: AppColors.primaryColor),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarFallback(String name) {
    String initials = 'EM';
    final parts = name.trim().split(' ');
    if (parts.isNotEmpty && parts[0].isNotEmpty) {
      initials = parts[0][0];
      if (parts.length > 1 && parts[1].isNotEmpty) {
        initials += parts[1][0];
      }
    }
    return Center(
      child: Text(
        initials.toUpperCase(),
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
      ),
    );
  }

  Widget _buildInfoBadge(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
      decoration: BoxDecoration(
        color: AppColors.slate100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }

  // ── Bottom Sheet Pickers ────────────────────────────────────────
  void _showDateRangePickerBottomSheet(BuildContext context, LeaveReportsController controller) {
    final now = DateTime.now();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.65,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: AppColors.slate300, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Iconsax.calendar_1, color: AppColors.primaryColor, size: 18),
                        SizedBox(width: 8),
                        AppText('Select Date Range', fontSize: 16, fontWeight: FontWeight.bold),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textColorSecondary, size: 20),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
              ),
              const Divider(color: AppColors.slate100, height: 1),
              Expanded(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: controller.dateRangePresets.length,
                  separatorBuilder: (context, index) => const Divider(color: AppColors.slate100, height: 1),
                  itemBuilder: (context, index) {
                    final preset = controller.dateRangePresets[index];
                    final isSelected = preset == controller.selectedDateRangePreset.value;

                    return InkWell(
                      onTap: () async {
                        Get.back();
                        if (preset == 'Custom Date Range...') {
                          final initial = controller.customDateRange.value ??
                              DateTimeRange(
                                start: now.subtract(const Duration(days: 30)),
                                end: now,
                              );
                          final safeInitial = DateTimeRange(
                            start: initial.start.isAfter(now) ? now : initial.start,
                            end: initial.end.isAfter(now) ? now : initial.end,
                          );
                          final picked = await showDateRangePicker(
                            context: context,
                            firstDate: DateTime(2022),
                            lastDate: now,
                            initialDateRange: safeInitial,
                            builder: (context, child) {
                              return Theme(
                                data: ThemeData.light().copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: AppColors.primaryColor,
                                    onPrimary: Colors.white,
                                    surface: Colors.white,
                                    onSurface: AppColors.textColorPrimary,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) {
                            controller.setDatePreset(preset, picked);
                          }
                        } else {
                          controller.setDatePreset(preset);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        color: isSelected ? AppColors.primaryLight.withValues(alpha: 0.5) : Colors.transparent,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AppText(
                              preset,
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? AppColors.primaryColor : AppColors.textColorPrimary,
                            ),
                            if (isSelected)
                              const Icon(Iconsax.tick_circle, color: AppColors.primaryColor, size: 18),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDepartmentPicker(BuildContext context, LeaveReportsController controller) {
    _showOptionsBottomSheet(
      context: context,
      title: 'Select Department',
      icon: Iconsax.building,
      items: controller.departmentOptions,
      selectedId: controller.selectedDepartmentId.value,
      onSelected: (opt) => controller.setDepartment(opt),
    );
  }

  void _showLeaveTypePicker(BuildContext context, LeaveReportsController controller) {
    _showOptionsBottomSheet(
      context: context,
      title: 'Select Leave Type',
      icon: Iconsax.edit_2,
      items: controller.leaveTypeOptions,
      selectedId: controller.selectedLeaveTypeId.value,
      onSelected: (opt) => controller.setLeaveType(opt),
    );
  }

  void _showStatusPicker(BuildContext context, LeaveReportsController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.5,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: AppColors.slate300, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Iconsax.menu_board, color: AppColors.primaryColor, size: 18),
                        SizedBox(width: 8),
                        AppText('Select Status', fontSize: 16, fontWeight: FontWeight.bold),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textColorSecondary, size: 20),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
              ),
              const Divider(color: AppColors.slate100, height: 1),
              Expanded(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: controller.statusOptions.length,
                  separatorBuilder: (context, index) => const Divider(color: AppColors.slate100, height: 1),
                  itemBuilder: (context, index) {
                    final item = controller.statusOptions[index];
                    final isSelected = (item == 'All Status' && controller.selectedStatus.value == 'all') ||
                        (item.toLowerCase() == controller.selectedStatus.value);

                    return InkWell(
                      onTap: () {
                        controller.setStatus(item);
                        Get.back();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        color: isSelected ? AppColors.primaryLight.withValues(alpha: 0.5) : Colors.transparent,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AppText(
                              item,
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? AppColors.primaryColor : AppColors.textColorPrimary,
                            ),
                            if (isSelected)
                              const Icon(Iconsax.tick_circle, color: AppColors.primaryColor, size: 18),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showOptionsBottomSheet({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<ReportFilterOption> items,
    required dynamic selectedId,
    required Function(ReportFilterOption) onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.65,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: AppColors.slate300, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(icon, color: AppColors.primaryColor, size: 18),
                        const SizedBox(width: 8),
                        AppText(title, fontSize: 16, fontWeight: FontWeight.bold),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textColorSecondary, size: 20),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
              ),
              const Divider(color: AppColors.slate100, height: 1),
              Expanded(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: items.length,
                  separatorBuilder: (context, index) => const Divider(color: AppColors.slate100, height: 1),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final isSelected = item.id?.toString() == selectedId?.toString();

                    return InkWell(
                      onTap: () {
                        onSelected(item);
                        Get.back();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        color: isSelected ? AppColors.primaryLight.withValues(alpha: 0.5) : Colors.transparent,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AppText(
                              item.name,
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? AppColors.primaryColor : AppColors.textColorPrimary,
                            ),
                            if (isSelected)
                              const Icon(Iconsax.tick_circle, color: AppColors.primaryColor, size: 18),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Dynamic Donut Chart Painter ──────────────────────────────────
class DynamicDonutChartPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;

  DynamicDonutChartPainter({required this.values, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2);
    const strokeWidth = 18.0;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final total = values.fold(0.0, (prev, elem) => prev + elem);

    if (total <= 0) {
      paint.color = AppColors.slate200;
      canvas.drawCircle(center, radius - strokeWidth / 2, paint);
      return;
    }

    double startAngle = -math.pi / 2;

    for (int i = 0; i < values.length; i++) {
      if (values[i] <= 0) continue;
      final sweepAngle = (values[i] / total) * 2 * math.pi;
      paint.color = colors[i % colors.length];

      const gap = 0.04;
      final actualSweep = sweepAngle > gap ? sweepAngle - gap : sweepAngle;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle,
        actualSweep,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant DynamicDonutChartPainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.colors != colors;
  }
}
