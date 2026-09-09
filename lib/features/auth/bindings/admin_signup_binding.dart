import 'package:get/get.dart';
import '../../../../core/services/network/api_client.dart';
import '../controllers/admin_signup_controller.dart';
import '../domain/repositories/admin_signup_repository.dart';
import '../domain/repositories/admin_signup_repository_interface.dart';
import '../domain/usecases/admin_signup_usecase.dart';

class AdminSignupBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiClient>()) {
      Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);
    }

    Get.lazyPut<AdminSignupRepositoryInterface>(
      () => AdminSignupRepository(Get.find<ApiClient>()),
      fenix: true,
    );

    Get.lazyPut<AdminSignupUseCase>(
      () => AdminSignupUseCase(Get.find<AdminSignupRepositoryInterface>()),
      fenix: true,
    );

    Get.lazyPut<AdminLoginUseCase>(
      () => AdminLoginUseCase(Get.find<AdminSignupRepositoryInterface>()),
      fenix: true,
    );

    Get.lazyPut<AdminForgotPasswordUseCase>(
      () => AdminForgotPasswordUseCase(Get.find<AdminSignupRepositoryInterface>()),
      fenix: true,
    );

    Get.lazyPut<AdminResetPasswordUseCase>(
      () => AdminResetPasswordUseCase(Get.find<AdminSignupRepositoryInterface>()),
      fenix: true,
    );

    Get.lazyPut<AdminSignupController>(
      () => AdminSignupController(
        adminSignupUseCase: Get.find<AdminSignupUseCase>(),
        adminLoginUseCase: Get.find<AdminLoginUseCase>(),
        adminForgotPasswordUseCase: Get.find<AdminForgotPasswordUseCase>(),
        adminResetPasswordUseCase: Get.find<AdminResetPasswordUseCase>(),
      ),
      fenix: true,
    );
  }
}
