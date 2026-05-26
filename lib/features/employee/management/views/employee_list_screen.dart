import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text.dart';
import '../controllers/employee_controller.dart';
import '../../../../routes/route_helper.dart';
import 'employee_detail_screen.dart';

class EmployeeListScreen extends StatelessWidget {
  const EmployeeListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EmployeeController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textColorPrimary, size: 20),
        ),
        title: const AppText('Employees', fontSize: 18, fontWeight: FontWeight.w800),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(RouteHelper.getAddEmployeeRoute()),
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      body: Column(
        children: [
          // ── Search Bar ──
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: TextField(
              onChanged: (v) => controller.filterEmployees(v),
              decoration: InputDecoration(
                hintText: 'Search employees...',
                hintStyle: const TextStyle(color: AppColors.textColorHint, fontSize: 14),
                prefixIcon: const Icon(Iconsax.search_normal, color: AppColors.textColorHint, size: 20),
                filled: true,
                fillColor: const Color(0xFFF1F5F9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),

          // ── List ──
          Expanded(
            child: Obx(() {
              if (controller.filteredEmployees.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Iconsax.people, size: 64, color: AppColors.slate200),
                      const SizedBox(height: 16),
                      const AppText('No employees found', color: AppColors.textColorSecondary),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(20),
                physics: const BouncingScrollPhysics(),
                itemCount: controller.filteredEmployees.length,
                itemBuilder: (context, index) {
                  final employee = controller.filteredEmployees[index];
                  return GestureDetector(
                    onTap: () => Get.to(() => EmployeeDetailScreen(employee: employee)),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.slate200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: AppColors.primaryColor.withValues(alpha: 0.1),
                          child: AppText(
                            employee.name[0],
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(employee.name, fontSize: 16, fontWeight: FontWeight.w800),
                              const SizedBox(height: 4),
                              AppText(employee.designation, fontSize: 12, color: AppColors.textColorSecondary),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Iconsax.call, size: 12, color: AppColors.textColorHint),
                                  const SizedBox(width: 4),
                                  AppText(employee.mobile, fontSize: 11, color: AppColors.textColorHint),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.slate200),
                      ],
                    ),
                  )
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
