import '../../../core/services/network/api_client.dart';
import '../../../core/utils/logger.dart';
import '../models/create_shift_request_model.dart';
import '../models/shift_response_model.dart';
import 'shift_repository_interface.dart';

class ShiftRepository implements ShiftRepositoryInterface {
  final ApiClient apiClient;

  ShiftRepository({required this.apiClient});

  @override
  Future<ShiftResponseModel> createShift(CreateShiftRequestModel request) async {
    try {
      final response = await apiClient.post(
        '/api/admin/shifts',
        data: request.toJson(),
      );

      if (response.isSuccess && response.json != null) {
        return ShiftResponseModel.fromJson(response.json!);
      }

      return ShiftResponseModel(
        status: false,
        message: response.message.isNotEmpty ? response.message : 'Failed to create shift',
      );
    } catch (e) {
      Logger.e('ShiftRepository => Failed to create shift: $e');
      return ShiftResponseModel(
        status: false,
        message: e.toString(),
      );
    }
  }

  @override
  Future<ShiftResponseModel> updateShift(String id, CreateShiftRequestModel request) async {
    try {
      final response = await apiClient.put(
        '/api/admin/shifts/$id',
        data: request.toJson(),
      );

      if (response.isSuccess && response.json != null) {
        return ShiftResponseModel.fromJson(response.json!);
      }

      return ShiftResponseModel(
        status: false,
        message: response.message.isNotEmpty ? response.message : 'Failed to update shift',
      );
    } catch (e) {
      Logger.e('ShiftRepository => Failed to update shift: $e');
      return ShiftResponseModel(
        status: false,
        message: e.toString(),
      );
    }
  }

  @override
  Future<ShiftResponseModel> assignEmployeesToShift(String shiftId, List<int> employeeIds) async {
    try {
      final response = await apiClient.put(
        '/api/admin/shifts/$shiftId',
        data: {
          'employee_ids': employeeIds,
        },
      );

      if (response.isSuccess && response.json != null) {
        return ShiftResponseModel.fromJson(response.json!);
      }

      return ShiftResponseModel(
        status: response.isSuccess,
        message: response.message.isNotEmpty
            ? response.message
            : (response.isSuccess ? 'Shift assigned successfully.' : 'Failed to assign shift.'),
      );
    } catch (e) {
      Logger.e('ShiftRepository => Failed to assign shift: $e');
      return ShiftResponseModel(
        status: false,
        message: e.toString(),
      );
    }
  }

  @override
  Future<ShiftResponseModel> deleteShift(String id) async {
    try {
      final response = await apiClient.delete('/api/admin/shifts/$id');

      if (response.isSuccess && response.json != null) {
        return ShiftResponseModel.fromJson(response.json!);
      }

      return ShiftResponseModel(
        status: response.isSuccess,
        message: response.message.isNotEmpty
            ? response.message
            : (response.isSuccess ? 'Shift deleted successfully' : 'Failed to delete shift'),
      );
    } catch (e) {
      Logger.e('ShiftRepository => Failed to delete shift: $e');
      return ShiftResponseModel(
        status: false,
        message: e.toString(),
      );
    }
  }

  @override
  Future<ShiftListResponseModel> getShifts({String? status}) async {
    try {
      final queryParams = (status != null && status.isNotEmpty && status != 'All Status')
          ? '?status=$status'
          : '';
      final response = await apiClient.get('/api/admin/shifts$queryParams');

      if (response.isSuccess && response.json != null) {
        return ShiftListResponseModel.fromJson(response.json!);
      }

      return ShiftListResponseModel(
        status: false,
        message: response.message.isNotEmpty ? response.message : 'Failed to retrieve shifts',
        data: [],
      );
    } catch (e) {
      Logger.e('ShiftRepository => Failed to retrieve shifts: $e');
      return ShiftListResponseModel(
        status: false,
        message: e.toString(),
        data: [],
      );
    }
  }

  @override
  Future<ShiftResponseModel> getShiftDetails(String id) async {
    try {
      final response = await apiClient.get('/api/admin/shifts/$id');

      if (response.isSuccess && response.json != null) {
        return ShiftResponseModel.fromJson(response.json!);
      }

      return ShiftResponseModel(
        status: false,
        message: response.message.isNotEmpty ? response.message : 'Failed to retrieve shift details',
      );
    } catch (e) {
      Logger.e('ShiftRepository => Failed to retrieve shift details: $e');
      return ShiftResponseModel(
        status: false,
        message: e.toString(),
      );
    }
  }
}
