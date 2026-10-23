import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../controllers/employee_flow_controller.dart';
import '../models/employee_flow_models.dart';
import '../widgets/employee_flow_widgets.dart';

/// Screen 9: Comprehensive Task History Screen
/// Fulfills user requirement:
/// "pura history dikhgi sbhi task ki and kisi task ko handover kiya how to bhi dikhga proper history me
/// and history me kon sa task kab start hua kitna time bcha hai proper sbhi kuchh mention rhe"
class EmployeeTaskHistoryScreen extends StatelessWidget {
  final EmployeeFlowTask? task;
  final EmployeeFlowProject? project;

  const EmployeeTaskHistoryScreen({
    super.key,
    this.task,
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: EmployeeFlowTheme.textDark),
          onPressed: () => Get.back(),
        ),
        title: Text(
          task != null
              ? 'Task History: ${task!.title}'
              : (project != null ? '${project!.code} - Task History' : 'Complete Tasks History'),
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: EmployeeFlowTheme.textDark,
          ),
        ),
        centerTitle: false,
      ),
      body: Obx(() {
        final tasksToShow = task != null
            ? [task!]
            : (project != null
                ? controller.getTasksForProject(project!.id)
                : controller.allTasks);

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          physics: const BouncingScrollPhysics(),
          itemCount: tasksToShow.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final t = tasksToShow[index];
            return _buildDetailedTaskHistoryCard(context, t);
          },
        );
      }),
    );
  }

  Widget _buildDetailedTaskHistoryCard(BuildContext context, EmployeeFlowTask t) {
    final isExceeded = t.isTimeExceeded;

    return EmployeeFlowCard(
      padding: const EdgeInsets.all(16),
      borderColor: isExceeded ? EmployeeFlowTheme.dangerRed.withValues(alpha: 0.5) : EmployeeFlowTheme.cardBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Title & Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: EmployeeFlowTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${t.moduleTitle} • ${t.projectName}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: EmployeeFlowTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              EmployeeFlowStatusBadge(status: t.status),
            ],
          ),

          const SizedBox(height: 14),

          // Start Date & Time Status
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isExceeded ? const Color(0xFFFFF5F5) : EmployeeFlowTheme.surfaceSlate,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isExceeded ? EmployeeFlowTheme.dangerRed.withValues(alpha: 0.3) : EmployeeFlowTheme.cardBorder,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Iconsax.calendar_1, size: 14, color: EmployeeFlowTheme.primaryBlue),
                        const SizedBox(width: 6),
                        Text(
                          'Started: ${t.startDate}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: EmployeeFlowTheme.textDark,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Iconsax.clock, size: 14, color: EmployeeFlowTheme.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          'Due: ${t.dueDate}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: EmployeeFlowTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Time calculations
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Allocated Time: ${t.allocatedHours.toStringAsFixed(0)}h',
                      style: const TextStyle(fontSize: 11, color: EmployeeFlowTheme.textMuted),
                    ),
                    Text(
                      'Time Spent: ${t.formattedSpentTime}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isExceeded ? EmployeeFlowTheme.dangerRed : EmployeeFlowTheme.textDark,
                      ),
                    ),
                    Text(
                      isExceeded
                          ? 'Overtime: +${t.overtimeHours.toStringAsFixed(1)}h'
                          : 'Time Left: ${t.remainingHours.toStringAsFixed(1)}h',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: isExceeded ? EmployeeFlowTheme.dangerRed : EmployeeFlowTheme.primaryBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                EmployeeFlowProgressBar(
                  progress: t.progress,
                  isExceeded: isExceeded,
                  activeColor: isExceeded ? EmployeeFlowTheme.dangerRed : EmployeeFlowTheme.primaryBlue,
                  height: 6,
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Work & Break Sessions Timeline for this task
          const Text(
            'Session History & Breaks',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: EmployeeFlowTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),

          if (t.workSessions.isEmpty)
            const Text(
              'No active timer session logged yet.',
              style: TextStyle(fontSize: 11, color: EmployeeFlowTheme.textMuted),
            )
          else
            ...t.workSessions.map((session) {
              final isBreak = session.isBreak;
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Icon(
                      isBreak ? Icons.pause_circle_filled : Icons.check_circle_outline,
                      size: 14,
                      color: isBreak ? EmployeeFlowTheme.warningOrange : EmployeeFlowTheme.primaryBlue,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isBreak ? 'Break (${session.breakReason})' : 'Active Work Session',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isBreak ? EmployeeFlowTheme.warningOrange : EmployeeFlowTheme.textDark,
                        ),
                      ),
                    ),
                    Text(
                      '${session.formattedStartTime} - ${session.formattedEndTime}',
                      style: const TextStyle(fontSize: 11, color: EmployeeFlowTheme.textMuted),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      session.formattedDuration,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: EmployeeFlowTheme.textDark,
                      ),
                    ),
                  ],
                ),
              );
            }),

          // Handover History for this task
          if (t.handoverHistory.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: EmployeeFlowTheme.cardBorder),
            const SizedBox(height: 10),
            Row(
              children: const [
                Icon(Iconsax.repeat, size: 14, color: EmployeeFlowTheme.primaryBlue),
                SizedBox(width: 6),
                Text(
                  'Handover Audit Record',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: EmployeeFlowTheme.textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ...t.handoverHistory.map((ho) => Container(
                  margin: const EdgeInsets.only(top: 6),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: EmployeeFlowTheme.surfaceSlate,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: EmployeeFlowTheme.cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${ho.fromUser} (${ho.fromUserRole}) → ${ho.toUser} (${ho.toUserRole})',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: EmployeeFlowTheme.textDark,
                            ),
                          ),
                          EmployeeFlowStatusBadge(status: ho.status, fontSize: 10),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${ho.timestamp} • Reason: ${ho.reason} • Progress at handover: ${ho.progressAtHandover.toInt()}%',
                        style: const TextStyle(fontSize: 11, color: EmployeeFlowTheme.textMuted),
                      ),
                      if (ho.notes.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          'Notes: "${ho.notes}"',
                          style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: EmployeeFlowTheme.textDark),
                        ),
                      ],
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }
}
