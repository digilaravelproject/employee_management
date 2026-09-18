import 'package:get/get.dart';
import '../../../core/services/network/api_client.dart';
import '../repositories/department_repository.dart';
import '../controllers/departments_controller.dart';

class DepartmentBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiClient>()) {
      Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);
    }
    Get.lazyPut<DepartmentRepository>(
      () => DepartmentRepository(apiClient: Get.find<ApiClient>()),
    );
    Get.lazyPut<DepartmentsController>(
      () => DepartmentsController(repository: Get.find<DepartmentRepository>()),
    );
  }
}
