import '../../employee/management/models/employee_model.dart';

class UpcomingBirthdaysResponseModel {
  final bool status;
  final String message;
  final int days;
  final int total;
  final List<UpcomingBirthdayItem> data;

  UpcomingBirthdaysResponseModel({
    required this.status,
    required this.message,
    this.days = 30,
    this.total = 0,
    required this.data,
  });

  factory UpcomingBirthdaysResponseModel.fromJson(Map<String, dynamic> json) {
    List<UpcomingBirthdayItem> list = [];
    if (json['data'] is List) {
      list = (json['data'] as List)
          .whereType<Map<String, dynamic>>()
          .map((item) => UpcomingBirthdayItem.fromJson(item))
          .toList();
    }

    return UpcomingBirthdaysResponseModel(
      status: json['status'] == true ||
          json['status'] == 1 ||
          json['status']?.toString().toLowerCase() == 'true',
      message: json['message']?.toString() ?? '',
      days: int.tryParse(json['days']?.toString() ?? '') ?? 30,
      total: int.tryParse(json['total']?.toString() ?? '') ?? list.length,
      data: list,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'days': days,
      'total': total,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}

class UpcomingBirthdayItem {
  final int id;
  final String employeeId;
  final String name;
  final String designation;
  final String? avatar;
  final String birthday;
  final String birthdayLabel;
  final int daysUntil;
  final bool isToday;

  UpcomingBirthdayItem({
    required this.id,
    required this.employeeId,
    required this.name,
    required this.designation,
    this.avatar,
    required this.birthday,
    required this.birthdayLabel,
    this.daysUntil = 0,
    this.isToday = false,
  });

  factory UpcomingBirthdayItem.fromJson(Map<String, dynamic> json) {
    return UpcomingBirthdayItem(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      employeeId: json['employee_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      designation: json['designation']?.toString() ?? '',
      avatar: json['avatar']?.toString(),
      birthday: json['birthday']?.toString() ?? '',
      birthdayLabel: json['birthday_label']?.toString() ?? '',
      daysUntil: int.tryParse(json['days_until']?.toString() ?? '') ?? 0,
      isToday: json['is_today'] == true ||
          json['is_today'] == 1 ||
          json['is_today']?.toString().toLowerCase() == 'true',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'name': name,
      'designation': designation,
      'avatar': avatar,
      'birthday': birthday,
      'birthday_label': birthdayLabel,
      'days_until': daysUntil,
      'is_today': isToday,
    };
  }

  String get formattedDaysUntil {
    if (isToday || daysUntil == 0) return 'Today 🎉';
    if (daysUntil == 1) return 'Tomorrow 🎈';
    return 'In $daysUntil days';
  }

  /// Convert to EmployeeModel to seamlessly open EmployeeDetailScreen
  EmployeeModel toEmployeeModel() {
    return EmployeeModel(
      id: id.toString(),
      employeeId: employeeId,
      name: name,
      mobile: '',
      email: '',
      designation: designation,
      profilePic: avatar,
      joiningDate: '',
      address: '',
      dob: birthday,
    );
  }
}
