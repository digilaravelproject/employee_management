import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/network/api_client.dart';
import '../../../../core/services/network/response_model.dart';
import '../../../../core/utils/logger.dart';
import '../models/create_employee_request_model.dart';
import '../models/create_employee_response_model.dart';
import '../models/employee_model.dart';
import 'employee_repository_interface.dart';

class EmployeeRepository implements EmployeeRepositoryInterface {
  final ApiClient apiClient;

  EmployeeRepository({required this.apiClient});

  @override
  Future<CreateEmployeeResponseModel> createEmployee(CreateEmployeeRequestModel request) async {
    try {
      final formData = await request.toFormData();
      final response = await apiClient.post('/api/admin/employees', data: formData);

      if (response.isSuccess && response.json != null) {
        return CreateEmployeeResponseModel.fromJson(response.json!);
      }

      return CreateEmployeeResponseModel(
        status: false,
        message: response.message.isNotEmpty ? response.message : 'Failed to create employee',
      );
    } catch (e) {
      Logger.e('EmployeeRepository => Failed to create employee: $e');
      return CreateEmployeeResponseModel(
        status: false,
        message: e.toString(),
      );
    }
  }

  @override
  Future<EmployeeListResponseModel> getEmployees() async {
    try {
      Logger.d('EmployeeRepository => Calling getEmployees at ${AppConstants.adminEmployeesUrl}');
      final response = await apiClient.get(
        AppConstants.adminEmployeesUrl,
        handleError: false,
        showToaster: false,
      );

      Logger.d('EmployeeRepository => Response status: ${response.statusCode}, isSuccess: ${response.isSuccess}');
      Logger.d('EmployeeRepository => Raw Data: ${response.json ?? response.body}');

      if (response.json != null) {
        return EmployeeListResponseModel.fromJson(response.json!);
      } else if (response.body is Map<String, dynamic>) {
        return EmployeeListResponseModel.fromJson(response.body as Map<String, dynamic>);
      } else {
        return EmployeeListResponseModel(
          status: response.isSuccess,
          message: response.message.isNotEmpty
              ? response.message
              : (response.isSuccess ? 'Employees retrieved successfully.' : 'Failed to retrieve employees.'),
          data: [],
        );
      }
    } catch (e, stackTrace) {
      Logger.e('EmployeeRepository => Exception in getEmployees: $e');
      Logger.e('EmployeeRepository => StackTrace: $stackTrace');
      return EmployeeListResponseModel(
        status: false,
        message: 'Something went wrong while fetching employees: ${e.toString()}',
        data: [],
      );
    }
  }

  @override
  Future<EmployeeDetailResponseModel> getEmployeeById(String id) async {
    try {
      Logger.d('EmployeeRepository => Calling getEmployeeById for ID: $id');
      final response = await apiClient.get(
        '/api/admin/employees/$id',
        handleError: false,
        showToaster: false,
      );

      Logger.d('EmployeeRepository => getEmployeeById status: ${response.statusCode}, isSuccess: ${response.isSuccess}');
      Logger.d('EmployeeRepository => getEmployeeById Raw Data: ${response.json ?? response.body}');

      if (response.json != null) {
        return EmployeeDetailResponseModel.fromJson(response.json!);
      } else if (response.body is Map<String, dynamic>) {
        return EmployeeDetailResponseModel.fromJson(response.body as Map<String, dynamic>);
      } else {
        return EmployeeDetailResponseModel(
          status: response.isSuccess,
          message: response.message.isNotEmpty
              ? response.message
              : (response.isSuccess ? 'Employee details retrieved successfully.' : 'Failed to retrieve employee details.'),
        );
      }
    } catch (e, stackTrace) {
      Logger.e('EmployeeRepository => Exception in getEmployeeById: $e');
      Logger.e('EmployeeRepository => StackTrace: $stackTrace');
      return EmployeeDetailResponseModel(
        status: false,
        message: 'Something went wrong while fetching employee details: ${e.toString()}',
      );
    }
  }

  @override
  Future<ResponseModel> updateEmployee(String id, Map<String, dynamic> data) async {
    try {
      Logger.d('EmployeeRepository => Calling updateEmployee for ID: $id at /api/admin/employees/$id with data: $data');
      final response = await apiClient.patch(
        '/api/admin/employees/$id',
        data: data,
        handleError: false,
        showToaster: false,
      );

      Logger.d('EmployeeRepository => updateEmployee response status: ${response.statusCode}, isSuccess: ${response.isSuccess}');
      Logger.d('EmployeeRepository => updateEmployee response data: ${response.json ?? response.body}');
      return response;
    } catch (e, stackTrace) {
      Logger.e('EmployeeRepository => Exception in updateEmployee: $e');
      Logger.e('EmployeeRepository => StackTrace: $stackTrace');
      return ResponseModel(
        isSuccess: false,
        message: 'Failed to update employee: ${e.toString()}',
      );
    }
  }

  @override
  Future<ResponseModel> updateEmployeeAvatar(String id, File imageFile) async {
    try {
      Logger.d('EmployeeRepository => Calling updateEmployeeAvatar for ID: $id at /api/admin/employees/$id');
      final filename = imageFile.path.split(Platform.pathSeparator).last;
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(
          imageFile.path,
          filename: filename,
        ),
      });

      final response = await apiClient.post(
        '/api/admin/employees/$id',
        data: formData,
        handleError: false,
        showToaster: false,
      );

      Logger.d('EmployeeRepository => updateEmployeeAvatar response status: ${response.statusCode}, isSuccess: ${response.isSuccess}');
      Logger.d('EmployeeRepository => updateEmployeeAvatar response data: ${response.json ?? response.body}');
      return response;
    } catch (e, stackTrace) {
      Logger.e('EmployeeRepository => Exception in updateEmployeeAvatar: $e');
      Logger.e('EmployeeRepository => StackTrace: $stackTrace');
      return ResponseModel(
        isSuccess: false,
        message: 'Failed to update profile image: ${e.toString()}',
      );
    }
  }

  @override
  Future<ResponseModel> deleteEmployee(String id) async {
    try {
      Logger.d('EmployeeRepository => Calling deleteEmployee for ID: $id at /api/admin/employees/$id');
      final response = await apiClient.delete(
        '/api/admin/employees/$id',
        handleError: false,
        showToaster: false,
      );

      Logger.d('EmployeeRepository => deleteEmployee response status: ${response.statusCode}, isSuccess: ${response.isSuccess}');
      return response;
    } catch (e, stackTrace) {
      Logger.e('EmployeeRepository => Exception in deleteEmployee: $e');
      Logger.e('EmployeeRepository => StackTrace: $stackTrace');
      return ResponseModel(
        isSuccess: false,
        message: 'Failed to delete employee: ${e.toString()}',
      );
    }
  }
}
