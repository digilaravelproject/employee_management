import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/leads_controller.dart';
import '../models/lead_model.dart';
import 'lead_details_screen.dart';
import 'add_edit_lead_screen.dart';

class LeadsListScreen extends StatelessWidget {
  const LeadsListScreen({super.key});

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
        title: const AppText(
          'Leads',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textColorPrimary,
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0, left: 8.0, top: 8.0, bottom: 8.0),
            child: GestureDetector(
              onTap: () {
                controller.clearForm();
                Get.to(() => const AddEditLeadScreen(isEditMode: false));
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.primaryColor, // Indigo/Blue matching theme
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Horizontal Stats Deck ──
          const SizedBox(height: 12),
          SizedBox(
            height: 84,
            child: Obx(() {
              return ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildStatCard(
                    title: 'Total Leads',
                    value: '${controller.totalLeadsCount}',
                    color: AppColors.indigo500,
                    isSelected: controller.selectedFilter.value == 'All',
                    onTap: () => controller.selectedFilter.value = 'All',
                  ),
                  _buildStatCard(
                    title: 'New',
                    value: '${controller.newLeadsCount}',
                    color: AppColors.primaryColor,
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

          // ── Search & Filter Section ──
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

          // ── Leads Feed List ──
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
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                physics: const BouncingScrollPhysics(),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final lead = list[index];
                  return _LeadListItem(lead: lead);
                },
              );
            }),
          ),
        ],
      ),
    );
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
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.06) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? color : AppColors.slate200,
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
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
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isSelected ? color : AppColors.textColorSecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            AppText(
              value,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: isSelected ? color : AppColors.textColorPrimary,
            ),
          ],
        ),
      ),
    );
  }
}

class _LeadListItem extends StatelessWidget {
  final Lead lead;
  const _LeadListItem({required this.lead});

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
            color: Colors.black.withValues(alpha: 0.02),
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
                // Avatar Left
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryColor.withValues(alpha: 0.2),
                        AppColors.indigo500.withValues(alpha: 0.2),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: AppColors.slate100, width: 1.5),
                  ),
                  child: Center(
                    child: lead.name.isNotEmpty
                        ? AppText(
                            lead.name.substring(0, 1).toUpperCase(),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                          )
                        : const Icon(Iconsax.user, color: AppColors.primaryColor),
                  ),
                ),
                const SizedBox(width: 14),

                // Info Center
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
                        lead.companyName,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColorSecondary,
                      ),
                      const SizedBox(height: 4),
                      AppText(
                        lead.leadSource,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textColorHint,
                      ),
                    ],
                  ),
                ),

                // Status Right
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    AppText(
                      lead.leadStatus,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                    const SizedBox(width: 8),
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
        return AppColors.primaryColor;
      case 'Contacted':
        return AppColors.warningColor;
      case 'Converted':
        return AppColors.successColor;
      default:
        return AppColors.primaryColor;
    }
  }
}
