class CreateEmployeeResponseModel {
  final bool status;
  final String message;
  final dynamic data;

  CreateEmployeeResponseModel({
    required this.status,
    required this.message,
    this.data,
  });

  factory CreateEmployeeResponseModel.fromJson(Map<String, dynamic> json) {
    return CreateEmployeeResponseModel(
      status: json['status'] == true || json['status'] == 1 || json['status']?.toString() == 'true',
      message: json['message']?.toString() ?? '',
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      if (data != null) 'data': data,
    };
  }
}
