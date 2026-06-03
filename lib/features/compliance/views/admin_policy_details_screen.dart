import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/compliance_controller.dart';
import '../models/compliance_models.dart';

class AdminPolicyDetailsScreen extends StatefulWidget {
  final PolicyItem policy;

  const AdminPolicyDetailsScreen({super.key, required this.policy});

  @override
  State<AdminPolicyDetailsScreen> createState() => _AdminPolicyDetailsScreenState();
}

class _AdminPolicyDetailsScreenState extends State<AdminPolicyDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _isNotifying = false.obs;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _notifyEmployees(ComplianceController controller) async {
    _isNotifying.value = true;
    
    // Simulate notification broadcasting delay
    await Future.delayed(const Duration(milliseconds: 1500));
    
    _isNotifying.value = false;

    Get.snackbar(
      'Notifications Dispatched! 📢',
      'Broadcasting compliance alerts for "${widget.policy.title}" to all pending employees.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF4F46E5),
      colorText: Colors.white,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      borderRadius: 16,
    );

    // Append a log entry
    controller.auditLogs.insert(
      0,
      ComplianceAuditLog(
        id: 'log_${DateTime.now().millisecondsSinceEpoch}',
        dateTime: DateTime.now(),
        activity: 'Reminder Sent',
        policyTitle: widget.policy.title,
        performedBy: 'Admin',
        details: 'Admin triggered manual broadcast reminders for outstanding acknowledgements.',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ComplianceController>();

    Color statusColor = const Color(0xFF10B981);
    if (widget.policy.status == 'Pending') statusColor = const Color(0xFFF59E0B);
    if (widget.policy.status == 'Overdue') statusColor = const Color(0xFFEF4444);

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
            icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF1E293B)),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Document Header Info ──
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                // Red/Purple PDF Icon Block
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Iconsax.document_text5,
                    color: Color(0xFFEF4444),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: AppText(
                              widget.policy.title,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: AppText(
                              widget.policy.status,
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      AppText(
                        'Version ${widget.policy.version} • Published ${DateFormat('dd MMM yyyy').format(widget.policy.updatedDate)}',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF64748B),
                      ),
                      const SizedBox(height: 2),
                      const AppText(
                        'Last updated by Admin',
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF94A3B8),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Horizontal Tabs selector ──
          Container(
            color: Colors.white,
            width: double.infinity,
            child: TabBar(
              controller: _tabController,
              indicatorColor: const Color(0xFF4F46E5),
              indicatorWeight: 3,
              labelColor: const Color(0xFF4F46E5),
              unselectedLabelColor: const Color(0xFF64748B),
              labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
              unselectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Employees (160)'),
                Tab(text: 'Acknowledgement'),
                Tab(text: 'Audit'),
              ],
            ),
          ),

          // ── Tab View Body ──
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(controller),
                _buildMockListTab('Total Assigned Employees', controller),
                _buildMockListTab('Acknowledgement Statuses', controller),
                _buildMockListTab('Policy Audit Records', controller),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(ComplianceController controller) {
    final applies = widget.policy.category == 'Leave Policies' ? 'Full-Time Employees' : 'All Active Staff';
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats breakdown deck
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFEEF2FF)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMiniOverviewStat('180', 'Total Assigned', const Color(0xFF4F46E5)),
                      _buildMiniOverviewStat('156', 'Acknowledged', const Color(0xFF10B981)),
                      _buildMiniOverviewStat('24', 'Pending Review', const Color(0xFFF59E0B)),
                      _buildMiniOverviewStat('0', 'Overdue Standard', const Color(0xFFEF4444)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Policy statement summary
                const AppText(
                  'Policy Summary',
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF475569),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFEEF2FF)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.policy.summary,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                          height: 1.4,
                          fontFamily: 'Outfit',
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.policy.description,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF64748B),
                          height: 1.4,
                          fontFamily: 'Outfit',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Core attributes
                const AppText(
                  'Policy Attributes',
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF475569),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFEEF2FF)),
                  ),
                  child: Column(
                    children: [
                      _buildAttributeRow('Category', widget.policy.category, Iconsax.folder),
                      const Divider(color: Color(0xFFF1F5F9), height: 24),
                      _buildAttributeRow('Policy Owner', 'HR Department', Iconsax.user),
                      const Divider(color: Color(0xFFF1F5F9), height: 24),
                      _buildAttributeRow(
                        'Next Review Date',
                        DateFormat('dd MMMM yyyy').format(widget.policy.reviewDate),
                        Iconsax.calendar,
                      ),
                      const Divider(color: Color(0xFFF1F5F9), height: 24),
                      _buildAttributeRow('Attachments', 'policy_doc_signed.pdf', Iconsax.document_text),
                      const Divider(color: Color(0xFFF1F5F9), height: 24),
                      _buildAttributeRow('Applies To', applies, Iconsax.profile_2user),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Sticky Footer
        Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
          ),
          child: Obx(() {
            final isNotifying = _isNotifying.value;

            return Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF4F46E5), width: 1.5),
                      minimumSize: const Size(0, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const AppText(
                      'Edit Policy',
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF4F46E5),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isNotifying ? null : () => _notifyEmployees(controller),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      minimumSize: const Size(0, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: isNotifying
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const AppText(
                            'Notify Employees',
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }

  Widget _buildMiniOverviewStat(String value, String label, Color valueColor) {
    return Column(
      children: [
        AppText(value, fontSize: 16, fontWeight: FontWeight.w900, color: valueColor),
        const SizedBox(height: 4),
        AppText(label, fontSize: 8.5, fontWeight: FontWeight.w700, color: const Color(0xFF94A3B8)),
      ],
    );
  }

  Widget _buildAttributeRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF64748B), size: 18),
        const SizedBox(width: 12),
        AppText(label, fontSize: 11.5, fontWeight: FontWeight.w700, color: const Color(0xFF64748B)),
        const Spacer(),
        AppText(value, fontSize: 11.5, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B)),
      ],
    );
  }

  Widget _buildMockListTab(String listLabel, ComplianceController controller) {
    final list = controller.acknowledgements;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            listLabel,
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF475569),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFEEF2FF)),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: list.length,
              separatorBuilder: (context, index) => const Divider(color: Color(0xFFF1F5F9), height: 16),
              itemBuilder: (context, index) {
                final ack = list[index];
                Color badgeCol = const Color(0xFF10B981);
                if (ack.status == 'Pending') badgeCol = const Color(0xFFF59E0B);
                if (ack.status == 'Overdue') badgeCol = const Color(0xFFEF4444);

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundImage: NetworkImage(ack.avatarUrl),
                        backgroundColor: const Color(0xFFCBD5E1),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(ack.employeeName, fontSize: 12, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B)),
                            const SizedBox(height: 2),
                            AppText(ack.designation, fontSize: 9.5, color: const Color(0xFF64748B)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: badgeCol.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: AppText(ack.status, fontSize: 8, fontWeight: FontWeight.w800, color: badgeCol),
                          ),
                          if (ack.acknowledgedTime != null) ...[
                            const SizedBox(height: 4),
                            AppText(ack.acknowledgedTime!, fontSize: 8, color: const Color(0xFF94A3B8)),
                          ],
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
