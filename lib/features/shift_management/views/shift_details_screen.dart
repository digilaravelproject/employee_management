import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/shift_controller.dart';
import '../models/shift_model.dart';
import '../models/shift_response_model.dart';
import 'assign_shift_screen.dart';
import 'create_shift_screen.dart';

class ShiftDetailsScreen extends StatefulWidget {
  final ShiftModel shift;
  final int initialTabIndex;

  const ShiftDetailsScreen({
    super.key,
    required this.shift,
    this.initialTabIndex = 0,
  });

  @override
  State<ShiftDetailsScreen> createState() => _ShiftDetailsScreenState();
}

class _ShiftDetailsScreenState extends State<ShiftDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final ShiftController _controller;
  final TextEditingController _employeeSearchController = TextEditingController();
  String _employeeSearchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: widget.initialTabIndex.clamp(0, 3));
    _controller = Get.isRegistered<ShiftController>()
        ? Get.find<ShiftController>()
        : Get.put(ShiftController());

    // Fetch shift details from API
    _controller.fetchShiftDetails(widget.shift.id);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _employeeSearchController.dispose();
    super.dispose();
  }

  String _formatMinutes(int? minutes, {String fallback = 'N/A'}) {
    if (minutes == null) return fallback;
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours > 0 && mins > 0) return '${hours}h ${mins}m ($minutes mins)';
    if (hours > 0) return '${hours}h 00m ($minutes mins)';
    return '$minutes mins';
  }

  String _formatDateString(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
    } catch (_) {
      return dateStr;
    }
  }

  void _showDeleteConfirmationDialog(BuildContext context, String shiftName) {
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
                'Are you sure you want to delete "$shiftName"? This will permanently remove this shift and cannot be undone.',
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
                      final isDeleting = _controller.isSubmitting.value;
                      return ElevatedButton(
                        onPressed: isDeleting
                            ? null
                            : () async {
                                final res = await _controller.deleteShiftApi(widget.shift.id);
                                if (res.status) {
                                  Get.back(); // Close dialog
                                  Get.back(result: true); // Close details screen
                                  Get.snackbar(
                                    'Deleted',
                                    res.message.isNotEmpty ? res.message : 'Shift deleted successfully.',
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.redAccent,
                                    colorText: Colors.white,
                                    duration: const Duration(seconds: 3),
                                  );
                                  _controller.fetchShifts();
                                } else {
                                  Get.back(); // Close dialog
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

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final details = _controller.selectedShiftDetails.value;
      final isLoading = _controller.isLoadingDetails.value && details == null;

      final shiftName = details?.name.isNotEmpty == true ? details!.name : widget.shift.name;
      final shiftCode = details?.code.isNotEmpty == true ? details!.code : widget.shift.code;
      final shiftType = details?.shiftType.isNotEmpty == true ? details!.shiftType : widget.shift.type;
      final isActive = details != null ? (details.status?.toLowerCase() == 'active') : widget.shift.isActive;
      final startTime = details?.startTime.isNotEmpty == true ? details!.startTime : widget.shift.startTime;
      final endTime = details?.endTime.isNotEmpty == true ? details!.endTime : widget.shift.endTime;
      final netDuration = details?.netWorkingDuration ?? details?.totalDuration ?? widget.shift.workingHours;
      final grossDuration = details?.grossDuration ?? '9h 00m';

      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textColorPrimary, size: 20),
            onPressed: () => Get.back(),
          ),
          title: AppText(
            shiftName,
            fontSize: 17,
            fontWeight: FontWeight.bold,
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            IconButton(
              tooltip: 'Assign Employees',
              icon: const Icon(Iconsax.profile_2user, color: AppColors.primaryColor, size: 20),
              onPressed: () async {
                final res = await Get.to(() => AssignShiftScreen(
                      preSelectedShift: widget.shift,
                      preSelectedShiftData: details,
                    ));
                if (res == true) {
                  _controller.fetchShiftDetails(widget.shift.id);
                  _controller.fetchShifts();
                }
              },
            ),
            IconButton(
              tooltip: 'Edit Shift',
              icon: const Icon(Iconsax.edit, color: AppColors.textColorSecondary, size: 20),
              onPressed: () async {
                final res = await Get.to(() => CreateShiftScreen(
                      shiftToEdit: widget.shift,
                      shiftDataToEdit: details,
                    ));
                if (res == true) {
                  _controller.fetchShiftDetails(widget.shift.id);
                  _controller.fetchShifts();
                }
              },
            ),
            IconButton(
              tooltip: 'Delete Shift',
              icon: const Icon(Iconsax.trash, color: Colors.redAccent, size: 20),
              onPressed: () => _showDeleteConfirmationDialog(context, shiftName),
            ),
          ],
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
            : RefreshIndicator(
                onRefresh: () => _controller.fetchShiftDetails(widget.shift.id),
                color: AppColors.primaryColor,
                child: Column(
                  children: [
                    // Banner Card
                    Container(
                      width: double.infinity,
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: widget.shift.iconColor.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(widget.shift.icon, color: widget.shift.iconColor, size: 28),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: AppText(
                                        shiftName,
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (shiftCode.isNotEmpty) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.slate100,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: AppText(
                                          shiftCode,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textColorSecondary,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isActive
                                            ? AppColors.successColor.withValues(alpha: 0.1)
                                            : AppColors.slate200,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: AppText(
                                        isActive ? 'Active' : 'Inactive',
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: isActive ? AppColors.successColor : AppColors.textColorSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                AppText(
                                  '$startTime - $endTime  |  Net: $netDuration (Gross: $grossDuration)  |  $shiftType',
                                  fontSize: 11,
                                  color: AppColors.textColorSecondary,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Premium Scrollable Segmented Tab Bar
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.slate200.withValues(alpha: 0.6)),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          isScrollable: true,
                          tabAlignment: TabAlignment.start,
                          dividerColor: Colors.transparent,
                          indicatorSize: TabBarIndicatorSize.tab,
                          indicator: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          labelColor: AppColors.primaryColor,
                          unselectedLabelColor: AppColors.textColorSecondary,
                          labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          labelPadding: const EdgeInsets.symmetric(horizontal: 20),
                          tabs: const [
                            Tab(height: 36, text: 'Overview'),
                            Tab(height: 36, text: 'Employees'),
                            Tab(height: 36, text: 'Schedule'),
                            Tab(height: 36, text: 'Attendance'),
                          ],
                        ),
                      ),
                    ),

                    // Tab Contents
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildOverviewTab(details),
                          _buildEmployeesTab(details),
                          _buildScheduleTab(details),
                          _buildAttendanceTab(details),
                          // _buildHistoryTab(details),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      );
    });
  }

  // ----------------------------------------------------
  // Tab 1: Overview
  // ----------------------------------------------------
  Widget _buildOverviewTab(ShiftDataModel? details) {
    final assignedCount = details?.assignedEmployeesCount ?? details?.assignedEmployees.length ?? widget.shift.employeesCount;
    final workingDaysCount = details?.workingDays.where((w) => w.enabled).length ?? 6;
    final breakDuration = details?.breakDuration ?? widget.shift.breakDuration;
    final breakType = details?.breaks.isNotEmpty == true ? details!.breaks.first.type : widget.shift.breakType;
    final gracePeriod = details?.gracePeriodMinutes != null ? '${details!.gracePeriodMinutes} Minutes' : widget.shift.gracePeriod;
    final overtimeStatus = details?.overtimeEnabled ?? widget.shift.enableOvertime;
    final grossDuration = details?.grossDuration ?? '9h 00m';
    final netDuration = details?.netWorkingDuration ?? details?.totalDuration ?? widget.shift.workingHours;
    final description = details?.description ?? widget.shift.description;
    final shiftName = details?.name.isNotEmpty == true ? details!.name : widget.shift.name;
    final breaksList = details?.breaks ?? [];

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shift Overview Card
          _buildCard(
            title: 'Shift Overview',
            child: Column(
              children: [
                _buildOverviewRow('Shift Code', details?.code ?? widget.shift.code),
                const Divider(height: 16, color: AppColors.slate100),
                _buildOverviewRow('Shift Type', details?.shiftType ?? widget.shift.type),
                const Divider(height: 16, color: AppColors.slate100),
                _buildOverviewRow('Shift Timings', '${details?.startTime ?? widget.shift.startTime} - ${details?.endTime ?? widget.shift.endTime}'),
                const Divider(height: 16, color: AppColors.slate100),
                _buildOverviewRow('Cross Midnight', (details?.crossMidnight ?? widget.shift.crossMidnight) ? 'Yes' : 'No'),
                const Divider(height: 16, color: AppColors.slate100),
                _buildOverviewRow('Employees Assigned', '$assignedCount Members'),
                const Divider(height: 16, color: AppColors.slate100),
                _buildOverviewRow('Working Days', '$workingDaysCount Days / Week'),
                const Divider(height: 16, color: AppColors.slate100),
                _buildOverviewRow('Gross Duration', grossDuration),
                const Divider(height: 16, color: AppColors.slate100),
                _buildOverviewRow('Net Working Duration', netDuration),
                const Divider(height: 16, color: AppColors.slate100),
                _buildOverviewRow('Total Break Duration', '$breakDuration ($breakType)'),
                const Divider(height: 16, color: AppColors.slate100),
                _buildOverviewRow('Grace Period', gracePeriod),
                const Divider(height: 16, color: AppColors.slate100),
                _buildOverviewRow('Overtime Status', overtimeStatus ? 'Enabled' : 'Disabled'),
              ],
            ),
          ),

          // Breaks Section if breaks are defined
          if (breaksList.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildCard(
              title: 'Configured Breaks (${breaksList.length})',
              child: Column(
                children: breaksList.map((b) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.slate50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.slate200),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Iconsax.coffee, size: 16, color: AppColors.primaryColor),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(b.name, fontSize: 13, fontWeight: FontWeight.bold),
                              const SizedBox(height: 2),
                              AppText('${b.startTime} - ${b.endTime} (${b.type})', fontSize: 11, color: AppColors.textColorSecondary),
                            ],
                          ),
                        ),
                        if (b.durationMinutes != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: AppText('${b.durationMinutes} min', fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue),
                          ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],

          if (description.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildCard(
              title: 'Description',
              child: AppText(
                description,
                fontSize: 13,
                color: AppColors.textColorSecondary,
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Quick Actions Card
          _buildCard(
            title: 'Quick Actions',
            child: Column(
              children: [
                _buildQuickActionTile(
                  icon: Iconsax.edit,
                  iconColor: Colors.blue,
                  title: 'Edit Shift',
                  subtitle: 'Modify operational timings, breaks, or rules',
                  onTap: () async {
                    final res = await Get.to(() => CreateShiftScreen(
                          shiftToEdit: widget.shift,
                          shiftDataToEdit: details,
                        ));
                    if (res == true) {
                      _controller.fetchShiftDetails(widget.shift.id);
                      _controller.fetchShifts();
                    }
                  },
                ),
                const Divider(height: 12, color: AppColors.slate100),
                _buildQuickActionTile(
                  icon: Iconsax.profile_2user,
                  iconColor: Colors.green,
                  title: 'Assign Employees',
                  subtitle: 'Add or transfer team members to this shift',
                  onTap: () async {
                    final res = await Get.to(() => AssignShiftScreen(
                          preSelectedShift: widget.shift,
                          preSelectedShiftData: details,
                        ));
                    if (res == true) {
                      _controller.fetchShiftDetails(widget.shift.id);
                      _controller.fetchShifts();
                    }
                  },
                ),
               /* const Divider(height: 12, color: AppColors.slate100),
                _buildQuickActionTile(
                  icon: Iconsax.copy,
                  iconColor: Colors.purple,
                  title: 'Duplicate Shift',
                  subtitle: 'Clone this configuration to create a new shift',
                  onTap: () {
                    _controller.duplicateShift(widget.shift);
                    Get.snackbar(
                      'Shift Cloned',
                      'A copy of ${widget.shift.name} has been added.',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.black87,
                      colorText: Colors.white,
                    );
                  },
                ),
                const Divider(height: 12, color: AppColors.slate100),
                _buildQuickActionTile(
                  icon: widget.shift.isActive ? Iconsax.slash : Iconsax.tick_circle,
                  iconColor: widget.shift.isActive ? Colors.red : Colors.green,
                  title: widget.shift.isActive ? 'Deactivate Shift' : 'Activate Shift',
                  subtitle: widget.shift.isActive
                      ? 'Mark inactive and remove from active assignments'
                      : 'Restore shift to active operations',
                  onTap: () {
                    _controller.toggleShiftStatus(widget.shift);
                  },
                ),*/
                const Divider(height: 12, color: AppColors.slate100),
                _buildQuickActionTile(
                  icon: Iconsax.trash,
                  iconColor: Colors.redAccent,
                  title: 'Delete Shift',
                  subtitle: 'Permanently remove this shift configuration',
                  onTap: () => _showDeleteConfirmationDialog(context, shiftName),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // Tab 2: Employees (Live API data: assigned_employees)
  // ----------------------------------------------------
  Widget _buildEmployeesTab(ShiftDataModel? details) {
    final assignedEmployees = details?.assignedEmployees ?? [];
    final filtered = assignedEmployees.where((emp) {
      if (_employeeSearchQuery.isEmpty) return true;
      final q = _employeeSearchQuery.toLowerCase();
      final nameMatch = emp.name.toLowerCase().contains(q);
      final idMatch = emp.employeeId.toLowerCase().contains(q);
      final emailMatch = emp.email.toLowerCase().contains(q);
      final deptMatch = (emp.department ?? '').toLowerCase().contains(q);
      final desigMatch = (emp.designation ?? '').toLowerCase().contains(q);
      return nameMatch || idMatch || emailMatch || deptMatch || desigMatch;
    }).toList();

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  AppText('Assigned Team', fontSize: 15, fontWeight: FontWeight.bold),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: AppText(
                      '${assignedEmployees.length}',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: () async {
                  final res = await Get.to(() => AssignShiftScreen(
                        preSelectedShift: widget.shift,
                        preSelectedShiftData: details,
                      ));
                  if (res == true) {
                    _controller.fetchShiftDetails(widget.shift.id);
                    _controller.fetchShifts();
                  }
                },
                icon: const Icon(Icons.add, size: 16, color: AppColors.primaryColor),
                label: const AppText('Assign More', fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Search Bar if employees exist
          if (assignedEmployees.isNotEmpty) ...[
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.slate200),
              ),
              child: TextField(
                controller: _employeeSearchController,
                onChanged: (val) {
                  setState(() {
                    _employeeSearchQuery = val.trim();
                  });
                },
                style: const TextStyle(fontSize: 13, color: AppColors.textColorPrimary),
                decoration: InputDecoration(
                  hintText: 'Search by employee name, ID, or department...',
                  hintStyle: const TextStyle(color: AppColors.textColorHint, fontSize: 12),
                  prefixIcon: const Icon(Iconsax.search_normal, color: AppColors.textColorHint, size: 18),
                  suffixIcon: _employeeSearchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 16, color: AppColors.textColorHint),
                          onPressed: () {
                            _employeeSearchController.clear();
                            setState(() {
                              _employeeSearchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],

          if (assignedEmployees.isEmpty)
            Container(
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
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.slate50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Iconsax.profile_2user, size: 36, color: AppColors.textColorHint),
                  ),
                  const SizedBox(height: 12),
                  const AppText(
                    'No employees assigned to this shift',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColorPrimary,
                  ),
                  const SizedBox(height: 4),
                  const AppText(
                    'Assign staff to enable scheduled tracking and automated attendance.',
                    fontSize: 11,
                    color: AppColors.textColorHint,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final res = await Get.to(() => AssignShiftScreen(
                            preSelectedShift: widget.shift,
                            preSelectedShiftData: details,
                          ));
                      if (res == true) {
                        _controller.fetchShiftDetails(widget.shift.id);
                        _controller.fetchShifts();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.add, size: 16, color: Colors.white),
                    label: const AppText('Assign Employees', fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )
          else if (filtered.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.slate200),
              ),
              child: const Center(
                child: AppText('No matching employees found', fontSize: 13, color: AppColors.textColorHint),
              ),
            )
          else
            ...filtered.map((emp) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.slate200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.015),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    if (emp.avatar != null && emp.avatar!.isNotEmpty)
                      CircleAvatar(
                        radius: 22,
                        backgroundImage: NetworkImage(emp.avatar!),
                        backgroundColor: AppColors.primaryLight,
                      )
                    else
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.primaryLight,
                        child: AppText(
                          emp.name.split(' ').map((n) => n.isNotEmpty ? n[0] : '').take(2).join(),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
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
                                  emp.name,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (emp.employeeId.isNotEmpty) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
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
                            ],
                          ),
                          const SizedBox(height: 3),
                          AppText(
                            '${emp.designation ?? 'Member'}  •  ${emp.department ?? 'General'}',
                            fontSize: 11,
                            color: AppColors.textColorSecondary,
                          ),
                          if (emp.email.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            AppText(
                              emp.email,
                              fontSize: 10,
                              color: AppColors.textColorHint,
                            ),
                          ],
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (emp.status?.toLowerCase() == 'active' || emp.status == null)
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: AppText(
                        emp.status ?? 'Active',
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: (emp.status?.toLowerCase() == 'active' || emp.status == null)
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // Tab 3: Schedule (Live API data: working_days)
  // ----------------------------------------------------
  Widget _buildScheduleTab(ShiftDataModel? details) {
    final workingDays = details?.workingDays.isNotEmpty == true
        ? details!.workingDays
        : [
            ShiftWorkingDayDataModel(day: 'Monday', enabled: true, startTime: '10:00', endTime: '19:00'),
            ShiftWorkingDayDataModel(day: 'Tuesday', enabled: true, startTime: '10:00', endTime: '19:00'),
            ShiftWorkingDayDataModel(day: 'Wednesday', enabled: true, startTime: '10:00', endTime: '19:00'),
            ShiftWorkingDayDataModel(day: 'Thursday', enabled: true, startTime: '10:00', endTime: '19:00'),
            ShiftWorkingDayDataModel(day: 'Friday', enabled: true, startTime: '10:00', endTime: '19:00'),
            ShiftWorkingDayDataModel(day: 'Saturday', enabled: true, startTime: '10:00', endTime: '19:00'),
            ShiftWorkingDayDataModel(day: 'Sunday', enabled: false, startTime: '10:00', endTime: '19:00'),
          ];

    final activeDaysCount = workingDays.where((d) => d.enabled).length;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Weekly Schedule Summary Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Iconsax.calendar_1, color: AppColors.primaryColor, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        '$activeDaysCount Working Days / Week',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                      const SizedBox(height: 2),
                      AppText(
                        'Standard shift hours: ${details?.startTime ?? widget.shift.startTime} to ${details?.endTime ?? widget.shift.endTime}',
                        fontSize: 11,
                        color: AppColors.textColorSecondary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Days List
          ...workingDays.map((d) {
            final isWorking = d.enabled;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isWorking ? AppColors.slate200 : const Color(0xFFF1F5F9),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        isWorking ? Icons.check_circle_rounded : Icons.remove_circle_outline_rounded,
                        color: isWorking ? Colors.green : AppColors.textColorHint,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      AppText(
                        d.day,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isWorking ? AppColors.textColorPrimary : AppColors.textColorHint,
                      ),
                    ],
                  ),
                  if (isWorking)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.slate50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.slate200),
                      ),
                      child: Row(
                        children: [
                          const Icon(Iconsax.clock, size: 14, color: AppColors.primaryColor),
                          const SizedBox(width: 6),
                          AppText('${d.startTime} - ${d.endTime}', fontSize: 12, fontWeight: FontWeight.w600),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.slate100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const AppText('Weekly Off', fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textColorSecondary),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // Tab 4: Attendance Rules (Live API data: grace, late, overtime, etc.)
  // ----------------------------------------------------
  Widget _buildAttendanceTab(ShiftDataModel? details) {
    final graceMinutes = details?.gracePeriodMinutes ?? 15;
    final graceTimeLate = details?.graceTimeLate ?? '00:15';
    final lateAfterMinutes = details?.lateAfterMinutes ?? 15;
    final lateThresholdMinutes = details?.lateThresholdMinutes ?? 30;
    final autoMarkLate = details?.autoMarkLate ?? true;
    final autoMarkHalfDay = details?.autoMarkHalfDay ?? true;
    final earlyLeavingAllowed = details?.earlyLeavingAllowed ?? false;

    final minWorkingMinutes = details?.minimumWorkingMinutes ?? 480;
    final halfDayAfterMinutes = details?.halfDayAfterMinutes ?? 240;

    final overtimeEnabled = details?.overtimeEnabled ?? true;
    final overtimeAfter = details?.overtimeAfter ?? '08:00';
    final overtimeStartsAfterMinutes = details?.overtimeStartsAfterMinutes ?? 480;
    final minimumOvertimeMinutes = details?.minimumOvertimeMinutes ?? 30;
    final overtimeCalculation = details?.overtimeCalculation ?? 'Hourly';
    final overtimeApprovalRequired = details?.overtimeApprovalRequired ?? true;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Punctuality & Grace Card
          _buildCard(
            title: 'Punctuality & Grace Rules',
            child: Column(
              children: [
                _buildOverviewRow('Grace Period', _formatMinutes(graceMinutes)),
                const Divider(height: 16, color: AppColors.slate100),
                _buildOverviewRow('Grace Time (Late)', graceTimeLate),
                const Divider(height: 16, color: AppColors.slate100),
                _buildOverviewRow('Mark Late After', _formatMinutes(lateAfterMinutes)),
                const Divider(height: 16, color: AppColors.slate100),
                _buildOverviewRow('Late Threshold Deduction', _formatMinutes(lateThresholdMinutes)),
                const Divider(height: 16, color: AppColors.slate100),
                _buildOverviewRow('Auto Mark Late', autoMarkLate ? 'Enabled' : 'Disabled'),
                const Divider(height: 16, color: AppColors.slate100),
                _buildOverviewRow('Auto Mark Half Day', autoMarkHalfDay ? 'Enabled' : 'Disabled'),
                const Divider(height: 16, color: AppColors.slate100),
                _buildOverviewRow('Early Leaving Allowed', earlyLeavingAllowed ? 'Allowed' : 'Not Allowed'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Working Hours Policy Card
          _buildCard(
            title: 'Working Hours & Deduction Thresholds',
            child: Column(
              children: [
                _buildOverviewRow('Minimum Daily Hours', _formatMinutes(minWorkingMinutes)),
                const Divider(height: 16, color: AppColors.slate100),
                _buildOverviewRow('Half Day Trigger After', _formatMinutes(halfDayAfterMinutes)),
                const Divider(height: 16, color: AppColors.slate100),
                _buildOverviewRow('Gross Total Duration', details?.grossDuration ?? '9h 00m'),
                const Divider(height: 16, color: AppColors.slate100),
                _buildOverviewRow('Net Working Duration', details?.netWorkingDuration ?? '8h 00m'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Overtime Policy Card
          _buildCard(
            title: 'Overtime Policy',
            child: Column(
              children: [
                _buildOverviewRow('Overtime Status', overtimeEnabled ? 'Enabled' : 'Disabled'),
                const Divider(height: 16, color: AppColors.slate100),
                _buildOverviewRow('Overtime After Time', overtimeAfter),
                const Divider(height: 16, color: AppColors.slate100),
                _buildOverviewRow('Overtime Starts After', _formatMinutes(overtimeStartsAfterMinutes)),
                const Divider(height: 16, color: AppColors.slate100),
                _buildOverviewRow('Minimum Overtime Duration', _formatMinutes(minimumOvertimeMinutes)),
                const Divider(height: 16, color: AppColors.slate100),
                _buildOverviewRow('Calculation Mode', overtimeCalculation),
                const Divider(height: 16, color: AppColors.slate100),
                _buildOverviewRow('Manager Approval', overtimeApprovalRequired ? 'Mandatory' : 'Automatic'),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // Tab 5: History / Audit
  // ----------------------------------------------------
  Widget _buildHistoryTab(ShiftDataModel? details) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shift Timestamps Card from API
          _buildCard(
            title: 'Audit & System Timestamps',
            child: Column(
              children: [
                _buildOverviewRow('Created At', _formatDateString(details?.createdAt)),
                const Divider(height: 16, color: AppColors.slate100),
                _buildOverviewRow('Last Updated At', _formatDateString(details?.updatedAt)),
                const Divider(height: 16, color: AppColors.slate100),
                _buildOverviewRow('Shift Status', details?.status ?? (widget.shift.isActive ? 'Active' : 'Inactive')),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const AppText('Activity Log', fontSize: 14, fontWeight: FontWeight.bold),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.slate200),
                ),
                child: const Row(
                  children: [
                    AppText('All Activities', fontSize: 11, fontWeight: FontWeight.w600),
                    Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.textColorSecondary),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ..._controller.historyList.map((item) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.slate200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: item.actionColor.withValues(alpha: 0.1),
                    child: Icon(
                      item.action == 'Created'
                          ? Iconsax.add_circle
                          : item.action == 'Assigned'
                              ? Iconsax.user_add
                              : item.action == 'Deactivated'
                                  ? Iconsax.slash
                                  : Iconsax.edit_2,
                      size: 18,
                      color: item.actionColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AppText(item.userName, fontSize: 13, fontWeight: FontWeight.bold),
                            AppText(item.date, fontSize: 11, color: AppColors.textColorHint),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: item.actionColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: AppText(
                                item.action,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: item.actionColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: AppText(
                                item.details,
                                fontSize: 12,
                                color: AppColors.textColorSecondary,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // Helpers
  // ----------------------------------------------------
  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(title, fontSize: 15, fontWeight: FontWeight.bold),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildOverviewRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText(label, fontSize: 13, color: AppColors.textColorSecondary),
        AppText(value, fontSize: 13, fontWeight: FontWeight.bold),
      ],
    );
  }

  Widget _buildQuickActionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(title, fontSize: 13, fontWeight: FontWeight.bold),
                  AppText(subtitle, fontSize: 11, color: AppColors.textColorHint),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textColorHint),
          ],
        ),
      ),
    );
  }
}
