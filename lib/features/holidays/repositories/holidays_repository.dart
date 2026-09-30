import '../../../core/constants/app_constants.dart';
import '../../../core/services/network/api_client.dart';
import '../../../core/utils/logger.dart';
import '../../leave_management/models/holiday_calendar_model.dart';
import '../models/add_holiday_model.dart';
import '../models/holiday_details_model.dart';
import 'holidays_repository_interface.dart';

class HolidaysRepository implements HolidaysRepositoryInterface {
  final ApiClient apiClient;

  HolidaysRepository({required this.apiClient});

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

      Logger.d('HolidaysRepository => GET ${AppConstants.adminHolidaysUrl} with params: $queryParams');

      final response = await apiClient.get(
        AppConstants.adminHolidaysUrl,
        queryParameters: queryParams,
        handleError: false,
        showToaster: false,
      );

      Logger.d('HolidaysRepository => GET holidays status: ${response.statusCode}, isSuccess: ${response.isSuccess}');

      if (response.json != null) {
        return HolidayCalendarResponse.fromJson(response.json!);
      } else if (response.body is Map<String, dynamic>) {
        return HolidayCalendarResponse.fromJson(response.body as Map<String, dynamic>);
      }
      return null;
    } catch (e, stackTrace) {
      Logger.e('HolidaysRepository => Error fetching holidays: $e\n$stackTrace');
      return null;
    }
  }

  @override
  Future<AddHolidayResponseModel?> addHoliday(AddHolidayRequestModel request) async {
    try {
      Logger.d('HolidaysRepository => POST ${AppConstants.adminHolidaysUrl} with data: ${request.toJson()}');

      final response = await apiClient.post(
        AppConstants.adminHolidaysUrl,
        data: request.toJson(),
        handleError: false,
        showToaster: false,
      );

      Logger.d('HolidaysRepository => POST addHoliday status: ${response.statusCode}, isSuccess: ${response.isSuccess}');

      if (response.json != null) {
        return AddHolidayResponseModel.fromJson(response.json!);
      } else if (response.body is Map<String, dynamic>) {
        return AddHolidayResponseModel.fromJson(response.body as Map<String, dynamic>);
      } else {
        return AddHolidayResponseModel(
          status: response.isSuccess,
          message: response.message.isNotEmpty
              ? response.message
              : (response.isSuccess ? 'Holiday created successfully.' : 'Failed to add holiday.'),
        );
      }
    } catch (e, stackTrace) {
      Logger.e('HolidaysRepository => Error adding holiday: $e\n$stackTrace');
      return AddHolidayResponseModel(
        status: false,
        message: 'Something went wrong while adding holiday: $e',
      );
    }
  }

  @override
  Future<AddHolidayResponseModel?> updateHoliday(
    String id,
    AddHolidayRequestModel request,
  ) async {
    try {
      final url = '${AppConstants.adminHolidaysUrl}/$id';
      Logger.d('HolidaysRepository => PATCH $url with data: ${request.toJson()}');

      final response = await apiClient.patch(
        url,
        data: request.toJson(),
        handleError: false,
        showToaster: false,
      );

      Logger.d('HolidaysRepository => PATCH updateHoliday status: ${response.statusCode}, isSuccess: ${response.isSuccess}');

      if (response.json != null) {
        return AddHolidayResponseModel.fromJson(response.json!);
      } else if (response.body is Map<String, dynamic>) {
        return AddHolidayResponseModel.fromJson(response.body as Map<String, dynamic>);
      } else {
        return AddHolidayResponseModel(
          status: response.isSuccess,
          message: response.message.isNotEmpty
              ? response.message
              : (response.isSuccess ? 'Holiday updated successfully.' : 'Failed to update holiday.'),
        );
      }
    } catch (e, stackTrace) {
      Logger.e('HolidaysRepository => Error updating holiday $id: $e\n$stackTrace');
      return AddHolidayResponseModel(
        status: false,
        message: 'Something went wrong while updating holiday: $e',
      );
    }
  }

  @override
  Future<HolidayDetailsResponseModel?> getHolidayDetails(String id) async {
    try {
      final url = '${AppConstants.adminHolidaysUrl}/$id';
      Logger.d('HolidaysRepository => GET $url');

      final response = await apiClient.get(
        url,
        handleError: false,
        showToaster: false,
      );

      Logger.d('HolidaysRepository => GET holiday details status: ${response.statusCode}, isSuccess: ${response.isSuccess}');

      if (response.json != null) {
        return HolidayDetailsResponseModel.fromJson(response.json!);
      } else if (response.body is Map<String, dynamic>) {
        return HolidayDetailsResponseModel.fromJson(response.body as Map<String, dynamic>);
      }
      return null;
    } catch (e, stackTrace) {
      Logger.e('HolidaysRepository => Error getting holiday details $id: $e\n$stackTrace');
      return null;
    }
  }

  @override
  Future<bool> deleteHoliday(String id) async {
    try {
      final url = '${AppConstants.adminHolidaysUrl}/$id';
      Logger.d('HolidaysRepository => DELETE $url');

      final response = await apiClient.delete(
        url,
        handleError: false,
        showToaster: false,
      );

      Logger.d('HolidaysRepository => DELETE holiday status: ${response.statusCode}, isSuccess: ${response.isSuccess}');

      if (response.isSuccess) {
        return true;
      }
      if (response.json != null && response.json!['status'] == true) {
        return true;
      }
      return false;
    } catch (e, stackTrace) {
      Logger.e('HolidaysRepository => Error deleting holiday $id: $e\n$stackTrace');
      return false;
    }
  }
}
