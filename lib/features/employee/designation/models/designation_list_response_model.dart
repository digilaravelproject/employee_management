import 'designation_model.dart';

class DesignationListResponseModel {
  final bool status;
  final String message;
  final int total;
  final List<DesignationModel> data;

  DesignationListResponseModel({
    required this.status,
    required this.message,
    required this.total,
    required this.data,
  });

  factory DesignationListResponseModel.fromJson(Map<String, dynamic> json) {
    return DesignationListResponseModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      total: json['total'] ?? 0,
      data: json['data'] != null 
          ? List<DesignationModel>.from(json['data'].map((x) => DesignationModel.fromJson(x)))
          : [],
    );
  }
}
