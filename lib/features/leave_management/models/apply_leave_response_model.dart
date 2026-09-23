class ApplyLeaveResponseModel {
  final bool status;
  final String message;
  final dynamic data;

  ApplyLeaveResponseModel({
    required this.status,
    required this.message,
    this.data,
  });

  factory ApplyLeaveResponseModel.fromJson(Map<String, dynamic> json) {
    String msg = json['message']?.toString() ?? '';
    if (json['errors'] != null && json['errors'] is Map) {
      final errorsMap = json['errors'] as Map;
      final errorList = <String>[];
      errorsMap.forEach((key, value) {
        if (value is List && value.isNotEmpty) {
          errorList.add(value.first.toString());
        } else if (value is String) {
          errorList.add(value);
        }
      });
      if (errorList.isNotEmpty) {
        msg = errorList.join('\n');
      }
    }

    return ApplyLeaveResponseModel(
      status: json['status'] == true || json['status']?.toString() == 'true',
      message: msg,
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
