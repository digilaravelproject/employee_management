import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/network/api_client.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../../../core/utils/logger.dart';
import '../../employee/management/controllers/employee_controller.dart';
import '../../employee/management/views/employee_detail_screen.dart';
import '../models/upcoming_birthdays_model.dart';

class BirthdaysController extends GetxController {
  final ApiClient _apiClient;

  BirthdaysController({ApiClient? apiClient})
      : _apiClient = apiClient ??
            (Get.isRegistered<ApiClient>()
                ? Get.find<ApiClient>()
                : ApiClient());

  final RxList<UpcomingBirthdayItem> birthdays = <UpcomingBirthdayItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxInt selectedDays = 30.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUpcomingBirthdays();
  }

  Future<void> fetchUpcomingBirthdays({int? days, bool isRefresh = false}) async {
    final queryDays = days ?? selectedDays.value;
    selectedDays.value = queryDays;

    if (!isRefresh) {
      isLoading.value = true;
    }
    errorMessage.value = '';

    try {
      final response = await _apiClient.get(
        AppConstants.adminUpcomingBirthdaysUrl,
        queryParameters: {'days': queryDays},
        handleError: false,
        showToaster: false,
      );

      final json = response.json ??
          (response.body is Map<String, dynamic>
              ? response.body as Map<String, dynamic>
              : null);

      if (json != null) {
        final parsed = UpcomingBirthdaysResponseModel.fromJson(json);
        if (parsed.status) {
          birthdays.assignAll(parsed.data);
          Logger.d('BirthdaysController => Loaded ${parsed.data.length} upcoming birthdays for $queryDays days.');
        } else {
          errorMessage.value = parsed.message.isNotEmpty ? parsed.message : 'Failed to retrieve birthdays.';
          Logger.w('BirthdaysController => ${errorMessage.value}');
        }
      } else {
        errorMessage.value = response.message.isNotEmpty ? response.message : 'No data returned from server.';
      }
    } catch (e) {
      Logger.e('BirthdaysController => Exception loading upcoming birthdays: $e');
      errorMessage.value = 'Failed to load birthdays. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Open WhatsApp to send a warm birthday greeting
  Future<void> openWhatsAppWish(UpcomingBirthdayItem item, {String? phone}) async {
    final message = Uri.encodeComponent(
      'Dear ${item.name},\n\nWishing you a very Happy Birthday! 🎂🎉 May your special day bring you immense joy, great health, and continued success!\n\nBest regards,\nTeam',
    );
    final targetPhone = (phone != null && phone.trim().isNotEmpty) ? phone.replaceAll(RegExp(r'\D'), '') : '';
    final urlString = targetPhone.isNotEmpty
        ? 'https://wa.me/$targetPhone?text=$message'
        : 'https://wa.me/?text=$message';

    final uri = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        CustomSnackbar.showInfo('Could not launch WhatsApp. Copying birthday message.');
      }
    } catch (e) {
      Logger.e('BirthdaysController => Could not launch WhatsApp: $e');
      CustomSnackbar.showError('Unable to open WhatsApp.');
    }
  }

  /// Open default mail client to send an official birthday email
  Future<void> openEmailWish(UpcomingBirthdayItem item, {String? email}) async {
    final subject = Uri.encodeComponent('Happy Birthday, ${item.name}! 🎂🎉');
    final body = Uri.encodeComponent(
      'Dear ${item.name},\n\nWishing you a very Happy Birthday! May this year be packed with incredible milestones, personal growth, and wonderful moments.\n\nWarmest wishes,\nManagement & Team',
    );
    final targetEmail = email?.trim() ?? '';
    final uri = Uri.parse('mailto:$targetEmail?subject=$subject&body=$body');

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        CustomSnackbar.showInfo('Email client not found.');
      }
    } catch (e) {
      Logger.e('BirthdaysController => Could not launch email: $e');
      CustomSnackbar.showError('Unable to open email client.');
    }
  }

  /// Open full Employee Details Screen for the employee
  void openEmployeeProfile(UpcomingBirthdayItem item) {
    final empController = Get.isRegistered<EmployeeController>()
        ? Get.find<EmployeeController>()
        : Get.put(EmployeeController());

    // Try finding richer cached details if available in EmployeeController
    final cached = empController.employees.firstWhereOrNull(
      (e) => e.id == item.id.toString() || e.employeeId.toLowerCase() == item.employeeId.toLowerCase(),
    );

    final employeeModel = cached ?? item.toEmployeeModel();
    Get.to(() => EmployeeDetailScreen(employee: employeeModel));
  }
}
