import 'package:get/get.dart';
import '../../../core/services/network/api_client.dart';
import '../controllers/leave_calendar_controller.dart';
import '../repositories/holiday_calendar_repository.dart';
import '../repositories/holiday_calendar_repository_interface.dart';

class LeaveCalendarBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiClient>()) {
      Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);
    }

    if (!Get.isRegistered<HolidayCalendarRepositoryInterface>()) {
      Get.lazyPut<HolidayCalendarRepositoryInterface>(
        () => HolidayCalendarRepository(apiClient: Get.find<ApiClient>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<LeaveCalendarController>()) {
      Get.lazyPut<LeaveCalendarController>(
        () => LeaveCalendarController(
          repository: Get.find<HolidayCalendarRepositoryInterface>(),
        ),
        fenix: true,
      );
    }
  }
}
