import 'package:get/get.dart';
import '../../../core/services/network/api_client.dart';
import '../../../core/utils/logger.dart';
import '../models/holiday_calendar_model.dart';
import '../repositories/holiday_calendar_repository.dart';
import '../repositories/holiday_calendar_repository_interface.dart';

class LeaveCalendarController extends GetxController {
  final HolidayCalendarRepositoryInterface repository;

  LeaveCalendarController({HolidayCalendarRepositoryInterface? repository})
      : repository = repository ??
            HolidayCalendarRepository(
              apiClient: Get.isRegistered<ApiClient>()
                  ? Get.find<ApiClient>()
                  : Get.put(ApiClient()),
            );

  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxString errorMessage = ''.obs;

  final RxInt selectedYear = DateTime.now().year.obs;
  final RxString selectedLocation = 'All Locations'.obs;

  final Rxn<HolidayCalendarResponse> holidayData = Rxn<HolidayCalendarResponse>();
  final Rxn<HolidaySummary> summary = Rxn<HolidaySummary>();
  final RxList<HolidayMonth> months = <HolidayMonth>[].obs;

  final RxList<int> availableYears = [2024, 2025, 2026]
      .where((y) => y <= DateTime.now().year)
      .toList()
      .obs;
  final RxList<String> availableLocations = [
    'All Locations',
    'Delhi HQ',
    'Mumbai Office',
    'Bangalore Tech Hub',
    'Remote',
  ].obs;

  // Track expanded state for months. Default all open or current month open.
  final RxMap<String, bool> expandedMonths = <String, bool>{}.obs;

  @override
  void onInit() {
    super.onInit();
    final now = DateTime.now();
    selectedYear.value = now.year;
    fetchHolidays();
  }

  Future<void> fetchHolidays({bool isRefresh = false}) async {
    try {
      if (isRefresh) {
        isRefreshing.value = true;
      } else {
        isLoading.value = true;
      }
      errorMessage.value = '';

      final response = await repository.getHolidays(
        year: selectedYear.value,
        location: selectedLocation.value,
      );

      if (response != null && response.status) {
        holidayData.value = response;
        summary.value = response.summary;
        months.assignAll(response.months);

        // By default, expand all months that have holidays
        for (final m in response.months) {
          if (!expandedMonths.containsKey(m.month)) {
            expandedMonths[m.month] = true;
          }
        }

        Logger.d('LeaveCalendarController => Loaded ${response.months.length} months with ${response.summary?.total ?? 0} holidays');
      } else {
        errorMessage.value = response?.message ?? 'Failed to load holidays.';
      }
    } catch (e, stack) {
      Logger.e('LeaveCalendarController => Error fetching holidays: $e\n$stack');
      errorMessage.value = 'Failed to load holidays. Please try again.';
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  void changeYear(int year) {
    if (year > DateTime.now().year) return;
    if (selectedYear.value != year) {
      selectedYear.value = year;
      fetchHolidays();
    }
  }

  void changeLocation(String location) {
    if (selectedLocation.value != location) {
      selectedLocation.value = location;
      fetchHolidays();
    }
  }

  void toggleMonth(String month) {
    expandedMonths[month] = !(expandedMonths[month] ?? true);
  }

  int get totalHolidays => summary.value?.total ?? 0;
  int get nationalHolidays => summary.value?.national ?? 0;
  int get restrictedHolidays => summary.value?.restricted ?? 0;
  int get optionalHolidays => summary.value?.optional ?? 0;
}
