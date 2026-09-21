import 'package:get/get.dart';
import '../../../core/services/network/api_client.dart';
import '../controllers/admin_leave_controller.dart';
import '../repositories/admin_leave_repository.dart';
import '../repositories/admin_leave_repository_interface.dart';

class AdminLeaveBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiClient>()) {
      Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);
    }

    if (!Get.isRegistered<AdminLeaveRepositoryInterface>()) {
      Get.lazyPut<AdminLeaveRepositoryInterface>(
        () => AdminLeaveRepository(apiClient: Get.find<ApiClient>()),
        fenix: true,
      );
    }

    Get.lazyPut<AdminLeaveController>(
      () => AdminLeaveController(
        repository: Get.find<AdminLeaveRepositoryInterface>(),
      ),
      fenix: true,
    );
  }
}
