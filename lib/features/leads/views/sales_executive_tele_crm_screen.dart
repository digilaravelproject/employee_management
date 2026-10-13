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
  final String time;
  final String note;
  final String performedBy;
  final bool isCompleted;

  ExecLeadProcessStep({
    required this.title,
    required this.date,
    this.time = '',
    required this.note,
    this.performedBy = '',
    required this.isCompleted,
  });
}

class TeleCrmColleague {
  final String name;
  final String email;
  final String role;
  final String avatarUrl;
  final int activeLeadsCount;
  final String phone;

  const TeleCrmColleague({
    required this.name,
    required this.email,
    required this.role,
    required this.avatarUrl,
    required this.activeLeadsCount,
    this.phone = '+91 98765 00000',
  });
}

final List<TeleCrmColleague> _defaultColleaguesList = [
  const TeleCrmColleague(
    name: 'Neha Verma',
    email: 'neha.verma@company.com',
    role: 'Senior Sales Executive',
    avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150&auto=format&fit=crop&q=80',
    activeLeadsCount: 14,
    phone: '+91 98765 11221',
  ),
  const TeleCrmColleague(
    name: 'Aman Khan',
    email: 'aman.khan@company.com',
    role: 'Tele-CRM Specialist',
    avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150&auto=format&fit=crop&q=80',
    activeLeadsCount: 19,
    phone: '+91 98765 22332',
  ),
  const TeleCrmColleague(
    name: 'Pooja Singh',
    email: 'pooja.singh@company.com',
    role: 'BDE Executive',
    avatarUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150&auto=format&fit=crop&q=80',
    activeLeadsCount: 11,
    phone: '+91 98765 33443',
  ),
  const TeleCrmColleague(
    name: 'Kunal Roy',
    email: 'kunal.roy@company.com',
    role: 'Enterprise Sales Lead',
    avatarUrl: 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=150&auto=format&fit=crop&q=80',
    activeLeadsCount: 8,
    phone: '+91 98765 44554',
  ),
  const TeleCrmColleague(
    name: 'Priya Patel',
    email: 'priya.patel@company.com',
    role: 'Client Relationship Exec',
    avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&auto=format&fit=crop&q=80',
    activeLeadsCount: 16,
    phone: '+91 98765 55665',
  ),
];

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

  String assignedEmployee;
  String assignedEmployeeAvatar;
  String assignedEmployeeRole;
  bool isReassigned;

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
    this.assignedEmployee = 'Rahul Sharma (You)',
    this.assignedEmployeeAvatar = 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&auto=format&fit=crop&q=80',
    this.assignedEmployeeRole = 'Sales Executive',
    this.isReassigned = false,
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
      assignedEmployee: 'Rahul Sharma (You)',
      processSteps: [
        ExecLeadProcessStep(title: 'Lead Assigned by Admin', date: '06 Oct 2026', time: '10:00 AM', note: 'Source: Facebook Ads', performedBy: 'System Auto', isCompleted: true),
        ExecLeadProcessStep(title: 'First Call Attempt', date: '07 Oct 2026', time: '11:15 AM', note: 'Client asked to share quotation.', performedBy: 'Rahul Sharma', isCompleted: true),
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
      assignedEmployee: 'Rahul Sharma (You)',
      processSteps: [
        ExecLeadProcessStep(title: 'Lead Created by You', date: '08 Oct 2026', time: '02:30 PM', note: 'Outreach to local clinics.', performedBy: 'Rahul Sharma', isCompleted: true),
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
      assignedEmployee: 'Rahul Sharma (You)',
      processSteps: [
        ExecLeadProcessStep(title: 'Lead Assigned by Admin', date: '04 Oct 2026', time: '09:10 AM', note: '', performedBy: 'Admin', isCompleted: true),
        ExecLeadProcessStep(title: 'Demo Scheduled', date: '05 Oct 2026', time: '04:00 PM', note: 'Zoom link shared.', performedBy: 'Rahul Sharma', isCompleted: true),
        ExecLeadProcessStep(title: 'Demo Completed', date: '06 Oct 2026', time: '05:30 PM', note: 'Trial activated for 7 days.', performedBy: 'Rahul Sharma', isCompleted: true),
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
      assignedEmployee: 'Rahul Sharma (You)',
      processSteps: [
        ExecLeadProcessStep(title: 'Lead Assigned by Admin', date: '08 Oct 2026', time: '10:05 AM', note: 'Fresh lead.', performedBy: 'System Auto', isCompleted: true),
      ],
    ),
    TeleCrmLeadItem(
      id: 'TC-205',
      customerName: 'Sunil Mehta',
      phone: '+91 98110 55443',
      city: 'Pune',
      source: 'Referral',
      sourceColorHex: '0xFF10B981',
      status: 'Converted',
      isSelfGenerated: false,
      requirement: 'Annual SaaS subscription with 120 user licenses.',
      potentialValue: 185000,
      nextFollowupDateTime: null,
      lastCallNote: 'Payment received. Contract executed.',
      lastCallDuration: '12m 30s',
      lastCallDate: 'Yesterday 02:15 PM',
      assignedEmployee: 'Rahul Sharma (You)',
      processSteps: [
        ExecLeadProcessStep(title: 'Lead Assigned by Admin', date: '01 Oct 2026', time: '09:30 AM', note: 'Referred by standard client.', performedBy: 'Admin', isCompleted: true),
        ExecLeadProcessStep(title: 'Product Demo', date: '03 Oct 2026', time: '03:00 PM', note: 'Demo presented to leadership.', performedBy: 'Rahul Sharma', isCompleted: true),
        ExecLeadProcessStep(title: 'Converted to Customer 🎉', date: '10 Oct 2026', time: '11:45 AM', note: 'Deal closed at ₹1,85,000. Contract finalized.', performedBy: 'Rahul Sharma', isCompleted: true),
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
                '${_selectedTab.endsWith('Leads') ? _selectedTab : '$_selectedTab Leads'} (${_filteredLeads.length})',
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
            const SizedBox(height: 100), // Generous FAB spacing so cards are never covered
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
            const SizedBox(height: 8),

            // Assigned Employee Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: lead.isReassigned ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: lead.isReassigned ? const Color(0xFFDBEAFE) : const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 11,
                    backgroundImage: NetworkImage(lead.assignedEmployeeAvatar),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                        children: [
                          TextSpan(
                            text: lead.isReassigned ? 'Transferred to: ' : 'Assigned to: ',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          TextSpan(
                            text: lead.assignedEmployee,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: lead.isReassigned ? const Color(0xFF1D4ED8) : const Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: lead.isReassigned ? const Color(0xFFDBEAFE) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: AppText(
                      lead.isReassigned ? 'Transferred' : 'Owner',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: lead.isReassigned ? const Color(0xFF1D4ED8) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                    const SizedBox(height: 3),
                    Text(
                      lead.lastCallNote,
                      style: const TextStyle(
                        fontSize: 11,
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

            // ── Modern Unified Action Toolbar (3 Professional Balanced Buttons) ──
            Row(
              children: [
                // 1. Call Action (Emerald Tonal)
                Expanded(
                  child: Material(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () {
                        Get.snackbar(
                          'Dialing Call 📞',
                          'Calling ${lead.customerName} (${lead.phone})...',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: const Color(0xFF059669),
                          colorText: Colors.white,
                          margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          borderRadius: 14,
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 38,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFA7F3D0)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.phone_rounded, size: 14, color: Color(0xFF059669)),
                            SizedBox(width: 5),
                            AppText('Call', fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF059669)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // 2. Status Action (Slate Tonal)
                Expanded(
                  child: Material(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () => _showUpdateStatusModal(lead),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 38,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.edit_note_rounded, size: 16, color: Color(0xFF334155)),
                            SizedBox(width: 4),
                            AppText('Status', fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // 3. Assign Action (Royal Blue Tonal / Grey Locked if Converted)
                Expanded(
                  child: Material(
                    color: lead.status == 'Converted' ? const Color(0xFFF1F5F9) : const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () {
                        if (lead.status == 'Converted') {
                          Get.snackbar(
                            'Reassignment Locked',
                            'This lead is already converted and cannot be reassigned to another employee.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: const Color(0xFF475569),
                            colorText: Colors.white,
                            icon: const Icon(Icons.lock_rounded, color: Colors.white),
                            margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                            borderRadius: 14,
                          );
                        } else {
                          showAssignLeadToColleagueModal(
                            context: context,
                            lead: lead,
                            onAssigned: () => setState(() {}),
                          );
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 38,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: lead.status == 'Converted' ? const Color(0xFFE2E8F0) : const Color(0xFFBFDBFE),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              lead.status == 'Converted' ? Icons.lock_outline_rounded : Icons.swap_horiz_rounded,
                              size: 15,
                              color: lead.status == 'Converted' ? const Color(0xFF94A3B8) : const Color(0xFF2563EB),
                            ),
                            const SizedBox(width: 4),
                            AppText(
                              lead.status == 'Converted' ? 'Locked' : 'Assign',
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: lead.status == 'Converted' ? const Color(0xFF94A3B8) : const Color(0xFF2563EB),
                            ),
                          ],
                        ),
                      ),
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
    final noteController = TextEditingController();
    
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const AppText('Update Lead Status', fontSize: 18, fontWeight: FontWeight.w800),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  const AppText('Status', fontSize: 12, fontWeight: FontWeight.bold),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['Interested', 'Follow-up', 'Converted', 'Unreachable', 'Wrong Number'].map((s) {
                      final isSelected = selectedStatus == s;
                      return ChoiceChip(
                        label: Text(s, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : Colors.black, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                        selected: isSelected,
                        selectedColor: s == 'Converted' ? const Color(0xFF10B981) : AppColors.primaryColor,
                        onSelected: (bool selected) {
                          setModalState(() {
                            selectedStatus = s;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  if (selectedStatus == 'Converted') ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 16),
                          SizedBox(width: 8),
                          Expanded(
                            child: AppText(
                              'Converting this lead will lock reassignment permanently.',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF065F46),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  
                  const AppText('Call Note / Update Details', fontSize: 12, fontWeight: FontWeight.bold),
                  const SizedBox(height: 8),
                  TextField(
                    controller: noteController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'E.g., Client wants a demo tomorrow...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          final prevStatus = lead.status;
                          lead.status = selectedStatus;
                          lead.processSteps.add(ExecLeadProcessStep(
                            title: selectedStatus == 'Converted' 
                                ? 'Converted to Customer 🎉' 
                                : 'Status updated from $prevStatus to $selectedStatus',
                            date: DateFormat('dd MMM yyyy').format(DateTime.now()),
                            time: DateFormat('hh:mm a').format(DateTime.now()),
                            note: noteController.text.trim().isNotEmpty
                                ? noteController.text.trim()
                                : (selectedStatus == 'Converted' ? 'Lead closed & converted successfully.' : 'Updated via Executive App'),
                            performedBy: 'Rahul Sharma',
                            isCompleted: true,
                          ));
                        });
                        Navigator.pop(context);
                        Get.snackbar(
                          selectedStatus == 'Converted' ? 'Lead Converted 🎉' : 'Status Updated',
                          selectedStatus == 'Converted' ? 'Congratulations! Deal successfully closed.' : 'Lead status has been updated to $selectedStatus.',
                          backgroundColor: const Color(0xFF16A34A),
                          colorText: Colors.white,
                          snackPosition: SnackPosition.BOTTOM,
                          margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          borderRadius: 14,
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
// 🚀 REASSIGN LEAD TO ANOTHER EMPLOYEE MODAL (PROVISION FOR UNCONVERTED LEADS)
// ─────────────────────────────────────────────────────────────────────────────
void showAssignLeadToColleagueModal({
  required BuildContext context,
  required TeleCrmLeadItem lead,
  required VoidCallback onAssigned,
}) {
  // Guard check: cannot reassign converted lead
  if (lead.status == 'Converted') {
    Get.snackbar(
      'Reassignment Locked',
      'This lead is already converted and cannot be reassigned to another employee.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF475569),
      colorText: Colors.white,
      icon: const Icon(Icons.lock_rounded, color: Colors.white),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      borderRadius: 14,
    );
    return;
  }

  TeleCrmColleague? selectedColleague = _defaultColleaguesList.first;
  String selectedReason = 'Branch / Location Transfer';
  final noteController = TextEditingController(text: 'Assigned for follow-up and client meeting.');
  final searchController = TextEditingController();

  final List<String> transferReasons = [
    'Branch / Location Transfer',
    'Language Preference',
    'Enterprise Specialist',
    'Workload Balancing',
    'Client Requested Callback',
    'Special Deal Term Requirement',
  ];

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (modalCtx) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          final query = searchController.text.trim().toLowerCase();
          final filteredColleagues = _defaultColleaguesList.where((c) {
            return c.name.toLowerCase().contains(query) ||
                c.role.toLowerCase().contains(query) ||
                c.email.toLowerCase().contains(query);
          }).toList();

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(modalCtx).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const AppText(
                            'Assign Lead to Colleague',
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                          const SizedBox(height: 3),
                          AppText(
                            '${lead.customerName} (${lead.id})',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF64748B),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 22, color: Color(0xFF64748B)),
                        onPressed: () => Navigator.pop(modalCtx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Provision Policy Information Banner
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline_rounded, color: Color(0xFF2563EB), size: 18),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Provision: You can transfer this lead to another sales executive as long as it has not been converted. Once converted, the deal is permanently won.',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF1E40AF),
                              fontWeight: FontWeight.w500,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Search Sales Executive Colleague
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: TextField(
                      controller: searchController,
                      onChanged: (val) => setModalState(() {}),
                      decoration: const InputDecoration(
                        hintText: 'Search colleague name or role...',
                        hintStyle: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                        prefixIcon: Icon(Iconsax.search_normal, size: 18, color: Color(0xFF94A3B8)),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  const AppText(
                    'Select Colleague *',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF334155),
                  ),
                  const SizedBox(height: 8),

                  // Colleagues List
                  Container(
                    constraints: const BoxConstraints(maxHeight: 180),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: filteredColleagues.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: AppText('No colleagues found matching search.', fontSize: 12, color: Color(0xFF94A3B8)),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            itemCount: filteredColleagues.length,
                            separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                            itemBuilder: (context, index) {
                              final colleague = filteredColleagues[index];
                              final isSelected = selectedColleague?.email == colleague.email;

                              return InkWell(
                                onTap: () {
                                  setModalState(() {
                                    selectedColleague = colleague;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  color: isSelected ? const Color(0xFFEFF6FF) : Colors.transparent,
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 17,
                                        backgroundImage: NetworkImage(colleague.avatarUrl),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            AppText(
                                              colleague.name,
                                              fontSize: 13.5,
                                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                              color: const Color(0xFF0F172A),
                                            ),
                                            const SizedBox(height: 2),
                                            AppText(
                                              colleague.role,
                                              fontSize: 11,
                                              color: const Color(0xFF64748B),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF1F5F9),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: AppText(
                                          '${colleague.activeLeadsCount} Leads',
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF475569),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
                                        size: 20,
                                        color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFCBD5E1),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 16),

                  // Reason for Reassignment
                  const AppText(
                    'Reason for Reassignment',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF334155),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: transferReasons.map((reason) {
                      final isSelected = selectedReason == reason;
                      return ChoiceChip(
                        label: Text(reason, style: TextStyle(fontSize: 11, color: isSelected ? Colors.white : const Color(0xFF334155), fontWeight: isSelected ? FontWeight.bold : FontWeight.w500)),
                        selected: isSelected,
                        selectedColor: const Color(0xFF2563EB),
                        backgroundColor: const Color(0xFFF8FAFC),
                        side: BorderSide(color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0)),
                        onSelected: (val) {
                          setModalState(() {
                            selectedReason = reason;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),

                  // Instructions for Colleague
                  const AppText(
                    'Notes / Handoff Instructions',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF334155),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: noteController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Add client requirement or specific instructions...',
                      hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Submit Assignment Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (selectedColleague == null) {
                          Get.snackbar('Select Colleague', 'Please pick an executive to transfer this lead.');
                          return;
                        }

                        // Apply update
                        final chosen = selectedColleague!;
                        lead.assignedEmployee = chosen.name;
                        lead.assignedEmployeeAvatar = chosen.avatarUrl;
                        lead.assignedEmployeeRole = chosen.role;
                        lead.isReassigned = true;

                        lead.processSteps.add(ExecLeadProcessStep(
                          title: 'Lead Reassigned to ${chosen.name}',
                          date: DateFormat('dd MMM yyyy').format(DateTime.now()),
                          time: DateFormat('hh:mm a').format(DateTime.now()),
                          note: 'Transferred by Rahul Sharma. Reason: $selectedReason. ${noteController.text.trim().isNotEmpty ? 'Note: ${noteController.text.trim()}' : ''}',
                          performedBy: 'Rahul Sharma',
                          isCompleted: true,
                        ));

                        Navigator.pop(modalCtx);
                        onAssigned();

                        Get.snackbar(
                          'Lead Assigned 🎉',
                          'Lead ${lead.id} successfully reassigned to ${chosen.name}.',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: const Color(0xFF10B981),
                          colorText: Colors.white,
                          icon: const Icon(Icons.swap_horiz_rounded, color: Colors.white),
                          margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          borderRadius: 14,
                        );
                      },
                      icon: const Icon(Icons.swap_horiz_rounded, color: Colors.white, size: 18),
                      label: AppText(
                        'Assign Lead to ${selectedColleague?.name ?? 'Colleague'}',
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// 📱 FULL SCREEN LEAD DETAIL VIEW FOR EXECUTIVE (TREE FORMAT)
// ─────────────────────────────────────────────────────────────────────────────
class ExecLeadFullDetailScreen extends StatefulWidget {
  final TeleCrmLeadItem lead;
  final VoidCallback onStatusUpdated;

  const ExecLeadFullDetailScreen({super.key, required this.lead, required this.onStatusUpdated});

  @override
  State<ExecLeadFullDetailScreen> createState() => _ExecLeadFullDetailScreenState();
}

class _ExecLeadFullDetailScreenState extends State<ExecLeadFullDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final lead = widget.lead;
    final isConverted = lead.status == 'Converted';

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
        actions: [
          if (!isConverted)
            IconButton(
              icon: const Icon(Icons.swap_horiz_rounded, color: Color(0xFF2563EB)),
              tooltip: 'Assign to Colleague',
              onPressed: () => showAssignLeadToColleagueModal(
                context: context,
                lead: lead,
                onAssigned: () {
                  setState(() {});
                  widget.onStatusUpdated();
                },
              ),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5)),
          ],
        ),
        child: Row(
          children: [
            if (!isConverted) ...[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => showAssignLeadToColleagueModal(
                    context: context,
                    lead: lead,
                    onAssigned: () {
                      setState(() {});
                      widget.onStatusUpdated();
                    },
                  ),
                  icon: const Icon(Icons.swap_horiz_rounded, size: 17, color: Color(0xFF2563EB)),
                  label: const AppText(
                    'Assign Lead',
                    color: Color(0xFF2563EB),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFBFDBFE)),
                    backgroundColor: const Color(0xFFEFF6FF),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              flex: isConverted ? 1 : 2,
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
                icon: const Icon(Icons.phone_rounded, color: Colors.white, size: 18),
                label: const AppText('Call Client Now', color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
              ),
            ),
          ],
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
                          color: isConverted ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: AppText(
                          lead.status,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isConverted ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  const SizedBox(height: 14),

                  // Assigned Employee Detailed Row with Reassign action
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: lead.isReassigned ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: lead.isReassigned ? const Color(0xFFBFDBFE) : const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundImage: NetworkImage(lead.assignedEmployeeAvatar),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  AppText(
                                    lead.isReassigned ? 'Transferred Employee' : 'Assigned Executive',
                                    fontSize: 10.5,
                                    color: const Color(0xFF64748B),
                                  ),
                                  if (lead.isReassigned) ...[
                                    const SizedBox(width: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFDBEAFE),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const AppText('Handed Over', fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF1D4ED8)),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 2),
                              AppText(
                                lead.assignedEmployee,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0F172A),
                              ),
                            ],
                          ),
                        ),
                        if (!isConverted)
                          ElevatedButton.icon(
                            onPressed: () => showAssignLeadToColleagueModal(
                              context: context,
                              lead: lead,
                              onAssigned: () {
                                setState(() {});
                                widget.onStatusUpdated();
                              },
                            ),
                            icon: const Icon(Icons.swap_horiz_rounded, size: 14, color: Colors.white),
                            label: const AppText('Reassign', fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.lock_rounded, size: 12, color: Color(0xFF64748B)),
                                SizedBox(width: 4),
                                AppText('Locked (Converted)', fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

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
              final isReassignStep = step.title.toLowerCase().contains('reassigned');

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
                            color: isReassignStep 
                                ? const Color(0xFF2563EB) 
                                : (step.isCompleted ? const Color(0xFF10B981) : Colors.white),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isReassignStep 
                                  ? const Color(0xFF2563EB) 
                                  : (step.isCompleted ? const Color(0xFF10B981) : const Color(0xFFCBD5E1)),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            isReassignStep ? Icons.swap_horiz_rounded : Icons.check_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
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
                            color: isReassignStep ? const Color(0xFFF8FAFC) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isReassignStep ? const Color(0xFFBFDBFE) : const Color(0xFFE2E8F0)),
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
                                  AppText('${step.date} ${step.time}'.trim(), fontSize: 11, color: const Color(0xFF64748B)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.person_outline_rounded, size: 12, color: Color(0xFF94A3B8)),
                                  const SizedBox(width: 4),
                                  AppText(step.performedBy.isNotEmpty ? step.performedBy : 'Unknown', fontSize: 11, color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
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

