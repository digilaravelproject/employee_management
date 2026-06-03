import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/compliance_controller.dart';
import '../models/compliance_models.dart';
import 'acknowledge_success_screen.dart';

class EmployeePolicyReaderScreen extends StatefulWidget {
  final PolicyItem policy;

  const EmployeePolicyReaderScreen({super.key, required this.policy});

  @override
  State<EmployeePolicyReaderScreen> createState() => _EmployeePolicyReaderScreenState();
}

class _EmployeePolicyReaderScreenState extends State<EmployeePolicyReaderScreen> {
  final _isSummaryView = false.obs;
  final _hasAcceptedCheckbox = false.obs;

  Future<void> _submitAcknowledgement(ComplianceController controller) async {
    if (!_hasAcceptedCheckbox.value) {
      Get.snackbar(
        'Action Required ⚠️',
        'You must read, understand and check the agreement checkbox before acknowledging.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        borderRadius: 16,
      );
      return;
    }

    controller.acknowledgePolicy(widget.policy.id).then((success) {
      if (success) {
        // Clear back screens and push success page
        Get.off(() => AcknowledgeSuccessScreen(
              policyName: widget.policy.title,
              version: widget.policy.version,
              acknowledgedDate: DateTime.now(),
            ));
      }
    });
  }

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
          'Policy Details',
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: Color(0xFF1E293B),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Iconsax.share, color: Color(0xFF1E293B), size: 18),
            onPressed: () {},
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isAcknowledging.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Color(0xFF10B981)),
                SizedBox(height: 16),
                AppText(
                  'Securing digital signature & registering audit log...',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF475569),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // ── Document Header Detail ──
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Iconsax.document_text5,
                      color: Color(0xFF10B981),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          widget.policy.title,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF1E293B),
                        ),
                        const SizedBox(height: 4),
                        AppText(
                          'Version ${widget.policy.version} • Published ${DateFormat('dd MMM yyyy').format(widget.policy.updatedDate)}',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF64748B),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const AppText(
                            'Pending Acknowledgement',
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFD97706),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Navigation tabs inside reader ──
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildSubTab('Policy Document', !_isSummaryView.value, () => _isSummaryView.value = false),
                  const SizedBox(width: 16),
                  _buildSubTab('Policy Summary', _isSummaryView.value, () => _isSummaryView.value = true),
                ],
              ),
            ),

            // ── Interactive Document reader viewport ──
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Obx(() {
                  if (_isSummaryView.value) {
                    return _buildSummarySheet();
                  } else {
                    return _buildPDFReaderSheet();
                  }
                }),
              ),
            ),

            // ── Checklist & Footer buttons ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFEEF2FF),
                    blurRadius: 12,
                    offset: Offset(0, -6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Checkbox row
                  GestureDetector(
                    onTap: () => _hasAcceptedCheckbox.toggle(),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(() => Container(
                              margin: const EdgeInsets.only(top: 2),
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: _hasAcceptedCheckbox.value ? const Color(0xFF10B981) : Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: _hasAcceptedCheckbox.value ? const Color(0xFF10B981) : const Color(0xFFCBD5E1),
                                  width: 1.5,
                                ),
                              ),
                              child: _hasAcceptedCheckbox.value
                                  ? const Icon(Icons.check, color: Colors.white, size: 12)
                                  : null,
                            )),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'I have read and understood this policy, and I agree to abide by all its terms and guidelines.',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF475569),
                              height: 1.3,
                              fontFamily: 'Outfit',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Acknowledge and Reject buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Get.back(),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
                            minimumSize: const Size(0, 50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const AppText(
                            'Reject',
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFEF4444),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Obx(() {
                          final accepted = _hasAcceptedCheckbox.value;
                          return ElevatedButton(
                            onPressed: () => _submitAcknowledgement(controller),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accepted ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
                              minimumSize: const Size(0, 50),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 0,
                            ),
                            child: const AppText(
                              'Acknowledge Policy',
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSubTab(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? const Color(0xFF10B981) : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: AppText(
          label,
          fontSize: 11.5,
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          color: isSelected ? const Color(0xFF1E293B) : const Color(0xFF64748B),
        ),
      ),
    );
  }

  Widget _buildSummarySheet() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFEEF2FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText(
            'Policy Summary',
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1E293B),
          ),
          const SizedBox(height: 12),
          Text(
            widget.policy.summary,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF475569),
              height: 1.4,
              fontFamily: 'Outfit',
            ),
          ),
          const SizedBox(height: 20),
          _buildSummaryBullet('Official Category:', widget.policy.category),
          _buildSummaryBullet('Review Cycle:', 'Annual standard review scheduled.'),
          _buildSummaryBullet('Binding Impact:', 'Applies to full performance metrics assessments.'),
        ],
      ),
    );
  }

  Widget _buildSummaryBullet(String boldText, String normalText) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 12, height: 1.3, fontFamily: 'Outfit'),
                children: [
                  TextSpan(
                    text: '$boldText ',
                    style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
                  ),
                  TextSpan(
                    text: normalText,
                    style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPDFReaderSheet() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFEEF2FF)),
      ),
      child: Column(
        children: [
          // PDF Page layout tools header (1 / 8, - 100% +)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(bottom: BorderSide(color: Color(0xFFEEF2FF))),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.chevron_left_rounded, color: Color(0xFF64748B), size: 16),
                    SizedBox(width: 6),
                    AppText('1 / 8', fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF475569)),
                    SizedBox(width: 6),
                    Icon(Icons.chevron_right_rounded, color: Color(0xFF64748B), size: 16),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.remove_circle_outline, color: Color(0xFF64748B), size: 14),
                    SizedBox(width: 6),
                    AppText('100%', fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF475569)),
                    SizedBox(width: 6),
                    Icon(Icons.add_circle_outline, color: Color(0xFF64748B), size: 14),
                  ],
                ),
                Icon(Icons.fullscreen_rounded, color: Color(0xFF64748B), size: 16),
              ],
            ),
          ),

          // Scrollable Document PDF reader simulator text
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: AppText(
                    widget.policy.title.toUpperCase(),
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  widget.policy.description,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF334155),
                    height: 1.5,
                    fontFamily: 'Outfit',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
