import 'designation_model.dart';

class DesignationResponseModel {
  final bool status;
  final String message;
  final DesignationModel? data;

  DesignationResponseModel({
    required this.status,
    required this.message,
    this.data,
  });

  factory DesignationResponseModel.fromJson(Map<String, dynamic> json) {
    return DesignationResponseModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? DesignationModel.fromJson(json['data']) : null,
    );
  }
}
