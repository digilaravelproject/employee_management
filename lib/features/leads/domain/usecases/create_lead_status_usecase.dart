import '../../models/lead_status_model.dart';
import '../../repositories/admin_leads_repository_interface.dart';

class CreateLeadStatusUseCase {
  final AdminLeadsRepositoryInterface repository;

  CreateLeadStatusUseCase(this.repository);

  Future<LeadStatusDetailResponseModel> call(CreateLeadStatusRequestModel request) async {
    return await repository.createLeadStatus(request);
  }
}
