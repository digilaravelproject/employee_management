import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/leads_controller.dart';
import 'tabs/leads_list_tab.dart';
import 'tabs/follow_ups_tab.dart';
import 'tabs/customers_tab.dart';
import 'add_edit_lead_screen.dart';
import 'bde_leads_target_screen.dart';

class LeadsDashboardShell extends StatelessWidget {
  const LeadsDashboardShell({super.key});

  @override
  Widget build(BuildContext context) {
    // Put controller in memory
    final controller = Get.put(LeadsController());

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
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
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textColorPrimary, size: 20),
              onPressed: () => Get.back(),
            ),
          ),
        ),
        title: Obx(() {
          final titles = ['Leads Dashboard', 'Follow-ups', 'Customers Ledger', 'BDE Targets & Sales'];
          return AppText(
            titles[controller.currentTabIdx.value],
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textColorPrimary,
          );
        }),
        centerTitle: false,
        actions: [
          // Symmetrical Toggle ListView/KanbanView Button (only on Leads tab)
          // Obx(() {
          //   if (controller.currentTabIdx.value != 0) return const SizedBox();
          //   final isKanban = controller.isKanbanView.value;
          //   return IconButton(
          //     icon: Icon(
          //       isKanban ? Iconsax.menu : Iconsax.kanban,
          //       color: AppColors.primaryColor,
          //       size: 22,
          //     ),
          //     tooltip: isKanban ? 'Switch to List View' : 'Switch to Kanban View',
          //     onPressed: () {
          //       controller.isKanbanView.value = !isKanban;
          //     },
          //   );
          // }),
          // Obx(() {
          //   if (controller.currentTabIdx.value != 0) return const SizedBox();
          //   return IconButton(
          //     icon: const Icon(Iconsax.refresh, color: AppColors.textColorSecondary),
          //     onPressed: () {
          //       controller.selectedFilter.value = 'All';
          //       controller.searchQuery.value = '';
          //     },
          //   );
          // }),
          // Add lead button in the AppBar for luxury layout consistency
          Obx(() {
            final tabIdx = controller.currentTabIdx.value;
            if (tabIdx != 0 && tabIdx != 2) return const SizedBox();
            return Padding(
              padding: const EdgeInsets.only(right: 16.0, left: 4.0),
              child: GestureDetector(
                onTap: () {
                  controller.clearForm();
                  Get.to(() => const AddEditLeadScreen(isEditMode: false));
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 18),
                ),
              ),
            );
          }),
        ],
      ),
      body: Column(
        children: [
          // ── Beautiful Premium Top Segmented Switch Selector ──
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.slate100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Obx(() {
                return Row(
                  children: [
                    _buildSegmentItem(controller, 'Leads', 0),
                    _buildSegmentItem(controller, 'Follow-ups', 1),
                    _buildSegmentItem(controller, 'Customers', 2),
                    _buildSegmentItem(controller, 'Targets', 3),
                  ],
                );
              }),
            ),
          ),

          // ── Active View Body ──
          Expanded(
            child: Obx(() {
              switch (controller.currentTabIdx.value) {
                case 0:
                  return const LeadsListTab();
                case 1:
                  return const FollowUpsTab();
                case 2:
                  return const CustomersTab();
                default:
                  return const _BdeTargetsTabGateway();
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentItem(LeadsController controller, String title, int index) {
    final isSelected = controller.currentTabIdx.value == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          controller.currentTabIdx.value = index;
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: AppText(
            title,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? AppColors.primaryColor : AppColors.textColorSecondary,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _BdeTargetsTabGateway extends StatelessWidget {
  const _BdeTargetsTabGateway();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Iconsax.chart_21, color: Color(0xFF38BDF8), size: 28),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            'BDE Sales Targets & Deals',
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          SizedBox(height: 2),
                          AppText(
                            'Monthly targets, closed leads & rankings',
                            fontSize: 12,
                            color: Color(0xFF94A3B8),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const AppText(
                  'Manage individual sales targets for Business Development Executives, track closed deal values against targets with month filters, and monitor the executive leaderboard.',
                  fontSize: 13,
                  color: Color(0xFFCBD5E1),
                  height: 1.5,
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF38BDF8),
                      foregroundColor: const Color(0xFF0F172A),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    icon: const Icon(Iconsax.arrow_right_3, size: 18, color: Color(0xFF0F172A)),
                    label: const AppText(
                      'Open Targets & Leaderboard',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                    onPressed: () {
                      Get.to(() => const BdeLeadsTargetScreen());
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Features Breakdown Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppText(
                  'Module Highlights',
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColorPrimary,
                ),
                const SizedBox(height: 14),
                _buildHighlightRow(
                  icon: Iconsax.status_up,
                  title: 'Monthly Target Progress',
                  desc: 'Track target vs achieved revenue with auto-updating progress bar',
                  color: Colors.blue,
                ),
                const SizedBox(height: 12),
                _buildHighlightRow(
                  icon: Iconsax.verify,
                  title: 'Closed Deals Breakdown',
                  desc: 'Inspect each converted lead, closed amount, date, and notes',
                  color: Colors.green,
                ),
                const SizedBox(height: 12),
                _buildHighlightRow(
                  icon: Iconsax.ranking,
                  title: 'Executive Leaderboard & Target Setting',
                  desc: 'Assign and edit targets for each BDE and track rankings',
                  color: Colors.purple,
                ),
                const SizedBox(height: 12),
                _buildHighlightRow(
                  icon: Iconsax.calendar,
                  title: 'Month-by-Month Filter',
                  desc: 'Seamlessly switch between September, August, July to review historical targets',
                  color: Colors.orange,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightRow({
    required IconData icon,
    required String title,
    required String desc,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(title, fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
              const SizedBox(height: 2),
              AppText(desc, fontSize: 11, color: AppColors.textColorSecondary),
            ],
          ),
        ),
      ],
    );
  }
}
