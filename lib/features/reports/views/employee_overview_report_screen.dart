import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/admin_reports_controller.dart';

class EmployeeOverviewReportScreen extends StatefulWidget {
  final String initialCategoryTab;

  const EmployeeOverviewReportScreen({
    super.key,
    required this.initialCategoryTab,
  });

  @override
  State<EmployeeOverviewReportScreen> createState() => _EmployeeOverviewReportScreenState();
}

class _EmployeeOverviewReportScreenState extends State<EmployeeOverviewReportScreen> {
  final controller = Get.find<AdminReportsController>();
  late String activeTab;

  @override
  void initState() {
    super.initState();
    // Map initialCategoryTab string parameter to actual tabs
    activeTab = widget.initialCategoryTab;
    if (!['Overview', 'Attendance', 'Payroll', 'Leave', 'Sales', 'Tasks'].contains(activeTab)) {
      activeTab = 'Overview';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
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
                size: 18,
              ),
              onPressed: () => Get.back(),
            ),
          ),
        ),
        title: const AppText(
          'Employee Overview',
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: Color(0xFF1E293B),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFF1E293B)),
            onPressed: () {},
          ),
        ],
        centerTitle: false,
      ),
      body: SafeArea(
        child: Obx(() {
          final employee = controller.selectedEmployee.value;
          if (employee == null) {
            return const Center(child: AppText('No employee selected.'));
          }

          return Column(
            children: [
              // ── EMPLOYEE HEADER CARD ──
              _buildEmployeeHeaderCard(employee),
              
              // ── SCROLLABLE TABS ROW ──
              _buildTabsBar(),

              // ── SELECTED TAB VIEW ──
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: _buildSelectedTabContent(employee),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  // ── HEADER CARD WIDGET ──
  Widget _buildEmployeeHeaderCard(AdminReportEmployee employee) {
    Color statusBg;
    Color statusText;
    if (employee.status == 'Active') {
      statusBg = const Color(0xFFD1FAE5);
      statusText = const Color(0xFF059669);
    } else if (employee.status == 'On Leave') {
      statusBg = const Color(0xFFFEF3C7);
      statusText = const Color(0xFFD97706);
    } else {
      statusBg = const Color(0xFFF1F5F9);
      statusText = const Color(0xFF475569);
    }

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: NetworkImage(employee.avatarUrl),
                fit: BoxFit.cover,
              ),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: AppText(
                        employee.name,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1E293B),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        employee.status,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: statusText,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                AppText(
                  employee.designation,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
                const SizedBox(height: 3),
                AppText(
                  'Emp ID: ${employee.employeeId}',
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF94A3B8),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── CUSTOM SCROLLABLE TABS ROW ──
  Widget _buildTabsBar() {
    final List<String> tabs = ['Overview', 'Attendance', 'Payroll', 'Leave', 'Sales', 'Tasks'];

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFF1F5F9)),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: tabs.map((tab) {
            final isSelected = activeTab == tab;
            return GestureDetector(
              onTap: () {
                setState(() {
                  activeTab = tab;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected ? const Color(0xFF2563EB) : Colors.transparent,
                      width: 2.5,
                    ),
                  ),
                ),
                child: Text(
                  tab,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF64748B),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ── CONDITIONAL RENDER ACCORDING TO TABS ──
  Widget _buildSelectedTabContent(AdminReportEmployee employee) {
    switch (activeTab) {
      case 'Attendance':
        return _buildAttendanceTab(employee);
      case 'Payroll':
        return _buildPayrollTab(employee);
      case 'Leave':
        return _buildLeaveTab(employee);
      case 'Sales':
        return _buildSalesTab(employee);
      case 'Tasks':
        return _buildTasksTab(employee);
      case 'Overview':
      default:
        return _buildOverviewTab(employee);
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // ── 1. OVERVIEW TAB VIEW ──
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildOverviewTab(AdminReportEmployee employee) {
    final formatCurrency = employee.totalSales >= 100000 
        ? '₹${(employee.totalSales/100000).toStringAsFixed(2)}L' 
        : '₹${employee.totalSales.toInt()}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const AppText(
              'Overview Summary',
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Color(0xFF475569),
            ),
            GestureDetector(
              onTap: () => _showMonthSelectionBottomSheet(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    AppText(controller.activeMonth.value, fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down, size: 14, color: Color(0xFF64748B)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Metrics Grid Row
        Row(
          children: [
            Expanded(
              child: _buildOverviewGridCard(
                'Present Days',
                '${employee.presentDays} / ${employee.totalWorkingDays}',
                Iconsax.calendar_tick,
                const Color(0xFF10B981),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildOverviewGridCard(
                'Total Leaves',
                '${employee.totalLeaves}',
                Iconsax.sun_1,
                const Color(0xFFF97316),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildOverviewGridCard(
                'Total Sales',
                formatCurrency,
                Iconsax.wallet,
                const Color(0xFF3B82F6),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildOverviewGridCard(
                'Leads Generated',
                '${employee.totalLeads}',
                Iconsax.filter,
                const Color(0xFF8B5CF6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Tasks Completed & Performance Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFEEF2FF)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AppText(
                    'Tasks Completed',
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                  ),
                  AppText(
                    '${employee.tasksCompleted} / ${employee.totalTasks}',
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF2563EB),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: employee.totalTasks > 0 ? (employee.tasksCompleted / employee.totalTasks) : 0,
                  backgroundColor: const Color(0xFFEFF6FF),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 16),
              
              // Performance Graphic / Level
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AppText(
                          'Performance Summary',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(height: 4),
                        AppText(
                          employee.performance,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF10B981),
                        ),
                      ],
                    ),
                  ),
                  
                  // Mini Performance graphic painter
                  SizedBox(
                    width: 70,
                    height: 35,
                    child: CustomPaint(
                      painter: _MiniSparklinePainter(color: const Color(0xFF10B981)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Recent Activities Timeline
        const AppText(
          'Recent Activities',
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: Color(0xFF475569),
        ),
        const SizedBox(height: 12),

        if (employee.recentActivities.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEEF2FF)),
            ),
            child: const Center(
              child: AppText(
                'No recent activity recorded.',
                fontSize: 11,
                color: Color(0xFF94A3B8),
              ),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFEEF2FF)),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: employee.recentActivities.length,
              separatorBuilder: (context, index) => const Divider(color: Color(0xFFF1F5F9), height: 20),
              itemBuilder: (context, index) {
                final activity = employee.recentActivities[index];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 3),
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2563EB),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            activity.title,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E293B),
                          ),
                          const SizedBox(height: 3),
                          AppText(
                            activity.time,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF94A3B8),
                          ),
                        ],
                      ),
                    ),
                    if (activity.meta.isNotEmpty)
                      AppText(
                        activity.meta,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF10B981),
                      ),
                  ],
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildOverviewGridCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEF2FF)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  value,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF1E293B),
                ),
                const SizedBox(height: 1),
                AppText(
                  label,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF94A3B8),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // ── 2. ATTENDANCE TAB VIEW ──
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildAttendanceTab(AdminReportEmployee employee) {
    // Days in May 2024 = 31.
    // Starts on Wednesday (dayOfWeek = 3)
    const int startOffset = 2; // Wednesday is 3rd column, offset is 2 spaces in grid

    // Dynamic calculated status
    int present = 0;
    int absent = 0;
    int lateArr = 0;
    int halfDay = 0;
    
    employee.attendanceCalendar.forEach((day, status) {
      if (status == 'Present') present++;
      if (status == 'Absent') absent++;
      if (status == 'Late') lateArr++;
      if (status == 'Half Day') halfDay++;
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Calendar Month Bar
        GestureDetector(
          onTap: () => _showMonthSelectionBottomSheet(context),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppText(
                controller.activeMonth.value,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1E293B),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down, size: 16, color: Color(0xFF64748B)),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Calendar Week Days labels
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _CalendarHeaderLabel('Mon'),
            _CalendarHeaderLabel('Tue'),
            _CalendarHeaderLabel('Wed'),
            _CalendarHeaderLabel('Thu'),
            _CalendarHeaderLabel('Fri'),
            _CalendarHeaderLabel('Sat'),
            _CalendarHeaderLabel('Sun'),
          ],
        ),
        const SizedBox(height: 8),

        // Grid Calendar Builder
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.0,
          ),
          itemCount: 31 + startOffset,
          itemBuilder: (context, index) {
            if (index < startOffset) {
              return const SizedBox();
            }
            final day = index - startOffset + 1;
            final status = employee.attendanceCalendar[day] ?? 'Present';
            return _buildCalendarDayCircle(day, status);
          },
        ),
        const SizedBox(height: 16),

        // Calendar color legend indicator row
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _LegendItem(color: Color(0xFF10B981), label: 'Present'),
            _LegendItem(color: Color(0xFFEF4444), label: 'Absent'),
            _LegendItem(color: Color(0xFFF59E0B), label: 'Late'),
            _LegendItem(color: Color(0xFF3B82F6), label: 'Half Day'),
          ],
        ),
        const SizedBox(height: 20),

        // Summary details card
        const AppText(
          'Summary',
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: Color(0xFF475569),
        ),
        const SizedBox(height: 10),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFEEF2FF)),
          ),
          child: Column(
            children: [
              _buildAttendanceSummaryRow('Total Working Days', '${employee.totalWorkingDays}'),
              const Divider(color: Color(0xFFF1F5F9)),
              _buildAttendanceSummaryRow('Days Present', '$present'),
              const Divider(color: Color(0xFFF1F5F9)),
              _buildAttendanceSummaryRow('Days Absent', '$absent'),
              const Divider(color: Color(0xFFF1F5F9)),
              _buildAttendanceSummaryRow('Late Arrivals', '$lateArr'),
              const Divider(color: Color(0xFFF1F5F9)),
              _buildAttendanceSummaryRow('Half Days', '$halfDay'),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Excel Export action button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Get.snackbar(
                'Success Export',
                'Attendance log exported to Excel sheet successfully! 📄',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: const Color(0xFF10B981),
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const AppText(
              'Export Attendance (Excel)',
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarDayCircle(int day, String status) {
    Color ringColor = Colors.transparent;
    Color ringFill = Colors.transparent;
    Color textColor = const Color(0xFF1E293B);

    if (status == 'Weekend') {
      textColor = const Color(0xFF94A3B8);
    } else if (status == 'Present') {
      ringFill = const Color(0xFF10B981).withValues(alpha: 0.12);
      ringColor = const Color(0xFF10B981).withValues(alpha: 0.25);
      textColor = const Color(0xFF047857);
    } else if (status == 'Absent') {
      ringFill = const Color(0xFFEF4444).withValues(alpha: 0.12);
      ringColor = const Color(0xFFEF4444).withValues(alpha: 0.25);
      textColor = const Color(0xFFB91C1C);
    } else if (status == 'Late') {
      ringFill = const Color(0xFFF59E0B).withValues(alpha: 0.12);
      ringColor = const Color(0xFFF59E0B).withValues(alpha: 0.25);
      textColor = const Color(0xFFB45309);
    } else if (status == 'Half Day') {
      ringFill = const Color(0xFF3B82F6).withValues(alpha: 0.12);
      ringColor = const Color(0xFF3B82F6).withValues(alpha: 0.25);
      textColor = const Color(0xFF1D4ED8);
    }

    return Container(
      decoration: BoxDecoration(
        color: ringFill,
        shape: BoxShape.circle,
        border: Border.all(color: ringColor, width: 1.5),
      ),
      child: Center(
        child: Text(
          '$day',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildAttendanceSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(
            label,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF64748B),
          ),
          AppText(
            value,
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF1E293B),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // ── 3. PAYROLL TAB VIEW ──
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildPayrollTab(AdminReportEmployee employee) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month Selector
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const AppText(
              'Salary Period',
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Color(0xFF475569),
            ),
            GestureDetector(
              onTap: () => _showMonthSelectionBottomSheet(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    AppText(controller.activeMonth.value, fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down, size: 14, color: Color(0xFF64748B)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Net Salary card
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2563EB).withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Net Salary',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '₹${_formatSalary(employee.netSalary.toInt())}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Iconsax.empty_wallet_change,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Earnings Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFEEF2FF)),
          ),
          child: Column(
            children: [
              const Row(
                children: [
                  Icon(Iconsax.wallet_3, color: Color(0xFF10B981), size: 16),
                  SizedBox(width: 8),
                  AppText(
                    'EARNINGS',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF10B981),
                    letterSpacing: 0.8,
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Divider(color: Color(0xFFF1F5F9)),
              ),
              _buildPayrollItemRow('Basic Salary', employee.basicSalary),
              _buildPayrollItemRow('HRA', employee.hra),
              _buildPayrollItemRow('Conveyance', employee.conveyance),
              _buildPayrollItemRow('Performance Bonus', employee.performanceBonus),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Divider(color: Color(0xFFF1F5F9)),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AppText('Total Earnings', fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
                  AppText('₹${_formatSalary(employee.grossEarnings.toInt())}', fontSize: 13.5, fontWeight: FontWeight.w900, color: const Color(0xFF1E293B)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Deductions Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFEEF2FF)),
          ),
          child: Column(
            children: [
              const Row(
                children: [
                  Icon(Iconsax.card_remove, color: Color(0xFFEF4444), size: 16),
                  SizedBox(width: 8),
                  AppText(
                    'DEDUCTIONS',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFEF4444),
                    letterSpacing: 0.8,
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Divider(color: Color(0xFFF1F5F9)),
              ),
              _buildPayrollItemRow('TDS (Tax)', employee.tds),
              _buildPayrollItemRow('Provident Fund (PF)', employee.pf),
              _buildPayrollItemRow('ESI', employee.esi),
              _buildPayrollItemRow('Other Deductions', employee.otherDeductions),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Divider(color: Color(0xFFF1F5F9)),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AppText('Total Deductions', fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
                  AppText('₹${_formatSalary(employee.totalDeductions.toInt())}', fontSize: 13.5, fontWeight: FontWeight.w900, color: const Color(0xFFEF4444)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Download Payslip button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Get.snackbar(
                'Success Download',
                'Payslip PDF download initialized! 💾',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: const Color(0xFF10B981),
                colorText: Colors.white,
              );
            },
            icon: const Icon(Iconsax.document_download, color: Colors.white, size: 18),
            label: const AppText(
              'Download Payslip (PDF)',
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPayrollItemRow(String label, double val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(
            label,
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF64748B),
          ),
          AppText(
            '₹${_formatSalary(val.toInt())}',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E293B),
          ),
        ],
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

  // ──────────────────────────────────────────────────────────────────────────
  // ── 4. LEAVE TAB VIEW ──
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildLeaveTab(AdminReportEmployee employee) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Balance Title
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const AppText(
              'Leave Balance',
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Color(0xFF475569),
            ),
            GestureDetector(
              onTap: () => _showMonthSelectionBottomSheet(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    AppText(controller.activeMonth.value, fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down, size: 14, color: Color(0xFF64748B)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Leave Balance row cards
        Row(
          children: [
            Expanded(
              child: _buildLeaveProgressCard(
                'Casual Leave',
                employee.casualLeaveUsed,
                employee.casualLeaveTotal,
                const Color(0xFF3B82F6),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildLeaveProgressCard(
                'Sick Leave',
                employee.sickLeaveUsed,
                employee.sickLeaveTotal,
                const Color(0xFFF59E0B),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildLeaveProgressCard(
                'Earned Leave',
                employee.earnedLeaveUsed,
                employee.earnedLeaveTotal,
                const Color(0xFF10B981),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Leave History List
        const AppText(
          'Leave History',
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: Color(0xFF475569),
        ),
        const SizedBox(height: 12),

        if (employee.leaveHistory.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEEF2FF)),
            ),
            child: const Center(
              child: AppText(
                'No leaves requested in this period.',
                fontSize: 11,
                color: Color(0xFF94A3B8),
              ),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFEEF2FF)),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: employee.leaveHistory.length,
              separatorBuilder: (context, index) => const Divider(color: Color(0xFFF1F5F9), height: 16),
              itemBuilder: (context, index) {
                final leave = employee.leaveHistory[index];
                
                Color statusBg;
                Color statusText;
                if (leave.status == 'Approved') {
                  statusBg = const Color(0xFFD1FAE5);
                  statusText = const Color(0xFF059669);
                } else if (leave.status == 'Rejected') {
                  statusBg = const Color(0xFFFEE2E2);
                  statusText = const Color(0xFFDC2626);
                } else {
                  statusBg = const Color(0xFFFEF3C7);
                  statusText = const Color(0xFFD97706);
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              leave.date,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1E293B),
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                AppText(
                                  leave.type,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF64748B),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  width: 4,
                                  height: 4,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFCBD5E1),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                AppText(
                                  leave.duration,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF64748B),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          leave.status,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: statusText,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildLeaveProgressCard(String label, int used, int total, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEF2FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: Color(0xFF64748B),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$used',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
              Text(
                ' / $total',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: total > 0 ? (used / total) : 0,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // ── 5. SALES & LEADS TAB VIEW ──
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildSalesTab(AdminReportEmployee employee) {
    if (employee.leadsCount == 0 && employee.totalSales == 0) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFEEF2FF)),
        ),
        child: const Column(
          children: [
            Icon(Iconsax.filter_remove, size: 40, color: Color(0xFFCBD5E1)),
            SizedBox(height: 10),
            AppText(
              'No sales / leads logs for this designation.',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF94A3B8),
            ),
          ],
        ),
      );
    }

    final formatSales = employee.totalSales >= 100000 
        ? '₹${(employee.totalSales/100000).toStringAsFixed(2)}L' 
        : '₹${employee.totalSales.toInt()}';
        
    final formatTarget = employee.salesTarget >= 100000 
        ? '₹${(employee.salesTarget/100000).toStringAsFixed(2)}L' 
        : '₹${employee.salesTarget.toInt()}';

    final targetProgress = employee.salesTarget > 0 ? (employee.totalSales / employee.salesTarget) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dropdown period
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const AppText(
              'Sales Performance',
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Color(0xFF475569),
            ),
            GestureDetector(
              onTap: () => _showMonthSelectionBottomSheet(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    AppText(controller.activeMonth.value, fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down, size: 14, color: Color(0xFF64748B)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Statistics blocks row
        Row(
          children: [
            Expanded(
              child: _buildSalesStatsCell('Leads', '${employee.leadsCount}', const Color(0xFF3B82F6)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildSalesStatsCell('Converted', '${employee.convertedLeadsCount}', const Color(0xFF10B981)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildSalesStatsCell('Conversion %', '${employee.conversionRate.toStringAsFixed(1)}%', const Color(0xFF8B5CF6)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildSalesStatsCell('Total Sales', formatSales, const Color(0xFFF97316)),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Leads Overview Circular chart Donut Representation
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFEEF2FF)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppText(
                'Leads Overview',
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E293B),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  // Circular ring graphic
                  SizedBox(
                    width: 90,
                    height: 90,
                    child: CustomPaint(
                      painter: _DonutChartPainter(
                        slices: employee.leadsOverview,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${employee.leadsCount}',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
                            ),
                            const Text(
                              'Total',
                              style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  
                  // Legend labels
                  Expanded(
                    child: Column(
                      children: employee.leadsOverview.entries.map((entry) {
                        Color col;
                        if (entry.key == 'New') col = const Color(0xFF3B82F6);
                        else if (entry.key == 'Contacted') col = const Color(0xFFF59E0B);
                        else if (entry.key == 'Converted') col = const Color(0xFF10B981);
                        else col = const Color(0xFFEF4444);

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3.5),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(color: col, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 10),
                              AppText(
                                entry.key,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF64748B),
                              ),
                              const Spacer(),
                              AppText(
                                '${entry.value}',
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF1E293B),
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
        ),
        const SizedBox(height: 16),

        // Sales Target Summary Bar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFEEF2FF)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppText(
                'Sales Summary',
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E293B),
              ),
              const SizedBox(height: 14),
              _buildSalesSummaryRow('Total Sales', formatSales),
              const SizedBox(height: 8),
              _buildSalesSummaryRow('Target', formatTarget),
              const SizedBox(height: 8),
              _buildSalesSummaryRow('Achievement', '${(targetProgress * 100).toStringAsFixed(0)}%'),
              const SizedBox(height: 12),
              
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: targetProgress,
                  backgroundColor: const Color(0xFFEFF6FF),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Top Products list
        if (employee.topProducts.isNotEmpty) ...[
          const AppText(
            'Top Products / Services',
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: Color(0xFF475569),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFEEF2FF)),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: employee.topProducts.length,
              separatorBuilder: (context, index) => const Divider(color: Color(0xFFF1F5F9), height: 16),
              itemBuilder: (context, index) {
                final product = employee.topProducts[index];
                final val = product['value'] as double;
                final formatVal = val >= 100000 
                    ? '₹${(val/100000).toStringAsFixed(2)}L' 
                    : '₹${val.toInt()}';

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppText(
                      product['name'] as String,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                    ),
                    AppText(
                      formatVal,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF1E293B),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSalesStatsCell(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEF2FF)),
      ),
      child: Column(
        children: [
          AppText(
            label,
            fontSize: 8.5,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF94A3B8),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          AppText(
            value,
            fontSize: 12.5,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ],
      ),
    );
  }

  Widget _buildSalesSummaryRow(String label, String val) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText(
          label,
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF64748B),
        ),
        AppText(
          val,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF1E293B),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // ── 6. TASKS & PROJECTS TAB VIEW ──
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildTasksTab(AdminReportEmployee employee) {
    if (employee.projects.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFEEF2FF)),
        ),
        child: const Column(
          children: [
            Icon(Iconsax.task_square, size: 40, color: Color(0xFFCBD5E1)),
            SizedBox(height: 10),
            AppText(
              'No active projects or tasks allocated.',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF94A3B8),
            ),
          ],
        ),
      );
    }

    int totalProjs = employee.projects.length;
    int completedProjs = employee.projects.where((p) => p.status == 'Completed').length;
    int inProgressProjs = employee.projects.where((p) => p.status == 'In Progress').length;
    int holdProjs = employee.projects.where((p) => p.status == 'On Hold').length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const AppText(
              'Project Tracker',
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Color(0xFF475569),
            ),
            GestureDetector(
              onTap: () => _showMonthSelectionBottomSheet(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    AppText(controller.activeMonth.value, fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down, size: 14, color: Color(0xFF64748B)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Summary totals card
        Row(
          children: [
            Expanded(child: _buildSalesStatsCell('Total Projects', '$totalProjs', const Color(0xFF2563EB))),
            const SizedBox(width: 6),
            Expanded(child: _buildSalesStatsCell('Completed', '$completedProjs', const Color(0xFF10B981))),
            const SizedBox(width: 6),
            Expanded(child: _buildSalesStatsCell('In Progress', '$inProgressProjs', const Color(0xFFF97316))),
            const SizedBox(width: 6),
            Expanded(child: _buildSalesStatsCell('On Hold', '$holdProjs', const Color(0xFFEF4444))),
          ],
        ),
        const SizedBox(height: 20),

        // Projects List title
        const AppText(
          'Projects',
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: Color(0xFF475569),
        ),
        const SizedBox(height: 12),

        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: employee.projects.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final project = employee.projects[index];
            
            Color statusBg;
            Color statusText;
            if (project.status == 'Completed') {
              statusBg = const Color(0xFFD1FAE5);
              statusText = const Color(0xFF059669);
            } else if (project.status == 'On Hold') {
              statusBg = const Color(0xFFFEE2E2);
              statusText = const Color(0xFFDC2626);
            } else {
              statusBg = const Color(0xFFEFF6FF);
              statusText = const Color(0xFF2563EB);
            }

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFEEF2FF)),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    if (project.tasksBreakdown.isNotEmpty) {
                      _showProjectTasksBottomSheet(project);
                    } else {
                      Get.snackbar(
                        project.name,
                        'No detailed task breakdowns listed for this project archive.',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: const Color(0xFF1E293B),
                        colorText: Colors.white,
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: AppText(
                                project.name,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF1E293B),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: statusBg,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                project.status,
                                style: TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w800,
                                  color: statusText,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Progress ${project.progress}%',
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                            ),
                            if (project.tasksBreakdown.isNotEmpty)
                              const Row(
                                children: [
                                  Text(
                                    'View Tasks',
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF2563EB)),
                                  ),
                                  SizedBox(width: 2),
                                  Icon(Icons.keyboard_arrow_right, size: 12, color: Color(0xFF2563EB)),
                                ],
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        
                        // Progress bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: project.progress / 100.0,
                            backgroundColor: const Color(0xFFF1F5F9),
                            valueColor: AlwaysStoppedAnimation<Color>(statusText),
                            minHeight: 4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // Project details tasks breakdown sheet
  void _showProjectTasksBottomSheet(AdminProjectReport project) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: AppText(
                    '${project.name} Tasks',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const Divider(color: Color(0xFFF1F5F9), height: 12),
            const SizedBox(height: 10),

            ListView.separated(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: project.tasksBreakdown.length,
              separatorBuilder: (context, index) => const Divider(color: Color(0xFFF1F5F9), height: 16),
              itemBuilder: (context, index) {
                final task = project.tasksBreakdown[index];
                
                Color statusColor;
                if (task.status == 'Completed') {
                  statusColor = const Color(0xFF10B981);
                } else if (task.status == 'In Progress') {
                  statusColor = const Color(0xFF3B82F6);
                } else {
                  statusColor = const Color(0xFF94A3B8);
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: AppText(
                              task.title,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1E293B),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              task.status,
                              style: TextStyle(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w800,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Due: ${task.dueDate}',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)),
                          ),
                          Text(
                            '${task.progress}%',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showMonthSelectionBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const AppText(
                  'Select Report Month',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const Divider(color: Color(0xFFF1F5F9), height: 12),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.availableMonths.length,
              itemBuilder: (context, index) {
                final month = controller.availableMonths[index];
                final isSelected = controller.activeMonth.value == month;

                return InkWell(
                  onTap: () {
                    controller.changeActiveMonth(month);
                    Get.back();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFEFF6FF) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AppText(
                          month,
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF1E293B),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle_rounded,
                            color: Color(0xFF2563EB),
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────
// ── CUSTOM PAINTERS ──
// ──────────────────────────────────────────────────────────────────────────

// Mini Sparkline Painter for Overview tab
class _MiniSparklinePainter extends CustomPainter {
  final Color color;

  const _MiniSparklinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height * 0.7);
    path.quadraticBezierTo(
      size.width * 0.25, size.height * 0.6,
      size.width * 0.5, size.height * 0.3,
    );
    path.quadraticBezierTo(
      size.width * 0.75, size.height * 0.1,
      size.width, size.height * 0.15,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Donut Chart Painter for Sales tab
class _DonutChartPainter extends CustomPainter {
  final Map<String, int> slices;

  const _DonutChartPainter({required this.slices});

  @override
  void paint(Canvas canvas, Size size) {
    final double total = slices.values.fold(0, (sum, val) => sum + val);
    if (total == 0) return;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10.0
      ..strokeCap = StrokeCap.butt;

    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: (size.width - paint.strokeWidth) / 2,
    );

    double startAngle = -3.14 / 2; // Start from top
    slices.forEach((status, value) {
      final sweepAngle = (value / total) * 2 * 3.14159;

      if (status == 'New') paint.color = const Color(0xFF3B82F6);
      else if (status == 'Contacted') paint.color = const Color(0xFFF59E0B);
      else if (status == 'Converted') paint.color = const Color(0xFF10B981);
      else paint.color = const Color(0xFFEF4444);

      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ──────────────────────────────────────────────────────────────────────────
// ── HELPER UTILITY WIDGETS ──
// ──────────────────────────────────────────────────────────────────────────

class _CalendarHeaderLabel extends StatelessWidget {
  final String text;

  const _CalendarHeaderLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      child: Center(
        child: AppText(
          text,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF94A3B8),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        AppText(
          label,
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF64748B),
        ),
      ],
    );
  }
}
