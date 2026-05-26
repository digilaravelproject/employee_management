import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_input_field.dart';
import '../controllers/leads_controller.dart';
import '../models/lead_model.dart';
import 'add_edit_lead_screen.dart';
import 'assign_sales_team_screen.dart';
import 'convert_lead_screen.dart';

class LeadDetailsScreen extends StatelessWidget {
  const LeadDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LeadsController>();

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
          'Lead Details',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textColorPrimary,
        ),
        centerTitle: false,
        actions: [
          Obx(() {
            final lead = controller.selectedLead.value;
            if (lead == null) return const SizedBox();
            return IconButton(
              icon: const Icon(Iconsax.edit_2, color: AppColors.textColorSecondary),
              onPressed: () {
                controller.initializeEditing(lead);
                Get.to(() => AddEditLeadScreen(isEditMode: true, leadId: lead.id));
              },
            );
          }),
          Obx(() {
            final lead = controller.selectedLead.value;
            if (lead == null) return const SizedBox();
            return IconButton(
              icon: const Icon(Iconsax.trash, color: AppColors.errorColor),
              onPressed: () => _showDeleteConfirmation(context, controller, lead),
            );
          }),
        ],
      ),
      body: Obx(() {
        final lead = controller.selectedLead.value;
        if (lead == null) {
          return const Center(
            child: AppText('No lead details found.', fontSize: 16, fontWeight: FontWeight.bold),
          );
        }

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Profile Header Section ──
                    _buildProfileHeader(lead),
                    const SizedBox(height: 16),

                    // ── Quick Actions Grid ──
                    _buildQuickActions(lead),
                    const SizedBox(height: 16),

                    // ── Key Details Card ──
                    _buildDetailsCard(lead),
                    const SizedBox(height: 20),

                    // ── Timeline Tab Layout ──
                    _buildTabs(controller),
                    const SizedBox(height: 16),

                    // ── Tab Content ──
                    Obx(() {
                      if (controller.selectedTabIdx.value == 0) {
                        return _buildNotesAndFollowUpsTab(lead);
                      } else {
                        return _buildActivityTimelineTab(lead);
                      }
                    }),
                  ],
                ),
              ),
            ),

            // ── Fixed Bottom Actions Footer ──
            _buildBottomFooter(context, controller, lead),
          ],
        );
      }),
    );
  }

  Widget _buildProfileHeader(Lead lead) {
    final statusColor = _getStatusColor(lead.leadStatus);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.slate200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Lead avatar
              Container(
                width: 64,
                height: 64,
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
                  border: Border.all(color: AppColors.slate100, width: 2),
                ),
                child: Center(
                  child: AppText(
                    lead.name.isNotEmpty ? lead.name.substring(0, 1).toUpperCase() : 'L',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Name and Company
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      lead.name,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColorPrimary,
                    ),
                    const SizedBox(height: 2),
                    AppText(
                      lead.companyName,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColorSecondary,
                    ),
                  ],
                ),
              ),
              // Status Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: AppText(
                  lead.leadStatus,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: statusColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.slate200),
          const SizedBox(height: 12),
          // Score Gauge Card Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star_rounded, color: Colors.orangeAccent, size: 20),
              const SizedBox(width: 6),
              AppText(
                'Lead Score',
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textColorSecondary,
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.slate100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: AppText(
                  '${lead.leadScore}/100',
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textColorPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(Lead lead) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActionItem(
          icon: Icons.phone_outlined,
          label: 'Call',
          onTap: () => Get.snackbar('Mock Action', 'Dialing ${lead.mobile}...', backgroundColor: AppColors.primaryColor, colorText: Colors.white),
        ),
        _buildActionItem(
          icon: Icons.mail_outline_rounded,
          label: 'Email',
          onTap: () => Get.snackbar('Mock Action', 'Opening mail client to ${lead.email}...', backgroundColor: AppColors.primaryColor, colorText: Colors.white),
        ),
        _buildActionItem(
          icon: Icons.message_outlined,
          label: 'WhatsApp',
          onTap: () => Get.snackbar('Mock Action', 'Opening WhatsApp thread with ${lead.name}...', backgroundColor: AppColors.primaryColor, colorText: Colors.white),
        ),
        _buildActionItem(
          icon: Icons.more_horiz_rounded,
          label: 'More',
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildActionItem({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 76,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.slate200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.01),
              blurRadius: 8,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.textColorSecondary, size: 22),
            const SizedBox(height: 6),
            AppText(
              label,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.textColorSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard(Lead lead) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailItem(label: 'Lead Source', value: lead.leadSource, isValueColored: true),
          _buildDetailItem(label: 'Lead Status', value: lead.leadStatus, isStatusBadge: true),
          _buildDetailItem(
            label: 'Assigned To',
            value: lead.assignedTo.name,
            avatarUrl: lead.assignedTo.avatarUrl,
            hasChevron: true,
            onTap: () => Get.to(() => AssignSalesTeamScreen(lead: lead)),
          ),
          _buildDetailItem(label: 'Mobile', value: lead.mobile, trailingIcon: Icons.phone_in_talk_outlined),
          _buildDetailItem(label: 'Email', value: lead.email, trailingIcon: Icons.mail_outline),
          _buildDetailItem(label: 'Company', value: lead.companyName),
          _buildDetailItem(label: 'Designation', value: lead.designation),
          _buildDetailItem(label: 'Location', value: lead.location),
          _buildDetailItem(label: 'Created On', value: _formatDateTime(lead.createdOn)),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required String label,
    required String value,
    bool isValueColored = false,
    bool isStatusBadge = false,
    String? avatarUrl,
    IconData? trailingIcon,
    bool hasChevron = false,
    VoidCallback? onTap,
  }) {
    Widget valueWidget = AppText(
      value,
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: isValueColored ? AppColors.primaryColor : AppColors.textColorPrimary,
    );

    if (isStatusBadge) {
      final color = _getStatusColor(value);
      valueWidget = Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: AppText(
          value,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      );
    }

    if (avatarUrl != null) {
      valueWidget = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 11,
            backgroundImage: NetworkImage(avatarUrl),
          ),
          const SizedBox(width: 6),
          AppText(
            value,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.textColorPrimary,
          ),
          if (hasChevron) ...[
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_right_rounded, color: AppColors.textColorHint, size: 16),
          ]
        ],
      );
    }

    final content = Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(
            label,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textColorSecondary,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              valueWidget,
              if (trailingIcon != null) ...[
                const SizedBox(width: 8),
                Icon(trailingIcon, color: AppColors.textColorSecondary, size: 16),
              ],
            ],
          ),
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: content,
      );
    }
    return content;
  }

  Widget _buildTabs(LeadsController controller) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.slate200, width: 1.5)),
      ),
      child: Obx(() {
        return Row(
          children: [
            _buildTabItem(
              title: 'Notes & Follow-ups',
              isActive: controller.selectedTabIdx.value == 0,
              onTap: () => controller.selectedTabIdx.value = 0,
            ),
            const SizedBox(width: 24),
            _buildTabItem(
              title: 'Activity Timeline',
              isActive: controller.selectedTabIdx.value == 1,
              onTap: () => controller.selectedTabIdx.value = 1,
            ),
          ],
        );
      }),
    );
  }

  Widget _buildTabItem({required String title, required bool isActive, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: AppText(
              title,
              fontSize: 14,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
              color: isActive ? AppColors.primaryColor : AppColors.textColorHint,
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 3,
            width: isActive ? 120 : 0,
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesAndFollowUpsTab(Lead lead) {
    if (lead.followUps.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 36),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(Iconsax.note_21, size: 48, color: AppColors.textColorHint.withValues(alpha: 0.3)),
            const SizedBox(height: 12),
            const AppText('No Notes or Follow-ups yet.', fontSize: 13, fontWeight: FontWeight.w600),
            const SizedBox(height: 2),
            const AppText('Click the button below to add activities.', fontSize: 11, color: AppColors.textColorHint),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: lead.followUps.length,
      itemBuilder: (context, index) {
        final followUp = lead.followUps[index];
        final statusColor = followUp.isCompleted ? AppColors.successColor : AppColors.warningColor;
        final statusText = followUp.isCompleted ? 'Completed' : 'Pending';

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.slate200),
          ),
          child: Column(
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
                          color: _getTimelineTypeColor(followUp.type).withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getTimelineTypeIcon(followUp.type),
                          color: _getTimelineTypeColor(followUp.type),
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 10),
                      AppText(
                        followUp.title,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColorPrimary,
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: AppText(
                      statusText,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              AppText(
                followUp.content,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textColorSecondary,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Icon(Iconsax.calendar, size: 14, color: AppColors.textColorHint),
                  const SizedBox(width: 4),
                  AppText(
                    _formatDateTime(followUp.dateTime),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColorSecondary,
                  ),
                  const Spacer(),
                  const Icon(Iconsax.user, size: 14, color: AppColors.textColorHint),
                  const SizedBox(width: 4),
                  AppText(
                    followUp.representative,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColorSecondary,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActivityTimelineTab(Lead lead) {
    // Elegant chronological list of events
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildActivityEvent(
            title: 'Lead Created',
            description: 'Lead was registered into the CRM system.',
            time: _formatDateTime(lead.createdOn),
            isLast: lead.followUps.isEmpty,
          ),
          ...List.generate(lead.followUps.length, (index) {
            final followUp = lead.followUps[lead.followUps.length - 1 - index];
            return _buildActivityEvent(
              title: followUp.title,
              description: followUp.content,
              time: _formatDateTime(followUp.dateTime),
              isLast: index == lead.followUps.length - 1,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildActivityEvent({
    required String title,
    required String description,
    required String time,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: AppColors.primaryColor,
                shape: BoxShape.circle,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 50,
                color: AppColors.slate200,
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText(
                    title,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColorPrimary,
                  ),
                  AppText(
                    time,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textColorHint,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              AppText(
                description,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textColorSecondary,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomFooter(BuildContext context, LeadsController controller, Lead lead) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.slate200)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton.icon(
            onPressed: () => _showAddNoteBottomSheet(context, controller),
            icon: const Icon(Icons.add, size: 18, color: Colors.white),
            label: const AppText(
              'Add Note / Follow-up',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
          ),
          const SizedBox(height: 10),
          if (lead.leadStatus != 'Converted')
            OutlinedButton(
              onPressed: () => Get.to(() => ConvertLeadScreen(lead: lead)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primaryColor, width: 1.5),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const AppText(
                'Convert to Customer',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
        ],
      ),
    );
  }

  void _showAddNoteBottomSheet(BuildContext context, LeadsController controller) {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    final typeObs = 'note'.obs;
    final statusObs = false.obs; // false = Pending, true = Completed

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.slate200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const AppText(
                'Add Note & Activity',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textColorPrimary,
              ),
              const SizedBox(height: 16),
              AppInputField(
                controller: titleCtrl,
                hint: 'e.g. Follow-up Call, Proposal Meeting',
                label: 'Title',
                validator: (val) => val == null || val.isEmpty ? 'Required field' : null,
              ),
              const SizedBox(height: 14),
              AppInputField(
                controller: contentCtrl,
                hint: 'Enter details of what was discussed...',
                label: 'Note / Discussion details',
                maxLines: 3,
                validator: (val) => val == null || val.isEmpty ? 'Required field' : null,
              ),
              const SizedBox(height: 14),
              const AppText('Activity Type', fontSize: 13, fontWeight: FontWeight.bold),
              const SizedBox(height: 8),
              Obx(() {
                return Row(
                  children: [
                    _buildTypeOption(typeObs, 'note', Iconsax.note_1, 'Note'),
                    const SizedBox(width: 8),
                    _buildTypeOption(typeObs, 'call', Iconsax.call, 'Call'),
                    const SizedBox(width: 8),
                    _buildTypeOption(typeObs, 'proposal', Iconsax.document_text, 'Proposal'),
                  ],
                );
              }),
              const SizedBox(height: 16),
              const AppText('Status', fontSize: 13, fontWeight: FontWeight.bold),
              const SizedBox(height: 8),
              Obx(() {
                return Row(
                  children: [
                    ChoiceChip(
                      label: const AppText('Pending', fontSize: 12),
                      selected: !statusObs.value,
                      onSelected: (val) => statusObs.value = false,
                      selectedColor: AppColors.warningColor.withValues(alpha: 0.15),
                      labelStyle: TextStyle(
                        color: !statusObs.value ? AppColors.warningColor : AppColors.textColorSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                      backgroundColor: AppColors.slate50,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    const SizedBox(width: 10),
                    ChoiceChip(
                      label: const AppText('Completed', fontSize: 12),
                      selected: statusObs.value,
                      onSelected: (val) => statusObs.value = true,
                      selectedColor: AppColors.successColor.withValues(alpha: 0.15),
                      labelStyle: TextStyle(
                        color: statusObs.value ? AppColors.successColor : AppColors.textColorSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                      backgroundColor: AppColors.slate50,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ],
                );
              }),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (titleCtrl.text.isNotEmpty && contentCtrl.text.isNotEmpty) {
                    controller.addFollowUpNote(
                      title: titleCtrl.text.trim(),
                      content: contentCtrl.text.trim(),
                      type: typeObs.value,
                      date: DateTime.now(),
                      isCompleted: statusObs.value,
                    );
                    Get.back(); // Pop sheet
                  } else {
                    Get.snackbar(
                      'Validation Error',
                      'Please complete all input fields',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: AppColors.errorColor,
                      colorText: Colors.white,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const AppText('Save Activity Note', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildTypeOption(RxString typeObs, String value, IconData icon, String label) {
    final isSelected = typeObs.value == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => typeObs.value = value,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryColor.withValues(alpha: 0.08) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primaryColor : AppColors.slate200,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? AppColors.primaryColor : AppColors.textColorSecondary, size: 18),
              const SizedBox(height: 4),
              AppText(
                label,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.primaryColor : AppColors.textColorSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, LeadsController controller, Lead lead) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const AppText('Confirm Delete', fontSize: 16, fontWeight: FontWeight.bold),
        content: AppText(
          'Are you sure you want to permanently delete lead "${lead.name}"? This action cannot be undone.',
          fontSize: 13,
          color: AppColors.textColorSecondary,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: AppText('Cancel', fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textColorHint),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back(); // Pop Dialog
              controller.deleteLead(lead.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const AppText('Delete', fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
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

  Color _getTimelineTypeColor(String type) {
    switch (type) {
      case 'call':
        return AppColors.warningColor;
      case 'proposal':
        return AppColors.primaryColor;
      case 'email':
        return AppColors.indigo500;
      default:
        return AppColors.textColorSecondary;
    }
  }

  IconData _getTimelineTypeIcon(String type) {
    switch (type) {
      case 'call':
        return Iconsax.call;
      case 'proposal':
        return Iconsax.document_text;
      case 'email':
        return Iconsax.direct;
      default:
        return Iconsax.note_1;
    }
  }

  String _formatDateTime(DateTime dt) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
  }
}
