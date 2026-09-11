import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text.dart';
import '../controllers/employee_controller.dart';
import 'add_employee_screen.dart';
import 'employee_detail_screen.dart';

class EmployeeListScreen extends StatelessWidget {
  const EmployeeListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<EmployeeController>()
        ? Get.find<EmployeeController>()
        : Get.put(EmployeeController());

    final searchController = TextEditingController(text: controller.searchQuery.value);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textColorPrimary, size: 20),
        ),
        title: const AppText('Employee Directory', fontSize: 18, fontWeight: FontWeight.w800),
        centerTitle: false,
        actions: [
          // Export Button
          IconButton(
            tooltip: 'Export Directory',
            icon: const Icon(Iconsax.document_download, color: AppColors.textColorPrimary, size: 20),
            onPressed: () => _handleExport(context, controller),
          ),
          // Add Employee Button
          IconButton(
            tooltip: 'Add Employee',
            icon: const Icon(Iconsax.user_add, color: AppColors.primaryColor, size: 22),
            onPressed: () => Get.to(() => const AddEmployeeScreen()),
          ),
          const SizedBox(width: 6),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => const AddEmployeeScreen()),
        backgroundColor: AppColors.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const AppText('Add Employee', fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      body: Column(
        children: [
          // Search Bar & Filter Button Container
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: AppColors.slate200.withValues(alpha: 0.8))),
            ),
            child: Row(
              children: [
                // Search Input
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.slate50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.slate200),
                    ),
                    child: TextField(
                      controller: searchController,
                      onChanged: (v) => controller.filterEmployees(v),
                      style: const TextStyle(fontSize: 13, color: AppColors.textColorPrimary),
                      decoration: InputDecoration(
                        hintText: 'Search by name, ID, mobile, dept...',
                        hintStyle: const TextStyle(color: AppColors.textColorHint, fontSize: 13),
                        prefixIcon: const Icon(Iconsax.search_normal, color: AppColors.textColorSecondary, size: 18),
                        suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close, size: 16, color: AppColors.textColorHint),
                                onPressed: () {
                                  searchController.clear();
                                  controller.filterEmployees('');
                                },
                              )
                            : const SizedBox.shrink()),
                        filled: false,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Filter BottomSheet Trigger Button
                Obx(() {
                  final activeCount = controller.activeFiltersCount;
                  final hasActive = activeCount > 0;

                  return InkWell(
                    onTap: () => _showFilterBottomSheet(context, controller),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        color: hasActive ? AppColors.primaryColor : AppColors.slate50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: hasActive ? AppColors.primaryColor : AppColors.slate200,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Iconsax.filter_search,
                            size: 18,
                            color: hasActive ? Colors.white : AppColors.textColorPrimary,
                          ),
                          if (hasActive) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: AppText(
                                '$activeCount',
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          // Active Filter Chips Bar (if any filters are applied)
          Obx(() {
            if (controller.activeFiltersCount == 0) return const SizedBox.shrink();

            return Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => controller.resetFilters(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.clear_all, size: 14, color: Colors.redAccent),
                            SizedBox(width: 4),
                            AppText('Reset All', fontSize: 11, fontWeight: FontWeight.bold, color: Colors.redAccent),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (controller.filterDepartment.value != 'All')
                      _buildActiveFilterTag('Dept: ${controller.filterDepartment.value}', () {
                        controller.filterDepartment.value = 'All';
                        controller.applyFilters();
                      }),
                    if (controller.filterDesignation.value != 'All')
                      _buildActiveFilterTag('Role: ${controller.filterDesignation.value}', () {
                        controller.filterDesignation.value = 'All';
                        controller.applyFilters();
                      }),
                    if (controller.filterTeam.value != 'All')
                      _buildActiveFilterTag('Team: ${controller.filterTeam.value}', () {
                        controller.filterTeam.value = 'All';
                        controller.applyFilters();
                      }),
                    if (controller.filterShift.value != 'All')
                      _buildActiveFilterTag('Shift: ${controller.filterShift.value}', () {
                        controller.filterShift.value = 'All';
                        controller.applyFilters();
                      }),
                    if (controller.filterStatus.value != 'All')
                      _buildActiveFilterTag('Status: ${controller.filterStatus.value}', () {
                        controller.filterStatus.value = 'All';
                        controller.applyFilters();
                      }),
                    if (controller.filterJoiningYear.value != 'All')
                      _buildActiveFilterTag('Year: ${controller.filterJoiningYear.value}', () {
                        controller.filterJoiningYear.value = 'All';
                        controller.applyFilters();
                      }),
                  ],
                ),
              ),
            );
          }),

          // Employee Count Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() => Row(
                  children: [
                    const AppText('Employees', fontSize: 15, fontWeight: FontWeight.bold),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: AppText(
                        '${controller.filteredEmployees.length}',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                )),
                TextButton.icon(
                  onPressed: () => _handleExport(context, controller),
                  icon: const Icon(Iconsax.export_1, size: 14, color: AppColors.textColorSecondary),
                  label: const AppText('Export CSV', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textColorSecondary),
                ),
              ],
            ),
          ),

          // Employees List View
          Expanded(
            child: Obx(() {
              final list = controller.filteredEmployees;

              if (list.isEmpty) {
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
                        child: const Icon(Iconsax.user_remove, size: 48, color: AppColors.textColorHint),
                      ),
                      const SizedBox(height: 16),
                      const AppText('No employees found', fontSize: 16, fontWeight: FontWeight.bold),
                      const SizedBox(height: 4),
                      const AppText('Try adjusting your search or active filters', fontSize: 12, color: AppColors.textColorSecondary),
                      const SizedBox(height: 16),
                      if (controller.activeFiltersCount > 0)
                        ElevatedButton.icon(
                          onPressed: () => controller.resetFilters(),
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const AppText('Reset Filters', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 80),
                physics: const BouncingScrollPhysics(),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final emp = list[index];
                  return _buildEmployeeCard(context, emp);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // Employee Item Card
  // ----------------------------------------------------
  Widget _buildEmployeeCard(BuildContext context, dynamic emp) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: InkWell(
        onTap: () => Get.to(() => EmployeeDetailScreen(employee: emp)),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar with Initials
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primaryLight,
                    child: AppText(
                      emp.name.split(' ').map((n) => n.isNotEmpty ? n[0] : '').take(2).join(),
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Name, ID & Designation
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: AppText(
                                emp.name,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppColors.slate100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: AppText(
                                emp.employeeId,
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textColorSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        AppText(
                          emp.designation,
                          fontSize: 12,
                          color: AppColors.textColorSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Iconsax.building_4, size: 12, color: AppColors.textColorHint),
                            const SizedBox(width: 4),
                            AppText(emp.department, fontSize: 11, color: AppColors.textColorHint),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: emp.isActive
                          ? AppColors.successColor.withValues(alpha: 0.1)
                          : AppColors.errorColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 3,
                          backgroundColor: emp.isActive ? AppColors.successColor : AppColors.errorColor,
                        ),
                        const SizedBox(width: 4),
                        AppText(
                          emp.isActive ? 'Active' : 'Inactive',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: emp.isActive ? AppColors.successColor : AppColors.errorColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Divider(height: 1, color: AppColors.slate100),
              ),

              // Bottom Details Row: Team, Shift, Joining Date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.slate50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.slate200),
                        ),
                        child: Row(
                          children: [
                            const Icon(Iconsax.profile_2user, size: 12, color: AppColors.textColorSecondary),
                            const SizedBox(width: 4),
                            AppText(emp.team, fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textColorSecondary),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.wb_sunny_outlined, size: 12, color: Colors.orange),
                            const SizedBox(width: 4),
                            AppText(emp.shift, fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Joining Date
                  Row(
                    children: [
                      const Icon(Iconsax.calendar_1, size: 12, color: AppColors.textColorHint),
                      const SizedBox(width: 4),
                      AppText(emp.joiningDate, fontSize: 11, color: AppColors.textColorSecondary),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------
  // Active Filter Tag Widget
  // ----------------------------------------------------
  Widget _buildActiveFilterTag(String label, VoidCallback onClear) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppText(label, fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
          const SizedBox(width: 4),
          InkWell(
            onTap: onClear,
            child: const Icon(Icons.close, size: 12, color: AppColors.primaryColor),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // Multi-Criteria Filter BottomSheet (Requested by User)
  // ----------------------------------------------------
  void _showFilterBottomSheet(BuildContext context, EmployeeController controller) {
    // Temporary variables for bottomsheet selection
    String tempDept = controller.filterDepartment.value;
    String tempDesig = controller.filterDesignation.value;
    String tempTeam = controller.filterTeam.value;
    String tempShift = controller.filterShift.value;
    String tempStatus = controller.filterStatus.value;
    String tempYear = controller.filterJoiningYear.value;

    Get.bottomSheet(
      isScrollControlled: true,
      StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.82,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Modal Handle Bar
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

                // Modal Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Iconsax.filter_search, size: 20, color: AppColors.primaryColor),
                        SizedBox(width: 8),
                        AppText('Filter Employees', fontSize: 17, fontWeight: FontWeight.bold),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        setModalState(() {
                          tempDept = 'All';
                          tempDesig = 'All';
                          tempTeam = 'All';
                          tempShift = 'All';
                          tempStatus = 'All';
                          tempYear = 'All';
                        });
                      },
                      child: const AppText('Reset', fontSize: 13, fontWeight: FontWeight.bold, color: Colors.redAccent),
                    ),
                  ],
                ),
                const Divider(height: 16, color: AppColors.slate200),

                // Filter Options Scrollable Content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Filter by Department
                        _buildFilterLabel('Filter by Department'),
                        const SizedBox(height: 8),
                        _buildDropdownSelector<String>(
                          value: tempDept,
                          items: controller.departmentsList,
                          onChanged: (val) {
                            if (val != null) setModalState(() => tempDept = val);
                          },
                        ),
                        const SizedBox(height: 18),

                        // 2. Filter by Designation
                        _buildFilterLabel('Filter by Designation'),
                        const SizedBox(height: 8),
                        _buildDropdownSelector<String>(
                          value: tempDesig,
                          items: controller.filterDesignationsList,
                          onChanged: (val) {
                            if (val != null) setModalState(() => tempDesig = val);
                          },
                        ),
                        const SizedBox(height: 18),

                        // 3. Filter by Team
                        _buildFilterLabel('Filter by Team'),
                        const SizedBox(height: 8),
                        _buildDropdownSelector<String>(
                          value: tempTeam,
                          items: controller.teamsList,
                          onChanged: (val) {
                            if (val != null) setModalState(() => tempTeam = val);
                          },
                        ),
                        const SizedBox(height: 18),

                        // 4. Filter by Shift
                        _buildFilterLabel('Filter by Shift'),
                        const SizedBox(height: 8),
                        _buildDropdownSelector<String>(
                          value: tempShift,
                          items: controller.shiftsList,
                          onChanged: (val) {
                            if (val != null) setModalState(() => tempShift = val);
                          },
                        ),
                        const SizedBox(height: 18),

                        // 5. Filter by Status (Active / Inactive)
                        _buildFilterLabel('Filter by Status'),
                        const SizedBox(height: 8),
                        Row(
                          children: controller.statusList.map((status) {
                            final isSelected = tempStatus == status;
                            return Expanded(
                              child: GestureDetector(
                                onTap: () => setModalState(() => tempStatus = status),
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppColors.primaryColor : AppColors.slate50,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isSelected ? AppColors.primaryColor : AppColors.slate200,
                                    ),
                                  ),
                                  child: Center(
                                    child: AppText(
                                      status,
                                      fontSize: 12,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                      color: isSelected ? Colors.white : AppColors.textColorPrimary,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 18),

                        // 6. Filter by Joining Date (Year)
                        _buildFilterLabel('Filter by Joining Year'),
                        const SizedBox(height: 8),
                        _buildDropdownSelector<String>(
                          value: tempYear,
                          items: controller.joiningYearsList,
                          onChanged: (val) {
                            if (val != null) setModalState(() => tempYear = val);
                          },
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // Apply Actions Bar
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              controller.resetFilters();
                              Get.back();
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(color: AppColors.slate300),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const AppText('Clear All', fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textColorSecondary),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () {
                              controller.filterDepartment.value = tempDept;
                              controller.filterDesignation.value = tempDesig;
                              controller.filterTeam.value = tempTeam;
                              controller.filterShift.value = tempShift;
                              controller.filterStatus.value = tempStatus;
                              controller.filterJoiningYear.value = tempYear;
                              controller.applyFilters();
                              Get.back();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const AppText('Apply Filters', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterLabel(String title) {
    return AppText(title, fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary);
  }

  Widget _buildDropdownSelector<T>({
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.slate50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.slate200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textColorSecondary, size: 20),
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textColorPrimary),
          onChanged: onChanged,
          items: items.map((T item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(item.toString()),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ----------------------------------------------------
  // Export Employees Function
  // ----------------------------------------------------
  void _handleExport(BuildContext context, EmployeeController controller) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const AppText('Export Employee Data', fontSize: 16, fontWeight: FontWeight.bold),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const SizedBox(height: 6),
            AppText(
              'Export ${controller.filteredEmployees.length} active records to your device.',
              fontSize: 12,
              color: AppColors.textColorSecondary,
            ),
            const SizedBox(height: 16),
            ListTile(
              onTap: () {
                Get.back();
                Get.snackbar(
                  'Export Started',
                  'Exporting ${controller.filteredEmployees.length} employees to Excel (.xlsx)',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppColors.successColor,
                  colorText: Colors.white,
                );
              },
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Iconsax.document_1, color: Colors.green, size: 22),
              ),
              title: const AppText('Excel Format (.xlsx)', fontSize: 14, fontWeight: FontWeight.bold),
              subtitle: const AppText('Full employee details with departments & shifts', fontSize: 11, color: AppColors.textColorSecondary),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textColorHint),
            ),
            const Divider(height: 12, color: AppColors.slate100),
            ListTile(
              onTap: () {
                Get.back();
                Get.snackbar(
                  'Export Started',
                  'Exporting ${controller.filteredEmployees.length} employees to CSV (.csv)',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppColors.successColor,
                  colorText: Colors.white,
                );
              },
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Iconsax.document_text, color: Colors.blue, size: 22),
              ),
              title: const AppText('CSV Format (.csv)', fontSize: 14, fontWeight: FontWeight.bold),
              subtitle: const AppText('Standard tabular spreadsheet format', fontSize: 11, color: AppColors.textColorSecondary),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textColorHint),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
