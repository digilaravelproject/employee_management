import 'package:get/get.dart';
import '../../../core/controllers/app_controller.dart';
import '../../../core/services/network/api_client.dart';
import '../../../core/utils/logger.dart';
import '../models/employee_dashboard_model.dart';
import '../repositories/dashboard_repository.dart';

class DashboardController extends GetxController {
  final DashboardRepository _repository;

  DashboardController({DashboardRepository? repository})
      : _repository = repository ??
            DashboardRepository(
              apiClient: Get.isRegistered<ApiClient>()
                  ? Get.find<ApiClient>()
                  : ApiClient(),
            );

  final RxInt currentIndex = 0.obs;
  final RxBool isLoading = false.obs;
  final Rxn<EmployeeDashboardData> employeeDashboardData =
      Rxn<EmployeeDashboardData>();

  void changeIndex(int index) {
    currentIndex.value = index;
  }

  @override
  void onInit() {
    super.onInit();
    _initDashboardData();

    if (Get.isRegistered<AppController>()) {
      ever(Get.find<AppController>().userRole, (role) {
        if (role != 'admin') {
          fetchEmployeeDashboard();
        }
      });
    }
  }

  void _initDashboardData() {
    if (Get.isRegistered<AppController>()) {
      final role = Get.find<AppController>().userRole.value;
      if (role != 'admin') {
        fetchEmployeeDashboard();
      }
    } else {
      fetchEmployeeDashboard();
    }
  }

  Future<void> fetchEmployeeDashboard() async {
    try {
      isLoading.value = true;
      final response = await _repository.getEmployeeDashboard();
      if (response.status && response.data != null) {
        employeeDashboardData.value = response.data;
        Logger.d('DashboardController => Employee Dashboard loaded successfully: ${response.data?.greeting}');
      } else {
        Logger.w('DashboardController => Failed to load employee dashboard: ${response.message}');
      }
    } catch (e) {
      Logger.e('DashboardController => Exception loading employee dashboard: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
