import '../models/client_model.dart';
import '../models/client_detail_model.dart';

abstract class ClientsRepositoryInterface {
  Future<List<Client>> getClients({String? status, int perPage = 15});
  Future<ClientDetailResponse> getClientDetail(dynamic id);
}
