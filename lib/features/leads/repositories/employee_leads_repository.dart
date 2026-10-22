import '../../../core/constants/app_constants.dart';
import '../../../core/services/network/api_client.dart';
import '../../../core/services/network/response_model.dart';
import '../../../core/utils/logger.dart';
import '../models/employee_leads_response_model.dart';
import '../models/lead_status_model.dart';
import '../models/sales_employee_model.dart';

abstract class EmployeeLeadsRepositoryInterface {
  Future<EmployeeLeadsResponseModel> getEmployeeLeads({
    int page = 1,
    int perPage = 20,
    String? status,
    String? search,
  });

  Future<EmployeeLeadDetailResponseModel> getEmployeeLeadDetail(dynamic leadId);

  Future<SalesEmployeesResponseModel> getSalesEmployees({String? search});

  Future<ResponseModel> assignLead(
    dynamic leadId, {
    required int employeeId,
    required String reason,
    String? notes,
  });

  Future<LeadStatusesResponseModel> getLeadStatuses();

  Future<ResponseModel> updateLeadStatus(
    dynamic leadId, {
    required String status,
    String? callNote,
    dynamic statusId,
    String? slug,
  });
}

class EmployeeLeadsRepository implements EmployeeLeadsRepositoryInterface {
  final ApiClient apiClient;

  EmployeeLeadsRepository({required this.apiClient});

  @override
  Future<EmployeeLeadsResponseModel> getEmployeeLeads({
    int page = 1,
    int perPage = 20,
    String? status,
    String? search,
  }) async {
    try {
      final isSearch = search != null && search.trim().isNotEmpty;
      final endpoint = isSearch
          ? AppConstants.employeeLeadsSearchUrl
          : AppConstants.employeeLeadsUrl;

      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': perPage,
      };

      if (isSearch) {
        queryParams['q'] = search.trim();
      }

      if (status != null && status.trim().isNotEmpty && status.trim().toLowerCase() != 'all') {
        queryParams['status'] = status.trim();
      }

      final response = await apiClient.get(
        endpoint,
        queryParameters: queryParams,
      );

      if (response.isSuccess && response.json != null) {
        return EmployeeLeadsResponseModel.fromJson(response.json!);
      }

      return EmployeeLeadsResponseModel(
        status: false,
        message: response.message.isNotEmpty
            ? response.message
            : 'Failed to retrieve employee leads',
        data: [],
      );
    } catch (e) {
      Logger.e('EmployeeLeadsRepository => Failed to retrieve leads: $e');
      return EmployeeLeadsResponseModel(
        status: false,
        message: e.toString(),
        data: [],
      );
    }
  }

  @override
  Future<EmployeeLeadDetailResponseModel> getEmployeeLeadDetail(dynamic leadId) async {
    try {
      final endpoint = AppConstants.employeeLeadDetailUrl(leadId);
      final response = await apiClient.get(endpoint);

      if (response.isSuccess && response.json != null) {
        return EmployeeLeadDetailResponseModel.fromJson(response.json!);
      }

      return EmployeeLeadDetailResponseModel(
        status: false,
        message: response.message.isNotEmpty
            ? response.message
            : 'Failed to retrieve lead details',
        data: null,
      );
    } catch (e) {
      Logger.e('EmployeeLeadsRepository => Failed to retrieve lead detail ($leadId): $e');
      return EmployeeLeadDetailResponseModel(
        status: false,
        message: e.toString(),
        data: null,
      );
    }
  }

  @override
  Future<SalesEmployeesResponseModel> getSalesEmployees({String? search}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (search != null && search.trim().isNotEmpty) {
        queryParams['q'] = search.trim();
      }

      final response = await apiClient.get(
        AppConstants.employeeSalesEmployeesUrl,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.isSuccess && response.json != null) {
        return SalesEmployeesResponseModel.fromJson(response.json!);
      }

      return SalesEmployeesResponseModel(
        status: false,
        message: response.message.isNotEmpty
            ? response.message
            : 'Failed to retrieve sales employees',
        data: [],
      );
    } catch (e) {
      Logger.e('EmployeeLeadsRepository => Failed to retrieve sales employees: $e');
      return SalesEmployeesResponseModel(
        status: false,
        message: e.toString(),
        data: [],
      );
    }
  }

  @override
  Future<ResponseModel> assignLead(
    dynamic leadId, {
    required int employeeId,
    required String reason,
    String? notes,
  }) async {
    try {
      final endpoint = AppConstants.employeeAssignLeadUrl(leadId);
      final data = <String, dynamic>{
        'employee_id': employeeId,
        'reason': reason,
      };
      if (notes != null && notes.trim().isNotEmpty) {
        data['notes'] = notes.trim();
      }

      final response = await apiClient.post(
        endpoint,
        data: data,
      );

      return response;
    } catch (e) {
      Logger.e('EmployeeLeadsRepository => Failed to assign lead ($leadId): $e');
      return ResponseModel(
        isSuccess: false,
        message: e.toString(),
      );
    }
  }

  @override
  Future<LeadStatusesResponseModel> getLeadStatuses() async {
    try {
      final response = await apiClient.get(AppConstants.adminLeadStatusesUrl);

      if (response.isSuccess && response.json != null) {
        return LeadStatusesResponseModel.fromJson(response.json!);
      }

      return LeadStatusesResponseModel(
        status: false,
        message: response.message.isNotEmpty
            ? response.message
            : 'Failed to retrieve lead statuses',
        data: [],
      );
    } catch (e) {
      Logger.e('EmployeeLeadsRepository => Failed to retrieve lead statuses: $e');
      return LeadStatusesResponseModel(
        status: false,
        message: e.toString(),
        data: [],
      );
    }
  }

  @override
  Future<ResponseModel> updateLeadStatus(
    dynamic leadId, {
    required String status,
    String? callNote,
    dynamic statusId,
    String? slug,
  }) async {
    try {
      final endpoint = AppConstants.employeeLeadStatusUrl(leadId);
      final data = <String, dynamic>{
        'status': status,
      };
      if (statusId != null) {
        data['status_id'] = statusId;
        data['lead_status_id'] = statusId;
      }
      if (slug != null && slug.isNotEmpty) {
        data['status_slug'] = slug;
        data['slug'] = slug;
      }
      if (callNote != null && callNote.trim().isNotEmpty) {
        data['call_note'] = callNote.trim();
      }

      final response = await apiClient.patch(
        endpoint,
        data: data,
      );

      return response;
    } catch (e) {
      Logger.e('EmployeeLeadsRepository => Failed to update lead status ($leadId): $e');
      return ResponseModel(
        isSuccess: false,
        message: e.toString(),
      );
    }
  }
}
