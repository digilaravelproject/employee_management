import '../../models/lead_status_model.dart';
import '../../repositories/admin_leads_repository_interface.dart';

class GetLeadStatusDetailUseCase {
  final AdminLeadsRepositoryInterface repository;

  GetLeadStatusDetailUseCase(this.repository);

  Future<LeadStatusDetailResponseModel> call(dynamic id) async {
    return await repository.getLeadStatusDetail(id);
  }
}
