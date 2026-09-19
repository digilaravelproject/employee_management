import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/shift_controller.dart';
import '../models/shift_model.dart';
import 'assign_shift_screen.dart';
import 'create_shift_screen.dart';
import 'shift_details_screen.dart';
// import 'shift_history_screen.dart';
// import 'shift_rotation_screen.dart';

class ShiftManagementScreen extends StatelessWidget {
  const ShiftManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ShiftController controller = Get.isRegistered<ShiftController>()
        ? Get.find<ShiftController>()
        : Get.put(ShiftController());

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textColorPrimary, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const AppText('Shift Management', fontSize: 18, fontWeight: FontWeight.bold),
        centerTitle: false,
        actions: [
          // IconButton(
          //   tooltip: 'Shift History',
          //   icon: const Icon(Iconsax.clock, color: AppColors.textColorPrimary, size: 20),
          //   onPressed: () => Get.to(() => const ShiftHistoryScreen()),
          // ),
          IconButton(
            tooltip: 'Create Shift',
            icon: const Icon(Iconsax.add_circle, color: AppColors.primaryColor, size: 22),
            onPressed: () => Get.to(() => const CreateShiftScreen()),
          ),
          const SizedBox(width: 4),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => const CreateShiftScreen()),
        backgroundColor: AppColors.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const AppText('Add Shift', fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.fetchShifts(),
        color: AppColors.primaryColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quick Actions (Matching previous requirements)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildQuickAction(
                    context,
                    Iconsax.clipboard_text,
                    'Create Shift',
                    Colors.purple,
                    () => Get.to(() => const CreateShiftScreen()),
                  ),
                  _buildQuickAction(
                    context,
                    Iconsax.profile_2user,
                    'Assign Shift',
                    Colors.green,
                    () async {
                      final res = await Get.to(() => const AssignShiftScreen());
                      if (res == true) {
                        controller.fetchShifts();
                      }
                    },
                  ),
                  // _buildQuickAction(
                  //   context,
                  //   Iconsax.clock,
                  //   'Shift History',
                  //   Colors.blue,
                  //   () => Get.to(() => const ShiftHistoryScreen()),
                  // ),
                  // _buildQuickAction(context, Iconsax.repeate_music, 'Rotation', Colors.orange, () => Get.to(() => const ShiftRotationScreen())),
                  // _buildQuickAction(context, Iconsax.calendar_2, 'Roster', Colors.blue, () {}),
                ],
              ),

              const SizedBox(height: 24),

              // Top Stat Summary Cards (Matching Panel 1: List View)
              Obx(() => Row(
                children: [
                  Expanded(
                    child: _buildSummaryStatCard(
                      icon: Iconsax.calendar_tick,
                      color: Colors.blue,
                      count: '${controller.totalShifts}',
                      label: 'Total Shifts',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildSummaryStatCard(
                      icon: Iconsax.profile_2user,
                      color: Colors.purple,
                      count: '${controller.totalEmployees}',
                      label: 'Employees',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildSummaryStatCard(
                      icon: Iconsax.tick_circle,
                      color: Colors.green,
                      count: '${controller.activeShifts}',
                      label: 'Active',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildSummaryStatCard(
                      icon: Iconsax.close_circle,
                      color: Colors.redAccent,
                      count: '${controller.inactiveShifts}',
                      label: 'Inactive',
                    ),
                  ),
                ],
              )),

              const SizedBox(height: 24),

              // Search & Filter Section (Matching Panel 1)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.slate200),
                ),
                child: Column(
                  children: [
                    // Search Bar
                    TextFormField(
                      onChanged: (val) => controller.searchQuery.value = val,
                      style: const TextStyle(fontSize: 13, color: AppColors.textColorPrimary),
                      decoration: InputDecoration(
                        hintText: 'Search shifts by name or code...',
                        hintStyle: const TextStyle(color: AppColors.textColorHint, fontSize: 13),
                        prefixIcon: const Icon(Iconsax.search_normal, color: AppColors.textColorSecondary, size: 18),
                        filled: true,
                        fillColor: AppColors.slate50,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Filter Dropdowns Row
                    Obx(() => Row(
                      children: [
                        // Type Filter
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.slate50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.slate200),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: controller.selectedType.value,
                                isExpanded: true,
                                icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textColorPrimary),
                                onChanged: (val) {
                                  if (val != null) controller.selectedType.value = val;
                                },
                                items: controller.typeFilterOptions.map((opt) {
                                  return DropdownMenuItem(value: opt, child: Text(opt));
                                }).toList(),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        // Status Filter
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.slate50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.slate200),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: controller.selectedStatus.value,
                                isExpanded: true,
                                icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textColorPrimary),
                                onChanged: (val) {
                                  if (val != null) {
                                    controller.selectedStatus.value = val;
                                    controller.fetchShifts();
                                  }
                                },
                                items: controller.statusFilterOptions.map((opt) {
                                  return DropdownMenuItem(value: opt, child: Text(opt));
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Shifts List Header
              Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const AppText('All Shifts', fontSize: 16, fontWeight: FontWeight.bold),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: AppText(
                          '${controller.filteredShifts.length}',
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: () => Get.to(() => const CreateShiftScreen()),
                    icon: const Icon(Icons.add_circle_outline, size: 16, color: AppColors.primaryColor),
                    label: const AppText('Add Shift', fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                  ),
                ],
              )),

              const SizedBox(height: 12),

              // Dynamic Shift Cards List
              Obx(() {
                if (controller.isLoading.value && controller.shifts.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 48),
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(color: AppColors.primaryColor),
                  );
                }

                final list = controller.filteredShifts;

                if (list.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.slate200),
                    ),
                    child: Column(
                      children: const [
                        Icon(Iconsax.calendar_search, size: 40, color: AppColors.textColorHint),
                        SizedBox(height: 12),
                        AppText('No shifts found matching criteria', fontSize: 13, color: AppColors.textColorHint),
                      ],
                    ),
                  );
                }

                return Column(
                  children: list.map((shift) => _buildShiftItemCard(context, shift, controller)).toList(),
                );
              }),

              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------
  // Summary Stat Card (Matching Panel 1)
  // ----------------------------------------------------
  Widget _buildSummaryStatCard({
    required IconData icon,
    required Color color,
    required String count,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 8),
          AppText(count, fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
          const SizedBox(height: 2),
          AppText(label, fontSize: 10, color: AppColors.textColorSecondary, maxLines: 1),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // Shift Item Card (Clickable to Panel 9: Shift Details)
  // ----------------------------------------------------
  Widget _buildShiftItemCard(BuildContext context, ShiftModel shift, ShiftController controller) {
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
        onTap: () => Get.to(() => ShiftDetailsScreen(shift: shift)),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: shift.iconColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(shift.icon, color: shift.iconColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: AppText(
                                shift.name,
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
                              child: AppText(shift.code, fontSize: 9, color: AppColors.textColorSecondary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Iconsax.clock, size: 14, color: AppColors.textColorHint),
                            const SizedBox(width: 4),
                            AppText(
                              '${shift.startTime} - ${shift.endTime}',
                              fontSize: 12,
                              color: AppColors.textColorSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Status Badge & Menu
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: shift.isActive
                              ? AppColors.successColor.withValues(alpha: 0.1)
                              : AppColors.slate200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: AppText(
                          shift.isActive ? 'Active' : 'Inactive',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: shift.isActive ? AppColors.successColor : AppColors.textColorSecondary,
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, size: 18, color: AppColors.textColorSecondary),
                        padding: EdgeInsets.zero,
                        onSelected: (val) async {
                          if (val == 'view') {
                            Get.to(() => ShiftDetailsScreen(shift: shift));
                          } else if (val == 'edit') {
                            final res = await Get.to(() => CreateShiftScreen(shiftToEdit: shift));
                            if (res == true) {
                              controller.fetchShifts();
                            }
                          } else if (val == 'assign') {
                            final res = await Get.to(() => AssignShiftScreen(preSelectedShift: shift));
                            if (res == true) {
                              controller.fetchShifts();
                            }
                          } else if (val == 'toggle') {
                            controller.toggleShiftStatus(shift);
                          } else if (val == 'duplicate') {
                            controller.duplicateShift(shift);
                          } else if (val == 'delete') {
                            _showDeleteDialog(context, shift, controller);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'view',
                            child: Row(
                              children: [
                                Icon(Iconsax.eye, size: 16),
                                SizedBox(width: 8),
                                AppText('View Details', fontSize: 12),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Iconsax.edit, size: 16),
                                SizedBox(width: 8),
                                AppText('Edit Shift', fontSize: 12),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'assign',
                            child: Row(
                              children: [
                                Icon(Iconsax.profile_2user, size: 16),
                                SizedBox(width: 8),
                                AppText('Assign Employees', fontSize: 12),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'duplicate',
                            child: Row(
                              children: [
                                Icon(Iconsax.copy, size: 16),
                                SizedBox(width: 8),
                                AppText('Duplicate', fontSize: 12),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'toggle',
                            child: Row(
                              children: [
                                Icon(
                                  shift.isActive ? Iconsax.slash : Iconsax.tick_circle,
                                  size: 16,
                                  color: shift.isActive ? Colors.red : Colors.green,
                                ),
                                const SizedBox(width: 8),
                                AppText(shift.isActive ? 'Deactivate' : 'Activate', fontSize: 12),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Iconsax.trash, size: 16, color: Colors.redAccent),
                                SizedBox(width: 8),
                                AppText('Delete Shift', fontSize: 12, color: Colors.redAccent),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Divider(height: 1, color: AppColors.slate100),
              ),

              // Bottom Details Row: Employees & Type
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Iconsax.profile_2user, size: 14, color: AppColors.primaryColor),
                      const SizedBox(width: 6),
                      AppText(
                        '${shift.employeesCount} Employees',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColorPrimary,
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.slate100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: AppText(
                      shift.type,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textColorSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          AppText(label, fontSize: 11, fontWeight: FontWeight.w600),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, ShiftModel shift, ShiftController controller) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Iconsax.trash, color: Colors.redAccent, size: 28),
              ),
              const SizedBox(height: 16),
              const AppText(
                'Delete Shift',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textColorPrimary,
              ),
              const SizedBox(height: 8),
              AppText(
                'Are you sure you want to delete "${shift.name}"? This action cannot be undone.',
                fontSize: 13,
                color: AppColors.textColorSecondary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: AppColors.slate200),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const AppText(
                        'Cancel',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColorSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(() {
                      final isDeleting = controller.isSubmitting.value;
                      return ElevatedButton(
                        onPressed: isDeleting
                            ? null
                            : () async {
                                final res = await controller.deleteShiftApi(shift.id);
                                Get.back();
                                if (res.status) {
                                  Get.snackbar(
                                    'Deleted',
                                    res.message.isNotEmpty ? res.message : 'Shift deleted successfully.',
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.redAccent,
                                    colorText: Colors.white,
                                    duration: const Duration(seconds: 3),
                                  );
                                } else {
                                  Get.snackbar(
                                    'Delete Failed',
                                    res.message.isNotEmpty ? res.message : 'Failed to delete shift.',
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: AppColors.errorColor,
                                    colorText: Colors.white,
                                    duration: const Duration(seconds: 4),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: isDeleting
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const AppText(
                                'Delete',
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                      );
                    }),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
