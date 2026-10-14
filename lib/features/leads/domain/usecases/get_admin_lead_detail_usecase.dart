import '../../models/admin_leads_response_model.dart';
import '../../repositories/admin_leads_repository_interface.dart';

class GetAdminLeadDetailUseCase {
  final AdminLeadsRepositoryInterface repository;

  GetAdminLeadDetailUseCase(this.repository);

  Future<AdminLeadDetailResponseModel> execute(dynamic id) async {
    return await repository.getAdminLeadDetail(id);
  }
}
