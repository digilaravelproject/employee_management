class PerformanceMessageUserApiData {
  final dynamic id;
  final String name;
  final String avatar;
  final String designation;

  PerformanceMessageUserApiData({
    this.id,
    this.name = '',
    this.avatar = '',
    this.designation = '',
  });

  factory PerformanceMessageUserApiData.fromJson(Map<String, dynamic> json) {
    return PerformanceMessageUserApiData(
      id: json['id'],
      name: json['name']?.toString() ?? '',
      avatar: json['avatar']?.toString() ?? '',
      designation: json['designation']?.toString() ?? '',
    );
  }
}

class PerformanceMessageItemApiData {
  final dynamic id;
  final dynamic senderId;
  final dynamic receiverId;
  final String message;
  final String? readAt;
  final String? createdAt;
  final String? updatedAt;
  final PerformanceMessageUserApiData? sender;
  final PerformanceMessageUserApiData? receiver;

  PerformanceMessageItemApiData({
    this.id,
    this.senderId,
    this.receiverId,
    this.message = '',
    this.readAt,
    this.createdAt,
    this.updatedAt,
    this.sender,
    this.receiver,
  });

  factory PerformanceMessageItemApiData.fromJson(Map<String, dynamic> json) {
    return PerformanceMessageItemApiData(
      id: json['id'],
      senderId: json['sender_id'],
      receiverId: json['receiver_id'],
      message: json['message']?.toString() ?? '',
      readAt: json['read_at']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      sender: json['sender'] is Map<String, dynamic>
          ? PerformanceMessageUserApiData.fromJson(json['sender'] as Map<String, dynamic>)
          : null,
      receiver: json['receiver'] is Map<String, dynamic>
          ? PerformanceMessageUserApiData.fromJson(json['receiver'] as Map<String, dynamic>)
          : null,
    );
  }
}

class PerformanceMessagesPaginationApiData {
  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;

  PerformanceMessagesPaginationApiData({
    this.currentPage = 1,
    this.perPage = 50,
    this.total = 0,
    this.lastPage = 1,
  });

  factory PerformanceMessagesPaginationApiData.fromJson(Map<String, dynamic> json) {
    return PerformanceMessagesPaginationApiData(
      currentPage: int.tryParse(json['current_page']?.toString() ?? '1') ?? 1,
      perPage: int.tryParse(json['per_page']?.toString() ?? '50') ?? 50,
      total: int.tryParse(json['total']?.toString() ?? '0') ?? 0,
      lastPage: int.tryParse(json['last_page']?.toString() ?? '1') ?? 1,
    );
  }
}

class PerformanceMessagesApiResponse {
  final bool status;
  final String message;
  final List<PerformanceMessageItemApiData> data;
  final PerformanceMessagesPaginationApiData? pagination;

  PerformanceMessagesApiResponse({
    required this.status,
    required this.message,
    this.data = const [],
    this.pagination,
  });

  factory PerformanceMessagesApiResponse.fromJson(Map<String, dynamic> json) {
    List<PerformanceMessageItemApiData> list = [];
    if (json['data'] is List) {
      list = (json['data'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => PerformanceMessageItemApiData.fromJson(e))
          .toList();
    }

    PerformanceMessagesPaginationApiData? pag;
    if (json['pagination'] is Map<String, dynamic>) {
      pag = PerformanceMessagesPaginationApiData.fromJson(json['pagination'] as Map<String, dynamic>);
    }

    return PerformanceMessagesApiResponse(
      status: json['status'] == true ||
          json['status'] == 1 ||
          json['status']?.toString().toLowerCase() == 'true',
      message: json['message']?.toString() ?? '',
      data: list,
      pagination: pag,
    );
  }
}
