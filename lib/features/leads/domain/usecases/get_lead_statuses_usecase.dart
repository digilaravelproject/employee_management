import '../../models/lead_status_model.dart';
import '../../repositories/admin_leads_repository_interface.dart';

class GetLeadStatusesUseCase {
  final AdminLeadsRepositoryInterface repository;

  GetLeadStatusesUseCase(this.repository);

  Future<LeadStatusesResponseModel> call({String? category}) async {
    return await repository.getLeadStatuses(category: category);
  }
}
