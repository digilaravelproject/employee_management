import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../controllers/admin_flow_controller.dart';
import '../models/admin_flow_models.dart';
import '../widgets/admin_flow_widgets.dart';

class AdminHandoverHistoryScreen extends StatelessWidget {
  final AdminFlowTask? task;

  const AdminHandoverHistoryScreen({
    super.key,
    this.task,
  });

  @override
  Widget build(BuildContext context) {
    final controller = AdminFlowController.to;

    return Scaffold(
      backgroundColor: AdminFlowTheme.surfaceSlate,
      appBar: const AdminFlowAppBar(
        title: 'Handover History',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task Subtitle Header Card
            AdminFlowCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Iconsax.task, color: AdminFlowTheme.primaryBlue, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Task',
                          style: TextStyle(fontSize: 11, color: AdminFlowTheme.textMuted, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          task?.title ?? 'Signup Flow',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AdminFlowTheme.textDark),
                        ),
                      ],
                    ),
                  ),
                  if (task != null) AdminFlowStatusBadge(status: task!.status),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Vertical Timeline Card
            AdminFlowCard(
              padding: const EdgeInsets.all(20),
              child: Obx(() {
                final list = task != null && task!.handoverHistory.isNotEmpty
                    ? task!.handoverHistory
                    : controller.globalHandoverHistory;

                if (list.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('No handover history recorded yet.', style: TextStyle(color: AdminFlowTheme.textMuted)),
                    ),
                  );
                }

                return Column(
                  children: List.generate(list.length, (index) {
                    final record = list[index];
                    final isLast = index == list.length - 1;
                    return _buildTimelineItem(record, isLast);
                  }),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(AdminFlowHandoverRecord record, bool isLast) {
    Color dotColor = AdminFlowTheme.primaryBlue;
    IconData dotIcon = Icons.arrow_forward_rounded;

    if (record.status.toLowerCase().contains('initial')) {
      dotColor = AdminFlowTheme.primaryBlue;
      dotIcon = Icons.add_rounded;
    } else if (record.status.toLowerCase().contains('accepted') || record.status.toLowerCase().contains('completed')) {
      dotColor = AdminFlowTheme.successText;
      dotIcon = Icons.check_rounded;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator with line
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: dotColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: dotColor, width: 1.5),
                ),
                child: Icon(dotIcon, size: 13, color: dotColor),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: const Color(0xFFE2E8F0),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),

          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Timestamp
                  Text(
                    record.timestamp,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AdminFlowTheme.textMuted,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Action Title
                  Text(
                    record.status == 'Initial Assignment'
                        ? 'Assigned to ${record.toUser}'
                        : record.status == 'Accepted'
                            ? 'Accepted by ${record.toUser}'
                            : 'Handover from ${record.fromUser} to ${record.toUser}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AdminFlowTheme.textDark,
                    ),
                  ),

                  // Reason / Details
                  if (record.reason.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      '(Reason: ${record.reason})',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AdminFlowTheme.primaryBlue,
                      ),
                    ),
                  ],

                  if (record.notes.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      record.notes,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AdminFlowTheme.textMuted,
                        height: 1.3,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
