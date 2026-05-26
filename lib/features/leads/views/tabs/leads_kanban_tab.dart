import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text.dart';
import '../../controllers/leads_controller.dart';
import '../../models/lead_model.dart';
import '../lead_details_screen.dart';

class LeadsKanbanTab extends StatelessWidget {
  const LeadsKanbanTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LeadsController>();

    return Column(
      children: [
        // ── Kanban Column Titles Header ──
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              AppText('Lead Kanban View', fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
              AppText('Drag / Tap cards to explore', fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textColorHint),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // ── Horizontal Column Scroll List ──
        Expanded(
          child: Obx(() {
            final newLeads = controller.leads.where((l) => l.leadStatus == 'New').toList();
            final contactedLeads = controller.leads.where((l) => l.leadStatus == 'Contacted').toList();
            final convertedLeads = controller.leads.where((l) => l.leadStatus == 'Converted').toList();

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildKanbanColumn(
                    title: 'New',
                    count: newLeads.length,
                    leads: newLeads,
                    color: AppColors.infoColor,
                  ),
                  _buildKanbanColumn(
                    title: 'Contacted',
                    count: contactedLeads.length,
                    leads: contactedLeads,
                    color: AppColors.warningColor,
                  ),
                  _buildKanbanColumn(
                    title: 'Converted',
                    count: convertedLeads.length,
                    leads: convertedLeads,
                    color: AppColors.successColor,
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildKanbanColumn({
    required String title,
    required int count,
    required List<Lead> leads,
    required Color color,
  }) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16, bottom: 24),
      decoration: BoxDecoration(
        color: AppColors.slate50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Column header pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              border: Border(bottom: BorderSide(color: AppColors.slate200.withValues(alpha: 0.8))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    AppText(
                      title,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColorPrimary,
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: AppText(
                    '$count',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),

          // Scrollable column items list
          Expanded(
            child: leads.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Iconsax.document_text5, size: 36, color: AppColors.textColorHint.withValues(alpha: 0.3)),
                        const SizedBox(height: 8),
                        const AppText(
                          'No Leads in this stage',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColorHint,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    physics: const BouncingScrollPhysics(),
                    itemCount: leads.length,
                    itemBuilder: (context, index) {
                      final lead = leads[index];
                      return _buildKanbanCard(context, lead, color);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildKanbanCard(BuildContext context, Lead lead, Color statusColor) {
    final controller = Get.find<LeadsController>();
    final formattedDate = DateFormat('dd MMMM yyyy').format(lead.createdOn);

    return DragTarget<Lead>(
      onAcceptWithDetails: (details) {
        // Change dragged lead status dynamically! This makes it extremely interactive!
        final draggedLead = details.data;
        final index = controller.leads.indexWhere((l) => l.id == draggedLead.id);
        if (index != -1) {
          String newStatus = 'New';
          if (statusColor == AppColors.warningColor) newStatus = 'Contacted';
          if (statusColor == AppColors.successColor) newStatus = 'Converted';
          
          controller.leads[index] = draggedLead.copyWith(leadStatus: newStatus);
          Get.snackbar(
            'Lead Updated 🎯',
            'Moved ${draggedLead.name} to $newStatus',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.primaryColor,
            colorText: Colors.white,
            duration: const Duration(seconds: 1),
          );
        }
      },
      builder: (context, candidateData, rejectedData) {
        final cardContent = Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: candidateData.isNotEmpty ? statusColor : AppColors.slate200,
              width: candidateData.isNotEmpty ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.01),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Initials Circle
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryColor.withValues(alpha: 0.1),
                          AppColors.indigo500.withValues(alpha: 0.1),
                        ],
                      ),
                    ),
                    child: Center(
                      child: AppText(
                        lead.name.isNotEmpty ? lead.name.substring(0, 2).toUpperCase() : 'LD',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          lead.name,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColorPrimary,
                        ),
                        const SizedBox(height: 2),
                        AppText(
                          lead.companyName,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColorSecondary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: Divider(color: AppColors.slate100, height: 1),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Iconsax.global_search, size: 10, color: AppColors.textColorHint),
                      const SizedBox(width: 4),
                      AppText(
                        lead.leadSource,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColorHint,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Iconsax.calendar_1, size: 10, color: AppColors.textColorHint),
                      const SizedBox(width: 4),
                      AppText(
                        formattedDate,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColorHint,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );

        return Draggable<Lead>(
          data: lead,
          feedback: Material(
            color: Colors.transparent,
            child: SizedBox(
              width: 256,
              child: cardContent,
            ),
          ),
          childWhenDragging: Opacity(
            opacity: 0.4,
            child: cardContent,
          ),
          child: GestureDetector(
            onTap: () {
              controller.selectedLead.value = lead;
              controller.selectedTabIdx.value = 0;
              Get.to(() => const LeadDetailsScreen());
            },
            child: cardContent,
          ),
        );
      },
    );
  }
}
