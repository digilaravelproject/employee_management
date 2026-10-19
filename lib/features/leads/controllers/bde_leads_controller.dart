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
  final List<AppUser> salesExecutives = [];

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
    targets.clear();
  }

  void _seedLeads() {
    allLeads.clear();
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

    final emp = salesExecutives.firstWhereOrNull((s) => s.email == email) ??
        (salesExecutives.isNotEmpty ? salesExecutives.first : AppUser(name: email.isNotEmpty ? email : 'Executive', email: email, avatarUrl: ''));
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
      final emp = salesExecutives.firstWhereOrNull((s) => s.email == employeeEmail) ??
          (salesExecutives.isNotEmpty ? salesExecutives.first : AppUser(name: employeeEmail, email: employeeEmail, avatarUrl: ''));
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
