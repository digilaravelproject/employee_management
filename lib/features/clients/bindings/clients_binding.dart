import 'package:get/get.dart';
import '../../../core/services/network/api_client.dart';
import '../controllers/clients_controller.dart';
import '../repositories/clients_repository.dart';
import '../repositories/clients_repository_interface.dart';

class ClientsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiClient>()) {
      Get.lazyPut<ApiClient>(() => ApiClient());
    }

    if (!Get.isRegistered<ClientsRepositoryInterface>()) {
      Get.lazyPut<ClientsRepositoryInterface>(
        () => ClientsRepository(apiClient: Get.find<ApiClient>()),
      );
    }

    if (!Get.isRegistered<ClientsController>()) {
      Get.lazyPut<ClientsController>(
        () => ClientsController(repository: Get.find<ClientsRepositoryInterface>()),
      );
    }
  }
}
