import '../../models/lead_source_model.dart';
import '../../repositories/admin_leads_repository_interface.dart';

class UpdateLeadSourceUseCase {
  final AdminLeadsRepositoryInterface repository;

  UpdateLeadSourceUseCase(this.repository);

  Future<LeadSourceDetailResponseModel> call(dynamic id, UpdateLeadSourceRequestModel request) {
    return repository.updateLeadSource(id, request);
  }
}
