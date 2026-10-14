import '../../models/admin_leads_request_model.dart';
import '../../models/admin_leads_response_model.dart';
import '../../repositories/admin_leads_repository_interface.dart';

class AssignLeadUseCase {
  final AdminLeadsRepositoryInterface repository;

  AssignLeadUseCase(this.repository);

  Future<AdminLeadDetailResponseModel> call(dynamic leadId, AssignLeadRequestModel request) async {
    return await repository.assignLead(leadId, request);
  }
}
