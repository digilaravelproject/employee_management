import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import 'sales_executive_tele_crm_screen.dart';
import 'sales_executive_create_lead_screen.dart';
import '../bindings/admin_leads_hub_binding.dart';
import '../controllers/admin_leads_hub_controller.dart';
import '../models/admin_leads_request_model.dart';
import '../models/admin_leads_response_model.dart';
import '../models/sales_employee_model.dart';
import '../repositories/admin_leads_repository_interface.dart';
import 'package:url_launcher/url_launcher.dart';

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

  factory SalesExecutivePerf.fromSalesEmployee(SalesEmployeeModel emp) {
    return SalesExecutivePerf(
      name: emp.displayName,
      avatar: emp.avatar ?? '',
      designation: emp.displayDesignation,
      revenue: 0.0,
      target: emp.salesTarget > 0 ? emp.salesTarget : 500000.0,
      callsCount: 0,
      totalTalkTime: '0h 0m',
      avgTalkTime: '0m',
      convertedLeads: emp.dealsClosedCount,
      totalLeadsAssigned: emp.assignedLeadsCount,
      totalLeadsSelfGenerated: 0,
    );
  }
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
  late final AdminLeadsHubController _hubController;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<AdminLeadsHubController>()) {
      AdminLeadsHubBinding().dependencies();
    }
    _hubController = Get.find<AdminLeadsHubController>();
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
    _teamSearchController.dispose();
    super.dispose();
  }

  // Dynamic or fallback executives list
  List<SalesExecutivePerf> get _effectiveExecutivesList {
    if (Get.isRegistered<AdminLeadsHubController>()) {
      final ctrl = Get.find<AdminLeadsHubController>();
      if (ctrl.salesEmployees.isNotEmpty) {
        return ctrl.salesEmployees
            .map((emp) => SalesExecutivePerf.fromSalesEmployee(emp))
            .toList();
      }
    }
    return _executives;
  }

  // Filtered Executives for Option 1
  List<SalesExecutivePerf> get _filteredExecutives {
    final list = _effectiveExecutivesList;
    final query = _teamSearchController.text.trim().toLowerCase();
    if (query.isEmpty) return list;
    return list.where((exec) =>
      exec.name.toLowerCase().contains(query) ||
      exec.designation.toLowerCase().contains(query)
    ).toList();
  }

  int get _unassignedLeadsCount => _leadsList.where((l) => l.assignedExecutive == 'Unassigned').length;

  @override
  Widget build(BuildContext context) {
    final execs = _effectiveExecutivesList;
    final totalRevenue = execs.fold<double>(0, (sum, item) => sum + item.revenue);
    final totalTarget = execs.fold<double>(0, (sum, item) => sum + item.target);
    final overallProgress = totalTarget > 0 ? (totalRevenue / totalTarget * 100) : 0;
    final totalCalls = execs.fold<int>(0, (sum, item) => sum + item.callsCount);
    final totalConverted = execs.fold<int>(0, (sum, item) => sum + item.convertedLeads);

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
    return Obx(() {
      final summary = _hubController.summary.value;
      final totalLeadsCount = summary?.all ?? _leadsList.length;
      final unassignedLeads = summary?.unassigned ?? _unassignedLeadsCount;

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
          'stat': '$totalLeadsCount Total Master Leads',
          'icon': Iconsax.task_square,
          'color': const Color(0xFF2563EB),
          'lightColor': const Color(0xFFEFF6FF),
          'badge': unassignedLeads > 0 ? '$unassignedLeads New' : null,
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
    });
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



  // ───────────────────────────────────────────────────────────────────────────
  // 🎯 OPTION 2: MULTI-SOURCE LEADS ALLOCATION & MANAGEMENT HUB VIEW
  // ───────────────────────────────────────────────────────────────────────────

  Widget _buildLeadHubOptionView() {
    return Obx(() {
      final summary = _hubController.summary.value;
      final totalAllCount = summary?.all ?? _hubController.leadsList.length;
      final unassignedCount = summary?.unassigned ?? _hubController.leadsList.where((l) => !l.isAssigned).length;
      final assignedCount = summary?.assigned ?? _hubController.leadsList.where((l) => l.isAssigned).length;
      final currentAssignment = _hubController.selectedAssignment.value;
      final currentSource = _hubController.selectedSource.value;
      final currentStatus = _hubController.selectedStatus.value;
      final isLoading = _hubController.isLoading.value;
      final isLoadingMore = _hubController.isLoadingMore.value;
      final errorMessage = _hubController.errorMessage.value;
      final leads = _hubController.filteredLeads;

      return RefreshIndicator(
        onRefresh: () => _hubController.fetchLeads(isRefresh: true),
        color: AppColors.primaryColor,
        child: ListView(
          controller: _hubController.scrollController,
          padding: const EdgeInsets.all(16),
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
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
                    '$unassignedCount New Unassigned',
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
                _buildDynamicAllocationChip(
                  'All',
                  totalAllCount,
                  isSelected: currentAssignment == 'all',
                  onTap: () => _hubController.setAssignmentFilter('all'),
                ),
                const SizedBox(width: 8),
                _buildDynamicAllocationChip(
                  'New (Unassigned)',
                  unassignedCount,
                  isSelected: currentAssignment == 'unassigned',
                  isAlert: true,
                  onTap: () => _hubController.setAssignmentFilter('unassigned'),
                ),
                const SizedBox(width: 8),
                _buildDynamicAllocationChip(
                  'Assigned',
                  assignedCount,
                  isSelected: currentAssignment == 'assigned',
                  onTap: () => _hubController.setAssignmentFilter('assigned'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Search Field
            TextField(
              controller: _hubController.searchController,
              onChanged: (val) => _hubController.onSearchChanged(val),
              decoration: InputDecoration(
                hintText: 'Search lead by name, phone, code, requirement...',
                hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                prefixIcon: const Icon(Iconsax.search_normal_1, size: 16, color: Color(0xFF64748B)),
                suffixIcon: isLoading && _hubController.searchQuery.value.isNotEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryColor),
                        ),
                      )
                    : _hubController.searchQuery.value.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close, size: 16, color: Color(0xFF64748B)),
                            onPressed: () => _hubController.clearSearch(),
                          )
                        : null,
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
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Sleek Filter Bar: [ 🎛️ Filters ▾ ] + Quick/Active Shortcut Pills
            _buildLeadFiltersBar(context, currentSource, currentStatus, currentAssignment),
            const SizedBox(height: 14),

            // Error Message Banner with Retry
            if (errorMessage.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AppText(
                        errorMessage,
                        fontSize: 11.5,
                        color: const Color(0xFFB91C1C),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _hubController.fetchLeads(isRefresh: true),
                      child: const AppText('Retry', fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFFDC2626)),
                    ),
                  ],
                ),
              ),

            // Leads Content: Loading Skeleton / Empty State / Leads List
            if (isLoading)
              _buildLeadsLoadingSkeleton()
            else if (leads.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    const Icon(Iconsax.folder_open, size: 44, color: AppColors.textColorHint),
                    const SizedBox(height: 10),
                    const AppText(
                      'No leads match the selected filter criteria',
                      color: AppColors.textColorSecondary,
                      fontSize: 13,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 14),
                    OutlinedButton.icon(
                      onPressed: () => _hubController.resetAllFilters(),
                      icon: const Icon(Icons.refresh, size: 14, color: AppColors.primaryColor),
                      label: const AppText('Reset All Filters', fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primaryColor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              )
            else
              ...leads.map((lead) => _buildApiLeadCard(lead)),

            // Pagination Loading Indicator
            if (isLoadingMore)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryColor)),
                      SizedBox(width: 8),
                      AppText('Loading more leads...', fontSize: 11.5, color: AppColors.textColorSecondary),
                    ],
                  ),
                ),
              ),

            // Load More Button
            if (!isLoading && !isLoadingMore && _hubController.hasMorePages)
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 20),
                child: Center(
                  child: OutlinedButton.icon(
                    onPressed: () => _hubController.loadMoreLeads(),
                    icon: const Icon(Icons.arrow_downward_rounded, size: 14, color: AppColors.primaryColor),
                    label: AppText(
                      'Load More Leads (${_hubController.pagination.value?.currentPage}/${_hubController.pagination.value?.lastPage})',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      side: const BorderSide(color: AppColors.primaryColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildDynamicAllocationChip(
    String label,
    int count, {
    bool isAlert = false,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
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

  // ── FILTER BAR & BOTTOM SHEET MODAL ─────────────────────────────────────────

  Widget _buildLeadFiltersBar(
    BuildContext context,
    String currentSource,
    String currentStatus,
    String currentAssignment,
  ) {
    final bool hasStatusFilter = currentStatus != 'all';

    final sourceChannels = [
      {'key': 'all', 'label': 'All Channels', 'color': null},
      {'key': 'website', 'label': 'Website', 'color': const Color(0xFF10B981)},
      {'key': 'google_ads', 'label': 'Google Ads', 'color': const Color(0xFFEA4335)},
      {'key': 'facebook_ads', 'label': 'Facebook Ads', 'color': const Color(0xFF1877F2)},
      {'key': 'justdial', 'label': 'JustDial', 'color': const Color(0xFFF58220)},
      {'key': 'referral', 'label': 'Referral', 'color': const Color(0xFF8B5CF6)},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          // 1. [ 🎛️ Filters ▾ ] Button (styled exactly like the reference UI)
          GestureDetector(
            onTap: () => _showLeadsFilterBottomSheet(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7.5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: hasStatusFilter ? AppColors.primaryColor : const Color(0xFFCBD5E1),
                  width: hasStatusFilter ? 1.5 : 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 1.5),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.tune_rounded,
                    size: 15,
                    color: hasStatusFilter ? AppColors.primaryColor : const Color(0xFF1E293B),
                  ),
                  const SizedBox(width: 6),
                  AppText(
                    hasStatusFilter ? 'Filters (1)' : 'Filters',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: hasStatusFilter ? AppColors.primaryColor : const Color(0xFF1E293B),
                  ),
                  const SizedBox(width: 3),
                  Icon(
                    Icons.arrow_drop_down_rounded,
                    size: 19,
                    color: hasStatusFilter ? AppColors.primaryColor : const Color(0xFF475569),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // 2. Active status pill if status is filtered via BottomSheet
          if (hasStatusFilter) ...[
            _buildActiveFilterPill(
              label: 'Status: ${_getStatusLabel(currentStatus)}',
              onRemove: () => _hubController.setStatusFilter('all'),
              accentColor: _getStatusColor(currentStatus),
            ),
            const SizedBox(width: 8),
          ],

          // 3. Source Channel Tabs ONLY
          ...sourceChannels.map((item) {
            final key = item['key'] as String;
            final label = item['label'] as String;
            final color = item['color'] as Color?;
            return _buildSourceChannelTab(
              label: label,
              key: key,
              isSelected: currentSource == key,
              color: color,
              onTap: () => _hubController.setSourceFilter(key),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSourceChannelTab({
    required String label,
    required String key,
    required bool isSelected,
    required VoidCallback onTap,
    Color? color,
  }) {
    final chipColor = color ?? AppColors.primaryColor;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7.5),
          decoration: BoxDecoration(
            color: isSelected
                ? (key == 'all' ? AppColors.primaryColor : chipColor.withValues(alpha: 0.12))
                : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? (key == 'all' ? AppColors.primaryColor : chipColor)
                  : const Color(0xFFCBD5E1),
              width: isSelected ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (key != 'all') ...[
                Icon(
                  _getSourceIcon(key),
                  size: 13,
                  color: isSelected ? chipColor : const Color(0xFF64748B),
                ),
                const SizedBox(width: 5),
              ],
              AppText(
                label,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected
                    ? (key == 'all' ? Colors.white : chipColor)
                    : const Color(0xFF334155),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveFilterPill({
    required String label,
    required VoidCallback onRemove,
    Color? accentColor,
  }) {
    final color = accentColor ?? AppColors.primaryColor;
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 6, top: 5, bottom: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppText(label, fontSize: 11.5, fontWeight: FontWeight.bold, color: color),
          const SizedBox(width: 4),
          InkWell(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: Icon(Icons.close_rounded, size: 14, color: color),
            ),
          ),
        ],
      ),
    );
  }

  void _showLeadsFilterBottomSheet(BuildContext context) {
    final currentSource = _hubController.selectedSource.value;
    final currentStatus = _hubController.selectedStatus.value;
    final currentAssignment = _hubController.selectedAssignment.value;

    String tempSource = currentSource;
    String tempStatus = currentStatus;
    String tempAssignment = currentAssignment;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top drag handle
                  const SizedBox(height: 12),
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Title bar with "Filters" and "Reset"
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.tune_rounded, size: 18, color: AppColors.primaryColor),
                            ),
                            const SizedBox(width: 10),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText(
                                  'Filter Leads',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A),
                                ),
                                AppText(
                                  'Refine leads by source channel & pipeline stage',
                                  fontSize: 11,
                                  color: Color(0xFF64748B),
                                ),
                              ],
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            setModalState(() {
                              tempSource = 'all';
                              tempStatus = 'all';
                              tempAssignment = 'all';
                            });
                          },
                          child: const AppText(
                            'Reset All',
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFDC2626),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 20, color: Color(0xFFF1F5F9)),

                  // Scrollable filters content
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Source Channels Section
                          Row(
                            children: [
                              const Icon(Iconsax.global, size: 16, color: Color(0xFF475569)),
                              const SizedBox(width: 6),
                              const AppText(
                                'Marketing Source Channel',
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1E293B),
                              ),
                              if (tempSource != 'all') ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const AppText('Active', fontSize: 9.5, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildModalFilterChip(
                                label: 'All Channels',
                                icon: Icons.all_inclusive_rounded,
                                isSelected: tempSource == 'all',
                                onTap: () => setModalState(() => tempSource = 'all'),
                              ),
                              _buildModalFilterChip(
                                label: 'Website',
                                icon: Icons.language_rounded,
                                accentColor: const Color(0xFF10B981),
                                isSelected: tempSource == 'website',
                                onTap: () => setModalState(() => tempSource = 'website'),
                              ),
                              _buildModalFilterChip(
                                label: 'Google Ads',
                                icon: Icons.ads_click_rounded,
                                accentColor: const Color(0xFFEA4335),
                                isSelected: tempSource == 'google_ads',
                                onTap: () => setModalState(() => tempSource = 'google_ads'),
                              ),
                              _buildModalFilterChip(
                                label: 'Facebook Ads',
                                icon: Icons.campaign_rounded,
                                accentColor: const Color(0xFF1877F2),
                                isSelected: tempSource == 'facebook_ads',
                                onTap: () => setModalState(() => tempSource = 'facebook_ads'),
                              ),
                              _buildModalFilterChip(
                                label: 'JustDial',
                                icon: Icons.call_rounded,
                                accentColor: const Color(0xFFF58220),
                                isSelected: tempSource == 'justdial',
                                onTap: () => setModalState(() => tempSource = 'justdial'),
                              ),
                              _buildModalFilterChip(
                                label: 'Referral',
                                icon: Icons.people_outline_rounded,
                                accentColor: const Color(0xFF8B5CF6),
                                isSelected: tempSource == 'referral',
                                onTap: () => setModalState(() => tempSource = 'referral'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 22),

                          // 2. Pipeline Status Section
                          Row(
                            children: [
                              const Icon(Iconsax.chart_2, size: 16, color: Color(0xFF475569)),
                              const SizedBox(width: 6),
                              const AppText(
                                'Pipeline Status',
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1E293B),
                              ),
                              if (tempStatus != 'all') ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const AppText('Active', fontSize: 9.5, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildModalFilterChip(
                                label: 'All Status',
                                icon: Icons.list_alt_rounded,
                                isSelected: tempStatus == 'all',
                                onTap: () => setModalState(() => tempStatus = 'all'),
                              ),
                              _buildModalFilterChip(
                                label: 'New Leads',
                                icon: Icons.fiber_new_rounded,
                                accentColor: const Color(0xFF2563EB),
                                isSelected: tempStatus == 'new',
                                onTap: () => setModalState(() => tempStatus = 'new'),
                              ),
                              _buildModalFilterChip(
                                label: 'Interested',
                                icon: Icons.thumb_up_alt_outlined,
                                accentColor: const Color(0xFF16A34A),
                                isSelected: tempStatus == 'interested',
                                onTap: () => setModalState(() => tempStatus = 'interested'),
                              ),
                              _buildModalFilterChip(
                                label: 'Follow-up',
                                icon: Icons.access_time_rounded,
                                accentColor: const Color(0xFFD97706),
                                isSelected: tempStatus == 'follow_up',
                                onTap: () => setModalState(() => tempStatus = 'follow_up'),
                              ),
                              _buildModalFilterChip(
                                label: 'Converted',
                                icon: Icons.check_circle_outline_rounded,
                                accentColor: const Color(0xFF7C3AED),
                                isSelected: tempStatus == 'converted',
                                onTap: () => setModalState(() => tempStatus = 'converted'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 22),

                          // 3. Lead Allocation Section
                          Row(
                            children: [
                              const Icon(Iconsax.profile_2user, size: 16, color: Color(0xFF475569)),
                              const SizedBox(width: 6),
                              const AppText(
                                'Assignment Status',
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1E293B),
                              ),
                              if (tempAssignment != 'all') ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const AppText('Active', fontSize: 9.5, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildModalFilterChip(
                                label: 'All Allocation',
                                icon: Icons.groups_rounded,
                                isSelected: tempAssignment == 'all',
                                onTap: () => setModalState(() => tempAssignment = 'all'),
                              ),
                              _buildModalFilterChip(
                                label: 'New (Unassigned)',
                                icon: Icons.person_add_disabled_rounded,
                                accentColor: const Color(0xFFDC2626),
                                isSelected: tempAssignment == 'unassigned',
                                onTap: () => setModalState(() => tempAssignment = 'unassigned'),
                              ),
                              _buildModalFilterChip(
                                label: 'Assigned',
                                icon: Icons.assignment_turned_in_rounded,
                                accentColor: const Color(0xFF0D9488),
                                isSelected: tempAssignment == 'assigned',
                                onTap: () => setModalState(() => tempAssignment = 'assigned'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Action Buttons
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(modalContext),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              side: const BorderSide(color: Color(0xFFCBD5E1)),
                            ),
                            child: const AppText('Cancel', fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 3,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(modalContext);
                              _hubController.applyFilters(
                                source: tempSource,
                                status: tempStatus,
                                assignment: tempAssignment,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_rounded, size: 17, color: Colors.white),
                                SizedBox(width: 6),
                                AppText('Apply Filters', fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildModalFilterChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    Color? accentColor,
  }) {
    final activeColor = accentColor ?? AppColors.primaryColor;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withValues(alpha: 0.12) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? activeColor : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? activeColor : const Color(0xFF64748B),
            ),
            const SizedBox(width: 6),
            AppText(
              label,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? activeColor : const Color(0xFF334155),
            ),
            if (isSelected) ...[
              const SizedBox(width: 5),
              Icon(Icons.check_circle_rounded, size: 14, color: activeColor),
            ],
          ],
        ),
      ),
    );
  }


  String _getStatusLabel(String status) {
    switch (status) {
      case 'new':
        return 'New Leads';
      case 'interested':
        return 'Interested';
      case 'follow_up':
        return 'Follow-up';
      case 'converted':
        return 'Converted';
      default:
        return 'All Status';
    }
  }

  Widget _buildLeadsLoadingSkeleton() {
    return Column(
      children: List.generate(4, (index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 90,
                    height: 20,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  Container(
                    width: 60,
                    height: 18,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: 180,
                height: 16,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 140,
                height: 12,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildApiLeadCard(AdminLeadDataModel lead) {
    final isUnassigned = !lead.isAssigned;
    final sourceColor = _getSourceColor(lead.displaySource);
    final statusColor = _getStatusColor(lead.displayStatus);
    final statusBgColor = _getStatusBgColor(lead.displayStatus);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnassigned ? const Color(0xFFFCA5A5) : const Color(0xFFE2E8F0),
          width: isUnassigned ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isUnassigned
                ? const Color(0xFFEF4444).withValues(alpha: 0.06)
                : const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => Get.to(() => AdminLeadFullDetailScreen(apiLead: lead, leadId: lead.id)),
          onLongPress: () => _showApiLeadDetailModal(context, lead),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Source, Lead Code, Status Pill
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
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_getSourceIcon(lead.displaySource), size: 12, color: sourceColor),
                              const SizedBox(width: 4),
                              AppText(
                                lead.displaySource,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: sourceColor,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        AppText(
                          lead.displayLeadCode,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF64748B),
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
                        lead.displayStatus.toUpperCase(),
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Customer Name & Company
                AppText(
                  lead.displayName,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
                if (lead.displayCompany.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Iconsax.buildings, size: 12, color: Color(0xFF64748B)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: AppText(
                          lead.displayCompany,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF475569),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 8),

                // Contact Row: Phone & Email
                Row(
                  children: [
                    const Icon(Iconsax.call, size: 12, color: Color(0xFF64748B)),
                    const SizedBox(width: 4),
                    AppText(lead.displayPhone, fontSize: 11.5, color: const Color(0xFF475569)),
                    const SizedBox(width: 12),
                    const Icon(Iconsax.sms, size: 12, color: Color(0xFF64748B)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: AppText(
                        lead.displayEmail,
                        fontSize: 11.5,
                        color: const Color(0xFF475569),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Requirement & Value Box
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Iconsax.note_text, size: 13, color: AppColors.primaryColor),
                      const SizedBox(width: 6),
                      Expanded(
                        child: AppText(
                          lead.displayRequirement,
                          fontSize: 11,
                          color: const Color(0xFF334155),
                          fontWeight: FontWeight.w600,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (lead.estimatedValue != null)
                        AppText(
                          '₹${lead.estimatedValue}',
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF16A34A),
                        ),
                    ],
                  ),
                ),

                // Notes Snippet (2 lines + View more)
                if (lead.displayNotes.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Iconsax.message_text_1, size: 12, color: Color(0xFF64748B)),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              lead.displayNotes,
                              fontSize: 10.5,
                              color: const Color(0xFF64748B),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              height: 1.35,
                            ),
                            if (lead.displayNotes.length > 70 || lead.displayNotes.contains('\n')) ...[
                              const SizedBox(height: 2),
                              GestureDetector(
                                onTap: () => Get.to(() => AdminLeadFullDetailScreen(apiLead: lead, leadId: lead.id)),
                                child: const AppText(
                                  'View more',
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 10),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                const SizedBox(height: 10),

                // Footer Row: Executive Assignment & Action Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: isUnassigned ? const Color(0xFFFEE2E2) : AppColors.primaryLight,
                          child: Icon(
                            isUnassigned ? Icons.warning_amber_rounded : Iconsax.user,
                            size: 12,
                            color: isUnassigned ? const Color(0xFFDC2626) : AppColors.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const AppText('Assigned Executive', fontSize: 8.5, color: AppColors.textColorHint),
                            AppText(
                              lead.assignedExecutiveName,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isUnassigned ? const Color(0xFFDC2626) : AppColors.textColorPrimary,
                            ),
                          ],
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showAssignApiLeadModal(context, lead),
                      icon: Icon(
                        isUnassigned ? Iconsax.user_add : Iconsax.edit,
                        size: 12,
                        color: Colors.white,
                      ),
                      label: AppText(
                        isUnassigned ? 'Assign Lead' : 'Re-Assign',
                        fontSize: 10.5,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isUnassigned ? const Color(0xFFDC2626) : AppColors.primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Bottom Sheet: Full Lead Details ─────────────────────────────────────────
  void _showApiLeadDetailModal(BuildContext context, AdminLeadDataModel lead) {
    final sourceColor = _getSourceColor(lead.displaySource);
    final statusColor = _getStatusColor(lead.displayStatus);
    final statusBgColor = _getStatusBgColor(lead.displayStatus);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.88,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Drag indicator handle
            const SizedBox(height: 12),
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 14),

            // Modal Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: sourceColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: sourceColor.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_getSourceIcon(lead.displaySource), size: 14, color: sourceColor),
                            const SizedBox(width: 4),
                            AppText(
                              lead.displaySource,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: sourceColor,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      AppText(
                        lead.displayLeadCode,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF64748B),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: AppText(
                      lead.displayStatus.toUpperCase(),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),

            // Scrollable Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                physics: const BouncingScrollPhysics(),
                children: [
                  // Full Customer Name & Company
                  AppText(
                    lead.displayName,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                  if (lead.displayCompany.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Iconsax.buildings, size: 14, color: Color(0xFF64748B)),
                        const SizedBox(width: 6),
                        AppText(
                          lead.displayCompany,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF475569),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),

                  // Quick Action Buttons (Call, WhatsApp, Email)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (lead.displayPhone.isNotEmpty && lead.displayPhone != 'N/A') {
                              launchUrl(Uri.parse('tel:${lead.displayPhone}'));
                            }
                          },
                          icon: const Icon(Iconsax.call, size: 14, color: Colors.white),
                          label: const AppText('Call', fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (lead.displayEmail.isNotEmpty && lead.displayEmail != 'N/A') {
                              launchUrl(Uri.parse('mailto:${lead.displayEmail}'));
                            }
                          },
                          icon: const Icon(Iconsax.sms, size: 14, color: Colors.white),
                          label: const AppText('Email', fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Contact Details Card
                  _buildDetailSectionTitle('Contact Details', Iconsax.user_tag),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        _buildDetailItem(Iconsax.call, 'Phone Number', lead.displayPhone),
                        const Divider(height: 16, color: Color(0xFFE2E8F0)),
                        _buildDetailItem(Iconsax.sms, 'Email Address', lead.displayEmail),
                        if (lead.location != null && lead.location!.isNotEmpty) ...[
                          const Divider(height: 16, color: Color(0xFFE2E8F0)),
                          _buildDetailItem(Iconsax.location, 'Location', lead.location!),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Requirement & Financials Card
                  _buildDetailSectionTitle('Lead Requirement & Scope', Iconsax.document_text),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailItem(Iconsax.task, 'Requirement', lead.displayRequirement),
                        if (lead.estimatedValue != null) ...[
                          const Divider(height: 16, color: Color(0xFFE2E8F0)),
                          _buildDetailItem(Iconsax.coin, 'Estimated Value', '₹${lead.estimatedValue}'),
                        ],
                        if (lead.expectedClosingDate != null) ...[
                          const Divider(height: 16, color: Color(0xFFE2E8F0)),
                          _buildDetailItem(Iconsax.calendar_tick, 'Expected Closing Date', _formatDate(lead.expectedClosingDate)),
                        ],
                        if (lead.createdAt != null) ...[
                          const Divider(height: 16, color: Color(0xFFE2E8F0)),
                          _buildDetailItem(Iconsax.calendar_1, 'Received On', _formatDate(lead.createdAt)),
                        ],
                      ],
                    ),
                  ),

                  // Inquiry Notes Message Section
                  if (lead.displayNotes.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    _buildDetailSectionTitle('Inquiry Message / Notes', Iconsax.message_favorite),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFBBF7D0)),
                      ),
                      child: AppText(
                        lead.displayNotes,
                        fontSize: 12,
                        color: const Color(0xFF14532D),
                        height: 1.5,
                      ),
                    ),
                  ],

                  const SizedBox(height: 18),

                  // Current Assignment Card
                  _buildDetailSectionTitle('Sales Team Allocation', Iconsax.user_octagon),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: lead.isAssigned ? AppColors.primaryLight : const Color(0xFFFEE2E2),
                              child: Icon(
                                lead.isAssigned ? Iconsax.user : Icons.warning_amber_rounded,
                                size: 16,
                                color: lead.isAssigned ? AppColors.primaryColor : const Color(0xFFDC2626),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const AppText('Assigned Executive', fontSize: 10, color: AppColors.textColorHint),
                                AppText(
                                  lead.assignedExecutiveName,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: lead.isAssigned ? AppColors.textColorPrimary : const Color(0xFFDC2626),
                                ),
                              ],
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _showAssignApiLeadModal(context, lead);
                          },
                          icon: Icon(
                            lead.isAssigned ? Iconsax.edit : Iconsax.user_add,
                            size: 13,
                            color: Colors.white,
                          ),
                          label: AppText(
                            lead.isAssigned ? 'Re-Assign' : 'Assign Lead',
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: lead.isAssigned ? AppColors.primaryColor : const Color(0xFFDC2626),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.primaryColor),
        const SizedBox(width: 6),
        AppText(
          title,
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF0F172A),
        ),
      ],
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 13, color: const Color(0xFF64748B)),
        const SizedBox(width: 8),
        SizedBox(
          width: 110,
          child: AppText(label, fontSize: 11, color: const Color(0xFF64748B)),
        ),
        Expanded(
          child: AppText(
            value,
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  // ── Bottom Sheet: Assign / Re-Assign Executive to Lead with Notes ────────
  void _showAssignApiLeadModal(BuildContext context, AdminLeadDataModel lead) {
    final ctrl = Get.isRegistered<AdminLeadsHubController>()
        ? Get.find<AdminLeadsHubController>()
        : null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _LeadAssignmentBottomSheet(
        lead: lead,
        ctrl: ctrl,
      ),
    );
  }

  // ── Helper Color & Icon Mappers ─────────────────────────────────────────────
  Color _getSourceColor(String source) {
    final s = source.toLowerCase();
    if (s.contains('website')) return const Color(0xFF10B981);
    if (s.contains('google')) return const Color(0xFFEA4335);
    if (s.contains('facebook')) return const Color(0xFF1877F2);
    if (s.contains('justdial')) return const Color(0xFFF58220);
    if (s.contains('referral')) return const Color(0xFF8B5CF6);
    return AppColors.primaryColor;
  }

  IconData _getSourceIcon(String source) {
    final s = source.toLowerCase();
    if (s.contains('website')) return Icons.language;
    if (s.contains('google')) return Icons.g_mobiledata;
    if (s.contains('facebook')) return Icons.facebook;
    if (s.contains('justdial')) return Iconsax.call;
    return Iconsax.routing;
  }

  Color _getStatusColor(String status) {
    final s = status.toLowerCase();
    if (s == 'new') return const Color(0xFF2563EB);
    if (s == 'interested') return const Color(0xFF16A34A);
    if (s.contains('follow')) return const Color(0xFFD97706);
    if (s.contains('convert')) return const Color(0xFF7C3AED);
    if (s.contains('unreach')) return const Color(0xFF9333EA);
    if (s.contains('wrong')) return const Color(0xFFDC2626);
    return const Color(0xFF475569);
  }

  Color _getStatusBgColor(String status) {
    final s = status.toLowerCase();
    if (s == 'new') return const Color(0xFFEFF6FF);
    if (s == 'interested') return const Color(0xFFDCFCE7);
    if (s.contains('follow')) return const Color(0xFFFEF3C7);
    if (s.contains('convert')) return const Color(0xFFEDE9FE);
    if (s.contains('unreach')) return const Color(0xFFF3E8FF);
    if (s.contains('wrong')) return const Color(0xFFFEE2E8);
    return const Color(0xFFF1F5F9);
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return 'N/A';
    try {
      final dt = DateTime.parse(raw);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return raw;
    }
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
// ─────────────────────────────────────────────────────────────────────────────
// 📱 FULL SCREEN LEAD DETAIL VIEW (TREE FORMAT & API BACKED)
// ─────────────────────────────────────────────────────────────────────────────
class AdminLeadFullDetailScreen extends StatefulWidget {
  final AdminLeadItem? lead;
  final AdminLeadDataModel? apiLead;
  final dynamic leadId;

  const AdminLeadFullDetailScreen({
    super.key,
    this.lead,
    this.apiLead,
    this.leadId,
  });

  @override
  State<AdminLeadFullDetailScreen> createState() => _AdminLeadFullDetailScreenState();
}

class _AdminLeadFullDetailScreenState extends State<AdminLeadFullDetailScreen> {
  AdminLeadDataModel? _currentApiLead;
  bool _isLoading = false;
  String _errorMessage = '';
  bool _isNotesExpanded = false;

  @override
  void initState() {
    super.initState();
    _currentApiLead = widget.apiLead;
    final targetId = widget.leadId ?? widget.apiLead?.id;
    if (targetId != null) {
      _loadLeadDetail(targetId);
    }
  }

  Future<void> _loadLeadDetail(dynamic id) async {
    if (_currentApiLead == null) {
      setState(() => _isLoading = true);
    }
    try {
      final repository = Get.find<AdminLeadsRepositoryInterface>();
      final response = await repository.getAdminLeadDetail(id);
      if (response.status && response.data != null) {
        if (mounted) {
          setState(() {
            _currentApiLead = response.data;
            _isLoading = false;
            _errorMessage = '';
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
            if (_currentApiLead == null) {
              _errorMessage = response.message.isNotEmpty ? response.message : 'Failed to load lead details';
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          if (_currentApiLead == null) {
            _errorMessage = 'Error loading details: $e';
          }
        });
      }
    }
  }

  String _formatDateTime(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final period = dt.hour >= 12 ? 'PM' : 'AM';
      final minute = dt.minute.toString().padLeft(2, '0');
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}, $hour:$minute $period';
    } catch (_) {
      return dateStr;
    }
  }

  Color _getSourceColor(String source) {
    final s = source.toLowerCase();
    if (s.contains('website')) return const Color(0xFF10B981);
    if (s.contains('google')) return const Color(0xFFEA4335);
    if (s.contains('facebook')) return const Color(0xFF1877F2);
    if (s.contains('justdial')) return const Color(0xFFF58220);
    if (s.contains('referral')) return const Color(0xFF8B5CF6);
    return AppColors.primaryColor;
  }

  IconData _getSourceIcon(String source) {
    final s = source.toLowerCase();
    if (s.contains('website')) return Icons.language_rounded;
    if (s.contains('google')) return Icons.ads_click_rounded;
    if (s.contains('facebook')) return Icons.campaign_rounded;
    if (s.contains('justdial')) return Iconsax.call;
    return Iconsax.routing;
  }

  Color _getStatusColor(String status) {
    final s = status.toLowerCase();
    if (s == 'new') return const Color(0xFF2563EB);
    if (s == 'interested') return const Color(0xFF16A34A);
    if (s.contains('follow')) return const Color(0xFFD97706);
    if (s.contains('convert')) return const Color(0xFF7C3AED);
    return const Color(0xFF475569);
  }

  Color _getStatusBgColor(String status) {
    final s = status.toLowerCase();
    if (s == 'new') return const Color(0xFFEFF6FF);
    if (s == 'interested') return const Color(0xFFDCFCE7);
    if (s.contains('follow')) return const Color(0xFFFEF3C7);
    if (s.contains('convert')) return const Color(0xFFEDE9FE);
    return const Color(0xFFF1F5F9);
  }

  @override
  Widget build(BuildContext context) {
    final apiLead = _currentApiLead;
    final legacyLead = widget.lead;

    final customerName = apiLead?.displayName ?? legacyLead?.customerName ?? 'Lead Details';
    final leadCode = apiLead?.displayLeadCode ?? legacyLead?.id ?? '';
    final status = apiLead?.displayStatus ?? legacyLead?.status ?? 'new';
    final phone = apiLead?.displayPhone ?? legacyLead?.phone ?? 'N/A';
    final email = apiLead?.displayEmail ?? (legacyLead != null ? '${legacyLead.customerName.toLowerCase().replaceAll(' ', '.')}@example.com' : 'N/A');
    final requirement = apiLead?.displayRequirement ?? legacyLead?.requirement ?? 'General Inquiry';
    final source = apiLead?.displaySource ?? legacyLead?.source ?? 'Website';
    final company = apiLead?.displayCompany ?? '';
    final location = apiLead?.location ?? '';
    final notes = apiLead?.displayNotes ?? '';
    final estimatedValue = apiLead?.estimatedValue?.toString() ?? (legacyLead != null ? '₹${(legacyLead.potentialValue / 1000).toStringAsFixed(0)}k' : null);
    final expectedClosingDate = apiLead?.expectedClosingDate;
    final createdAt = apiLead?.createdAt;

    final sourceColor = _getSourceColor(source);
    final statusColor = _getStatusColor(status);
    final statusBgColor = _getStatusBgColor(status);

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
        title: AppText(
          leadCode.isNotEmpty ? 'Lead Details ($leadCode)' : 'Lead Details',
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF0F172A),
        ),
        centerTitle: true,
        actions: [
          if (widget.leadId != null || apiLead != null)
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Color(0xFF475569), size: 20),
              tooltip: 'Refresh',
              onPressed: () {
                final id = widget.leadId ?? apiLead?.id;
                if (id != null) _loadLeadDetail(id);
              },
            ),
        ],
      ),
      body: _isLoading && apiLead == null
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            )
          : _errorMessage.isNotEmpty && apiLead == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 40),
                        const SizedBox(height: 12),
                        AppText(_errorMessage, fontSize: 13, color: const Color(0xFFDC2626), textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            final id = widget.leadId ?? apiLead?.id;
                            if (id != null) _loadLeadDetail(id);
                          },
                          child: const AppText('Retry', color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
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
                            // Header Row: Avatar, Name, Lead Code, Status Pill
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: const Color(0xFFEFF6FF),
                                  child: Text(
                                    customerName.isNotEmpty ? customerName[0].toUpperCase() : 'L',
                                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      AppText(customerName, fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                                      const SizedBox(height: 3),
                                      if (company.isNotEmpty)
                                        AppText(company, fontSize: 12, color: const Color(0xFF64748B), fontWeight: FontWeight.w500)
                                      else
                                        AppText('Lead ID: $leadCode', fontSize: 12, color: const Color(0xFF64748B)),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusBgColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: AppText(
                                    status.toUpperCase(),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: statusColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Divider(height: 1, color: Color(0xFFF1F5F9)),
                            const SizedBox(height: 14),

                            // Quick Action Buttons (Call, Email)
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      if (phone.isNotEmpty && phone != 'N/A') {
                                        launchUrl(Uri.parse('tel:$phone'));
                                      }
                                    },
                                    icon: const Icon(Iconsax.call, size: 14, color: Colors.white),
                                    label: const AppText('Call', fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF10B981),
                                      padding: const EdgeInsets.symmetric(vertical: 9),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      elevation: 0,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      if (email.isNotEmpty && email != 'N/A') {
                                        launchUrl(Uri.parse('mailto:$email'));
                                      }
                                    },
                                    icon: const Icon(Iconsax.sms, size: 14, color: Colors.white),
                                    label: const AppText('Email', fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2563EB),
                                      padding: const EdgeInsets.symmetric(vertical: 9),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      elevation: 0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Phone & Email Rows
                            _buildInfoDetailRow(Icons.phone_rounded, 'Phone', phone),
                            const SizedBox(height: 10),
                            _buildInfoDetailRow(Icons.email_rounded, 'Email', email),
                            const SizedBox(height: 10),
                            _buildInfoDetailRow(Icons.assignment_rounded, 'Requirement', requirement),
                            if (location.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              _buildInfoDetailRow(Icons.location_on_rounded, 'Location', location),
                            ],
                            if (estimatedValue != null) ...[
                              const SizedBox(height: 10),
                              _buildInfoDetailRow(Icons.attach_money_rounded, 'Estimated Value', estimatedValue.startsWith('₹') ? estimatedValue : '₹$estimatedValue', valueColor: const Color(0xFF15803D)),
                            ],
                            if (expectedClosingDate != null) ...[
                              const SizedBox(height: 10),
                              _buildInfoDetailRow(Icons.event_rounded, 'Closing Date', _formatDateTime(expectedClosingDate)),
                            ],
                            const SizedBox(height: 10),
                            _buildInfoDetailRow(
                              _getSourceIcon(source),
                              'Source Channel',
                              source,
                              valueColor: sourceColor,
                            ),
                            if (createdAt != null) ...[
                              const SizedBox(height: 10),
                              _buildInfoDetailRow(Icons.access_time_rounded, 'Received On', _formatDateTime(createdAt)),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 2. Inquiry Description / Notes (with 2 lines & View more toggle)
                      if (notes.isNotEmpty) ...[
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
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Iconsax.note_2, size: 16, color: AppColors.primaryColor),
                                  SizedBox(width: 8),
                                  AppText(
                                    'Inquiry Notes / Description',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              AppText(
                                notes,
                                fontSize: 12.5,
                                color: const Color(0xFF334155),
                                height: 1.5,
                                maxLines: _isNotesExpanded ? null : 2,
                                overflow: _isNotesExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                              ),
                              if (notes.length > 70 || notes.contains('\n')) ...[
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isNotesExpanded = !_isNotesExpanded;
                                    });
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      AppText(
                                        _isNotesExpanded ? 'View less' : 'View more',
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryColor,
                                      ),
                                      const SizedBox(width: 3),
                                      Icon(
                                        _isNotesExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                                        size: 16,
                                        color: AppColors.primaryColor,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // 3. Source Payload / Form Submission Section (if present)
                      if (apiLead?.sourcePayload != null && apiLead!.sourcePayload!.isNotEmpty) ...[
                        _buildSourcePayloadSection(apiLead.sourcePayload!),
                        const SizedBox(height: 20),
                      ],

                      // 4. Process & Interactions History Tree
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
                                const Row(
                                  children: [
                                    Icon(Iconsax.clock, size: 16, color: AppColors.primaryColor),
                                    SizedBox(width: 8),
                                    AppText(
                                      'Process & Interactions History',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ],
                                ),
                                if (apiLead?.history.isNotEmpty == true)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEFF6FF),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: AppText(
                                      '${apiLead!.history.length} Event${apiLead.history.length > 1 ? 's' : ''}',
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF2563EB),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildHistoryTimeline(apiLead, legacyLead),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 5. Sales Team Allocation Card
                      if (apiLead != null)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
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
                              const Row(
                                children: [
                                  Icon(Iconsax.user_octagon, size: 16, color: AppColors.primaryColor),
                                  SizedBox(width: 8),
                                  AppText(
                                    'Sales Team Allocation',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 16,
                                        backgroundColor: apiLead.isAssigned ? AppColors.primaryLight : const Color(0xFFFEE2E2),
                                        child: Icon(
                                          apiLead.isAssigned ? Iconsax.user : Icons.warning_amber_rounded,
                                          size: 16,
                                          color: apiLead.isAssigned ? AppColors.primaryColor : const Color(0xFFDC2626),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const AppText('Assigned Executive', fontSize: 10, color: AppColors.textColorHint),
                                          AppText(
                                            apiLead.assignedExecutiveName,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: apiLead.isAssigned ? AppColors.textColorPrimary : const Color(0xFFDC2626),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      _showAssignModal(context, apiLead);
                                    },
                                    icon: Icon(
                                      apiLead.isAssigned ? Iconsax.edit : Iconsax.user_add,
                                      size: 13,
                                      color: Colors.white,
                                    ),
                                    label: AppText(
                                      apiLead.isAssigned ? 'Re-Assign' : 'Assign Lead',
                                      fontSize: 11,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: apiLead.isAssigned ? AppColors.primaryColor : const Color(0xFFDC2626),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
    );
  }

  Widget _buildHistoryTimeline(AdminLeadDataModel? apiLead, AdminLeadItem? legacyLead) {
    if (apiLead?.history.isNotEmpty == true) {
      final historyList = apiLead!.history;
      return Column(
        children: List.generate(historyList.length, (index) {
          final item = historyList[index];
          final isLast = index == historyList.length - 1;
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Tree Connector (Line & Dot)
                Column(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF10B981), width: 2),
                      ),
                      child: const Icon(Icons.check_rounded, size: 13, color: Colors.white),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: const Color(0xFF10B981).withValues(alpha: 0.5),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                // Step Content Card
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: AppText(
                                  item.title ?? 'Lead Event',
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              if (item.occurredAt != null)
                                AppText(
                                  _formatDateTime(item.occurredAt),
                                  fontSize: 10.5,
                                  color: const Color(0xFF64748B),
                                ),
                            ],
                          ),
                          if (item.actorName != null && item.actorName!.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                const Icon(Icons.person_outline_rounded, size: 12, color: Color(0xFF94A3B8)),
                                const SizedBox(width: 4),
                                AppText(
                                  item.actorName!,
                                  fontSize: 11,
                                  color: const Color(0xFF64748B),
                                  fontWeight: FontWeight.w500,
                                ),
                              ],
                            ),
                          ],
                          if (item.description != null && item.description!.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            AppText(
                              item.description!,
                              fontSize: 11.5,
                              color: const Color(0xFF475569),
                              height: 1.4,
                            ),
                          ],
                          if (item.metadata != null && item.metadata!.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: item.metadata!.entries.map((e) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: const Color(0xFFCBD5E1)),
                                  ),
                                  child: AppText(
                                    '${e.key}: ${e.value}',
                                    fontSize: 9.5,
                                    color: const Color(0xFF475569),
                                  ),
                                );
                              }).toList(),
                            ),
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
      );
    } else if (legacyLead != null && legacyLead.processSteps.isNotEmpty) {
      // Legacy dummy steps fallback
      final steps = legacyLead.processSteps;
      return Column(
        children: List.generate(steps.length, (index) {
          final step = steps[index];
          final isLast = index == steps.length - 1;
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: step.isCompleted ? const Color(0xFF10B981) : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: step.isCompleted ? const Color(0xFF10B981) : const Color(0xFFCBD5E1),
                          width: 2,
                        ),
                      ),
                      child: step.isCompleted
                          ? const Icon(Icons.check_rounded, size: 13, color: Colors.white)
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
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: AppText(step.title, fontSize: 13, fontWeight: FontWeight.bold)),
                              AppText('${step.date} ${step.time}'.trim(), fontSize: 10.5, color: const Color(0xFF64748B)),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Icon(Icons.person_outline_rounded, size: 12, color: Color(0xFF94A3B8)),
                              const SizedBox(width: 4),
                              AppText(step.performedBy.isNotEmpty ? step.performedBy : 'Unknown', fontSize: 11, color: const Color(0xFF64748B)),
                            ],
                          ),
                          if (step.note.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            AppText(step.note, fontSize: 11.5, color: const Color(0xFF475569)),
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
      );
    } else {
      // Default initial lead event
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              color: Color(0xFF10B981),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded, size: 13, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    'Lead Captured via ${apiLead?.displaySource ?? 'Inquiry'}',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 4),
                  AppText(
                    apiLead?.createdAt != null
                        ? 'Received on ${_formatDateTime(apiLead!.createdAt)}'
                        : 'Imported into CRM',
                    fontSize: 11,
                    color: const Color(0xFF64748B),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildSourcePayloadSection(Map<String, dynamic> payload) {
    final submission = payload['submission'] is Map ? payload['submission'] as Map : null;
    final fields = payload['fields'] is Map ? payload['fields'] as Map : null;

    return Container(
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
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Iconsax.global, size: 16, color: AppColors.primaryColor),
              SizedBox(width: 8),
              AppText(
                'Source Submission Details',
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (submission != null) ...[
            if (submission['form_name'] != null)
              _buildInfoDetailRow(Icons.description_outlined, 'Form Name', submission['form_name'].toString()),
            if (submission['referer'] != null) ...[
              const SizedBox(height: 8),
              _buildInfoDetailRow(Icons.link_rounded, 'Referer Page', submission['referer'].toString()),
            ],
            if (submission['user_ip'] != null) ...[
              const SizedBox(height: 8),
              _buildInfoDetailRow(Icons.computer_rounded, 'User IP', submission['user_ip'].toString()),
            ],
          ],
          if (fields != null && fields.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 10),
            const AppText('Submitted Form Values', fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
            const SizedBox(height: 6),
            ...fields.entries.where((e) => e.value != null && e.value.toString().isNotEmpty && e.key != 'message').map((e) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: AppText(e.key.toString(), fontSize: 10, fontWeight: FontWeight.w600, color: const Color(0xFF475569)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AppText(e.value.toString(), fontSize: 11.5, color: const Color(0xFF1E293B)),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoDetailRow(dynamic icon, String label, String value, {Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon is IconData)
          Icon(icon, size: 15, color: const Color(0xFF64748B))
        else if (icon is Widget)
          icon,
        const SizedBox(width: 8),
        SizedBox(
          width: 110,
          child: AppText(label, fontSize: 12, color: const Color(0xFF64748B)),
        ),
        Expanded(
          child: AppText(
            value,
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: valueColor ?? const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  void _showAssignModal(BuildContext context, AdminLeadDataModel lead) {
    final ctrl = Get.isRegistered<AdminLeadsHubController>()
        ? Get.find<AdminLeadsHubController>()
        : null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _LeadAssignmentBottomSheet(
        lead: lead,
        ctrl: ctrl,
        onSuccess: (emp, notes, res) {
          if (res.data != null) {
            setState(() {
              _currentApiLead = res.data;
            });
          } else {
            setState(() {
              _currentApiLead = _currentApiLead?.copyWith(
                assignedTo: emp.id,
                assignedEmployee: emp.displayName,
                notes: notes,
              );
            });
          }
          // Reload details to get new timeline event
          _loadLeadDetail(lead.id);
        },
      ),
    );
  }
}

// ── Bottom Sheet: Assign / Re-Assign Executive with Custom Notes ────────────
class _LeadAssignmentBottomSheet extends StatefulWidget {
  final AdminLeadDataModel lead;
  final AdminLeadsHubController? ctrl;
  final void Function(SalesEmployeeModel employee, String notes, AdminLeadDetailResponseModel response)? onSuccess;

  const _LeadAssignmentBottomSheet({
    required this.lead,
    this.ctrl,
    this.onSuccess,
  });

  @override
  State<_LeadAssignmentBottomSheet> createState() => _LeadAssignmentBottomSheetState();
}

class _LeadAssignmentBottomSheetState extends State<_LeadAssignmentBottomSheet> {
  SalesEmployeeModel? _selectedEmployee;
  late final TextEditingController _notesController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final defaultNote = widget.lead.isAssigned
        ? 'Re-assigned for follow-up and deal progress.'
        : 'Assigned for initial discovery call.';
    _notesController = TextEditingController(text: defaultNote);

    final ctrl = widget.ctrl;
    if (ctrl != null) {
      if (ctrl.salesEmployees.isEmpty) {
        ctrl.fetchSalesEmployees();
      } else {
        _autoSelectAssignedEmployee(ctrl.salesEmployees);
      }
    }
  }

  void _autoSelectAssignedEmployee(List<SalesEmployeeModel> list) {
    for (final emp in list) {
      if (emp.id.toString() == widget.lead.assignedTo?.toString() ||
          emp.displayName.toLowerCase() == widget.lead.assignedExecutiveName.toLowerCase()) {
        _selectedEmployee = emp;
        _notesController.text = widget.lead.isAssigned
            ? 'Re-assigned to ${emp.displayName} for follow-up and deal progress.'
            : 'Assigned to ${emp.displayName} for initial discovery call.';
        break;
      }
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _selectEmployee(SalesEmployeeModel emp) {
    setState(() {
      _selectedEmployee = emp;
      if (_notesController.text.isEmpty ||
          _notesController.text.contains('discovery call') ||
          _notesController.text.contains('deal progress')) {
        _notesController.text = widget.lead.isAssigned
            ? 'Re-assigned to ${emp.displayName} for follow-up and deal progress.'
            : 'Assigned to ${emp.displayName} for initial discovery call.';
      }
    });
  }

  Future<void> _handleConfirm() async {
    if (_selectedEmployee == null) {
      Get.snackbar(
        'Executive Required',
        'Please select a sales executive before confirming.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFF59E0B),
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final notes = _notesController.text.trim().isNotEmpty
        ? _notesController.text.trim()
        : (widget.lead.isAssigned
            ? 'Re-assigned to ${_selectedEmployee!.displayName} for follow-up.'
            : 'Assigned to ${_selectedEmployee!.displayName} for initial discovery call.');

    final assignRequest = AssignLeadRequestModel(
      employeeId: _selectedEmployee!.id,
      notes: notes,
    );

    try {
      AdminLeadDetailResponseModel res;
      if (widget.ctrl != null) {
        res = await widget.ctrl!.assignLead(widget.lead.id, assignRequest);
      } else {
        final repo = Get.find<AdminLeadsRepositoryInterface>();
        res = await repo.assignLead(widget.lead.id, assignRequest);
      }

      if (res.status) {
        if (mounted) Navigator.pop(context);
        if (widget.onSuccess != null) {
          widget.onSuccess!(_selectedEmployee!, notes, res);
        }
        Get.snackbar(
          'Lead Assigned Successfully 🎯',
          res.message.isNotEmpty
              ? res.message
              : '${widget.lead.displayName} assigned to ${_selectedEmployee!.displayName}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Assignment Failed',
          res.message.isNotEmpty ? res.message : 'Failed to assign lead',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFEF4444),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to assign lead: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Widget _buildChip(String label) {
    return InkWell(
      onTap: () {
        final empName = _selectedEmployee?.displayName ?? 'executive';
        setState(() {
          _notesController.text = widget.lead.isAssigned
              ? 'Re-assigned to $empName: $label.'
              : 'Assigned to $empName: $label.';
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFCBD5E1)),
        ),
        child: AppText(
          label,
          fontSize: 11,
          color: const Color(0xFF475569),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isReassign = widget.lead.isAssigned;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 14,
        left: 20,
        right: 20,
        bottom: bottomInset + 18,
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: isReassign
                      ? const Color(0xFFEFF6FF)
                      : const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isReassign ? Iconsax.user_edit : Iconsax.user_add,
                  color: isReassign
                      ? const Color(0xFF2563EB)
                      : const Color(0xFF059669),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      isReassign ? 'Re-Assign Lead' : 'Assign Lead',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    const SizedBox(height: 2),
                    AppText(
                      widget.lead.displayName,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColorSecondary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: AppText(
                  widget.lead.displayLeadCode,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF475569),
                ),
              ),
            ],
          ),

          // Current Assignment Info (if reassignment)
          if (isReassign) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Row(
                children: [
                  const Icon(Iconsax.info_circle, size: 15, color: Color(0xFFD97706)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AppText(
                      'Currently assigned to: ${widget.lead.assignedExecutiveName}',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFB45309),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 14),

          // Scrollable body
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Select Executive Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const AppText(
                        'Select Sales Executive *',
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                      ),
                      if (widget.ctrl != null)
                        InkWell(
                          onTap: () => widget.ctrl!.fetchSalesEmployees(),
                          borderRadius: BorderRadius.circular(6),
                          child: const Padding(
                            padding: EdgeInsets.all(4),
                            child: Row(
                              children: [
                                Icon(Icons.refresh_rounded, size: 14, color: AppColors.primaryColor),
                                SizedBox(width: 3),
                                AppText('Refresh', fontSize: 11, color: AppColors.primaryColor, fontWeight: FontWeight.bold),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Executives List
                  if (widget.ctrl != null)
                    Obx(() {
                      final employees = widget.ctrl!.salesEmployees;
                      final isLoading = widget.ctrl!.isLoadingSalesEmployees.value;

                      if (isLoading && employees.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      if (employees.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: const AppText(
                            'No sales executives found. Please refresh.',
                            fontSize: 12,
                            color: AppColors.textColorSecondary,
                          ),
                        );
                      }

                      return Column(
                        children: employees.map((emp) {
                          final isSelected = _selectedEmployee?.id == emp.id;
                          final isCurrentOwner = widget.lead.assignedTo?.toString() == emp.id.toString() ||
                              widget.lead.assignedExecutiveName.toLowerCase() == emp.displayName.toLowerCase();

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primaryLight : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? AppColors.primaryColor : const Color(0xFFE2E8F0),
                                width: isSelected ? 1.5 : 1.0,
                              ),
                            ),
                            child: ListTile(
                              dense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                              leading: CircleAvatar(
                                radius: 17,
                                backgroundColor: isSelected ? AppColors.primaryColor : AppColors.primaryLight,
                                backgroundImage: (emp.avatar != null && emp.avatar!.isNotEmpty)
                                    ? NetworkImage(emp.avatar!)
                                    : null,
                                child: (emp.avatar == null || emp.avatar!.isEmpty)
                                    ? Icon(
                                        Iconsax.user,
                                        size: 16,
                                        color: isSelected ? Colors.white : AppColors.primaryColor,
                                      )
                                    : null,
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: AppText(
                                      emp.displayName,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? AppColors.primaryColor : const Color(0xFF1E293B),
                                    ),
                                  ),
                                  if (isCurrentOwner)
                                    Container(
                                      margin: const EdgeInsets.only(right: 6),
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFEF3C7),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const AppText(
                                        'Current',
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFB45309),
                                      ),
                                    ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEEF2FF),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: AppText(
                                      emp.displayEmployeeId,
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF4F46E5),
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: AppText(
                                '${emp.displayDesignation} • ${emp.dealsClosedCount} Closed • ${emp.assignedLeadsCount} Leads',
                                fontSize: 10.5,
                                color: const Color(0xFF64748B),
                              ),
                              trailing: Icon(
                                isSelected ? Icons.check_circle_rounded : Icons.radio_button_off_rounded,
                                color: isSelected ? AppColors.primaryColor : const Color(0xFFCBD5E1),
                                size: 20,
                              ),
                              onTap: () => _selectEmployee(emp),
                            ),
                          );
                        }).toList(),
                      );
                    }),

                  const SizedBox(height: 14),

                  // Assignment Notes Section
                  Row(
                    children: [
                      const Icon(Iconsax.note_text, size: 16, color: AppColors.primaryColor),
                      const SizedBox(width: 6),
                      const AppText(
                        'Assignment Notes',
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const AppText(
                          'Included in API',
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _notesController,
                    maxLines: 3,
                    minLines: 2,
                    style: const TextStyle(fontSize: 12.5, color: Color(0xFF1E293B)),
                    decoration: InputDecoration(
                      hintText: 'e.g. Assigned to Rahul for initial discovery call.',
                      hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.all(12),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Quick Suggestion Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildChip('Initial discovery call'),
                        const SizedBox(width: 6),
                        _buildChip('Urgent follow-up'),
                        const SizedBox(width: 6),
                        _buildChip('High priority client'),
                        const SizedBox(width: 6),
                        _buildChip('Product demo requested'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),
                ],
              ),
            ),
          ),

          // Bottom Action Button
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: (_selectedEmployee == null || _isSubmitting)
                  ? null
                  : _handleConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                disabledBackgroundColor: const Color(0xFFCBD5E1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isReassign ? Iconsax.user_edit : Iconsax.user_add,
                          size: 17,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        AppText(
                          isReassign ? 'Confirm Re-Assignment' : 'Confirm Assignment',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ],
                    ),
            ),
          ),
        ],
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

