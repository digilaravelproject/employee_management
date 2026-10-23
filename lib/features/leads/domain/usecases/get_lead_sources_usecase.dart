import '../../models/lead_source_model.dart';
import '../../repositories/admin_leads_repository_interface.dart';

class GetLeadSourcesUseCase {
  final AdminLeadsRepositoryInterface repository;

  GetLeadSourcesUseCase(this.repository);

  Future<LeadSourcesResponseModel> call({String status = 'all'}) async {
    return await repository.getLeadSources(status: status);
  }
}
