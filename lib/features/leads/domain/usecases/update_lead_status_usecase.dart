import '../../models/lead_status_model.dart';
import '../../repositories/admin_leads_repository_interface.dart';

class UpdateLeadStatusUseCase {
  final AdminLeadsRepositoryInterface repository;

  UpdateLeadStatusUseCase(this.repository);

  Future<LeadStatusDetailResponseModel> call(dynamic id, CreateLeadStatusRequestModel request) async {
    return await repository.updateLeadStatus(id, request);
  }
}
