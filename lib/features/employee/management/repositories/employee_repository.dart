import '../../../../core/services/network/api_client.dart';
import '../../../../core/utils/logger.dart';
import '../models/create_employee_request_model.dart';
import '../models/create_employee_response_model.dart';
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
}
