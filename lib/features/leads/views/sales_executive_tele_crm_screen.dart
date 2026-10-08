import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import 'sales_executive_create_lead_screen.dart';

// ── MODELS ───────────────────────────────────────────────────────────────────
class ExecLeadProcessStep {
  final String title;
  final String date;
  final String note;
  final bool isCompleted;

  ExecLeadProcessStep({
    required this.title,
    required this.date,
    required this.note,
    required this.isCompleted,
  });
}

class TeleCrmLeadItem {
  final String id;
  final String customerName;
  final String phone;
  final String email;
  final String city;
  final String source;
  final String sourceColorHex;
  String status; // Interested, Follow-up, Pending Call, Converted, Unreachable, Wrong Number
  DateTime? nextFollowupDateTime;
  String requirement;
  double potentialValue;
  bool isSelfGenerated; // True = self brought, False = admin assigned
  List<ExecLeadProcessStep> processSteps;
  
  String lastCallNote;
  String lastCallDuration;
  String lastCallDate;

  TeleCrmLeadItem({
    required this.id,
    required this.customerName,
    required this.phone,
    this.email = 'client@example.com',
    required this.city,
    required this.source,
    required this.sourceColorHex,
    required this.status,
    this.nextFollowupDateTime,
    this.requirement = 'N/A',
    this.potentialValue = 0,
    this.isSelfGenerated = false,
    required this.processSteps,
    this.lastCallNote = '',
    this.lastCallDuration = '',
    this.lastCallDate = '',
  });
}

// ── SALES EXECUTIVE TELE-CRM SCREEN ──────────────────────────────────────────
class SalesExecutiveTeleCrmScreen extends StatefulWidget {
  const SalesExecutiveTeleCrmScreen({super.key});

  @override
  State<SalesExecutiveTeleCrmScreen> createState() => _SalesExecutiveTeleCrmScreenState();
}

class _SalesExecutiveTeleCrmScreenState extends State<SalesExecutiveTeleCrmScreen> {
  String _selectedTab = 'All Leads'; // All Leads, Follow-ups Today, Interested, Pending Call, Converted, Unreachable
  String _targetFilter = 'Today'; // Today, Weekly, Monthly
  final TextEditingController _searchController = TextEditingController();

  final List<TeleCrmLeadItem> _myLeads = [
    TeleCrmLeadItem(
      id: 'TC-201',
      customerName: 'Rajesh Agrawal',
      phone: '+91 98230 44556',
      city: 'Mumbai',
      source: 'Facebook Ads',
      sourceColorHex: '0xFF1877F2',
      status: 'Follow-up',
      isSelfGenerated: false,
      requirement: '40 Biometric Devices for office.',
      potentialValue: 140000,
      nextFollowupDateTime: DateTime.now().add(const Duration(hours: 2, minutes: 30)),
      lastCallNote: 'Interested. Asked for custom pricing quotation.',
      lastCallDuration: '8m 45s',
      lastCallDate: 'Yesterday 04:30 PM',
      processSteps: [
        ExecLeadProcessStep(title: 'Lead Assigned by Admin', date: '06 Oct 2026', note: 'Source: Facebook Ads', isCompleted: true),
        ExecLeadProcessStep(title: 'First Call Attempt', date: '07 Oct 2026', note: 'Client asked to share quotation.', isCompleted: true),
      ],
    ),
    TeleCrmLeadItem(
      id: 'TC-202',
      customerName: 'Dr. Alok Verma',
      phone: '+91 99112 88776',
      city: 'Delhi NCR',
      source: 'Self Generated',
      sourceColorHex: '0xFF7C3AED',
      status: 'Follow-up',
      isSelfGenerated: true,
      requirement: 'Custom clinic staff attendance app.',
      potentialValue: 65000,
      nextFollowupDateTime: DateTime.now().add(const Duration(hours: 5, minutes: 15)),
      lastCallNote: 'Call back in afternoon after surgery.',
      lastCallDuration: '3m 12s',
      lastCallDate: 'Today 11:00 AM',
      processSteps: [
        ExecLeadProcessStep(title: 'Lead Created by You', date: '08 Oct 2026', note: 'Outreach to local clinics.', isCompleted: true),
      ],
    ),
    TeleCrmLeadItem(
      id: 'TC-203',
      customerName: 'Meghna Sundaram',
      phone: '+91 97445 11223',
      city: 'Bengaluru',
      source: 'Website',
      sourceColorHex: '0xFF10B981',
      status: 'Interested',
      isSelfGenerated: false,
      requirement: 'Enterprise HRMS Integration.',
      potentialValue: 220000,
      nextFollowupDateTime: DateTime.now().add(const Duration(days: 1)),
      lastCallNote: 'Demo completed. Shared trial credentials.',
      lastCallDuration: '14m 20s',
      lastCallDate: '06 Oct 2026',
      processSteps: [
        ExecLeadProcessStep(title: 'Lead Assigned by Admin', date: '04 Oct 2026', note: '', isCompleted: true),
        ExecLeadProcessStep(title: 'Demo Scheduled', date: '05 Oct 2026', note: 'Zoom link shared.', isCompleted: true),
        ExecLeadProcessStep(title: 'Demo Completed', date: '06 Oct 2026', note: 'Trial activated for 7 days.', isCompleted: true),
      ],
    ),
    TeleCrmLeadItem(
      id: 'TC-204',
      customerName: 'Kishore Patel',
      phone: '+91 98980 33221',
      city: 'Ahmedabad',
      source: 'Google Ads',
      sourceColorHex: '0xFFEA4335',
      status: 'Pending Call',
      isSelfGenerated: false,
      requirement: 'Multiple shift attendance for factory workers.',
      potentialValue: 90000,
      nextFollowupDateTime: null,
      lastCallNote: 'Fresh lead assigned today.',
      lastCallDuration: '-',
      lastCallDate: '-',
      processSteps: [
        ExecLeadProcessStep(title: 'Lead Assigned by Admin', date: '08 Oct 2026', note: 'Fresh lead.', isCompleted: true),
      ],
    ),
  ];

  List<TeleCrmLeadItem> get _filteredLeads {
    final query = _searchController.text.trim().toLowerCase();
    return _myLeads.where((lead) {
      final matchesSearch = lead.customerName.toLowerCase().contains(query) ||
          lead.phone.toLowerCase().contains(query) ||
          lead.city.toLowerCase().contains(query) ||
          lead.id.toLowerCase().contains(query);
      if (!matchesSearch) return false;

      if (_selectedTab == 'Follow-ups Today') {
        return lead.status == 'Follow-up';
      } else if (_selectedTab == 'Interested') {
        return lead.status == 'Interested';
      } else if (_selectedTab == 'Pending Call') {
        return lead.status == 'Pending Call';
      } else if (_selectedTab == 'Converted') {
        return lead.status == 'Converted';
      } else if (_selectedTab == 'Unreachable') {
        return lead.status == 'Unreachable' || lead.status == 'Wrong Number';
      }
      return true; // 'All Leads'
    }).toList();
  }

  // Target calculation mock
  Map<String, dynamic> _getTargetData() {
    if (_targetFilter == 'Today') {
      return {'target': 20000, 'achieved': 5000, 'callsTarget': 50, 'callsMade': 28};
    } else if (_targetFilter == 'Weekly') {
      return {'target': 150000, 'achieved': 65000, 'callsTarget': 300, 'callsMade': 142};
    } else { // Monthly
      return {'target': 600000, 'achieved': 420000, 'callsTarget': 1200, 'callsMade': 850};
    }
  }

  @override
  Widget build(BuildContext context) {
    final targetData = _getTargetData();
    double revenueProgress = (targetData['achieved'] / targetData['target']).clamp(0.0, 1.0);
    double callProgress = (targetData['callsMade'] / targetData['callsTarget']).clamp(0.0, 1.0);
    
    final followupsCount = _myLeads.where((l) => l.status == 'Follow-up').length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 18),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              'Sales Executive Tele-CRM',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
            AppText(
              'Manage your leads, targets & follow-ups',
              fontSize: 11,
              color: AppColors.textColorSecondary,
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => Get.to(() => const SalesExecutiveCreateLeadScreen()),
            icon: const Icon(Icons.add_circle_rounded, color: AppColors.primaryColor),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => const SalesExecutiveCreateLeadScreen()),
        backgroundColor: AppColors.primaryColor,
        icon: const Icon(Iconsax.add, color: Colors.white, size: 20),
        label: const AppText('New Lead', color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        children: [
          // ── 1. Target & Performance Header Banner ──
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryColor, AppColors.primaryColor.withValues(alpha: 0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                // Filter dropdown
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const AppText('My Performance Target', fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                    Container(
                      height: 28,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _targetFilter,
                          dropdownColor: AppColors.primaryColor,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 16),
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                          items: ['Today', 'Weekly', 'Monthly'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _targetFilter = val);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Revenue Progress
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const AppText('Revenue Achieved', fontSize: 11, color: Color(0xFFE0E7FF)),
                    AppText('₹${(targetData['achieved'] / 1000).toStringAsFixed(0)}k / ₹${(targetData['target'] / 1000).toStringAsFixed(0)}k', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: revenueProgress,
                    backgroundColor: Colors.black.withValues(alpha: 0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Calls Progress
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const AppText('Calls Made', fontSize: 11, color: Color(0xFFE0E7FF)),
                    AppText('${targetData['callsMade']} / ${targetData['callsTarget']} calls', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: callProgress,
                    backgroundColor: Colors.black.withValues(alpha: 0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFDE047)),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── 2. Search & Segregation Tabs ──
          TextField(
            controller: _searchController,
            onChanged: (val) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search customer name, phone, city...',
              hintStyle: const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
              prefixIcon: const Icon(Iconsax.search_normal_1, size: 18, color: Color(0xFF64748B)),
              fillColor: Colors.white,
              filled: true,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
            ),
          ),
          const SizedBox(height: 12),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildTabChip('All Leads'),
                _buildTabChip('Follow-ups Today', count: followupsCount),
                _buildTabChip('Interested'),
                _buildTabChip('Pending Call'),
                _buildTabChip('Converted'),
                _buildTabChip('Unreachable'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── 3. Leads List ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                '$_selectedTab Leads (${_filteredLeads.length})',
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
              const AppText(
                'Tap for full details',
                fontSize: 10.5,
                color: AppColors.textColorHint,
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (_filteredLeads.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Column(
                children: [
                  Icon(Iconsax.folder_open, size: 40, color: AppColors.textColorHint),
                  SizedBox(height: 10),
                  AppText(
                    'No leads found in this section.',
                    color: AppColors.textColorSecondary,
                    fontSize: 13,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ..._filteredLeads.map((lead) => _buildTeleCrmLeadCard(lead)),
            const SizedBox(height: 60), // FAB spacing
        ],
      ),
    );
  }

  Widget _buildTabChip(String label, {int? count}) {
    final isSelected = _selectedTab == label;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        selected: isSelected,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppText(
              label,
              fontSize: 11.5,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected ? Colors.white : const Color(0xFF475569),
            ),
            if (count != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white.withValues(alpha: 0.3) : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: AppText(
                  '$count',
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : const Color(0xFF334155),
                ),
              ),
            ],
          ],
        ),
        backgroundColor: Colors.white,
        selectedColor: AppColors.primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: isSelected ? AppColors.primaryColor : const Color(0xFFCBD5E1)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        onSelected: (val) {
          setState(() {
            _selectedTab = label;
          });
        },
      ),
    );
  }

  Widget _buildTeleCrmLeadCard(TeleCrmLeadItem lead) {
    Color statusColor;
    Color statusBgColor;

    switch (lead.status) {
      case 'Interested':
        statusColor = const Color(0xFF16A34A);
        statusBgColor = const Color(0xFFDCFCE7);
        break;
      case 'Follow-up':
        statusColor = const Color(0xFFD97706);
        statusBgColor = const Color(0xFFFEF3C7);
        break;
      case 'Converted':
        statusColor = const Color(0xFF2563EB);
        statusBgColor = const Color(0xFFDBEAFE);
        break;
      case 'Unreachable':
        statusColor = const Color(0xFF7C3AED);
        statusBgColor = const Color(0xFFEDE9FE);
        break;
      case 'Wrong Number':
        statusColor = const Color(0xFFDC2626);
        statusBgColor = const Color(0xFFFEE2E2);
        break;
      default:
        statusColor = const Color(0xFF475569);
        statusBgColor = const Color(0xFFF1F5F9);
    }

    final sourceColor = Color(int.parse(lead.sourceColorHex));

    return GestureDetector(
      onTap: () => Get.to(() => ExecLeadFullDetailScreen(
        lead: lead,
        onStatusUpdated: () => setState(() {}),
      )),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: lead.isSelfGenerated ? const Color(0xFFE9D5FF) : const Color(0xFFE2E8F0),
            width: lead.isSelfGenerated ? 1.5 : 1.0,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: lead.isSelfGenerated ? const Color(0xFFF3E8FF) : const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: AppText(
                        lead.isSelfGenerated ? 'Self Brought' : 'Admin Assigned',
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        color: lead.isSelfGenerated ? const Color(0xFF7C3AED) : const Color(0xFF2563EB),
                      ),
                    ),
                    const SizedBox(width: 8),
                    AppText(
                      lead.id,
                      fontSize: 10.5,
                      color: AppColors.textColorHint,
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: AppText(
                    lead.status,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        lead.customerName,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textColorPrimary,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Iconsax.location, size: 12, color: AppColors.textColorSecondary),
                          const SizedBox(width: 4),
                          AppText(
                            lead.city,
                            fontSize: 11,
                            color: AppColors.textColorSecondary,
                          ),
                          const SizedBox(width: 10),
                          const Icon(Iconsax.call, size: 12, color: AppColors.textColorSecondary),
                          const SizedBox(width: 4),
                          AppText(
                            lead.phone,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColorPrimary,
                          ),
                          const SizedBox(width: 10),
                          const Icon(Iconsax.wallet_3, size: 12, color: AppColors.textColorSecondary),
                          const SizedBox(width: 4),
                          AppText(
                            '₹${(lead.potentialValue / 1000).toStringAsFixed(0)}k',
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF15803D),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Follow-up Timer Alert Bar (if follow-up date set)
            if (lead.nextFollowupDateTime != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFCD34D)),
                ),
                child: Row(
                  children: [
                    const Icon(Iconsax.timer_1, size: 14, color: Color(0xFFD97706)),
                    const SizedBox(width: 6),
                    AppText(
                      'Next Follow-up Call: ${DateFormat('dd MMM, hh:mm a').format(lead.nextFollowupDateTime!)}',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFB45309),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Last Discussion Note
            if (lead.lastCallNote.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const AppText('Last Call Discussion:', fontSize: 9.5, color: AppColors.textColorHint, fontWeight: FontWeight.bold),
                        AppText('Duration: ${lead.lastCallDuration}', fontSize: 9.5, color: AppColors.textColorSecondary),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lead.lastCallNote,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF334155),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 12),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showUpdateStatusModal(lead);
                    },
                    icon: const Icon(Icons.edit_note_rounded, size: 16, color: Color(0xFF0F172A)),
                    label: const AppText('Update Status', fontSize: 11.5, color: Color(0xFF0F172A), fontWeight: FontWeight.bold),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.snackbar(
                        'Dialing Call 📞',
                        'Calling ${lead.customerName}...',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: AppColors.primaryColor,
                        colorText: Colors.white,
                      );
                    },
                    icon: const Icon(Icons.phone_rounded, size: 14, color: Colors.white),
                    label: const AppText('Call Now', fontSize: 11.5, color: Colors.white, fontWeight: FontWeight.bold),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  void _showUpdateStatusModal(TeleCrmLeadItem lead) {
    String selectedStatus = lead.status;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppText('Update Lead Status', fontSize: 18, fontWeight: FontWeight.w800),
                  const SizedBox(height: 20),
                  
                  const AppText('Status', fontSize: 12, fontWeight: FontWeight.bold),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['Interested', 'Follow-up', 'Converted', 'Unreachable', 'Wrong Number'].map((s) {
                      return ChoiceChip(
                        label: Text(s, style: TextStyle(fontSize: 12, color: selectedStatus == s ? Colors.white : Colors.black)),
                        selected: selectedStatus == s,
                        selectedColor: AppColors.primaryColor,
                        onSelected: (bool selected) {
                          setModalState(() {
                            selectedStatus = s;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  
                  const AppText('Call Note / Update Details', fontSize: 12, fontWeight: FontWeight.bold),
                  const SizedBox(height: 8),
                  TextField(
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'E.g., Client wants a demo tomorrow...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          lead.status = selectedStatus;
                          lead.processSteps.add(ExecLeadProcessStep(
                            title: 'Status updated to $selectedStatus',
                            date: DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now()),
                            note: 'Updated via Executive App',
                            isCompleted: true,
                          ));
                        });
                        Navigator.pop(context);
                        Get.snackbar(
                          'Status Updated',
                          'Lead has been updated.',
                          backgroundColor: const Color(0xFF16A34A),
                          colorText: Colors.white,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const AppText('Save Updates', color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 📱 FULL SCREEN LEAD DETAIL VIEW FOR EXECUTIVE (TREE FORMAT)
// ─────────────────────────────────────────────────────────────────────────────
class ExecLeadFullDetailScreen extends StatelessWidget {
  final TeleCrmLeadItem lead;
  final VoidCallback onStatusUpdated;

  const ExecLeadFullDetailScreen({super.key, required this.lead, required this.onStatusUpdated});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 20),
              onPressed: () => Get.back(),
            ),
          ),
        ),
        title: const AppText(
          'Lead Details',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF0F172A),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5)),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: () {
            // Can show the same update status modal here by extracting it to a standalone widget or controller.
            Get.snackbar('Quick Action', 'Use Update Status button on card for now.');
          },
          icon: const Icon(Icons.phone_rounded, color: Colors.white),
          label: const AppText('Call Client Now', color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Client Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: const Color(0xFFEFF6FF),
                        child: Text(
                          lead.customerName.isNotEmpty ? lead.customerName[0].toUpperCase() : 'C',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(lead.customerName, fontSize: 16, fontWeight: FontWeight.bold),
                            const SizedBox(height: 4),
                            AppText('Lead ID: ${lead.id}', fontSize: 12, color: const Color(0xFF64748B)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: AppText(
                          lead.status,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF16A34A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.phone_rounded, size: 16, color: Color(0xFF64748B)),
                      const SizedBox(width: 8),
                      AppText(lead.phone, fontSize: 13, fontWeight: FontWeight.w600),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.email_rounded, size: 16, color: Color(0xFF64748B)),
                      const SizedBox(width: 8),
                      AppText(lead.email, fontSize: 13, fontWeight: FontWeight.w600),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.assignment_rounded, size: 16, color: Color(0xFF64748B)),
                      const SizedBox(width: 8),
                      Expanded(child: AppText('Requirement: ${lead.requirement}', fontSize: 13, fontWeight: FontWeight.w600, maxLines: 3)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.attach_money_rounded, size: 16, color: Color(0xFF64748B)),
                      const SizedBox(width: 8),
                      AppText('Potential Value: ₹${(lead.potentialValue / 1000).toStringAsFixed(0)}k', fontSize: 13, fontWeight: FontWeight.w800, color: const Color(0xFF15803D)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.campaign_rounded, size: 16, color: Color(0xFF64748B)),
                      const SizedBox(width: 8),
                      AppText(lead.isSelfGenerated ? 'Self Brought by You' : 'Assigned by Admin', fontSize: 13, fontWeight: FontWeight.w600, color: lead.isSelfGenerated ? const Color(0xFF7C3AED) : const Color(0xFF2563EB)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // 2. Process & Interactions History Tree
            const AppText(
              'Process & Interactions History',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
            const SizedBox(height: 16),
            ...List.generate(lead.processSteps.length, (index) {
              final step = lead.processSteps[index];
              final isLast = index == lead.processSteps.length - 1;
              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Tree Connector (Line & Dot)
                    Column(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: step.isCompleted ? const Color(0xFF10B981) : Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: step.isCompleted ? const Color(0xFF10B981) : const Color(0xFFCBD5E1),
                              width: 2,
                            ),
                          ),
                          child: step.isCompleted
                              ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                              : null,
                        ),
                        if (!isLast)
                          Expanded(
                            child: Container(
                              width: 2,
                              color: step.isCompleted ? const Color(0xFF10B981) : const Color(0xFFE2E8F0),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    // Step Content Card
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2)),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(child: AppText(step.title, fontSize: 13.5, fontWeight: FontWeight.bold)),
                                  AppText(step.date, fontSize: 11, color: const Color(0xFF64748B)),
                                ],
                              ),
                              if (step.note.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                AppText(step.note, fontSize: 12, color: const Color(0xFF475569)),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
