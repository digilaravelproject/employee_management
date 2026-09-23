import 'package:get/get.dart';
import '../../../core/services/network/api_client.dart';
import '../controllers/apply_leave_controller.dart';
import '../domain/usecases/apply_leave_usecase.dart';
import '../domain/usecases/get_leave_types_usecase.dart';
import '../repositories/apply_leave_repository.dart';
import '../repositories/apply_leave_repository_interface.dart';

class ApplyLeaveBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiClient>()) {
      Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);
    }

    if (!Get.isRegistered<ApplyLeaveRepositoryInterface>()) {
      Get.lazyPut<ApplyLeaveRepositoryInterface>(
        () => ApplyLeaveRepository(apiClient: Get.find<ApiClient>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<GetLeaveTypesUseCase>()) {
      Get.lazyPut<GetLeaveTypesUseCase>(
        () => GetLeaveTypesUseCase(Get.find<ApplyLeaveRepositoryInterface>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<ApplyLeaveUseCase>()) {
      Get.lazyPut<ApplyLeaveUseCase>(
        () => ApplyLeaveUseCase(Get.find<ApplyLeaveRepositoryInterface>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<ApplyLeaveController>()) {
      Get.lazyPut<ApplyLeaveController>(
        () => ApplyLeaveController(
          getLeaveTypesUseCase: Get.find<GetLeaveTypesUseCase>(),
          applyLeaveUseCase: Get.find<ApplyLeaveUseCase>(),
        ),
        fenix: true,
      );
    }
  }
}
