import '../../../core/constants/app_constants.dart';
import '../../../core/services/network/api_client.dart';
import '../../../core/utils/logger.dart';
import '../models/department_request_model.dart';
import '../models/department_response_model.dart';

class DepartmentRepository {
  final ApiClient apiClient;

  DepartmentRepository({required this.apiClient});

  Future<DepartmentResponseModel> createDepartment(DepartmentRequestModel data) async {
    try {
      final response = await apiClient.post(AppConstants.adminDepartmentsUrl, data: data.toJson());

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
      final response = await apiClient.get('${AppConstants.adminDepartmentsUrl}$queryParams');

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
      final response = await apiClient.get(AppConstants.adminDepartmentUrl(id));

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
      final response = await apiClient.get(AppConstants.adminSearchDepartmentsUrl(query));

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
      final response = await apiClient.patch(AppConstants.adminDepartmentUrl(id), data: data.toJson());

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
      final response = await apiClient.delete(AppConstants.adminDepartmentUrl(id));

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

  Future<DepartmentResponseModel> addEmployeesToDepartment(String departmentId, List<int> employeeIds) async {
    try {
      final response = await apiClient.post(
        AppConstants.adminDepartmentEmployeesUrl(departmentId),
        data: {'employee_ids': employeeIds},
      );

      if (response.isSuccess && response.json != null) {
        return DepartmentResponseModel.fromJson(response.json!);
      }

      return DepartmentResponseModel(
        status: false,
        message: response.message.isNotEmpty ? response.message : 'Unknown error occurred',
      );
    } catch (e) {
      Logger.e('DepartmentRepository => Failed to add employees to department: $e');
      return DepartmentResponseModel(
        status: false,
        message: e.toString(),
      );
    }
  }

  Future<DepartmentResponseModel> removeEmployeeFromDepartment(String departmentId, String employeeId) async {
    try {
      final response = await apiClient.delete(AppConstants.adminDepartmentEmployeeUrl(departmentId, employeeId));

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
