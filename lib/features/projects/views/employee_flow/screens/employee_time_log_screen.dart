import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/employee_flow_models.dart';
import '../controllers/employee_flow_controller.dart';
import '../widgets/employee_flow_widgets.dart';

/// Screen 7: Time Log
/// Matches Mockup 7 from user reference:
/// - Header: "Time Log"
/// - Period Toggle: "This Week" / "This Month"
/// - 3 Metric Cards: Total Estimated (40h), Total Actual (36h), Remaining (4h)
/// - Task-wise Time Progress List with -1h badge and warning indicators
class EmployeeTimeLogScreen extends StatelessWidget {
  final bool showBackButton;
  final EmployeeFlowProject? project;

  const EmployeeTimeLogScreen({
    super.key,
    this.showBackButton = true,
    this.project,
  });

  @override
  Widget build(BuildContext context) {
    final controller = EmployeeFlowController.to;

    return Scaffold(
      backgroundColor: EmployeeFlowTheme.surfaceSlate,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: EmployeeFlowTheme.textDark),
                onPressed: () => Get.back(),
              )
            : null,
        title: Text(
          project != null ? '${project!.code} - Time Log' : 'Time Log',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: EmployeeFlowTheme.textDark,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Period Selector Toggle [This Week] / [This Month]
            Obx(() {
              final isThisWeek = controller.timeLogPeriod.value == 'This Week';

              return Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: EmployeeFlowTheme.cardBorder),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => controller.timeLogPeriod.value = 'This Week',
                        borderRadius: BorderRadius.circular(8),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isThisWeek ? EmployeeFlowTheme.primaryBlue : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'This Week',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isThisWeek ? FontWeight.w700 : FontWeight.w500,
                              color: isThisWeek ? Colors.white : EmployeeFlowTheme.textMuted,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () => controller.timeLogPeriod.value = 'This Month',
                        borderRadius: BorderRadius.circular(8),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: !isThisWeek ? EmployeeFlowTheme.primaryBlue : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'This Month',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: !isThisWeek ? FontWeight.w700 : FontWeight.w500,
                              color: !isThisWeek ? Colors.white : EmployeeFlowTheme.textMuted,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 16),

            // 2. Metrics Summary Row: Total Estimated, Total Actual, Remaining
            Obx(() {
              final items = project != null
                  ? controller.getTimeLogItemsForProject(project!.id)
                  : controller.timeLogItems;

              final totalEst = items.fold<double>(0.0, (acc, item) => acc + item.allocatedHours);
              final totalAct = items.fold<double>(0.0, (acc, item) => acc + item.actualHours);
              final rem = (totalEst - totalAct);

              final estimated = '${totalEst.toStringAsFixed(0)}h';
              final actual = '${totalAct.toStringAsFixed(1)}h';
              final remaining = '${rem > 0 ? rem.toStringAsFixed(1) : 0}h';

              return Row(
                children: [
                  Expanded(
                    child: _buildMetricBox(
                      label: 'Total Estimated',
                      value: estimated,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMetricBox(
                      label: 'Total Actual',
                      value: actual,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMetricBox(
                      label: 'Remaining',
                      value: remaining,
                    ),
                  ),
                ],
              );
            }),

            const SizedBox(height: 24),

            // 3. Task-wise Time Section
            const Text(
              'Task-wise Time',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: EmployeeFlowTheme.textDark,
              ),
            ),
            const SizedBox(height: 12),

            // Items list matching Screenshot 7
            Obx(() {
              final items = project != null
                  ? controller.getTimeLogItemsForProject(project!.id)
                  : controller.timeLogItems;
              return Column(
                children: items.map((item) => _buildTaskTimeRow(item)).toList(),
              );
            }),

            const SizedBox(height: 20),

            // Today's Work Punch Log
            EmployeeFlowCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Today's Active Logs",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: EmployeeFlowTheme.textDark,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: EmployeeFlowTheme.successBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          '6h 30m Logged Today',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: EmployeeFlowTheme.successText),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildLogEntry('09:30 AM', 'Started "Design Login Screen"', 'Work Session: 3h 00m'),
                  _buildLogEntry('12:30 PM', 'Paused for Lunch Break', 'Break Duration: 30m', isBreak: true),
                  _buildLogEntry('01:00 PM', 'Resumed "Design Login Screen"', 'Work Session: 2h 00m'),
                  _buildLogEntry('03:00 PM', 'Switched to "API Integration"', 'Work Session: 1h 00m'),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricBox({
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: EmployeeFlowTheme.cardBorder),
      ),
      child: Column(
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: EmployeeFlowTheme.textMuted,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: EmployeeFlowTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskTimeRow(dynamic item) {
    final progress = (item.actualHours / item.allocatedHours).clamp(0.0, 1.0);
    final isOvertime = item.isOvertime;
    final diffText = item.diffHours == 0.0 ? '0h' : '${item.diffHours.toInt()}h';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOvertime ? EmployeeFlowTheme.dangerRed.withValues(alpha: 0.3) : EmployeeFlowTheme.cardBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.taskTitle,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: EmployeeFlowTheme.textDark,
                  ),
                ),
              ),
              Row(
                children: [
                  Text(
                    '${item.actualHours.toInt()}h / ${item.allocatedHours.toInt()}h',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: EmployeeFlowTheme.textMuted,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    diffText,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isOvertime ? EmployeeFlowTheme.dangerRed : EmployeeFlowTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          EmployeeFlowProgressBar(
            progress: progress,
            isExceeded: isOvertime,
            activeColor: isOvertime ? EmployeeFlowTheme.dangerRed : EmployeeFlowTheme.successGreen,
            height: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildLogEntry(String time, String title, String subtitle, {bool isBreak = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isBreak ? EmployeeFlowTheme.warningBg : EmployeeFlowTheme.infoBg,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              time,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: isBreak ? EmployeeFlowTheme.warningOrange : EmployeeFlowTheme.primaryBlue,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: EmployeeFlowTheme.textDark),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: EmployeeFlowTheme.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
