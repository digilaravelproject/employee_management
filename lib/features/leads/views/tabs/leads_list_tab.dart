import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text.dart';
import '../../controllers/leads_controller.dart';
import '../../models/lead_model.dart';
import '../lead_details_screen.dart';
import 'leads_kanban_tab.dart';

class LeadsListTab extends StatelessWidget {
  const LeadsListTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LeadsController>();

    return Obx(() {
      if (controller.isKanbanView.value) {
        return const LeadsKanbanTab();
      }
      
      return Column(
        children: [
          // ── Search & Query Bar ──
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.slate50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.slate100),
                    ),
                    child: TextField(
                      onChanged: (value) => controller.searchQuery.value = value,
                      decoration: const InputDecoration(
                        hintText: 'Search leads...',
                        hintStyle: TextStyle(color: AppColors.textColorHint, fontSize: 14),
                        prefixIcon: Icon(Iconsax.search_normal, color: AppColors.textColorHint, size: 20),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Symmetrical Category Count Stat Deck ──
          const SizedBox(height: 10),
          SizedBox(
            height: 74,
            child: Obx(() {
              return ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildStatCard(
                    title: 'All Leads',
                    value: '${controller.totalLeadsCount}',
                    color: AppColors.primaryColor,
                    isSelected: controller.selectedFilter.value == 'All',
                    onTap: () => controller.selectedFilter.value = 'All',
                  ),
                  _buildStatCard(
                    title: 'New',
                    value: '${controller.newLeadsCount}',
                    color: AppColors.infoColor,
                    isSelected: controller.selectedFilter.value == 'New',
                    onTap: () => controller.selectedFilter.value = 'New',
                  ),
                  _buildStatCard(
                    title: 'Contacted',
                    value: '${controller.contactedLeadsCount}',
                    color: AppColors.warningColor,
                    isSelected: controller.selectedFilter.value == 'Contacted',
                    onTap: () => controller.selectedFilter.value = 'Contacted',
                  ),
                  _buildStatCard(
                    title: 'Converted',
                    value: '${controller.convertedLeadsCount}',
                    color: AppColors.successColor,
                    isSelected: controller.selectedFilter.value == 'Converted',
                    onTap: () => controller.selectedFilter.value = 'Converted',
                  ),
                ],
              );
            }),
          ),
          const SizedBox(height: 12),

          // ── Symmetrical Leads List Builder ──
          Expanded(
            child: Obx(() {
              final list = controller.filteredLeads;
              if (list.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Iconsax.user_search, size: 64, color: AppColors.textColorHint.withValues(alpha: 0.3)),
                      const SizedBox(height: 16),
                      const AppText('No Leads Found', fontSize: 16, fontWeight: FontWeight.bold),
                      const SizedBox(height: 4),
                      AppText(
                        controller.searchQuery.value.isNotEmpty
                            ? 'Try refining your search terms'
                            : 'No leads available under this category',
                        fontSize: 12,
                        color: AppColors.textColorHint,
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                physics: const BouncingScrollPhysics(),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final lead = list[index];
                  return _LeadListItemCard(lead: lead);
                },
              );
            }),
          ),
        ],
      );
    });
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 104,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.06) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : AppColors.slate200,
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.015),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AppText(
              title,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isSelected ? color : AppColors.textColorSecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            AppText(
              value,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: isSelected ? color : AppColors.textColorPrimary,
            ),
          ],
        ),
      ),
    );
  }
}

class _LeadListItemCard extends StatelessWidget {
  final Lead lead;
  const _LeadListItemCard({required this.lead});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LeadsController>();
    final statusColor = _getStatusColor(lead.leadStatus);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.slate200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            controller.selectedLead.value = lead;
            controller.selectedTabIdx.value = 0;
            Get.to(() => const LeadDetailsScreen());
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Initials Circle Avatar
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryColor.withValues(alpha: 0.15),
                        AppColors.indigo500.withValues(alpha: 0.15),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: AppColors.slate100, width: 1.5),
                  ),
                  child: Center(
                    child: AppText(
                      lead.name.isNotEmpty ? lead.name.substring(0, 2).toUpperCase() : 'LD',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Lead info block
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        lead.name,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColorPrimary,
                      ),
                      const SizedBox(height: 2),
                      AppText(
                        lead.mobile,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColorSecondary,
                      ),
                      const SizedBox(height: 4),
                      AppText(
                        'Source: ${lead.leadSource}',
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textColorHint,
                      ),
                    ],
                  ),
                ),

                // Status pill
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: AppText(
                        lead.leadStatus,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: AppColors.textColorHint,
                      size: 14,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'New':
        return AppColors.infoColor;
      case 'Contacted':
        return AppColors.warningColor;
      case 'Converted':
        return AppColors.successColor;
      default:
        return AppColors.primaryColor;
    }
  }
}
