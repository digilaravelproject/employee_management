import '../models/client_detail_model.dart';
import '../models/clients_response_model.dart';

abstract class ClientsRepositoryInterface {
  Future<ClientsResponseModel> getClients({String? status, int page = 1, int perPage = 15});
  Future<ClientsResponseModel> searchClients({required String query, String? status, int page = 1, int perPage = 15});
  Future<ClientDetailResponse> getClientDetail(dynamic id);
  Future<CreateClientResponse> createClient(Map<String, dynamic> clientData);
  Future<UpdateClientResponse> updateClient(dynamic id, Map<String, dynamic> clientData);
  Future<DeleteClientResponse> deleteClient(dynamic id);
}

