import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../bindings/admin_leave_binding.dart';
import '../controllers/admin_leave_controller.dart';
import '../models/admin_leave_model.dart';
import 'leave_approval_screen.dart';

class LeaveRequestsScreen extends StatefulWidget {
  const LeaveRequestsScreen({super.key});

  @override
  State<LeaveRequestsScreen> createState() => _LeaveRequestsScreenState();
}

class _LeaveRequestsScreenState extends State<LeaveRequestsScreen> {
  late final AdminLeaveController controller;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<AdminLeaveController>()) {
      AdminLeaveBinding().dependencies();
    }
    controller = Get.find<AdminLeaveController>();
  }

  void _showFilterBottomSheet() {
    FilterItemOption tempDepartment = controller.departmentOptions.firstWhere(
      (opt) => opt.id?.toString() == controller.selectedDepartmentId.value?.toString(),
      orElse: () => controller.departmentOptions.isNotEmpty
          ? controller.departmentOptions.first
          : FilterItemOption(id: null, name: 'All'),
    );

    FilterItemOption tempLeaveType = controller.leaveTypeOptions.firstWhere(
      (opt) => opt.id?.toString() == controller.selectedLeaveTypeId.value?.toString(),
      orElse: () => controller.leaveTypeOptions.isNotEmpty
          ? controller.leaveTypeOptions.first
          : FilterItemOption(id: null, name: 'All'),
    );

    String tempRole = controller.selectedRole.value;
    String tempDesignation = controller.selectedDesignation.value;
    String tempStatus = controller.selectedStatus.value;
    String tempDatePreset = controller.selectedDatePreset.value;
    DateTimeRange? tempDateRange = controller.selectedDateRange.value;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // Handle Bar & Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: AppColors.borderColor)),
                    ),
                    child: Column(
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: AppColors.slate300,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Iconsax.filter_edit, color: AppColors.primaryColor, size: 22),
                                SizedBox(width: 10),
                                AppText(
                                  'Filter Leave Requests',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textColorPrimary,
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: () {
                                setSheetState(() {
                                  tempDepartment = controller.departmentOptions.first;
                                  tempLeaveType = controller.leaveTypeOptions.first;
                                  tempRole = 'All';
                                  tempDesignation = 'All';
                                  tempStatus = 'All';
                                  tempDatePreset = 'All Time';
                                  tempDateRange = null;
                                });
                              },
                              child: const AppText(
                                'Reset',
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.errorColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Filter Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Status Filter
                          _buildSectionTitle(Iconsax.status, 'Request Status'),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: ['All', 'Pending', 'Approved', 'Rejected'].map((status) {
                              final isSel = tempStatus.toLowerCase() == status.toLowerCase();
                              Color chipColor = AppColors.primaryColor;
                              if (status == 'Pending') chipColor = Colors.orange;
                              if (status == 'Approved') chipColor = Colors.green;
                              if (status == 'Rejected') chipColor = Colors.red;

                              return ChoiceChip(
                                label: Text(status),
                                selected: isSel,
                                onSelected: (sel) {
                                  setSheetState(() => tempStatus = status);
                                },
                                selectedColor: chipColor.withValues(alpha: 0.15),
                                backgroundColor: AppColors.slate50,
                                labelStyle: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                                  color: isSel ? chipColor : AppColors.textColorSecondary,
                                ),
                                side: BorderSide(
                                  color: isSel ? chipColor : AppColors.borderColor,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 20),

                          // 2. Department Filter
                          _buildSectionTitle(Iconsax.building, 'Department'),
                          const SizedBox(height: 8),
                          _buildOptionDropdown(
                            value: tempDepartment,
                            items: controller.departmentOptions,
                            onChanged: (val) {
                              if (val != null) setSheetState(() => tempDepartment = val);
                            },
                          ),

                          const SizedBox(height: 20),

                          // 3. Leave Type Filter
                          _buildSectionTitle(Iconsax.calendar_tick, 'Leave Type'),
                          const SizedBox(height: 8),
                          _buildOptionDropdown(
                            value: tempLeaveType,
                            items: controller.leaveTypeOptions,
                            onChanged: (val) {
                              if (val != null) setSheetState(() => tempLeaveType = val);
                            },
                          ),

                          const SizedBox(height: 20),

                          // 4. Designation Filter
                          _buildSectionTitle(Iconsax.briefcase, 'Designation'),
                          const SizedBox(height: 8),
                          _buildFilterDropdown<String>(
                            value: tempDesignation,
                            items: controller.designations,
                            onChanged: (val) {
                              if (val != null) setSheetState(() => tempDesignation = val);
                            },
                          ),

                          const SizedBox(height: 20),

                          // 5. Role Filter
                          _buildSectionTitle(Iconsax.user_tag, 'Role'),
                          const SizedBox(height: 8),
                          _buildFilterDropdown<String>(
                            value: tempRole,
                            items: controller.roles,
                            onChanged: (val) {
                              if (val != null) setSheetState(() => tempRole = val);
                            },
                          ),

                          const SizedBox(height: 20),

                          // 6. Date Range Presets
                          _buildSectionTitle(Iconsax.calendar_1, 'Date Filter'),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: controller.datePresets.map((preset) {
                              final isSel = tempDatePreset == preset;
                              return ChoiceChip(
                                label: Text(preset),
                                selected: isSel,
                                onSelected: (sel) async {
                                  if (preset == 'Custom Range') {
                                    final now = DateTime.now();
                                    final picked = await showDateRangePicker(
                                      context: context,
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime(2030),
                                      initialDateRange: tempDateRange ??
                                          DateTimeRange(
                                            start: now.subtract(const Duration(days: 7)),
                                            end: now,
                                          ),
                                    );
                                    if (picked != null) {
                                      setSheetState(() {
                                        tempDatePreset = preset;
                                        tempDateRange = picked;
                                      });
                                    }
                                  } else {
                                    setSheetState(() {
                                      tempDatePreset = preset;
                                      final now = DateTime.now();
                                      if (preset == 'Today') {
                                        tempDateRange = DateTimeRange(start: now, end: now);
                                      } else if (preset == 'This Week') {
                                        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
                                        tempDateRange = DateTimeRange(
                                          start: startOfWeek,
                                          end: startOfWeek.add(const Duration(days: 6)),
                                        );
                                      } else if (preset == 'This Month') {
                                        final startOfMonth = DateTime(now.year, now.month, 1);
                                        final endOfMonth = DateTime(now.year, now.month + 1, 0);
                                        tempDateRange = DateTimeRange(start: startOfMonth, end: endOfMonth);
                                      } else if (preset == 'Last Month') {
                                        final startOfLastMonth = DateTime(now.year, now.month - 1, 1);
                                        final endOfLastMonth = DateTime(now.year, now.month, 0);
                                        tempDateRange = DateTimeRange(start: startOfLastMonth, end: endOfLastMonth);
                                      } else {
                                        tempDateRange = null;
                                      }
                                    });
                                  }
                                },
                                selectedColor: AppColors.primaryLight,
                                backgroundColor: AppColors.slate50,
                                labelStyle: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                                  color: isSel ? AppColors.primaryColor : AppColors.textColorSecondary,
                                ),
                                side: BorderSide(
                                  color: isSel ? AppColors.primaryColor : AppColors.borderColor,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Action Buttons
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(top: BorderSide(color: AppColors.borderColor)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Get.back(),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(color: AppColors.borderColor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const AppText(
                              'Cancel',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textColorSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Get.back();
                              controller.applyFilters(
                                status: tempStatus,
                                departmentId: tempDepartment.id,
                                departmentName: tempDepartment.name,
                                leaveTypeId: tempLeaveType.id,
                                leaveTypeName: tempLeaveType.name,
                                datePreset: tempDatePreset,
                                dateRange: tempDateRange,
                                role: tempRole,
                                designation: tempDesignation,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const AppText(
                              'Apply Filters',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildOptionDropdown({
    required FilterItemOption value,
    required List<FilterItemOption> items,
    required ValueChanged<FilterItemOption?> onChanged,
  }) {
    final validItems = items.any((item) => item.id?.toString() == value.id?.toString())
        ? items
        : [value, ...items];

    final matchedValue = validItems.firstWhere(
      (item) => item.id?.toString() == value.id?.toString(),
      orElse: () => validItems.first,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.slate50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<FilterItemOption>(
          value: matchedValue,
          isExpanded: true,
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textColorSecondary, size: 20),
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textColorPrimary),
          onChanged: onChanged,
          items: validItems.map((FilterItemOption item) {
            final isSelected = item.id?.toString() == matchedValue.id?.toString();
            return DropdownMenuItem<FilterItemOption>(
              value: item,
              child: AppText(
                item.name,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.primaryColor : AppColors.textColorPrimary,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildFilterDropdown<T>({
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
  }) {
    final validItems = items.contains(value) ? items : [value, ...items];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.slate50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textColorSecondary, size: 20),
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textColorPrimary),
          onChanged: onChanged,
          items: validItems.map((T item) {
            final isSelected = item == value;
            return DropdownMenuItem<T>(
              value: item,
              child: AppText(
                item.toString(),
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.primaryColor : AppColors.textColorPrimary,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primaryColor),
        const SizedBox(width: 6),
        AppText(
          title,
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: AppColors.textColorPrimary,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_outlined, color: AppColors.textColorPrimary),
          onPressed: () => Get.back(),
        ),
        title: const AppText('Leave Requests', fontSize: 18, fontWeight: FontWeight.bold),
        centerTitle: false,
        actions: [
          // Filter Icon with active indicator & count
          Obx(() {
            final hasFilters = controller.hasActiveFilters;
            final count = controller.activeFilterCount;
            return Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    hasFilters ? Iconsax.filter_edit : Iconsax.filter,
                    color: hasFilters ? AppColors.primaryColor : AppColors.textColorPrimary,
                  ),
                  onPressed: _showFilterBottomSheet,
                ),
                if (hasFilters)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Center(
                        child: Text(
                          '$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          }),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs (Status)
          Obx(() {
            final currentStatus = controller.selectedStatus.value;
            final filterTabs = [
              {'label': 'All', 'count': controller.allCount, 'color': AppColors.primaryColor},
              {'label': 'Pending', 'count': controller.pendingCount, 'color': Colors.orange},
              {'label': 'Approved', 'count': controller.approvedCount, 'color': Colors.green},
              {'label': 'Rejected', 'count': controller.rejectedCount, 'color': Colors.red},
            ];

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: filterTabs.map((filter) {
                  final label = filter['label'] as String;
                  final isSelected = currentStatus.toLowerCase() == label.toLowerCase();
                  final count = filter['count'] as int;
                  final color = filter['color'] as Color;

                  return GestureDetector(
                    onTap: () => controller.setStatusTab(label),
                    child: Container(
                      margin: const EdgeInsets.only(right: 16),
                      padding: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: isSelected ? AppColors.primaryColor : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          AppText(
                            label,
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? AppColors.textColorPrimary : AppColors.textColorSecondary,
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: isSelected ? 0.2 : 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: AppText(
                              '$count',
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          }),

          const SizedBox(height: 12),

          // Search Bar & Filter trigger button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderColor),
                    ),
                    child: TextField(
                      controller: controller.searchController,
                      onChanged: controller.onSearchQueryChanged,
                      style: const TextStyle(fontSize: 14, color: AppColors.textColorPrimary),
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        isDense: true,
                        filled: false,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        prefixIcon: const Icon(
                          Iconsax.search_normal,
                          color: AppColors.textColorSecondary,
                          size: 18,
                        ),
                        hintText: 'Search by employee name...',
                        hintStyle: const TextStyle(color: AppColors.textColorHint, fontSize: 13),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close, size: 16, color: AppColors.textColorSecondary),
                                splashRadius: 18,
                                onPressed: () {
                                  controller.searchController.clear();
                                  controller.onSearchQueryChanged('');
                                },
                              )
                            : const SizedBox.shrink()),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Quick filter button
                Obx(() {
                  final hasFilters = controller.hasActiveFilters;
                  return InkWell(
                    onTap: _showFilterBottomSheet,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: hasFilters ? AppColors.primaryColor : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: hasFilters ? AppColors.primaryColor : AppColors.borderColor,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Iconsax.setting_4,
                          color: hasFilters ? Colors.white : AppColors.textColorPrimary,
                          size: 20,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          // Active Filter Chips Row
          Obx(() {
            if (!controller.hasActiveFilters) return const SizedBox.shrink();

            return Column(
              children: [
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    height: 32,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        // Clear All Chip
                        GestureDetector(
                          onTap: controller.resetAllFilters,
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.errorColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.errorColor.withValues(alpha: 0.3)),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.refresh, size: 14, color: AppColors.errorColor),
                                SizedBox(width: 4),
                                AppText('Clear All', fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.errorColor),
                              ],
                            ),
                          ),
                        ),

                        // Department Chip
                        if (controller.selectedDepartmentId.value != null || controller.selectedDepartmentName.value != 'All')
                          _buildActiveFilterPill(
                            'Dept: ${controller.selectedDepartmentName.value}',
                            controller.removeDepartmentFilter,
                          ),

                        // Leave Type Chip
                        if (controller.selectedLeaveTypeId.value != null || controller.selectedLeaveTypeName.value != 'All')
                          _buildActiveFilterPill(
                            'Type: ${controller.selectedLeaveTypeName.value}',
                            controller.removeLeaveTypeFilter,
                          ),

                        // Role Chip
                        if (controller.selectedRole.value != 'All')
                          _buildActiveFilterPill(
                            'Role: ${controller.selectedRole.value}',
                            controller.removeRoleFilter,
                          ),

                        // Designation Chip
                        if (controller.selectedDesignation.value != 'All')
                          _buildActiveFilterPill(
                            'Desig: ${controller.selectedDesignation.value}',
                            controller.removeDesignationFilter,
                          ),

                        // Date Range Chip
                        if (controller.selectedDatePreset.value != 'All Time' || controller.selectedDateRange.value != null)
                          _buildActiveFilterPill(
                            controller.selectedDatePreset.value == 'Custom Range' && controller.selectedDateRange.value != null
                                ? '${DateFormat('dd MMM').format(controller.selectedDateRange.value!.start)} - ${DateFormat('dd MMM').format(controller.selectedDateRange.value!.end)}'
                                : controller.selectedDatePreset.value,
                            controller.removeDateFilter,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),

          const SizedBox(height: 12),

          // Requests List / Loading / Error State
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primaryColor),
                      SizedBox(height: 12),
                      AppText('Loading leave requests...', fontSize: 13, color: AppColors.textColorSecondary),
                    ],
                  ),
                );
              }

              if (controller.errorMessage.value.isNotEmpty && controller.allLeaves.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                        const SizedBox(height: 16),
                        AppText(
                          controller.errorMessage.value,
                          fontSize: 14,
                          color: AppColors.textColorSecondary,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () => controller.fetchLeaveRequests(),
                          icon: const Icon(Icons.refresh, size: 16, color: Colors.white),
                          label: const AppText('Retry', fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final filteredList = controller.filteredRequests;

              if (filteredList.isEmpty) {
                return RefreshIndicator(
                  onRefresh: controller.refreshLeaves,
                  color: AppColors.primaryColor,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                      _buildEmptyState(),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.refreshLeaves,
                color: AppColors.primaryColor,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  itemCount: filteredList.length,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return _buildRequestCard(filteredList[index]);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFilterPill(String label, VoidCallback onRemove) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppText(label, fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primaryColor),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close, size: 14, color: AppColors.primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.slate100,
                shape: BoxShape.circle,
              ),
              child: const Icon(Iconsax.document_filter, size: 48, color: AppColors.slate400),
            ),
            const SizedBox(height: 16),
            const AppText(
              'No Leave Requests Found',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textColorPrimary,
            ),
            const SizedBox(height: 8),
            const AppText(
              'No leave requests match your selected status or filter criteria.',
              fontSize: 12,
              color: AppColors.textColorSecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            if (controller.hasActiveFilters || controller.searchQuery.value.isNotEmpty)
              ElevatedButton.icon(
                onPressed: controller.resetAllFilters,
                icon: const Icon(Icons.refresh, size: 16, color: Colors.white),
                label: const AppText('Reset Filters', fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              )
            else
              ElevatedButton.icon(
                onPressed: () => controller.fetchLeaveRequests(),
                icon: const Icon(Icons.refresh, size: 16, color: Colors.white),
                label: const AppText('Refresh List', fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestCard(AdminLeaveItemModel req) {
    Color statusColor;
    if (req.status == 'Approved') {
      statusColor = Colors.green;
    } else if (req.status == 'Rejected') {
      statusColor = Colors.red;
    } else {
      statusColor = Colors.orange;
    }

    final initial = req.employee.name.isNotEmpty ? req.employee.name[0].toUpperCase() : 'E';

    return GestureDetector(
      onTap: () => Get.to(() => LeaveApprovalScreen(requestData: req.toViewMap())),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
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
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primaryColor.withValues(alpha: 0.1),
                  child: Text(
                    initial,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(req.employee.name, fontSize: 14, fontWeight: FontWeight.bold),
                      Row(
                        children: [
                          Flexible(
                            child: AppText(
                              req.employee.designation,
                              fontSize: 12,
                              color: AppColors.textColorSecondary,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (req.employee.department.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Container(
                              width: 3,
                              height: 3,
                              decoration: const BoxDecoration(
                                color: AppColors.textColorSecondary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: AppText(
                                req.employee.department,
                                fontSize: 11,
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.w600,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: AppText(
                    req.leaveType,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Iconsax.calendar_1, color: AppColors.textColorSecondary, size: 16),
                    const SizedBox(width: 8),
                    AppText(req.formattedDates, fontSize: 12, fontWeight: FontWeight.w600),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.slate100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: AppText(req.duration, fontSize: 11, color: AppColors.textColorSecondary),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: AppText(req.status, fontSize: 11, fontWeight: FontWeight.bold, color: statusColor),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(color: AppColors.borderColor, height: 1),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText('Applied on ${req.formattedAppliedOn}', fontSize: 11, color: AppColors.textColorSecondary),
                const Icon(Icons.keyboard_arrow_right, color: AppColors.textColorSecondary, size: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
