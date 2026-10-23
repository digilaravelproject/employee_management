import '../../models/lead_source_model.dart';
import '../../repositories/admin_leads_repository_interface.dart';

class CreateLeadSourceUseCase {
  final AdminLeadsRepositoryInterface repository;

  CreateLeadSourceUseCase(this.repository);

  Future<LeadSourceDetailResponseModel> call(CreateLeadSourceRequestModel request) {
    return repository.createLeadSource(request);
  }
}
