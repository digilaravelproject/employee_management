import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ApplyLeaveController extends GetxController {
  // Observables
  final RxString selectedLeaveType = 'Casual Leave'.obs;
  final Rx<DateTime?> fromDate = Rx<DateTime?>(null);
  final Rx<DateTime?> toDate = Rx<DateTime?>(null);
  final RxString sessionType = 'Full Day'.obs; // Full Day, 1st Half, 2nd Half
  final RxDouble totalDays = 0.0.obs;

  // Dummy Data
  final List<String> leaveTypes = [
    'Casual Leave',
    'Sick Leave',
    'Paid Leave',
    'Comp Off',
    'Maternity Leave',
    'Other Leave',
  ];

  @override
  void onInit() {
    super.onInit();
    // Set default dates to today and tomorrow just for UX
    final now = DateTime.now();
    fromDate.value = now;
    toDate.value = now.add(const Duration(days: 2));
    calculateTotalDays();
  }

  // Set Leave Type
  void setLeaveType(String type) {
    selectedLeaveType.value = type;
  }

  // Set Session Type
  void setSessionType(String type) {
    sessionType.value = type;
    calculateTotalDays();
  }

  // Date Picker for From Date
  Future<void> selectFromDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: fromDate.value ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      fromDate.value = picked;
      // Auto-adjust toDate if fromDate is after toDate
      if (toDate.value != null && picked.isAfter(toDate.value!)) {
        toDate.value = picked;
      }
      calculateTotalDays();
    }
  }

  // Date Picker for To Date
  Future<void> selectToDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: toDate.value ?? fromDate.value ?? DateTime.now(),
      firstDate: fromDate.value ?? DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      toDate.value = picked;
      calculateTotalDays();
    }
  }

  // Calculate Days
  void calculateTotalDays() {
    if (fromDate.value == null || toDate.value == null) {
      totalDays.value = 0;
      return;
    }

    // Basic calculation: Difference in days + 1 (inclusive)
    int diffInDays = toDate.value!.difference(fromDate.value!).inDays + 1;
    
    // Handle half days
    if (sessionType.value == '1st Half' || sessionType.value == '2nd Half') {
      // If it's a multi-day leave but selected half day, logic usually applies to the whole period or single day.
      // Usually half day is for a single day, but if multi-day, maybe the total is (diffInDays - 0.5)
      // We will assume half day applies to the total duration by reducing it by 0.5 for UX demonstration.
      // Or simply, if half day is selected, it's 0.5 days per day.
      // Let's do a simple calculation: (diffInDays - 0.5) if diffInDays > 0
      if (diffInDays == 1) {
        totalDays.value = 0.5;
      } else {
        // Just an example logic: total days - 0.5 (meaning one half day in the duration)
        // Or half of the total days. Let's subtract 0.5
        totalDays.value = diffInDays - 0.5;
      }
    } else {
      totalDays.value = diffInDays.toDouble();
    }
  }

  // Format Dates
  String getFormattedFromDate() {
    if (fromDate.value == null) return 'Select Date';
    return DateFormat('dd MMM yyyy').format(fromDate.value!);
  }

  String getFormattedToDate() {
    if (toDate.value == null) return 'Select Date';
    return DateFormat('dd MMM yyyy').format(toDate.value!);
  }
}
