import '../../models/lead_source_model.dart';
import '../../repositories/admin_leads_repository_interface.dart';

class GetLeadSourceDetailUseCase {
  final AdminLeadsRepositoryInterface repository;

  GetLeadSourceDetailUseCase(this.repository);

  Future<LeadSourceDetailResponseModel> call(dynamic id) {
    return repository.getLeadSourceDetail(id);
  }
}
