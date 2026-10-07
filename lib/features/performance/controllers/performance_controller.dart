import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../core/services/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/logger.dart';
import '../models/performance_model.dart';
import '../repositories/performance_repository.dart';
import '../repositories/performance_repository_interface.dart';

class PerformanceController extends GetxController {
  final PerformanceRepositoryInterface repository;

  PerformanceController({PerformanceRepositoryInterface? repository})
      : repository = repository ??
            (Get.isRegistered<PerformanceRepositoryInterface>()
                ? Get.find<PerformanceRepositoryInterface>()
                : PerformanceRepository(
                    apiClient: Get.isRegistered<ApiClient>() ? Get.find<ApiClient>() : ApiClient(),
                  ));

  // Navigation Tabs
  final RxInt selectedDashboardTab = 0.obs; // 0 = My Overview, 1 = Team Overview
  final RxInt selectedTargetTab = 0.obs; // 0 = Active, 1 = Completed

  // API Loading & Error states
  final RxBool isLoadingEmployees = false.obs;
  final RxString errorMessage = "".obs;

  // Month Selector
  final RxString selectedMonthApi = "".obs; // YYYY-MM
  final RxString selectedMonthDisplay = "".obs;
  late final RxString selectedMonth;
  late final RxList<String> monthsList;

  // Search Filter query
  final RxString searchQuery = "".obs;

  // API Data
  final RxList<EmployeePerformance> employees = <EmployeePerformance>[].obs;
  final Rxn<PerformanceSummaryModel> summary = Rxn<PerformanceSummaryModel>();

  // Additional metrics & targets for employee view
  final RxList<PerformanceMetric> metrics = <PerformanceMetric>[].obs;
  final RxList<PerformanceTarget> targets = <PerformanceTarget>[].obs;

  @override
  void onInit() {
    super.onInit();
    final now = DateTime.now();
    final currentYear = now.year;
    selectedMonthApi.value = DateFormat('yyyy-MM').format(now);
    selectedMonthDisplay.value = DateFormat('MMMM yyyy').format(now);
    
    selectedMonth = DateFormat('MMM yyyy').format(now).obs;
    monthsList = List.generate(now.month, (i) {
      final dt = DateTime(currentYear, i + 1);
      return DateFormat('MMM yyyy').format(dt);
    }).obs;
    
    _loadMockMetricsAndTargets();
    fetchPerformanceEmployees();
  }

  /// Calendar Date Picker for Dashboard
  Future<void> openCalendarDatePicker(BuildContext context) async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 3, 1, 1),
      lastDate: DateTime(now.year + 1, 12, 31),
      currentDate: now,
      helpText: 'Select Date for Performance Month',
      cancelText: 'Cancel',
      confirmText: 'Select',
    );

    if (pickedDate != null) {
      selectedMonthApi.value = DateFormat('yyyy-MM').format(pickedDate);
      selectedMonthDisplay.value = DateFormat('MMMM yyyy').format(pickedDate);
      selectedMonth.value = DateFormat('MMM yyyy').format(pickedDate);
      await fetchPerformanceEmployees(month: selectedMonthApi.value);
    }
  }

  // ── Fetch Employee Performance via Repository ────────────────────────
  Future<void> fetchPerformanceEmployees({String? month}) async {
    try {
      isLoadingEmployees.value = true;
      errorMessage.value = "";

      final targetMonth = month ?? selectedMonthApi.value;
      Logger.d('PerformanceController => Fetching performance for month=$targetMonth, view=team');

      final response = await repository.getEmployeePerformance(
        month: targetMonth,
        view: 'team',
        page: 1,
        perPage: 20,
      );

      if (response.status) {
        summary.value = response.summary;
        if (response.filters?.period?.label.isNotEmpty == true) {
          selectedMonthDisplay.value = response.filters!.period!.label;
        }

        final list = response.data.map((item) => item.toUiModel()).toList();
        employees.assignAll(list);
        Logger.d('PerformanceController => Loaded ${employees.length} employees from repository');
      } else {
        errorMessage.value = response.message.isNotEmpty
            ? response.message
            : 'Failed to retrieve performance data.';
        Logger.w('PerformanceController => Repository returned status false: ${response.message}');
      }
    } catch (e, st) {
      Logger.e('PerformanceController => Exception in fetchPerformanceEmployees: $e\n$st');
      errorMessage.value = 'Something went wrong while fetching performance data.';
    } finally {
      isLoadingEmployees.value = false;
    }
  }

  Future<void> refreshData() async {
    await fetchPerformanceEmployees();
  }

  // Filtered employees by search query
  List<EmployeePerformance> get filteredEmployees {
    final query = searchQuery.value.trim().toLowerCase();
    final list = List<EmployeePerformance>.from(employees)
      ..sort((a, b) => a.rank.compareTo(b.rank));

    if (query.isEmpty) return list;
    return list.where((e) =>
      e.name.toLowerCase().contains(query) ||
      e.designation.toLowerCase().contains(query) ||
      e.department.toLowerCase().contains(query) ||
      (e.employeeCode != null && e.employeeCode!.toLowerCase().contains(query))
    ).toList();
  }

  // Summary helpers
  int get totalEmployeesCount => summary.value?.totalEmployees ?? employees.length;
  num get averagePerformancePercent => summary.value?.averagePerformance ?? 0;
  PerformanceTopPerformerModel? get topPerformer => summary.value?.topPerformer;

  void _loadMockMetricsAndTargets() {
    // Populate mock key metrics for employee tab
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
        bgLightColor: AppColors.primaryLight,
      ),
      PerformanceMetric(
        name: 'Quality of Work',
        label: '4.5 / 5.0 Rating',
        progress: 0.9,
        icon: Iconsax.star,
        accentColor: const Color(0xFFF43F5E),
        bgLightColor: const Color(0xFFFFF1F2),
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
    ]);
  }

  List<PerformanceTarget> get activeTargets => targets.where((t) => !t.isCompleted).toList();
  List<PerformanceTarget> get completedTargets => targets.where((t) => t.isCompleted).toList();

  int get overallProgressGoalsCount => targets.length;
  int get overallProgressAchievedCount => targets.where((t) => t.isCompleted).length;
  int get overallProgressInProgressCount => targets.where((t) => !t.isCompleted && t.progress > 0).length;
  int get overallProgressOverdueCount => targets.where((t) => !t.isCompleted && t.dueDate.isBefore(DateTime.now())).length;

  int get totalEstimatedIncentive {
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
      final newHistory = Map<String, double>.from(old.progressHistory);
      newHistory['May 22'] = newProgress;

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
