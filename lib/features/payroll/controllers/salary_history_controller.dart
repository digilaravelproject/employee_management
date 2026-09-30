import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/logger.dart';
import '../models/salary_history_model.dart';
import '../repositories/payroll_repository_interface.dart';

class SalaryHistoryController extends GetxController {
  final PayrollRepositoryInterface repository;

  SalaryHistoryController({required this.repository});

  final RxBool isLoading = false.obs;
  final Rxn<SalaryHistoryDataModel> salaryHistoryData = Rxn<SalaryHistoryDataModel>();
  final RxInt selectedYear = DateTime.now().year.obs;
  final RxString errorMessage = ''.obs;

  /// Available years strictly up to current year (no future years allowed)
  List<int> get availableYears {
    final currentYear = DateTime.now().year;
    const startYear = 2020;
    if (currentYear < startYear) return [currentYear];
    return List.generate(currentYear - startYear + 1, (index) => currentYear - index);
  }

  @override
  void onInit() {
    super.onInit();
    fetchSalaryHistory();
  }

  Future<void> fetchSalaryHistory({int? year}) async {
    final currentYear = DateTime.now().year;
    var targetYear = year ?? selectedYear.value;

    // Safety guard: Never allow future year
    if (targetYear > currentYear) {
      targetYear = currentYear;
    }

    selectedYear.value = targetYear;
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await repository.getSalaryHistory(year: targetYear);
      if (response != null && response.status && response.data != null) {
        salaryHistoryData.value = response.data;
        errorMessage.value = '';
      } else {
        errorMessage.value = response?.message ?? 'Failed to load salary history.';
      }
    } catch (e) {
      Logger.e('SalaryHistoryController => Error: $e');
      errorMessage.value = 'An error occurred while loading salary history.';
    } finally {
      isLoading.value = false;
    }
  }

  void changeYear(int year) {
    if (year > DateTime.now().year) return;
    if (selectedYear.value == year) return;
    fetchSalaryHistory(year: year);
  }

  num get currentMonthlyCtc => salaryHistoryData.value?.currentMonthlyCtc ?? 0;
  CurrentCtcBreakdownModel? get currentCtcBreakdown => salaryHistoryData.value?.currentCtcBreakdown;
  List<RecentPayslipModel> get recentPayslips => salaryHistoryData.value?.recentPayslips ?? [];

  Future<void> openPayslip(RecentPayslipModel payslip) async {
    final url = payslip.payslipUrl;
    if (url == null || url.trim().isEmpty) {
      Get.snackbar(
        'Notice',
        'Payslip link is not available for this month.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.warningColor,
        colorText: Colors.white,
      );
      return;
    }

    try {
      final uri = Uri.parse(url.trim());
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          'Notice',
          'Could not open payslip link.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.warningColor,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Logger.e('SalaryHistoryController => Failed to open payslip: $e');
      Get.snackbar(
        'Error',
        'Failed to open payslip URL: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorColor,
        colorText: Colors.white,
      );
    }
  }
}
