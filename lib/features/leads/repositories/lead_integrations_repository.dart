import '../../../core/constants/app_constants.dart';
import '../../../core/services/network/api_client.dart';
import '../../../core/utils/logger.dart';
import '../models/facebook_authorization_request_model.dart';
import '../models/facebook_authorization_response_model.dart';
import '../models/lead_integrations_status_response_model.dart';
import 'lead_integrations_repository_interface.dart';

class LeadIntegrationsRepository implements LeadIntegrationsRepositoryInterface {
  final ApiClient apiClient;

  LeadIntegrationsRepository({required this.apiClient});

  @override
  Future<FacebookAuthorizationResponseModel> getFacebookAuthorizationUrl(
    FacebookAuthorizationRequestModel request,
  ) async {
    try {
      final response = await apiClient.post(
        AppConstants.facebookAuthorizationUrl,
        data: request.toJson(),
      );

      if (response.isSuccess && response.json != null) {
        return FacebookAuthorizationResponseModel.fromJson(response.json!);
      }

      return FacebookAuthorizationResponseModel(
        status: false,
        message: response.message.isNotEmpty
            ? response.message
            : 'Failed to retrieve Facebook authorization URL',
      );
    } catch (e) {
      Logger.e('LeadIntegrationsRepository => Failed to get Facebook auth URL: $e');
      return FacebookAuthorizationResponseModel(
        status: false,
        message: e.toString(),
      );
    }
  }

  @override
  Future<LeadIntegrationsStatusResponseModel> getLeadIntegrationsStatus() async {
    try {
      final response = await apiClient.get(
        AppConstants.leadIntegrationsStatusUrl,
      );

      if (response.isSuccess && response.json != null) {
        return LeadIntegrationsStatusResponseModel.fromJson(response.json!);
      }

      return LeadIntegrationsStatusResponseModel(
        status: false,
        message: response.message.isNotEmpty
            ? response.message
            : 'Failed to retrieve lead integrations status',
      );
    } catch (e) {
      Logger.e('LeadIntegrationsRepository => Failed to get integration status: $e');
      return LeadIntegrationsStatusResponseModel(
        status: false,
        message: e.toString(),
      );
    }
  }
}
