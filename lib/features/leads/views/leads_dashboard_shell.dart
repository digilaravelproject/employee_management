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
          final titles = ['Leads Dashboard', 'Follow-ups', 'Customers Ledger', 'CRM Analytics'];
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
                    _buildSegmentItem(controller, 'More', 3),
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
                  return const _CRMMorePlaceholder();
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

class _CRMMorePlaceholder extends StatelessWidget {
  const _CRMMorePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Iconsax.setting_4, size: 48, color: AppColors.primaryColor),
          ),
          const SizedBox(height: 16),
          const AppText('CRM Settings & Analytics', fontSize: 16, fontWeight: FontWeight.bold),
          const SizedBox(height: 6),
          const AppText(
            'Analytics reports & triggers are coming soon.',
            fontSize: 12,
            color: AppColors.textColorSecondary,
          ),
        ],
      ),
    );
  }
}
