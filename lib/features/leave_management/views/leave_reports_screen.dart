import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import 'dart:math' as math;

class LeaveReportsScreen extends StatefulWidget {
  const LeaveReportsScreen({super.key});

  @override
  State<LeaveReportsScreen> createState() => _LeaveReportsScreenState();
}

class _LeaveReportsScreenState extends State<LeaveReportsScreen> {
  // Selected Filters
  String _selectedDateRange = '01 May 2025 - 31 May 2025';
  String _selectedDepartment = 'All Departments';
  String _selectedLeaveType = 'All Leave Types';
  String _selectedStatus = 'All Status';

  // Date Range state
  DateTimeRange? _customDateRange;

  // Filter options
  final List<String> _dateRangePresets = [
    '01 May 2025 - 31 May 2025',
    'Today',
    'This Week',
    'This Month',
    'Last Month',
    'This Quarter (Q2 2025)',
    'Year to Date (2025)',
    'All Time',
    'Custom Date Range...',
  ];

  final List<String> _departments = [
    'All Departments',
    'Design',
    'Development',
    'Marketing',
    'HR',
    'Sales',
  ];

  final List<String> _leaveTypes = [
    'All Leave Types',
    'Casual Leave',
    'Sick Leave',
    'Paid Leave',
    'Comp Off',
    'Other Leave',
  ];

  final List<String> _statuses = [
    'All Status',
    'Approved',
    'Rejected',
    'Pending',
  ];

  // Raw mock dataset (32 items matching base report values)
  final List<Map<String, dynamic>> _reportData = [
    // Design (9 total: 7 Appr, 1 Rej, 1 Pend)
    {'department': 'Design', 'type': 'Casual Leave', 'status': 'Approved', 'date': DateTime(2025, 5, 2)},
    {'department': 'Design', 'type': 'Casual Leave', 'status': 'Approved', 'date': DateTime(2025, 5, 8)},
    {'department': 'Design', 'type': 'Casual Leave', 'status': 'Pending', 'date': DateTime(2025, 5, 20)},
    {'department': 'Design', 'type': 'Sick Leave', 'status': 'Approved', 'date': DateTime(2025, 5, 11)},
    {'department': 'Design', 'type': 'Sick Leave', 'status': 'Rejected', 'date': DateTime(2025, 5, 18)},
    {'department': 'Design', 'type': 'Paid Leave', 'status': 'Approved', 'date': DateTime(2025, 5, 14)},
    {'department': 'Design', 'type': 'Paid Leave', 'status': 'Approved', 'date': DateTime(2025, 5, 22)},
    {'department': 'Design', 'type': 'Comp Off', 'status': 'Approved', 'date': DateTime(2025, 5, 25)},
    {'department': 'Design', 'type': 'Other Leave', 'status': 'Approved', 'date': DateTime(2025, 5, 28)},

    // Development (11 total: 8 Appr, 2 Rej, 1 Pend)
    {'department': 'Development', 'type': 'Casual Leave', 'status': 'Approved', 'date': DateTime(2025, 5, 3)},
    {'department': 'Development', 'type': 'Casual Leave', 'status': 'Approved', 'date': DateTime(2025, 5, 6)},
    {'department': 'Development', 'type': 'Casual Leave', 'status': 'Approved', 'date': DateTime(2025, 5, 15)},
    {'department': 'Development', 'type': 'Casual Leave', 'status': 'Approved', 'date': DateTime(2025, 5, 27)},
    {'department': 'Development', 'type': 'Casual Leave', 'status': 'Rejected', 'date': DateTime(2025, 5, 12)},
    {'department': 'Development', 'type': 'Sick Leave', 'status': 'Approved', 'date': DateTime(2025, 5, 4)},
    {'department': 'Development', 'type': 'Sick Leave', 'status': 'Approved', 'date': DateTime(2025, 5, 16)},
    {'department': 'Development', 'type': 'Sick Leave', 'status': 'Pending', 'date': DateTime(2025, 5, 21)},
    {'department': 'Development', 'type': 'Paid Leave', 'status': 'Approved', 'date': DateTime(2025, 5, 9)},
    {'department': 'Development', 'type': 'Paid Leave', 'status': 'Rejected', 'date': DateTime(2025, 5, 23)},
    {'department': 'Development', 'type': 'Comp Off', 'status': 'Approved', 'date': DateTime(2025, 5, 19)},

    // Marketing (5 total: 4 Appr, 1 Rej, 0 Pend)
    {'department': 'Marketing', 'type': 'Casual Leave', 'status': 'Approved', 'date': DateTime(2025, 5, 5)},
    {'department': 'Marketing', 'type': 'Casual Leave', 'status': 'Approved', 'date': DateTime(2025, 5, 17)},
    {'department': 'Marketing', 'type': 'Sick Leave', 'status': 'Rejected', 'date': DateTime(2025, 5, 13)},
    {'department': 'Marketing', 'type': 'Paid Leave', 'status': 'Approved', 'date': DateTime(2025, 5, 23)},
    {'department': 'Marketing', 'type': 'Comp Off', 'status': 'Approved', 'date': DateTime(2025, 5, 26)},

    // HR (4 total: 3 Appr, 0 Rej, 1 Pend)
    {'department': 'HR', 'type': 'Casual Leave', 'status': 'Approved', 'date': DateTime(2025, 5, 7)},
    {'department': 'HR', 'type': 'Sick Leave', 'status': 'Pending', 'date': DateTime(2025, 5, 19)},
    {'department': 'HR', 'type': 'Paid Leave', 'status': 'Approved', 'date': DateTime(2025, 5, 24)},
    {'department': 'HR', 'type': 'Comp Off', 'status': 'Approved', 'date': DateTime(2025, 5, 30)},

    // Sales (3 total: 2 Appr, 1 Rej, 0 Pend)
    {'department': 'Sales', 'type': 'Casual Leave', 'status': 'Approved', 'date': DateTime(2025, 5, 10)},
    {'department': 'Sales', 'type': 'Sick Leave', 'status': 'Rejected', 'date': DateTime(2025, 5, 21)},
    {'department': 'Sales', 'type': 'Other Leave', 'status': 'Approved', 'date': DateTime(2025, 5, 29)},
  ];

  bool get _hasActiveFilters {
    return _selectedDepartment != 'All Departments' ||
        _selectedLeaveType != 'All Leave Types' ||
        _selectedStatus != 'All Status' ||
        _selectedDateRange != '01 May 2025 - 31 May 2025';
  }

  void _resetAllFilters() {
    setState(() {
      _selectedDateRange = '01 May 2025 - 31 May 2025';
      _customDateRange = null;
      _selectedDepartment = 'All Departments';
      _selectedLeaveType = 'All Leave Types';
      _selectedStatus = 'All Status';
    });
  }

  // Filtered dataset
  List<Map<String, dynamic>> get _filteredData {
    return _reportData.where((item) {
      // Department
      if (_selectedDepartment != 'All Departments' && item['department'] != _selectedDepartment) {
        return false;
      }
      // Leave Type
      if (_selectedLeaveType != 'All Leave Types' && item['type'] != _selectedLeaveType) {
        return false;
      }
      // Status
      if (_selectedStatus != 'All Status' && item['status'] != _selectedStatus) {
        return false;
      }
      // Custom Date Range
      if (_customDateRange != null) {
        final date = item['date'] as DateTime;
        final start = _customDateRange!.start;
        final end = _customDateRange!.end.add(const Duration(days: 1));
        if (date.isBefore(start) || date.isAfter(end)) return false;
      }
      return true;
    }).toList();
  }

  // Bottom sheet picker for single selection
  void _showSingleSelectBottomSheet({
    required String title,
    required IconData icon,
    required List<String> items,
    required String selectedValue,
    required Function(String) onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
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
                decoration: BoxDecoration(
                  color: AppColors.slate300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(icon, color: AppColors.primaryColor, size: 20),
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
              const Divider(color: AppColors.borderColor, height: 1),
              Expanded(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: items.length,
                  separatorBuilder: (context, index) => const Divider(color: AppColors.borderColor, height: 1),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final isSelected = item == selectedValue;

                    return InkWell(
                      onTap: () {
                        onSelected(item);
                        Get.back();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                              const Icon(Iconsax.tick_circle, color: AppColors.primaryColor, size: 20),
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

  // Date Range bottom sheet picker
  void _showDateRangePickerBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
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
                decoration: BoxDecoration(
                  color: AppColors.slate300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Iconsax.calendar_1, color: AppColors.primaryColor, size: 20),
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
              const Divider(color: AppColors.borderColor, height: 1),
              Expanded(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _dateRangePresets.length,
                  separatorBuilder: (context, index) => const Divider(color: AppColors.borderColor, height: 1),
                  itemBuilder: (context, index) {
                    final preset = _dateRangePresets[index];
                    final isSelected = preset == _selectedDateRange;

                    return InkWell(
                      onTap: () async {
                        Get.back();
                        if (preset == 'Custom Date Range...') {
                          final picked = await showDateRangePicker(
                            context: context,
                            firstDate: DateTime(2024),
                            lastDate: DateTime(2026),
                            initialDateRange: _customDateRange ??
                                DateTimeRange(
                                  start: DateTime(2025, 5, 1),
                                  end: DateTime(2025, 5, 31),
                                ),
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
                            setState(() {
                              _customDateRange = picked;
                              _selectedDateRange =
                                  '${DateFormat('dd MMM yyyy').format(picked.start)} - ${DateFormat('dd MMM yyyy').format(picked.end)}';
                            });
                          }
                        } else {
                          setState(() {
                            _selectedDateRange = preset;
                            final now = DateTime.now();
                            if (preset == 'Today') {
                              _customDateRange = DateTimeRange(
                                start: DateTime(now.year, now.month, now.day),
                                end: DateTime(now.year, now.month, now.day),
                              );
                            } else if (preset == 'This Week') {
                              final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
                              _customDateRange = DateTimeRange(
                                start: DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
                                end: now,
                              );
                            } else if (preset == 'This Month') {
                              _customDateRange = DateTimeRange(
                                start: DateTime(now.year, now.month, 1),
                                end: DateTime(now.year, now.month + 1, 0),
                              );
                            } else if (preset == 'Last Month') {
                              _customDateRange = DateTimeRange(
                                start: DateTime(now.year, now.month - 1, 1),
                                end: DateTime(now.year, now.month, 0),
                              );
                            } else {
                              _customDateRange = null;
                            }
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        color: isSelected ? AppColors.primaryLight.withValues(alpha: 0.5) : Colors.transparent,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                if (preset == 'Custom Date Range...')
                                  const Padding(
                                    padding: EdgeInsets.only(right: 8.0),
                                    child: Icon(Iconsax.calendar_edit, size: 16, color: AppColors.primaryColor),
                                  ),
                                AppText(
                                  preset,
                                  fontSize: 14,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected ? AppColors.primaryColor : AppColors.textColorPrimary,
                                ),
                              ],
                            ),
                            if (isSelected)
                              const Icon(Iconsax.tick_circle, color: AppColors.primaryColor, size: 20),
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

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredData;
    final totalRequests = filtered.length;
    final approvedCount = filtered.where((e) => e['status'] == 'Approved').length;
    final rejectedCount = filtered.where((e) => e['status'] == 'Rejected').length;
    final pendingCount = filtered.where((e) => e['status'] == 'Pending').length;

    // Breakdown for Donut Chart
    final casualCount = filtered.where((e) => e['type'] == 'Casual Leave').length;
    final sickCount = filtered.where((e) => e['type'] == 'Sick Leave').length;
    final paidCount = filtered.where((e) => e['type'] == 'Paid Leave').length;
    final compCount = filtered.where((e) => e['type'] == 'Comp Off').length;
    final otherCount = filtered.where((e) => e['type'] == 'Other Leave').length;

    final casualPct = totalRequests > 0 ? (casualCount / totalRequests * 100) : 0.0;
    final sickPct = totalRequests > 0 ? (sickCount / totalRequests * 100) : 0.0;
    final paidPct = totalRequests > 0 ? (paidCount / totalRequests * 100) : 0.0;
    final compPct = totalRequests > 0 ? (compCount / totalRequests * 100) : 0.0;
    final otherPct = totalRequests > 0 ? (otherCount / totalRequests * 100) : 0.0;

    final chartValues = [casualPct, sickPct, paidPct, compPct, otherPct];
    final chartColors = [Colors.blue, Colors.orange, Colors.green, Colors.purple, Colors.pink];

    // Department Summary counts
    final deptList = ['Design', 'Development', 'Marketing', 'HR', 'Sales'];
    final Map<String, Map<String, int>> deptStats = {};
    int maxDeptTotal = 1;

    for (final dept in deptList) {
      final deptFiltered = filtered.where((e) => e['department'] == dept);
      final dTotal = deptFiltered.length;
      final dAppr = deptFiltered.where((e) => e['status'] == 'Approved').length;
      final dRej = deptFiltered.where((e) => e['status'] == 'Rejected').length;
      final dPend = deptFiltered.where((e) => e['status'] == 'Pending').length;

      deptStats[dept] = {
        'total': dTotal,
        'approved': dAppr,
        'rejected': dRej,
        'pending': dPend,
      };

      if (dTotal > maxDeptTotal) {
        maxDeptTotal = dTotal;
      }
    }

    final deptColors = {
      'Design': Colors.blue,
      'Development': Colors.green,
      'Marketing': Colors.purple,
      'HR': Colors.orange,
      'Sales': Colors.pink,
    };

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textColorPrimary),
          onPressed: () => Get.back(),
        ),
        title: const AppText('Leave Reports', fontSize: 18, fontWeight: FontWeight.bold),
        centerTitle: false,
        actions: [
          if (_hasActiveFilters)
            IconButton(
              icon: const Icon(Icons.refresh, color: AppColors.errorColor),
              tooltip: 'Reset Filters',
              onPressed: _resetAllFilters,
            ),
          IconButton(
            icon: const Icon(Iconsax.document_download, color: AppColors.textColorPrimary),
            onPressed: () {
              Get.snackbar(
                'Downloading Report',
                'Leave report for $_selectedDateRange is being downloaded.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppColors.textColorPrimary,
                colorText: Colors.white,
                duration: const Duration(seconds: 2),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Header & Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const AppText('Report Filters', fontSize: 14, fontWeight: FontWeight.bold),
                if (_hasActiveFilters)
                  GestureDetector(
                    onTap: _resetAllFilters,
                    child: const Row(
                      children: [
                        Icon(Icons.refresh, size: 14, color: AppColors.primaryColor),
                        SizedBox(width: 4),
                        AppText(
                          'Reset',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),

            // Top Filters Container (Interactive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderColor),
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
                  // 1. Date Range
                  _buildInteractiveFilterRow(
                    icon: Iconsax.calendar_1,
                    label: 'Date Range',
                    value: _selectedDateRange,
                    isFiltered: _selectedDateRange != '01 May 2025 - 31 May 2025',
                    onTap: _showDateRangePickerBottomSheet,
                  ),
                  _buildDivider(),

                  // 2. Department
                  _buildInteractiveFilterRow(
                    icon: Iconsax.building,
                    label: 'Department',
                    value: _selectedDepartment,
                    isFiltered: _selectedDepartment != 'All Departments',
                    onTap: () {
                      _showSingleSelectBottomSheet(
                        title: 'Select Department',
                        icon: Iconsax.building,
                        items: _departments,
                        selectedValue: _selectedDepartment,
                        onSelected: (val) => setState(() => _selectedDepartment = val),
                      );
                    },
                  ),
                  _buildDivider(),

                  // 3. Leave Type
                  _buildInteractiveFilterRow(
                    icon: Iconsax.edit_2,
                    label: 'Leave Type',
                    value: _selectedLeaveType,
                    isFiltered: _selectedLeaveType != 'All Leave Types',
                    onTap: () {
                      _showSingleSelectBottomSheet(
                        title: 'Select Leave Type',
                        icon: Iconsax.edit_2,
                        items: _leaveTypes,
                        selectedValue: _selectedLeaveType,
                        onSelected: (val) => setState(() => _selectedLeaveType = val),
                      );
                    },
                  ),
                  _buildDivider(),

                  // 4. Status
                  _buildInteractiveFilterRow(
                    icon: Iconsax.menu_board,
                    label: 'Status',
                    value: _selectedStatus,
                    isFiltered: _selectedStatus != 'All Status',
                    onTap: () {
                      _showSingleSelectBottomSheet(
                        title: 'Select Status',
                        icon: Iconsax.menu_board,
                        items: _statuses,
                        selectedValue: _selectedStatus,
                        onSelected: (val) => setState(() => _selectedStatus = val),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Stats Row
            Row(
              children: [
                Expanded(child: _buildStatCard('Total Requests', '$totalRequests', Colors.blue)),
                const SizedBox(width: 10),
                Expanded(child: _buildStatCard('Approved', '$approvedCount', Colors.green)),
                const SizedBox(width: 10),
                Expanded(child: _buildStatCard('Rejected', '$rejectedCount', Colors.red)),
                const SizedBox(width: 10),
                Expanded(child: _buildStatCard('Pending', '$pendingCount', Colors.orange)),
              ],
            ),

            const SizedBox(height: 24),

            // Chart Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: totalRequests == 0
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Column(
                          children: [
                            Icon(Iconsax.chart_2, size: 36, color: AppColors.slate300),
                            SizedBox(height: 8),
                            AppText('No records found for current filter', fontSize: 13, color: AppColors.textColorSecondary),
                          ],
                        ),
                      ),
                    )
                  : Row(
                      children: [
                        // Donut Chart
                        SizedBox(
                          width: 120,
                          height: 120,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CustomPaint(
                                size: const Size(120, 120),
                                painter: DynamicDonutChartPainter(
                                  values: chartValues,
                                  colors: chartColors,
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AppText('$totalRequests', fontSize: 24, fontWeight: FontWeight.bold),
                                  const AppText('Total', fontSize: 10, color: AppColors.textColorSecondary),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        // Legend
                        Expanded(
                          child: Column(
                            children: [
                              _buildChartLegend(Colors.blue, 'Casual Leave', '$casualCount (${casualPct.toStringAsFixed(1)}%)'),
                              _buildChartLegend(Colors.orange, 'Sick Leave', '$sickCount (${sickPct.toStringAsFixed(1)}%)'),
                              _buildChartLegend(Colors.green, 'Paid Leave', '$paidCount (${paidPct.toStringAsFixed(1)}%)'),
                              _buildChartLegend(Colors.purple, 'Comp Off', '$compCount (${compPct.toStringAsFixed(1)}%)'),
                              _buildChartLegend(Colors.pink, 'Other Leave', '$otherCount (${otherPct.toStringAsFixed(1)}%)'),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),

            const SizedBox(height: 24),

            // Department Summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const AppText('Department Summary', fontSize: 14, fontWeight: FontWeight.bold),
                if (_selectedDepartment != 'All Departments')
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: AppText(
                      _selectedDepartment,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderColor),
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
                  const Row(
                    children: [
                      Expanded(flex: 3, child: SizedBox()),
                      Expanded(child: AppText('Approved', fontSize: 10, color: AppColors.textColorSecondary, textAlign: TextAlign.center)),
                      Expanded(child: AppText('Rejected', fontSize: 10, color: AppColors.textColorSecondary, textAlign: TextAlign.center)),
                      Expanded(child: AppText('Pending', fontSize: 10, color: AppColors.textColorSecondary, textAlign: TextAlign.center)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...deptList
                      .where((d) => _selectedDepartment == 'All Departments' || _selectedDepartment == d)
                      .map((dept) {
                    final stats = deptStats[dept]!;
                    return _buildDepartmentRow(
                      dept,
                      stats['total']!,
                      stats['approved']!,
                      stats['rejected']!,
                      stats['pending']!,
                      deptColors[dept] ?? Colors.blue,
                      maxDeptTotal,
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveFilterRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isFiltered,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Icon(icon, color: isFiltered ? AppColors.primaryColor : AppColors.textColorSecondary, size: 18),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: AppText(
                label,
                fontSize: 12,
                fontWeight: isFiltered ? FontWeight.bold : FontWeight.normal,
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
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isFiltered ? AppColors.primaryColor : AppColors.textColorPrimary,
                        textAlign: TextAlign.right,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.keyboard_arrow_down, color: AppColors.textColorSecondary, size: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Divider(color: AppColors.borderColor, height: 1),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          AppText(label, fontSize: 10, color: AppColors.textColorSecondary, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),
          AppText(value, fontSize: 18, fontWeight: FontWeight.bold, color: color),
        ],
      ),
    );
  }

  Widget _buildChartLegend(Color color, String label, String value) {
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
          Expanded(child: AppText(label, fontSize: 11, color: AppColors.textColorSecondary)),
          AppText(value, fontSize: 11, fontWeight: FontWeight.w600),
        ],
      ),
    );
  }

  Widget _buildDepartmentRow(
    String name,
    int total,
    int approved,
    int rejected,
    int pending,
    Color color,
    int maxTotal,
  ) {
    double widthFactor = maxTotal > 0 ? (total / maxTotal) : 0.0;
    if (widthFactor > 1.0) widthFactor = 1.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(name, fontSize: 12, fontWeight: FontWeight.w600),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: widthFactor > 0 ? widthFactor : 0.02,
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: widthFactor > 0 ? color : AppColors.slate200,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    AppText(total.toString(), fontSize: 10, color: AppColors.textColorSecondary),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: AppText(
              approved.toString(),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.green,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: AppText(
              rejected.toString(),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.red,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: AppText(
              pending.toString(),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

// Dynamic Donut Chart Painter
class DynamicDonutChartPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;

  DynamicDonutChartPainter({required this.values, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2);
    const strokeWidth = 20.0;

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

    double startAngle = -math.pi / 2; // Top

    for (int i = 0; i < values.length; i++) {
      if (values[i] <= 0) continue;
      final sweepAngle = (values[i] / total) * 2 * math.pi;
      paint.color = colors[i];

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
