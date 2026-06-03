import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/compliance_controller.dart';
import '../models/compliance_models.dart';
import 'upload_policy_screen.dart';
import 'admin_policy_details_screen.dart';
import 'compliance_tracking_screen.dart';
import 'compliance_audit_logs_screen.dart';
import 'employee_policy_reader_screen.dart';
import 'acknowledge_success_screen.dart';

class ComplianceDashboardScreen extends StatelessWidget {
  const ComplianceDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject the controller
    final controller = Get.put(ComplianceController());

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
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.textColorPrimary,
                size: 18,
              ),
              onPressed: () => Get.back(),
            ),
          ),
        ),
        title: const AppText(
          'Compliance & Policies',
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: Color(0xFF1E293B),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.notification, color: Color(0xFF1E293B)),
            onPressed: () {},
          ),
        ],
        centerTitle: false,
      ),
      body: Column(
        children: [
          // --- Perspective Toggler (Admin Side / Employee Side) ---
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Obx(() => Row(
                children: [
                  Expanded(
                    child: _buildPerspectiveTab(
                      label: 'Admin Side',
                      subLabel: 'Full Control',
                      isSelected: controller.isAdminMode.value,
                      icon: Iconsax.security_user,
                      onTap: () => controller.isAdminMode.value = true,
                    ),
                  ),
                  Expanded(
                    child: _buildPerspectiveTab(
                      label: 'Employee Side',
                      subLabel: 'My Portal',
                      isSelected: !controller.isAdminMode.value,
                      icon: Iconsax.user,
                      onTap: () => controller.isAdminMode.value = false,
                    ),
                  ),
                ],
              )),
            ),
          ),

          // --- Dynamic Body ---
          Expanded(
            child: Obx(() {
              if (controller.isAdminMode.value) {
                return _buildAdminDashboard(context, controller);
              } else {
                return _buildEmployeeDashboard(context, controller);
              }
            }),
          ),
        ],
      ),
    );
  }

  // Segmented Perspective Tab builder
  Widget _buildPerspectiveTab({
    required String label,
    required String subLabel,
    required bool isSelected,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFF64748B),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? const Color(0xFF1E293B) : const Color(0xFF64748B),
                  ),
                ),
                Text(
                  subLabel,
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // --- ADMIN VIEW PANEL ---
  // ==========================================
  Widget _buildAdminDashboard(BuildContext context, ComplianceController controller) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Compliance Overview Card ──
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF4F46E5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4F46E5).withValues(alpha: 0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppText(
                        'Compliance Overview',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFE2E8F0),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildStatBadge('${controller.totalPolicies}', 'Total Policies', Colors.white.withValues(alpha: 0.15)),
                          const SizedBox(width: 8),
                          _buildStatBadge('${controller.publishedCount}', 'Published', const Color(0xFF10B981).withValues(alpha: 0.2)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildStatBadge('${controller.pendingCount}', 'Pending', const Color(0xFFF59E0B).withValues(alpha: 0.2)),
                          const SizedBox(width: 8),
                          _buildStatBadge('${controller.overdueCount}', 'Overdue', const Color(0xFFEF4444).withValues(alpha: 0.2)),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Iconsax.shield_security,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Quick Actions ──
          const AppText(
            'Quick Actions',
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Color(0xFF475569),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildQuickActionBtn(
                'Upload\nPolicy',
                Iconsax.document_upload,
                const Color(0xFF3B82F6),
                () => Get.to(() => const UploadPolicyScreen()),
              ),
              _buildQuickActionBtn(
                'Policy\nCategories',
                Iconsax.category,
                const Color(0xFF8B5CF6),
                () => _showCategoriesSheet(context, controller),
              ),
              _buildQuickActionBtn(
                'Compliance\nTracking',
                Iconsax.user_tick,
                const Color(0xFF10B981),
                () => Get.to(() => const ComplianceTrackingScreen()),
              ),
              _buildQuickActionBtn(
                'Audit\nLogs',
                Iconsax.task,
                const Color(0xFFF97316),
                () => Get.to(() => const ComplianceAuditLogsScreen()),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Policy Status breakdown ──
          const AppText(
            'Policy Status Breakdown',
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Color(0xFF475569),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFEEF2FF)),
            ),
            child: Column(
              children: [
                _buildStatusIndicatorRow('Published', controller.publishedCount, controller.totalPolicies, const Color(0xFF10B981)),
                const SizedBox(height: 12),
                _buildStatusIndicatorRow('Pending Acknowledgement', controller.pendingCount, controller.totalPolicies, const Color(0xFFF59E0B)),
                const SizedBox(height: 12),
                _buildStatusIndicatorRow('Overdue', controller.overdueCount, controller.totalPolicies, const Color(0xFFEF4444)),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Recent Policies ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const AppText(
                'Recent Policies',
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFF475569),
              ),
              GestureDetector(
                onTap: () => Get.to(() => const ComplianceTrackingScreen()),
                child: const AppText(
                  'View All',
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF2563EB),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.adminPolicies.length > 4 ? 4 : controller.adminPolicies.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final policy = controller.adminPolicies[index];
              return _buildAdminPolicyCard(policy);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge(String count, String label, Color bgColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              count,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
            const SizedBox(height: 2),
            AppText(
              label,
              fontSize: 8.5,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFE2E8F0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionBtn(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 76,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEEF2FF)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF475569),
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicatorRow(String label, int value, int total, Color color) {
    final double pct = total > 0 ? (value / total) : 0.0;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: color),
                ),
                const SizedBox(width: 8),
                AppText(
                  label,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF475569),
                ),
              ],
            ),
            AppText(
              '$value (${(pct * 100).toStringAsFixed(0)}%)',
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E293B),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 6,
            backgroundColor: const Color(0xFFF1F5F9),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildAdminPolicyCard(PolicyItem policy) {
    Color statusColor = const Color(0xFF10B981);
    if (policy.status == 'Pending') statusColor = const Color(0xFFF59E0B);
    if (policy.status == 'Overdue') statusColor = const Color(0xFFEF4444);

    return GestureDetector(
      onTap: () => Get.to(() => AdminPolicyDetailsScreen(policy: policy)),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFEEF2FF)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Iconsax.document_text5, color: Color(0xFF6366F1), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    policy.title,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E293B),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      AppText(
                        'v${policy.version}',
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF64748B),
                      ),
                      Container(
                        width: 3,
                        height: 3,
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: const BoxDecoration(
                          color: Color(0xFF94A3B8),
                          shape: BoxShape.circle,
                        ),
                      ),
                      AppText(
                        DateFormat('dd MMM yyyy').format(policy.updatedDate),
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF94A3B8),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: AppText(
                policy.status,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: statusColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoriesSheet(BuildContext context, ComplianceController controller) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
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
              'Policy Categories',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
            ),
            const SizedBox(height: 16),
            _buildCategoryTile('HR Policies', 'Policies relating to ethics, values and employee support.', 8, const Color(0xFF3B82F6)),
            const SizedBox(height: 10),
            _buildCategoryTile('Leave Policies', 'Entitlements, schedules and reporting channels.', 4, const Color(0xFF10B981)),
            const SizedBox(height: 10),
            _buildCategoryTile('IT & Security', 'Server infrastructure, passwords and database privacy rules.', 6, const Color(0xFF8B5CF6)),
            const SizedBox(height: 10),
            _buildCategoryTile('Work Policies', 'Productivity metrics, work locations and core shifts.', 6, const Color(0xFFF97316)),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTile(String title, String desc, int count, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEF2FF)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(Iconsax.folder_open, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(title, fontSize: 12.5, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B)),
                const SizedBox(height: 2),
                AppText(desc, fontSize: 9.5, color: const Color(0xFF64748B), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: const Color(0xFFE2E8F0))),
            child: AppText('$count', fontSize: 11, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B)),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // --- EMPLOYEE VIEW PANEL ---
  // ==========================================
  Widget _buildEmployeeDashboard(BuildContext context, ComplianceController controller) {
    return Column(
      children: [
        // Top static panels inside scrollable body
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── My Compliance Overview Card ──
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFEEF2FF)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4F46E5).withValues(alpha: 0.02),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Beautiful Custom Painter Donut Chart
                      SizedBox(
                        width: 76,
                        height: 76,
                        child: CustomPaint(
                          painter: _DonutChartPainter(
                            percentage: controller.employeeComplianceScore,
                            trackColor: const Color(0xFFF1F5F9),
                            progressColor: const Color(0xFF10B981),
                          ),
                          child: Center(
                            child: AppText(
                              '${controller.employeeComplianceScore.toStringAsFixed(0)}%',
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const AppText(
                              'My Compliance Overview',
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF64748B),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildMiniStat('Total', '${controller.employeeTotalPolicies}'),
                                _buildMiniStat('Ack\'d', '${controller.employeeAcknowledgedCount}'),
                                _buildMiniStat('Pending', '${controller.employeePendingCount}'),
                                _buildMiniStat('Overdue', '${controller.employeeOverdueCount}'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Filter Deck Tabs ──
                const AppText(
                  'My Policies Directory',
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF475569),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildFilterChip(controller, 'All', controller.employeeTotalPolicies),
                    const SizedBox(width: 8),
                    _buildFilterChip(controller, 'To Acknowledge', controller.employeePendingCount),
                    const SizedBox(width: 8),
                    _buildFilterChip(controller, 'Acknowledged', controller.employeeAcknowledgedCount),
                  ],
                ),
                const SizedBox(height: 16),

                // ── My Policies list ──
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.filteredEmployeePolicies.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final policy = controller.filteredEmployeePolicies[index];
                    return _buildEmployeePolicyCard(context, policy);
                  },
                ),
              ],
            ),
          ),
        ),

        // ── Download Report Sticky Button ──
        Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
          ),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _simulateDownloadComplianceReport(),
              icon: const Icon(Iconsax.document_download, color: Colors.white, size: 18),
              label: const AppText(
                'Download My Compliance Report',
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      children: [
        AppText(value, fontSize: 13, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B)),
        const SizedBox(height: 2),
        AppText(label, fontSize: 8.5, fontWeight: FontWeight.w600, color: const Color(0xFF94A3B8)),
      ],
    );
  }

  Widget _buildFilterChip(ComplianceController controller, String tabName, int count) {
    return Obx(() {
      final isSelected = controller.selectedEmployeeFilter.value == tabName;
      return GestureDetector(
        onTap: () => controller.selectedEmployeeFilter.value = tabName,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF4F46E5) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            children: [
              AppText(
                tabName,
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: isSelected ? Colors.white : const Color(0xFF64748B),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white.withValues(alpha: 0.2) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: AppText(
                  '$count',
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? Colors.white : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildEmployeePolicyCard(BuildContext context, PolicyItem policy) {
    final Color col = policy.isAcknowledged ? const Color(0xFF10B981) : const Color(0xFFF59E0B);
    final String statusLabel = policy.isAcknowledged ? 'Acknowledged' : 'Pending';

    return GestureDetector(
      onTap: () {
        if (policy.isAcknowledged) {
          Get.to(() => AcknowledgeSuccessScreen(
                policyName: policy.title,
                version: policy.version,
                acknowledgedDate: policy.acknowledgedDate ?? DateTime.now(),
              ));
        } else {
          Get.to(() => EmployeePolicyReaderScreen(policy: policy));
        }
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFEEF2FF)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: col.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                policy.isAcknowledged ? Iconsax.document : Iconsax.document_filter,
                color: col,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    policy.title,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E293B),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      AppText(
                        'v${policy.version}',
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF64748B),
                      ),
                      Container(
                        width: 3,
                        height: 3,
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: const BoxDecoration(
                          color: Color(0xFF94A3B8),
                          shape: BoxShape.circle,
                        ),
                      ),
                      AppText(
                        policy.category,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF94A3B8),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: col.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: AppText(
                statusLabel,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: col,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _simulateDownloadComplianceReport() {
    Get.showOverlay(
      opacity: 0.25,
      loadingWidget: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Color(0xFF4F46E5)),
              SizedBox(height: 16),
              AppText(
                'Generating PDF Report...',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ],
          ),
        ),
      ),
      asyncFunction: () async {
        await Future.delayed(const Duration(seconds: 2));
        Get.snackbar(
          'Report Downloaded Successfully! 📂',
          'Your personalized compliance metrics report has been saved to device downloads.',
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

// ── CUSTOM DONUT CHART PAINTER ──
class _DonutChartPainter extends CustomPainter {
  final double percentage;
  final Color trackColor;
  final Color progressColor;

  _DonutChartPainter({
    required this.percentage,
    required this.trackColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 4; // Subtract stroke width margins

    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = 6.5
      ..style = PaintingStyle.stroke;

    final progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = 6.5
      ..strokeCap = StrokeCap.round;

    progressPaint.style = PaintingStyle.stroke;

    // Draw background track ring
    canvas.drawCircle(center, radius, trackPaint);

    // Draw active progress segment
    final double sweepAngle = (percentage / 100) * 360 * (3.1415926535 / 180);
    final double startAngle = -90 * (3.1415926535 / 180); // Start from the top

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
