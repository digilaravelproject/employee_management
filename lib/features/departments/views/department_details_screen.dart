import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/departments_controller.dart';
import '../models/department_api_model.dart';
import 'edit_department_screen.dart';

class DepartmentDetailsScreen extends StatefulWidget {
  final String departmentId;
  const DepartmentDetailsScreen({super.key, required this.departmentId});

  @override
  State<DepartmentDetailsScreen> createState() => _DepartmentDetailsScreenState();
}

class _DepartmentDetailsScreenState extends State<DepartmentDetailsScreen> {
  late Future<DepartmentApiModel?> _detailsFuture;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  void _loadDetails() {
    final controller = Get.find<DepartmentsController>();
    _detailsFuture = controller.fetchDepartmentDetails(widget.departmentId);
  }

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
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textColorPrimary, size: 18),
              onPressed: () => Get.back(),
            ),
          ),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText('Department Details', fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
            AppText('View department profile & members', fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textColorHint),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.textColorPrimary, size: 20),
            onPressed: () {
              setState(() {
                _loadDetails();
              });
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: AppColors.textColorPrimary, size: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (value) {
              if (value == 'delete') {
                _detailsFuture.then((dept) {
                  if (dept != null) {
                    _showDeleteDepartmentConfirmation(
                      controller,
                      dept.id.toString(),
                      dept.name,
                    );
                  }
                });
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Iconsax.trash, size: 16, color: Colors.redAccent),
                    SizedBox(width: 8),
                    AppText('Delete Department', fontSize: 13, fontWeight: FontWeight.w500, color: Colors.redAccent),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FutureBuilder<DepartmentApiModel?>(
        future: _detailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryColor));
          }

          final dept = snapshot.data;
          if (dept == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.building_3, size: 60, color: AppColors.textColorHint.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  const AppText('Could not load department details', fontSize: 14, color: AppColors.textColorSecondary),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _loadDetails();
                      });
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor, elevation: 0),
                    child: const AppText('Retry', color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }

          final themeColor = _getThemeColor(dept.name);
          final icon = _getIcon(dept.name);
          final employees = dept.employees;
          final displayCount = employees.length > 3 ? 3 : employees.length;
          final remainingCount = employees.length - displayCount;

          return RefreshIndicator(
            color: AppColors.primaryColor,
            onRefresh: () async {
              setState(() {
                _loadDetails();
              });
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
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
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Icon circle
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: themeColor.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(icon, color: themeColor, size: 36),
                        ),
                        const SizedBox(height: 14),
                        AppText(dept.name, fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
                        const SizedBox(height: 6),
                        if (dept.description != null && dept.description!.isNotEmpty)
                          AppText(
                            dept.description!,
                            fontSize: 12,
                            textAlign: TextAlign.center,
                            color: AppColors.textColorSecondary,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),

                        // Status badge
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: dept.status.toLowerCase() == 'active'
                                ? const Color(0xFF10B981).withValues(alpha: 0.1)
                                : AppColors.textColorHint.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: AppText(
                            dept.status,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: dept.status.toLowerCase() == 'active' ? const Color(0xFF10B981) : AppColors.textColorHint,
                          ),
                        ),

                        const SizedBox(height: 20),
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        const SizedBox(height: 16),

                        // Metrics Row
                        Row(
                          children: [
                            _buildMetricBlock('${dept.employeesCount}', 'Employees'),
                            _buildVerticalDivider(),
                            _buildMetricBlock(dept.head != null ? '1' : '0', 'Head'),
                            _buildVerticalDivider(),
                            _buildMetricBlock('${dept.teamCount}', 'Teams'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Edit button row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          controller.populateFormFromApi(dept);
                          Get.to(() => const EditDepartmentScreen())?.then((_) {
                            setState(() {
                              _loadDetails();
                            });
                          });
                        },
                        icon: const Icon(Iconsax.edit_2, size: 14, color: AppColors.primaryColor),
                        label: const AppText('Edit Department', fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primaryColor),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Department Head Card ──
                  const AppText('Department Head', fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFF1F5F9)),
                    ),
                    child: dept.head != null
                        ? Row(
                            children: [
                              dept.head!.avatar != null && dept.head!.avatar!.isNotEmpty
                                  ? CircleAvatar(
                                      radius: 22,
                                      backgroundImage: NetworkImage(dept.head!.avatar!),
                                    )
                                  : CircleAvatar(
                                      radius: 22,
                                      backgroundColor: themeColor.withValues(alpha: 0.15),
                                      child: AppText(
                                        dept.head!.name.isNotEmpty ? dept.head!.name.substring(0, 1).toUpperCase() : 'H',
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: themeColor,
                                      ),
                                    ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppText(dept.head!.name, fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
                                    const SizedBox(height: 2),
                                    AppText(dept.head!.email, fontSize: 11, color: AppColors.textColorHint),
                                    if (dept.head!.designation != null && dept.head!.designation!.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: themeColor.withValues(alpha: 0.08),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: AppText(dept.head!.designation!, fontSize: 10, fontWeight: FontWeight.w600, color: themeColor),
                                      ),
                                    ],
                                    if (dept.head!.employeeId != null && dept.head!.employeeId!.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      AppText(dept.head!.employeeId!, fontSize: 10, color: AppColors.textColorHint),
                                    ],
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Iconsax.profile_circle, color: AppColors.primaryColor, size: 18),
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: AppColors.slate50,
                                child: const Icon(Iconsax.profile_add, color: AppColors.textColorHint, size: 20),
                              ),
                              const SizedBox(width: 14),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppText('No Head Assigned', fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
                                    SizedBox(height: 2),
                                    AppText('Edit the department to assign a head', fontSize: 10, color: AppColors.textColorHint),
                                  ],
                                ),
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 24),

                  // ── Assigned Employees Section ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText('Employees (${dept.employeesCount})', fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
                      if (employees.isNotEmpty)
                        GestureDetector(
                          onTap: () => _showAllEmployeesSheet(context, controller, dept.id.toString(), dept.name, employees),
                          child: const AppText('View All', fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (employees.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                      ),
                      child: Column(
                        children: [
                          Icon(Iconsax.profile_delete, size: 36, color: AppColors.textColorHint.withValues(alpha: 0.4)),
                          const SizedBox(height: 8),
                          const AppText('No employees assigned yet', fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textColorHint),
                        ],
                      ),
                    )
                  else
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
                              final emp = employees[index];
                              final empName = emp.name;
                              final empEmail = emp.email;
                              final empAvatar = emp.avatar;
                              final empStatus = emp.status ?? 'active';
                              return Row(
                                children: [
                                  empAvatar != null && empAvatar.isNotEmpty
                                      ? CircleAvatar(radius: 18, backgroundImage: NetworkImage(empAvatar))
                                      : CircleAvatar(
                                          radius: 18,
                                          backgroundColor: themeColor.withValues(alpha: 0.12),
                                          child: AppText(
                                            empName.isNotEmpty ? empName[0].toUpperCase() : '?',
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: themeColor,
                                          ),
                                        ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        AppText(empName, fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
                                        const SizedBox(height: 2),
                                        AppText(empEmail, fontSize: 10, color: AppColors.textColorHint),
                                        if (emp.employeeId != null && emp.employeeId!.isNotEmpty) ...[
                                          const SizedBox(height: 2),
                                          AppText(emp.employeeId!, fontSize: 9, color: AppColors.textColorHint),
                                        ],
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFECFDF5),
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: AppText(
                                      empStatus.capitalize ?? empStatus,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF10B981),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  IconButton(
                                    icon: const Icon(Iconsax.trash, color: AppColors.errorColor, size: 18),
                                    constraints: const BoxConstraints(),
                                    padding: const EdgeInsets.all(6),
                                    onPressed: () => _showRemoveEmployeeConfirmation(
                                      context,
                                      controller,
                                      dept.id.toString(),
                                      emp.id.toString(),
                                      empName,
                                      () {
                                        setState(() {
                                          _loadDetails();
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          if (remainingCount > 0) ...[
                            const Divider(height: 20, color: Color(0xFFF1F5F9)),
                            GestureDetector(
                              onTap: () => _showAllEmployeesSheet(context, controller, dept.id.toString(), dept.name, employees),
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
                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMetricBlock(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          AppText(value, fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textColorPrimary),
          const SizedBox(height: 4),
          AppText(label, fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textColorHint),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(width: 1, height: 30, color: const Color(0xFFE2E8F0));
  }

  void _showAllEmployeesSheet(
    BuildContext context,
    DepartmentsController controller,
    String deptId,
    String deptName,
    List<DepartmentMemberModel> employees,
  ) {
    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.65,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: const BoxDecoration(color: Color(0xFFCBD5E1), borderRadius: BorderRadius.all(Radius.circular(10))),
              ),
            ),
            const SizedBox(height: 18),
            AppText('$deptName Members', fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
            AppText('${employees.length} employees in this department', fontSize: 11, color: AppColors.textColorHint),
            const SizedBox(height: 14),
            Expanded(
              child: ListView.separated(
                itemCount: employees.length,
                physics: const BouncingScrollPhysics(),
                separatorBuilder: (context, index) => const Divider(height: 20, color: Color(0xFFF1F5F9)),
                itemBuilder: (context, index) {
                  final emp = employees[index];
                  final empName = emp.name;
                  final empEmail = emp.email;
                  final empAvatar = emp.avatar;
                  return Row(
                    children: [
                      empAvatar != null && empAvatar.isNotEmpty
                          ? CircleAvatar(radius: 20, backgroundImage: NetworkImage(empAvatar))
                          : CircleAvatar(
                              radius: 20,
                              backgroundColor: AppColors.primaryColor.withValues(alpha: 0.1),
                              child: AppText(
                                empName.isNotEmpty ? empName[0].toUpperCase() : '?',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryColor,
                              ),
                            ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(empName, fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
                            AppText(empEmail, fontSize: 10, color: AppColors.textColorHint),
                            if (emp.employeeId != null && emp.employeeId!.isNotEmpty) ...[
                              AppText(emp.employeeId!, fontSize: 9, color: AppColors.textColorHint),
                            ],
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Iconsax.trash, color: AppColors.errorColor, size: 18),
                        onPressed: () {
                          Get.back(); // close bottomsheet
                          _showRemoveEmployeeConfirmation(
                            context,
                            controller,
                            deptId,
                            emp.id.toString(),
                            empName,
                            () {
                              setState(() {
                                _loadDetails();
                              });
                            },
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showRemoveEmployeeConfirmation(
    BuildContext context,
    DepartmentsController controller,
    String departmentId,
    String employeeId,
    String employeeName,
    VoidCallback onSuccess,
  ) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.errorColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Iconsax.trash, color: AppColors.errorColor, size: 20),
            ),
            const SizedBox(width: 10),
            const AppText('Remove Employee', fontSize: 16, fontWeight: FontWeight.bold),
          ],
        ),
        content: AppText(
          'Are you sure you want to remove "$employeeName" from this department?',
          fontSize: 14,
          color: AppColors.textColorPrimary,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const AppText('Cancel', color: AppColors.textColorSecondary, fontWeight: FontWeight.w600),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              final success = await controller.removeEmployeeFromDepartmentApi(departmentId, employeeId);
              if (success) {
                CustomSnackbar.showSuccess('Employee removed successfully');
                onSuccess();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const AppText('Remove', color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _showDeleteDepartmentConfirmation(
    DepartmentsController controller,
    String departmentId,
    String departmentName,
  ) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.errorColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Iconsax.trash, color: AppColors.errorColor, size: 20),
            ),
            const SizedBox(width: 10),
            const AppText('Delete Department', fontSize: 16, fontWeight: FontWeight.bold),
          ],
        ),
        content: AppText(
          'Are you sure you want to delete "$departmentName"? This action cannot be undone.',
          fontSize: 14,
          color: AppColors.textColorPrimary,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const AppText('Cancel', color: AppColors.textColorSecondary, fontWeight: FontWeight.w600),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              final success = await controller.deleteDepartmentApi(departmentId);
              if (success) {
                Get.back();
                CustomSnackbar.showSuccess('Department deleted successfully');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const AppText('Delete', color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Color _getThemeColor(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('tech') || lower.contains('eng') || lower.contains('code') || lower.contains('dev') || lower.contains('product')) return const Color(0xFF6366F1);
    if (lower.contains('hr') || lower.contains('people') || lower.contains('recruit') || lower.contains('human')) return const Color(0xFFEC4899);
    if (lower.contains('market') || lower.contains('advert') || lower.contains('social')) return const Color(0xFF10B981);
    if (lower.contains('finance') || lower.contains('money') || lower.contains('audit') || lower.contains('pay')) return const Color(0xFFF59E0B);
    if (lower.contains('sale') || lower.contains('deal') || lower.contains('revenue')) return const Color(0xFF3B82F6);
    if (lower.contains('support') || lower.contains('it') || lower.contains('help')) return const Color(0xFF06B6D4);
    return const Color(0xFF8B5CF6);
  }

  IconData _getIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('tech') || lower.contains('eng') || lower.contains('code') || lower.contains('dev') || lower.contains('product')) return Iconsax.code;
    if (lower.contains('hr') || lower.contains('people') || lower.contains('recruit') || lower.contains('human')) return Iconsax.user_octagon;
    if (lower.contains('market') || lower.contains('advert') || lower.contains('social')) return Iconsax.volume_high;
    if (lower.contains('finance') || lower.contains('money') || lower.contains('audit') || lower.contains('pay')) return Iconsax.empty_wallet;
    if (lower.contains('sale') || lower.contains('deal') || lower.contains('revenue')) return Iconsax.graph;
    if (lower.contains('support') || lower.contains('it') || lower.contains('help')) return Iconsax.monitor;
    return Iconsax.category;
  }
}
