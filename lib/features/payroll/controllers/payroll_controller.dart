import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/services/network/api_client.dart';
import '../../../core/utils/logger.dart';
import '../models/payroll_record_model.dart';
import '../models/salary_detail_model.dart';
import '../models/salary_model.dart';
import '../repositories/payroll_repository.dart';
import '../repositories/payroll_repository_interface.dart';

class PayrollMonthOption {
  final String code; // e.g. "2026-09"
  final String label; // e.g. "September 2026"

  const PayrollMonthOption({required this.code, required this.label});
}

class SalaryLineItemController {
  final TextEditingController nameController;
  final TextEditingController amountController;

  SalaryLineItemController({String name = '', String amount = ''})
      : nameController = TextEditingController(text: name),
        amountController = TextEditingController(text: amount);

  void dispose() {
    nameController.dispose();
    amountController.dispose();
  }
}

class PayrollController extends GetxController {
  final PayrollRepositoryInterface repository;

  PayrollController({PayrollRepositoryInterface? repository})
      : repository = repository ??
            PayrollRepository(
              apiClient: Get.isRegistered<ApiClient>()
                  ? Get.find<ApiClient>()
                  : Get.put(ApiClient()),
            );

  // Symmetrical reactive list of payroll records
  final RxList<PayrollRecord> payrollRecords = <PayrollRecord>[].obs;
  final RxList<SalaryEmployeeRecord> salaryEmployees = <SalaryEmployeeRecord>[].obs;
  final Rxn<SalaryDataModel> salaryData = Rxn<SalaryDataModel>();
  final Rxn<SalarySummaryModel> summary = Rxn<SalarySummaryModel>();

  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxString errorMessage = ''.obs;

  // Selected single detail
  final Rxn<SalaryDetailDataModel> selectedSalaryDetail = Rxn<SalaryDetailDataModel>();
  final RxBool isDetailLoading = false.obs;
  final RxString detailErrorMessage = ''.obs;

  static List<PayrollMonthOption> getAvailableMonthOptions() {
    final now = DateTime.now();
    final List<PayrollMonthOption> list = [];
    for (int i = 0; i < 12; i++) {
      final date = DateTime(now.year, now.month - i, 1);
      final code = DateFormat('yyyy-MM').format(date);
      final label = DateFormat('MMMM yyyy').format(date);
      list.add(PayrollMonthOption(code: code, label: label));
    }
    return list;
  }

  // Selected period (defaults to current month)
  late final RxString selectedMonth = DateFormat('yyyy-MM').format(DateTime.now()).obs;
  late final RxString selectedMonthLabel = DateFormat('MMMM yyyy').format(DateTime.now()).obs;

  late final List<PayrollMonthOption> availableMonthOptions = getAvailableMonthOptions();

  List<String> get availableMonths => availableMonthOptions.map((e) => e.label).toList();

  // Filter variables
  final RxString searchQuery = ''.obs;
  final RxString selectedFilter = 'All'.obs; // 'All', 'Created', 'Pending'

  // Selected single record
  final Rxn<PayrollRecord> selectedRecord = Rxn<PayrollRecord>();
  final Rxn<SalaryEmployeeRecord> selectedSalaryRecord = Rxn<SalaryEmployeeRecord>();

  // Create Salary Form Elements
  late TextEditingController bankNameController;
  late TextEditingController accountController;
  late TextEditingController remarksController;

  final paymentDate = Rxn<DateTime>();
  final selectedPaymentMode = Rxn<String>();
  final confirmReviewed = false.obs;

  final List<String> paymentModes = ['Bank Transfer', 'Cash', 'Cheque', 'UPI'];

  // Dynamic form lists for earnings and deductions
  final RxList<SalaryLineItemController> formEarnings = <SalaryLineItemController>[].obs;
  final RxList<SalaryLineItemController> formDeductions = <SalaryLineItemController>[].obs;
  final RxBool isSubmittingSalary = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeControllers();
    fetchSalaries();

    // Auto debounce search
    debounce(
      searchQuery,
      (_) => fetchSalaries(),
      time: const Duration(milliseconds: 350),
    );
  }

  void _initializeControllers() {
    bankNameController = TextEditingController();
    accountController = TextEditingController();
    remarksController = TextEditingController();
  }

  @override
  void onClose() {
    bankNameController.dispose();
    accountController.dispose();
    remarksController.dispose();
    for (final item in formEarnings) {
      item.dispose();
    }
    for (final item in formDeductions) {
      item.dispose();
    }
    super.onClose();
  }

  Future<void> fetchSalaries({bool isRefresh = false}) async {
    try {
      if (isRefresh) {
        isRefreshing.value = true;
      } else {
        isLoading.value = true;
      }
      errorMessage.value = '';

      final String statusParam = selectedFilter.value == 'All'
          ? 'all'
          : selectedFilter.value.toLowerCase();

      final response = await repository.getSalaries(
        month: selectedMonth.value,
        search: searchQuery.value.trim(),
        status: statusParam,
      );

      if (response != null && response.status && response.data != null) {
        final data = response.data!;
        salaryData.value = data;
        summary.value = data.summary;
        salaryEmployees.assignAll(data.employees);

        if (data.monthLabel.isNotEmpty) {
          selectedMonthLabel.value = data.monthLabel;
        }

        final convertedRecords = data.employees.map((e) => e.toPayrollRecord()).toList();
        payrollRecords.assignAll(convertedRecords);

        Logger.d('PayrollController => Loaded ${data.employees.length} salary records from server');
      } else {
        errorMessage.value = response?.message ?? 'Failed to retrieve salaries.';
      }
    } catch (e, stack) {
      Logger.e('PayrollController => Error in fetchSalaries: $e\n$stack');
      errorMessage.value = 'Failed to load salary data.';
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  Future<void> fetchEmployeeSalaryDetails(String employeeId, {String? month}) async {
    try {
      isDetailLoading.value = true;
      detailErrorMessage.value = '';
      final targetMonth = month ?? selectedMonth.value;

      Logger.d('PayrollController => Fetching salary detail for employee: $employeeId, month: $targetMonth');

      final response = await repository.getEmployeeSalaryDetails(
        employeeId: employeeId,
        month: targetMonth,
      );

      if (response != null && response.status && response.data != null) {
        final detail = response.data!;
        selectedSalaryDetail.value = detail;
        selectedRecord.value = detail.toPayrollRecord();
        Logger.d('PayrollController => Detail retrieved successfully for employee: $employeeId');
      } else {
        detailErrorMessage.value = response?.message ?? 'Failed to retrieve salary details.';
      }
    } catch (e, stack) {
      Logger.e('PayrollController => Error in fetchEmployeeSalaryDetails: $e\n$stack');
      detailErrorMessage.value = 'Failed to load employee salary details.';
    } finally {
      isDetailLoading.value = false;
    }
  }

  void changeMonth(String monthCode, String monthLabel) {
    try {
      final now = DateTime.now();
      final parsed = DateFormat('yyyy-MM').parse(monthCode);
      if (DateTime(parsed.year, parsed.month, 1).isAfter(DateTime(now.year, now.month, 1))) {
        return;
      }
    } catch (_) {}
    if (selectedMonth.value != monthCode) {
      selectedMonth.value = monthCode;
      selectedMonthLabel.value = monthLabel;
      fetchSalaries();
    }
  }

  void onFilterChanged(String filter) {
    if (selectedFilter.value != filter) {
      selectedFilter.value = filter;
      fetchSalaries();
    }
  }

  // Active statistics counts from API summary
  int get totalEmployeesCount =>
      summary.value?.totalEmployees ?? payrollRecords.length;

  int get createdCount =>
      summary.value?.created ??
      payrollRecords.where((r) => r.status.toLowerCase() == 'created').length;

  int get pendingCount =>
      summary.value?.pending ??
      payrollRecords.where((r) => r.status.toLowerCase() == 'pending').length;

  // Filtered list based on search queries and tabs
  List<PayrollRecord> get filteredPayrollRecords {
    List<PayrollRecord> temp = List.from(payrollRecords);

    // Apply selected tab filter locally if backend returned 'all'
    if (selectedFilter.value != 'All') {
      temp = temp
          .where((r) => r.status.toLowerCase() == selectedFilter.value.toLowerCase())
          .toList();
    }

    // Apply search query
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      temp = temp.where((r) =>
          r.employeeName.toLowerCase().contains(query) ||
          r.employeeId.toLowerCase().contains(query) ||
          r.designation.toLowerCase().contains(query) ||
          r.department.toLowerCase().contains(query)).toList();
    }

    return temp;
  }

  // Clear payment form values
  void clearForm() {
    bankNameController.clear();
    accountController.clear();
    remarksController.clear();
    paymentDate.value = DateTime.now();
    selectedPaymentMode.value = 'Bank Transfer';
    confirmReviewed.value = false;

    for (final item in formEarnings) {
      item.dispose();
    }
    formEarnings.clear();

    for (final item in formDeductions) {
      item.dispose();
    }
    formDeductions.clear();
  }

  void addEarningItem({String name = '', String amount = ''}) {
    formEarnings.add(SalaryLineItemController(name: name, amount: amount));
  }

  void removeEarningItem(int index) {
    if (index >= 0 && index < formEarnings.length) {
      formEarnings[index].dispose();
      formEarnings.removeAt(index);
    }
  }

  void addDeductionItem({String name = '', String amount = ''}) {
    formDeductions.add(SalaryLineItemController(name: name, amount: amount));
  }

  void removeDeductionItem(int index) {
    if (index >= 0 && index < formDeductions.length) {
      formDeductions[index].dispose();
      formDeductions.removeAt(index);
    }
  }

  num get calculatedGrossEarnings {
    num total = 0;
    for (final item in formEarnings) {
      total += num.tryParse(item.amountController.text.trim()) ?? 0;
    }
    return total;
  }

  num get calculatedTotalDeductions {
    num total = 0;
    for (final item in formDeductions) {
      total += num.tryParse(item.amountController.text.trim()) ?? 0;
    }
    return total;
  }

  num get calculatedNetPayable => calculatedGrossEarnings - calculatedTotalDeductions;

  // Set values to selected record for paying
  void initializePaymentForm(PayrollRecord record) {
    clearForm();
    selectedRecord.value = record;

    final detail = selectedSalaryDetail.value;
    if (detail != null && detail.earnings.isNotEmpty) {
      for (final e in detail.earnings) {
        addEarningItem(name: e.name, amount: e.amount.toInt().toString());
      }
    } else {
      final gross = record.grossEarnings > 0 ? record.grossEarnings : record.netPayable;
      addEarningItem(name: 'Basic', amount: (gross * 0.5).toInt().toString());
      addEarningItem(name: 'HRA', amount: (gross * 0.25).toInt().toString());
      addEarningItem(name: 'Allowances', amount: (gross * 0.25).toInt().toString());
    }

    if (detail != null && detail.deductions.isNotEmpty) {
      for (final d in detail.deductions) {
        addDeductionItem(name: d.name, amount: d.amount.toInt().toString());
      }
    } else if (record.totalDeductions > 0) {
      addDeductionItem(name: 'Leaves/LWP', amount: record.totalDeductions.toInt().toString());
    } else {
      addDeductionItem(name: 'Leaves/LWP', amount: '0');
    }
  }

  // Commit salary creation transaction via live API
  Future<bool> submitCreateSalary() async {
    final record = selectedRecord.value;
    final detail = selectedSalaryDetail.value;

    final employeeId = record?.employeeId ?? detail?.employee.employeeId;
    if (employeeId == null || employeeId.isEmpty) {
      Get.snackbar(
        'Error',
        'No employee selected.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
      return false;
    }

    final pDate = paymentDate.value ?? DateTime.now();
    final formattedDate =
        "${pDate.year}-${pDate.month.toString().padLeft(2, '0')}-${pDate.day.toString().padLeft(2, '0')}";
    final targetMonth = selectedMonth.value.isNotEmpty
        ? selectedMonth.value
        : (detail?.month ?? '2026-09');

    // Build earnings list
    final List<SalaryLineItem> earningsList = [];
    for (final e in formEarnings) {
      final name = e.nameController.text.trim();
      final amount = num.tryParse(e.amountController.text.trim()) ?? 0;
      if (name.isNotEmpty) {
        earningsList.add(SalaryLineItem(name: name, amount: amount));
      }
    }

    // Build deductions list
    final List<SalaryLineItem> deductionsList = [];
    for (final d in formDeductions) {
      final name = d.nameController.text.trim();
      final amount = num.tryParse(d.amountController.text.trim()) ?? 0;
      if (name.isNotEmpty) {
        deductionsList.add(SalaryLineItem(name: name, amount: amount));
      }
    }

    final request = CreateSalaryRequestModel(
      employeeId: employeeId,
      salaryMonth: targetMonth,
      paymentDate: formattedDate,
      paymentMode: selectedPaymentMode.value ?? 'Bank Transfer',
      bankName: bankNameController.text.trim().isNotEmpty
          ? bankNameController.text.trim()
          : 'HDFC Bank',
      accountUpiAddress: accountController.text.trim().isNotEmpty
          ? accountController.text.trim()
          : 'XXXX XXXX XXXX 1234',
      remarks: remarksController.text.trim().isNotEmpty
          ? remarksController.text.trim()
          : 'Processed successfully',
      earnings: earningsList,
      deductions: deductionsList,
      confirmed: confirmReviewed.value,
    );

    try {
      isSubmittingSalary.value = true;
      Logger.d('PayrollController => Submitting create salary: ${request.toJson()}');

      final response = await repository.createSalary(request);

      if (response != null && response.status) {
        Logger.d('PayrollController => Salary created successfully: ${response.message}');

        // Locally update record for immediate UI sync
        final index = payrollRecords.indexWhere((r) => r.id == record?.id || r.employeeId == employeeId);
        final grossAmount = calculatedGrossEarnings;
        final deductAmount = calculatedTotalDeductions;

        if (index != -1 && record != null) {
          final updated = record.copyWith(
            status: 'Created',
            paymentDate: formattedDate,
            paymentMode: request.paymentMode,
            bankName: request.bankName,
            accountIfsc: request.accountUpiAddress,
            remarks: request.remarks,
            basicSalary: grossAmount.toDouble(),
            hra: 0,
            conveyance: 0,
            specialAllowance: 0,
            incentive: 0,
            bonus: 0,
            overtimeAmount: 0,
            leaveDeduction: deductAmount.toDouble(),
            lateDeduction: 0,
            pf: 0,
            esi: 0,
            loanAdvance: 0,
            otherDeduction: 0,
          );
          payrollRecords[index] = updated;
          selectedRecord.value = updated;
        }

        // Update summary counts locally
        if (summary.value != null) {
          final currentSummary = summary.value!;
          summary.value = SalarySummaryModel(
            totalEmployees: currentSummary.totalEmployees,
            created: currentSummary.created + 1,
            pending: (currentSummary.pending - 1).clamp(0, 9999),
          );
        }

        // Re-fetch detail for this employee
        await fetchEmployeeSalaryDetails(employeeId, month: targetMonth);

        // Refresh salary listing in background
        fetchSalaries(isRefresh: true);

        Get.snackbar(
          'Salary Processed Successfully 🎉',
          response.message ?? 'Salary created successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return true;
      } else {
        final error = response?.message ?? 'Failed to create salary.';
        Logger.e('PayrollController => Failed to create salary: $error');
        Get.snackbar(
          'Error',
          error,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFEF4444),
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
        return false;
      }
    } catch (e, stack) {
      Logger.e('PayrollController => Exception in submitCreateSalary: $e\n$stack');
      Get.snackbar(
        'Error',
        'Something went wrong while creating salary: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
      return false;
    } finally {
      isSubmittingSalary.value = false;
    }
  }

  void processCreateSalary() {
    submitCreateSalary();
  }
}
