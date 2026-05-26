import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/performance_controller.dart';
import '../models/performance_model.dart';
import 'target_details_screen.dart';

class MyTargetsScreen extends StatelessWidget {
  const MyTargetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PerformanceController>();

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
          'My Targets',
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppColors.textColorPrimary,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Iconsax.add, color: AppColors.primaryColor, size: 24),
            tooltip: 'Add Target',
            onPressed: () => _showAddTargetDialog(context, controller),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── SUB-TABS: Active / Completed ──
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.slate100,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    // Active Targets
                    Expanded(
                      child: Obx(() {
                        final count = controller.activeTargets.length;
                        final isActive = controller.selectedTargetTab.value == 0;
                        return GestureDetector(
                          onTap: () => controller.selectedTargetTab.value = 0,
                          behavior: HitTestBehavior.opaque,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: isActive ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(9),
                              boxShadow: isActive
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.04),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      )
                                    ]
                                  : null,
                            ),
                            alignment: Alignment.center,
                            child: AppText(
                              'Active ($count)',
                              fontSize: 12.5,
                              fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                              color: isActive ? AppColors.primaryColor : AppColors.textColorSecondary,
                            ),
                          ),
                        );
                      }),
                    ),

                    // Completed Targets
                    Expanded(
                      child: Obx(() {
                        final count = controller.completedTargets.length;
                        final isActive = controller.selectedTargetTab.value == 1;
                        return GestureDetector(
                          onTap: () => controller.selectedTargetTab.value = 1,
                          behavior: HitTestBehavior.opaque,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: isActive ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(9),
                              boxShadow: isActive
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.04),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      )
                                    ]
                                  : null,
                            ),
                            alignment: Alignment.center,
                            child: AppText(
                              'Completed ($count)',
                              fontSize: 12.5,
                              fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                              color: isActive ? AppColors.primaryColor : AppColors.textColorSecondary,
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),

            // ── TARGET CARDS GRID / LIST ──
            Expanded(
              child: Obx(() {
                final list = controller.selectedTargetTab.value == 0
                    ? controller.activeTargets
                    : controller.completedTargets;

                if (list.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: const BoxDecoration(
                            color: AppColors.slate100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            controller.selectedTargetTab.value == 0 ? Iconsax.award : Iconsax.tick_circle,
                            color: AppColors.textColorHint,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 16),
                        AppText(
                          controller.selectedTargetTab.value == 0 ? 'No Active Targets' : 'No Completed Targets Yet',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textColorPrimary,
                        ),
                        const SizedBox(height: 4),
                        AppText(
                          controller.selectedTargetTab.value == 0
                              ? 'Hooray! You are all caught up.'
                              : 'Keep working hard to smash your goals!',
                          fontSize: 11.5,
                          color: AppColors.textColorSecondary,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: list.length,
                  physics: const BouncingScrollPhysics(),
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final target = list[index];
                    return _TargetDetailCard(target: target);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTargetDialog(BuildContext context, PerformanceController controller) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final valController = TextEditingController();
    final incentiveController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const AppText('Create New Goal', fontSize: 16, fontWeight: FontWeight.w800),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Goal Title',
                  labelStyle: const TextStyle(fontSize: 12, color: AppColors.textColorSecondary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: descController,
                decoration: InputDecoration(
                  labelText: 'Goal Description',
                  labelStyle: const TextStyle(fontSize: 12, color: AppColors.textColorSecondary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: valController,
                      decoration: InputDecoration(
                        labelText: 'Target (e.g. 20 Clients)',
                        labelStyle: const TextStyle(fontSize: 10, color: AppColors.textColorSecondary),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: incentiveController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Incentive (₹)',
                        labelStyle: const TextStyle(fontSize: 10, color: AppColors.textColorSecondary),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const AppText('Cancel', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textColorSecondary),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            onPressed: () {
              final title = titleController.text.trim();
              final desc = descController.text.trim();
              final val = valController.text.trim();
              final incentive = int.tryParse(incentiveController.text.trim()) ?? 1000;

              if (title.isNotEmpty && val.isNotEmpty) {
                controller.addNewTarget(title, desc, val, incentive);
                Navigator.pop(context);
              }
            },
            child: const AppText('Assign Goal', fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

// ── HIGH-FIDELITY TARGET DETAIL CARD ──────────────────────────────────────────
class _TargetDetailCard extends StatelessWidget {
  final PerformanceTarget target;

  const _TargetDetailCard({required this.target});

  @override
  Widget build(BuildContext context) {
    // Style configurations based on status
    Color accentColor;
    Color bgLightColor;
    IconData visualIcon;

    if (target.isCompleted) {
      accentColor = AppColors.successColor;
      bgLightColor = const Color(0xFFEAFAF1);
      visualIcon = Iconsax.tick_circle;
    } else {
      switch (target.status) {
        case 'On Track':
          accentColor = AppColors.successColor;
          bgLightColor = const Color(0xFFEAFAF1);
          visualIcon = Iconsax.award;
          break;
        case 'In Progress':
          accentColor = AppColors.warningColor;
          bgLightColor = const Color(0xFFFEF9EC);
          visualIcon = Iconsax.clock;
          break;
        default:
          accentColor = AppColors.primaryColor;
          bgLightColor = AppColors.primaryLight;
          visualIcon = Iconsax.info_circle;
      }
    }

    return GestureDetector(
      onTap: () => Get.to(() => TargetDetailsScreen(target: target)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.slate200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.01),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Top Row: Status badge, Title & Description
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: bgLightColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(visualIcon, color: accentColor, size: 18),
                ),
                const SizedBox(width: 14),
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
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: bgLightColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: AppText(
                              target.status,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: accentColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      AppText(
                        target.description,
                        fontSize: 11,
                        color: AppColors.textColorSecondary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Middle Row: Target details (Targets, Achieved, Progress bar)
            Row(
              children: [
                Expanded(
                  child: _MetricDetailLabel(label: 'Target', value: target.targetValue),
                ),
                Expanded(
                  child: _MetricDetailLabel(label: 'Achieved', value: target.achievedValue),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const AppText('Progress', fontSize: 9.5, color: AppColors.textColorSecondary, fontWeight: FontWeight.w500),
                      const SizedBox(height: 4),
                      AppText('${(target.progress * 100).round()}%', fontSize: 13, color: AppColors.textColorPrimary, fontWeight: FontWeight.w900),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Continuous Linear Progress bar
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
                  widthFactor: target.progress,
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Bottom row: Due date & Frequency
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Iconsax.calendar, size: 12, color: AppColors.textColorHint),
                    const SizedBox(width: 4),
                    AppText(
                      'Due Date: ${DateFormat('dd MMM yyyy').format(target.dueDate)}',
                      fontSize: 10,
                      color: AppColors.textColorSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Iconsax.refresh, size: 12, color: AppColors.textColorHint),
                    const SizedBox(width: 4),
                    AppText(
                      target.frequency,
                      fontSize: 10,
                      color: AppColors.textColorSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricDetailLabel extends StatelessWidget {
  final String label;
  final String value;

  const _MetricDetailLabel({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(label, fontSize: 9.5, color: AppColors.textColorSecondary, fontWeight: FontWeight.w500),
        const SizedBox(height: 4),
        AppText(value, fontSize: 13, color: AppColors.textColorPrimary, fontWeight: FontWeight.w800),
      ],
    );
  }
}
