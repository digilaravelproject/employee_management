import '../../models/admin_leads_request_model.dart';
import '../../models/admin_leads_response_model.dart';
import '../../repositories/admin_leads_repository_interface.dart';

class CreateAdminLeadUseCase {
  final AdminLeadsRepositoryInterface repository;

  CreateAdminLeadUseCase(this.repository);

  Future<AdminLeadDetailResponseModel> call(CreateAdminLeadRequestModel request) async {
    return await repository.createAdminLead(request);
  }
}
