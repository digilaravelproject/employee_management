import '../models/facebook_authorization_request_model.dart';
import '../models/facebook_authorization_response_model.dart';
import '../models/lead_integrations_status_response_model.dart';

abstract class LeadIntegrationsRepositoryInterface {
  Future<FacebookAuthorizationResponseModel> getFacebookAuthorizationUrl(
    FacebookAuthorizationRequestModel request,
  );

  Future<LeadIntegrationsStatusResponseModel> getLeadIntegrationsStatus();
}
