import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/performance_controller.dart';
import '../models/performance_model.dart';

class TargetDetailsScreen extends StatelessWidget {
  final PerformanceTarget target;

  const TargetDetailsScreen({super.key, required this.target});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PerformanceController>();

    // We will listen to reactive updates for this specific target
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
          'Target Details',
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppColors.textColorPrimary,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.textColorPrimary, size: 20),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          // Find the reactive instance of the target in the controller
          final reactiveTarget = controller.targets.firstWhere((t) => t.id == target.id, orElse: () => target);

          Color statusColor;
          Color statusBg;
          if (reactiveTarget.isCompleted) {
            statusColor = AppColors.successColor;
            statusBg = const Color(0xFFEAFAF1);
          } else {
            statusColor = reactiveTarget.status == 'On Track' ? AppColors.successColor : AppColors.warningColor;
            statusBg = reactiveTarget.status == 'On Track' ? const Color(0xFFEAFAF1) : const Color(0xFFFEF9EC);
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── GOAL HEADER WIDGET ──
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.slate200),
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Iconsax.award, color: AppColors.primaryColor, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText(reactiveTarget.title, fontSize: 15, fontWeight: FontWeight.w800),
                                const SizedBox(height: 4),
                                AppText(reactiveTarget.description, fontSize: 11.5, color: AppColors.textColorSecondary),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: statusBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: AppText(
                              reactiveTarget.status,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Metric Summary Stats row
                      Row(
                        children: [
                          Expanded(child: _DetailStatCol(label: 'Target', value: reactiveTarget.targetValue)),
                          Container(width: 1, height: 32, color: AppColors.slate200),
                          Expanded(child: _DetailStatCol(label: 'Achieved', value: reactiveTarget.achievedValue)),
                          Container(width: 1, height: 32, color: AppColors.slate200),
                          Expanded(child: _DetailStatCol(label: 'Progress', value: '${(reactiveTarget.progress * 100).round()}%', valueColor: AppColors.primaryColor)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── GOAL METADATA GRID CARD ──
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.slate200),
                  ),
                  child: Column(
                    children: [
                      _MetaRow(icon: Iconsax.tag, label: 'Goal Type', value: reactiveTarget.goalType),
                      const Divider(height: 24, color: AppColors.slate200),
                      _MetaRow(icon: Iconsax.calendar_1, label: 'Assigned On', value: DateFormat('dd MMM yyyy').format(reactiveTarget.assignedOn)),
                      const Divider(height: 24, color: AppColors.slate200),
                      _MetaRow(icon: Iconsax.calendar, label: 'Due Date', value: DateFormat('dd MMM yyyy').format(reactiveTarget.dueDate)),
                      const Divider(height: 24, color: AppColors.slate200),
                      _MetaRow(icon: Iconsax.refresh, label: 'Frequency', value: reactiveTarget.frequency),
                      const Divider(height: 24, color: AppColors.slate200),
                      _AssignedByMetaRow(
                        name: reactiveTarget.assignedByName,
                        imageUrl: reactiveTarget.assignedByImage,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── PROGRESS HISTORY GRAPH ──
                const AppText(
                  'Progress History',
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textColorPrimary,
                ),
                const SizedBox(height: 12),
                Container(
                  height: 230,
                  padding: const EdgeInsets.fromLTRB(10, 20, 20, 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.slate200),
                  ),
                  child: _HistoryLineChart(history: reactiveTarget.progressHistory),
                ),
                const SizedBox(height: 20),

                // ── INCENTIVE IMPACT CARD ──
                _IncentiveImpactCard(target: reactiveTarget),
                const SizedBox(height: 24),

                // ── ACTIONS BUTTON ROW ──
                if (!reactiveTarget.isCompleted)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.primaryColor, width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () => _showUpdateProgressSheet(context, controller, reactiveTarget),
                          child: const AppText(
                            'Update Progress',
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                          ),
                          onPressed: () => controller.markTargetCompleted(reactiveTarget.id),
                          child: const AppText(
                            'Mark as Completed',
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 30),
              ],
            ),
          );
        }),
      ),
    );
  }

  void _showUpdateProgressSheet(BuildContext context, PerformanceController controller, PerformanceTarget target) {
    double currentProgress = target.progress;
    final valController = TextEditingController(text: target.achievedValue.replaceAll(RegExp(r'[^0-9]'), ''));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AppText('Update Target Progress', fontSize: 16, fontWeight: FontWeight.w800),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 14),
              AppText('Goal: ${target.title}', fontSize: 12.5, color: AppColors.textColorSecondary),
              const SizedBox(height: 20),

              // slider progress percentage
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AppText('Progress Percentage', fontSize: 12, fontWeight: FontWeight.w700),
                  AppText('${(currentProgress * 100).round()}%', fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.primaryColor),
                ],
              ),
              Slider(
                value: currentProgress,
                activeColor: AppColors.primaryColor,
                inactiveColor: AppColors.slate200,
                onChanged: (val) {
                  setState(() {
                    currentProgress = val;
                  });
                },
              ),
              const SizedBox(height: 14),

              // numeric achieved text input
              TextField(
                controller: valController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Quantity Achieved',
                  hintText: 'e.g. 18',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 20),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  onPressed: () {
                    final numericVal = valController.text.trim();
                    if (numericVal.isNotEmpty) {
                      // Extract suffix from targetValue (e.g. 'Clients')
                      final suffixList = target.targetValue.split(' ');
                      final suffix = suffixList.length > 1 ? ' ${suffixList.sublist(1).join(' ')}' : '';

                      controller.updateTargetProgress(
                        target.id,
                        currentProgress,
                        '$numericVal$suffix',
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: const AppText('Save Progress', fontSize: 13.5, fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailStatCol extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailStatCol({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppText(label, fontSize: 10, color: AppColors.textColorSecondary, fontWeight: FontWeight.w500),
        const SizedBox(height: 4),
        AppText(value, fontSize: 14.5, color: valueColor ?? AppColors.textColorPrimary, fontWeight: FontWeight.w900),
      ],
    );
  }
}

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetaRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textColorHint, size: 16),
        const SizedBox(width: 10),
        AppText(label, fontSize: 12, color: AppColors.textColorSecondary, fontWeight: FontWeight.w500),
        const Spacer(),
        AppText(value, fontSize: 12, color: AppColors.textColorPrimary, fontWeight: FontWeight.w700),
      ],
    );
  }
}

class _AssignedByMetaRow extends StatelessWidget {
  final String name;
  final String imageUrl;

  const _AssignedByMetaRow({required this.name, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Iconsax.profile, color: AppColors.textColorHint, size: 16),
        const SizedBox(width: 10),
        const AppText('Assigned By', fontSize: 12, color: AppColors.textColorSecondary, fontWeight: FontWeight.w500),
        const Spacer(),
        CircleAvatar(
          radius: 10,
          backgroundColor: AppColors.slate200,
          backgroundImage: NetworkImage(imageUrl),
        ),
        const SizedBox(width: 6),
        AppText(name, fontSize: 12, color: AppColors.textColorPrimary, fontWeight: FontWeight.w700),
      ],
    );
  }
}

// ── FL_CHART LINE GRAPH REPRESENTATION ─────────────────────────────────────────
class _HistoryLineChart extends StatelessWidget {
  final Map<String, double> history;

  const _HistoryLineChart({required this.history});

  @override
  Widget build(BuildContext context) {
    final entries = history.entries.toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 25,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppColors.slate200,
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < entries.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: AppText(
                      entries[index].key,
                      fontSize: 8.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textColorSecondary,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 25,
              reservedSize: 32,
              getTitlesWidget: (value, meta) {
                return AppText(
                  '${value.toInt()}%',
                  fontSize: 8.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textColorSecondary,
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: false,
        ),
        minX: 0,
        maxX: (entries.length - 1).toDouble(),
        minY: 0,
        maxY: 100,
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(entries.length, (index) {
              return FlSpot(
                index.toDouble(),
                entries[index].value * 100,
              );
            }),
            isCurved: true,
            gradient: const LinearGradient(
              colors: [
                AppColors.primaryColor,
                Color(0xFF60A5FA), // Light Blue
              ],
            ),
            barWidth: 3.5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                radius: 4.5,
                color: Colors.white,
                strokeWidth: 2.5,
                strokeColor: AppColors.primaryColor,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryColor.withValues(alpha: 0.18),
                  AppColors.primaryColor.withValues(alpha: 0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── INCENTIVE IMPACT CARD ────────────────────────────────────────────────────
class _IncentiveImpactCard extends StatelessWidget {
  final PerformanceTarget target;

  const _IncentiveImpactCard({required this.target});

  @override
  Widget build(BuildContext context) {
    // Current eligible sum based on progress
    final currentEarned = (target.estimatedIncentive * target.progress).round();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF), // Soft primary light blue
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDBEAFE)),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Iconsax.gift, color: AppColors.primaryColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppText(
                      'Incentive Impact',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColorSecondary,
                    ),
                    const SizedBox(height: 2),
                    AppText(
                      '₹ ${currentEarned.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} / ₹ ${target.estimatedIncentive.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textColorPrimary,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24, color: Color(0xFFBFDBFE)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const AppText('Performance Score', fontSize: 10, color: AppColors.textColorSecondary, fontWeight: FontWeight.w600),
              const AppText('87%', fontSize: 11, color: AppColors.textColorPrimary, fontWeight: FontWeight.w800),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const AppText('Eligibility', fontSize: 10, color: AppColors.textColorSecondary, fontWeight: FontWeight.w600),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAFAF1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const AppText('Eligible', fontSize: 9, color: AppColors.successColor, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
