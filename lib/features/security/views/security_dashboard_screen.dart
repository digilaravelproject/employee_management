import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/security_controller.dart';
import 'login_history_screen.dart';
import 'activity_logs_screen.dart';
import 'backup_restore_screen.dart';
import 'security_monitoring_screen.dart';

class SecurityDashboardScreen extends StatelessWidget {
  const SecurityDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Put controller in memory
    final controller = Get.put(SecurityController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.slate100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.textColorPrimary,
                size: 18,
              ),
              onPressed: () => Get.back(),
            ),
          ),
        ),
        title: const AppText(
          'Security Dashboard',
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: Color(0xFF1E293B),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.notification, color: Color(0xFF1E293B)),
            onPressed: () {},
          ),
        ],
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── OVERVIEW (TODAY) ──
              const AppText(
                'Overview (Today)',
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFF475569),
              ),
              const SizedBox(height: 12),

              Obx(() => Row(
                children: [
                  Expanded(
                    child: _buildStatCell(
                      'Total Logins',
                      '${controller.totalLogins.value}',
                      '+12%',
                      Iconsax.user_tick,
                      const Color(0xFF3B82F6),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildStatCell(
                      'Active Users',
                      '${controller.activeUsers.value}',
                      '+8%',
                      Iconsax.profile_2user,
                      const Color(0xFF10B981),
                    ),
                  ),
                ],
              )),
              const SizedBox(height: 10),
              Obx(() => Row(
                children: [
                  Expanded(
                    child: _buildStatCell(
                      'Failed Logins',
                      '${controller.failedLogins.value}',
                      '-20%',
                      Iconsax.user_remove,
                      const Color(0xFFEF4444),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildStatCell(
                      'Suspicious Activity',
                      '${controller.suspiciousActivities.value}',
                      'View All',
                      Iconsax.warning_2,
                      const Color(0xFFF59E0B),
                    ),
                  ),
                ],
              )),
              const SizedBox(height: 24),

              // ── QUICK ACTIONS ──
              const AppText(
                'Quick Actions',
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFF475569),
              ),
              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildQuickActionBtn(
                    'Login\nHistory',
                    Iconsax.clock,
                    const Color(0xFF3B82F6),
                    () => Get.to(() => const LoginHistoryScreen()),
                  ),
                  _buildQuickActionBtn(
                    'Activity\nLogs',
                    Iconsax.document_text,
                    const Color(0xFF8B5CF6),
                    () => Get.to(() => const ActivityLogsScreen()),
                  ),
                  _buildQuickActionBtn(
                    'Backup &\nRestore',
                    Iconsax.cloud_change,
                    const Color(0xFF10B981),
                    () => Get.to(() => const BackupRestoreScreen()),
                  ),
                  _buildQuickActionBtn(
                    'Security\nMonitor',
                    Iconsax.security_safe,
                    const Color(0xFFF97316),
                    () => Get.to(() => const SecurityMonitoringScreen()),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── LOGIN TREND (THIS WEEK) ──
              const AppText(
                'Login Trend (This Week)',
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFF475569),
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFEEF2FF)),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 120,
                      width: double.infinity,
                      child: CustomPaint(
                        painter: _TrendChartPainter(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _ChartLabel('Mon'),
                        _ChartLabel('Tue'),
                        _ChartLabel('Wed'),
                        _ChartLabel('Thu'),
                        _ChartLabel('Fri'),
                        _ChartLabel('Sat'),
                        _ChartLabel('Sun'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── RECENT ALERTS ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AppText(
                    'Recent Alerts',
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF475569),
                  ),
                  GestureDetector(
                    onTap: () => Get.to(() => const SecurityMonitoringScreen()),
                    child: const AppText(
                      'View All',
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Obx(() {
                final alerts = controller.recentAlerts;
                if (alerts.isEmpty) {
                  return const Center(child: Text('No security flags raised today.'));
                }

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFEEF2FF)),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: alerts.length,
                    separatorBuilder: (context, index) => const Divider(color: Color(0xFFF1F5F9), height: 16),
                    itemBuilder: (context, index) {
                      final alert = alerts[index];
                      final col = alert.isHighRisk ? const Color(0xFFEF4444) : const Color(0xFFF59E0B);
                      
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: col.withValues(alpha: 0.08),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                alert.isHighRisk ? Iconsax.info_circle : Iconsax.warning_2,
                                color: col,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppText(
                                    alert.title,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF1E293B),
                                  ),
                                  const SizedBox(height: 3),
                                  AppText(
                                    alert.time,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF94A3B8),
                                  ),
                                ],
                              ),
                            ),
                            AppText(
                              alert.ipOrUser,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF64748B),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCell(String label, String value, String badge, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEEF2FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: badge.contains('+') 
                      ? const Color(0xFFD1FAE5) 
                      : badge.contains('-') 
                          ? const Color(0xFFFEE2E2) 
                          : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    color: badge.contains('+') 
                        ? const Color(0xFF059669) 
                        : badge.contains('-') 
                            ? const Color(0xFFDC2626) 
                            : const Color(0xFF2563EB),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppText(
            value,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF1E293B),
          ),
          const SizedBox(height: 2),
          AppText(
            label,
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF94A3B8),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionBtn(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 76,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEEF2FF)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF475569),
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartLabel extends StatelessWidget {
  final String text;

  const _ChartLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return AppText(
      text,
      fontSize: 9,
      fontWeight: FontWeight.w700,
      color: const Color(0xFF94A3B8),
    );
  }
}

class _TrendChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..color = const Color(0xFF2563EB)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF2563EB).withValues(alpha: 0.25),
          const Color(0xFF2563EB).withValues(alpha: 0.01),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final dotPaint = Paint()
      ..color = const Color(0xFF2563EB)
      ..style = PaintingStyle.fill;

    final dotRingPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // 7 coordinates representing Mon-Sun
    final List<Offset> points = [
      Offset(0, size.height * 0.7),
      Offset(size.width * 0.166, size.height * 0.5),
      Offset(size.width * 0.332, size.height * 0.6),
      Offset(size.width * 0.498, size.height * 0.45),
      Offset(size.width * 0.664, size.height * 0.65),
      Offset(size.width * 0.83, size.height * 0.38),
      Offset(size.width, size.height * 0.15),
    ];

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      final controlPoint1 = Offset(p1.dx + (p2.dx - p1.dx) / 2, p1.dy);
      final controlPoint2 = Offset(p1.dx + (p2.dx - p1.dx) / 2, p2.dy);
      path.cubicTo(
        controlPoint1.dx, controlPoint1.dy,
        controlPoint2.dx, controlPoint2.dy,
        p2.dx, p2.dy,
      );
    }

    // Draw the gradient filled curve underneath
    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, borderPaint);

    // Draw active dots along the Bezier curve
    for (var pt in points) {
      canvas.drawCircle(pt, 5.0, dotPaint);
      canvas.drawCircle(pt, 5.0, dotRingPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
