import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'dart:math';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../models/performance_model.dart';
import '../../chat/controllers/chat_controller.dart';
import '../../chat/views/chat_room_screen.dart';
import '../../chat/models/chat_models.dart';

class TeamMemberPerformanceScreen extends StatelessWidget {
  final EmployeePerformance emp;

  const TeamMemberPerformanceScreen({super.key, required this.emp});

  @override
  Widget build(BuildContext context) {
    // Generate dummy metrics based on employee performance score
    final double attendanceProgress = max(0.4, min(1.0, emp.performanceScore / 100.0 + 0.1));
    final double leaveProgress = emp.performanceScore < 75 ? 0.3 : 0.8;
    final double taskCompletionProgress = emp.performanceScore / 100.0;
    final double timelySubmissionProgress = max(0.3, taskCompletionProgress - 0.05);
    final double qualityProgress = max(0.4, taskCompletionProgress + 0.02);

    final metrics = [
      PerformanceMetric(
        name: 'Attendance',
        label: '${(attendanceProgress * 26).round()} / 26 Days',
        progress: attendanceProgress,
        icon: Iconsax.calendar,
        accentColor: attendanceProgress > 0.8 ? AppColors.successColor : AppColors.warningColor,
        bgLightColor: attendanceProgress > 0.8 ? const Color(0xFFEAFAF1) : const Color(0xFFFEF9EC),
      ),
      PerformanceMetric(
        name: 'Leave',
        label: '${emp.performanceScore < 75 ? 3 : 1} / 2 Days',
        progress: leaveProgress,
        icon: Iconsax.sun_1,
        accentColor: leaveProgress > 0.5 ? AppColors.successColor : AppColors.warningColor,
        bgLightColor: leaveProgress > 0.5 ? const Color(0xFFEAFAF1) : const Color(0xFFFEF9EC),
      ),
      PerformanceMetric(
        name: 'Task Completion',
        label: '${(taskCompletionProgress * 20).round()} / 20 Tasks',
        progress: taskCompletionProgress,
        icon: Iconsax.task_square,
        accentColor: taskCompletionProgress > 0.75 ? AppColors.successColor : AppColors.warningColor,
        bgLightColor: taskCompletionProgress > 0.75 ? const Color(0xFFEAFAF1) : const Color(0xFFFEF9EC),
      ),
      PerformanceMetric(
        name: 'Timely Submissions',
        label: '${(timelySubmissionProgress * 12).round()} / 12 Tasks',
        progress: timelySubmissionProgress,
        icon: Iconsax.clock,
        accentColor: timelySubmissionProgress > 0.75 ? AppColors.primaryColor : AppColors.warningColor,
        bgLightColor: timelySubmissionProgress > 0.75 ? const Color(0xFFEFF6FF) : const Color(0xFFFEF9EC),
      ),
      PerformanceMetric(
        name: 'Quality of Work',
        label: '${(qualityProgress * 5).toStringAsFixed(1)} / 5.0 Rating',
        progress: qualityProgress,
        icon: Iconsax.star,
        accentColor: const Color(0xFFF43F5E), // Rose 500
        bgLightColor: const Color(0xFFFFF1F2), // Rose 50
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textColorPrimary, size: 18),
          onPressed: () => Get.back(),
        ),
        title: AppText(
          '${emp.name}\'s Overview',
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppColors.textColorPrimary,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Employee Info Header
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(emp.imageUrl),
                  backgroundColor: AppColors.slate200,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(emp.name, fontSize: 18, fontWeight: FontWeight.bold),
                      const SizedBox(height: 4),
                      AppText('${emp.designation} • ${emp.department}', fontSize: 13, color: AppColors.textColorSecondary),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Performance Card
            _buildPerformanceCard(),
            const SizedBox(height: 24),

            // Key Metrics
            const AppText(
              'Detailed Metrics',
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textColorPrimary,
            ),
            const SizedBox(height: 10),
            ...metrics.map((m) => _buildMetricItem(m)),

            const SizedBox(height: 32),

            // Warning / Message Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _openChatWithEmployee(),
                icon: Icon(emp.performanceScore < 75 ? Icons.warning_amber_rounded : Iconsax.message, color: Colors.white),
                label: AppText(
                  emp.performanceScore < 75 ? 'Send Warning Message' : 'Send Message',
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: emp.performanceScore < 75 ? Colors.red : AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: emp.performanceScore < 75 
              ? [const Color(0xFFEF4444), const Color(0xFFF87171)] 
              : [const Color(0xFF4F46E5), const Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (emp.performanceScore < 75 ? const Color(0xFFEF4444) : const Color(0xFF4F46E5)).withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const AppText(
                'Overall Performance',
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
              Container(
                height: 28,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const AppText('May 2024', color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: CustomPaint(
                  painter: _PerformanceRingPainter(
                    score: emp.performanceScore.toDouble(),
                    label: emp.ratingLabel,
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        _buildMiniGridItem('Rank', '#${emp.rank}'),
                        const SizedBox(width: 12),
                        _buildMiniGridItem('Score', '${emp.performanceScore}'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniGridItem(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(label, fontSize: 9, color: Colors.white70, fontWeight: FontWeight.w600),
            const SizedBox(height: 2),
            AppText(value, fontSize: 16, color: Colors.white, fontWeight: FontWeight.w900),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(PerformanceMetric metric) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: metric.bgLightColor,
              shape: BoxShape.circle,
            ),
            child: Icon(metric.icon, color: metric.accentColor, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppText(metric.name, fontSize: 12, fontWeight: FontWeight.w700),
                    AppText(
                      metric.label,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textColorSecondary,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Stack(
                  children: [
                    Container(
                      height: 6,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.slate100,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: metric.progress,
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: metric.accentColor,
                          borderRadius: BorderRadius.circular(3),
                        ),
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
  }

  void _openChatWithEmployee() {
    final chatCtrl = Get.put(ChatController());
    final existingIdx = chatCtrl.conversations.indexWhere((c) => c.id == emp.id);
    if (existingIdx == -1) {
      chatCtrl.conversations.insert(0, ChatConversation(
        id: emp.id,
        name: emp.name,
        avatarUrl: emp.imageUrl,
        designation: emp.designation,
        lastMessage: '',
        lastMessageTime: DateTime.now(),
      ));
    }
    chatCtrl.selectConversation(emp.id);
    Get.to(() => const ChatRoomScreen());
  }
}

class _PerformanceRingPainter extends CustomPainter {
  final double score;
  final String label;

  _PerformanceRingPainter({required this.score, required this.label});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2);
    const strokeWidth = 8.0;

    final trackPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius - strokeWidth / 2, trackPaint);

    final progressPaint = Paint()
      ..shader = const SweepGradient(
        colors: [Color(0xFFFEF08A), Color(0xFF10B981), Color(0xFFFEF08A)],
        startAngle: 0,
        endAngle: pi * 2,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    final sweepAngle = (score / 100.0) * pi * 2;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    final scoreSpan = TextSpan(
      style: const TextStyle(
        fontFamily: 'Inter',
        color: Colors.white,
        fontWeight: FontWeight.w900,
        fontSize: 18,
        height: 1.1,
      ),
      text: '${score.round()}%\n',
      children: [
        TextSpan(
          text: label,
          style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w700,
            fontSize: 7.5,
          ),
        ),
      ],
    );

    textPainter.text = scoreSpan;
    textPainter.layout(minWidth: 0, maxWidth: size.width);
    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
