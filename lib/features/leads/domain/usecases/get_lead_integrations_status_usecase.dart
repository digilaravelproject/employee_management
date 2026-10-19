import '../../models/lead_integrations_status_response_model.dart';
import '../../repositories/lead_integrations_repository_interface.dart';

class GetLeadIntegrationsStatusUseCase {
  final LeadIntegrationsRepositoryInterface repository;

  GetLeadIntegrationsStatusUseCase(this.repository);

  Future<LeadIntegrationsStatusResponseModel> call() async {
    return await repository.getLeadIntegrationsStatus();
  }
}
