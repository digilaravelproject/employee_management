import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/network/api_client.dart';
import '../../../core/utils/logger.dart';
import '../../leave_management/controllers/leave_calendar_controller.dart';
import '../../leave_management/models/holiday_calendar_model.dart';
import '../models/add_holiday_model.dart';
import '../models/holiday_model.dart';
import '../repositories/holidays_repository.dart';
import '../repositories/holidays_repository_interface.dart';

class HolidaysController extends GetxController {
  final HolidaysRepositoryInterface repository;

  HolidaysController({HolidaysRepositoryInterface? repository})
      : repository = repository ??
            HolidaysRepository(
              apiClient: Get.isRegistered<ApiClient>()
                  ? Get.find<ApiClient>()
                  : Get.put(ApiClient()),
            );

  // Reactive list of holidays
  final RxList<Holiday> holidays = <Holiday>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxBool isDeleting = false.obs;
  final RxBool isLoadingDetails = false.obs;
  final RxString errorMessage = ''.obs;

  final Rxn<HolidayItemModel> holidayDetails = Rxn<HolidayItemModel>();

  final Rxn<HolidayCalendarResponse> calendarResponse = Rxn<HolidayCalendarResponse>();
  final Rxn<HolidaySummary> summary = Rxn<HolidaySummary>();

  // Filters
  final RxInt filterYear = DateTime.now().year.obs;
  final RxString filterLocation = 'All Locations'.obs;

  // Selected holiday for details or edit mode
  final Rxn<Holiday> selectedHoliday = Rxn<Holiday>();

  // Collapsible Month Expansion States: Month index (1-12) -> isExpanded
  final RxMap<int, bool> expandedMonths = <int, bool>{}.obs;

  // Form Fields & Controllers for Add / Edit Screen
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final Rxn<DateTime> selectedDate = Rxn<DateTime>();
  final RxString selectedType = 'National'.obs;
  final RxString selectedLocation = 'All Locations'.obs;
  final RxBool repeatEveryYear = true.obs;

  // Constant list of locations and types for dropdowns
  final List<String> locations = [
    'All Locations',
    'Delhi HQ',
    'Mumbai Office',
    'Bangalore Tech Hub',
    'Remote',
  ];

  final List<String> holidayTypes = [
    'National',
    'Restricted',
    'Optional',
  ];

  @override
  void onInit() {
    super.onInit();
    // Expand the current month by default
    final currentMonth = DateTime.now().month;
    expandedMonths[currentMonth] = true;
    fetchHolidays();
  }

  // Change active calendar year and trigger reload
  void changeYear(int year) {
    if (filterYear.value != year) {
      filterYear.value = year;
      fetchHolidays();
    }
  }

  // Change active location and trigger reload
  void changeLocation(String location) {
    if (filterLocation.value != location) {
      filterLocation.value = location;
      fetchHolidays();
    }
  }

  // Summary statistics getters
  int get totalHolidays => summary.value?.total ?? filteredHolidays.length;
  int get nationalHolidays =>
      summary.value?.national ??
      filteredHolidays
          .where((h) => h.type.toLowerCase().contains('national'))
          .length;
  int get restrictedHolidays =>
      summary.value?.restricted ??
      filteredHolidays
          .where((h) => h.type.toLowerCase().contains('restricted'))
          .length;
  int get optionalHolidays =>
      summary.value?.optional ??
      filteredHolidays
          .where((h) => h.type.toLowerCase().contains('optional'))
          .length;

  // Fetch holidays from server
  Future<void> fetchHolidays({bool isRefresh = false}) async {
    try {
      if (isRefresh) {
        isRefreshing.value = true;
      } else {
        isLoading.value = true;
      }
      errorMessage.value = '';

      final response = await repository.getHolidays(
        year: filterYear.value,
        location: filterLocation.value,
      );

      if (response != null && response.status) {
        calendarResponse.value = response;
        summary.value = response.summary;

        final List<Holiday> serverHolidays = [];

        // Parse from months list
        for (final m in response.months) {
          for (final h in m.holidays) {
            DateTime parsedDate;
            try {
              parsedDate = DateTime.parse(h.date);
            } catch (_) {
              parsedDate = DateTime.now();
            }
            serverHolidays.add(Holiday(
              id: h.id.toString(),
              name: h.name,
              date: parsedDate,
              type: h.type,
              location: h.location ?? 'All Locations',
              repeatEveryYear: h.repeatEveryYear,
              description: h.description ?? '',
              addedBy: 'Admin',
              addedOn: DateTime.now(),
            ));
          }
        }

        // If months was empty but response.data has items
        if (serverHolidays.isEmpty && response.data.isNotEmpty) {
          for (final h in response.data) {
            DateTime parsedDate;
            try {
              parsedDate = DateTime.parse(h.date);
            } catch (_) {
              parsedDate = DateTime.now();
            }
            serverHolidays.add(Holiday(
              id: h.id.toString(),
              name: h.name,
              date: parsedDate,
              type: h.type,
              location: h.location ?? 'All Locations',
              repeatEveryYear: h.repeatEveryYear,
              description: h.description ?? '',
              addedBy: 'Admin',
              addedOn: DateTime.now(),
            ));
          }
        }

        holidays.assignAll(serverHolidays);

        // Auto-expand any month that has holidays
        for (final h in serverHolidays) {
          expandedMonths[h.date.month] = true;
        }

        Logger.d('HolidaysController => Loaded ${serverHolidays.length} holidays from server for year ${filterYear.value}');
      } else {
        errorMessage.value = response?.message ?? 'Failed to load holidays.';
        if (holidays.isEmpty) {
          _initializeFallbackHolidays();
        }
      }
    } catch (e, stack) {
      Logger.e('HolidaysController => Error in fetchHolidays: $e\n$stack');
      errorMessage.value = 'Failed to load holidays. Please try again.';
      if (holidays.isEmpty) {
        _initializeFallbackHolidays();
      }
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  // Fetch full holiday details by ID from API
  Future<void> fetchHolidayDetails(String id) async {
    try {
      isLoadingDetails.value = true;
      Logger.d('HolidaysController => Fetching details for holiday ID: $id');
      final response = await repository.getHolidayDetails(id);

      if (response != null && response.status && response.data != null) {
        final item = response.data!;
        holidayDetails.value = item;

        DateTime parsedDate;
        try {
          parsedDate = DateTime.parse(item.date);
        } catch (_) {
          parsedDate = selectedHoliday.value?.date ?? DateTime.now();
        }

        DateTime addedOn;
        try {
          addedOn = item.createdAt != null
              ? DateTime.parse(item.createdAt!)
              : DateTime.now();
        } catch (_) {
          addedOn = DateTime.now();
        }

        final updated = Holiday(
          id: item.id.toString(),
          name: item.name,
          date: parsedDate,
          type: item.type,
          location: item.location ?? 'All Locations',
          repeatEveryYear: item.repeatEveryYear,
          description: item.description ?? '',
          addedBy: 'Admin',
          addedOn: addedOn,
        );
        selectedHoliday.value = updated;
        Logger.d('HolidaysController => Loaded details for: ${item.name}');
      }
    } catch (e, stack) {
      Logger.e('HolidaysController => Error in fetchHolidayDetails: $e\n$stack');
    } finally {
      isLoadingDetails.value = false;
    }
  }

  // Reactive filtered holidays list based on Year and Location
  List<Holiday> get filteredHolidays {
    return holidays.where((h) {
      final matchesYear = h.date.year == filterYear.value;
      final matchesLocation = filterLocation.value == 'All Locations' ||
          h.location == 'All Locations' ||
          h.location == filterLocation.value;
      return matchesYear && matchesLocation;
    }).toList();
  }

  // Group filtered holidays by month index (1 for Jan, 12 for Dec)
  Map<int, List<Holiday>> get holidaysByMonth {
    final Map<int, List<Holiday>> grouped = {};
    for (int i = 1; i <= 12; i++) {
      grouped[i] = [];
    }

    for (var h in filteredHolidays) {
      final month = h.date.month;
      grouped[month]?.add(h);
    }
    return grouped;
  }

  // Toggle Month Collapse state
  void toggleMonth(int monthIndex) {
    if (expandedMonths.containsKey(monthIndex)) {
      expandedMonths[monthIndex] = !expandedMonths[monthIndex]!;
    } else {
      expandedMonths[monthIndex] = true;
    }
    expandedMonths.refresh();
  }

  // Clear Form Fields for Add Mode
  void clearForm() {
    nameController.clear();
    descriptionController.clear();
    selectedDate.value = null;
    selectedType.value = 'National';
    selectedLocation.value = 'All Locations';
    repeatEveryYear.value = true;
  }

  // Populate Form Fields for Edit Mode
  void populateForm(Holiday holiday) {
    nameController.text = holiday.name;
    descriptionController.text = holiday.description;
    selectedDate.value = holiday.date;
    selectedType.value = _normalizeType(holiday.type);
    selectedLocation.value = holiday.location;
    repeatEveryYear.value = holiday.repeatEveryYear;
  }

  String _normalizeType(String type) {
    final lower = type.toLowerCase().trim();
    if (lower.contains('national')) return 'National';
    if (lower.contains('restricted')) return 'Restricted';
    if (lower.contains('optional')) return 'Optional';
    return 'National';
  }

  // Add new holiday via server API
  Future<bool> addHoliday() async {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Holiday Name is required!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
    }

    if (selectedDate.value == null) {
      Get.snackbar(
        'Validation Error',
        'Please select a date!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
    }

    final normType = _normalizeType(selectedType.value);
    final pDate = selectedDate.value!;
    final formattedDate =
        "${pDate.year}-${pDate.month.toString().padLeft(2, '0')}-${pDate.day.toString().padLeft(2, '0')}";

    final request = AddHolidayRequestModel(
      name: nameController.text.trim(),
      date: formattedDate,
      type: normType,
      location: selectedLocation.value,
      repeatEveryYear: repeatEveryYear.value,
      description: descriptionController.text.trim(),
    );

    try {
      isSubmitting.value = true;
      Logger.d('HolidaysController => Calling addHoliday API with: ${request.toJson()}');

      final response = await repository.addHoliday(request);

      if (response != null && response.status) {
        // Add to local list immediately for instant visual response
        final newHoliday = Holiday(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: request.name,
          date: pDate,
          type: request.type,
          location: request.location,
          repeatEveryYear: request.repeatEveryYear,
          description: request.description ?? '',
          addedBy: 'Admin',
          addedOn: DateTime.now(),
        );
        holidays.add(newHoliday);
        expandedMonths[pDate.month] = true;

        // Refresh from server
        fetchHolidays(isRefresh: true);

        // Also refresh LeaveCalendarController if active in memory
        if (Get.isRegistered<LeaveCalendarController>()) {
          Get.find<LeaveCalendarController>().fetchHolidays(isRefresh: true);
        }

        clearForm();
        Get.back();
        Get.snackbar(
          'Success 🎉',
          response.message ?? 'Holiday added successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return true;
      } else {
        final err = response?.message ?? 'Failed to add holiday.';
        Get.snackbar(
          'Failed',
          err,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
        return false;
      }
    } catch (e, stack) {
      Logger.e('HolidaysController => Exception in addHoliday: $e\n$stack');
      Get.snackbar(
        'Error',
        'Something went wrong: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  // Alias for backward compatibility
  void saveHoliday() {
    addHoliday();
  }

  // Update existing holiday via PATCH API
  Future<bool> updateHoliday() async {
    final current = selectedHoliday.value;
    if (current == null) return false;

    if (nameController.text.trim().isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Holiday Name is required!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
    }

    if (selectedDate.value == null) {
      Get.snackbar(
        'Validation Error',
        'Please select a date!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
    }

    final normType = _normalizeType(selectedType.value);
    final pDate = selectedDate.value!;
    final formattedDate =
        "${pDate.year}-${pDate.month.toString().padLeft(2, '0')}-${pDate.day.toString().padLeft(2, '0')}";

    final request = AddHolidayRequestModel(
      name: nameController.text.trim(),
      date: formattedDate,
      type: normType,
      location: selectedLocation.value,
      repeatEveryYear: repeatEveryYear.value,
      description: descriptionController.text.trim(),
    );

    try {
      isSubmitting.value = true;
      Logger.d('HolidaysController => Calling updateHoliday PATCH API for ID ${current.id} with: ${request.toJson()}');

      final response = await repository.updateHoliday(current.id, request);

      if (response != null && response.status) {
        final updated = current.copyWith(
          name: request.name,
          date: pDate,
          type: request.type,
          location: request.location,
          repeatEveryYear: request.repeatEveryYear,
          description: request.description ?? '',
        );

        final idx = holidays.indexWhere((h) => h.id == current.id);
        if (idx != -1) {
          holidays[idx] = updated;
        }

        selectedHoliday.value = updated;

        // Re-fetch to sync months and summary
        fetchHolidays(isRefresh: true);

        // Also fetch single holiday details if active
        fetchHolidayDetails(current.id);

        if (Get.isRegistered<LeaveCalendarController>()) {
          Get.find<LeaveCalendarController>().fetchHolidays(isRefresh: true);
        }

        clearForm();
        Get.back();
        Get.snackbar(
          'Success 🎉',
          response.message ?? 'Holiday updated successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return true;
      } else {
        final err = response?.message ?? 'Failed to update holiday.';
        Get.snackbar(
          'Failed',
          err,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
        return false;
      }
    } catch (e, stack) {
      Logger.e('HolidaysController => Exception in updateHoliday: $e\n$stack');
      Get.snackbar(
        'Error',
        'Something went wrong: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  // Delete holiday via API
  Future<bool> deleteHoliday(String id) async {
    try {
      isDeleting.value = true;
      final success = await repository.deleteHoliday(id);
      if (success) {
        holidays.removeWhere((h) => h.id == id);
        selectedHoliday.value = null;

        // Re-fetch to sync summary and months from server
        fetchHolidays(isRefresh: true);

        // Also refresh leave calendar if active
        if (Get.isRegistered<LeaveCalendarController>()) {
          Get.find<LeaveCalendarController>().fetchHolidays(isRefresh: true);
        }

        Get.snackbar(
          'Deleted 🎉',
          'Holiday deleted successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return true;
      } else {
        Get.snackbar(
          'Failed',
          'Could not delete holiday. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return false;
      }
    } catch (e, stack) {
      Logger.e('HolidaysController => Error in deleteHoliday: $e\n$stack');
      Get.snackbar(
        'Error',
        'Something went wrong: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isDeleting.value = false;
    }
  }

  void _initializeFallbackHolidays() {
    final currentYear = filterYear.value;
    holidays.addAll([
      Holiday(
        id: '1',
        name: 'Republic Day',
        date: DateTime(currentYear, 1, 26),
        type: 'National',
        location: 'All Locations',
        repeatEveryYear: true,
        description: 'Republic Day commemorates the Constitution of India.',
        addedBy: 'Admin',
        addedOn: DateTime(currentYear, 1, 5),
      ),
      Holiday(
        id: '2',
        name: 'Independence Day',
        date: DateTime(currentYear, 8, 15),
        type: 'National',
        location: 'All Locations',
        repeatEveryYear: true,
        description: 'National holiday commemorating independence.',
        addedBy: 'Admin',
        addedOn: DateTime(currentYear, 1, 10),
      ),
      Holiday(
        id: '3',
        name: 'Gandhi Jayanti',
        date: DateTime(currentYear, 10, 2),
        type: 'National',
        location: 'All Locations',
        repeatEveryYear: true,
        description: 'Celebrated to mark the birthday of Mahatma Gandhi.',
        addedBy: 'Admin',
        addedOn: DateTime(currentYear, 1, 10),
      ),
    ]);
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}
