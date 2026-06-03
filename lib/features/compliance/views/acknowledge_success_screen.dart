import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/app_text.dart';

class AcknowledgeSuccessScreen extends StatelessWidget {
  final String policyName;
  final String version;
  final DateTime acknowledgedDate;

  const AcknowledgeSuccessScreen({
    super.key,
    required this.policyName,
    required this.version,
    required this.acknowledgedDate,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd MMMM yyyy, hh:mm a').format(acknowledgedDate);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              const Spacer(),

              // Glowing Success Checkmark Ring & Confetti Simulator
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer glowing soft pulse circle
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF10B981).withValues(alpha: 0.05),
                      ),
                    ),
                    // Middle pulse circle
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF10B981).withValues(alpha: 0.1),
                      ),
                    ),
                    // Inner solid green circle with check icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF10B981),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF10B981),
                            blurRadius: 16,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 42,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // Title Headers
              const AppText(
                'Policy Acknowledged!',
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1E293B),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 260,
                child: Text(
                  'You have successfully acknowledged the terms for $policyName.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 36),

              // Detailed metadata receipt panel
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFEEF2FF)),
                ),
                child: Column(
                  children: [
                    _buildReceiptRow('Policy Name', policyName),
                    const Divider(color: Color(0xFFE2E8F0), height: 24),
                    _buildReceiptRow('Version', 'v$version'),
                    const Divider(color: Color(0xFFE2E8F0), height: 24),
                    _buildReceiptRow('Acknowledged On', dateStr),
                    const Divider(color: Color(0xFFE2E8F0), height: 24),
                    _buildReceiptRow('Status', 'Legally Verified', valueColor: const Color(0xFF10B981)),
                  ],
                ),
              ),

              const Spacer(),

              // Primary "Back to My Policies" Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                    shadowColor: const Color(0xFF10B981).withValues(alpha: 0.2),
                  ),
                  child: const AppText(
                    'Back to My Policies',
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText(
          label,
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF64748B),
        ),
        Expanded(
          child: AppText(
            value,
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
            color: valueColor ?? const Color(0xFF1E293B),
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
