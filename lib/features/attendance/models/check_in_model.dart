class CheckInRequestModel {
  final double latitude;
  final double longitude;
  final String? notes;

  CheckInRequestModel({
    required this.latitude,
    required this.longitude,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'latitude': latitude,
      'longitude': longitude,
    };
    if (notes != null && notes!.trim().isNotEmpty) {
      map['notes'] = notes!.trim();
    }
    return map;
  }
}

class CheckInResponseModel {
  final bool status;
  final String message;
  final CheckInData? data;

  CheckInResponseModel({
    required this.status,
    required this.message,
    this.data,
  });

  factory CheckInResponseModel.fromJson(Map<String, dynamic> json) {
    return CheckInResponseModel(
      status: json['status'] == true || json['status'] == 1,
      message: json['message']?.toString() ?? '',
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? CheckInData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class CheckInData {
  final dynamic id;
  final dynamic userId;
  final String? date;
  final String? checkIn;
  final String? checkOut;
  final String? status;
  final double? latitude;
  final double? longitude;
  final String? notes;

  CheckInData({
    this.id,
    this.userId,
    this.date,
    this.checkIn,
    this.checkOut,
    this.status,
    this.latitude,
    this.longitude,
    this.notes,
  });

  factory CheckInData.fromJson(Map<String, dynamic> json) {
    return CheckInData(
      id: json['id'],
      userId: json['user_id'],
      date: json['date']?.toString(),
      checkIn: json['check_in']?.toString() ?? json['check_in_time']?.toString(),
      checkOut: json['check_out']?.toString() ?? json['check_out_time']?.toString(),
      status: json['status']?.toString(),
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      notes: json['notes']?.toString(),
    );
  }
}

class CheckOutRequestModel {
  final double latitude;
  final double longitude;
  final String? notes;

  CheckOutRequestModel({
    required this.latitude,
    required this.longitude,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'latitude': latitude,
      'longitude': longitude,
    };
    if (notes != null && notes!.trim().isNotEmpty) {
      map['notes'] = notes!.trim();
    }
    return map;
  }
}

class CheckOutResponseModel {
  final bool status;
  final String message;
  final dynamic data;

  CheckOutResponseModel({
    required this.status,
    required this.message,
    this.data,
  });

  factory CheckOutResponseModel.fromJson(Map<String, dynamic> json) {
    return CheckOutResponseModel(
      status: json['status'] == true || json['status'] == 1,
      message: json['message']?.toString() ?? '',
      data: json['data'],
    );
  }
}
