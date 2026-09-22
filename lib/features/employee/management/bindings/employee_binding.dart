import 'package:get/get.dart';
import '../../../../core/services/network/api_client.dart';
import '../controllers/employee_controller.dart';
import '../domain/usecases/create_employee_usecase.dart';
import '../repositories/employee_repository.dart';
import '../repositories/employee_repository_interface.dart';

class EmployeeBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiClient>()) {
      Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);
    }

    if (!Get.isRegistered<EmployeeRepositoryInterface>()) {
      Get.lazyPut<EmployeeRepositoryInterface>(
        () => EmployeeRepository(apiClient: Get.find<ApiClient>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<CreateEmployeeUseCase>()) {
      Get.lazyPut<CreateEmployeeUseCase>(
        () => CreateEmployeeUseCase(Get.find<EmployeeRepositoryInterface>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<EmployeeController>()) {
      Get.lazyPut<EmployeeController>(
        () => EmployeeController(
          createEmployeeUseCase: Get.find<CreateEmployeeUseCase>(),
        ),
        fenix: true,
      );
    }
  }
}
