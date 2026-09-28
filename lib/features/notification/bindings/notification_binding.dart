import 'package:get/get.dart';
import '../../../../core/services/network/api_client.dart';
import '../controllers/notification_controller.dart';
import '../repositories/notification_repository.dart';
import '../repositories/notification_repository_interface.dart';

class NotificationBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiClient>()) {
      Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);
    }

    if (!Get.isRegistered<NotificationRepositoryInterface>()) {
      Get.lazyPut<NotificationRepositoryInterface>(
        () => NotificationRepository(apiClient: Get.find<ApiClient>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<NotificationController>()) {
      Get.lazyPut<NotificationController>(
        () => NotificationController(
          repository: Get.find<NotificationRepositoryInterface>(),
        ),
        fenix: true,
      );
    }
  }
}
