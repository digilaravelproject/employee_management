import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/shift_controller.dart';
import '../models/shift_model.dart';
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
  final ShiftController _controller = Get.find<ShiftController>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this, initialIndex: widget.initialTabIndex);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textColorPrimary, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Row(
          children: [
            Flexible(
              child: AppText(
                widget.shift.name,
                fontSize: 17,
                fontWeight: FontWeight.bold,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: widget.shift.isActive ? AppColors.successColor.withValues(alpha: 0.1) : AppColors.slate200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: AppText(
                widget.shift.isActive ? 'Active' : 'Inactive',
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: widget.shift.isActive ? AppColors.successColor : AppColors.textColorSecondary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Assign Employees',
            icon: const Icon(Iconsax.profile_2user, color: AppColors.primaryColor, size: 20),
            onPressed: () => Get.to(() => const AssignShiftScreen()),
          ),
          IconButton(
            tooltip: 'Edit Shift',
            icon: const Icon(Iconsax.edit, color: AppColors.textColorSecondary, size: 20),
            onPressed: () => Get.to(() => const CreateShiftScreen()),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.textColorSecondary),
            onSelected: (val) {
              if (val == 'duplicate') {
                _controller.duplicateShift(widget.shift);
                Get.snackbar('Duplicated', 'Shift duplicated successfully', snackPosition: SnackPosition.BOTTOM);
              } else if (val == 'toggle') {
                setState(() {
                  _controller.toggleShiftStatus(widget.shift);
                });
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'duplicate',
                child: Row(
                  children: [
                    Icon(Iconsax.copy, size: 18, color: AppColors.textColorPrimary),
                    SizedBox(width: 10),
                    AppText('Duplicate Shift', fontSize: 13),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'toggle',
                child: Row(
                  children: [
                    Icon(
                      widget.shift.isActive ? Iconsax.slash : Iconsax.tick_circle,
                      size: 18,
                      color: widget.shift.isActive ? Colors.red : Colors.green,
                    ),
                    const SizedBox(width: 10),
                    AppText(widget.shift.isActive ? 'Deactivate Shift' : 'Activate Shift', fontSize: 13),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner Card (Matching Panel 9)
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
                          AppText(widget.shift.name, fontSize: 17, fontWeight: FontWeight.bold),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.slate100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: AppText(
                              widget.shift.code,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textColorSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      AppText(
                        '${widget.shift.startTime} - ${widget.shift.endTime}  |  ${widget.shift.workingHours}  |  ${widget.shift.type}',
                        fontSize: 12,
                        color: AppColors.textColorSecondary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tab Bar (Overview, Employees, Schedule, Attendance, History)
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: AppColors.primaryColor,
              unselectedLabelColor: AppColors.textColorSecondary,
              indicatorColor: AppColors.primaryColor,
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Employees'),
                Tab(text: 'Schedule'),
                Tab(text: 'Attendance'),
                Tab(text: 'History'),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.slate200),

          // Tab Contents
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildEmployeesTab(),
                _buildScheduleTab(),
                _buildAttendanceTab(),
                _buildHistoryTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // Tab 1: Overview
  // ----------------------------------------------------
  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shift Overview Card
          _buildCard(
            title: 'Shift Overview',
            child: Column(
              children: [
                _buildOverviewRow('Employees Assigned', '${widget.shift.employeesCount} Members'),
                const Divider(height: 16, color: AppColors.slate100),
                _buildOverviewRow('Working Days', '6 Days / Week (Mon - Sat)'),
                const Divider(height: 16, color: AppColors.slate100),
                _buildOverviewRow('Weekly Off', 'Sunday'),
                const Divider(height: 16, color: AppColors.slate100),
                _buildOverviewRow('Break Duration', '${widget.shift.breakDuration} (${widget.shift.breakType})'),
                const Divider(height: 16, color: AppColors.slate100),
                _buildOverviewRow('Grace Period', widget.shift.gracePeriod),
                const Divider(height: 16, color: AppColors.slate100),
                _buildOverviewRow('Overtime Status', widget.shift.enableOvertime ? 'Enabled' : 'Disabled'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Quick Actions Card (Matching Panel 9)
          _buildCard(
            title: 'Quick Actions',
            child: Column(
              children: [
                _buildQuickActionTile(
                  icon: Iconsax.edit,
                  iconColor: Colors.blue,
                  title: 'Edit Shift',
                  subtitle: 'Modify operational timings, breaks, or rules',
                  onTap: () => Get.to(() => const CreateShiftScreen()),
                ),
                const Divider(height: 12, color: AppColors.slate100),
                _buildQuickActionTile(
                  icon: Iconsax.profile_2user,
                  iconColor: Colors.green,
                  title: 'Assign Employees',
                  subtitle: 'Add or transfer team members to this shift',
                  onTap: () => Get.to(() => const AssignShiftScreen()),
                ),
                const Divider(height: 12, color: AppColors.slate100),
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
                    setState(() {
                      _controller.toggleShiftStatus(widget.shift);
                    });
                  },
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
  // Tab 2: Employees
  // ----------------------------------------------------
  Widget _buildEmployeesTab() {
    final employeeList = widget.shift.assignedEmployeeNames.isNotEmpty
        ? widget.shift.assignedEmployeeNames
        : ['Rahul Kumar', 'Amit Sharma', 'Pooja Verma', 'Vikram Joshi', 'Sameer Ali'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText('Assigned Team (${employeeList.length})', fontSize: 14, fontWeight: FontWeight.bold),
              TextButton.icon(
                onPressed: () => Get.to(() => const AssignShiftScreen()),
                icon: const Icon(Icons.add, size: 16, color: AppColors.primaryColor),
                label: const AppText('Assign More', fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...employeeList.map((name) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.slate200),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primaryLight,
                    child: AppText(
                      name.split(' ').map((n) => n.isNotEmpty ? n[0] : '').take(2).join(),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(name, fontSize: 14, fontWeight: FontWeight.bold),
                        const SizedBox(height: 2),
                        const AppText('Active in shift  •  Mon-Sat', fontSize: 11, color: AppColors.textColorSecondary),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const AppText(
                      'Assigned',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
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
  // Tab 3: Schedule
  // ----------------------------------------------------
  Widget _buildScheduleTab() {
    final days = [
      {'day': 'Monday', 'working': true},
      {'day': 'Tuesday', 'working': true},
      {'day': 'Wednesday', 'working': true},
      {'day': 'Thursday', 'working': true},
      {'day': 'Friday', 'working': true},
      {'day': 'Saturday', 'working': true},
      {'day': 'Sunday', 'working': false},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: days.map((d) {
          final isWorking = d['working'] as bool;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.slate200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isWorking ? Icons.check_circle : Icons.remove_circle_outline,
                      color: isWorking ? Colors.green : AppColors.textColorHint,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    AppText(
                      d['day'] as String,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isWorking ? AppColors.textColorPrimary : AppColors.textColorHint,
                    ),
                  ],
                ),
                isWorking
                    ? AppText('${widget.shift.startTime} - ${widget.shift.endTime}', fontSize: 12, fontWeight: FontWeight.w600)
                    : Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.slate100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const AppText('Weekly Off', fontSize: 11, color: AppColors.textColorSecondary),
                      ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ----------------------------------------------------
  // Tab 4: Attendance Rules
  // ----------------------------------------------------
  Widget _buildAttendanceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildCard(
            title: 'Punctuality & Grace Rules',
            child: Column(
              children: [
                _buildOverviewRow('Grace Period', widget.shift.gracePeriod),
                const Divider(height: 16, color: AppColors.slate100),
                _buildOverviewRow('Mark Late After', widget.shift.lateAfter),
                const Divider(height: 16, color: AppColors.slate100),
                _buildOverviewRow('Late Threshold Deduction', widget.shift.lateThreshold),
                const Divider(height: 16, color: AppColors.slate100),
                _buildOverviewRow('Auto Mark Late', widget.shift.autoMarkLate ? 'Enabled' : 'Disabled'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildCard(
            title: 'Hours & Overtime Policy',
            child: Column(
              children: [
                _buildOverviewRow('Minimum Daily Hours', widget.shift.minWorkingHours),
                const Divider(height: 16, color: AppColors.slate100),
                _buildOverviewRow('Half Day Threshold', widget.shift.halfDayAfter),
                const Divider(height: 16, color: AppColors.slate100),
                _buildOverviewRow('Overtime Starts After', widget.shift.otStartsAfter),
                const Divider(height: 16, color: AppColors.slate100),
                _buildOverviewRow('Minimum OT Duration', widget.shift.minimumOT),
                const Divider(height: 16, color: AppColors.slate100),
                _buildOverviewRow('OT Calculation Base', widget.shift.otCalculation),
                const Divider(height: 16, color: AppColors.slate100),
                _buildOverviewRow('Manager Approval', widget.shift.approvalRequired ? 'Mandatory' : 'Automatic'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // Tab 5: History (Matching Panel 11: Shift History)
  // ----------------------------------------------------
  Widget _buildHistoryTab() {
    return Obx(() {
      final logs = _controller.historyList;

      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const AppText('Audit Trail & Activities', fontSize: 14, fontWeight: FontWeight.bold),
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
            ...logs.map((item) {
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
    });
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
