import 'package:get/get.dart';
import '../../../core/services/network/api_client.dart';
import '../controllers/holidays_controller.dart';
import '../repositories/holidays_repository.dart';
import '../repositories/holidays_repository_interface.dart';

class HolidaysBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiClient>()) {
      Get.put(ApiClient());
    }
    Get.lazyPut<HolidaysRepositoryInterface>(
      () => HolidaysRepository(apiClient: Get.find<ApiClient>()),
    );
    Get.lazyPut<HolidaysController>(
      () => HolidaysController(repository: Get.find<HolidaysRepositoryInterface>()),
    );
  }
}
