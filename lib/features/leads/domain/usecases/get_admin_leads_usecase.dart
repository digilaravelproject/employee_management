import '../../models/admin_leads_request_model.dart';
import '../../models/admin_leads_response_model.dart';
import '../../repositories/admin_leads_repository_interface.dart';

class GetAdminLeadsUseCase {
  final AdminLeadsRepositoryInterface repository;

  GetAdminLeadsUseCase(this.repository);

  Future<AdminLeadsResponseModel> execute(AdminLeadsRequestModel request) async {
    return await repository.getAdminLeads(request);
  }
}
