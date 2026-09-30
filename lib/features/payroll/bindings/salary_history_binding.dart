import 'package:get/get.dart';
import '../../../core/services/network/api_client.dart';
import '../controllers/salary_history_controller.dart';
import '../repositories/payroll_repository.dart';
import '../repositories/payroll_repository_interface.dart';

class SalaryHistoryBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiClient>()) {
      Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);
    }

    if (!Get.isRegistered<PayrollRepositoryInterface>()) {
      Get.lazyPut<PayrollRepositoryInterface>(
        () => PayrollRepository(apiClient: Get.find<ApiClient>()),
        fenix: true,
      );
    }

    Get.lazyPut<SalaryHistoryController>(
      () => SalaryHistoryController(
        repository: Get.find<PayrollRepositoryInterface>(),
      ),
      fenix: true,
    );
  }
}
