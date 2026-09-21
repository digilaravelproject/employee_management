import '../../../core/services/network/api_client.dart';
import '../models/employee_dashboard_model.dart';

class DashboardRepository {
  final ApiClient apiClient;

  DashboardRepository({required this.apiClient});

  Future<EmployeeDashboardResponseModel> getEmployeeDashboard() async {
    final response = await apiClient.get('/api/admin/dashboard', handleError: false, showToaster: false);
    final json = response.json ?? (response.body is Map<String, dynamic> ? response.body as Map<String, dynamic> : null);
    if (json != null) {
      return EmployeeDashboardResponseModel.fromJson(json);
    }
    return EmployeeDashboardResponseModel(
      status: false,
      message: response.message.isNotEmpty ? response.message : 'Invalid response format',
    );
  }
}
