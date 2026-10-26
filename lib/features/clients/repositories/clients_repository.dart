import '../../../core/constants/app_constants.dart';
import '../../../core/services/network/api_client.dart';
import '../../../core/utils/logger.dart';
import '../models/client_detail_model.dart';
import '../models/clients_response_model.dart';
import 'clients_repository_interface.dart';

class ClientsRepository implements ClientsRepositoryInterface {
  final ApiClient apiClient;

  ClientsRepository({required this.apiClient});

  @override
  Future<ClientsResponseModel> getClients({String? status, int page = 1, int perPage = 15}) async {
    try {
      final query = <String, dynamic>{
        'status': (status == null || status.toLowerCase() == 'all') ? 'all' : status.toLowerCase(),
        'page': page,
        'per_page': perPage,
      };

      final response = await apiClient.get(
        AppConstants.adminClientsUrl,
        queryParameters: query,
        showToaster: false,
      );

      if (response.isSuccess && response.json != null) {
        return ClientsResponseModel.fromJson(response.json!);
      }

      return ClientsResponseModel(
        status: false,
        message: response.message.isNotEmpty ? response.message : 'Failed to retrieve clients.',
        data: [],
      );
    } catch (e) {
      Logger.e('ClientsRepository => getClients error: $e');
      return ClientsResponseModel(
        status: false,
        message: e.toString(),
        data: [],
      );
    }
  }

  @override
  Future<ClientsResponseModel> searchClients({
    required String query,
    String? status,
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'query': query,
        'status': (status == null || status.toLowerCase() == 'all') ? 'all' : status.toLowerCase(),
        'page': page,
        'per_page': perPage,
      };

      final response = await apiClient.get(
        AppConstants.adminClientsSearchUrl,
        queryParameters: queryParams,
        showToaster: false,
      );

      if (response.isSuccess && response.json != null) {
        return ClientsResponseModel.fromJson(response.json!);
      }

      return ClientsResponseModel(
        status: false,
        message: response.message.isNotEmpty ? response.message : 'Failed to search clients.',
        data: [],
      );
    } catch (e) {
      Logger.e('ClientsRepository => searchClients error: $e');
      return ClientsResponseModel(
        status: false,
        message: e.toString(),
        data: [],
      );
    }
  }

  @override
  Future<ClientDetailResponse> getClientDetail(dynamic id) async {
    try {
      final endpoint = AppConstants.adminClientDetailUrl(id);
      final response = await apiClient.get(endpoint);

      if (response.isSuccess && response.json != null) {
        return ClientDetailResponse.fromJson(response.json!);
      }

      return ClientDetailResponse(
        status: false,
        message: response.message.isNotEmpty ? response.message : 'Failed to retrieve client details.',
      );
    } catch (e) {
      Logger.e('ClientsRepository => getClientDetail error: $e');
      return ClientDetailResponse(
        status: false,
        message: e.toString(),
      );
    }
  }

  @override
  Future<CreateClientResponse> createClient(Map<String, dynamic> clientData) async {
    try {
      final response = await apiClient.post(
        AppConstants.adminClientsUrl,
        data: clientData,
        showToaster: false,
      );

      if (response.isSuccess && response.json != null) {
        return CreateClientResponse.fromJson(response.json!);
      }

      return CreateClientResponse(
        status: false,
        message: response.message.isNotEmpty ? response.message : 'Failed to create client.',
      );
    } catch (e) {
      Logger.e('ClientsRepository => createClient error: $e');
      return CreateClientResponse(
        status: false,
        message: e.toString(),
      );
    }
  }

  @override
  Future<UpdateClientResponse> updateClient(dynamic id, Map<String, dynamic> clientData) async {
    try {
      final endpoint = AppConstants.adminClientDetailUrl(id);
      final response = await apiClient.patch(
        endpoint,
        data: clientData,
        showToaster: false,
      );

      if (response.isSuccess && response.json != null) {
        return UpdateClientResponse.fromJson(response.json!);
      }

      return UpdateClientResponse(
        status: false,
        message: response.message.isNotEmpty ? response.message : 'Failed to update client.',
      );
    } catch (e) {
      Logger.e('ClientsRepository => updateClient error: $e');
      return UpdateClientResponse(
        status: false,
        message: e.toString(),
      );
    }
  }

  @override
  Future<DeleteClientResponse> deleteClient(dynamic id) async {
    try {
      final endpoint = AppConstants.adminClientDetailUrl(id);
      final response = await apiClient.delete(
        endpoint,
        showToaster: false,
      );

      if (response.isSuccess && response.json != null) {
        return DeleteClientResponse.fromJson(response.json!);
      }

      return DeleteClientResponse(
        status: false,
        message: response.message.isNotEmpty ? response.message : 'Failed to delete client.',
      );
    } catch (e) {
      Logger.e('ClientsRepository => deleteClient error: $e');
      return DeleteClientResponse(
        status: false,
        message: e.toString(),
      );
    }
  }
}

