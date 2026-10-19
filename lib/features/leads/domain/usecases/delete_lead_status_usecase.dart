import '../../repositories/admin_leads_repository_interface.dart';

class DeleteLeadStatusUseCase {
  final AdminLeadsRepositoryInterface repository;

  DeleteLeadStatusUseCase(this.repository);

  Future<bool> call(dynamic id) async {
    return await repository.deleteLeadStatus(id);
  }
}
