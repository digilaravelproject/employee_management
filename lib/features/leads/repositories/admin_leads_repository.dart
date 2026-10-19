import '../../../core/constants/app_constants.dart';
import '../../../core/services/network/api_client.dart';
import '../../../core/utils/logger.dart';
import '../models/admin_leads_request_model.dart';
import '../models/admin_leads_response_model.dart';
import '../models/lead_status_model.dart';
import '../models/sales_employee_model.dart';
import 'admin_leads_repository_interface.dart';

class AdminLeadsRepository implements AdminLeadsRepositoryInterface {
  final ApiClient apiClient;

  AdminLeadsRepository({required this.apiClient});

  @override
  Future<AdminLeadsResponseModel> getAdminLeads(AdminLeadsRequestModel request) async {
    try {
      final isSearch = request.search != null && request.search!.trim().isNotEmpty;
      final endpoint = isSearch
          ? AppConstants.adminLeadsSearchUrl
          : AppConstants.adminLeadsUrl;
      final queryParams = isSearch
          ? request.toSearchParams()
          : request.toQueryParams();

      final response = await apiClient.get(
        endpoint,
        queryParameters: queryParams,
      );

      if (response.isSuccess && response.json != null) {
        return AdminLeadsResponseModel.fromJson(response.json!);
      }

      return AdminLeadsResponseModel(
        status: false,
        message: response.message.isNotEmpty ? response.message : 'Failed to retrieve leads',
        data: [],
      );
    } catch (e) {
      Logger.e('AdminLeadsRepository => Failed to retrieve leads: $e');
      return AdminLeadsResponseModel(
        status: false,
        message: e.toString(),
        data: [],
      );
    }
  }

  @override
  Future<AdminLeadDetailResponseModel> getAdminLeadDetail(dynamic id) async {
    try {
      final response = await apiClient.get(AppConstants.adminLeadDetailUrl(id));

      if (response.isSuccess && response.json != null) {
        return AdminLeadDetailResponseModel.fromJson(response.json!);
      }

      return AdminLeadDetailResponseModel(
        status: false,
        message: response.message.isNotEmpty
            ? response.message
            : 'Failed to retrieve lead details',
      );
    } catch (e) {
      Logger.e('AdminLeadsRepository => Failed to retrieve lead details: $e');
      return AdminLeadDetailResponseModel(
        status: false,
        message: e.toString(),
      );
    }
  }

  @override
  Future<SalesEmployeesResponseModel> getSalesEmployees() async {
    try {
      final response = await apiClient.get(AppConstants.adminSalesEmployeesUrl);

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
      Logger.e('AdminLeadsRepository => Failed to retrieve sales employees: $e');
      return SalesEmployeesResponseModel(
        status: false,
        message: e.toString(),
        data: [],
      );
    }
  }

  @override
  Future<AdminLeadDetailResponseModel> createAdminLead(CreateAdminLeadRequestModel request) async {
    try {
      final response = await apiClient.post(
        AppConstants.adminLeadsUrl,
        data: request.toJson(),
      );

      if (response.isSuccess && response.json != null) {
        return AdminLeadDetailResponseModel.fromJson(response.json!);
      }

      return AdminLeadDetailResponseModel(
        status: false,
        message: response.message.isNotEmpty
            ? response.message
            : 'Failed to create lead',
      );
    } catch (e) {
      Logger.e('AdminLeadsRepository => Failed to create lead: $e');
      return AdminLeadDetailResponseModel(
        status: false,
        message: e.toString(),
      );
    }
  }

  @override
  Future<AdminLeadDetailResponseModel> assignLead(dynamic leadId, AssignLeadRequestModel request) async {
    try {
      final response = await apiClient.post(
        AppConstants.adminAssignLeadUrl(leadId),
        data: request.toJson(),
      );

      if (response.isSuccess && response.json != null) {
        return AdminLeadDetailResponseModel.fromJson(response.json!);
      }

      return AdminLeadDetailResponseModel(
        status: false,
        message: response.message.isNotEmpty
            ? response.message
            : 'Failed to assign lead',
      );
    } catch (e) {
      Logger.e('AdminLeadsRepository => Failed to assign lead: $e');
      return AdminLeadDetailResponseModel(
        status: false,
        message: e.toString(),
      );
    }
  }

  @override
  Future<LeadStatusesResponseModel> getLeadStatuses({String? category}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (category != null && category.trim().isNotEmpty && category.trim().toLowerCase() != 'all') {
        queryParams['category'] = category.trim();
      }

      final response = await apiClient.get(
        AppConstants.adminLeadStatusesUrl,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

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
      Logger.e('AdminLeadsRepository => Failed to retrieve lead statuses: $e');
      return LeadStatusesResponseModel(
        status: false,
        message: e.toString(),
        data: [],
      );
    }
  }

  @override
  Future<LeadStatusDetailResponseModel> getLeadStatusDetail(dynamic id) async {
    try {
      final response = await apiClient.get(AppConstants.adminLeadStatusDetailUrl(id));

      if (response.isSuccess && response.json != null) {
        return LeadStatusDetailResponseModel.fromJson(response.json!);
      }

      return LeadStatusDetailResponseModel(
        status: false,
        message: response.message.isNotEmpty
            ? response.message
            : 'Failed to retrieve lead status details',
      );
    } catch (e) {
      Logger.e('AdminLeadsRepository => Failed to retrieve lead status details: $e');
      return LeadStatusDetailResponseModel(
        status: false,
        message: e.toString(),
      );
    }
  }

  @override
  Future<LeadStatusDetailResponseModel> createLeadStatus(CreateLeadStatusRequestModel request) async {
    try {
      final response = await apiClient.post(
        AppConstants.adminLeadStatusesUrl,
        data: request.toJson(),
      );

      if (response.isSuccess && response.json != null) {
        return LeadStatusDetailResponseModel.fromJson(response.json!);
      }

      return LeadStatusDetailResponseModel(
        status: false,
        message: response.message.isNotEmpty
            ? response.message
            : 'Failed to create lead status',
      );
    } catch (e) {
      Logger.e('AdminLeadsRepository => Failed to create lead status: $e');
      return LeadStatusDetailResponseModel(
        status: false,
        message: e.toString(),
      );
    }
  }

  @override
  Future<LeadStatusDetailResponseModel> updateLeadStatus(dynamic id, CreateLeadStatusRequestModel request) async {
    try {
      final response = await apiClient.patch(
        AppConstants.adminLeadStatusDetailUrl(id),
        data: request.toJson(),
      );

      if (response.isSuccess && response.json != null) {
        return LeadStatusDetailResponseModel.fromJson(response.json!);
      }

      return LeadStatusDetailResponseModel(
        status: false,
        message: response.message.isNotEmpty
            ? response.message
            : 'Failed to update lead status',
      );
    } catch (e) {
      Logger.e('AdminLeadsRepository => Failed to update lead status: $e');
      return LeadStatusDetailResponseModel(
        status: false,
        message: e.toString(),
      );
    }
  }

  @override
  Future<bool> deleteLeadStatus(dynamic id) async {
    try {
      final response = await apiClient.delete(AppConstants.adminLeadStatusDetailUrl(id));
      return response.isSuccess;
    } catch (e) {
      Logger.e('AdminLeadsRepository => Failed to delete lead status: $e');
      return false;
    }
  }
}
