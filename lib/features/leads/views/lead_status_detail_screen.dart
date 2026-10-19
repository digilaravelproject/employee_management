import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/admin_lead_statuses_controller.dart';
import '../models/lead_status_model.dart';

class LeadStatusDetailScreen extends StatefulWidget {
  final dynamic statusId;
  final LeadStatusModel? initialStatus;

  const LeadStatusDetailScreen({
    super.key,
    required this.statusId,
    this.initialStatus,
  });

  @override
  State<LeadStatusDetailScreen> createState() => _LeadStatusDetailScreenState();
}

class _LeadStatusDetailScreenState extends State<LeadStatusDetailScreen> {
  late final AdminLeadStatusesController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AdminLeadStatusesController.to;
    if (widget.initialStatus != null) {
      _controller.statusDetail.value = widget.initialStatus;
    }
    _controller.fetchLeadStatusDetail(widget.statusId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left, color: Color(0xFF0F172A), size: 20),
          onPressed: () => Get.back(),
        ),
        title: Obx(() {
          final status = _controller.statusDetail.value ?? widget.initialStatus;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                status?.name ?? 'Status Details',
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
              const AppText(
                'CRM Pipeline Stage Tag',
                fontSize: 11,
                color: Color(0xFF94A3B8),
              ),
            ],
          );
        }),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.refresh, size: 18, color: Color(0xFF475569)),
            tooltip: 'Refresh',
            onPressed: () => _controller.fetchLeadStatusDetail(widget.statusId),
          ),
          Obx(() {
            final status = _controller.statusDetail.value ?? widget.initialStatus;
            if (status == null) return const SizedBox.shrink();
            return PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF475569)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onSelected: (val) {
                if (val == 'edit') {
                  _showEditModal(status);
                } else if (val == 'delete') {
                  _showDeleteConfirmDialog(status);
                }
              },
              itemBuilder: (ctx) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Iconsax.edit_2, size: 16, color: Color(0xFF475569)),
                      SizedBox(width: 10),
                      AppText('Edit Status', fontSize: 13, fontWeight: FontWeight.w600),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Iconsax.trash, size: 16, color: Color(0xFFEF4444)),
                      SizedBox(width: 10),
                      AppText('Delete Status', fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFFEF4444)),
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
      ),
      body: Obx(() {
        final isLoading = _controller.isLoadingDetail.value;
        final status = _controller.statusDetail.value ?? widget.initialStatus;

        if (isLoading && status == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (status == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Iconsax.info_circle, size: 48, color: Color(0xFF94A3B8)),
                const SizedBox(height: 12),
                const AppText(
                  'Lead Status Not Found',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const AppText('Go Back', color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        }

        final colorVal = status.color;

        return RefreshIndicator(
          onRefresh: () => _controller.fetchLeadStatusDetail(widget.statusId),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Hero Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Color swatch badge & category
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: colorVal.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: colorVal.withValues(alpha: 0.4)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: colorVal,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(color: colorVal, blurRadius: 4),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),
                                AppText(
                                  status.displayCategory,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),

                          // Stage Order Position
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: AppText(
                              'Stage #${status.orderPosition ?? "-"}',
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Status Name
                      AppText(
                        status.name,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 6),

                      // Slug and System tag
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'slug: ${status.slug ?? status.name.toLowerCase().replaceAll(' ', '_')}',
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 11,
                                color: Color(0xFFCBD5E1),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (status.isSystem)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFF3B82F6).withValues(alpha: 0.4)),
                              ),
                              child: const AppText(
                                'System Reserved',
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF93C5FD),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 2. Metrics 3-Card Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Active Leads',
                        value: '${status.leadsCount}',
                        icon: Iconsax.profile_2user,
                        color: const Color(0xFF2563EB),
                        bgColor: const Color(0xFFEFF6FF),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Pipeline Order',
                        value: '#${status.orderPosition ?? 1}',
                        icon: Iconsax.sort,
                        color: const Color(0xFF059669),
                        bgColor: const Color(0xFFECFDF5),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Badge Color',
                        value: status.badgeColor,
                        icon: Iconsax.colorfilter,
                        color: colorVal,
                        bgColor: colorVal.withValues(alpha: 0.1),
                        isColorSwatch: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 3. Guidance / Description Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Iconsax.note_text, size: 18, color: Color(0xFF475569)),
                          SizedBox(width: 8),
                          AppText(
                            'Sales Guidance / Description',
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      AppText(
                        status.description.isNotEmpty
                            ? status.description
                            : 'No specific guidance or description set for this pipeline status tag.',
                        fontSize: 13,
                        color: status.description.isNotEmpty
                            ? const Color(0xFF334155)
                            : const Color(0xFF94A3B8),
                        height: 1.5,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 4. Configuration Details Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Iconsax.setting_2, size: 18, color: Color(0xFF475569)),
                          SizedBox(width: 8),
                          AppText(
                            'Configuration & Metadata',
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _buildInfoRow('Database ID', '${status.id}'),
                      _buildInfoRow('Category Key', status.category),
                      _buildInfoRow('Category Stage', status.displayCategory),
                      _buildInfoRow('Hex Color Code', status.badgeColor),
                      _buildInfoRow('Order Position', '${status.orderPosition ?? "Default"}'),
                      _buildInfoRow('System Status', status.isSystem ? 'Yes (Reserved)' : 'No (Custom)'),
                      if (status.createdAt != null && status.createdAt!.isNotEmpty)
                        _buildInfoRow('Created At', _formatTimestamp(status.createdAt!)),
                      if (status.updatedAt != null && status.updatedAt!.isNotEmpty)
                        _buildInfoRow('Updated At', _formatTimestamp(status.updatedAt!)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 5. Action Buttons (Edit & Delete)
                Row(
                  children: [
                    // Edit Button
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: () => _showEditModal(status),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        icon: const Icon(Iconsax.edit_2, size: 18),
                        label: const AppText(
                          'Edit Status',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Delete Button
                    Expanded(
                      flex: 1,
                      child: OutlinedButton.icon(
                        onPressed: () => _showDeleteConfirmDialog(status),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFEF4444),
                          side: const BorderSide(color: Color(0xFFEF4444)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        icon: const Icon(Iconsax.trash, size: 18, color: Color(0xFFEF4444)),
                        label: const AppText(
                          'Delete',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFEF4444),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
    bool isColorSwatch = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 14, color: color),
              ),
              if (isColorSwatch)
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          AppText(
            value,
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
          ),
          const SizedBox(height: 2),
          AppText(
            title,
            fontSize: 10.5,
            color: const Color(0xFF64748B),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(
            label,
            fontSize: 12,
            color: const Color(0xFF64748B),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: AppText(
              value,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(String isoString) {
    try {
      final dt = DateTime.parse(isoString);
      return '${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return isoString;
    }
  }

  // ── Edit Modal ─────────────────────────────────────────────────────────────
  void _showEditModal(LeadStatusModel status) {
    final nameController = TextEditingController(text: status.name);
    final descController = TextEditingController(text: status.description);
    String selectedCategory = status.category;
    String selectedHex = status.badgeColor;

    if (!['active_lead', 'prospecting', 'won', 'disqualified'].contains(selectedCategory.toLowerCase())) {
      selectedCategory = 'active_lead';
    } else {
      selectedCategory = selectedCategory.toLowerCase();
    }

    final presetColors = [
      '#3B82F6',
      '#10B981',
      '#F59E0B',
      '#6366F1',
      '#8B5CF6',
      '#059669',
      '#EF4444',
      '#64748B',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
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
                        decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const AppText(
                      'Edit Lead Status',
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                    const SizedBox(height: 4),
                    const AppText(
                      'Update name, category stage, and color for this status tag',
                      fontSize: 11,
                      color: AppColors.textColorSecondary,
                    ),
                    const SizedBox(height: 16),

                    // Status Name
                    const AppText('Status Name:', fontSize: 12, fontWeight: FontWeight.bold),
                    const SizedBox(height: 6),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: 'e.g. Interested, Follow-up, Converted',
                        fillColor: const Color(0xFFF8FAFC),
                        filled: true,
                        isDense: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Category
                    const AppText('Category:', fontSize: 12, fontWeight: FontWeight.bold),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: selectedCategory,
                      decoration: InputDecoration(
                        fillColor: const Color(0xFFF8FAFC),
                        filled: true,
                        isDense: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'active_lead', child: Text('Active Lead (In negotiation)')),
                        DropdownMenuItem(value: 'prospecting', child: Text('Prospecting (Initial stage)')),
                        DropdownMenuItem(value: 'won', child: Text('Won / Closed Deal')),
                        DropdownMenuItem(value: 'disqualified', child: Text('Disqualified / Invalid')),
                      ],
                      onChanged: (val) {
                        if (val != null) setModalState(() => selectedCategory = val);
                      },
                    ),
                    const SizedBox(height: 14),

                    // Description
                    const AppText('Description / Guideline:', fontSize: 12, fontWeight: FontWeight.bold),
                    const SizedBox(height: 6),
                    TextField(
                      controller: descController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'Short description for sales team',
                        fillColor: const Color(0xFFF8FAFC),
                        filled: true,
                        isDense: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Badge Color
                    const AppText('Badge Tag Color:', fontSize: 12, fontWeight: FontWeight.bold),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: presetColors.map((hex) {
                        final colorVal = LeadStatusModel.parseHexColor(hex);
                        final isSelected = selectedHex.toUpperCase() == hex.toUpperCase();
                        return GestureDetector(
                          onTap: () => setModalState(() => selectedHex = hex),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: colorVal,
                              shape: BoxShape.circle,
                              border: Border.all(color: isSelected ? Colors.black : Colors.transparent, width: 2.5),
                            ),
                            child: isSelected ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: Obx(() {
                        final isSubmitting = _controller.isSubmitting.value;
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  final name = nameController.text.trim();
                                  if (name.isEmpty) {
                                    Get.snackbar('Required', 'Please enter status name.', backgroundColor: const Color(0xFFEF4444), colorText: Colors.white);
                                    return;
                                  }

                                  final success = await _controller.updateLeadStatus(
                                    id: status.id,
                                    name: name,
                                    category: selectedCategory,
                                    description: descController.text.trim(),
                                    badgeColor: selectedHex,
                                    orderPosition: status.orderPosition,
                                  );

                                  if (success && ctx.mounted) {
                                    Navigator.pop(ctx);
                                  }
                                },
                          child: isSubmitting
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const AppText('Save Changes', color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ── Delete Confirmation Dialog ─────────────────────────────────────────────
  void _showDeleteConfirmDialog(LeadStatusModel status) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: AppText('Delete Status: ${status.name}', fontSize: 16, fontWeight: FontWeight.bold),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                'Are you sure you want to delete status "${status.name}"? This action cannot be undone.',
                fontSize: 13,
                color: const Color(0xFF64748B),
              ),
              if (status.leadsCount > 0) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFECACA)),
                  ),
                  child: AppText(
                    '⚠️ ${status.leadsCount} lead(s) are currently categorized with this status.',
                    fontSize: 11,
                    color: const Color(0xFFDC2626),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const AppText('Cancel', color: Color(0xFF64748B)),
            ),
            Obx(() {
              final isSubmitting = _controller.isSubmitting.value;
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: isSubmitting
                    ? null
                    : () async {
                        final success = await _controller.deleteLeadStatus(status.id, statusName: status.name);
                        if (success && ctx.mounted) {
                          Navigator.pop(ctx);
                          Get.back(); // Pop detail screen back to list
                        }
                      },
                child: isSubmitting
                    ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const AppText('Delete', color: Colors.white, fontWeight: FontWeight.bold),
              );
            }),
          ],
        );
      },
    );
  }
}
