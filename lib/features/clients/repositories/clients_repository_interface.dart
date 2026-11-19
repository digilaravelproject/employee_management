import 'package:dio/dio.dart';
import '../models/client_detail_model.dart';
import '../models/clients_response_model.dart';

abstract class ClientsRepositoryInterface {
  Future<ClientsResponseModel> getClients({String? status, int page = 1, int perPage = 15});
  Future<ClientsResponseModel> searchClients({required String query, String? status, int page = 1, int perPage = 15});
  Future<ClientDetailResponse> getClientDetail(dynamic id);
  Future<CreateClientResponse> createClient(Map<String, dynamic> clientData);
  Future<UpdateClientResponse> updateClient(dynamic id, Map<String, dynamic> clientData);
  Future<DeleteClientResponse> deleteClient(dynamic id);
  Future<AddClientCommunicationResponse> addCommunication({
    required dynamic clientId,
    required FormData formData,
  });
  Future<SingleClientCommunicationResponse> getCommunicationDetail({
    required dynamic clientId,
    required dynamic communicationId,
  });
  Future<UpdateClientCommunicationResponse> updateCommunication({
    required dynamic clientId,
    required dynamic communicationId,
    required Map<String, dynamic> data,
  });
  Future<DeleteClientResponse> deleteCommunication({
    required dynamic clientId,
    required dynamic communicationId,
  });
  Future<AddClientProjectResponse> addClientProject({
    required dynamic clientId,
    required Map<String, dynamic> data,
  });
  Future<ClientProjectsResponse> getClientProjects({
    required dynamic clientId,
    String status = 'all',
  });
}

