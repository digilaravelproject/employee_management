import '../models/admin_leads_request_model.dart';
import '../models/admin_leads_response_model.dart';
import '../models/sales_employee_model.dart';

abstract class AdminLeadsRepositoryInterface {
  Future<AdminLeadsResponseModel> getAdminLeads(AdminLeadsRequestModel request);
  Future<AdminLeadDetailResponseModel> getAdminLeadDetail(dynamic id);
  Future<SalesEmployeesResponseModel> getSalesEmployees();
  Future<AdminLeadDetailResponseModel> createAdminLead(CreateAdminLeadRequestModel request);
  Future<AdminLeadDetailResponseModel> assignLead(dynamic leadId, AssignLeadRequestModel request);
}
