import 'client_model.dart';
import 'client_detail_model.dart';

class ClientsPaginationModel {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  ClientsPaginationModel({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  bool get hasMore => currentPage < lastPage;

  factory ClientsPaginationModel.fromJson(Map<String, dynamic> json) {
    return ClientsPaginationModel(
      currentPage: (json['current_page'] as num?)?.toInt() ?? 1,
      lastPage: (json['last_page'] as num?)?.toInt() ?? 1,
      perPage: (json['per_page'] as num?)?.toInt() ?? 15,
      total: (json['total'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'last_page': lastPage,
      'per_page': perPage,
      'total': total,
    };
  }
}

class ClientsCountsModel {
  final int all;
  final int active;
  final int inactive;

  ClientsCountsModel({
    required this.all,
    required this.active,
    required this.inactive,
  });

  factory ClientsCountsModel.fromJson(Map<String, dynamic> json) {
    return ClientsCountsModel(
      all: (json['all'] as num?)?.toInt() ?? 0,
      active: (json['active'] as num?)?.toInt() ?? 0,
      inactive: (json['inactive'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'all': all,
      'active': active,
      'inactive': inactive,
    };
  }
}

class ClientsResponseModel {
  final bool status;
  final String message;
  final ClientsCountsModel? counts;
  final int total;
  final List<Client> data;
  final ClientsPaginationModel? pagination;

  ClientsResponseModel({
    required this.status,
    required this.message,
    this.counts,
    this.total = 0,
    required this.data,
    this.pagination,
  });

  factory ClientsResponseModel.fromJson(Map<String, dynamic> json) {
    List<Client> parsedList = [];
    if (json['data'] is List) {
      parsedList = (json['data'] as List)
          .whereType<Map<String, dynamic>>()
          .map((item) => Client.fromJson(item))
          .toList();
    }

    return ClientsResponseModel(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      counts: json['counts'] is Map<String, dynamic>
          ? ClientsCountsModel.fromJson(json['counts'] as Map<String, dynamic>)
          : null,
      total: (json['total'] as num?)?.toInt() ?? parsedList.length,
      data: parsedList,
      pagination: json['pagination'] is Map<String, dynamic>
          ? ClientsPaginationModel.fromJson(json['pagination'] as Map<String, dynamic>)
          : null,
    );
  }
}

class CreateClientResponse {
  final bool status;
  final String message;
  final Client? data;

  CreateClientResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory CreateClientResponse.fromJson(Map<String, dynamic> json) {
    return CreateClientResponse(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      data: json['data'] is Map<String, dynamic>
          ? Client.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class UpdateClientResponse {
  final bool status;
  final String message;
  final Client? data;
  final ClientDetailData? detailData;

  UpdateClientResponse({
    required this.status,
    required this.message,
    this.data,
    this.detailData,
  });

  factory UpdateClientResponse.fromJson(Map<String, dynamic> json) {
    Client? parsedClient;
    ClientDetailData? parsedDetail;

    if (json['data'] is Map<String, dynamic>) {
      final dataMap = json['data'] as Map<String, dynamic>;
      parsedClient = Client.fromJson(dataMap);
      try {
        parsedDetail = ClientDetailData.fromJson(dataMap);
      } catch (_) {}
    }

    return UpdateClientResponse(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      data: parsedClient,
      detailData: parsedDetail,
    );
  }
}

class DeleteClientResponse {
  final bool status;
  final String message;

  DeleteClientResponse({
    required this.status,
    required this.message,
  });

  factory DeleteClientResponse.fromJson(Map<String, dynamic> json) {
    return DeleteClientResponse(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
    );
  }
}


