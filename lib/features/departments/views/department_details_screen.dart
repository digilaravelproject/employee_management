import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/departments_controller.dart';
import 'edit_department_screen.dart';

class DepartmentDetailsScreen extends StatelessWidget {
  const DepartmentDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DepartmentsController>();

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
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              'Department Details',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textColorPrimary,
            ),
            AppText(
              'View department profile and members',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textColorHint,
            ),
          ],
        ),
        actions: [
          Obx(() {
            final dept = controller.selectedDepartment.value;
            if (dept == null) return const SizedBox();
            return TextButton(
              onPressed: () {
                controller.populateForm(dept);
                Get.to(() => const EditDepartmentScreen());
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: AppText(
                  'Edit',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
            );
          }),
        ],
      ),
      body: Obx(() {
        final dept = controller.selectedDepartment.value;
        if (dept == null) {
          return const Center(child: AppText('No department details found'));
        }

        final hasHead = dept.head != null;
        final employeesList = dept.employees;
        final displayCount = employeesList.length > 3 ? 3 : employeesList.length;
        final remainingCount = employeesList.length - displayCount;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top Profile Overview Card ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                ),
                child: Column(
                  children: [
                    // Large colorful themed icon
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: dept.themeColor.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        dept.icon,
                        color: dept.themeColor,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Title & Description
                    AppText(
                      dept.name,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColorPrimary,
                    ),
                    const SizedBox(height: 6),
                    AppText(
                      dept.description,
                      fontSize: 12,
                      textAlign: TextAlign.center,
                      color: AppColors.textColorSecondary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 24),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    const SizedBox(height: 20),

                    // Metrics Row (Employees, Head, Teams)
                    Row(
                      children: [
                        _buildMetricBlock('${dept.employees.length}', 'Employees'),
                        _buildVerticalDivider(),
                        _buildMetricBlock(hasHead ? '1' : '0', 'Head'),
                        _buildVerticalDivider(),
                        _buildMetricBlock('${dept.teamsCount}', 'Teams'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Department Head Card Section ──
              const AppText('Department Head', fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                ),
                child: Row(
                  children: [
                    if (hasHead) ...[
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(dept.head!.avatarUrl),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(dept.head!.name, fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
                            const SizedBox(height: 2),
                            AppText(dept.head!.email, fontSize: 10, color: AppColors.textColorHint),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Iconsax.sms,
                          color: AppColors.primaryColor,
                          size: 18,
                        ),
                      ),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.slate50,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Iconsax.profile_add, color: AppColors.textColorHint, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText('No Head Assigned', fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
                            SizedBox(height: 2),
                            AppText('Tapping edit will let you assign one', fontSize: 10, color: AppColors.textColorHint),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Assigned Employees Section ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText('Employees (${employeesList.length})', fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
                  GestureDetector(
                    onTap: () {
                      // Custom popup list of all employees in department
                      _showAllEmployeesDialog(context, dept.name, employeesList);
                    },
                    child: const AppText('View All', fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (employeesList.isEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                  ),
                  child: const Center(
                    child: AppText(
                      'No employees assigned yet',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textColorHint,
                    ),
                  ),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: displayCount,
                        separatorBuilder: (context, index) => const Divider(height: 20, color: Color(0xFFF1F5F9)),
                        itemBuilder: (context, index) {
                          final emp = employeesList[index];
                          return Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundImage: NetworkImage(emp.avatarUrl),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppText(emp.name, fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
                                    const SizedBox(height: 2),
                                    AppText(emp.email, fontSize: 10, color: AppColors.textColorHint),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFECFDF5), // Emerald light
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: const AppText(
                                  'Active',
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF10B981), // Emerald green
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      if (remainingCount > 0) ...[
                        const Divider(height: 20, color: Color(0xFFF1F5F9)),
                        GestureDetector(
                          onTap: () => _showAllEmployeesDialog(context, dept.name, employeesList),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: AppText(
                              '+ $remainingCount more employees',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 30),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildMetricBlock(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          AppText(
            value,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textColorPrimary,
          ),
          const SizedBox(height: 4),
          AppText(
            label,
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.textColorHint,
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 30,
      color: const Color(0xFFE2E8F0),
    );
  }

  // Show a full list of all employees in this department in a beautiful dialog/sheet
  void _showAllEmployeesDialog(BuildContext context, String deptName, List<dynamic> employees) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: const BoxDecoration(color: Color(0xFFCBD5E1), borderRadius: BorderRadius.all(Radius.circular(10))),
              ),
            ),
            const SizedBox(height: 18),
            AppText('$deptName Members', fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
            AppText('List of all ${employees.length} active employees in this department', fontSize: 11, color: AppColors.textColorHint),
            const SizedBox(height: 14),
            Expanded(
              child: ListView.separated(
                itemCount: employees.length,
                physics: const BouncingScrollPhysics(),
                separatorBuilder: (context, index) => const Divider(height: 20, color: Color(0xFFF1F5F9)),
                itemBuilder: (context, index) {
                  final emp = employees[index];
                  return Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(emp.avatarUrl),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(emp.name, fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
                            const SizedBox(height: 2),
                            AppText(emp.email, fontSize: 10, color: AppColors.textColorHint),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: const AppText(
                          'Active',
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF10B981),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
