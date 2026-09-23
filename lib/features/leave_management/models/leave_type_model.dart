class LeaveTypeModel {
  final int id;
  final String name;
  final String code;
  final String? description;
  final int annualAllowance;
  final bool isPaid;
  final bool requiresAttachment;
  final String status;
  final String? createdAt;
  final String? updatedAt;
  final int requestsCount;

  LeaveTypeModel({
    required this.id,
    required this.name,
    required this.code,
    this.description,
    this.annualAllowance = 12,
    this.isPaid = true,
    this.requiresAttachment = false,
    this.status = 'Active',
    this.createdAt,
    this.updatedAt,
    this.requestsCount = 0,
  });

  factory LeaveTypeModel.fromJson(Map<String, dynamic> json) {
    return LeaveTypeModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      description: json['description']?.toString(),
      annualAllowance: int.tryParse(json['annual_allowance']?.toString() ?? '12') ?? 12,
      isPaid: json['is_paid'] == true || json['is_paid'] == 1 || json['is_paid']?.toString() == 'true',
      requiresAttachment: json['requires_attachment'] == true ||
          json['requires_attachment'] == 1 ||
          json['requires_attachment']?.toString() == 'true',
      status: json['status']?.toString() ?? 'Active',
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      requestsCount: int.tryParse(json['requests_count']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'description': description,
      'annual_allowance': annualAllowance,
      'is_paid': isPaid,
      'requires_attachment': requiresAttachment,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'requests_count': requestsCount,
    };
  }
}

class LeaveTypeListResponseModel {
  final bool status;
  final String message;
  final List<LeaveTypeModel> data;

  LeaveTypeListResponseModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory LeaveTypeListResponseModel.fromJson(Map<String, dynamic> json) {
    List<LeaveTypeModel> types = [];
    if (json['data'] is List) {
      types = (json['data'] as List)
          .whereType<Map<String, dynamic>>()
          .map((item) => LeaveTypeModel.fromJson(item))
          .toList();
    }
    return LeaveTypeListResponseModel(
      status: json['status'] == true || json['status']?.toString() == 'true',
      message: json['message']?.toString() ?? '',
      data: types,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}
