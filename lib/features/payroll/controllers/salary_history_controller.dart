import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/logger.dart';
import '../models/salary_history_model.dart';
import '../repositories/payroll_repository_interface.dart';
import '../views/payslip_pdf_viewer_screen.dart';

class SalaryHistoryController extends GetxController {
  final PayrollRepositoryInterface repository;

  SalaryHistoryController({required this.repository});

  final RxBool isLoading = false.obs;
  final Rxn<SalaryHistoryDataModel> salaryHistoryData = Rxn<SalaryHistoryDataModel>();
  final RxInt selectedYear = DateTime.now().year.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isDownloadingPayslip = false.obs;
  final RxDouble downloadProgress = 0.0.obs;

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

  void viewPayslip(RecentPayslipModel payslip) {
    final url = payslip.payslipUrl;
    if (url == null || url.trim().isEmpty) {
      Get.snackbar(
        'Notice',
        'Payslip preview is not available for this month.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.warningColor,
        colorText: Colors.white,
      );
      return;
    }

    Get.to(
      () => PayslipPdfViewerScreen(
        payslipUrl: url.trim(),
        downloadUrl: payslip.payslipDownloadUrl?.trim() ?? url.trim(),
        monthLabel: payslip.monthLabel.isNotEmpty ? payslip.monthLabel : payslip.salaryMonth,
        netPayable: payslip.netPayable,
        status: payslip.status,
        paymentDate: payslip.paymentDate,
      ),
    );
  }

  Future<void> downloadPayslip(RecentPayslipModel payslip) async {
    final downloadUrl = payslip.payslipDownloadUrl ?? payslip.payslipUrl;
    if (downloadUrl == null || downloadUrl.trim().isEmpty) {
      Get.snackbar(
        'Notice',
        'Download link is not available for this month.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.warningColor,
        colorText: Colors.white,
      );
      return;
    }

    if (isDownloadingPayslip.value) return;
    isDownloadingPayslip.value = true;
    downloadProgress.value = 0.0;

    final safeMonth = (payslip.monthLabel.isNotEmpty ? payslip.monthLabel : payslip.salaryMonth)
        .replaceAll(RegExp(r'[^\w\-]'), '_')
        .trim();
    final fileName = 'Payslip_$safeMonth.pdf';

    Get.snackbar(
      'Downloading Payslip',
      'Downloading and storing payslip on your phone...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primaryColor,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      icon: const Icon(Icons.downloading_rounded, color: Colors.white),
    );

    try {
      String? targetPath;

      // 1. Try public Downloads directory on Android first
      if (!kIsWeb && Platform.isAndroid) {
        try {
          final publicDownloadDir = Directory('/storage/emulated/0/Download');
          if (publicDownloadDir.existsSync()) {
            final testFile = File('${publicDownloadDir.path}/$fileName');
            await testFile.writeAsString('', mode: FileMode.write);
            targetPath = testFile.path;
          }
        } catch (_) {
          targetPath = null;
        }
      }

      // 2. Fallback to external application directory or documents directory
      if (targetPath == null) {
        Directory? dir;
        if (!kIsWeb && Platform.isAndroid) {
          try {
            dir = await getExternalStorageDirectory();
          } catch (_) {}
        }
        dir ??= await getApplicationDocumentsDirectory();
        targetPath = '${dir.path}/$fileName';
      }

      // 3. Download the PDF bytes into device storage
      final dio = Dio();
      await dio.download(
        downloadUrl.trim(),
        targetPath,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            downloadProgress.value = received / total;
          }
        },
      );

      final file = File(targetPath);
      final exists = await file.exists();
      final length = exists ? await file.length() : 0;

      if (exists && length > 0) {
        // Also trigger external browser/system download so device Download Manager records it in Downloads
        try {
          final uri = Uri.parse(downloadUrl.trim());
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        } catch (_) {}

        Get.snackbar(
          'Download Successful',
          'Payslip saved to your phone:\n$fileName',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF16A34A),
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
          icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.white),
          mainButton: TextButton(
            onPressed: () => OpenFilex.open(targetPath!),
            child: const Text(
              'OPEN',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        );

        // Open downloaded PDF in default system reader
        await OpenFilex.open(targetPath);
      } else {
        // Fallback: Launch in external browser
        final uri = Uri.parse(downloadUrl.trim());
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      }
    } catch (e) {
      Logger.e('SalaryHistoryController => Failed to download payslip: $e');
      try {
        final uri = Uri.parse(downloadUrl.trim());
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      } catch (_) {}
      Get.snackbar(
        'Download Notice',
        'Download started via system browser: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.slate800,
        colorText: Colors.white,
      );
    } finally {
      isDownloadingPayslip.value = false;
      downloadProgress.value = 0.0;
    }
  }

  Future<void> openPayslip(RecentPayslipModel payslip) async {
    viewPayslip(payslip);
  }
}
