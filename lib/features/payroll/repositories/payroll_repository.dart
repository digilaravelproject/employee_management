import '../../../core/constants/app_constants.dart';
import '../../../core/services/network/api_client.dart';
import '../../../core/utils/logger.dart';
import '../models/salary_detail_model.dart';
import '../models/salary_history_model.dart';
import '../models/salary_model.dart';
import 'payroll_repository_interface.dart';

class PayrollRepository implements PayrollRepositoryInterface {
  final ApiClient apiClient;

  PayrollRepository({required this.apiClient});

  @override
  Future<SalaryListResponseModel?> getSalaries({
    required String month,
    String? search,
    String? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'month': month,
      };

      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }

      if (status != null && status.trim().isNotEmpty) {
        queryParams['status'] = status.trim().toLowerCase();
      } else {
        queryParams['status'] = 'all';
      }

      Logger.d('PayrollRepository => GET ${AppConstants.adminSalariesUrl} with params: $queryParams');

      final response = await apiClient.get(
        AppConstants.adminSalariesUrl,
        queryParameters: queryParams,
        handleError: false,
        showToaster: false,
      );

      Logger.d('PayrollRepository => Response status: ${response.statusCode}, isSuccess: ${response.isSuccess}');

      if (response.json != null) {
        return SalaryListResponseModel.fromJson(response.json!);
      } else if (response.body is Map<String, dynamic>) {
        return SalaryListResponseModel.fromJson(response.body as Map<String, dynamic>);
      }
      return null;
    } catch (e, stackTrace) {
      Logger.e('PayrollRepository => Error in getSalaries: $e');
      Logger.e('PayrollRepository => Stack: $stackTrace');
      return null;
    }
  }

  @override
  Future<SalaryDetailResponseModel?> getEmployeeSalaryDetails({
    required String employeeId,
    required String month,
  }) async {
    try {
      final url = AppConstants.adminSalaryEmployeeDetailsUrl(employeeId);
      final queryParams = <String, dynamic>{
        'month': month,
      };

      Logger.d('PayrollRepository => GET $url with params: $queryParams');

      final response = await apiClient.get(
        url,
        queryParameters: queryParams,
        handleError: false,
        showToaster: false,
      );

      Logger.d('PayrollRepository => Detail response status: ${response.statusCode}, isSuccess: ${response.isSuccess}');

      if (response.json != null) {
        return SalaryDetailResponseModel.fromJson(response.json!);
      } else if (response.body is Map<String, dynamic>) {
        return SalaryDetailResponseModel.fromJson(response.body as Map<String, dynamic>);
      }
      return null;
    } catch (e, stackTrace) {
      Logger.e('PayrollRepository => Error in getEmployeeSalaryDetails: $e');
      Logger.e('PayrollRepository => Stack: $stackTrace');
      return null;
    }
  }

  @override
  Future<CreateSalaryResponseModel?> createSalary(CreateSalaryRequestModel request) async {
    try {
      Logger.d('PayrollRepository => POST ${AppConstants.adminSalariesUrl} with data: ${request.toJson()}');

      final response = await apiClient.post(
        AppConstants.adminSalariesUrl,
        data: request.toJson(),
        handleError: false,
        showToaster: false,
      );

      Logger.d('PayrollRepository => Create salary status: ${response.statusCode}, isSuccess: ${response.isSuccess}');

      if (response.json != null) {
        return CreateSalaryResponseModel.fromJson(response.json!);
      } else if (response.body is Map<String, dynamic>) {
        return CreateSalaryResponseModel.fromJson(response.body as Map<String, dynamic>);
      } else {
        return CreateSalaryResponseModel(
          status: response.isSuccess,
          message: response.message.isNotEmpty
              ? response.message
              : (response.isSuccess ? 'Salary created successfully.' : 'Failed to create salary.'),
        );
      }
    } catch (e, stackTrace) {
      Logger.e('PayrollRepository => Error in createSalary: $e');
      Logger.e('PayrollRepository => Stack: $stackTrace');
      return CreateSalaryResponseModel(
        status: false,
        message: 'Something went wrong while creating salary: $e',
      );
    }
  }

  @override
  Future<SalaryHistoryResponseModel?> getSalaryHistory({int? year}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (year != null) {
        queryParams['year'] = year.toString();
      }

      Logger.d('PayrollRepository => GET ${AppConstants.adminSalaryHistoryUrl} with params: $queryParams');

      final response = await apiClient.get(
        AppConstants.adminSalaryHistoryUrl,
        queryParameters: queryParams,
        handleError: false,
        showToaster: false,
      );

      Logger.d('PayrollRepository => Salary history status: ${response.statusCode}, isSuccess: ${response.isSuccess}');

      if (response.json != null) {
        return SalaryHistoryResponseModel.fromJson(response.json!);
      } else if (response.body is Map<String, dynamic>) {
        return SalaryHistoryResponseModel.fromJson(response.body as Map<String, dynamic>);
      }
      return null;
    } catch (e, stackTrace) {
      Logger.e('PayrollRepository => Error in getSalaryHistory: $e');
      Logger.e('PayrollRepository => Stack: $stackTrace');
      return null;
    }
  }
}


