import 'department_api_model.dart';

class DepartmentResponseModel {
  final bool status;
  final String message;
  final DepartmentApiModel? data;

  DepartmentResponseModel({
    required this.status,
    required this.message,
    this.data,
  });

  factory DepartmentResponseModel.fromJson(Map<String, dynamic> json) {
    return DepartmentResponseModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? DepartmentApiModel.fromJson(json['data']) : null,
    );
  }
}

class DepartmentListResponseModel {
  final bool status;
  final String message;
  final int? total;
  final List<DepartmentApiModel> data;

  DepartmentListResponseModel({
    required this.status,
    required this.message,
    this.total,
    this.data = const [],
  });

  factory DepartmentListResponseModel.fromJson(Map<String, dynamic> json) {
    return DepartmentListResponseModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      total: json['total'],
      data: json['data'] != null
          ? List<DepartmentApiModel>.from(json['data'].map((x) => DepartmentApiModel.fromJson(x)))
          : [],
    );
  }
}
