import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../controllers/employee_flow_controller.dart';
import '../models/employee_flow_models.dart';
import '../widgets/employee_flow_widgets.dart';

/// Screen 6: Handover History
/// Matches Mockup 6 from user reference:
/// - Header: "Handover History"
/// - Total Handovers badge card: "2"
/// - Chronological Timeline items:
///   - "Rohit Verma → Sneha Patel" | "15 Sep 2025, 02:00 PM" | "Reason: Workload balance" | "View Details"
///   - "Sneha Patel → Neha Singh" | "10 Sep 2025, 11:30 AM" | "Reason: Leave" | "View Details"
class EmployeeHandoverHistoryScreen extends StatelessWidget {
  final EmployeeFlowProject? project;

  const EmployeeHandoverHistoryScreen({
    super.key,
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
          project != null ? '${project!.code} - Handovers' : 'Handover History',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: EmployeeFlowTheme.textDark,
          ),
        ),
        centerTitle: false,
      ),
      body: Obx(() {
        final handovers = project != null
            ? controller.getHandoversForProject(project!.id)
            : controller.globalHandoverHistory;

        return ListView(
          padding: const EdgeInsets.all(16),
          physics: const BouncingScrollPhysics(),
          children: [
            // 1. Total Handovers Summary Card
            EmployeeFlowCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: EmployeeFlowTheme.infoBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Iconsax.element_4,
                      color: EmployeeFlowTheme.primaryBlue,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Handovers',
                        style: TextStyle(
                          fontSize: 12,
                          color: EmployeeFlowTheme.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${handovers.length}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: EmployeeFlowTheme.textDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 2. Timeline List
            if (handovers.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'No handover history available.',
                    style: TextStyle(color: EmployeeFlowTheme.textMuted),
                  ),
                ),
              )
            else
              ...List.generate(handovers.length, (index) {
                final item = handovers[index];
                final isFirst = index == 0;
                final isLast = index == handovers.length - 1;

                return _buildTimelineRow(context, item, isFirst, isLast);
              }),
          ],
        );
      }),
    );
  }

  Widget _buildTimelineRow(
    BuildContext context,
    EmployeeFlowHandoverRecord item,
    bool isFirst,
    bool isLast,
  ) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator with dot and line
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(top: 18),
                  decoration: BoxDecoration(
                    color: isFirst ? EmployeeFlowTheme.primaryBlue : EmployeeFlowTheme.warningOrange,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: EmployeeFlowTheme.cardBorder,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Content Card
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 14),
              child: EmployeeFlowCard(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            '${item.fromUser} → ${item.toUser}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: EmployeeFlowTheme.textDark,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () => _showHandoverDetails(context, item),
                          child: const Text(
                            'View Details',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: EmployeeFlowTheme.primaryBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.timestamp,
                      style: const TextStyle(
                        fontSize: 11,
                        color: EmployeeFlowTheme.textMuted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          'Reason: ${item.reason}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: EmployeeFlowTheme.textMuted,
                          ),
                        ),
                        const Spacer(),
                        EmployeeFlowStatusBadge(status: item.status, fontSize: 10),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showHandoverDetails(BuildContext context, EmployeeFlowHandoverRecord item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: EmployeeFlowTheme.cardBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Handover Details',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: EmployeeFlowTheme.textDark),
                    ),
                    EmployeeFlowStatusBadge(status: item.status),
                  ],
                ),
                const SizedBox(height: 14),
                _detailTile('Task Title', item.taskTitle),
                _detailTile('Handed Over By', '${item.fromUser} (${item.fromUserRole})'),
                _detailTile('Handed Over To', '${item.toUser} (${item.toUserRole})'),
                _detailTile('Timestamp', item.timestamp),
                _detailTile('Reason', item.reason),
                _detailTile('Progress at Handover', '${item.progressAtHandover.toInt()}%'),
                if (item.notes.isNotEmpty) _detailTile('Notes', item.notes),
                if (item.attachmentName != null) _detailTile('Attachment', item.attachmentName!),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: EmployeeFlowTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Get.back(),
                    child: const Text('Close Details'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detailTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: EmployeeFlowTheme.textMuted, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: EmployeeFlowTheme.textDark),
            ),
          ),
        ],
      ),
    );
  }
}
