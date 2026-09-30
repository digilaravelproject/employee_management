class AddHolidayRequestModel {
  final String name;
  final String date; // Format: "yyyy-MM-dd" e.g. "2027-01-26"
  final String type; // "National", "Restricted", "Optional"
  final String location; // "All Locations"
  final bool repeatEveryYear;
  final String? description;

  AddHolidayRequestModel({
    required this.name,
    required this.date,
    required this.type,
    this.location = 'All Locations',
    this.repeatEveryYear = true,
    this.description,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'date': date,
        'type': type,
        'location': location,
        'repeat_every_year': repeatEveryYear,
        if (description != null && description!.trim().isNotEmpty)
          'description': description!.trim(),
      };
}

class AddHolidayResponseModel {
  final bool status;
  final String? message;
  final dynamic data;

  AddHolidayResponseModel({
    required this.status,
    this.message,
    this.data,
  });

  factory AddHolidayResponseModel.fromJson(Map<String, dynamic> json) {
    return AddHolidayResponseModel(
      status: json['status'] == true,
      message: json['message']?.toString(),
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        if (data != null) 'data': data,
      };
}
