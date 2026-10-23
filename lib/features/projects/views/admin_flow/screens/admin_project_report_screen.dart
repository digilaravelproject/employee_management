import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../controllers/admin_flow_controller.dart';
import '../widgets/admin_flow_widgets.dart';

class AdminProjectReportScreen extends StatelessWidget {
  final bool isStandalone;

  const AdminProjectReportScreen({
    super.key,
    this.isStandalone = false,
  });

  @override
  Widget build(BuildContext context) {
    final controller = AdminFlowController.to;
    final project = controller.selectedProject.value;

    return Scaffold(
      backgroundColor: AdminFlowTheme.surfaceSlate,
      appBar: AdminFlowAppBar(
        title: 'Project Report',
        showBackButton: !isStandalone,
        actions: [
          IconButton(
            icon: const Icon(Iconsax.document_download, color: AdminFlowTheme.textDark, size: 20),
            onPressed: () {
              Get.snackbar(
                'Report Exported',
                'Report for ${project.title} exported as PDF.',
                snackPosition: SnackPosition.TOP,
                backgroundColor: const Color(0xFF0F172A),
                colorText: Colors.white,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time Summary Section
            AdminFlowCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Time Summary',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AdminFlowTheme.textDark),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTimeBox(
                          label: 'Estimated',
                          value: '${project.estimatedHours}',
                          unit: 'hrs',
                          color: const Color(0xFF3B206A),
                          bg: const Color(0xFFF5F0FB),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildTimeBox(
                          label: 'Actual',
                          value: '${project.actualHours}',
                          unit: 'hrs',
                          color: const Color(0xFF0F172A),
                          bg: const Color(0xFFF1F5F9),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildTimeBox(
                          label: 'Remaining',
                          value: '${project.remainingHours}',
                          unit: 'hrs',
                          color: const Color(0xFF10B981),
                          bg: const Color(0xFFECFDF5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Module Wise Progress Card with Donut Chart
            AdminFlowCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Module Wise Progress',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AdminFlowTheme.textDark),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      // Donut Chart
                      SizedBox(
                        width: 130,
                        height: 130,
                        child: CustomPaint(
                          painter: DonutChartPainter(
                            completed: 3,
                            inProgress: 5,
                            pending: 5,
                            percentage: 37,
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      // Legend
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLegendItem(
                              color: const Color(0xFF10B981),
                              label: 'Completed',
                              count: '3',
                            ),
                            const SizedBox(height: 12),
                            _buildLegendItem(
                              color: const Color(0xFF3B82F6),
                              label: 'In Progress',
                              count: '5',
                            ),
                            const SizedBox(height: 12),
                            _buildLegendItem(
                              color: const Color(0xFFF59E0B),
                              label: 'Pending',
                              count: '5',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Task Status Card
            AdminFlowCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Task Status',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AdminFlowTheme.textDark),
                  ),
                  const SizedBox(height: 16),

                  _buildTaskStatusBar(
                    label: 'Completed',
                    count: '12 (37.5%)',
                    percent: 0.375,
                    color: const Color(0xFF10B981),
                  ),
                  const SizedBox(height: 14),

                  _buildTaskStatusBar(
                    label: 'In Progress',
                    count: '14 (43.7%)',
                    percent: 0.437,
                    color: const Color(0xFF3B82F6),
                  ),
                  const SizedBox(height: 14),

                  _buildTaskStatusBar(
                    label: 'Pending',
                    count: '6 (18.8%)',
                    percent: 0.188,
                    color: const Color(0xFFF59E0B),
                  ),
                  const SizedBox(height: 14),

                  _buildTaskStatusBar(
                    label: 'Overdue',
                    count: '2 (6.2%)',
                    percent: 0.062,
                    color: const Color(0xFFEF4444),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeBox({
    required String label,
    required String value,
    required String unit,
    required Color color,
    required Color bg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AdminFlowTheme.textMuted),
          ),
          const SizedBox(height: 6),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                TextSpan(
                  text: ' $unit',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: color.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({required Color color, required String label, required String count}) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: AdminFlowTheme.textMuted, fontWeight: FontWeight.w500),
          ),
        ),
        Text(
          count,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AdminFlowTheme.textDark),
        ),
      ],
    );
  }

  Widget _buildTaskStatusBar({
    required String label,
    required String count,
    required double percent,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AdminFlowTheme.textDark)),
            Text(count, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AdminFlowTheme.textMuted)),
          ],
        ),
        const SizedBox(height: 6),
        AdminFlowProgressBar(
          progress: percent,
          color: color,
          height: 7,
          backgroundColor: const Color(0xFFF1F5F9),
        ),
      ],
    );
  }
}

class DonutChartPainter extends CustomPainter {
  final int completed;
  final int inProgress;
  final int pending;
  final int percentage;

  DonutChartPainter({
    required this.completed,
    required this.inProgress,
    required this.pending,
    required this.percentage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final total = (completed + inProgress + pending).toDouble();
    if (total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 14.0;

    final paintCompleted = Paint()
      ..color = const Color(0xFF10B981)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final paintInProgress = Paint()
      ..color = const Color(0xFF3B82F6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final paintPending = Paint()
      ..color = const Color(0xFFF59E0B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);

    double startAngle = -math.pi / 2;
    final sweepCompleted = (completed / total) * 2 * math.pi;
    final sweepInProgress = (inProgress / total) * 2 * math.pi;
    final sweepPending = (pending / total) * 2 * math.pi;

    canvas.drawArc(rect, startAngle, sweepCompleted, false, paintCompleted);
    startAngle += sweepCompleted;

    canvas.drawArc(rect, startAngle, sweepInProgress, false, paintInProgress);
    startAngle += sweepInProgress;

    canvas.drawArc(rect, startAngle, sweepPending, false, paintPending);

    // Center Percentage Text
    final textPainter = TextPainter(
      text: TextSpan(
        text: '$percentage%',
        style: const TextStyle(
          color: AdminFlowTheme.textDark,
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
