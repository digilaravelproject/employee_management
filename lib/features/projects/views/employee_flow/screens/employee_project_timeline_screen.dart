import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/employee_flow_models.dart';
import '../widgets/employee_flow_widgets.dart';

/// Screen 8: Project Timeline
/// Matches Mockup 8 from user reference:
/// - Header: "Project Timeline"
/// - Project Title: "E-Commerce Mobile App"
/// - Vertical milestone steps:
///   - 01 Sep 2025: Project Started (Completed green check)
///   - 10 Sep 2025: Design Phase (Completed green check)
///   - 18 Sep 2025: Development Phase (In Progress blue pulse)
///   - 01 Oct 2025: Testing Phase (Pending orange)
///   - 15 Oct 2025: UAT & Bug Fixes (Pending orange)
///   - 31 Dec 2025: Final Release (Pending orange)
class EmployeeProjectTimelineScreen extends StatelessWidget {
  final EmployeeFlowProject project;

  const EmployeeProjectTimelineScreen({
    super.key,
    required this.project,
  });

  @override
  Widget build(BuildContext context) {
    final milestones = project.milestones;

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
          'Project Timeline',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: EmployeeFlowTheme.textDark,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project Title Header
            Text(
              project.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: EmployeeFlowTheme.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${project.code} • ${project.duration} (${project.startDate} - ${project.endDate})',
              style: const TextStyle(
                fontSize: 12,
                color: EmployeeFlowTheme.textMuted,
              ),
            ),
            const SizedBox(height: 24),

            // Vertical Milestone Timeline
            ...List.generate(milestones.length, (index) {
              final ms = milestones[index];
              final isLast = index == milestones.length - 1;
              return _buildTimelineStep(ms, isLast);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineStep(EmployeeFlowMilestone ms, bool isLast) {
    Color iconColor;
    Widget iconWidget;

    if (ms.status == 'Completed') {
      iconColor = EmployeeFlowTheme.successGreen;
      iconWidget = const Icon(Icons.check, size: 14, color: Colors.white);
    } else if (ms.status == 'In Progress') {
      iconColor = EmployeeFlowTheme.primaryBlue;
      iconWidget = Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      );
    } else {
      iconColor = EmployeeFlowTheme.warningOrange;
      iconWidget = Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      );
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step Circle & Line
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: iconColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(child: iconWidget),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: ms.status == 'Completed'
                          ? EmployeeFlowTheme.successGreen
                          : EmployeeFlowTheme.cardBorder,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ms.date,
                    style: const TextStyle(
                      fontSize: 12,
                      color: EmployeeFlowTheme.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        ms.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: EmployeeFlowTheme.textDark,
                        ),
                      ),
                      if (ms.status == 'In Progress')
                        EmployeeFlowStatusBadge(status: 'In Progress')
                      else if (ms.status == 'Pending')
                        EmployeeFlowStatusBadge(status: 'Pending')
                      else
                        const Icon(Icons.check_circle_rounded, size: 16, color: EmployeeFlowTheme.successGreen),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
