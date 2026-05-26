import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../models/performance_model.dart';

class PerformanceController extends GetxController {
  // Navigation Tabs
  final RxInt selectedDashboardTab = 0.obs; // 0 = My Overview, 1 = Team Overview
  final RxInt selectedTeamSubTab = 0.obs; // 0 = Team View, 1 = Department View
  final RxInt selectedTargetTab = 0.obs; // 0 = Active, 1 = Completed

  // Month Selector
  final RxString selectedMonth = "May 2024".obs;
  final RxList<String> monthsList = ["Jan 2024", "Feb 2024", "Mar 2024", "Apr 2024", "May 2024", "Jun 2024"].obs;

  // Search Filter query
  final RxString searchQuery = "".obs;

  // Data lists
  final RxList<EmployeePerformance> employees = <EmployeePerformance>[].obs;
  final RxList<PerformanceMetric> metrics = <PerformanceMetric>[].obs;
  final RxList<PerformanceTarget> targets = <PerformanceTarget>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadMockData();
  }

  void _loadMockData() {
    // Populate mock employees
    employees.assignAll([
      EmployeePerformance(
        id: '1',
        name: 'Rohit Sharma',
        designation: 'HR Executive',
        department: 'HR & People',
        performanceScore: 87,
        ratingLabel: 'Very Good',
        imageUrl: 'https://i.pravatar.cc/150?u=rohit',
        rank: 1,
      ),
      EmployeePerformance(
        id: '2',
        name: 'Priya Singh',
        designation: 'Sr. Executive',
        department: 'Operations',
        performanceScore: 74,
        ratingLabel: 'Good',
        imageUrl: 'https://i.pravatar.cc/150?u=priya',
        rank: 3,
      ),
      EmployeePerformance(
        id: '3',
        name: 'Amit Verma',
        designation: 'Accountant',
        department: 'Finance',
        performanceScore: 68,
        ratingLabel: 'Average',
        imageUrl: 'https://i.pravatar.cc/150?u=amit',
        rank: 5,
      ),
      EmployeePerformance(
        id: '4',
        name: 'Sneha Patel',
        designation: 'Executive',
        department: 'Tech Support',
        performanceScore: 90,
        ratingLabel: 'Excellent',
        imageUrl: 'https://i.pravatar.cc/150?u=sneha',
        rank: 2,
      ),
      EmployeePerformance(
        id: '5',
        name: 'Vikram Mehta',
        designation: 'Sales Executive',
        department: 'Sales & Growth',
        performanceScore: 72,
        ratingLabel: 'Good',
        imageUrl: 'https://i.pravatar.cc/150?u=vikram',
        rank: 4,
      ),
      EmployeePerformance(
        id: '6',
        name: 'Neha Gupta',
        designation: 'HR Coordinator',
        department: 'HR & People',
        performanceScore: 65,
        ratingLabel: 'Average',
        imageUrl: 'https://i.pravatar.cc/150?u=neha',
        rank: 6,
      ),
      EmployeePerformance(
        id: '7',
        name: 'Karan Das',
        designation: 'Operations Specialist',
        department: 'Operations',
        performanceScore: 80,
        ratingLabel: 'Very Good',
        imageUrl: 'https://i.pravatar.cc/150?u=karan',
        rank: 7,
      ),
      EmployeePerformance(
        id: '8',
        name: 'Pooja Nair',
        designation: 'Marketing Manager',
        department: 'Sales & Growth',
        performanceScore: 78,
        ratingLabel: 'Good',
        imageUrl: 'https://i.pravatar.cc/150?u=pooja',
        rank: 8,
      ),
    ]);

    // Populate mock key metrics
    metrics.assignAll([
      PerformanceMetric(
        name: 'Attendance',
        label: '26 / 26 Days',
        progress: 1.0,
        icon: Iconsax.calendar,
        accentColor: AppColors.successColor,
        bgLightColor: const Color(0xFFEAFAF1),
      ),
      PerformanceMetric(
        name: 'Leave',
        label: '1 / 2 Days',
        progress: 0.5,
        icon: Iconsax.sun_1,
        accentColor: AppColors.warningColor,
        bgLightColor: const Color(0xFFFEF9EC),
      ),
      PerformanceMetric(
        name: 'Task Completion',
        label: '18 / 20 Tasks',
        progress: 0.9,
        icon: Iconsax.task_square,
        accentColor: AppColors.successColor,
        bgLightColor: const Color(0xFFEAFAF1),
      ),
      PerformanceMetric(
        name: 'Timely Submissions',
        label: '11 / 12 Tasks',
        progress: 0.92,
        icon: Iconsax.clock,
        accentColor: AppColors.primaryColor,
        bgLightColor: const Color(0xFFEFF6FF),
      ),
      PerformanceMetric(
        name: 'Quality of Work',
        label: '4.5 / 5.0 Rating',
        progress: 0.9,
        icon: Iconsax.star,
        accentColor: const Color(0xFFF43F5E), // Rose 500
        bgLightColor: const Color(0xFFFFF1F2), // Rose 50
      ),
    ]);

    // Populate mock targets
    targets.assignAll([
      PerformanceTarget(
        id: '1',
        title: 'Increase Client Onboarding',
        description: 'Onboard 20 new clients this month',
        targetValue: '20 Clients',
        achievedValue: '16 Clients',
        progress: 0.8,
        status: 'On Track',
        frequency: 'Monthly',
        dueDate: DateTime(2026, 5, 31),
        isCompleted: false,
        goalType: 'Individual',
        assignedOn: DateTime(2026, 5, 1),
        assignedByName: 'Vikram Mehta',
        assignedByImage: 'https://i.pravatar.cc/150?u=manager',
        estimatedIncentive: 4320,
        progressHistory: {
          'May 1': 0.20,
          'May 8': 0.40,
          'May 15': 0.60,
          'May 22': 0.80,
          'May 31': 0.80,
        },
      ),
      PerformanceTarget(
        id: '2',
        title: 'Improve Response Time',
        description: 'Maintain avg response time under 2 hrs',
        targetValue: 'Under 2 hrs',
        achievedValue: '1.5 hrs',
        progress: 0.75,
        status: 'In Progress',
        frequency: 'Monthly',
        dueDate: DateTime(2026, 5, 31),
        isCompleted: false,
        goalType: 'Individual',
        assignedOn: DateTime(2026, 5, 1),
        assignedByName: 'Vikram Mehta',
        assignedByImage: 'https://i.pravatar.cc/150?u=manager',
        estimatedIncentive: 2500,
        progressHistory: {
          'May 1': 0.10,
          'May 8': 0.30,
          'May 15': 0.50,
          'May 22': 0.75,
          'May 31': 0.75,
        },
      ),
      PerformanceTarget(
        id: '3',
        title: 'Complete Project Documentation',
        description: 'Submit all project docs before EOM',
        targetValue: '5 Tasks',
        achievedValue: '5 Tasks',
        progress: 1.0,
        status: 'On Track',
        frequency: 'Monthly',
        dueDate: DateTime(2026, 5, 31),
        isCompleted: true,
        goalType: 'Individual',
        assignedOn: DateTime(2026, 5, 1),
        assignedByName: 'Vikram Mehta',
        assignedByImage: 'https://i.pravatar.cc/150?u=manager',
        estimatedIncentive: 1800,
        progressHistory: {
          'May 1': 0.20,
          'May 8': 0.50,
          'May 15': 0.80,
          'May 22': 1.0,
          'May 31': 1.0,
        },
      ),
      PerformanceTarget(
        id: '4',
        title: 'Upsell Existing Clients',
        description: 'Close 10 upsell opportunities',
        targetValue: '10 Deals',
        achievedValue: '6 Deals',
        progress: 0.6,
        status: 'In Progress',
        frequency: 'Monthly',
        dueDate: DateTime(2026, 5, 31),
        isCompleted: false,
        goalType: 'Individual',
        assignedOn: DateTime(2026, 5, 1),
        assignedByName: 'Vikram Mehta',
        assignedByImage: 'https://i.pravatar.cc/150?u=manager',
        estimatedIncentive: 3500,
        progressHistory: {
          'May 1': 0.0,
          'May 8': 0.20,
          'May 15': 0.40,
          'May 22': 0.60,
          'May 31': 0.60,
        },
      ),
    ]);
  }

  // Filtered lists
  List<EmployeePerformance> get filteredEmployees {
    final query = searchQuery.value.trim().toLowerCase();
    
    // Grouping/Filtering by team vs department
    List<EmployeePerformance> list = employees;
    if (selectedTeamSubTab.value == 1) {
      // Sort or filter differently if needed for Department View, e.g. group by department
      list = List.from(employees)..sort((a, b) => a.department.compareTo(b.department));
    } else {
      // Sort by rank for Team View
      list = List.from(employees)..sort((a, b) => a.rank.compareTo(b.rank));
    }

    if (query.isEmpty) return list;
    return list.where((e) =>
      e.name.toLowerCase().contains(query) ||
      e.designation.toLowerCase().contains(query) ||
      e.department.toLowerCase().contains(query)
    ).toList();
  }

  List<PerformanceTarget> get activeTargets => targets.where((t) => !t.isCompleted).toList();
  List<PerformanceTarget> get completedTargets => targets.where((t) => t.isCompleted).toList();

  int get overallProgressGoalsCount => targets.length;
  int get overallProgressAchievedCount => targets.where((t) => t.isCompleted).length;
  int get overallProgressInProgressCount => targets.where((t) => !t.isCompleted && t.progress > 0).length;
  int get overallProgressOverdueCount => targets.where((t) => !t.isCompleted && t.dueDate.isBefore(DateTime.now())).length;

  int get totalEstimatedIncentive {
    // Sum incentives of active and completed targets multiplied by progress
    double total = 0;
    for (var t in targets) {
      total += t.estimatedIncentive * t.progress;
    }
    return total.round();
  }

  void updateTargetProgress(String id, double newProgress, String achievedVal) {
    final index = targets.indexWhere((t) => t.id == id);
    if (index != -1) {
      final old = targets[index];
      // Update progress history for today
      final newHistory = Map<String, double>.from(old.progressHistory);
      newHistory['May 22'] = newProgress; // Mock current date node

      targets[index] = old.copyWith(
        achievedValue: achievedVal,
        progress: newProgress,
        status: newProgress >= 1.0 ? 'Completed' : (newProgress >= 0.75 ? 'On Track' : 'In Progress'),
        isCompleted: newProgress >= 1.0,
        progressHistory: newHistory,
      );
      targets.refresh();
    }
  }

  void markTargetCompleted(String id) {
    final index = targets.indexWhere((t) => t.id == id);
    if (index != -1) {
      final old = targets[index];
      final newHistory = Map<String, double>.from(old.progressHistory);
      newHistory['May 31'] = 1.0;

      targets[index] = old.copyWith(
        achievedValue: old.targetValue,
        progress: 1.0,
        status: 'Completed',
        isCompleted: true,
        progressHistory: newHistory,
      );
      targets.refresh();

      Get.snackbar(
        'Goal Completed!',
        'Excellent work in completing: ${old.title}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.successColor,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  void addNewTarget(String title, String description, String targetVal, int incentive) {
    final newT = PerformanceTarget(
      id: (targets.length + 1).toString(),
      title: title,
      description: description,
      targetValue: targetVal,
      achievedValue: '0',
      progress: 0.0,
      status: 'In Progress',
      frequency: 'Monthly',
      dueDate: DateTime(2026, 5, 31),
      isCompleted: false,
      goalType: 'Individual',
      assignedOn: DateTime.now(),
      assignedByName: 'Vikram Mehta',
      assignedByImage: 'https://i.pravatar.cc/150?u=manager',
      estimatedIncentive: incentive,
      progressHistory: {
        'May 1': 0.0,
      },
    );
    targets.add(newT);
    targets.refresh();

    Get.snackbar(
      'Target Added',
      'New target "$title" has been successfully assigned.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.textColorPrimary,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }
}
