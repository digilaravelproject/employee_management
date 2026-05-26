import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/performance_controller.dart';
import '../models/performance_model.dart';
import 'my_targets_screen.dart';
import 'target_details_screen.dart';

class PerformanceDashboardScreen extends StatelessWidget {
  const PerformanceDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PerformanceController());

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textColorPrimary, size: 18),
          onPressed: () => Get.back(),
        ),
        title: const AppText(
          'Performance',
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppColors.textColorPrimary,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Iconsax.notification, color: AppColors.textColorPrimary, size: 20),
            onPressed: () {
              // Action for notification
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── CUSTOM SEGMENT SELECTOR (My Overview / Team Overview) ──
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.slate100,
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    // My Overview Tab
                    Expanded(
                      child: Obx(() {
                        final isActive = controller.selectedDashboardTab.value == 0;
                        return GestureDetector(
                          onTap: () => controller.selectedDashboardTab.value = 0,
                          behavior: HitTestBehavior.opaque,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: isActive ? AppColors.primaryColor : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: isActive
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primaryColor.withValues(alpha: 0.25),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      )
                                    ]
                                  : null,
                            ),
                            alignment: Alignment.center,
                            child: AppText(
                              'My Overview',
                              fontSize: 13,
                              fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                              color: isActive ? Colors.white : AppColors.textColorSecondary,
                            ),
                          ),
                        );
                      }),
                    ),

                    // Team Overview Tab
                    Expanded(
                      child: Obx(() {
                        final isActive = controller.selectedDashboardTab.value == 1;
                        return GestureDetector(
                          onTap: () => controller.selectedDashboardTab.value = 1,
                          behavior: HitTestBehavior.opaque,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: isActive ? AppColors.primaryColor : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: isActive
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primaryColor.withValues(alpha: 0.25),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      )
                                    ]
                                  : null,
                            ),
                            alignment: Alignment.center,
                            child: AppText(
                              'Team Overview',
                              fontSize: 13,
                              fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                              color: isActive ? Colors.white : AppColors.textColorSecondary,
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),

            // ── BODY MAIN VIEWS ──
            Expanded(
              child: Obx(() {
                if (controller.selectedDashboardTab.value == 0) {
                  return const _MyOverviewTab();
                } else {
                  return const _TeamOverviewTab();
                }
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// ── SUB-VIEW: MY OVERVIEW TAB ────────────────────────────────────────────────
class _MyOverviewTab extends StatelessWidget {
  const _MyOverviewTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Overall Performance Card ──
          const _OverallPerformanceCard(),
          const SizedBox(height: 24),

          // ── Key Metrics Section ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const AppText(
                'Key Metrics',
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.textColorPrimary,
              ),
              TextButton(
                onPressed: () {
                  // View all key metrics details if required
                },
                child: const AppText(
                  'View All',
                  fontSize: 12,
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const _KeyMetricsList(),
          const SizedBox(height: 24),

          // ── My Targets Section ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const AppText(
                'My Targets',
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.textColorPrimary,
              ),
              TextButton(
                onPressed: () => Get.to(() => const MyTargetsScreen()),
                child: const AppText(
                  'View All',
                  fontSize: 12,
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const _MyTargetsPreviewCard(),
          const SizedBox(height: 16),

          // ── Incentive Estimate Ribbon ──
          const _IncentiveEstimateRibbon(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ── OVERALL PERFORMANCE CARD (Circular ring + Grid) ──────────────────────────
class _OverallPerformanceCard extends StatelessWidget {
  const _OverallPerformanceCard();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PerformanceController>();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Top Row: Title & Month Dropdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const AppText(
                'Overall Performance',
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
              Obx(() => Container(
                    height: 28,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: controller.selectedMonth.value,
                        dropdownColor: const Color(0xFF4F46E5),
                        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 16),
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        onChanged: (val) {
                          if (val != null) controller.selectedMonth.value = val;
                        },
                        items: controller.monthsList.map((m) {
                          return DropdownMenuItem<String>(
                            value: m,
                            child: AppText(m, color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          );
                        }).toList(),
                      ),
                    ),
                  )),
            ],
          ),
          const SizedBox(height: 22),

          // Main Row: Circular Progress Ring & Statistics Grid
          Row(
            children: [
              // Circular Ring (Left)
              SizedBox(
                width: 100,
                height: 100,
                child: CustomPaint(
                  painter: _PerformanceRingPainter(
                    score: 87,
                    label: 'Very Good',
                  ),
                ),
              ),
              const SizedBox(width: 24),

              // Mini Grid (Right)
              Expanded(
                child: Obx(() {
                  return Column(
                    children: [
                      Row(
                        children: [
                          _MiniGridItem(label: 'Goals', value: '${controller.overallProgressGoalsCount}'),
                          const SizedBox(width: 12),
                          _MiniGridItem(label: 'Achieved', value: '${controller.overallProgressAchievedCount}'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _MiniGridItem(label: 'In Progress', value: '${controller.overallProgressInProgressCount}'),
                          const SizedBox(width: 12),
                          _MiniGridItem(label: 'Overdue', value: '${controller.overallProgressOverdueCount}'),
                        ],
                      ),
                    ],
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniGridItem extends StatelessWidget {
  final String label;
  final String value;

  const _MiniGridItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
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
}

// ── CUSTOM PERFORMANCE CIRCULAR GAUGE PAINTER ─────────────────────────────────
class _PerformanceRingPainter extends CustomPainter {
  final double score;
  final String label;

  _PerformanceRingPainter({required this.score, required this.label});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2);
    const strokeWidth = 8.0;

    // Background track circle
    final trackPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius - strokeWidth / 2, trackPaint);

    // Active progress arc with custom glow gradient
    final progressPaint = Paint()
      ..shader = const SweepGradient(
        colors: [
          Color(0xFFFEF08A), // Yellow
          Color(0xFF10B981), // Emerald/Green
          Color(0xFFFEF08A), // Symmetrical Yellow gradient
        ],
        startAngle: 0,
        endAngle: pi * 2,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    // Map 0-100 score to 0 to 2*pi radians
    final sweepAngle = (score / 100.0) * pi * 2;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -pi / 2, // Start at 12 o'clock
      sweepAngle,
      false,
      progressPaint,
    );

    // Score Text Inside
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

// ── KEY METRICS LIST (LINEAR PROGRESS BARS) ──────────────────────────────────
class _KeyMetricsList extends StatelessWidget {
  const _KeyMetricsList();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PerformanceController>();

    return Column(
      children: controller.metrics.map((metric) {
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
              // Icon container with specific tinted background color
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: metric.bgLightColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(metric.icon, color: metric.accentColor, size: 18),
              ),
              const SizedBox(width: 14),

              // Title & progression detail
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

                    // Custom Linear Progress bar
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
              const SizedBox(width: 12),

              // Chevron suffix arrow
              Icon(Icons.arrow_forward_ios, color: AppColors.textColorHint.withValues(alpha: 0.7), size: 12),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ── MY TARGETS PREVIEW CARD ──────────────────────────────────────────────────
class _MyTargetsPreviewCard extends StatelessWidget {
  const _MyTargetsPreviewCard();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PerformanceController>();

    return Obx(() {
      final list = controller.activeTargets;
      if (list.isEmpty) return const SizedBox.shrink();
      final target = list[0]; // Preview first active target

      return GestureDetector(
        onTap: () => Get.to(() => TargetDetailsScreen(target: target)),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.slate200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Iconsax.award, color: AppColors.primaryColor, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: AppText(
                                target.title,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEAFAF1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const AppText(
                                'On Track',
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: AppColors.successColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        AppText(
                          target.description,
                          fontSize: 10,
                          color: AppColors.textColorSecondary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Progress bar and numeric tracking
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText('16 / 20 Clients', fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textColorSecondary),
                  AppText('${(target.progress * 100).round()}%', fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primaryColor),
                ],
              ),
              const SizedBox(height: 8),
              Stack(
                children: [
                  Container(
                    height: 5,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.slate100,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: target.progress,
                    child: Container(
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}

// ── INCENTIVE ESTIMATE RIBBON ───────────────────────────────────────────────
class _IncentiveEstimateRibbon extends StatelessWidget {
  const _IncentiveEstimateRibbon();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PerformanceController>();

    return Obx(() {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF), // Tinted Blue background
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFDBEAFE)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Iconsax.wallet, color: AppColors.primaryColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppText(
                    'Incentive Estimate',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColorSecondary,
                  ),
                  const SizedBox(height: 2),
                  AppText(
                    '₹ ${controller.totalEstimatedIncentive.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textColorPrimary,
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                final list = controller.activeTargets;
                if (list.isNotEmpty) {
                  Get.to(() => TargetDetailsScreen(target: list[0]));
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: const Row(
                  children: [
                    AppText('View Details', fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primaryColor),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios, size: 8, color: AppColors.primaryColor),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ── SUB-VIEW: TEAM OVERVIEW TAB ──────────────────────────────────────────────
class _TeamOverviewTab extends StatelessWidget {
  const _TeamOverviewTab();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PerformanceController>();

    return Column(
      children: [
        // ── Stats Horizontal Strip ──
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.slate50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.slate200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const _TeamStatItem(icon: Iconsax.profile_2user, label: 'Total Employees', value: '24'),
                Container(height: 24, width: 1, color: AppColors.slate200),
                const _TeamStatItem(icon: Iconsax.graph, label: 'Avg. Performance', value: '76%'),
                Container(height: 24, width: 1, color: AppColors.slate200),
                const _TopPerformerItem(name: 'Rohit Sharma'),
              ],
            ),
          ),
        ),

        // ── Search employee bar ──
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.slate100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      const Icon(Iconsax.search_normal, color: AppColors.textColorHint, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          onChanged: (val) => controller.searchQuery.value = val,
                          style: const TextStyle(fontSize: 13, color: AppColors.textColorPrimary, fontWeight: FontWeight.w600),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Search employee...',
                            hintStyle: TextStyle(color: AppColors.textColorHint, fontSize: 13),
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: AppColors.slate100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Iconsax.filter, color: AppColors.textColorSecondary, size: 18),
                  onPressed: () {
                    // Filter action logic
                  },
                ),
              ),
            ],
          ),
        ),

        // ── Sub-tabs: Team View & Department View ──
        Container(
          color: Colors.white,
          child: Row(
            children: [
              _TeamSubTabButton(index: 0, label: 'Team View'),
              _TeamSubTabButton(index: 1, label: 'Department View'),
            ],
          ),
        ),

        // ── Employee rankings list ──
        Expanded(
          child: Obx(() {
            final list = controller.filteredEmployees;
            if (list.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: AppColors.slate100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Iconsax.search_status, color: AppColors.textColorHint, size: 36),
                    ),
                    const SizedBox(height: 12),
                    const AppText('No Employees Found', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textColorPrimary),
                    const SizedBox(height: 4),
                    const AppText('Try searching another name or division.', fontSize: 11, color: AppColors.textColorSecondary),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              itemCount: list.length,
              physics: const BouncingScrollPhysics(),
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final emp = list[index];
                return _EmployeePerformanceCard(emp: emp);
              },
            );
          }),
        ),
      ],
    );
  }
}

class _TeamStatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _TeamStatItem({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.textColorHint, size: 13),
            const SizedBox(width: 4),
            AppText(label, fontSize: 8.5, color: AppColors.textColorSecondary, fontWeight: FontWeight.w600),
          ],
        ),
        const SizedBox(height: 3),
        AppText(value, fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.textColorPrimary),
      ],
    );
  }
}

class _TopPerformerItem extends StatelessWidget {
  final String name;

  const _TopPerformerItem({required this.name});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 14,
          backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=rohit'),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText('Top Performer', fontSize: 8.5, color: AppColors.textColorSecondary, fontWeight: FontWeight.w600),
            const SizedBox(height: 2),
            AppText(name, fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.textColorPrimary),
          ],
        ),
      ],
    );
  }
}

class _TeamSubTabButton extends StatelessWidget {
  final int index;
  final String label;

  const _TeamSubTabButton({required this.index, required this.label});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PerformanceController>();

    return Expanded(
      child: Obx(() {
        final isActive = controller.selectedTeamSubTab.value == index;
        return GestureDetector(
          onTap: () => controller.selectedTeamSubTab.value = index,
          behavior: HitTestBehavior.opaque,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: AppText(
                  label,
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                  color: isActive ? AppColors.primaryColor : AppColors.textColorHint,
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 2.5,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primaryColor : Colors.transparent,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ── INDIVIDUAL TEAM MEMBER PERFORMANCE CARD ────────────────────────────────────
class _EmployeePerformanceCard extends StatelessWidget {
  final EmployeePerformance emp;

  const _EmployeePerformanceCard({required this.emp});

  @override
  Widget build(BuildContext context) {
    // Rating level custom colors
    Color badgeBgColor;
    Color badgeTextColor;

    switch (emp.ratingLabel) {
      case 'Excellent':
        badgeBgColor = const Color(0xFFEFF6FF); // Slate Blue/Cyan
        badgeTextColor = AppColors.primaryColor;
        break;
      case 'Very Good':
        badgeBgColor = const Color(0xFFEAFAF1); // Light Green
        badgeTextColor = AppColors.successColor;
        break;
      case 'Good':
        badgeBgColor = const Color(0xFFEFF6FF); // Light Sapphire
        badgeTextColor = AppColors.primaryColor;
        break;
      default:
        badgeBgColor = const Color(0xFFFEF9EC); // Light Yellow
        badgeTextColor = AppColors.warningColor;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Row(
        children: [
          // Rank Badge Indicator
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: emp.rank <= 3 ? AppColors.primaryLight : AppColors.slate100,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: AppText(
              '${emp.rank}',
              fontSize: 10.5,
              fontWeight: FontWeight.w900,
              color: emp.rank <= 3 ? AppColors.primaryColor : AppColors.textColorSecondary,
            ),
          ),
          const SizedBox(width: 12),

          // Custom Network Avatar
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.slate200,
            backgroundImage: NetworkImage(emp.imageUrl),
            onBackgroundImageError: (exception, stackTrace) {
              // Fallback image handled gracefully by system
            },
          ),
          const SizedBox(width: 12),

          // Name and designation details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(emp.name, fontSize: 13, fontWeight: FontWeight.w800),
                const SizedBox(height: 2),
                AppText(emp.designation, fontSize: 10.5, color: AppColors.textColorSecondary),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Visual Performance Ranking & Percentage Badge
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AppText('${emp.performanceScore}%', fontSize: 13.5, fontWeight: FontWeight.w900, color: AppColors.textColorPrimary),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeBgColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: AppText(
                  emp.ratingLabel,
                  fontSize: 8.5,
                  fontWeight: FontWeight.w800,
                  color: badgeTextColor,
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          Icon(Icons.arrow_forward_ios, size: 10, color: AppColors.textColorHint.withValues(alpha: 0.6)),
        ],
      ),
    );
  }
}
