import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/admin_lead_sources_controller.dart';
import '../models/lead_source_model.dart';
import '../controllers/admin_leads_hub_controller.dart';
import '../models/sales_employee_model.dart';

class LeadSourceDetailScreen extends StatefulWidget {
  final dynamic sourceId;
  final LeadSourceModel? initialSource;

  const LeadSourceDetailScreen({
    super.key,
    required this.sourceId,
    this.initialSource,
  });

  @override
  State<LeadSourceDetailScreen> createState() => _LeadSourceDetailScreenState();
}

class _LeadSourceDetailScreenState extends State<LeadSourceDetailScreen> {
  late final AdminLeadSourcesController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AdminLeadSourcesController.to;
    if (widget.initialSource != null) {
      _controller.sourceDetail.value = widget.initialSource;
    }
    _controller.fetchLeadSourceDetail(widget.sourceId);
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
          final source = _controller.sourceDetail.value ?? widget.initialSource;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                source?.name ?? 'Lead Source Details',
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
              AppText(
                source != null ? 'Channel Key: ${source.sourceKey}' : 'Lead Allocation Rule',
                fontSize: 11,
                color: const Color(0xFF94A3B8),
              ),
            ],
          );
        }),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.edit_2, size: 18, color: Color(0xFF475569)),
            tooltip: 'Edit Rule',
            onPressed: () {
              final source = _controller.sourceDetail.value ?? widget.initialSource;
              if (source != null) {
                _showEditModal(context, source);
              }
            },
          ),
          IconButton(
            icon: const Icon(Iconsax.refresh, size: 18, color: Color(0xFF475569)),
            tooltip: 'Refresh',
            onPressed: () => _controller.fetchLeadSourceDetail(widget.sourceId),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Obx(() {
        final source = _controller.sourceDetail.value ?? widget.initialSource;
        final isLoading = _controller.isDetailLoading.value;
        final error = _controller.detailErrorMessage.value;

        if (isLoading && source == null) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.primaryColor),
                SizedBox(height: 14),
                AppText('Loading lead source details...', fontSize: 13, color: Color(0xFF64748B)),
              ],
            ),
          );
        }

        if (error.isNotEmpty && source == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Iconsax.warning_2, size: 48, color: Color(0xFFEF4444)),
                  const SizedBox(height: 12),
                  const AppText(
                    'Failed to load source details',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                  const SizedBox(height: 6),
                  AppText(error, fontSize: 12, color: const Color(0xFF64748B), textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _controller.fetchLeadSourceDetail(widget.sourceId),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor),
                    icon: const Icon(Iconsax.refresh, size: 14, color: Colors.white),
                    label: const AppText('Retry', color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        }

        if (source == null) {
          return const Center(
            child: AppText('Lead source not found', fontSize: 13, color: Color(0xFF64748B)),
          );
        }

        final colorVal = source.colorValue;
        final assignedLeads = (source.leadsCount - source.unassignedLeadsCount).clamp(0, 9999999);

        return RefreshIndicator(
          onRefresh: () => _controller.fetchLeadSourceDetail(widget.sourceId),
          color: colorVal,
          child: ListView(
            padding: const EdgeInsets.all(16),
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            children: [
              // Hero Banner Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorVal,
                      colorVal.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: colorVal.withValues(alpha: 0.3),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                                    ),
                                    child: AppText(
                                      'ID: #${source.id}',
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: source.isActive
                                          ? const Color(0xFF10B981).withValues(alpha: 0.9)
                                          : Colors.black.withValues(alpha: 0.4),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: BoxDecoration(
                                            color: source.isActive ? Colors.white : const Color(0xFF94A3B8),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        AppText(
                                          source.isActive ? 'Active Channel' : 'Inactive',
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              AppText(
                                source.name,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 4),
                              AppText(
                                'Strategy: ${source.strategyDisplayName}',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ],
                          ),
                        ),
                        Transform.scale(
                          scale: 0.85,
                          child: Switch.adaptive(
                            value: source.isActive,
                            activeThumbColor: Colors.white,
                            activeTrackColor: Colors.white.withValues(alpha: 0.4),
                            onChanged: (val) {
                              _controller.toggleSourceStatus(source.id, val);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            source.isConfigured ? Iconsax.tick_circle : Iconsax.info_circle,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: AppText(
                              source.isConfigured
                                  ? 'Fully configured & automated webhook active'
                                  : 'Setup pending - Assign employees to start auto-routing leads',
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 4 Stat Cards
              Row(
                children: [
                  Expanded(
                    child: _buildMetricTile(
                      label: 'Total Leads',
                      value: '${source.leadsCount}',
                      icon: Iconsax.task_square,
                      color: const Color(0xFF2563EB),
                      bgColor: const Color(0xFFEFF6FF),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMetricTile(
                      label: 'Unassigned',
                      value: '${source.unassignedLeadsCount}',
                      icon: Iconsax.warning_2,
                      color: source.unassignedLeadsCount > 0 ? const Color(0xFFEA580C) : const Color(0xFF10B981),
                      bgColor: source.unassignedLeadsCount > 0 ? const Color(0xFFFFF7ED) : const Color(0xFFECFDF5),
                      hasAlert: source.unassignedLeadsCount > 0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricTile(
                      label: 'Assigned Leads',
                      value: '$assignedLeads',
                      icon: Iconsax.user_tick,
                      color: const Color(0xFF059669),
                      bgColor: const Color(0xFFECFDF5),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMetricTile(
                      label: 'Allocated Team',
                      value: '${source.employees.length}',
                      icon: Iconsax.people,
                      color: const Color(0xFF7C3AED),
                      bgColor: const Color(0xFFF5F3FF),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Configuration Details Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Iconsax.setting_2, size: 16, color: Color(0xFF475569)),
                        SizedBox(width: 8),
                        AppText(
                          'Source Configuration Details',
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    const SizedBox(height: 12),
                    _buildConfigRow('Source Key', source.sourceKey, isMono: true),
                    _buildConfigRow('Allocation Strategy', source.strategyDisplayName),
                    _buildConfigRow('Hex Color', source.color, colorIndicator: colorVal),
                    _buildConfigRow('Configuration Status', source.isConfigured ? 'Configured' : 'Unconfigured'),
                    if (source.createdAt != null)
                      _buildConfigRow('Created At', _formatDateTime(source.createdAt!)),
                    if (source.updatedAt != null)
                      _buildConfigRow('Last Updated', _formatDateTime(source.updatedAt!)),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Assigned Employees Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText(
                    'Assigned Team Members (${source.employees.length}):',
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E293B),
                  ),
                  if (source.employees.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: colorVal.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: AppText(
                        '${source.strategyDisplayName} Mode',
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: colorVal,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),

              if (source.employees.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFECACA)),
                  ),
                  child: Column(
                    children: [
                      const Icon(Iconsax.info_circle, size: 32, color: Color(0xFFDC2626)),
                      const SizedBox(height: 8),
                      const AppText(
                        'No Employees Assigned',
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF991B1B),
                      ),
                      const SizedBox(height: 4),
                      const AppText(
                        'Inbound leads from this channel will remain in the unassigned pool until team members are allocated.',
                        fontSize: 11.5,
                        color: Color(0xFFB91C1C),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
                ...source.employees.asMap().entries.map((entry) {
                  final index = entry.key;
                  final emp = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.primaryLight,
                          backgroundImage: (emp.avatar != null && emp.avatar!.isNotEmpty)
                              ? NetworkImage(emp.avatar!)
                              : null,
                          child: (emp.avatar == null || emp.avatar!.isEmpty)
                              ? const Icon(Iconsax.user, size: 20, color: AppColors.primaryColor)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  AppText(
                                    emp.name,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF0F172A),
                                  ),
                                  const SizedBox(width: 6),
                                  if (emp.status != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFECFDF5),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: AppText(
                                        emp.status!,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF059669),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              if (emp.designation != null && emp.designation!.isNotEmpty)
                                AppText(
                                  emp.designation!,
                                  fontSize: 11,
                                  color: const Color(0xFF64748B),
                                ),
                              if (emp.email != null && emp.email!.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                AppText(
                                  emp.email!,
                                  fontSize: 10.5,
                                  color: const Color(0xFF94A3B8),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              const AppText(
                                'Sequence',
                                fontSize: 9,
                                color: Color(0xFF94A3B8),
                              ),
                              AppText(
                                '#${(emp.pivot?.position ?? index) + 1}',
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF334155),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              const SizedBox(height: 24),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
    bool hasAlert = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: hasAlert ? color.withValues(alpha: 0.4) : const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  value,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF0F172A),
                ),
                const SizedBox(height: 2),
                AppText(
                  label,
                  fontSize: 10.5,
                  color: const Color(0xFF64748B),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigRow(String label, String value, {bool isMono = false, Color? colorIndicator}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(label, fontSize: 11.5, color: const Color(0xFF64748B)),
          Row(
            children: [
              if (colorIndicator != null) ...[
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(color: colorIndicator, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
              ],
              AppText(
                value,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isMono ? const Color(0xFF2563EB) : const Color(0xFF1E293B),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDateTime(String raw) {
    try {
      final dt = DateTime.parse(raw).toLocal();
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return raw;
    }
  }

  void _showEditModal(BuildContext context, LeadSourceModel source) {
    final nameController = TextEditingController(text: source.name);
    String selectedStrategy = source.allocationStrategy.contains('round') ? 'round_robin' : 'primary';
    final List<int> selectedEmployeeIds = source.employees.map((e) => e.id).toList();

    List<SalesEmployeeModel> availableEmployees = [];
    if (Get.isRegistered<AdminLeadsHubController>()) {
      availableEmployees = Get.find<AdminLeadsHubController>().salesEmployees;
    }

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
                    AppText(
                      'Edit Lead Source (${source.name})',
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                    const SizedBox(height: 4),
                    const AppText(
                      'Update channel allocation rules and assigned sales executives',
                      fontSize: 11,
                      color: AppColors.textColorSecondary,
                    ),
                    const SizedBox(height: 16),

                    // Source Name
                    const AppText('Channel Name:', fontSize: 12, fontWeight: FontWeight.bold),
                    const SizedBox(height: 6),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: 'e.g. Facebook Ads, Google Ads',
                        fillColor: const Color(0xFFF8FAFC),
                        filled: true,
                        isDense: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Strategy
                    const AppText('Allocation Strategy:', fontSize: 12, fontWeight: FontWeight.bold),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: selectedStrategy,
                      decoration: InputDecoration(
                        fillColor: const Color(0xFFF8FAFC),
                        filled: true,
                        isDense: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'round_robin', child: Text('Round-Robin (Rotate sequentially among employees)')),
                        DropdownMenuItem(value: 'primary', child: Text('Primary Dedicated Executive')),
                      ],
                      onChanged: (val) {
                        if (val != null) setModalState(() => selectedStrategy = val);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Employees Checkboxes
                    const AppText('Assigned Team Member(s):', fontSize: 12, fontWeight: FontWeight.bold),
                    const SizedBox(height: 8),

                    if (availableEmployees.isEmpty) ...[
                      // If hub list empty, show existing employees from source
                      ...source.employees.map((emp) {
                        final isSelected = selectedEmployeeIds.contains(emp.id);
                        return CheckboxListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: AppText(emp.name, fontSize: 13, fontWeight: FontWeight.bold),
                          subtitle: emp.designation != null ? AppText(emp.designation!, fontSize: 11, color: AppColors.textColorSecondary) : null,
                          value: isSelected,
                          activeColor: AppColors.primaryColor,
                          onChanged: (val) {
                            setModalState(() {
                              if (val == true) {
                                if (!selectedEmployeeIds.contains(emp.id)) selectedEmployeeIds.add(emp.id);
                              } else {
                                selectedEmployeeIds.remove(emp.id);
                              }
                            });
                          },
                        );
                      }),
                    ] else ...[
                      ...availableEmployees.map((emp) {
                        final isSelected = selectedEmployeeIds.contains(emp.id);
                        return CheckboxListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: Row(
                            children: [
                              CircleAvatar(
                                radius: 12,
                                backgroundColor: AppColors.primaryLight,
                                backgroundImage: (emp.avatar != null && emp.avatar!.isNotEmpty) ? NetworkImage(emp.avatar!) : null,
                                child: (emp.avatar == null || emp.avatar!.isEmpty)
                                    ? const Icon(Iconsax.user, size: 12, color: AppColors.primaryColor)
                                    : null,
                              ),
                              const SizedBox(width: 8),
                              AppText(emp.displayName, fontSize: 13, fontWeight: FontWeight.bold),
                              const SizedBox(width: 6),
                              AppText('(${emp.displayDesignation})', fontSize: 11, color: AppColors.textColorSecondary),
                            ],
                          ),
                          value: isSelected,
                          activeColor: AppColors.primaryColor,
                          onChanged: (val) {
                            setModalState(() {
                              if (val == true) {
                                if (!selectedEmployeeIds.contains(emp.id)) selectedEmployeeIds.add(emp.id);
                              } else {
                                selectedEmployeeIds.remove(emp.id);
                              }
                            });
                          },
                        );
                      }),
                    ],
                    const SizedBox(height: 20),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: Obx(() {
                        final isUpdating = _controller.isUpdating.value;
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: isUpdating
                              ? null
                              : () async {
                                  final name = nameController.text.trim();
                                  if (name.isEmpty) {
                                    Get.snackbar('Required', 'Please enter source name.', backgroundColor: const Color(0xFFEF4444), colorText: Colors.white);
                                    return;
                                  }

                                  final request = UpdateLeadSourceRequestModel(
                                    name: name,
                                    sourceKey: source.sourceKey,
                                    allocationStrategy: selectedStrategy,
                                    employeeIds: selectedEmployeeIds,
                                    isActive: source.isActive,
                                    color: source.color,
                                  );

                                  final success = await _controller.updateLeadSource(
                                    source.id,
                                    request,
                                    showSnackbar: false,
                                  );
                                  if (ctx.mounted) {
                                    Navigator.of(ctx).pop();
                                  }
                                  if (success) {
                                    Get.snackbar(
                                      'Lead Source Updated 🎯',
                                      'Lead source updated successfully.',
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: const Color(0xFF10B981),
                                      colorText: Colors.white,
                                    );
                                  }
                                },
                          child: isUpdating
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const AppText('Update Lead Source', color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
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
}
