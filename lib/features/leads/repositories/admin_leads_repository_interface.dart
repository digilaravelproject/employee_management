import '../models/admin_leads_request_model.dart';
import '../models/admin_leads_response_model.dart';
import '../models/lead_status_model.dart';
import '../models/sales_employee_model.dart';

abstract class AdminLeadsRepositoryInterface {
  Future<AdminLeadsResponseModel> getAdminLeads(AdminLeadsRequestModel request);
  Future<AdminLeadDetailResponseModel> getAdminLeadDetail(dynamic id);
  Future<SalesEmployeesResponseModel> getSalesEmployees();
  Future<AdminLeadDetailResponseModel> createAdminLead(CreateAdminLeadRequestModel request);
  Future<AdminLeadDetailResponseModel> assignLead(dynamic leadId, AssignLeadRequestModel request);
  Future<LeadStatusesResponseModel> getLeadStatuses({String? category});
  Future<LeadStatusDetailResponseModel> getLeadStatusDetail(dynamic id);
  Future<LeadStatusDetailResponseModel> createLeadStatus(CreateLeadStatusRequestModel request);
  Future<LeadStatusDetailResponseModel> updateLeadStatus(dynamic id, CreateLeadStatusRequestModel request);
  Future<bool> deleteLeadStatus(dynamic id);
}
