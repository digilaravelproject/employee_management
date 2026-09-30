import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/services/network/api_client.dart';
import '../../../core/utils/logger.dart';
import '../models/admin_attendance_model.dart';
import '../repositories/attendance_repository.dart';

class AttendanceController extends GetxController {
  final AttendanceRepository _repository;

  AttendanceController({AttendanceRepository? repository})
      : _repository = repository ??
            AttendanceRepository(
              apiClient: Get.isRegistered<ApiClient>()
                  ? Get.find<ApiClient>()
                  : Get.put(ApiClient()),
            );

  final RxInt selectedTab = 0.obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rxn<AdminAttendanceData> attendanceData = Rxn<AdminAttendanceData>();

  Timer? _debounceTimer;

  // Status mapping for tabs
  final List<String> tabStatusKeys = ['all', 'present', 'absent', 'leave'];

  @override
  void onInit() {
    super.onInit();
    fetchAttendance();
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    searchController.dispose();
    super.onClose();
  }

  Future<void> fetchAttendance({bool isSearch = false}) async {
    if (!isSearch) {
      isLoading.value = true;
      errorMessage.value = '';
    }

    final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate.value);
    final statusStr = tabStatusKeys[selectedTab.value.clamp(0, tabStatusKeys.length - 1)];

    try {
      Logger.d('AttendanceController => Fetching for date: $dateStr, status: $statusStr, search: ${searchQuery.value}');
      final response = await _repository.getAdminAttendance(
        date: dateStr,
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
        status: statusStr,
        sort: 'name',
        direction: 'asc',
      );

      if (response.status && response.data != null) {
        attendanceData.value = response.data;
      } else {
        if (!isSearch) {
          errorMessage.value = response.message.isNotEmpty
              ? response.message
              : 'Failed to retrieve attendance data.';
        }
      }
    } catch (e) {
      Logger.e('AttendanceController => Error: $e');
      if (!isSearch) {
        errorMessage.value = e.toString();
      }
    } finally {
      if (!isSearch) {
        isLoading.value = false;
      }
    }
  }

  void changeTab(int index) {
    if (selectedTab.value == index) return;
    selectedTab.value = index;
    fetchAttendance();
  }

  void changeDate(DateTime date) {
    final now = DateTime.now();
    if (DateTime(date.year, date.month, date.day).isAfter(DateTime(now.year, now.month, now.day))) {
      return;
    }
    selectedDate.value = date;
    fetchAttendance();
  }

  void previousDay() {
    selectedDate.value = selectedDate.value.subtract(const Duration(days: 1));
    fetchAttendance();
  }

  void nextDay() {
    final now = DateTime.now();
    final next = selectedDate.value.add(const Duration(days: 1));
    if (DateTime(next.year, next.month, next.day).isAfter(DateTime(now.year, now.month, now.day))) {
      return;
    }
    selectedDate.value = next;
    fetchAttendance();
  }

  void selectToday() {
    selectedDate.value = DateTime.now();
    fetchAttendance();
  }

  Future<void> selectDateFromPicker(BuildContext context) async {
    final now = DateTime.now();
    final initial = selectedDate.value.isAfter(now) ? now : selectedDate.value;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: const Color(0xFF2563EB),
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      changeDate(picked);
    }
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      fetchAttendance(isSearch: true);
    });
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    fetchAttendance(isSearch: true);
  }
}
