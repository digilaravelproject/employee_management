import 'package:get/get.dart';
import '../../../core/services/network/api_client.dart';
import '../controllers/shift_controller.dart';
import '../domain/usecases/assign_shift_usecase.dart';
import '../domain/usecases/create_shift_usecase.dart';
import '../domain/usecases/delete_shift_usecase.dart';
import '../domain/usecases/get_shift_details_usecase.dart';
import '../domain/usecases/get_shifts_usecase.dart';
import '../domain/usecases/update_shift_usecase.dart';
import '../repositories/shift_repository.dart';
import '../repositories/shift_repository_interface.dart';

class ShiftBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiClient>()) {
      Get.lazyPut<ApiClient>(() => ApiClient());
    }

    Get.lazyPut<ShiftRepositoryInterface>(
      () => ShiftRepository(apiClient: Get.find<ApiClient>()),
    );

    Get.lazyPut<CreateShiftUseCase>(
      () => CreateShiftUseCase(Get.find<ShiftRepositoryInterface>()),
    );

    Get.lazyPut<UpdateShiftUseCase>(
      () => UpdateShiftUseCase(Get.find<ShiftRepositoryInterface>()),
    );

    Get.lazyPut<AssignShiftUseCase>(
      () => AssignShiftUseCase(Get.find<ShiftRepositoryInterface>()),
    );

    Get.lazyPut<DeleteShiftUseCase>(
      () => DeleteShiftUseCase(Get.find<ShiftRepositoryInterface>()),
    );

    Get.lazyPut<GetShiftsUseCase>(
      () => GetShiftsUseCase(Get.find<ShiftRepositoryInterface>()),
    );

    Get.lazyPut<GetShiftDetailsUseCase>(
      () => GetShiftDetailsUseCase(Get.find<ShiftRepositoryInterface>()),
    );

    Get.lazyPut<ShiftController>(
      () => ShiftController(
        createShiftUseCase: Get.find<CreateShiftUseCase>(),
        updateShiftUseCase: Get.find<UpdateShiftUseCase>(),
        assignShiftUseCase: Get.find<AssignShiftUseCase>(),
        deleteShiftUseCase: Get.find<DeleteShiftUseCase>(),
        getShiftsUseCase: Get.find<GetShiftsUseCase>(),
        getShiftDetailsUseCase: Get.find<GetShiftDetailsUseCase>(),
      ),
    );
  }
}
