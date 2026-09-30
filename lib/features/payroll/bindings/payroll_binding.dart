import 'package:get/get.dart';
import '../../../core/services/network/api_client.dart';
import '../controllers/payroll_controller.dart';
import '../repositories/payroll_repository.dart';
import '../repositories/payroll_repository_interface.dart';

class PayrollBinding extends Bindings {
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

    if (!Get.isRegistered<PayrollController>()) {
      Get.lazyPut<PayrollController>(
        () => PayrollController(
          repository: Get.find<PayrollRepositoryInterface>(),
        ),
        fenix: true,
      );
    }
  }
}
