import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_bottom_sheet_dropdown.dart';
import '../controllers/compliance_controller.dart';
import '../models/compliance_models.dart';

class ComplianceAuditLogsScreen extends StatelessWidget {
  const ComplianceAuditLogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ComplianceController>();

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
        title: const AppText(
          'Audit Logs',
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: Color(0xFF1E293B),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Iconsax.export, color: Color(0xFF1E293B)),
            onPressed: () => _showExportSheet(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // ── Filter Bar Chips ──
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Obx(() {
              final activeFilter = controller.selectedAuditFilter.value;
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildFilterChip(controller, 'All', activeFilter == 'All'),
                    const SizedBox(width: 8),
                    _buildFilterChip(controller, 'Policy Created', activeFilter == 'Policy Created'),
                    const SizedBox(width: 8),
                    _buildFilterChip(controller, 'Policy Published', activeFilter == 'Policy Published'),
                    const SizedBox(width: 8),
                    _buildFilterChip(controller, 'Acknowledgement', activeFilter == 'Acknowledgement'),
                    const SizedBox(width: 8),
                    _buildFilterChip(controller, 'Reminder Sent', activeFilter == 'Reminder Sent'),
                  ],
                ),
              );
            }),
          ),

          // ── Logs Data list/table sheet ──
          Expanded(
            child: Obx(() {
              final logs = controller.filteredAuditLogs;
              if (logs.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Iconsax.task, color: Color(0xFF94A3B8), size: 40),
                      SizedBox(height: 12),
                      AppText('No audit records found under this filter.', fontSize: 13, color: Color(0xFF64748B)),
                    ],
                  ),
                );
              }

              return ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                itemCount: logs.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final log = logs[index];
                  return _buildAuditLogCard(log);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(ComplianceController controller, String label, bool isSelected) {
    return GestureDetector(
      onTap: () => controller.selectedAuditFilter.value = label,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFE2E8F0),
          ),
        ),
        child: AppText(
          label,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: isSelected ? Colors.white : const Color(0xFF64748B),
        ),
      ),
    );
  }

  Widget _buildAuditLogCard(ComplianceAuditLog log) {
    Color actColor = const Color(0xFF3B82F6);
    IconData actIcon = Iconsax.document_text;
    
    if (log.activity == 'Policy Created') {
      actColor = const Color(0xFF8B5CF6);
      actIcon = Iconsax.document_code;
    } else if (log.activity == 'Policy Published') {
      actColor = const Color(0xFF10B981);
      actIcon = Iconsax.document_forward;
    } else if (log.activity == 'Acknowledgement') {
      actColor = const Color(0xFF06B6D4);
      actIcon = Iconsax.document;
    } else if (log.activity == 'Reminder Sent') {
      actColor = const Color(0xFFF97316);
      actIcon = Iconsax.notification;
    }

    final dateStr = DateFormat('dd MMM yyyy, hh:mm a').format(log.dateTime);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEEF2FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: actColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(actIcon, color: actColor, size: 12),
                    const SizedBox(width: 4),
                    AppText(log.activity, fontSize: 9, fontWeight: FontWeight.w800, color: actColor),
                  ],
                ),
              ),
              AppText(dateStr, fontSize: 9, fontWeight: FontWeight.w600, color: const Color(0xFF94A3B8)),
            ],
          ),
          const SizedBox(height: 10),
          AppText(
            log.policyTitle,
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1E293B),
          ),
          const SizedBox(height: 4),
          Text(
            log.details,
            style: const TextStyle(
              fontSize: 11.5,
              color: Color(0xFF64748B),
              height: 1.3,
              fontFamily: 'Outfit',
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const AppText('Performed By: ', fontSize: 9.5, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8)),
              AppText(log.performedBy, fontSize: 9.5, fontWeight: FontWeight.w800, color: const Color(0xFF475569)),
            ],
          ),
        ],
      ),
    );
  }

  void _showExportSheet(BuildContext context) {
    final activeFormat = 'PDF'.obs;
    final formats = ['PDF', 'Excel (XLSX)', 'CSV'];
    final fromDate = Rxn<DateTime>(DateTime.now().subtract(const Duration(days: 30)));
    final toDate = Rxn<DateTime>(DateTime.now());

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const AppText(
                'Export Audit Logs',
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E293B),
              ),
              const SizedBox(height: 4),
              const AppText(
                'Export audit logs for compliance, legal, and standard corporate purposes.',
                fontSize: 11,
                color: Color(0xFF64748B),
              ),
              const SizedBox(height: 20),

              // Format dropdown
              const AppText(
                'Select Format *',
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF475569),
              ),
              const SizedBox(height: 8),
              Obx(() => CustomBottomSheetDropdown(
                    label: 'Format',
                    selectedValue: activeFormat.value,
                    items: formats,
                    onChanged: (val) {
                      activeFormat.value = val;
                    },
                  )),
              const SizedBox(height: 16),

              // Date range selections
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AppText('From Date *', fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF475569)),
                        const SizedBox(height: 8),
                        Obx(() => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  AppText(
                                    fromDate.value == null 
                                        ? 'Select' 
                                        : DateFormat('dd MMM yy').format(fromDate.value!),
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF1E293B),
                                  ),
                                  const Icon(Iconsax.calendar, color: Color(0xFF64748B), size: 14),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AppText('To Date *', fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF475569)),
                        const SizedBox(height: 8),
                        Obx(() => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  AppText(
                                    toDate.value == null 
                                        ? 'Select' 
                                        : DateFormat('dd MMM yy').format(toDate.value!),
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF1E293B),
                                  ),
                                  const Icon(Iconsax.calendar, color: Color(0xFF64748B), size: 14),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Export Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    _simulateExportLoading(activeFormat.value);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const AppText('Export Report', fontSize: 13.5, fontWeight: FontWeight.w800, color: Colors.white),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _simulateExportLoading(String format) {
    Get.showOverlay(
      opacity: 0.25,
      loadingWidget: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Color(0xFF4F46E5)),
              const SizedBox(height: 16),
              AppText(
                'Compiling & Formatting $format...',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E293B),
              ),
            ],
          ),
        ),
      ),
      asyncFunction: () async {
        await Future.delayed(const Duration(seconds: 2));
        Get.snackbar(
          'Export Successful! 📈',
          'Audit log report in $format has been generated and saved.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          borderRadius: 16,
        );
      },
    );
  }
}
