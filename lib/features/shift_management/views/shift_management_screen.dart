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

class ShiftManagementScreen extends StatefulWidget {
  const ShiftManagementScreen({super.key});

  @override
  State<ShiftManagementScreen> createState() => _ShiftManagementScreenState();
}

class _ShiftManagementScreenState extends State<ShiftManagementScreen> {
  late final TextEditingController _searchController;
  late final ShiftController _controller;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _controller = Get.isRegistered<ShiftController>()
        ? Get.find<ShiftController>()
        : Get.put(ShiftController());
    _searchController.text = _controller.searchQuery.value;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          IconButton(
            tooltip: 'Create Shift',
            icon: const Icon(Iconsax.add_circle, color: AppColors.primaryColor, size: 22),
            onPressed: () async {
              final res = await Get.to(() => const CreateShiftScreen());
              if (res == true) {
                _controller.fetchShifts();
              }
            },
          ),
          const SizedBox(width: 6),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final res = await Get.to(() => const CreateShiftScreen());
          if (res == true) {
            _controller.fetchShifts();
          }
        },
        backgroundColor: AppColors.primaryColor,
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
        label: const AppText('Add Shift', fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: () => _controller.fetchShifts(),
        color: AppColors.primaryColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Quick Action Action Buttons
              Row(
                children: [
                  Expanded(
                    child: _buildActionCard(
                      icon: Iconsax.add_circle5,
                      title: 'Create Shift',
                      subtitle: 'New schedule & rules',
                      primaryColor: const Color(0xFF6366F1), // Indigo
                      onTap: () async {
                        final res = await Get.to(() => const CreateShiftScreen());
                        if (res == true) {
                          _controller.fetchShifts();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionCard(
                      icon: Iconsax.profile_2user5,
                      title: 'Assign Shift',
                      subtitle: 'Allocate to staff',
                      primaryColor: const Color(0xFF10B981), // Emerald green
                      onTap: () async {
                        final res = await Get.to(() => const AssignShiftScreen());
                        if (res == true) {
                          _controller.fetchShifts();
                        }
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // 2. Stats Dashboard Cards (2x2 Grid)
              Obx(() => Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatGridCard(
                          icon: Iconsax.calendar_1,
                          iconColor: const Color(0xFF3B82F6),
                          count: '${_controller.totalShifts}',
                          title: 'Total Shifts',
                          subtitle: 'Configured schedules',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatGridCard(
                          icon: Iconsax.people,
                          iconColor: const Color(0xFF8B5CF6),
                          count: '${_controller.totalEmployees}',
                          title: 'Total Staff',
                          subtitle: 'Assigned members',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatGridCard(
                          icon: Iconsax.tick_circle,
                          iconColor: const Color(0xFF10B981),
                          count: '${_controller.activeShifts}',
                          title: 'Active Shifts',
                          subtitle: 'Live in roster',
                          isLive: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatGridCard(
                          icon: Iconsax.close_circle,
                          iconColor: const Color(0xFFEF4444),
                          count: '${_controller.inactiveShifts}',
                          title: 'Inactive Shifts',
                          subtitle: 'Disabled/Archived',
                        ),
                      ),
                    ],
                  ),
                ],
              )),

              const SizedBox(height: 20),

              // 3. Search Bar (Without dropdown filter)
              Container(
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
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    _controller.searchQuery.value = val;
                    setState(() {});
                  },
                  style: const TextStyle(fontSize: 13, color: AppColors.textColorPrimary),
                  decoration: InputDecoration(
                    hintText: 'Search shifts by name, type, or code...',
                    hintStyle: const TextStyle(color: AppColors.textColorHint, fontSize: 13),
                    prefixIcon: const Icon(Iconsax.search_normal, color: AppColors.textColorSecondary, size: 18),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18, color: AppColors.textColorHint),
                            onPressed: () {
                              _searchController.clear();
                              _controller.searchQuery.value = '';
                              setState(() {});
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 4. Shifts List Header
              Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const AppText('All Shifts', fontSize: 15, fontWeight: FontWeight.bold),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: AppText(
                          '${_controller.filteredShifts.length}',
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  if (_controller.searchQuery.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        _searchController.clear();
                        _controller.searchQuery.value = '';
                        setState(() {});
                      },
                      child: const AppText('Clear Search', fontSize: 12, color: AppColors.primaryColor, fontWeight: FontWeight.w600),
                    ),
                ],
              )),

              const SizedBox(height: 10),

              // 5. Dynamic Shift Cards List
              Obx(() {
                if (_controller.isLoading.value && _controller.shifts.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 48),
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(color: AppColors.primaryColor),
                  );
                }

                final list = _controller.filteredShifts;

                if (list.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.slate200),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.slate50,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Iconsax.calendar_search, size: 36, color: AppColors.textColorHint),
                        ),
                        const SizedBox(height: 12),
                        const AppText('No shifts found', fontSize: 14, fontWeight: FontWeight.bold),
                        const SizedBox(height: 4),
                        const AppText(
                          'Try searching with a different keyword or create a new shift.',
                          fontSize: 12,
                          color: AppColors.textColorHint,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final res = await Get.to(() => const CreateShiftScreen());
                            if (res == true) {
                              _controller.fetchShifts();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          ),
                          icon: const Icon(Icons.add, size: 16, color: Colors.white),
                          label: const AppText('Create New Shift', fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: list.map((shift) => _buildShiftItemCard(context, shift, _controller)).toList(),
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
  // Action Button Card (Create / Assign Shift)
  // ----------------------------------------------------
  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color primaryColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.slate200),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: primaryColor, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppText(
                      title,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColorPrimary,
                    ),
                    const SizedBox(height: 2),
                    AppText(
                      subtitle,
                      fontSize: 10,
                      color: AppColors.textColorSecondary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------
  // 2x2 Metric Stats Card
  // ----------------------------------------------------
  Widget _buildStatGridCard({
    required IconData icon,
    required Color iconColor,
    required String count,
    required String title,
    required String subtitle,
    bool isLive = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              if (isLive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const AppText('Live', fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          AppText(
            count,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textColorPrimary,
          ),
          const SizedBox(height: 2),
          AppText(
            title,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textColorPrimary,
          ),
          const SizedBox(height: 1),
          AppText(
            subtitle,
            fontSize: 10,
            color: AppColors.textColorSecondary,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // Shift Item Card
  // ----------------------------------------------------
  Widget _buildShiftItemCard(BuildContext context, ShiftModel shift, ShiftController controller) {
    final bool isActive = shift.isActive;
    final Color badgeColor = isActive ? const Color(0xFF10B981) : AppColors.textColorHint;

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
        onTap: () async {
          await Get.to(() => ShiftDetailsScreen(shift: shift));
          controller.fetchShifts();
        },
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
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.slate100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: AppText(shift.code, fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.textColorSecondary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Iconsax.clock, size: 13, color: AppColors.textColorHint),
                            const SizedBox(width: 4),
                            AppText(
                              '${shift.startTime} - ${shift.endTime}',
                              fontSize: 12,
                              color: AppColors.textColorSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                            if (shift.workingHours.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              Container(
                                width: 3,
                                height: 3,
                                decoration: const BoxDecoration(
                                  color: AppColors.textColorHint,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              AppText(
                                shift.workingHours,
                                fontSize: 11,
                                color: AppColors.textColorHint,
                              ),
                            ],
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
                          color: badgeColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: badgeColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            AppText(
                              isActive ? 'Active' : 'Inactive',
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: badgeColor,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 2),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, size: 18, color: AppColors.textColorSecondary),
                        padding: EdgeInsets.zero,
                        onSelected: (val) async {
                          if (val == 'view') {
                            await Get.to(() => ShiftDetailsScreen(shift: shift));
                            controller.fetchShifts();
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
                                SizedBox(width: 8),
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
                        '${shift.employeesCount} Staff Assigned',
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
