import 'package:get/get.dart';
import '../../../core/services/network/api_client.dart';
import '../controllers/employee_performance_detail_controller.dart';
import '../controllers/performance_controller.dart';
import '../repositories/performance_repository.dart';
import '../repositories/performance_repository_interface.dart';

class PerformanceBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiClient>()) {
      Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);
    }

    if (!Get.isRegistered<PerformanceRepositoryInterface>()) {
      Get.lazyPut<PerformanceRepositoryInterface>(
        () => PerformanceRepository(apiClient: Get.find<ApiClient>()),
        fenix: true,
      );
    }

    Get.lazyPut<PerformanceController>(
      () => PerformanceController(
        repository: Get.find<PerformanceRepositoryInterface>(),
      ),
      fenix: true,
    );

    Get.lazyPut<EmployeePerformanceDetailController>(
      () => EmployeePerformanceDetailController(
        repository: Get.find<PerformanceRepositoryInterface>(),
      ),
      fenix: true,
    );
  }
}
