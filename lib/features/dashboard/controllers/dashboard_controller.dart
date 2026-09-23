import 'package:get/get.dart';
import '../../../core/controllers/app_controller.dart';
import '../../../core/services/location/location_service.dart';
import '../../../core/services/network/api_client.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../../../core/utils/logger.dart';
import '../../attendance/models/check_in_model.dart';
import '../../attendance/repositories/attendance_repository.dart';
import '../models/employee_dashboard_model.dart';
import '../repositories/dashboard_repository.dart';

class DashboardController extends GetxController {
  final DashboardRepository _repository;
  final AttendanceRepository _attendanceRepository;

  DashboardController({
    DashboardRepository? repository,
    AttendanceRepository? attendanceRepository,
  })  : _repository = repository ??
            DashboardRepository(
              apiClient: Get.isRegistered<ApiClient>()
                  ? Get.find<ApiClient>()
                  : ApiClient(),
            ),
        _attendanceRepository = attendanceRepository ??
            AttendanceRepository(
              apiClient: Get.isRegistered<ApiClient>()
                  ? Get.find<ApiClient>()
                  : ApiClient(),
            );

  final RxInt currentIndex = 0.obs;
  final RxBool isLoading = false.obs;
  final RxBool isCheckingIn = false.obs;
  final RxBool isCheckingOut = false.obs;
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

  /// Mark employee check-in with device current GPS location
  Future<bool> checkIn({String? notes}) async {
    try {
      isCheckingIn.value = true;

      // 1. Fetch current device GPS location
      String? locationError;
      final position = await LocationService.getCurrentLocation(
        onError: (err) {
          locationError = err;
        },
      );

      if (position == null) {
        final errorMsg = locationError ?? 'Unable to retrieve current location. Please turn on GPS.';
        CustomSnackbar.showError(errorMsg);
        return false;
      }

      // 2. Prepare check-in request with current GPS latitude and longitude
      final request = CheckInRequestModel(
        latitude: position.latitude,
        longitude: position.longitude,
        notes: (notes != null && notes.trim().isNotEmpty)
            ? notes.trim()
            : 'Checked in from mobile app',
      );

      Logger.d('DashboardController => Submitting check-in with lat=${request.latitude}, long=${request.longitude}');

      // 3. Send API request
      final response = await _attendanceRepository.checkIn(request);

      if (response.status) {
        final successMsg = response.message.isNotEmpty
            ? response.message
            : 'Checked in successfully.';
        CustomSnackbar.showSuccess(successMsg);

        // 4. Refresh employee dashboard data to update the check-in time and status on UI
        await fetchEmployeeDashboard();
        return true;
      } else {
        final errorMsg = response.message.isNotEmpty
            ? response.message
            : 'Check-in failed. Please try again.';
        CustomSnackbar.showError(errorMsg);
        return false;
      }
    } catch (e) {
      Logger.e('DashboardController => Exception during check-in: $e');
      CustomSnackbar.showError('Something went wrong while checking in.');
      return false;
    } finally {
      isCheckingIn.value = false;
    }
  }

  /// Mark employee clock out / check out with device current GPS location
  Future<bool> checkOut({String? notes}) async {
    try {
      isCheckingOut.value = true;

      // 1. Fetch current device GPS location
      String? locationError;
      final position = await LocationService.getCurrentLocation(
        onError: (err) {
          locationError = err;
        },
      );

      if (position == null) {
        final errorMsg = locationError ?? 'Unable to retrieve current location. Please turn on GPS.';
        CustomSnackbar.showError(errorMsg);
        return false;
      }

      // 2. Prepare check-out request with current GPS latitude and longitude
      final request = CheckOutRequestModel(
        latitude: position.latitude,
        longitude: position.longitude,
        notes: (notes != null && notes.trim().isNotEmpty)
            ? notes.trim()
            : 'Work completed',
      );

      Logger.d('DashboardController => Submitting check-out with lat=${request.latitude}, long=${request.longitude}');

      // 3. Send API request
      final response = await _attendanceRepository.checkOut(request);

      if (response.status) {
        final successMsg = response.message.isNotEmpty
            ? response.message
            : 'Clocked out successfully.';
        CustomSnackbar.showSuccess(successMsg);

        // 4. Refresh employee dashboard data to update the check-out time and status on UI
        await fetchEmployeeDashboard();
        return true;
      } else {
        final errorMsg = response.message.isNotEmpty
            ? response.message
            : 'Clock-out failed. Please try again.';
        CustomSnackbar.showError(errorMsg);
        return false;
      }
    } catch (e) {
      Logger.e('DashboardController => Exception during check-out: $e');
      CustomSnackbar.showError('Something went wrong while clocking out.');
      return false;
    } finally {
      isCheckingOut.value = false;
    }
  }
}
