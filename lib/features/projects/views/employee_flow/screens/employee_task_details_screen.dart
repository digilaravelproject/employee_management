import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../controllers/employee_flow_controller.dart';
import '../models/employee_flow_models.dart';
import '../widgets/employee_flow_widgets.dart';
import 'employee_request_handover_screen.dart';
import 'employee_task_history_screen.dart';

/// Screen: Task Details with Live Timer, Overtime Red Warning, Break Logger & Sessions
class EmployeeTaskDetailsScreen extends StatelessWidget {
  final EmployeeFlowTask task;

  const EmployeeTaskDetailsScreen({
    super.key,
    required this.task,
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: EmployeeFlowTheme.textDark),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Task Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: EmployeeFlowTheme.textDark,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Iconsax.clock, color: EmployeeFlowTheme.primaryBlue, size: 22),
            tooltip: 'All Task History',
            onPressed: () => Get.to(() => EmployeeTaskHistoryScreen(task: task)),
          ),
          IconButton(
            icon: const Icon(Iconsax.repeat, color: EmployeeFlowTheme.primaryBlue, size: 22),
            tooltip: 'Request Handover',
            onPressed: () => Get.to(() => EmployeeRequestHandoverScreen(task: task)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Task Header Card
            EmployeeFlowCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: EmployeeFlowTheme.infoBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          task.moduleTitle,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: EmployeeFlowTheme.primaryBlue,
                          ),
                        ),
                      ),
                      EmployeeFlowStatusBadge(status: task.status),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    task.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: EmployeeFlowTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Iconsax.folder_2, size: 14, color: EmployeeFlowTheme.textHint),
                      const SizedBox(width: 4),
                      Text(
                        task.projectName,
                        style: const TextStyle(
                          fontSize: 12,
                          color: EmployeeFlowTheme.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(height: 1, color: EmployeeFlowTheme.cardBorder),
                  const SizedBox(height: 14),
                  // Dates & Priority
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildHeaderInfoTile(
                        label: 'Start Date',
                        value: task.startDate,
                        icon: Iconsax.calendar,
                      ),
                      _buildHeaderInfoTile(
                        label: 'Due Date',
                        value: task.dueDate,
                        icon: Iconsax.calendar_tick,
                      ),
                      _buildHeaderInfoTile(
                        label: 'Priority',
                        value: task.priority,
                        icon: Iconsax.flag,
                        valueColor: task.priority == 'High' ? EmployeeFlowTheme.dangerRed : EmployeeFlowTheme.textDark,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 2. LIVE WORK TRACKING & TIMER CARD (CORE FEATURE)
            Obx(() {
              // Ensure Rx observables are accessed so GetX registers the widget
              final _ = controller.allTasks.length;
              final active = controller.activeRunningTask.value;
              final currentTask = controller.allTasks.firstWhereOrNull((t) => t.id == task.id) ??
                  (active?.id == task.id ? active! : task);

              final isCurrentlyRunning = currentTask.isRunning && !currentTask.isPaused;
              final isCurrentlyPaused = currentTask.isRunning && currentTask.isPaused;
              final isExceeded = currentTask.isTimeExceeded;

              return EmployeeFlowCard(
                borderColor: isExceeded
                    ? EmployeeFlowTheme.dangerRed
                    : (isCurrentlyRunning ? EmployeeFlowTheme.primaryBlue : EmployeeFlowTheme.cardBorder),
                backgroundColor: isExceeded ? const Color(0xFFFFF5F5) : Colors.white,
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isCurrentlyRunning
                                    ? EmployeeFlowTheme.primaryBlue
                                    : (isCurrentlyPaused ? EmployeeFlowTheme.warningOrange : EmployeeFlowTheme.textHint),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isCurrentlyRunning
                                  ? 'Active Work Timer'
                                  : (isCurrentlyPaused ? 'Timer Paused (On Break)' : 'Work Timer'),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isCurrentlyRunning
                                    ? EmployeeFlowTheme.primaryBlue
                                    : (isCurrentlyPaused ? EmployeeFlowTheme.warningOrange : EmployeeFlowTheme.textDark),
                              ),
                            ),
                          ],
                        ),
                        // Overtime Alert Badge
                        if (isExceeded)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: EmployeeFlowTheme.dangerBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: const [
                                Icon(Icons.warning_amber_rounded, size: 14, color: EmployeeFlowTheme.dangerRed),
                                SizedBox(width: 4),
                                Text(
                                  'TIME EXCEEDED',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: EmployeeFlowTheme.dangerRed,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Big Timer Display
                    Center(
                      child: Text(
                        currentTask.formattedSpentTime,
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          color: isExceeded ? EmployeeFlowTheme.dangerRed : EmployeeFlowTheme.textDark,
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Target / Allocated vs Spent Gauge
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isExceeded ? Colors.white : EmployeeFlowTheme.surfaceSlate,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isExceeded ? EmployeeFlowTheme.dangerRed.withValues(alpha: 0.3) : EmployeeFlowTheme.cardBorder,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Allocated: ${currentTask.allocatedHours.toStringAsFixed(0)}h',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: EmployeeFlowTheme.textMuted,
                                ),
                              ),
                              Text(
                                isExceeded
                                    ? 'Overtime: +${currentTask.overtimeHours.toStringAsFixed(1)}h'
                                    : 'Remaining: ${currentTask.remainingHours.toStringAsFixed(1)}h',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isExceeded ? EmployeeFlowTheme.dangerRed : EmployeeFlowTheme.primaryBlue,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          EmployeeFlowProgressBar(
                            progress: currentTask.progress,
                            isExceeded: isExceeded,
                            activeColor: isExceeded ? EmployeeFlowTheme.dangerRed : EmployeeFlowTheme.primaryBlue,
                            height: 7,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Timer Control Buttons: Start, Pause (Break), Resume, Stop
                    if (currentTask.status != 'Completed') ...[
                      Row(
                        children: [
                          if (!currentTask.isRunning)
                            Expanded(
                              child: SizedBox(
                                height: 46,
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.play_arrow_rounded, size: 20),
                                  label: const Text('Start Work Timer'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: EmployeeFlowTheme.primaryBlue,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  onPressed: () => controller.startTaskTimer(currentTask),
                                ),
                              ),
                            )
                          else ...[
                            // Pause / Resume Button
                            Expanded(
                              child: SizedBox(
                                height: 46,
                                child: OutlinedButton.icon(
                                  icon: Icon(
                                    isCurrentlyPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                                    size: 20,
                                  ),
                                  label: Text(isCurrentlyPaused ? 'Resume Work' : 'Take Break'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: isCurrentlyPaused
                                        ? EmployeeFlowTheme.primaryBlue
                                        : EmployeeFlowTheme.warningOrange,
                                    side: BorderSide(
                                      color: isCurrentlyPaused
                                          ? EmployeeFlowTheme.primaryBlue
                                          : EmployeeFlowTheme.warningOrange,
                                      width: 1.5,
                                    ),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  onPressed: () {
                                    if (isCurrentlyPaused) {
                                      controller.resumeTaskTimer();
                                    } else {
                                      _showBreakOptions(context, controller);
                                    }
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Save Session Button
                            SizedBox(
                              height: 46,
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.stop_rounded, size: 20),
                                label: const Text('Stop'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF475569),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: () => controller.stopTaskTimer(markCompleted: false),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Mark Completed Button
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.check_circle_outline, size: 18),
                          label: const Text('Mark Task Completed'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: EmployeeFlowTheme.successGreen,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => controller.stopTaskTimer(markCompleted: true),
                        ),
                      ),
                    ] else
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: EmployeeFlowTheme.successBg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.check_circle, color: EmployeeFlowTheme.successText, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Task Completed Successfully',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: EmployeeFlowTheme.successText,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 16),

            // 3. Task Description & Criteria
            EmployeeFlowCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: EmployeeFlowTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    task.description,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: EmployeeFlowTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 4. Work Sessions & Breaks History
            Obx(() {
              final _ = controller.allTasks.length;
              final active = controller.activeRunningTask.value;
              final currentTask = controller.allTasks.firstWhereOrNull((t) => t.id == task.id) ??
                  (active?.id == task.id ? active! : task);

              return EmployeeFlowCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Work & Break Logs',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: EmployeeFlowTheme.textDark,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Get.to(() => EmployeeTaskHistoryScreen(task: currentTask)),
                          child: const Text('Full History', style: TextStyle(fontSize: 12, color: EmployeeFlowTheme.primaryBlue)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (currentTask.workSessions.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'No work sessions recorded yet. Click "Start Work Timer" to begin.',
                          style: TextStyle(fontSize: 12, color: EmployeeFlowTheme.textMuted),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: currentTask.workSessions.length,
                        separatorBuilder: (context, index) => const Divider(height: 14, color: EmployeeFlowTheme.cardBorder),
                        itemBuilder: (context, index) {
                          final session = currentTask.workSessions[index];
                          final isBreak = session.isBreak;

                        return Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: isBreak ? EmployeeFlowTheme.warningBg : EmployeeFlowTheme.infoBg,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isBreak ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                size: 14,
                                color: isBreak ? EmployeeFlowTheme.warningOrange : EmployeeFlowTheme.primaryBlue,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isBreak ? 'Break: ${session.breakReason}' : 'Work Session',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: EmployeeFlowTheme.textDark,
                                    ),
                                  ),
                                  Text(
                                    '${session.formattedStartTime} - ${session.formattedEndTime}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: EmployeeFlowTheme.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              session.formattedDuration,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isBreak ? EmployeeFlowTheme.warningOrange : EmployeeFlowTheme.textDark,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                ],
              ),
            );
          }),

            const SizedBox(height: 16),

            // 5. Handover Audit Trail for this task
            if (task.handoverHistory.isNotEmpty) ...[
              EmployeeFlowCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Handover History for this Task',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: EmployeeFlowTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...task.handoverHistory.map((ho) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: EmployeeFlowTheme.surfaceSlate,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: EmployeeFlowTheme.cardBorder),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${ho.fromUser} → ${ho.toUser}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: EmployeeFlowTheme.textDark,
                                    ),
                                  ),
                                  EmployeeFlowStatusBadge(status: ho.status),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${ho.timestamp} • Reason: ${ho.reason}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: EmployeeFlowTheme.textMuted,
                                ),
                              ),
                              if (ho.notes.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  ho.notes,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: EmployeeFlowTheme.textDark,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Handover Request Action Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                icon: const Icon(Iconsax.repeat, size: 18),
                label: const Text('Handover This Task to Colleague'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: EmployeeFlowTheme.primaryBlue,
                  side: const BorderSide(color: EmployeeFlowTheme.primaryBlue),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Get.to(() => EmployeeRequestHandoverScreen(task: task)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderInfoTile({
    required String label,
    required String value,
    required IconData icon,
    Color? valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 13, color: EmployeeFlowTheme.textHint),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: EmployeeFlowTheme.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: valueColor ?? EmployeeFlowTheme.textDark,
          ),
        ),
      ],
    );
  }

  void _showBreakOptions(BuildContext context, EmployeeFlowController controller) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Break Type',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: EmployeeFlowTheme.textDark,
                  ),
                ),
                const SizedBox(height: 14),
                ListTile(
                  leading: const Icon(Icons.coffee, color: Colors.brown),
                  title: const Text('Tea / Coffee Break'),
                  onTap: () {
                    Get.back();
                    controller.pauseTaskTimer(reason: 'Tea / Coffee Break');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.lunch_dining, color: Colors.orange),
                  title: const Text('Lunch Break'),
                  onTap: () {
                    Get.back();
                    controller.pauseTaskTimer(reason: 'Lunch Break');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.groups, color: EmployeeFlowTheme.primaryBlue),
                  title: const Text('Team Discussion / Standup'),
                  onTap: () {
                    Get.back();
                    controller.pauseTaskTimer(reason: 'Team Standup');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.more_horiz, color: EmployeeFlowTheme.textMuted),
                  title: const Text('Other Break'),
                  onTap: () {
                    Get.back();
                    controller.pauseTaskTimer(reason: 'Personal Break');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
