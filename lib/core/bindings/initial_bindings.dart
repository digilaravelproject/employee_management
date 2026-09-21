import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../controllers/app_controller.dart';
import '../services/network/api_client.dart';
import '../services/network/network_info.dart';
import 'package:dio/dio.dart';
import '../services/translations/localization_controller.dart';
import '../../features/dashboard/controllers/dashboard_controller.dart';
import '../../features/attendance/controllers/attendance_history_controller.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    // Core services
    Get.lazyPut(() => Dio(), fenix: true);
    Get.lazyPut(() => ApiClient(), fenix: true);
    Get.lazyPut(() => Connectivity(), fenix: true);
    Get.lazyPut(() => NetworkInfo(Get.find<Connectivity>()), fenix: true);
    Get.lazyPut(() => LocalizationController(), fenix: true);
    Get.put(AppController(), permanent: true);
    Get.lazyPut(() => DashboardController(), fenix: true);
    Get.lazyPut(() => AttendanceHistoryController(), fenix: true);
  }
}
