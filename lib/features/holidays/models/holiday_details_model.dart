import '../../leave_management/models/holiday_calendar_model.dart';

class HolidayDetailsResponseModel {
  final bool status;
  final String? message;
  final HolidayItemModel? data;

  HolidayDetailsResponseModel({
    required this.status,
    this.message,
    this.data,
  });

  factory HolidayDetailsResponseModel.fromJson(Map<String, dynamic> json) {
    return HolidayDetailsResponseModel(
      status: json['status'] == true,
      message: json['message']?.toString(),
      data: json['data'] is Map<String, dynamic>
          ? HolidayItemModel.fromJson(Map<String, dynamic>.from(json['data']))
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        if (data != null) 'data': data!.toJson(),
      };
}
