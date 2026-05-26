import '../models/language_model.dart';
import '../services/config/env_config.dart';
import 'app_text_constants.dart';

class AppConstants {
  static String appName = "Office Management";
  static String baseUrl = "https://beige-stingray-620454.hostingersite.com";
  static String imageBaseUrl = "https://beige-stingray-620454.hostingersite.com/storage";
  static String apiToken = EnvConfig.apiToken;
  static const String googleMapsKey = 'AIzaSyAH2m4kQwGljzCxdDdy7JrnKTDKCgFZU_A';
  static const String fontFamily = 'Poppins';
  static const String defaultTag = 'PCB_APP'; // default tag for log checking

  static const bool isHandleInternetScreen = true;
  static const bool isHandleErrorScreen = false;
  static const bool handleError = true; // manages logic-level error flow.
  static const bool showToaster = false; // manages UI-level notifications.
  
  static List<Language> languages = [
    Language(code: 'en_US', name: AppTextConstants.english, nativeName: 'English', symbol: 'en', flag: '🇺🇸'),
    Language(code: 'hi_IN', name: AppTextConstants.hindi, nativeName: 'हिंदी', symbol: 'hi', flag: '🇮🇳'),
    Language(code: 'mr_IN', name: AppTextConstants.marathi, nativeName: 'मराठी', symbol: 'mr', flag: '🇮🇳'),
    Language(code: 'gu_IN', name: AppTextConstants.gujarati, nativeName: 'ગુજરાતી', symbol: 'gu', flag: '🇮🇳'),
  ];

  // API base URLs
  static  String imageUrl = '$baseUrl';

  // API endpoints
  static const String sendOtpUrl = '/api/auth/send-otp';
  static const String resendOtpUrl = '/api/auth/resend-login-otp';
  static const String verifyLoginOtpUrl = '/api/auth/verify-login-otp';
  static const String registerSendOtpUrl = '/api/auth/register/send-otp';
  static const String plansListUrl = '/api/plans/list';
  static const String createSubscriptionUrl = '/api/v1/subscriptions';
  static const String verifyPaymentUrl = '/api/v1/subscriptions/verify-payment';
  static const String currentSubscriptionUrl = '/api/v1/subscriptions/current';
  static const String subscriptionsHistoryUrl = '/api/v1/subscriptions';
  static const String logoutUrl = '/api/v1/auth/logout';
  static const String profileUrl = '/api/v1/auth/me';
  static const String updateProfileUrl = '/api/v1/auth/profile/update';
  static const String userSignupUrl = '/api/user_signup';
  static const String userLoginUrl = '/api/user_login';
  static const String otpVerifyUrl = '/api/otp_verify';
  static const String documentTemplatesEndpoint = '/api/v1/document-templates/';

  // Shared Preferences keys
  static const String theme = 'theme';
  static const String language = 'language';
  static const String token = 'token';
  static const String userData = 'user_data';
  static const String profileData = 'profile_data';
  static const String isLoggedIn = 'is_logged_in';
  static const String leadsUrl = '/api/v1/leads';
  static String convertLeadToTripUrl(dynamic id) => '/api/v1/leads/$id/convert-to-trip';
  static String getLeadBillUrl(dynamic id) => '/api/v1/leads/$id/bill';
  static const String tripsUrl = '/api/v1/trips';
  static String getTripDetailsUrl(dynamic id) => '/api/v1/trips/$id';
  static const String availableVehiclesUrl = '/api/v1/trips/vehicles/list';
  static const String availableDriversUrl = '/api/v1/trips/drivers/list';
  static String assignVehiclesUrl(dynamic id) => '/api/v1/trips/$id/assign-vehicles';
  static String assignDriversUrl(dynamic id) => '/api/v1/trips/$id/assign-drivers';
  static String updateTripUrl(dynamic id) => '/api/v1/trips/$id';
  static String deleteTripUrl(dynamic id) => '/api/v1/trips/$id';
  static String getTripInvoiceUrl(dynamic id) => '/api/v1/trips/$id/invoice';
  static String removeTripVehicles(dynamic id) => '/api/v1/trips/$id/remove-vehicles';
  static String removeTripDrivers(dynamic id) => '/api/v1/trips/$id/remove-drivers';
  static String updateTripStatusUrl(dynamic id) => '/api/v1/trips/$id/status';
  static String tripPaymentUrl(dynamic id) => '/api/v1/trips/$id/payment';


  static const String createShift = '/api/v1/shifts';
  static const String getShift = '/api/v1/shifts';
  static  String getShiftById(int id) => '/api/v1/shifts/$id';

  // Role Endpoints
  static const String rolesUrl = '/api/v1/roles';
  static const String getRolesUrl = '/api/v1/roles';
  static const String createRoleUrl = '/api/v1/roles';
  static String updateRoleUrl(dynamic id) => '/api/v1/roles/$id';
  static String getRoleByIdUrl(dynamic id) => '/api/v1/roles/$id';

  // Route Endpoints
  static const String routesUrl = '/api/v1/routes';
  static const String createVendorUrl = '/api/v1/vendors';
  static const String getRoutesUrl = '/api/v1/routes';
  static const String createRouteUrl = '/api/v1/routes';
  static String searchRoutesUrl(String query) => '/api/v1/routes/search?query=$query';
  static String updateRouteUrl(dynamic id) => '/api/v1/routes/$id';
  static String getRouteByIdUrl(dynamic id) => '/api/v1/routes/$id';

  // Inventory Endpoints
  static const String inventoryListUrl = '/api/v1/inventories';
  static String inventoryDetailsUrl(int id) => '/api/v1/inventories/$id';
  static String inventoryDeleteUrl(int id) => '/api/v1/inventories/$id?force=1';
  static String inventoryStocksUrl(int id) => '/api/v1/inventories/$id/stocks';
  static String stockInUrl(int id) => '/api/v1/inventories/$id/stock-in';
  static String stockOutUrl(int id) => '/api/v1/inventories/$id/stock-out';




  static const String staffUrl = '/api/v1/staff';
  static const String getStaffUrl = '/api/v1/staff';
  static const String createStaffUrl = '/api/v1/staff';
  static String updateStaffUrl(dynamic id) => '/api/v1/staff/$id';
  static String getStaffDetailsUrl(dynamic id) => '/api/v1/staff/$id';
  static String getStaffDocumentsUrl(dynamic id) => '/api/v1/staff/$id/documents';
  static String uploadStaffDocumentUrl(dynamic id) => '/api/v1/staff/$id/document';
  static String deleteStaffUrl(dynamic id) => '/api/v1/staff/$id';
  static String getStaffPerformanceUrl(dynamic id) => '/api/v1/staff/$id/performance-report';
  static String getStaffAdvancesUrl(dynamic id) => '/api/v1/staff/$id/advances';
  static String recordStaffAdvanceUrl(dynamic id) => '/api/v1/staff/$id/advance';
  static String getStaffSalaryHistoryUrl(dynamic id) => '/api/v1/staff/$id/salary';
  static String paySalaryUrl(dynamic id) => '/api/v1/staff/$id/pay-salary';
  static String getStaffDutyHoursUrl(dynamic id) => '/api/v1/staff/$id/duty-hours';
  static const String attendanceUrl = '/api/v1/attendance';

  // Vehicle Endpoints
  static const String vehiclesUrl = '/api/v1/vehicles';
  static const String getVehiclesUrl = '/api/v1/vehicles';
  static const String getVehicleStatsUrl = '/api/v1/vehicles/stats';
  static String updateVehicleUrl(dynamic id) => '/api/v1/vehicles/$id';
  static String deleteVehicleUrl(dynamic id) => '/api/v1/vehicles/$id';

  // Vehicle Activity Endpoints (Fuel, Service, Repair)
  static String vehicleFuelUrl(dynamic vehicleId) => '/api/v1/vehicles/$vehicleId/activity/fuel';
  static String vehicleServiceUrl(dynamic vehicleId) => '/api/v1/vehicles/$vehicleId/activity/service';
  static String vehicleRepairUrl(dynamic vehicleId) => '/api/v1/vehicles/$vehicleId/activity/repair';
  static String vehicleDocumentsUrl(dynamic vehicleId) => '/api/v1/vehicles/$vehicleId/documents';
  static String vehicleTimelineUrl(dynamic vehicleId) => '/api/v1/vehicles/$vehicleId/timeline';
  static String vehicleServiceDetailsUrl(dynamic vehicleId, dynamic serviceId) => '/api/v1/vehicles/$vehicleId/activity/service/$serviceId';
  static String vehicleRepairDetailsUrl(dynamic vehicleId, dynamic repairId) => '/api/v1/vehicles/$vehicleId/activity/repair/$repairId';
  static String vehicleServicePaymentUrl(dynamic vehicleId, dynamic serviceId) => '/api/v1/vehicles/$vehicleId/activity/service/$serviceId/payment';
  static String vehicleRepairPaymentUrl(dynamic vehicleId, dynamic repairId) => '/api/v1/vehicles/$vehicleId/activity/repair/$repairId/payment';

  static String getFileUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    return '$baseUrl/storage/$path';
  }





  // Vehicle Type Endpoints
  static const String vehicleTypesUrl = '/api/v1/vehicle-types';
  static const String getVehicleTypesUrl = '/api/v1/vehicle-types';
  static String getVehicleTypesPagedUrl(int page) => '/api/v1/vehicle-types?page=$page&per_page=10';
  static String searchVehicleTypesUrl(String query, int page) => '/api/v1/vehicle-types/search?q=$query&page=$page&per_page=10';
  static String updateVehicleTypeUrl(dynamic id) => '/api/v1/vehicle-types/$id';
  static String deleteVehicleTypeUrl(dynamic id) => '/api/v1/vehicle-types/$id';


}
