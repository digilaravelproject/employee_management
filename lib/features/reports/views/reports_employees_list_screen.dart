import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/admin_reports_controller.dart';
import 'employee_overview_report_screen.dart';

class ReportsEmployeesListScreen extends StatelessWidget {
  final String initialTab; // The report category tapped (e.g. 'Attendance', 'Payroll', 'Leave', 'Sales', 'Tasks')
  
  const ReportsEmployeesListScreen({
    super.key,
    required this.initialTab,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminReportsController>();
    final searchController = TextEditingController(text: controller.searchQuery.value);

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
          'Employees List',
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: Color(0xFF1E293B),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.search_normal, color: Color(0xFF1E293B)),
            onPressed: () {},
          ),
        ],
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── SEARCH BAR ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: searchController,
                  onChanged: (val) => controller.filterEmployees(val),
                  decoration: const InputDecoration(
                    hintText: 'Search employees...',
                    hintStyle: TextStyle(fontSize: 13, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
                    prefixIcon: Icon(Iconsax.search_normal, color: Color(0xFF94A3B8), size: 18),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
            ),

            // ── TABS FILTER ──
            Obx(() {
              final activeTab = controller.activeFilterTab.value;
              final allCount = controller.employees.length;
              final activeCount = controller.employees.where((e) => e.status == 'Active').length;
              final leaveCount = controller.employees.where((e) => e.status == 'On Leave').length;
              final inactiveCount = controller.employees.where((e) => e.status == 'Inactive').length;

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Row(
                  children: [
                    _buildTabItem('All', allCount, activeTab == 'All', () => controller.setFilterTab('All')),
                    const SizedBox(width: 8),
                    _buildTabItem('Active', activeCount, activeTab == 'Active', () => controller.setFilterTab('Active')),
                    const SizedBox(width: 8),
                    _buildTabItem('On Leave', leaveCount, activeTab == 'On Leave', () => controller.setFilterTab('On Leave')),
                    const SizedBox(width: 8),
                    _buildTabItem('Inactive', inactiveCount, activeTab == 'Inactive', () => controller.setFilterTab('Inactive')),
                  ],
                ),
              );
            }),

            const SizedBox(height: 10),

            // ── EMPLOYEE LIST VIEW ──
            Expanded(
              child: Obx(() {
                final list = controller.filteredEmployees;
                if (list.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Iconsax.profile_2user, size: 48, color: Color(0xFFCBD5E1)),
                        SizedBox(height: 8),
                        AppText(
                          'No employees found',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF94A3B8),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: list.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final employee = list[index];
                    return _EmployeeListCard(
                      employee: employee,
                      onTap: () {
                        controller.selectEmployee(employee);
                        Get.to(() => EmployeeOverviewReportScreen(initialCategoryTab: initialTab));
                      },
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(String label, int count, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2563EB) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: const Color(0xFF2563EB).withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
          ],
        ),
        child: Row(
          children: [
            AppText(
              label,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: isSelected ? Colors.white : const Color(0xFF475569),
            ),
            const SizedBox(width: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withValues(alpha: 0.2) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? Colors.white : const Color(0xFF64748B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmployeeListCard extends StatelessWidget {
  final AdminReportEmployee employee;
  final VoidCallback onTap;

  const _EmployeeListCard({
    required this.employee,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    if (employee.status == 'Active') {
      statusColor = const Color(0xFF10B981);
    } else if (employee.status == 'On Leave') {
      statusColor = const Color(0xFFF59E0B);
    } else {
      statusColor = const Color(0xFF94A3B8);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEEF2FF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Profile Avatar with circular frame and status indicator
                Stack(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: NetworkImage(employee.avatarUrl),
                          fit: BoxFit.cover,
                        ),
                        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                      ),
                    ),
                    Positioned(
                      right: 1,
                      bottom: 1,
                      child: Container(
                        width: 11,
                        height: 11,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                
                // Name & Role
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        employee.name,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1E293B),
                      ),
                      const SizedBox(height: 3),
                      AppText(
                        employee.designation,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                      ),
                    ],
                  ),
                ),

                // Chevron icon
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Color(0xFFCBD5E1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
