import '../../../core/services/network/api_client.dart';
import '../../../core/utils/logger.dart';
import '../models/department_request_model.dart';
import '../models/department_response_model.dart';

class DepartmentRepository {
  final ApiClient apiClient;

  DepartmentRepository({required this.apiClient});

  Future<DepartmentResponseModel> createDepartment(DepartmentRequestModel data) async {
    try {
      final response = await apiClient.post('/api/admin/departments', data: data.toJson());

      if (response.isSuccess && response.json != null) {
        return DepartmentResponseModel.fromJson(response.json!);
      }

      return DepartmentResponseModel(
        status: false,
        message: response.message.isNotEmpty ? response.message : 'Unknown error occurred',
      );
    } catch (e) {
      Logger.e('DepartmentRepository => Failed to create department: $e');
      return DepartmentResponseModel(
        status: false,
        message: e.toString(),
      );
    }
  }

  Future<DepartmentListResponseModel> getDepartments({String? status}) async {
    try {
      final queryParams = status != null ? '?status=$status' : '';
      final response = await apiClient.get('/api/admin/departments$queryParams');

      if (response.isSuccess && response.json != null) {
        return DepartmentListResponseModel.fromJson(response.json!);
      }

      return DepartmentListResponseModel(
        status: false,
        message: response.message.isNotEmpty ? response.message : 'Unknown error occurred',
      );
    } catch (e) {
      Logger.e('DepartmentRepository => Failed to get departments: $e');
      return DepartmentListResponseModel(
        status: false,
        message: e.toString(),
      );
    }
  }

  Future<DepartmentResponseModel> getDepartmentDetails(String id) async {
    try {
      final response = await apiClient.get('/api/admin/departments/$id');

      if (response.isSuccess && response.json != null) {
        return DepartmentResponseModel.fromJson(response.json!);
      }

      return DepartmentResponseModel(
        status: false,
        message: response.message.isNotEmpty ? response.message : 'Unknown error occurred',
      );
    } catch (e) {
      Logger.e('DepartmentRepository => Failed to get department details: $e');
      return DepartmentResponseModel(
        status: false,
        message: e.toString(),
      );
    }
  }

  Future<DepartmentListResponseModel> searchDepartments(String query) async {
    try {
      final response = await apiClient.get('/api/admin/departments/search?query=$query');

      if (response.isSuccess && response.json != null) {
        return DepartmentListResponseModel.fromJson(response.json!);
      }

      return DepartmentListResponseModel(
        status: false,
        message: response.message.isNotEmpty ? response.message : 'Unknown error occurred',
      );
    } catch (e) {
      Logger.e('DepartmentRepository => Failed to search departments: $e');
      return DepartmentListResponseModel(
        status: false,
        message: e.toString(),
      );
    }
  }

  Future<DepartmentResponseModel> updateDepartment(String id, DepartmentRequestModel data) async {
    try {
      final response = await apiClient.patch('/api/admin/departments/$id', data: data.toJson());

      if (response.isSuccess && response.json != null) {
        return DepartmentResponseModel.fromJson(response.json!);
      }

      return DepartmentResponseModel(
        status: false,
        message: response.message.isNotEmpty ? response.message : 'Unknown error occurred',
      );
    } catch (e) {
      Logger.e('DepartmentRepository => Failed to update department: $e');
      return DepartmentResponseModel(
        status: false,
        message: e.toString(),
      );
    }
  }

  Future<DepartmentResponseModel> deleteDepartment(String id) async {
    try {
      final response = await apiClient.delete('/api/admin/departments/$id');

      if (response.isSuccess && response.json != null) {
        return DepartmentResponseModel.fromJson(response.json!);
      }

      return DepartmentResponseModel(
        status: false,
        message: response.message.isNotEmpty ? response.message : 'Unknown error occurred',
      );
    } catch (e) {
      Logger.e('DepartmentRepository => Failed to delete department: $e');
      return DepartmentResponseModel(
        status: false,
        message: e.toString(),
      );
    }
  }

  Future<DepartmentResponseModel> removeEmployeeFromDepartment(String departmentId, String employeeId) async {
    try {
      final response = await apiClient.delete('/api/admin/departments/$departmentId/employees/$employeeId');

      if (response.isSuccess && response.json != null) {
        return DepartmentResponseModel.fromJson(response.json!);
      }

      return DepartmentResponseModel(
        status: false,
        message: response.message.isNotEmpty ? response.message : 'Unknown error occurred',
      );
    } catch (e) {
      Logger.e('DepartmentRepository => Failed to remove employee: $e');
      return DepartmentResponseModel(
        status: false,
        message: e.toString(),
      );
    }
  }
}
