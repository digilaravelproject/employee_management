import '../../models/facebook_authorization_request_model.dart';
import '../../models/facebook_authorization_response_model.dart';
import '../../repositories/lead_integrations_repository_interface.dart';

class GetFacebookAuthorizationUrlUseCase {
  final LeadIntegrationsRepositoryInterface repository;

  GetFacebookAuthorizationUrlUseCase(this.repository);

  Future<FacebookAuthorizationResponseModel> call(
    FacebookAuthorizationRequestModel request,
  ) async {
    return await repository.getFacebookAuthorizationUrl(request);
  }
}
