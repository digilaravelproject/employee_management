import 'package:get/get.dart';
import '../../../../core/services/network/api_client.dart';
import '../repositories/designation_repository.dart';
import '../controllers/designation_controller.dart';

class DesignationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DesignationRepository>(
      () => DesignationRepository(apiClient: Get.find<ApiClient>()),
    );
    Get.lazyPut<DesignationController>(
      () => DesignationController(repository: Get.find<DesignationRepository>()),
    );
  }
}
