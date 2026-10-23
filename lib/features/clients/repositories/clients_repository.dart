import '../../../core/constants/app_constants.dart';
import '../../../core/services/network/api_client.dart';
import '../../../core/utils/logger.dart';
import '../models/client_model.dart';
import '../models/client_detail_model.dart';
import 'clients_repository_interface.dart';

class ClientsRepository implements ClientsRepositoryInterface {
  final ApiClient apiClient;

  ClientsRepository({required this.apiClient});

  @override
  Future<List<Client>> getClients({String? status, int perPage = 15}) async {
    try {
      final query = <String, dynamic>{
        'status': (status == null || status.toLowerCase() == 'all') ? 'all' : status.toLowerCase(),
        'per_page': perPage,
      };

      final response = await apiClient.get(
        AppConstants.adminClientsUrl,
        queryParameters: query,
      );

      if (response.isSuccess && response.json != null) {
        final json = response.json!;
        if (json['data'] is List) {
          final list = (json['data'] as List)
              .whereType<Map<String, dynamic>>()
              .map((e) => Client.fromJson(e))
              .toList();
          return list;
        }
      }

      return [];
    } catch (e) {
      Logger.e('ClientsRepository => getClients error: $e');
      return [];
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
}
