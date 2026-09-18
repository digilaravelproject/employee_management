import '../../../../core/services/network/api_client.dart';
import '../../../../core/services/network/response_model.dart';
import '../../../../core/utils/logger.dart';
import '../models/designation_request_model.dart';
import '../models/designation_response_model.dart';
import '../models/designation_list_response_model.dart';

class DesignationRepository {
  final ApiClient apiClient;

  DesignationRepository({required this.apiClient});

  Future<DesignationResponseModel> createDesignation(DesignationRequestModel data) async {
    try {
      final response = await apiClient.post('/api/admin/designations', data: data.toJson());
      
      if (response.isSuccess && response.json != null) {
        return DesignationResponseModel.fromJson(response.json!);
      }
      
      return DesignationResponseModel(
        status: false,
        message: response.message ?? 'Unknown error occurred',
      );
    } catch (e) {
      Logger.e('DesignationRepository => Failed to create designation: $e');
      return DesignationResponseModel(
        status: false,
        message: e.toString(),
      );
    }
  }

  Future<DesignationResponseModel> updateDesignation(String id, DesignationRequestModel data) async {
    try {
      final response = await apiClient.patch('/api/admin/designations/$id', data: data.toJson());
      
      if (response.isSuccess && response.json != null) {
        return DesignationResponseModel.fromJson(response.json!);
      }
      
      return DesignationResponseModel(
        status: false,
        message: response.message ?? 'Unknown error occurred',
      );
    } catch (e) {
      Logger.e('DesignationRepository => Failed to update designation: $e');
      return DesignationResponseModel(
        status: false,
        message: e.toString(),
      );
    }
  }

  Future<DesignationResponseModel> deleteDesignation(String id) async {
    try {
      final response = await apiClient.delete('/api/admin/designations/$id');
      
      if (response.isSuccess && response.json != null) {
        return DesignationResponseModel.fromJson(response.json!);
      }
      
      return DesignationResponseModel(
        status: false,
        message: response.message ?? 'Unknown error occurred',
      );
    } catch (e) {
      Logger.e('DesignationRepository => Failed to delete designation: $e');
      return DesignationResponseModel(
        status: false,
        message: e.toString(),
      );
    }
  }

  Future<DesignationResponseModel> removeEmployeeFromDesignation(String designationId, String employeeId) async {
    try {
      final response = await apiClient.delete('/api/admin/designations/$designationId/employees/$employeeId');
      
      if (response.isSuccess && response.json != null) {
        return DesignationResponseModel.fromJson(response.json!);
      }
      
      return DesignationResponseModel(
        status: false,
        message: response.message ?? 'Unknown error occurred',
      );
    } catch (e) {
      Logger.e('DesignationRepository => Failed to remove employee: $e');
      return DesignationResponseModel(
        status: false,
        message: e.toString(),
      );
    }
  }

  Future<DesignationListResponseModel> getDesignations() async {
    try {
      final response = await apiClient.get('/api/admin/designations');
      
      if (response.isSuccess && response.json != null) {
        return DesignationListResponseModel.fromJson(response.json!);
      }
      
      return DesignationListResponseModel(
        status: false,
        message: response.message ?? 'Unknown error occurred',
        total: 0,
        data: [],
      );
    } catch (e) {
      Logger.e('DesignationRepository => Failed to get designations: $e');
      return DesignationListResponseModel(
        status: false,
        message: e.toString(),
        total: 0,
        data: [],
      );
    }
  }

  Future<DesignationResponseModel> getDesignationDetails(String id) async {
    try {
      final response = await apiClient.get('/api/admin/designations/$id');
      
      if (response.isSuccess && response.json != null) {
        return DesignationResponseModel.fromJson(response.json!);
      }
      
      return DesignationResponseModel(
        status: false,
        message: response.message ?? 'Unknown error occurred',
      );
    } catch (e) {
      Logger.e('DesignationRepository => Failed to get designation details: $e');
      return DesignationResponseModel(
        status: false,
        message: e.toString(),
      );
    }
  }
}
