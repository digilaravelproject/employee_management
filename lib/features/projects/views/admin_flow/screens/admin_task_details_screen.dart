import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../models/admin_flow_models.dart';
import '../widgets/admin_flow_widgets.dart';
import 'admin_handover_task_screen.dart';
import 'admin_handover_history_screen.dart';

class AdminTaskDetailsScreen extends StatelessWidget {
  final AdminFlowTask task;

  const AdminTaskDetailsScreen({
    super.key,
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminFlowTheme.surfaceSlate,
      appBar: const AdminFlowAppBar(
        title: 'Task Details',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task Header Card
            AdminFlowCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Iconsax.task, color: AdminFlowTheme.primaryBlue, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AdminFlowTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          task.moduleTitle,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AdminFlowTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AdminFlowStatusBadge(status: task.status),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Info Key-Value Grid Card
            AdminFlowCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                          label: 'Assigned To',
                          content: Row(
                            children: [
                              CircleAvatar(
                                radius: 12,
                                backgroundColor: AdminFlowTheme.infoBg,
                                child: Text(
                                  task.assigneeName.isNotEmpty ? task.assigneeName[0] : 'U',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AdminFlowTheme.primaryBlue),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  task.assigneeName,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AdminFlowTheme.textDark),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: _buildInfoItem(
                          label: 'Estimated Time',
                          content: Text(
                            task.estimatedTime,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AdminFlowTheme.textDark),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24, color: AdminFlowTheme.cardBorder),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                          label: 'Actual Time',
                          content: Text(
                            task.actualTime,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AdminFlowTheme.textDark),
                          ),
                        ),
                      ),
                      Expanded(
                        child: _buildInfoItem(
                          label: 'Due Date',
                          content: Text(
                            task.dueDate,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AdminFlowTheme.textDark),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24, color: AdminFlowTheme.cardBorder),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                          label: 'Start Date',
                          content: Text(
                            task.startDate,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AdminFlowTheme.textDark),
                          ),
                        ),
                      ),
                      Expanded(
                        child: _buildInfoItem(
                          label: 'Priority',
                          content: AdminFlowStatusBadge(
                            status: task.priority,
                            fontSize: 10,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (task.isTimeExceeded) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFF87171)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Extra Time Exceeded: +${task.extraHours.toInt()}h extra time taken (${task.actualHours.toInt()}h spent vs ${task.allocatedHours.toInt()}h allocated).',
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF991B1B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Description Card
            AdminFlowCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AdminFlowTheme.textMuted),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    task.description,
                    style: const TextStyle(fontSize: 13, color: AdminFlowTheme.textDark, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Handover History Section Card
            AdminFlowCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Handover History',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AdminFlowTheme.textDark),
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.to(() => AdminHandoverHistoryScreen(task: task));
                        },
                        child: const Text(
                          'View All',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AdminFlowTheme.primaryBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Snippet nodes
                  _buildHistorySnippet(
                    title: 'Assigned to ${task.assigneeName}',
                    subtitle: '12 Sep 2025 10:00 AM',
                    isFirst: true,
                  ),
                  const SizedBox(height: 12),
                  _buildHistorySnippet(
                    title: 'Handover from Rohit Verma to ${task.assigneeName}',
                    subtitle: '15 Sep 2025 02:30 PM (Reason: Workload balance)',
                    isFirst: false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Handover Task Action Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.to(() => AdminHandoverTaskScreen(task: task));
                },
                icon: const Icon(Iconsax.refresh_2, size: 18, color: Colors.white),
                label: const Text(
                  'Handover Task',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminFlowTheme.primaryBlue,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({required String label, required Widget content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AdminFlowTheme.textMuted),
        ),
        const SizedBox(height: 4),
        content,
      ],
    );
  }

  Widget _buildHistorySnippet({required String title, required String subtitle, required bool isFirst}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(top: 5),
          decoration: BoxDecoration(
            color: isFirst ? AdminFlowTheme.primaryBlue : const Color(0xFF64748B),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AdminFlowTheme.textDark),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 11, color: AdminFlowTheme.textMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
