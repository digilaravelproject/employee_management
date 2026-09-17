import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/bde_leads_controller.dart';
import '../models/lead_model.dart';
import '../models/bde_target_model.dart';

class BdeLeadsTargetScreen extends StatelessWidget {
  const BdeLeadsTargetScreen({super.key});

  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static String formatInr(double amount) {
    return _currencyFormat.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BdeLeadsController());

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
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textColorPrimary, size: 18),
              onPressed: () => Get.back(),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText(
              'Sales Targets & Leads',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textColorPrimary,
            ),
            Obx(() => AppText(
                  controller.activeView.value == 'employee'
                      ? 'BDE Executive Portal'
                      : 'Manager & Team Overview',
                  fontSize: 12,
                  color: AppColors.textColorSecondary,
                  fontWeight: FontWeight.w500,
                )),
          ],
        ),
        actions: [
          // Role Perspective Switcher Pill
          Obx(() {
            final isEmployee = controller.activeView.value == 'employee';
            return Padding(
              padding: const EdgeInsets.only(right: 14.0),
              child: InkWell(
                onTap: () {
                  controller.activeView.value = isEmployee ? 'manager' : 'employee';
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isEmployee
                        ? AppColors.primaryColor.withValues(alpha: 0.1)
                        : Colors.purple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isEmployee
                          ? AppColors.primaryColor.withValues(alpha: 0.3)
                          : Colors.purple.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isEmployee ? Iconsax.user : Iconsax.people,
                        size: 14,
                        color: isEmployee ? AppColors.primaryColor : Colors.purple,
                      ),
                      const SizedBox(width: 5),
                      AppText(
                        isEmployee ? 'My View' : 'Team View',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isEmployee ? AppColors.primaryColor : Colors.purple,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
      floatingActionButton: Obx(() {
        if (controller.activeView.value != 'employee') return const SizedBox();
        return FloatingActionButton.extended(
          backgroundColor: AppColors.primaryColor,
          elevation: 4,
          icon: const Icon(Icons.add_circle_outline, color: Colors.white),
          label: const AppText(
            'New Lead',
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          onPressed: () => _showAddLeadDialog(context, controller),
        );
      }),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. Month Switcher Bar ──
            _buildMonthSelectorBar(context, controller),
            const SizedBox(height: 16),

            // ── 2. Content based on View (Employee vs Manager) ──
            Obx(() {
              if (controller.activeView.value == 'employee') {
                return _buildEmployeePerspective(context, controller);
              } else {
                return _buildManagerPerspective(context, controller);
              }
            }),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // 1. MONTH SELECTOR HEADER
  // ─────────────────────────────────────────────
  Widget _buildMonthSelectorBar(BuildContext context, BdeLeadsController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Obx(() {
        final currentMonth = controller.selectedMonth.value;
        final months = controller.availableMonths;
        final hasPrev = months.indexOf(currentMonth) < months.length - 1;
        final hasNext = months.indexOf(currentMonth) > 0;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(
                Icons.chevron_left_rounded,
                color: hasPrev ? AppColors.textColorPrimary : Colors.grey.shade300,
                size: 26,
              ),
              onPressed: hasPrev ? controller.previousMonth : null,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            GestureDetector(
              onTap: () => _showMonthPickerSheet(context, controller),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.slate100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Iconsax.calendar_1, size: 16, color: AppColors.primaryColor),
                    const SizedBox(width: 8),
                    AppText(
                      currentMonth,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColorPrimary,
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppColors.textColorSecondary),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.chevron_right_rounded,
                color: hasNext ? AppColors.textColorPrimary : Colors.grey.shade300,
                size: 26,
              ),
              onPressed: hasNext ? controller.nextMonth : null,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        );
      }),
    );
  }

  void _showMonthPickerSheet(BuildContext context, BdeLeadsController controller) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const AppText(
              'Select Target Month',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textColorPrimary,
            ),
            const SizedBox(height: 4),
            const AppText(
              'View performance metrics and closed leads for specific months',
              fontSize: 12,
              color: AppColors.textColorSecondary,
            ),
            const SizedBox(height: 16),
            ...controller.availableMonths.map((m) {
              return Obx(() {
                final isSelected = controller.selectedMonth.value == m;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    tileColor: isSelected ? AppColors.primaryColor.withValues(alpha: 0.08) : AppColors.slate100,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected ? AppColors.primaryColor : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    leading: Icon(
                      Iconsax.calendar_2,
                      color: isSelected ? AppColors.primaryColor : AppColors.textColorSecondary,
                    ),
                    title: AppText(
                      m,
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected ? AppColors.primaryColor : AppColors.textColorPrimary,
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: AppColors.primaryColor, size: 20)
                        : null,
                    onTap: () {
                      controller.selectMonth(m);
                      Get.back();
                    },
                  ),
                );
              });
            }),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  // ─────────────────────────────────────────────
  // 2. EMPLOYEE (BDE) PERSPECTIVE
  // ─────────────────────────────────────────────
  Widget _buildEmployeePerspective(BuildContext context, BdeLeadsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── A. Executive Hero Monthly Target Card ──
        _buildHeroTargetCard(controller),
        const SizedBox(height: 20),

        // ── B. Closed Deals This Month ("kon kon si lead kitne ki thi jo close ki") ──
        _buildClosedDealsSection(context, controller),
        const SizedBox(height: 24),

        // ── C. Pipeline Leads with Stage Filter Tabs ──
        _buildPipelineLeadsSection(context, controller),
      ],
    );
  }

  Widget _buildHeroTargetCard(BdeLeadsController controller) {
    return Obx(() {
      final target = controller.currentEmployeeTarget;
      final achieved = controller.myAchievedRevenueInMonth;
      final percentage = controller.myAchievementPercentage;
      final remaining = controller.myRemainingGap;
      final dealsWon = controller.myClosedDealsInMonth.length;
      final pctDisplay = (percentage * 100).toStringAsFixed(1);
      final isTargetAchieved = percentage >= 1.0;

      return Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Top Executive Name & Month
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white.withValues(alpha: 0.15),
                      backgroundImage: NetworkImage(target.avatarUrl),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          target.employeeName,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        const AppText(
                          'Business Development Executive',
                          fontSize: 11,
                          color: Color(0xFF94A3B8),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isTargetAchieved
                        ? Colors.green.withValues(alpha: 0.25)
                        : Colors.blue.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isTargetAchieved ? Colors.greenAccent : Colors.lightBlueAccent,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isTargetAchieved ? Icons.verified : Iconsax.timer,
                        size: 13,
                        color: isTargetAchieved ? Colors.greenAccent : Colors.lightBlueAccent,
                      ),
                      const SizedBox(width: 4),
                      AppText(
                        isTargetAchieved ? 'Target Met!' : '$pctDisplay%',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isTargetAchieved ? Colors.greenAccent : Colors.lightBlueAccent,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Middle Target vs Achieved Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppText(
                      'Achieved Revenue',
                      fontSize: 12,
                      color: Color(0xFF94A3B8),
                      fontWeight: FontWeight.w500,
                    ),
                    const SizedBox(height: 4),
                    AppText(
                      formatInr(achieved),
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF38BDF8), // vibrant cyan
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const AppText(
                      'Assigned Target',
                      fontSize: 12,
                      color: Color(0xFF94A3B8),
                      fontWeight: FontWeight.w500,
                    ),
                    const SizedBox(height: 4),
                    AppText(
                      formatInr(target.targetAmount),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: percentage.clamp(0.0, 1.0),
                minHeight: 10,
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(
                  isTargetAchieved
                      ? const Color(0xFF10B981) // Emerald Green
                      : const Color(0xFF38BDF8), // Sky Blue
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Bottom Metrics Chips
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Iconsax.cup, size: 16, color: Color(0xFFFBBF24)),
                      const SizedBox(width: 6),
                      AppText(
                        '$dealsWon Deals Won',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        isTargetAchieved ? Icons.check : Icons.trending_up,
                        size: 16,
                        color: isTargetAchieved ? const Color(0xFF10B981) : const Color(0xFFF43F5E),
                      ),
                      const SizedBox(width: 6),
                      AppText(
                        isTargetAchieved
                            ? 'Goal Achieved (+${formatInr(achieved - target.targetAmount)})'
                            : '${formatInr(remaining)} Remaining',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isTargetAchieved ? const Color(0xFF10B981) : const Color(0xFFFCA5A5),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  // ─────────────────────────────────────────────
  // B. CLOSED DEALS SECTION (LIST OF WON LEADS WITH AMOUNT)
  // ─────────────────────────────────────────────
  Widget _buildClosedDealsSection(BuildContext context, BdeLeadsController controller) {
    return Obx(() {
      final closedDeals = controller.myClosedDealsInMonth;
      final month = controller.selectedMonth.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Iconsax.verify, color: Colors.green, size: 18),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppText(
                        'Closed Deals This Month',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColorPrimary,
                      ),
                      AppText(
                        '${closedDeals.length} deals closed in $month',
                        fontSize: 11,
                        color: AppColors.textColorSecondary,
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: AppText(
                  formatInr(controller.myAchievedRevenueInMonth),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: Colors.green.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (closedDeals.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Icon(Iconsax.empty_wallet, size: 36, color: Colors.grey.shade400),
                  const SizedBox(height: 8),
                  AppText(
                    'No deals closed in $month yet',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColorSecondary,
                  ),
                  const SizedBox(height: 4),
                  const AppText(
                    'Convert pipeline leads to hit your target!',
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: closedDeals.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final lead = closedDeals[index];
                return _buildClosedDealCard(lead);
              },
            ),
        ],
      );
    });
  }

  Widget _buildClosedDealCard(Lead lead) {
    final dealAmount = lead.dealValue ?? lead.estimatedValue;
    final closeDate = lead.conversionDate ?? lead.createdOn;
    final formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(closeDate);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.green.withValues(alpha: 0.25), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      lead.companyName,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColorPrimary,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Iconsax.user, size: 12, color: AppColors.textColorSecondary),
                        const SizedBox(width: 4),
                        AppText(
                          '${lead.name} (${lead.designation})',
                          fontSize: 12,
                          color: AppColors.textColorSecondary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Prominent Green Deal Value Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7), // Light green
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF86EFAC)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const AppText(
                      'Deal Closed For',
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF166534),
                    ),
                    AppText(
                      '+ ${formatInr(dealAmount)}',
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF15803D),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 10),

          // Closing metadata & notes
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Iconsax.calendar_tick, size: 13, color: Colors.green),
                  const SizedBox(width: 5),
                  AppText(
                    formattedDate,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.slate100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(Iconsax.global, size: 11, color: AppColors.textColorSecondary),
                    const SizedBox(width: 4),
                    AppText(
                      lead.leadSource,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColorSecondary,
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (lead.conversionNotes != null && lead.conversionNotes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Iconsax.note_2, size: 12, color: Colors.blueGrey),
                  const SizedBox(width: 6),
                  Expanded(
                    child: AppText(
                      lead.conversionNotes!,
                      fontSize: 11,
                      color: Colors.blueGrey.shade700,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // C. PIPELINE LEADS SECTION & STAGE FILTER
  // ─────────────────────────────────────────────
  Widget _buildPipelineLeadsSection(BuildContext context, BdeLeadsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const AppText(
              'My Lead Pipeline',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textColorPrimary,
            ),
            Obx(() => AppText(
                  '${controller.filteredEmployeeLeads.length} leads',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColorSecondary,
                )),
          ],
        ),
        const SizedBox(height: 10),

        // Stage Filter Pills (All, In Pipeline, Closed Won, Lost)
        _buildStageFilterChips(controller),
        const SizedBox(height: 14),

        // Pipeline Leads List
        Obx(() {
          final leads = controller.filteredEmployeeLeads;
          if (leads.isEmpty) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Icon(Iconsax.folder_cross, size: 36, color: Colors.grey.shade400),
                  const SizedBox(height: 8),
                  const AppText(
                    'No leads in this category',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColorSecondary,
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: leads.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final lead = leads[index];
              return _buildPipelineLeadCard(context, lead, controller);
            },
          );
        }),
      ],
    );
  }

  Widget _buildStageFilterChips(BdeLeadsController controller) {
    final stages = ['All', 'In Pipeline', 'Closed Won', 'Lost'];

    return Obx(() {
      final selected = controller.selectedStageFilter.value;
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: stages.map((stage) {
            final isSelected = selected == stage;
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ChoiceChip(
                label: AppText(
                  stage,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.textColorSecondary,
                ),
                selected: isSelected,
                selectedColor: AppColors.primaryColor,
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected ? AppColors.primaryColor : const Color(0xFFE2E8F0),
                  ),
                ),
                onSelected: (val) {
                  if (val) controller.selectedStageFilter.value = stage;
                },
              ),
            );
          }).toList(),
        ),
      );
    });
  }

  Widget _buildPipelineLeadCard(
    BuildContext context,
    Lead lead,
    BdeLeadsController controller,
  ) {
    final status = lead.leadStatus.toLowerCase();
    final isWon = status == 'converted' || status == 'closed won';
    final isLost = status == 'lost' || status == 'closed lost';

    Color badgeColor = Colors.blue;
    if (isWon) {
      badgeColor = Colors.green;
    } else if (isLost) {
      badgeColor = Colors.red;
    } else if (status.contains('negotiation')) {
      badgeColor = Colors.purple;
    } else if (status.contains('proposal')) {
      badgeColor = Colors.orange;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Company & Status Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      lead.companyName,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColorPrimary,
                    ),
                    const SizedBox(height: 3),
                    AppText(
                      '${lead.name} • ${lead.designation}',
                      fontSize: 12,
                      color: AppColors.textColorSecondary,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
                ),
                child: AppText(
                  lead.leadStatus,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: badgeColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Key Values: Estimated Value & Expected Closing
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.slate100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Iconsax.coin, size: 16, color: Colors.amber),
                    const SizedBox(width: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AppText('Est. Value', fontSize: 10, color: AppColors.textColorSecondary),
                        AppText(
                          formatInr(lead.estimatedValue),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColorPrimary,
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Iconsax.calendar_1, size: 16, color: Colors.blueGrey),
                    const SizedBox(width: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AppText('Target Closing', fontSize: 10, color: AppColors.textColorSecondary),
                        AppText(
                          DateFormat('dd MMM yyyy').format(lead.expectedClosingDate),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColorPrimary,
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Iconsax.call, size: 16, color: Colors.teal),
                    const SizedBox(width: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AppText('Score', fontSize: 10, color: AppColors.textColorSecondary),
                        AppText(
                          '${lead.leadScore}/100',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (lead.notes.isNotEmpty) ...[
            const SizedBox(height: 10),
            AppText(
              lead.notes,
              fontSize: 11,
              color: Colors.grey.shade600,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          // Action Buttons for active pipeline leads
          if (!isWon && !isLost) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 10),
            Row(
              children: [
                // Quick Stage Shift Dropdown
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    icon: const Icon(Iconsax.edit_2, size: 14, color: AppColors.textColorSecondary),
                    label: const AppText('Stage', fontSize: 12, color: AppColors.textColorSecondary),
                    onPressed: () => _showUpdateStageSheet(context, lead, controller),
                  ),
                ),
                const SizedBox(width: 10),

                // Close & Win Deal Button!
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF15803D), // Forest Green
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.check_circle_outline, size: 15, color: Colors.white),
                    label: const AppText(
                      'Close & Win Deal',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    onPressed: () => _showWinDealDialog(context, lead, controller),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // 3. MANAGER / ADMIN PERSPECTIVE
  // ─────────────────────────────────────────────
  Widget _buildManagerPerspective(BuildContext context, BdeLeadsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── A. Team Total Performance Hero ──
        _buildTeamTotalCard(controller),
        const SizedBox(height: 20),

        // ── B. Executive Leaderboard & Targets ──
        _buildLeaderboardSection(context, controller),
      ],
    );
  }

  Widget _buildTeamTotalCard(BdeLeadsController controller) {
    return Obx(() {
      final teamTarget = controller.teamTargetAmount;
      final teamAchieved = controller.teamAchievedRevenue;
      final wonCount = controller.teamDealsWonCount;
      final month = controller.selectedMonth.value;
      final percentage = teamTarget > 0 ? (teamAchieved / teamTarget) : 0.0;
      final pctDisplay = (percentage * 100).toStringAsFixed(1);

      return Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2E1065), Color(0xFF4C1D95)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withValues(alpha: 0.3),
              blurRadius: 16,
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppText(
                      'BDE Team Target Summary',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    AppText(
                      'Overall sales metrics for $month',
                      fontSize: 11,
                      color: const Color(0xFFDDD6FE),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: AppText(
                    '$pctDisplay% Achieved',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppText('Total Revenue Won', fontSize: 11, color: Color(0xFFDDD6FE)),
                    const SizedBox(height: 4),
                    AppText(
                      formatInr(teamAchieved),
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF67E8F9),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const AppText('Cumulative Team Target', fontSize: 11, color: Color(0xFFDDD6FE)),
                    const SizedBox(height: 4),
                    AppText(
                      formatInr(teamTarget),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: percentage.clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: Colors.white.withValues(alpha: 0.15),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF34D399)),
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Iconsax.award, color: Colors.amber, size: 16),
                      const SizedBox(width: 6),
                      AppText(
                        '$wonCount Deals Closed by Team',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ],
                  ),
                  AppText(
                    '${formatInr(teamTarget - teamAchieved > 0 ? teamTarget - teamAchieved : 0)} to Target',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFDDD6FE),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildLeaderboardSection(BuildContext context, BdeLeadsController controller) {
    return Obx(() {
      final leaderboard = controller.teamLeaderboard;
      final month = controller.selectedMonth.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppText(
                    'Executive Target Leaderboard',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColorPrimary,
                  ),
                  AppText(
                    'Ranked by closed deal revenue in $month',
                    fontSize: 11,
                    color: AppColors.textColorSecondary,
                  ),
                ],
              ),
              const Icon(Iconsax.ranking, color: AppColors.primaryColor, size: 22),
            ],
          ),
          const SizedBox(height: 12),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: leaderboard.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = leaderboard[index];
              final rank = index + 1;
              return _buildExecutiveLeaderboardCard(context, item, rank, controller);
            },
          ),
        ],
      );
    });
  }

  Widget _buildExecutiveLeaderboardCard(
    BuildContext context,
    BdeLeaderboardItem item,
    int rank,
    BdeLeadsController controller,
  ) {
    final target = item.target;
    final achieved = item.achievedAmount;
    final pct = item.completionPercentage;
    final pctDisplay = (pct * 100).toStringAsFixed(1);
    final isTop3 = rank <= 3;

    Color rankColor = AppColors.textColorSecondary;
    if (rank == 1) rankColor = const Color(0xFFF59E0B); // Gold
    if (rank == 2) rankColor = const Color(0xFF94A3B8); // Silver
    if (rank == 3) rankColor = const Color(0xFFB45309); // Bronze

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isTop3 ? rankColor.withValues(alpha: 0.3) : const Color(0xFFE2E8F0),
          width: isTop3 ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Rank Badge
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: rankColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: rankColor, width: 1.5),
                ),
                child: AppText(
                  '#$rank',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: rankColor,
                ),
              ),
              const SizedBox(width: 10),
              CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(target.avatarUrl),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      target.employeeName,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColorPrimary,
                    ),
                    Row(
                      children: [
                        AppText(
                          '${item.wonDealsCount} Won',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade700,
                        ),
                        const SizedBox(width: 6),
                        const AppText('•', fontSize: 11, color: Colors.grey),
                        const SizedBox(width: 6),
                        AppText(
                          '$pctDisplay% of Target',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: pct >= 1.0 ? Colors.green : AppColors.primaryColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Edit Target Action for Manager
              IconButton(
                icon: const Icon(Iconsax.edit_2, size: 18, color: AppColors.primaryColor),
                tooltip: 'Edit Monthly Target',
                onPressed: () => _showEditTargetDialog(context, target, controller),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Numbers: Achieved vs Target
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                'Achieved: ${formatInr(achieved)}',
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              ),
              AppText(
                'Target: ${formatInr(target.targetAmount)}',
                fontSize: 12,
                color: AppColors.textColorSecondary,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation<Color>(
                pct >= 1.0 ? const Color(0xFF10B981) : AppColors.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // DIALOGS & ACTIONS
  // ─────────────────────────────────────────────

  // Win Deal Dialog (Enter Final Deal Value and Notes)
  void _showWinDealDialog(BuildContext context, Lead lead, BdeLeadsController controller) {
    final valueController = TextEditingController(text: lead.estimatedValue.toStringAsFixed(0));
    final notesController = TextEditingController(text: 'Contract finalized and signed.');

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.celebration, color: Colors.green, size: 22),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AppText('Close & Win Deal! 🚀', fontSize: 16, fontWeight: FontWeight.bold),
                        AppText(lead.companyName, fontSize: 12, color: AppColors.textColorSecondary),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const AppText(
                'Final Closed Deal Amount (₹)*',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textColorPrimary,
              ),
              const SizedBox(height: 6),
              TextField(
                controller: valueController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixText: '₹ ',
                  prefixStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                  filled: true,
                  fillColor: AppColors.slate100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const AppText(
                'Closure Notes / Deliverables',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textColorPrimary,
              ),
              const SizedBox(height: 6),
              TextField(
                controller: notesController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'e.g. 1-year contract, 50 user licenses...',
                  filled: true,
                  fillColor: AppColors.slate100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      child: const AppText('Cancel', color: AppColors.textColorSecondary),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF15803D),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        final val = double.tryParse(valueController.text.trim()) ?? lead.estimatedValue;
                        controller.markLeadAsWon(
                          leadId: lead.id,
                          finalDealValue: val,
                          notes: notesController.text.trim(),
                        );
                        Get.back();
                      },
                      child: const AppText('Confirm Win', color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Update Stage Sheet
  void _showUpdateStageSheet(BuildContext context, Lead lead, BdeLeadsController controller) {
    final stages = ['New', 'Contacted', 'Proposal Sent', 'Negotiation', 'Lost'];

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText('Update Pipeline Stage', fontSize: 16, fontWeight: FontWeight.bold),
            AppText(lead.companyName, fontSize: 12, color: AppColors.textColorSecondary),
            const SizedBox(height: 16),
            ...stages.map((stage) {
              final isCurrent = lead.leadStatus.toLowerCase() == stage.toLowerCase();
              return ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                title: AppText(
                  stage,
                  fontSize: 14,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  color: isCurrent ? AppColors.primaryColor : AppColors.textColorPrimary,
                ),
                trailing: isCurrent ? const Icon(Icons.check, color: AppColors.primaryColor) : null,
                onTap: () {
                  controller.updateLeadStage(lead.id, stage);
                  Get.back();
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  // Manager Edit Target Dialog
  void _showEditTargetDialog(BuildContext context, BdeTargetModel target, BdeLeadsController controller) {
    final targetController = TextEditingController(text: target.targetAmount.toStringAsFixed(0));
    final month = controller.selectedMonth.value;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(radius: 18, backgroundImage: NetworkImage(target.avatarUrl)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(target.employeeName, fontSize: 15, fontWeight: FontWeight.bold),
                        AppText('Set Target for $month', fontSize: 11, color: AppColors.textColorSecondary),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const AppText('Monthly Target Amount (₹)', fontSize: 12, fontWeight: FontWeight.bold),
              const SizedBox(height: 6),
              TextField(
                controller: targetController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixText: '₹ ',
                  prefixStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                  filled: true,
                  fillColor: AppColors.slate100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      child: const AppText('Cancel', color: AppColors.textColorSecondary),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        final val = double.tryParse(targetController.text.trim());
                        if (val != null && val > 0) {
                          controller.updateExecutiveTarget(
                            employeeEmail: target.employeeEmail,
                            month: month,
                            newTargetAmount: val,
                          );
                        }
                        Get.back();
                      },
                      child: const AppText('Save Target', color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Quick Add Lead Modal (for BDE Self-Sourcing)
  void _showAddLeadDialog(BuildContext context, BdeLeadsController controller) {
    final nameCtrl = TextEditingController();
    final companyCtrl = TextEditingController();
    final valueCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    String source = 'Website';

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const AppText('Add New Pipeline Lead', fontSize: 16, fontWeight: FontWeight.bold),
              const AppText('Register a prospect to your pipeline', fontSize: 12, color: AppColors.textColorSecondary),
              const SizedBox(height: 16),

              TextField(
                controller: companyCtrl,
                decoration: InputDecoration(
                  labelText: 'Company / Organization Name*',
                  filled: true,
                  fillColor: AppColors.slate100,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                        labelText: 'Contact Person*',
                        filled: true,
                        fillColor: AppColors.slate100,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        filled: true,
                        fillColor: AppColors.slate100,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              TextField(
                controller: valueCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Estimated Deal Value (₹)*',
                  prefixText: '₹ ',
                  filled: true,
                  fillColor: AppColors.slate100,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 10),

              TextField(
                controller: notesCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Requirements / Notes',
                  filled: true,
                  fillColor: AppColors.slate100,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    if (companyCtrl.text.trim().isEmpty || nameCtrl.text.trim().isEmpty) {
                      Get.snackbar('Missing Details', 'Please enter Company and Contact Person name.');
                      return;
                    }

                    final estVal = double.tryParse(valueCtrl.text.trim()) ?? 50000.0;
                    final rahul = controller.salesExecutives.first;

                    final newLead = Lead(
                      id: 'BDE-${DateTime.now().millisecondsSinceEpoch}',
                      name: nameCtrl.text.trim(),
                      companyName: companyCtrl.text.trim(),
                      email: '${nameCtrl.text.trim().toLowerCase().replaceAll(' ', '.')}@example.com',
                      mobile: phoneCtrl.text.trim().isNotEmpty ? phoneCtrl.text.trim() : '+91 98000 11122',
                      designation: 'Decision Maker',
                      leadSource: source,
                      leadStatus: 'New',
                      leadScore: 60,
                      assignedTo: rahul,
                      location: 'Delhi NCR',
                      estimatedValue: estVal,
                      expectedClosingDate: DateTime.now().add(const Duration(days: 15)),
                      notes: notesCtrl.text.trim(),
                      createdOn: DateTime.now(),
                      followUps: [],
                    );

                    controller.addNewBdeLead(newLead);
                    Get.back();
                  },
                  child: const AppText('Add to Pipeline', color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}
