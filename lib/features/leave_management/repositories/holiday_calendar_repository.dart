import '../../../core/constants/app_constants.dart';
import '../../../core/services/network/api_client.dart';
import '../../../core/utils/logger.dart';
import '../models/holiday_calendar_model.dart';
import 'holiday_calendar_repository_interface.dart';

class HolidayCalendarRepository implements HolidayCalendarRepositoryInterface {
  final ApiClient apiClient;

  HolidayCalendarRepository({required this.apiClient});

  @override
  Future<HolidayCalendarResponse?> getHolidays({
    required int year,
    String? location,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'year': year,
      };
      if (location != null && location.isNotEmpty) {
        queryParams['location'] = location;
      }

      Logger.d('HolidayCalendarRepository => Fetching holidays with params: $queryParams from ${AppConstants.adminHolidaysUrl}');

      final response = await apiClient.get(
        AppConstants.adminHolidaysUrl,
        queryParameters: queryParams,
        handleError: false,
        showToaster: false,
      );

      Logger.d('HolidayCalendarRepository => Response status: ${response.statusCode}, isSuccess: ${response.isSuccess}');

      if (response.json != null) {
        return HolidayCalendarResponse.fromJson(response.json!);
      } else if (response.body is Map<String, dynamic>) {
        return HolidayCalendarResponse.fromJson(response.body as Map<String, dynamic>);
      }
      return null;
    } catch (e, stackTrace) {
      Logger.e('HolidayCalendarRepository => Error fetching holidays: $e');
      Logger.e('HolidayCalendarRepository => Stack: $stackTrace');
      return null;
    }
  }
}
