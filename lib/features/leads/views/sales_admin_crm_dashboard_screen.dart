import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import 'sales_executive_tele_crm_screen.dart';
import 'sales_executive_create_lead_screen.dart';

// ── MODELS ───────────────────────────────────────────────────────────────────

class LeadProcessStep {
  final String title;
  final String date;
  final String time;
  final String note;
  final String performedBy;
  final bool isCompleted;

  LeadProcessStep({
    required this.title,
    required this.date,
    this.time = '',
    required this.note,
    this.performedBy = '',
    required this.isCompleted,
  });
}

class SourceAssignRule {
  String id;
  String sourceName; // Google Ads, Facebook Ads, JustDial, Website, Referral, Direct Inquiry
  String colorHex;
  List<String> assignedExecutives; // Employee names allocated for this source
  String strategy; // Round-Robin, Multi-Executive, Primary
  bool isActive;

  SourceAssignRule({
    required this.id,
    required this.sourceName,
    required this.colorHex,
    required this.assignedExecutives,
    this.strategy = 'Round-Robin',
    this.isActive = true,
  });
}

class AdminLeadStatusItem {
  String id;
  String name; // Interested, Follow-up, Converted, Unreachable, Wrong Number, New, In Progress
  String colorHex;
  String category; // Prospecting, Active Lead, Won, Disqualified
  String description;
  bool isDefault;

  AdminLeadStatusItem({
    required this.id,
    required this.name,
    required this.colorHex,
    required this.category,
    this.description = '',
    this.isDefault = false,
  });
}

class AdminLeadItem {
  final String id;
  final String customerName;
  final String phone;
  final String email;
  final String source; // Google Ads, Facebook Ads, JustDial, Website, Referral, Direct Inquiry
  final String sourceColorHex;
  String assignedExecutive;
  String assignedExecutiveAvatar;
  bool isSelfGenerated; // True if self-brought by executive, false if admin assigned
  String status; // New, In Progress, Follow-up, Interested, Converted, Wrong Number, Unreachable
  final String dateReceived;
  final String requirement;
  final double potentialValue;
  final int callAttempts;
  final String lastCallDuration;
  final List<LeadProcessStep> processSteps;

  AdminLeadItem({
    required this.id,
    required this.customerName,
    required this.phone,
    required this.email,
    required this.source,
    required this.sourceColorHex,
    required this.assignedExecutive,
    required this.assignedExecutiveAvatar,
    this.isSelfGenerated = false,
    required this.status,
    required this.dateReceived,
    required this.requirement,
    required this.potentialValue,
    this.callAttempts = 0,
    this.lastCallDuration = '0m',
    required this.processSteps,
  });
}

class SalesExecutivePerf {
  final String name;
  final String avatar;
  final String designation;
  final double revenue;
  final double target;
  final int callsCount;
  final String totalTalkTime;
  final String avgTalkTime;
  final int convertedLeads;
  final int totalLeadsAssigned;
  final int totalLeadsSelfGenerated;

  SalesExecutivePerf({
    required this.name,
    required this.avatar,
    required this.designation,
    required this.revenue,
    required this.target,
    required this.callsCount,
    required this.totalTalkTime,
    required this.avgTalkTime,
    required this.convertedLeads,
    required this.totalLeadsAssigned,
    required this.totalLeadsSelfGenerated,
  });

  int get totalLeads => totalLeadsAssigned + totalLeadsSelfGenerated;
  double get targetPercentage => target > 0 ? (revenue / target * 100).clamp(0, 100) : 0;
  double get conversionRate => totalLeads > 0 ? (convertedLeads / totalLeads * 100).clamp(0, 100) : 0;
}

// ── SALES ADMIN DASHBOARD SCREEN ─────────────────────────────────────────────

class SalesAdminDashboardScreen extends StatefulWidget {
  const SalesAdminDashboardScreen({super.key});

  @override
  State<SalesAdminDashboardScreen> createState() => _SalesAdminDashboardScreenState();
}

class _SalesAdminDashboardScreenState extends State<SalesAdminDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _mainTabController;
  int? _selectedModuleIndex; // null = Main 4 Vertical Cards Dashboard overview; 0=Sales Team, 1=Leads Hub, 2=Source Rules, 3=Lead Statuses


  // Search & Filter Controllers for Option 2 (Leads Hub)
  String _selectedSourceFilter = 'All';
  String _selectedLeadAllocationCategory = 'All'; // All, New (Unassigned), Assigned
  final String _selectedStatusFilter = 'All';
  final TextEditingController _searchController = TextEditingController();

  // Search for Option 1 (Sales Team)
  final TextEditingController _teamSearchController = TextEditingController();

  // Lead Source Auto-Assignment Rules State
  late List<SourceAssignRule> _sourceRules;
  int _roundRobinIndex = 0;

  // Lead Statuses Management State
  late List<AdminLeadStatusItem> _leadStatuses;

  // Mock Sales Executives
  final List<SalesExecutivePerf> _executives = [
    SalesExecutivePerf(
      name: 'Rahul Sharma',
      avatar: 'https://yellowgreen-stork-427223.hostingersite.com/storage/avatars/wiS1bnWjQxY81Zkn73BBwSEtNa8tFy6qWT5NpwhU.jpg',
      designation: 'Sr. Sales Executive',
      revenue: 650000,
      target: 800000,
      callsCount: 340,
      totalTalkTime: '24h 15m',
      avgTalkTime: '4m 30s',
      convertedLeads: 14,
      totalLeadsAssigned: 30,
      totalLeadsSelfGenerated: 15,
    ),
    SalesExecutivePerf(
      name: 'Priya Patel',
      avatar: '',
      designation: 'Sales Executive',
      revenue: 420000,
      target: 500000,
      callsCount: 280,
      totalTalkTime: '17h 40m',
      avgTalkTime: '3m 45s',
      convertedLeads: 9,
      totalLeadsAssigned: 22,
      totalLeadsSelfGenerated: 10,
    ),
    SalesExecutivePerf(
      name: 'Amit Verma',
      avatar: '',
      designation: 'Tele-Sales Representative',
      revenue: 510000,
      target: 600000,
      callsCount: 410,
      totalTalkTime: '32h 10m',
      avgTalkTime: '5m 10s',
      convertedLeads: 11,
      totalLeadsAssigned: 28,
      totalLeadsSelfGenerated: 12,
    ),
    SalesExecutivePerf(
      name: 'Neha Singh',
      avatar: '',
      designation: 'Sales Executive',
      revenue: 380000,
      target: 500000,
      callsCount: 210,
      totalTalkTime: '11h 20m',
      avgTalkTime: '3m 15s',
      convertedLeads: 7,
      totalLeadsAssigned: 20,
      totalLeadsSelfGenerated: 8,
    ),
  ];

  // Mock Master Leads Database
  late List<AdminLeadItem> _leadsList;

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(length: 4, vsync: this);
    _mainTabController.addListener(() {
      if (mounted) setState(() {});
    });
    _initLeadsData();
    _initSourceRules();
    _initLeadStatuses();
  }

  void _initSourceRules() {
    _sourceRules = [
      SourceAssignRule(
        id: 'SR-01',
        sourceName: 'Google Ads',
        colorHex: '0xFFEA4335',
        assignedExecutives: ['Rahul Sharma', 'Neha Singh'],
        strategy: 'Round-Robin',
        isActive: true,
      ),
      SourceAssignRule(
        id: 'SR-02',
        sourceName: 'Facebook Ads',
        colorHex: '0xFF1877F2',
        assignedExecutives: ['Priya Patel'],
        strategy: 'Round-Robin',
        isActive: true,
      ),
      SourceAssignRule(
        id: 'SR-03',
        sourceName: 'JustDial',
        colorHex: '0xFFF58220',
        assignedExecutives: ['Priya Patel', 'Amit Verma'],
        strategy: 'Round-Robin',
        isActive: true,
      ),
      SourceAssignRule(
        id: 'SR-04',
        sourceName: 'Website',
        colorHex: '0xFF10B981',
        assignedExecutives: ['Rahul Sharma'],
        strategy: 'Primary',
        isActive: true,
      ),
      SourceAssignRule(
        id: 'SR-05',
        sourceName: 'Referral',
        colorHex: '0xFF8B5CF6',
        assignedExecutives: ['Amit Verma'],
        strategy: 'Primary',
        isActive: true,
      ),
      SourceAssignRule(
        id: 'SR-06',
        sourceName: 'Direct Inquiry',
        colorHex: '0xFF6366F1',
        assignedExecutives: ['Rahul Sharma', 'Priya Patel', 'Amit Verma', 'Neha Singh'],
        strategy: 'Round-Robin',
        isActive: true,
      ),
    ];
  }

  void _initLeadStatuses() {
    _leadStatuses = [
      AdminLeadStatusItem(
        id: 'ST-01',
        name: 'New',
        colorHex: '0xFF3B82F6',
        category: 'Prospecting',
        description: 'Fresh lead captured, pending first outreach call.',
        isDefault: true,
      ),
      AdminLeadStatusItem(
        id: 'ST-02',
        name: 'Interested',
        colorHex: '0xFF10B981',
        category: 'Active Lead',
        description: 'Client expressed interest & requested proposal/demo.',
        isDefault: false,
      ),
      AdminLeadStatusItem(
        id: 'ST-03',
        name: 'Follow-up',
        colorHex: '0xFFF59E0B',
        category: 'Active Lead',
        description: 'Callback scheduled; active discussions ongoing.',
        isDefault: false,
      ),
      AdminLeadStatusItem(
        id: 'ST-04',
        name: 'In Progress',
        colorHex: '0xFF6366F1',
        category: 'Active Lead',
        description: 'Technical evaluation or contract review in progress.',
        isDefault: false,
      ),
      AdminLeadStatusItem(
        id: 'ST-05',
        name: 'Converted',
        colorHex: '0xFF059669',
        category: 'Won',
        description: 'Deal closed & advance payment received.',
        isDefault: false,
      ),
      AdminLeadStatusItem(
        id: 'ST-06',
        name: 'Unreachable',
        colorHex: '0xFF8B5CF6',
        category: 'Active Lead',
        description: 'Call unanswered after 3+ attempts.',
        isDefault: false,
      ),
      AdminLeadStatusItem(
        id: 'ST-07',
        name: 'Wrong Number',
        colorHex: '0xFFEF4444',
        category: 'Disqualified',
        description: 'Invalid contact details or spam inquiry.',
        isDefault: false,
      ),
      AdminLeadStatusItem(
        id: 'ST-08',
        name: 'Not Interested',
        colorHex: '0xFF64748B',
        category: 'Disqualified',
        description: 'Client declined offer or purchased competitor product.',
        isDefault: false,
      ),
    ];
  }

  void _triggerAutoAssignUnassignedLeads() {
    final unassignedLeads = _leadsList.where((l) => l.assignedExecutive == 'Unassigned').toList();
    if (unassignedLeads.isEmpty) {
      Get.snackbar(
        'All Leads Assigned',
        'No unassigned leads found in the database.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF6366F1),
        colorText: Colors.white,
      );
      return;
    }

    int assignedCount = 0;
    setState(() {
      for (var lead in unassignedLeads) {
        final ruleIndex = _sourceRules.indexWhere((r) => r.sourceName.toLowerCase() == lead.source.toLowerCase() && r.isActive);
        if (ruleIndex != -1) {
          final rule = _sourceRules[ruleIndex];
          if (rule.assignedExecutives.isNotEmpty) {
            String targetExecName;
            if (rule.strategy == 'Round-Robin' || rule.assignedExecutives.length > 1) {
              targetExecName = rule.assignedExecutives[_roundRobinIndex % rule.assignedExecutives.length];
              _roundRobinIndex++;
            } else {
              targetExecName = rule.assignedExecutives.first;
            }

            final execObj = _executives.firstWhere(
              (e) => e.name == targetExecName,
              orElse: () => _executives.first,
            );

            lead.assignedExecutive = execObj.name;
            lead.assignedExecutiveAvatar = execObj.avatar;
            lead.processSteps.add(
              LeadProcessStep(
                title: 'Auto-Assigned via Pre-set Rule',
                date: 'Today',
                note: 'Rule: ${rule.sourceName} ➔ ${execObj.name} (${rule.strategy})',
                isCompleted: true,
              ),
            );
            assignedCount++;
          }
        }
      }
    });

    Get.snackbar(
      'Auto-Assignment Completed 🚀',
      '$assignedCount unassigned lead(s) automatically allocated based on source rules!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF10B981),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  void _initLeadsData() {
    _leadsList = [
      AdminLeadItem(
        id: 'LD-1092',
        customerName: 'Anil Kumar (TechCorp India)',
        phone: '+91 98765 43210',
        email: 'anil@techcorp.in',
        source: 'Facebook Ads',
        sourceColorHex: '0xFF1877F2',
        assignedExecutive: 'Rahul Sharma',
        assignedExecutiveAvatar: 'https://yellowgreen-stork-427223.hostingersite.com/storage/avatars/wiS1bnWjQxY81Zkn73BBwSEtNa8tFy6qWT5NpwhU.jpg',
        isSelfGenerated: false,
        status: 'Interested',
        dateReceived: '07 Oct 2026',
        requirement: 'ERP & Attendance Suite - 50 Licenses',
        potentialValue: 120000,
        callAttempts: 4,
        lastCallDuration: '6m 12s',
        processSteps: [
          LeadProcessStep(title: 'Lead Captured via Facebook Ads', date: '05 Oct 2026', time: '10:30 AM', note: 'Inbound inquiry from Facebook lead form', performedBy: 'System Auto', isCompleted: true),
          LeadProcessStep(title: 'Assigned to Rahul Sharma', date: '05 Oct 2026', time: '10:35 AM', note: 'Admin auto-allocated to Rahul', performedBy: 'Admin (Ramesh)', isCompleted: true),
          LeadProcessStep(title: 'First Intro Call & Needs Analysis', date: '06 Oct 2026', time: '11:15 AM', note: 'Discussed biometric integration and 50 employee licenses', performedBy: 'Rahul Sharma', isCompleted: true),
          LeadProcessStep(title: 'Product Demo & Proposal Sent', date: '07 Oct 2026', time: '02:00 PM', note: 'Shared quote of ₹1.2L via email and WhatsApp', performedBy: 'Rahul Sharma', isCompleted: true),
          LeadProcessStep(title: 'Final Deal Closure', date: 'Pending', time: '-', note: 'Awaiting PO approval from Finance team', performedBy: 'Rahul Sharma', isCompleted: false),
        ],
      ),
      AdminLeadItem(
        id: 'LD-1093',
        customerName: 'Sanjay Mehta (Apex Logistics)',
        phone: '+91 98112 33445',
        email: 'sanjay.m@apexlogistics.com',
        source: 'JustDial',
        sourceColorHex: '0xFFF58220',
        assignedExecutive: 'Priya Patel',
        assignedExecutiveAvatar: '',
        isSelfGenerated: false,
        status: 'Follow-up',
        dateReceived: '07 Oct 2026',
        requirement: 'Biometric Hardware & GPS Tracking',
        potentialValue: 45000,
        callAttempts: 2,
        lastCallDuration: '3m 45s',
        processSteps: [
          LeadProcessStep(title: 'JustDial Inquiry Received', date: '06 Oct 2026', time: '09:15 AM', note: 'Hardware requirement inquiry', performedBy: 'System Auto', isCompleted: true),
          LeadProcessStep(title: 'Assigned to Priya Patel', date: '06 Oct 2026', time: '09:20 AM', note: 'Admin allocated lead', performedBy: 'Admin (Ramesh)', isCompleted: true),
          LeadProcessStep(title: 'Call #1 - Follow-up Scheduled', date: '07 Oct 2026', time: '04:30 PM', note: 'Client requested call back on Friday at 3 PM', performedBy: 'Priya Patel', isCompleted: true),
        ],
      ),
      AdminLeadItem(
        id: 'LD-1094',
        customerName: 'Dr. Vikram Shah (HealthClinic)',
        phone: '+91 97234 56789',
        email: 'vikram.shah@healthclinic.org',
        source: 'Website',
        sourceColorHex: '0xFF10B981',
        assignedExecutive: 'Amit Verma',
        assignedExecutiveAvatar: '',
        isSelfGenerated: true,
        status: 'Converted',
        dateReceived: '06 Oct 2026',
        requirement: 'Custom Clinic Staff Attendance App',
        potentialValue: 210000,
        callAttempts: 6,
        lastCallDuration: '12m 30s',
        processSteps: [
          LeadProcessStep(title: 'Self Generated by Executive', date: '02 Oct 2026', time: '11:00 AM', note: 'Cold call outreach by Amit Verma', performedBy: 'Amit Verma', isCompleted: true),
          LeadProcessStep(title: 'Requirement Finalized', date: '04 Oct 2026', time: '03:45 PM', note: 'Custom doctors shift module agreed', performedBy: 'Amit Verma', isCompleted: true),
          LeadProcessStep(title: 'Advance Payment Received', date: '06 Oct 2026', time: '10:20 AM', note: '₹2.1L full payment cleared via NetBanking', performedBy: 'Finance (Riya)', isCompleted: true),
        ],
      ),
      AdminLeadItem(
        id: 'LD-1095',
        customerName: 'Vikrant Builders (On-Site Staff)',
        phone: '+91 99887 76655',
        email: 'info@vikrantbuilders.com',
        source: 'Google Ads',
        sourceColorHex: '0xFFEA4335',
        assignedExecutive: 'Rahul Sharma',
        assignedExecutiveAvatar: 'https://yellowgreen-stork-427223.hostingersite.com/storage/avatars/wiS1bnWjQxY81Zkn73BBwSEtNa8tFy6qWT5NpwhU.jpg',
        isSelfGenerated: false,
        status: 'New',
        dateReceived: '07 Oct 2026',
        requirement: 'GPS Field Staff Tracking System',
        potentialValue: 180000,
        callAttempts: 0,
        lastCallDuration: '0m',
        processSteps: [
          LeadProcessStep(title: 'Google Ads High-Intent Lead', date: '07 Oct 2026', time: '08:00 AM', note: 'Received from search ad targeting site attendance', performedBy: 'System Auto', isCompleted: true),
          LeadProcessStep(title: 'Assigned to Rahul Sharma', date: '07 Oct 2026', time: '08:05 AM', note: 'Pending first call outreach', performedBy: 'Admin (Ramesh)', isCompleted: false),
        ],
      ),
      AdminLeadItem(
        id: 'LD-1096',
        customerName: 'Rohan Deshmukh (Deshmukh Logistics)',
        phone: '+91 94220 11223',
        email: 'rohan@deshmukhlogistics.com',
        source: 'Referral',
        sourceColorHex: '0xFF8B5CF6',
        assignedExecutive: 'Neha Singh',
        assignedExecutiveAvatar: '',
        isSelfGenerated: true,
        status: 'Unreachable',
        dateReceived: '05 Oct 2026',
        requirement: 'Payroll Software Module',
        potentialValue: 60000,
        callAttempts: 5,
        lastCallDuration: '0m 40s',
        processSteps: [
          LeadProcessStep(title: 'Referral Received', date: '05 Oct 2026', time: '12:30 PM', note: 'Referred by existing customer Apex', performedBy: 'Neha Singh', isCompleted: true),
          LeadProcessStep(title: '5 Unanswered Calls', date: '07 Oct 2026', time: '05:00 PM', note: 'Switched off / out of coverage', performedBy: 'Neha Singh', isCompleted: false),
        ],
      ),
      AdminLeadItem(
        id: 'LD-1097',
        customerName: 'Pooja Enterprises (Retail Chain)',
        phone: '+91 93211 44556',
        email: 'contact@poojaent.in',
        source: 'Facebook Ads',
        sourceColorHex: '0xFF1877F2',
        assignedExecutive: 'Unassigned',
        assignedExecutiveAvatar: '',
        isSelfGenerated: false,
        status: 'New',
        dateReceived: '07 Oct 2026',
        requirement: 'Shift Scheduling & Overtime Tracker',
        potentialValue: 95000,
        callAttempts: 0,
        lastCallDuration: '0m',
        processSteps: [
          LeadProcessStep(title: 'New Facebook Lead Inbound', date: '07 Oct 2026', note: 'Fresh lead awaiting admin allocation', isCompleted: true),
        ],
      ),
      AdminLeadItem(
        id: 'LD-1098',
        customerName: 'Global Solutions (Delhi Office)',
        phone: '+91 91122 33445',
        email: 'sales@globalsolutions.com',
        source: 'Google Ads',
        sourceColorHex: '0xFFEA4335',
        assignedExecutive: 'Unassigned',
        assignedExecutiveAvatar: '',
        isSelfGenerated: false,
        status: 'New',
        dateReceived: '07 Oct 2026',
        requirement: 'Multi-location Attendance Portal',
        potentialValue: 150000,
        callAttempts: 0,
        lastCallDuration: '0m',
        processSteps: [
          LeadProcessStep(title: 'Google Ads Contact Form', date: '07 Oct 2026', note: 'High urgency request for 100+ employees', isCompleted: true),
        ],
      ),
      AdminLeadItem(
        id: 'LD-1099',
        customerName: 'Karan Malhotra',
        phone: '+91 90000 00000',
        email: 'invalid@number.com',
        source: 'JustDial',
        sourceColorHex: '0xFFF58220',
        assignedExecutive: 'Amit Verma',
        assignedExecutiveAvatar: '',
        isSelfGenerated: false,
        status: 'Wrong Number',
        dateReceived: '04 Oct 2026',
        requirement: 'General Inquiry',
        potentialValue: 0,
        callAttempts: 1,
        lastCallDuration: '0m 15s',
        processSteps: [
          LeadProcessStep(title: 'JustDial Auto Import', date: '04 Oct 2026', note: 'Phone number non-existent', isCompleted: true),
        ],
      ),
    ];
  }

  @override
  void dispose() {
    _mainTabController.dispose();
    _searchController.dispose();
    _teamSearchController.dispose();
    super.dispose();
  }

  // Filtered Leads for Option 2
  List<AdminLeadItem> get _filteredLeads {
    final query = _searchController.text.trim().toLowerCase();
    return _leadsList.where((lead) {
      final matchesQuery = lead.customerName.toLowerCase().contains(query) ||
          lead.phone.toLowerCase().contains(query) ||
          lead.id.toLowerCase().contains(query) ||
          lead.requirement.toLowerCase().contains(query);
      if (!matchesQuery) return false;

      // Allocation Category Filter
      if (_selectedLeadAllocationCategory == 'New (Unassigned)' && lead.assignedExecutive != 'Unassigned') {
        return false;
      }
      if (_selectedLeadAllocationCategory == 'Assigned' && lead.assignedExecutive == 'Unassigned') {
        return false;
      }

      // Source Filter
      if (_selectedSourceFilter != 'All' && lead.source != _selectedSourceFilter) {
        return false;
      }

      // Status Filter
      if (_selectedStatusFilter != 'All' && lead.status != _selectedStatusFilter) {
        return false;
      }
      return true;
    }).toList();
  }

  // Filtered Executives for Option 1
  List<SalesExecutivePerf> get _filteredExecutives {
    final query = _teamSearchController.text.trim().toLowerCase();
    if (query.isEmpty) return _executives;
    return _executives.where((exec) =>
      exec.name.toLowerCase().contains(query) ||
      exec.designation.toLowerCase().contains(query)
    ).toList();
  }

  int get _unassignedLeadsCount => _leadsList.where((l) => l.assignedExecutive == 'Unassigned').length;

  @override
  Widget build(BuildContext context) {
    final totalRevenue = _executives.fold<double>(0, (sum, item) => sum + item.revenue);
    final totalTarget = _executives.fold<double>(0, (sum, item) => sum + item.target);
    final overallProgress = totalTarget > 0 ? (totalRevenue / totalTarget * 100) : 0;
    final totalCalls = _executives.fold<int>(0, (sum, item) => sum + item.callsCount);
    final totalConverted = _executives.fold<int>(0, (sum, item) => sum + item.convertedLeads);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      // FAB (New Lead creation) is strictly visible ONLY on Leads Hub screen view
      floatingActionButton: _selectedModuleIndex == 1
          ? FloatingActionButton.extended(
              onPressed: () => Get.to(() => const SalesExecutiveCreateLeadScreen()),
              backgroundColor: AppColors.primaryColor,
              icon: const Icon(Iconsax.add, color: Colors.white, size: 20),
              label: const AppText('New Lead', color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
            )
          : null,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B), size: 18),
          onPressed: () {
            if (_selectedModuleIndex != null) {
              setState(() {
                _selectedModuleIndex = null;
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              _selectedModuleIndex == null
                  ? 'Sales Tele-CRM Admin'
                  : _selectedModuleIndex == 0
                      ? 'Sales Team'
                      : _selectedModuleIndex == 1
                          ? 'Leads Hub'
                          : _selectedModuleIndex == 2
                              ? 'Source Rules'
                              : 'Lead Statuses',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
            AppText(
              _selectedModuleIndex == null
                  ? 'Team Performance & Lead Source Allocation'
                  : 'CRM Admin Management Module',
              fontSize: 11,
              color: AppColors.textColorSecondary,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.headphone, color: AppColors.primaryColor, size: 20),
            tooltip: 'Open Sales Executive View',
            onPressed: () => Get.to(() => const SalesExecutiveTeleCrmScreen()),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // Global Performance Summary Banner
          _buildGlobalPerformanceBanner(totalRevenue, overallProgress.toDouble(), totalCalls, totalConverted),

          // Main Screen Content: 4 Vertical Cards Overview OR Module View
          if (_selectedModuleIndex == null)
            Expanded(
              child: _build4VerticalCardsDashboard(),
            )
          else
            // Responding screen view
            Expanded(
              child: TabBarView(
                controller: _mainTabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  // ── OPTION 1: SALES TEAM & WORK DASHBOARD ──
                  _buildSalesTeamOptionView(overallProgress.toDouble(), totalCalls, totalConverted),

                  // ── OPTION 2: MULTI-SOURCE LEADS ALLOCATION HUB ──
                  _buildLeadHubOptionView(),

                  // ── OPTION 3: LEAD SOURCE PRE-SET ASSIGNMENT RULES ──
                  _buildSourceRulesOptionView(),

                  // ── OPTION 4: ADMIN LEAD STATUSES MANAGEMENT (CRUD) ──
                  _buildManageStatusesOptionView(),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGlobalPerformanceBanner(double totalRevenue, double overallProgress, int totalCalls, int totalConverted) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: const Color(0xFF1E1B4B),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _buildTopHeaderMiniStat('Revenue', '₹${(totalRevenue / 100000).toStringAsFixed(1)}L', Colors.white),
              _buildTopHeaderDivider(),
              _buildTopHeaderMiniStat('Target Achieved', '${overallProgress.round()}%', const Color(0xFF34D399)),
              _buildTopHeaderDivider(),
              _buildTopHeaderMiniStat('Total Calls', '$totalCalls', const Color(0xFFC7D2FE)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF4338CA),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Iconsax.status_up, color: Colors.white, size: 12),
                const SizedBox(width: 4),
                AppText(
                  'Deals Closed: $totalConverted',
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 4 VERTICAL CARDS MAIN DASHBOARD VIEW ───────────────────────────────────

  Widget _build4VerticalCardsDashboard() {
    final navItems = [
      {
        'index': 0,
        'title': 'Sales Team',
        'subtitle': 'Monitor executive performance, talk-time & call logs',
        'stat': '${_executives.length} Active Executives',
        'icon': Iconsax.user_search,
        'color': AppColors.primaryColor,
        'lightColor': const Color(0xFFEEF2FF),
        'badge': null,
      },
      {
        'index': 1,
        'title': 'Leads Hub',
        'subtitle': 'View & assign inbound multi-source sales leads',
        'stat': '${_leadsList.length} Total Master Leads',
        'icon': Iconsax.task_square,
        'color': const Color(0xFF2563EB),
        'lightColor': const Color(0xFFEFF6FF),
        'badge': _unassignedLeadsCount > 0 ? '$_unassignedLeadsCount New' : null,
      },
      {
        'index': 2,
        'title': 'Source Rules',
        'subtitle': 'Google, FB Ads & JustDial auto-assignment rules',
        'stat': '${_sourceRules.length} Configured Rules',
        'icon': Iconsax.routing,
        'color': const Color(0xFF7C3AED),
        'lightColor': const Color(0xFFF5F3FF),
        'badge': null,
      },
      {
        'index': 3,
        'title': 'Lead Statuses',
        'subtitle': 'Manage lead pipeline stage tags & status CRUD',
        'stat': '${_leadStatuses.length} Active Statuses',
        'icon': Iconsax.category,
        'color': const Color(0xFF059669),
        'lightColor': const Color(0xFFECFDF5),
        'badge': null,
      },
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      children: [
        const AppText(
          'CRM Admin Modules',
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: Color(0xFF0F172A),
        ),
        const SizedBox(height: 2),
        const AppText(
          'Select a card below to open its responding screen',
          fontSize: 11.5,
          color: AppColors.textColorSecondary,
        ),
        const SizedBox(height: 16),
        ...navItems.map((item) {
          final itemIdx = item['index'] as int;
          final itemColor = item['color'] as Color;
          final lightColor = item['lightColor'] as Color;
          final title = item['title'] as String;
          final subtitle = item['subtitle'] as String;
          final stat = item['stat'] as String;
          final icon = item['icon'] as IconData;
          final badge = item['badge'] as String?;

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: itemColor.withValues(alpha: 0.08),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(18),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedModuleIndex = itemIdx;
                    _mainTabController.animateTo(itemIdx);
                  });
                },
                borderRadius: BorderRadius.circular(18),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: lightColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: itemColor.withValues(alpha: 0.2)),
                        ),
                        child: Icon(icon, color: itemColor, size: 26),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: AppText(
                                    title,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                                if (badge != null) ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEF4444),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      badge,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 3),
                            AppText(
                              subtitle,
                              fontSize: 11.5,
                              color: const Color(0xFF64748B),
                              maxLines: 2,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Iconsax.info_circle, size: 12, color: itemColor),
                                const SizedBox(width: 4),
                                AppText(
                                  stat,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: itemColor,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }



  Widget _buildTopHeaderMiniStat(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(label, fontSize: 9.5, color: const Color(0xFF94A3B8)),
        const SizedBox(height: 2),
        AppText(value, fontSize: 13, fontWeight: FontWeight.bold, color: valueColor),
      ],
    );
  }

  Widget _buildTopHeaderDivider() {
    return Container(
      height: 22,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: const Color(0xFF3730A3),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 👥 OPTION 1: SALES TEAM PERFORMANCE & EMPLOYEE DEEP DIVE VIEW
  // ───────────────────────────────────────────────────────────────────────────

  Widget _buildSalesTeamOptionView(double overallProgress, int totalCalls, int totalConverted) {
    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    'Sales Team Overview',
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                  SizedBox(height: 2),
                  AppText(
                    'Tap on any employee card to view their complete work, leads & call logs',
                    fontSize: 11,
                    color: AppColors.textColorSecondary,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: AppText(
                '${_executives.length} Executives',
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Team Search
        TextField(
          controller: _teamSearchController,
          onChanged: (val) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Search sales executive by name or role...',
            hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
            prefixIcon: const Icon(Iconsax.search_normal_1, size: 16, color: Color(0xFF64748B)),
            fillColor: Colors.white,
            filled: true,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Employees List Cards
        ..._filteredExecutives.map((exec) => _buildEmployeeListCard(exec)),
      ],
    );
  }

  Widget _buildEmployeeListCard(SalesExecutivePerf exec) {
    // Calculate leads assigned vs self brought for this employee from database
    final execLeads = _leadsList.where((l) => l.assignedExecutive == exec.name).toList();
    final assignedCount = execLeads.where((l) => !l.isSelfGenerated).length;
    final selfBroughtCount = execLeads.where((l) => l.isSelfGenerated).length;
    final convertedCount = execLeads.where((l) => l.status == 'Converted').length;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => Get.to(() => EmployeeLeadDetailScreen(exec: exec, leadsList: _leadsList)),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Avatar, Name, Designation & Click Hint
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primaryLight,
                    backgroundImage: exec.avatar.isNotEmpty ? NetworkImage(exec.avatar) : null,
                    child: exec.avatar.isEmpty
                        ? Icon(Iconsax.user, size: 20, color: AppColors.primaryColor)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            AppText(exec.name, fontSize: 14, fontWeight: FontWeight.bold),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDCFCE7),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: AppText(
                                '${exec.conversionRate.round()}% Conv Rate',
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF16A34A),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        AppText(exec.designation, fontSize: 11, color: AppColors.textColorSecondary),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF94A3B8)),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              const SizedBox(height: 12),

              // Work Performance Row: Revenue, Target Progress, Call Talk Time
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppText('Revenue Closed', fontSize: 10, color: AppColors.textColorSecondary),
                      const SizedBox(height: 2),
                      AppText(
                        '₹${(exec.revenue / 1000).toStringAsFixed(0)}k / ₹${(exec.target / 1000).toStringAsFixed(0)}k',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF15803D),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const AppText('Calls / Total Talk Time', fontSize: 10, color: AppColors.textColorSecondary),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Iconsax.call_calling, size: 12, color: AppColors.primaryColor),
                          const SizedBox(width: 4),
                          AppText(
                            '${exec.callsCount} calls (${exec.totalTalkTime})',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColorPrimary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Progress Bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText('Target Progress', fontSize: 10, color: AppColors.textColorSecondary),
                      AppText('${exec.targetPercentage.round()}% Achieved', fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: exec.targetPercentage / 100.0,
                      backgroundColor: const Color(0xFFE2E8F0),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Leads Summary Pill Badges: Assigned vs Self Generated
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                ),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Iconsax.folder_2, size: 14, color: Color(0xFF64748B)),
                        const SizedBox(width: 6),
                        AppText(
                          'Total Leads: ${execLeads.length}',
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: AppText('Admin Assigned: $assignedCount', fontSize: 10, fontWeight: FontWeight.w600, color: const Color(0xFF2563EB)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3E8FF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: AppText('Self Brought: $selfBroughtCount', fontSize: 10, fontWeight: FontWeight.w600, color: const Color(0xFF7C3AED)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: AppText('Converted: $convertedCount', fontSize: 10, fontWeight: FontWeight.w600, color: const Color(0xFF16A34A)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Employee Deep-Dive Detailed Modal/Sheet
  // Employee details are now shown in a separate full screen via EmployeeLeadDetailScreen

  Widget _buildEmployeeModalStat(String label, String value, Color color) {
    return Column(
      children: [
        AppText(value, fontSize: 13, fontWeight: FontWeight.bold, color: color),
        const SizedBox(height: 2),
        AppText(label, fontSize: 9.5, color: const Color(0xFFC7D2FE)),
      ],
    );
  }

  Widget _buildEmployeeModalDivider() {
    return Container(height: 20, width: 1, color: const Color(0xFF6366F1));
  }

  Widget _buildEmployeeLeadProcessCard(AdminLeadItem lead) {
    // Only show last 2 steps
    final displaySteps = lead.processSteps.length > 2
        ? lead.processSteps.sublist(lead.processSteps.length - 2)
        : lead.processSteps;

    return GestureDetector(
      onTap: () => Get.to(() => AdminLeadFullDetailScreen(lead: lead)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                  AppText(lead.id, fontSize: 10.5, color: AppColors.textColorHint, fontWeight: FontWeight.w600),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: lead.status == 'Converted'
                      ? const Color(0xFFDCFCE7)
                      : lead.status == 'Interested'
                          ? const Color(0xFFE0F2FE)
                          : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: AppText(
                  lead.status,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: lead.status == 'Converted'
                      ? const Color(0xFF16A34A)
                      : lead.status == 'Interested'
                          ? const Color(0xFF0369A1)
                          : const Color(0xFFD97706),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AppText(lead.customerName, fontSize: 13.5, fontWeight: FontWeight.bold),
          const SizedBox(height: 2),
          AppText('${lead.phone} • Requirement: ${lead.requirement}', fontSize: 11, color: AppColors.textColorSecondary),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 8),

          // Lead Process Steps History (Last 2 only)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const AppText('Recent Activity:', fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
              if (lead.processSteps.length > 2)
                const AppText('Tap to see full history', fontSize: 9, color: Color(0xFF94A3B8)),
            ],
          ),
          const SizedBox(height: 6),
          ...displaySteps.map((step) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(
                    step.isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                    size: 13,
                    color: step.isCompleted ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: AppText(step.title, fontSize: 10.5, fontWeight: FontWeight.w600)),
                          AppText('${step.date} ${step.time}'.trim(), fontSize: 9.5, color: AppColors.textColorHint),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.person_outline_rounded, size: 10, color: const Color(0xFF94A3B8)),
                          const SizedBox(width: 2),
                          AppText(step.performedBy.isNotEmpty ? step.performedBy : 'Unknown', fontSize: 9.5, color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
                        ],
                      ),
                      if (step.note.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        AppText(step.note, fontSize: 9.5, color: AppColors.textColorSecondary),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    ));
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 🎯 OPTION 2: MULTI-SOURCE LEADS ALLOCATION & MANAGEMENT HUB VIEW
  // ───────────────────────────────────────────────────────────────────────────

  Widget _buildLeadHubOptionView() {
    final newLeadsCount = _leadsList.where((l) => l.assignedExecutive == 'Unassigned').length;
    final assignedLeadsCount = _leadsList.where((l) => l.assignedExecutive != 'Unassigned').length;

    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      children: [
        // Top Banner Title & Allocation Summary Tabs (All, New, Assigned)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    'Multi-Source Leads Hub',
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                  SizedBox(height: 2),
                  AppText(
                    'View all incoming leads & assign to sales team in 1 click',
                    fontSize: 11,
                    color: AppColors.textColorSecondary,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: AppText(
                '$newLeadsCount New Unassigned',
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFDC2626),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Allocation Filter Segment (All vs New Unassigned vs Assigned)
        Row(
          children: [
            _buildAllocationSegmentChip('All', _leadsList.length),
            const SizedBox(width: 8),
            _buildAllocationSegmentChip('New (Unassigned)', newLeadsCount, isAlert: true),
            const SizedBox(width: 8),
            _buildAllocationSegmentChip('Assigned', assignedLeadsCount),
          ],
        ),
        const SizedBox(height: 12),

        // Search Field
        TextField(
          controller: _searchController,
          onChanged: (val) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Search lead by name, phone, requirement...',
            hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
            prefixIcon: const Icon(Iconsax.search_normal_1, size: 16, color: Color(0xFF64748B)),
            fillColor: Colors.white,
            filled: true,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Marketing Source Filter Chips (Google Ads, Facebook Ads, JustDial, Website, Referral)
        const AppText('Filter by Source Channel:', fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
        const SizedBox(height: 6),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _buildSourceFilterChip('All'),
              _buildSourceFilterChip('Google Ads', const Color(0xFFEA4335)),
              _buildSourceFilterChip('Facebook Ads', const Color(0xFF1877F2)),
              _buildSourceFilterChip('JustDial', const Color(0xFFF58220)),
              _buildSourceFilterChip('Website', const Color(0xFF10B981)),
              _buildSourceFilterChip('Referral', const Color(0xFF8B5CF6)),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Master Leads List
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
                  'No leads match the selected filter criteria',
                  color: AppColors.textColorSecondary,
                  fontSize: 13,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ..._filteredLeads.map((lead) => _buildAdminLeadCard(lead)),
      ],
    );
  }

  Widget _buildAllocationSegmentChip(String label, int count, {bool isAlert = false}) {
    final isSelected = _selectedLeadAllocationCategory == label;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedLeadAllocationCategory = label;
          });
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? (isAlert ? const Color(0xFFEF4444) : AppColors.primaryColor)
                : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? (isAlert ? const Color(0xFFEF4444) : AppColors.primaryColor)
                  : const Color(0xFFCBD5E1),
            ),
          ),
          child: Column(
            children: [
              AppText(
                label,
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF475569),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              AppText(
                '$count Leads',
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: isSelected ? Colors.white : (isAlert ? const Color(0xFFDC2626) : AppColors.textColorPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSourceFilterChip(String label, [Color? color]) {
    final isSelected = _selectedSourceFilter == label;
    final chipColor = color ?? AppColors.primaryColor;

    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        selected: isSelected,
        label: AppText(
          label,
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
          color: isSelected ? Colors.white : const Color(0xFF475569),
        ),
        backgroundColor: Colors.white,
        selectedColor: chipColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: isSelected ? chipColor : const Color(0xFFCBD5E1)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        onSelected: (val) {
          setState(() {
            _selectedSourceFilter = label;
          });
        },
      ),
    );
  }

  Widget _buildAdminLeadCard(AdminLeadItem lead) {
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
        statusBgColor = const Color(0xFFFEE2E8);
        break;
      default:
        statusColor = const Color(0xFF475569);
        statusBgColor = const Color(0xFFF1F5F9);
    }

    final sourceColor = Color(int.parse(lead.sourceColorHex));
    final isUnassigned = lead.assignedExecutive == 'Unassigned';

    return GestureDetector(
      onTap: () => Get.to(() => AdminLeadFullDetailScreen(lead: lead)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnassigned ? const Color(0xFFFCA5A5) : const Color(0xFFE2E8F0),
          width: isUnassigned ? 1.5 : 1.0,
        ),
        boxShadow: isUnassigned
            ? [
                BoxShadow(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
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
                      color: sourceColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: sourceColor.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          lead.source == 'Google Ads'
                              ? Icons.g_mobiledata
                              : lead.source == 'Facebook Ads'
                                  ? Icons.facebook
                                  : lead.source == 'Website'
                                      ? Icons.language
                                      : Iconsax.call,
                          size: 13,
                          color: sourceColor,
                        ),
                        const SizedBox(width: 4),
                        AppText(
                          lead.source,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: sourceColor,
                        ),
                      ],
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
          AppText(
            lead.customerName,
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.textColorPrimary,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Iconsax.call, size: 12, color: AppColors.textColorSecondary),
              const SizedBox(width: 4),
              AppText(lead.phone, fontSize: 11.5, color: AppColors.textColorSecondary),
              const SizedBox(width: 12),
              const Icon(Iconsax.directbox_notif, size: 12, color: AppColors.textColorSecondary),
              const SizedBox(width: 4),
              Expanded(
                child: AppText(
                  lead.email,
                  fontSize: 11.5,
                  color: AppColors.textColorSecondary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Iconsax.note_text, size: 13, color: AppColors.primaryColor),
                const SizedBox(width: 6),
                Expanded(
                  child: AppText(
                    lead.requirement,
                    fontSize: 11,
                    color:  const Color(0xFF334155),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                AppText(
                  '₹${(lead.potentialValue / 1000).toStringAsFixed(0)}k',
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF16A34A),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: isUnassigned ? const Color(0xFFFEE2E2) : AppColors.primaryLight,
                    backgroundImage: lead.assignedExecutiveAvatar.isNotEmpty
                        ? NetworkImage(lead.assignedExecutiveAvatar)
                        : null,
                    child: lead.assignedExecutiveAvatar.isEmpty
                        ? Icon(
                            isUnassigned ? Icons.warning_amber_rounded : Iconsax.user,
                            size: 12,
                            color: isUnassigned ? const Color(0xFFDC2626) : AppColors.primaryColor,
                          )
                        : null,
                  ),
                  const SizedBox(width: 6),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppText('Assigned Executive', fontSize: 8.5, color: AppColors.textColorHint),
                      AppText(
                        lead.assignedExecutive,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isUnassigned ? const Color(0xFFDC2626) : AppColors.textColorPrimary,
                      ),
                    ],
                  ),
                ],
              ),

              // Assign / Re-assign Action Button
              ElevatedButton.icon(
                onPressed: () => _showAssignLeadModal(context, lead),
                icon: Icon(
                  isUnassigned ? Iconsax.user_add : Iconsax.edit,
                  size: 13,
                  color: Colors.white,
                ),
                label: AppText(
                  isUnassigned ? 'Assign Lead' : 'Re-Assign',
                  fontSize: 11,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isUnassigned ? const Color(0xFFDC2626) : AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
         // ),
        ],
      ),
    ));
  }

  // One-Tap Lead Allocation Bottom Sheet Modal
  void _showAssignLeadModal(BuildContext context, AdminLeadItem lead) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AppText(
                'Assign Lead: ${lead.customerName}',
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 4),
              AppText(
                'Source: ${lead.source} • Potential Value: ₹${lead.potentialValue.round()}',
                fontSize: 11,
                color: AppColors.textColorSecondary,
              ),
              const SizedBox(height: 16),
              const AppText('Select Sales Executive to Assign:', fontSize: 12, fontWeight: FontWeight.bold),
              const SizedBox(height: 10),
              ..._executives.map((exec) {
                final isCurrent = lead.assignedExecutive == exec.name;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isCurrent ? AppColors.primaryLight : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isCurrent ? AppColors.primaryColor : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: ListTile(
                    dense: true,
                    leading: CircleAvatar(
                      radius: 14,
                      backgroundColor: AppColors.primaryLight,
                      backgroundImage: exec.avatar.isNotEmpty ? NetworkImage(exec.avatar) : null,
                      child: exec.avatar.isEmpty
                          ? Icon(Iconsax.user, size: 14, color: AppColors.primaryColor)
                          : null,
                    ),
                    title: AppText(exec.name, fontSize: 13, fontWeight: FontWeight.bold),
                    subtitle: AppText('${exec.designation} (${exec.convertedLeads} Deals Closed)', fontSize: 10),
                    trailing: isCurrent
                        ? const Icon(Icons.check_circle, color: AppColors.primaryColor, size: 18)
                        : null,
                    onTap: () {
                      setState(() {
                        lead.assignedExecutive = exec.name;
                        lead.assignedExecutiveAvatar = exec.avatar;
                      });
                      Navigator.pop(ctx);
                      Get.snackbar(
                        'Lead Assigned Successfully 🎯',
                        '${lead.customerName} assigned to ${exec.name}',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: const Color(0xFF10B981),
                        colorText: Colors.white,
                      );
                    },
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
  // ───────────────────────────────────────────────────────────────────────────
  // ⚙️ OPTION 3: LEAD SOURCE PRE-SET ASSIGNMENT RULES VIEW
  // ───────────────────────────────────────────────────────────────────────────

  Widget _buildSourceRulesOptionView() {
    final unassignedCount = _leadsList.where((l) => l.assignedExecutive == 'Unassigned').length;

    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      children: [
        // Header Banner & Quick Actions
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E1B4B), Color(0xFF312E81)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1E1B4B).withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
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
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          'Lead Source Assignment Rules',
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                        SizedBox(height: 2),
                        AppText(
                          'Configure auto-allocation rules per source',
                          fontSize: 11,
                          color: Color(0xFFC7D2FE),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _showAddEditSourceRuleModal(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF1E1B4B),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    icon: const Icon(Iconsax.add, size: 14),
                    label: const AppText('Add Rule', fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            '$unassignedCount Unassigned Leads Pending',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 2),
                          const AppText(
                            'Click button to distribute unassigned leads using pre-set rules',
                            fontSize: 10,
                            color: Color(0xFFE0E7FF),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _triggerAutoAssignUnassignedLeads,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Iconsax.flash, size: 14),
                      label: const AppText('Auto-Assign Now', fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        const AppText(
          'Configured Lead Sources & Assigned Employees:',
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1E293B),
        ),
        const SizedBox(height: 10),

        ..._sourceRules.map((rule) {
          final colorVal = Color(int.parse(rule.colorHex));
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: rule.isActive ? colorVal.withValues(alpha: 0.3) : const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
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
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(color: colorVal, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 8),
                        AppText(rule.sourceName, fontSize: 14.5, fontWeight: FontWeight.w800),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: colorVal.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: AppText(
                            rule.strategy,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: colorVal,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Transform.scale(
                          scale: 0.8,
                          child: Switch.adaptive(
                            value: rule.isActive,
                            activeColor: AppColors.primaryColor,
                            onChanged: (val) {
                              setState(() {
                                rule.isActive = val;
                              });
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Iconsax.edit_2, size: 16, color: Color(0xFF64748B)),
                          onPressed: () => _showAddEditSourceRuleModal(existingRule: rule),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 10),

                const AppText('Assigned Employees:', fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                const SizedBox(height: 6),
                if (rule.assignedExecutives.isEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const AppText(
                      'No employees assigned (Leads will remain unassigned)',
                      fontSize: 11,
                      color: Color(0xFFDC2626),
                    ),
                  )
                else
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: rule.assignedExecutives.map((execName) {
                      final exec = _executives.firstWhere(
                        (e) => e.name == execName,
                        orElse: () => SalesExecutivePerf(
                          name: execName,
                          avatar: '',
                          designation: 'Sales Rep',
                          revenue: 0,
                          target: 0,
                          callsCount: 0,
                          totalTalkTime: '',
                          avgTalkTime: '',
                          convertedLeads: 0,
                          totalLeadsAssigned: 0,
                          totalLeadsSelfGenerated: 0,
                        ),
                      );
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 9,
                              backgroundColor: AppColors.primaryLight,
                              backgroundImage: exec.avatar.isNotEmpty ? NetworkImage(exec.avatar) : null,
                              child: exec.avatar.isEmpty
                                  ? const Icon(Iconsax.user, size: 9, color: AppColors.primaryColor)
                                  : null,
                            ),
                            const SizedBox(width: 6),
                            AppText(execName, fontSize: 11.5, fontWeight: FontWeight.w700),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }

  void _showAddEditSourceRuleModal({SourceAssignRule? existingRule}) {
    final isEditing = existingRule != null;
    final sourceNameController = TextEditingController(text: existingRule?.sourceName ?? '');
    String selectedStrategy = existingRule?.strategy ?? 'Round-Robin';
    final List<String> selectedExecs = List<String>.from(existingRule?.assignedExecutives ?? []);

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
                      isEditing ? 'Edit Lead Source Rule' : 'Create New Lead Source Rule',
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                    const SizedBox(height: 4),
                    const AppText(
                      'Select which employees will receive leads from this marketing channel',
                      fontSize: 11,
                      color: AppColors.textColorSecondary,
                    ),
                    const SizedBox(height: 16),

                    // Source Name Field
                    const AppText('Lead Source Name:', fontSize: 12, fontWeight: FontWeight.bold),
                    const SizedBox(height: 6),
                    TextField(
                      controller: sourceNameController,
                      decoration: InputDecoration(
                        hintText: 'e.g. Google Ads, Facebook Ads, LinkedIn Ads',
                        hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                        fillColor: const Color(0xFFF8FAFC),
                        filled: true,
                        isDense: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Allocation Strategy Dropdown
                    const AppText('Allocation Strategy:', fontSize: 12, fontWeight: FontWeight.bold),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: selectedStrategy,
                      decoration: InputDecoration(
                        fillColor: const Color(0xFFF8FAFC),
                        filled: true,
                        isDense: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Round-Robin', child: Text('Round-Robin (Rotate sequentially among employees)')),
                        DropdownMenuItem(value: 'Multi-Executive', child: Text('Multi-Executive (Pool allocation)')),
                        DropdownMenuItem(value: 'Primary', child: Text('Primary Dedicated Executive')),
                      ],
                      onChanged: (val) {
                        if (val != null) setModalState(() => selectedStrategy = val);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Employees Multi-select Checkboxes
                    const AppText('Select Assigned Employee(s):', fontSize: 12, fontWeight: FontWeight.bold),
                    const SizedBox(height: 8),
                    ..._executives.map((exec) {
                      final isSelected = selectedExecs.contains(exec.name);
                      return CheckboxListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: AppColors.primaryLight,
                              backgroundImage: exec.avatar.isNotEmpty ? NetworkImage(exec.avatar) : null,
                              child: exec.avatar.isEmpty
                                  ? const Icon(Iconsax.user, size: 12, color: AppColors.primaryColor)
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            AppText(exec.name, fontSize: 13, fontWeight: FontWeight.bold),
                            const SizedBox(width: 6),
                            AppText('(${exec.designation})', fontSize: 11, color: AppColors.textColorSecondary),
                          ],
                        ),
                        value: isSelected,
                        activeColor: AppColors.primaryColor,
                        onChanged: (val) {
                          setModalState(() {
                            if (val == true) {
                              if (!selectedExecs.contains(exec.name)) selectedExecs.add(exec.name);
                            } else {
                              selectedExecs.remove(exec.name);
                            }
                          });
                        },
                      );
                    }),
                    const SizedBox(height: 20),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          final name = sourceNameController.text.trim();
                          if (name.isEmpty) {
                            Get.snackbar('Required Field', 'Please enter source name.', backgroundColor: const Color(0xFFEF4444), colorText: Colors.white);
                            return;
                          }
                          setState(() {
                            if (isEditing) {
                              existingRule.sourceName = name;
                              existingRule.strategy = selectedStrategy;
                              existingRule.assignedExecutives = selectedExecs;
                            } else {
                              _sourceRules.add(
                                SourceAssignRule(
                                  id: 'SR-0${_sourceRules.length + 1}',
                                  sourceName: name,
                                  colorHex: '0xFF3B82F6',
                                  assignedExecutives: selectedExecs,
                                  strategy: selectedStrategy,
                                  isActive: true,
                                ),
                              );
                            }
                          });
                          Navigator.pop(ctx);
                          Get.snackbar(
                            'Source Rule Saved 🎯',
                            'Rule for $name updated successfully.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: const Color(0xFF10B981),
                            colorText: Colors.white,
                          );
                        },
                        child: const AppText('Save Source Rule', color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
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

  // ───────────────────────────────────────────────────────────────────────────
  // 🏷️ OPTION 4: ADMIN LEAD STATUSES MANAGEMENT (CRUD)
  // ───────────────────────────────────────────────────────────────────────────

  Widget _buildManageStatusesOptionView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      children: [
        // Top Banner Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      'Lead Status Management (Admin)',
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                    SizedBox(height: 2),
                    AppText(
                      'Add, update, or delete lead status pipeline tags',
                      fontSize: 11,
                      color: Color(0xFF94A3B8),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => _showAddEditStatusModal(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Iconsax.add, size: 14),
                label: const AppText('Add Status', fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        const AppText(
          'Active Lead Statuses List:',
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1E293B),
        ),
        const SizedBox(height: 10),

        ..._leadStatuses.map((status) {
          final colorVal = Color(int.parse(status.colorHex));
          final leadsCount = _leadsList.where((l) => l.status == status.name).length;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: colorVal,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(color: colorVal.withValues(alpha: 0.4), blurRadius: 4),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          AppText(status.name, fontSize: 14, fontWeight: FontWeight.w800),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: colorVal.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: AppText(
                              status.category,
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              color: colorVal,
                            ),
                          ),
                        ],
                      ),
                      if (status.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        AppText(status.description, fontSize: 11, color: AppColors.textColorSecondary),
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
                  child: AppText(
                    '$leadsCount Leads',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF475569),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Iconsax.edit_2, size: 16, color: Color(0xFF64748B)),
                  onPressed: () => _showAddEditStatusModal(existingStatus: status),
                ),
                IconButton(
                  icon: const Icon(Iconsax.trash, size: 16, color: Color(0xFFEF4444)),
                  onPressed: () => _showDeleteStatusDialog(status),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  void _showAddEditStatusModal({AdminLeadStatusItem? existingStatus}) {
    final isEditing = existingStatus != null;
    final nameController = TextEditingController(text: existingStatus?.name ?? '');
    final descController = TextEditingController(text: existingStatus?.description ?? '');
    String selectedCategory = existingStatus?.category ?? 'Active Lead';
    String selectedHex = existingStatus?.colorHex ?? '0xFF3B82F6';

    final presetColors = [
      '0xFF3B82F6', // Blue
      '0xFF10B981', // Emerald Green
      '0xFFF59E0B', // Amber
      '0xFF6366F1', // Indigo
      '0xFF8B5CF6', // Purple
      '0xFF059669', // Dark Green
      '0xFFEF4444', // Red
      '0xFF64748B', // Slate
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
                    AppText(
                      isEditing ? 'Edit Lead Status' : 'Create New Lead Status',
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                    const SizedBox(height: 4),
                    const AppText(
                      'Define status name, tag color, and stage category for your sales workflow',
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
                        hintText: 'e.g. Interested, Follow-up, Converted, Unreachable',
                        hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                        fillColor: const Color(0xFFF8FAFC),
                        filled: true,
                        isDense: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Category Dropdown
                    const AppText('Category:', fontSize: 12, fontWeight: FontWeight.bold),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: InputDecoration(
                        fillColor: const Color(0xFFF8FAFC),
                        filled: true,
                        isDense: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Prospecting', child: Text('Prospecting (Initial stage)')),
                        DropdownMenuItem(value: 'Active Lead', child: Text('Active Lead (In negotiation)')),
                        DropdownMenuItem(value: 'Won', child: Text('Won / Closed Deal')),
                        DropdownMenuItem(value: 'Disqualified', child: Text('Disqualified / Invalid')),
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
                      decoration: InputDecoration(
                        hintText: 'Short description for sales team',
                        hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                        fillColor: const Color(0xFFF8FAFC),
                        filled: true,
                        isDense: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Color Picker Swatches
                    const AppText('Badge Tag Color:', fontSize: 12, fontWeight: FontWeight.bold),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: presetColors.map((hex) {
                        final colorVal = Color(int.parse(hex));
                        final isSelected = selectedHex == hex;
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

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          final name = nameController.text.trim();
                          if (name.isEmpty) {
                            Get.snackbar('Required Field', 'Please enter status name.', backgroundColor: const Color(0xFFEF4444), colorText: Colors.white);
                            return;
                          }
                          setState(() {
                            if (isEditing) {
                              final oldName = existingStatus.name;
                              existingStatus.name = name;
                              existingStatus.category = selectedCategory;
                              existingStatus.colorHex = selectedHex;
                              existingStatus.description = descController.text.trim();

                              // Cascade update to matching leads
                              for (var lead in _leadsList) {
                                if (lead.status == oldName) {
                                  lead.status = name;
                                }
                              }
                            } else {
                              _leadStatuses.add(
                                AdminLeadStatusItem(
                                  id: 'ST-0${_leadStatuses.length + 1}',
                                  name: name,
                                  colorHex: selectedHex,
                                  category: selectedCategory,
                                  description: descController.text.trim(),
                                ),
                              );
                            }
                          });
                          Navigator.pop(ctx);
                          Get.snackbar(
                            'Status Saved 🏷️',
                            'Status "$name" has been saved successfully.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: const Color(0xFF10B981),
                            colorText: Colors.white,
                          );
                        },
                        child: const AppText('Save Lead Status', color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
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

  void _showDeleteStatusDialog(AdminLeadStatusItem status) {
    final leadsUsingStatus = _leadsList.where((l) => l.status == status.name).toList();
    final otherStatuses = _leadStatuses.where((s) => s.id != status.id).toList();
    String fallbackStatusName = otherStatuses.isNotEmpty ? otherStatuses.first.name : 'New';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: AppText('Delete Status: ${status.name}', fontSize: 16, fontWeight: FontWeight.bold),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    'Are you sure you want to delete this lead status?',
                    fontSize: 13,
                    color: AppColors.textColorSecondary,
                  ),
                  if (leadsUsingStatus.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFECACA)),
                      ),
                      child: AppText(
                        '⚠️ ${leadsUsingStatus.length} lead(s) currently use this status! Select fallback status to migrate them:',
                        fontSize: 11,
                        color: const Color(0xFFDC2626),
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: fallbackStatusName,
                      decoration: InputDecoration(
                        fillColor: const Color(0xFFF8FAFC),
                        filled: true,
                        isDense: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      items: otherStatuses.map((s) => DropdownMenuItem(value: s.name, child: Text(s.name))).toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => fallbackStatusName = val);
                      },
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const AppText('Cancel', color: Color(0xFF64748B)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    setState(() {
                      // Migrate leads if any
                      for (var lead in leadsUsingStatus) {
                        lead.status = fallbackStatusName;
                      }
                      _leadStatuses.removeWhere((s) => s.id == status.id);
                    });
                    Navigator.pop(ctx);
                    Get.snackbar(
                      'Status Deleted 🗑️',
                      'Status removed successfully.',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: const Color(0xFFEF4444),
                      colorText: Colors.white,
                    );
                  },
                  child: const AppText('Delete Status', color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 📱 FULL SCREEN LEAD DETAIL VIEW (TREE FORMAT)
// ─────────────────────────────────────────────────────────────────────────────
class AdminLeadFullDetailScreen extends StatelessWidget {
  final AdminLeadItem lead;

  const AdminLeadFullDetailScreen({super.key, required this.lead});

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
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
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
                      AppText('${lead.customerName.toLowerCase().replaceAll(' ', '.')}@example.com', fontSize: 13, fontWeight: FontWeight.w600),
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
                      AppText('Source: ${lead.source}', fontSize: 13, fontWeight: FontWeight.w600),
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
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
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

class EmployeeLeadDetailScreen extends StatelessWidget {
  final SalesExecutivePerf exec;
  final List<AdminLeadItem> leadsList;

  const EmployeeLeadDetailScreen({super.key, required this.exec, required this.leadsList});

  @override
  Widget build(BuildContext context) {
    final execLeads = leadsList.where((l) => l.assignedExecutive == exec.name).toList();
    final assignedLeads = execLeads.where((l) => !l.isSelfGenerated).toList();
    final selfBroughtLeads = execLeads.where((l) => l.isSelfGenerated).toList();

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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primaryLight,
              backgroundImage: exec.avatar.isNotEmpty ? NetworkImage(exec.avatar) : null,
              child: exec.avatar.isEmpty
                  ? Icon(Iconsax.user, size: 16, color: AppColors.primaryColor)
                  : null,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(exec.name, fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                AppText(exec.designation, fontSize: 11, color: const Color(0xFF64748B)),
              ],
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        children: [
          // Stats Overview Banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF312E81), Color(0xFF4338CA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildEmployeeModalStat('Revenue', '₹${(exec.revenue / 1000).toStringAsFixed(0)}k', Colors.white),
                _buildEmployeeModalDivider(),
                _buildEmployeeModalStat('Target', '${exec.targetPercentage.round()}%', const Color(0xFF34D399)),
                _buildEmployeeModalDivider(),
                _buildEmployeeModalStat('Avg Talk', exec.avgTalkTime, const Color(0xFFC7D2FE)),
                _buildEmployeeModalDivider(),
                _buildEmployeeModalStat('Total Talk', exec.totalTalkTime, Colors.white),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Lead Source Breakdown Cards (Assigned vs Self Brought)
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Iconsax.card_send, size: 14, color: Color(0xFF2563EB)),
                          SizedBox(width: 4),
                          AppText('Admin Assigned', fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      AppText('${assignedLeads.length} Leads', fontSize: 15, fontWeight: FontWeight.w900, color: const Color(0xFF2563EB)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFDDD6FE)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Iconsax.user_edit, size: 14, color: Color(0xFF7C3AED)),
                          SizedBox(width: 4),
                          AppText('Self Brought', fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF5B21B6)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      AppText('${selfBroughtLeads.length} Leads', fontSize: 15, fontWeight: FontWeight.w900, color: const Color(0xFF7C3AED)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Detailed Leads Process Section Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const AppText(
                'Assigned & Managed Leads Process',
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
              AppText(
                '${execLeads.length} Active Leads',
                fontSize: 11,
                color: AppColors.textColorSecondary,
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (execLeads.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: AppText(
                  'No leads currently assigned to this executive',
                  fontSize: 12,
                  color: AppColors.textColorSecondary,
                ),
              ),
            )
          else
            ...execLeads.map((lead) => _EmployeeLeadProcessCard(lead: lead)),
        ],
      ),
    );
  }

  Widget _buildEmployeeModalStat(String label, String value, Color color) {
    return Column(
      children: [
        AppText(value, fontSize: 13, fontWeight: FontWeight.bold, color: color),
        const SizedBox(height: 2),
        AppText(label, fontSize: 9.5, color: const Color(0xFFC7D2FE)),
      ],
    );
  }

  Widget _buildEmployeeModalDivider() {
    return Container(height: 20, width: 1, color: const Color(0xFF6366F1));
  }
}

class _EmployeeLeadProcessCard extends StatelessWidget {
  final AdminLeadItem lead;

  const _EmployeeLeadProcessCard({required this.lead});

  @override
  Widget build(BuildContext context) {
    final displaySteps = lead.processSteps.length > 2
        ? lead.processSteps.sublist(lead.processSteps.length - 2)
        : lead.processSteps;

    return GestureDetector(
      onTap: () => Get.to(() => AdminLeadFullDetailScreen(lead: lead)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                    AppText(lead.id, fontSize: 10.5, color: AppColors.textColorHint, fontWeight: FontWeight.w600),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: lead.status == 'Converted'
                        ? const Color(0xFFDCFCE7)
                        : lead.status == 'Interested'
                            ? const Color(0xFFE0F2FE)
                            : const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: AppText(
                    lead.status,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: lead.status == 'Converted'
                        ? const Color(0xFF16A34A)
                        : lead.status == 'Interested'
                            ? const Color(0xFF0369A1)
                            : const Color(0xFFD97706),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            AppText(lead.customerName, fontSize: 13.5, fontWeight: FontWeight.bold),
            const SizedBox(height: 2),
            AppText('${lead.phone} • Requirement: ${lead.requirement}', fontSize: 11, color: AppColors.textColorSecondary),
            const SizedBox(height: 10),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const AppText('Recent Activity:', fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                if (lead.processSteps.length > 2)
                  const AppText('Tap to see full history', fontSize: 9, color: Color(0xFF94A3B8)),
              ],
            ),
            const SizedBox(height: 6),
            ...displaySteps.map((step) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(
                      step.isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                      size: 13,
                      color: step.isCompleted ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: AppText(step.title, fontSize: 10.5, fontWeight: FontWeight.w600)),
                            AppText('${step.date} ${step.time}'.trim(), fontSize: 9.5, color: AppColors.textColorHint),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(Icons.person_outline_rounded, size: 10, color: const Color(0xFF94A3B8)),
                            const SizedBox(width: 2),
                            AppText(step.performedBy.isNotEmpty ? step.performedBy : 'Unknown', fontSize: 9.5, color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
                          ],
                        ),
                        if (step.note.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          AppText(step.note, fontSize: 9.5, color: AppColors.textColorSecondary),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}

