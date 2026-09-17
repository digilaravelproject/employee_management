import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/controllers/app_controller.dart';
import '../../role_permissions/models/role_permission_models.dart';
import '../models/lead_model.dart';
import '../models/bde_target_model.dart';

class BdeLeaderboardItem {
  final BdeTargetModel target;
  final double achievedAmount;
  final int wonDealsCount;
  final double completionPercentage;

  const BdeLeaderboardItem({
    required this.target,
    required this.achievedAmount,
    required this.wonDealsCount,
    required this.completionPercentage,
  });
}

class BdeLeadsController extends GetxController {
  // Available Months for filtering
  final List<String> availableMonths = [
    'September 2026',
    'August 2026',
    'July 2026',
    'June 2026',
  ];

  final selectedMonth = 'September 2026'.obs;

  // Active perspective: 'employee' or 'manager'
  final activeView = 'employee'.obs;

  // Currently logged-in executive (for employee view)
  final currentEmployeeEmail = 'rahul.sharma@company.com'.obs;

  // Pipeline Filter tab: 'All', 'In Pipeline', 'Closed Won', 'Lost'
  final selectedStageFilter = 'All'.obs;

  // Monthly targets per BDE
  final targets = <BdeTargetModel>[].obs;

  // All Leads in repository
  final allLeads = <Lead>[].obs;

  // Standard Sales Executives list
  final List<AppUser> salesExecutives = [
    const AppUser(
      name: 'Rahul Sharma',
      email: 'rahul.sharma@company.com',
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&auto=format&fit=crop&q=80',
    ),
    const AppUser(
      name: 'Neha Verma',
      email: 'neha.verma@company.com',
      avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150&auto=format&fit=crop&q=80',
    ),
    const AppUser(
      name: 'Aman Khan',
      email: 'aman.khan@company.com',
      avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150&auto=format&fit=crop&q=80',
    ),
    const AppUser(
      name: 'Pooja Singh',
      email: 'pooja.singh@company.com',
      avatarUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150&auto=format&fit=crop&q=80',
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    _initRole();
    _seedTargets();
    _seedLeads();
  }

  void _initRole() {
    if (Get.isRegistered<AppController>()) {
      final role = Get.find<AppController>().userRole.value.toLowerCase();
      if (role == 'admin' || role == 'manager') {
        activeView.value = 'manager';
      } else {
        activeView.value = 'employee';
      }
    }
  }

  void _seedTargets() {
    targets.assignAll([
      // September 2026 Targets
      const BdeTargetModel(
        id: 'T-SEP-01',
        employeeName: 'Rahul Sharma',
        employeeEmail: 'rahul.sharma@company.com',
        avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&auto=format&fit=crop&q=80',
        month: 'September 2026',
        targetAmount: 500000.0,
        targetDealsCount: 8,
      ),
      const BdeTargetModel(
        id: 'T-SEP-02',
        employeeName: 'Neha Verma',
        employeeEmail: 'neha.verma@company.com',
        avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150&auto=format&fit=crop&q=80',
        month: 'September 2026',
        targetAmount: 450000.0,
        targetDealsCount: 7,
      ),
      const BdeTargetModel(
        id: 'T-SEP-03',
        employeeName: 'Aman Khan',
        employeeEmail: 'aman.khan@company.com',
        avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150&auto=format&fit=crop&q=80',
        month: 'September 2026',
        targetAmount: 350000.0,
        targetDealsCount: 6,
      ),
      const BdeTargetModel(
        id: 'T-SEP-04',
        employeeName: 'Pooja Singh',
        employeeEmail: 'pooja.singh@company.com',
        avatarUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150&auto=format&fit=crop&q=80',
        month: 'September 2026',
        targetAmount: 400000.0,
        targetDealsCount: 6,
      ),

      // August 2026 Targets
      const BdeTargetModel(
        id: 'T-AUG-01',
        employeeName: 'Rahul Sharma',
        employeeEmail: 'rahul.sharma@company.com',
        avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&auto=format&fit=crop&q=80',
        month: 'August 2026',
        targetAmount: 450000.0,
        targetDealsCount: 7,
      ),
      const BdeTargetModel(
        id: 'T-AUG-02',
        employeeName: 'Neha Verma',
        employeeEmail: 'neha.verma@company.com',
        avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150&auto=format&fit=crop&q=80',
        month: 'August 2026',
        targetAmount: 400000.0,
        targetDealsCount: 6,
      ),
      const BdeTargetModel(
        id: 'T-AUG-03',
        employeeName: 'Aman Khan',
        employeeEmail: 'aman.khan@company.com',
        avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150&auto=format&fit=crop&q=80',
        month: 'August 2026',
        targetAmount: 300000.0,
        targetDealsCount: 5,
      ),
      const BdeTargetModel(
        id: 'T-AUG-04',
        employeeName: 'Pooja Singh',
        employeeEmail: 'pooja.singh@company.com',
        avatarUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150&auto=format&fit=crop&q=80',
        month: 'August 2026',
        targetAmount: 350000.0,
        targetDealsCount: 5,
      ),
    ]);
  }

  void _seedLeads() {
    final rahul = salesExecutives[0];
    final neha = salesExecutives[1];
    final aman = salesExecutives[2];
    final pooja = salesExecutives[3];

    allLeads.assignAll([
      // ──────── SEPTEMBER 2026 LEADS (RAHUL SHARMA) ────────
      Lead(
        id: 'BDE-001',
        name: 'Suresh Raina',
        companyName: 'Nexus Global Enterprises',
        email: 'suresh@nexusglobal.com',
        mobile: '+91 98234 11223',
        designation: 'Managing Director',
        leadSource: 'Referral',
        leadStatus: 'Converted',
        leadScore: 95,
        assignedTo: rahul,
        location: 'Mumbai, Maharashtra',
        estimatedValue: 180000.0,
        dealValue: 180000.0,
        conversionDate: DateTime(2026, 9, 8, 14, 30),
        conversionNotes: 'Annual enterprise ERP onboarding finalized.',
        expectedClosingDate: DateTime(2026, 9, 10),
        notes: 'Requested priority SLA contract. Deal successfully closed.',
        createdOn: DateTime(2026, 9, 2),
        followUps: [
          LeadFollowUp(
            id: 'F-001',
            title: 'Contract Signing Done',
            content: 'Client executed service agreement and issued advance PO.',
            dateTime: DateTime(2026, 9, 8, 11, 0),
            representative: 'Rahul Sharma',
            isCompleted: true,
            type: 'proposal',
          ),
        ],
      ),
      Lead(
        id: 'BDE-002',
        name: 'Anita Sen',
        companyName: 'Zenith Cloud Solutions',
        email: 'anita@zenithcloud.io',
        mobile: '+91 97123 44556',
        designation: 'CTO',
        leadSource: 'Google Ads',
        leadStatus: 'Converted',
        leadScore: 92,
        assignedTo: rahul,
        location: 'Bengaluru, Karnataka',
        estimatedValue: 120000.0,
        dealValue: 120000.0,
        conversionDate: DateTime(2026, 9, 12, 16, 00),
        conversionNotes: 'Cloud infrastructure monitoring suite closed.',
        expectedClosingDate: DateTime(2026, 9, 15),
        notes: 'Client reviewed 2 demos before approving the plan.',
        createdOn: DateTime(2026, 9, 4),
        followUps: [],
      ),
      Lead(
        id: 'BDE-003',
        name: 'Karan Mehra',
        companyName: 'Aura Logistics Pvt Ltd',
        email: 'karan@auralogistics.in',
        mobile: '+91 96543 22110',
        designation: 'VP Operations',
        leadSource: 'Website',
        leadStatus: 'Converted',
        leadScore: 88,
        assignedTo: rahul,
        location: 'Gurugram, Haryana',
        estimatedValue: 80000.0,
        dealValue: 80000.0,
        conversionDate: DateTime(2026, 9, 14, 12, 15),
        conversionNotes: 'Fleet tracking dispatch integration.',
        expectedClosingDate: DateTime(2026, 9, 14),
        notes: 'Fast closure within 10 days.',
        createdOn: DateTime(2026, 9, 5),
        followUps: [],
      ),
      Lead(
        id: 'BDE-004',
        name: 'Vikas Malhotra',
        companyName: 'Starlight Retailers Ltd',
        email: 'vikas@starlightretail.com',
        mobile: '+91 98112 33445',
        designation: 'Head of Purchasing',
        leadSource: 'LinkedIn Campaign',
        leadStatus: 'Proposal Sent',
        leadScore: 78,
        assignedTo: rahul,
        location: 'Delhi NCR',
        estimatedValue: 70000.0,
        expectedClosingDate: DateTime(2026, 9, 22),
        notes: 'Commercial quotation sent on Sep 11. Waiting for board approval.',
        createdOn: DateTime(2026, 9, 7),
        followUps: [
          LeadFollowUp(
            id: 'F-004',
            title: 'Quote Followup Call',
            content: 'Check on procurement approval status.',
            dateTime: DateTime(2026, 9, 18, 15, 0),
            representative: 'Rahul Sharma',
            isCompleted: false,
            type: 'call',
          ),
        ],
      ),
      Lead(
        id: 'BDE-005',
        name: 'Sneha Kapur',
        companyName: 'Innovatech Labs',
        email: 'sneha@innovatech.com',
        mobile: '+91 97234 88990',
        designation: 'Chief Strategy Officer',
        leadSource: 'Referral',
        leadStatus: 'Negotiation',
        leadScore: 82,
        assignedTo: rahul,
        location: 'Pune, Maharashtra',
        estimatedValue: 55000.0,
        expectedClosingDate: DateTime(2026, 9, 20),
        notes: 'Negotiating discount on annual payment terms.',
        createdOn: DateTime(2026, 9, 8),
        followUps: [],
      ),
      Lead(
        id: 'BDE-006',
        name: 'Gaurav Dubey',
        companyName: 'BlueWave Digital Media',
        email: 'gaurav@bluewave.co',
        mobile: '+91 99123 44009',
        designation: 'Founder',
        leadSource: 'Website',
        leadStatus: 'Contacted',
        leadScore: 65,
        assignedTo: rahul,
        location: 'Hyderabad, Telangana',
        estimatedValue: 40000.0,
        expectedClosingDate: DateTime(2026, 9, 25),
        notes: 'First discovery call completed. Demo scheduled for Friday.',
        createdOn: DateTime(2026, 9, 10),
        followUps: [],
      ),
      Lead(
        id: 'BDE-007',
        name: 'Dr. Alok Verma',
        companyName: 'Alpha Health Diagnostic',
        email: 'alok@alphahealth.org',
        mobile: '+91 96112 23344',
        designation: 'Director',
        leadSource: 'Cold Outreach',
        leadStatus: 'New',
        leadScore: 50,
        assignedTo: rahul,
        location: 'Chennai, Tamil Nadu',
        estimatedValue: 90000.0,
        expectedClosingDate: DateTime(2026, 9, 28),
        notes: 'Lead assigned from cold outreach database.',
        createdOn: DateTime(2026, 9, 12),
        followUps: [],
      ),

      // ──────── SEPTEMBER 2026 LEADS (OTHER BDEs) ────────
      Lead(
        id: 'BDE-010',
        name: 'Mohit Rao',
        companyName: 'Orion Biotech Ltd',
        email: 'mohit@orionbio.com',
        mobile: '+91 98450 12345',
        designation: 'Director',
        leadSource: 'Google Ads',
        leadStatus: 'Converted',
        leadScore: 96,
        assignedTo: neha,
        location: 'Bengaluru, Karnataka',
        estimatedValue: 250000.0,
        dealValue: 250000.0,
        conversionDate: DateTime(2026, 9, 5, 11, 00),
        conversionNotes: 'Pharma analytics solution closed.',
        expectedClosingDate: DateTime(2026, 9, 6),
        notes: 'Strategic account closed on annual terms.',
        createdOn: DateTime(2026, 9, 1),
        followUps: [],
      ),
      Lead(
        id: 'BDE-011',
        name: 'Deepak Shah',
        companyName: 'Matrix Financial Services',
        email: 'deepak@matrixfin.com',
        mobile: '+91 98711 55667',
        designation: 'COO',
        leadSource: 'Referral',
        leadStatus: 'Converted',
        leadScore: 90,
        assignedTo: neha,
        location: 'Mumbai, Maharashtra',
        estimatedValue: 150000.0,
        dealValue: 150000.0,
        conversionDate: DateTime(2026, 9, 11, 15, 30),
        conversionNotes: 'Fintech workflow management suite.',
        expectedClosingDate: DateTime(2026, 9, 12),
        notes: 'Closed with 1 year subscription.',
        createdOn: DateTime(2026, 9, 3),
        followUps: [],
      ),
      Lead(
        id: 'BDE-012',
        name: 'Sameer Joshi',
        companyName: 'Zenith Logistics Hub',
        email: 'sameer@zenithhub.in',
        mobile: '+91 98221 33445',
        designation: 'Director',
        leadSource: 'Website',
        leadStatus: 'Converted',
        leadScore: 85,
        assignedTo: aman,
        location: 'Delhi NCR',
        estimatedValue: 210000.0,
        dealValue: 210000.0,
        conversionDate: DateTime(2026, 9, 9, 17, 00),
        conversionNotes: 'Multi-branch operations license.',
        expectedClosingDate: DateTime(2026, 9, 10),
        notes: 'Deal closed after pilot test.',
        createdOn: DateTime(2026, 9, 2),
        followUps: [],
      ),
      Lead(
        id: 'BDE-013',
        name: 'Priyanka Ghosh',
        companyName: 'Sunrise EduTech',
        email: 'priyanka@sunriseedu.org',
        mobile: '+91 98300 77889',
        designation: 'Dean & Chairperson',
        leadSource: 'Conference',
        leadStatus: 'Converted',
        leadScore: 91,
        assignedTo: pooja,
        location: 'Kolkata, West Bengal',
        estimatedValue: 320000.0,
        dealValue: 320000.0,
        conversionDate: DateTime(2026, 9, 7, 16, 20),
        conversionNotes: 'Institutional attendance management rollout.',
        expectedClosingDate: DateTime(2026, 9, 8),
        notes: 'Signed 3-year enterprise contract.',
        createdOn: DateTime(2026, 9, 1),
        followUps: [],
      ),

      // ──────── AUGUST 2026 LEADS (HISTORICAL DATA) ────────
      Lead(
        id: 'BDE-AUG-01',
        name: 'Ramesh Kulkarni',
        companyName: 'Pinnacle Infotech Solutions',
        email: 'ramesh@pinnacle.com',
        mobile: '+91 98220 99887',
        designation: 'CEO',
        leadSource: 'Referral',
        leadStatus: 'Converted',
        leadScore: 98,
        assignedTo: rahul,
        location: 'Pune, Maharashtra',
        estimatedValue: 200000.0,
        dealValue: 200000.0,
        conversionDate: DateTime(2026, 8, 15, 14, 0),
        conversionNotes: 'Closed on Independence Day campaign offer.',
        expectedClosingDate: DateTime(2026, 8, 15),
        notes: 'Major account won.',
        createdOn: DateTime(2026, 8, 5),
        followUps: [],
      ),
      Lead(
        id: 'BDE-AUG-02',
        name: 'Kavita Menon',
        companyName: 'Horizon Tech Global',
        email: 'kavita@horizontech.com',
        mobile: '+91 98470 11223',
        designation: 'Head of IT',
        leadSource: 'Website',
        leadStatus: 'Converted',
        leadScore: 94,
        assignedTo: rahul,
        location: 'Kochi, Kerala',
        estimatedValue: 170000.0,
        dealValue: 170000.0,
        conversionDate: DateTime(2026, 8, 22, 16, 30),
        conversionNotes: 'Annual platform licenses with custom training.',
        expectedClosingDate: DateTime(2026, 8, 23),
        notes: 'Satisfied after 1 week trial.',
        createdOn: DateTime(2026, 8, 10),
        followUps: [],
      ),
      Lead(
        id: 'BDE-AUG-03',
        name: 'Manoj Tiwari',
        companyName: 'Skyline Ventures',
        email: 'manoj@skylinev.com',
        mobile: '+91 99110 55443',
        designation: 'Operations Head',
        leadSource: 'Google Ads',
        leadStatus: 'Converted',
        leadScore: 89,
        assignedTo: rahul,
        location: 'Noida, Uttar Pradesh',
        estimatedValue: 95000.0,
        dealValue: 95000.0,
        conversionDate: DateTime(2026, 8, 28, 12, 0),
        conversionNotes: 'Workforce monitoring tools.',
        expectedClosingDate: DateTime(2026, 8, 29),
        notes: 'Monthly billing with 1-year lockin.',
        createdOn: DateTime(2026, 8, 18),
        followUps: [],
      ),
    ]);
  }

  // ──────── HELPER CALCULATIONS & GETTERS ────────

  bool _isDateInSelectedMonth(DateTime? date) {
    if (date == null) return false;
    final parts = selectedMonth.value.split(' ');
    if (parts.length != 2) return false;
    final monthName = parts[0];
    final year = int.tryParse(parts[1]) ?? 2026;

    final monthMap = {
      'January': 1,
      'February': 2,
      'March': 3,
      'April': 4,
      'May': 5,
      'June': 6,
      'July': 7,
      'August': 8,
      'September': 9,
      'October': 10,
      'November': 11,
      'December': 12,
    };

    final targetMonthNumber = monthMap[monthName];
    if (targetMonthNumber == null) return false;

    return date.year == year && date.month == targetMonthNumber;
  }

  // Monthly Target Model for active employee in selected month
  BdeTargetModel get currentEmployeeTarget {
    final email = currentEmployeeEmail.value;
    final month = selectedMonth.value;
    final found = targets.firstWhereOrNull(
      (t) => t.employeeEmail.toLowerCase() == email.toLowerCase() && t.month == month,
    );

    if (found != null) return found;

    // Fallback default target
    final emp = salesExecutives.firstWhereOrNull((s) => s.email == email) ?? salesExecutives.first;
    return BdeTargetModel(
      id: 'T-TEMP',
      employeeName: emp.name,
      employeeEmail: emp.email,
      avatarUrl: emp.avatarUrl,
      month: month,
      targetAmount: 500000.0,
      targetDealsCount: 8,
    );
  }

  // Leads assigned to current employee
  List<Lead> get myLeads {
    final email = currentEmployeeEmail.value.toLowerCase();
    return allLeads.where((l) => l.assignedTo.email.toLowerCase() == email).toList();
  }

  // Closed/Won Deals for current employee in selected month
  List<Lead> get myClosedDealsInMonth {
    return myLeads.where((l) {
      final isWon = l.leadStatus.toLowerCase() == 'converted' || l.leadStatus.toLowerCase() == 'closed won';
      if (!isWon) return false;
      return _isDateInSelectedMonth(l.conversionDate ?? l.createdOn);
    }).toList();
  }

  // Total achieved revenue (INR) for current employee in selected month
  double get myAchievedRevenueInMonth {
    return myClosedDealsInMonth.fold(0.0, (sum, lead) => sum + (lead.dealValue ?? lead.estimatedValue));
  }

  // Target achievement percentage (0.0 to 1.0+)
  double get myAchievementPercentage {
    final target = currentEmployeeTarget.targetAmount;
    if (target <= 0) return 0.0;
    return (myAchievedRevenueInMonth / target);
  }

  // Remaining revenue needed to reach target
  double get myRemainingGap {
    final gap = currentEmployeeTarget.targetAmount - myAchievedRevenueInMonth;
    return gap > 0 ? gap : 0.0;
  }

  // Active pipeline leads for current employee (excludes won & lost)
  List<Lead> get myActivePipelineLeads {
    return myLeads.where((l) {
      final status = l.leadStatus.toLowerCase();
      final isClosed = status == 'converted' || status == 'closed won' || status == 'lost' || status == 'closed lost';
      return !isClosed;
    }).toList();
  }

  // Filtered leads list according to selected stage tab
  List<Lead> get filteredEmployeeLeads {
    final filter = selectedStageFilter.value;
    if (filter == 'Closed Won') {
      return myClosedDealsInMonth;
    } else if (filter == 'In Pipeline') {
      return myActivePipelineLeads;
    } else if (filter == 'Lost') {
      return myLeads.where((l) {
        final s = l.leadStatus.toLowerCase();
        return s == 'lost' || s == 'closed lost';
      }).toList();
    }

    // 'All' - Show all relevant leads (active pipeline + closed won in month)
    final closedInMonthIds = myClosedDealsInMonth.map((e) => e.id).toSet();
    return myLeads.where((l) {
      if (closedInMonthIds.contains(l.id)) return true;
      final status = l.leadStatus.toLowerCase();
      final isClosedWon = status == 'converted' || status == 'closed won';
      // If won in a different month, don't show under current month's active view
      if (isClosedWon) return false;
      return true;
    }).toList();
  }

  // ──────── TEAM & MANAGER GETTERS ────────

  // Total team target in selected month
  double get teamTargetAmount {
    final month = selectedMonth.value;
    return targets
        .where((t) => t.month == month)
        .fold(0.0, (sum, t) => sum + t.targetAmount);
  }

  // Total team revenue achieved in selected month
  double get teamAchievedRevenue {
    return allLeads.where((l) {
      final isWon = l.leadStatus.toLowerCase() == 'converted' || l.leadStatus.toLowerCase() == 'closed won';
      if (!isWon) return false;
      return _isDateInSelectedMonth(l.conversionDate ?? l.createdOn);
    }).fold(0.0, (sum, l) => sum + (l.dealValue ?? l.estimatedValue));
  }

  // Total team deals won count in selected month
  int get teamDealsWonCount {
    return allLeads.where((l) {
      final isWon = l.leadStatus.toLowerCase() == 'converted' || l.leadStatus.toLowerCase() == 'closed won';
      if (!isWon) return false;
      return _isDateInSelectedMonth(l.conversionDate ?? l.createdOn);
    }).length;
  }

  // Team Leaderboard items for selected month
  List<BdeLeaderboardItem> get teamLeaderboard {
    final month = selectedMonth.value;
    final monthTargets = targets.where((t) => t.month == month).toList();

    final List<BdeLeaderboardItem> items = [];

    for (final target in monthTargets) {
      final closedDeals = allLeads.where((l) {
        final matchUser = l.assignedTo.email.toLowerCase() == target.employeeEmail.toLowerCase();
        final isWon = l.leadStatus.toLowerCase() == 'converted' || l.leadStatus.toLowerCase() == 'closed won';
        return matchUser && isWon && _isDateInSelectedMonth(l.conversionDate ?? l.createdOn);
      }).toList();

      final achieved = closedDeals.fold(0.0, (sum, l) => sum + (l.dealValue ?? l.estimatedValue));
      final pct = target.targetAmount > 0 ? (achieved / target.targetAmount) : 0.0;

      items.add(BdeLeaderboardItem(
        target: target,
        achievedAmount: achieved,
        wonDealsCount: closedDeals.length,
        completionPercentage: pct,
      ));
    }

    // Sort descending by achieved amount
    items.sort((a, b) => b.achievedAmount.compareTo(a.achievedAmount));
    return items;
  }

  // ──────── ACTIONS ────────

  void selectMonth(String month) {
    selectedMonth.value = month;
  }

  void nextMonth() {
    final currentIndex = availableMonths.indexOf(selectedMonth.value);
    if (currentIndex > 0) {
      selectedMonth.value = availableMonths[currentIndex - 1];
    }
  }

  void previousMonth() {
    final currentIndex = availableMonths.indexOf(selectedMonth.value);
    if (currentIndex != -1 && currentIndex < availableMonths.length - 1) {
      selectedMonth.value = availableMonths[currentIndex + 1];
    }
  }

  void markLeadAsWon({
    required String leadId,
    required double finalDealValue,
    String? notes,
  }) {
    final index = allLeads.indexWhere((l) => l.id == leadId);
    if (index != -1) {
      final old = allLeads[index];
      final updated = old.copyWith(
        leadStatus: 'Converted',
        dealValue: finalDealValue,
        conversionDate: DateTime.now(),
        conversionNotes: notes ?? 'Deal won and closed successfully.',
      );
      allLeads[index] = updated;
      allLeads.refresh();

      Get.snackbar(
        'Deal Won & Closed! 🚀',
        'Added ₹${finalDealValue.toStringAsFixed(0)} to your monthly target achievement.',
        backgroundColor: Colors.green.shade800,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
      );
    }
  }

  void updateLeadStage(String leadId, String newStatus) {
    final index = allLeads.indexWhere((l) => l.id == leadId);
    if (index != -1) {
      allLeads[index] = allLeads[index].copyWith(leadStatus: newStatus);
      allLeads.refresh();
    }
  }

  void updateExecutiveTarget({
    required String employeeEmail,
    required String month,
    required double newTargetAmount,
  }) {
    final index = targets.indexWhere(
      (t) => t.employeeEmail.toLowerCase() == employeeEmail.toLowerCase() && t.month == month,
    );

    if (index != -1) {
      targets[index] = targets[index].copyWith(targetAmount: newTargetAmount);
    } else {
      final emp = salesExecutives.firstWhereOrNull((s) => s.email == employeeEmail) ?? salesExecutives.first;
      targets.add(BdeTargetModel(
        id: 'T-${DateTime.now().millisecondsSinceEpoch}',
        employeeName: emp.name,
        employeeEmail: emp.email,
        avatarUrl: emp.avatarUrl,
        month: month,
        targetAmount: newTargetAmount,
        targetDealsCount: 7,
      ));
    }
    targets.refresh();

    Get.snackbar(
      'Target Updated',
      'Monthly sales target set to ₹${newTargetAmount.toStringAsFixed(0)} for $month',
      backgroundColor: const Color(0xFF1E293B),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  void addNewBdeLead(Lead lead) {
    allLeads.insert(0, lead);
    allLeads.refresh();
    Get.snackbar(
      'Lead Added',
      '${lead.name} (${lead.companyName}) added to your pipeline.',
      backgroundColor: Colors.green.shade800,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }
}
