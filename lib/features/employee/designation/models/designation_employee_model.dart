class DesignationEmployeeModel {
  final int id;
  final int designationId;
  final String employeeId;
  final String name;
  final String email;
  final String mobileNumber;
  final String? avatar;
  final String status;

  DesignationEmployeeModel({
    required this.id,
    required this.designationId,
    required this.employeeId,
    required this.name,
    required this.email,
    required this.mobileNumber,
    this.avatar,
    required this.status,
  });

  factory DesignationEmployeeModel.fromJson(Map<String, dynamic> json) {
    return DesignationEmployeeModel(
      id: json['id'] ?? 0,
      designationId: json['designation_id'] ?? 0,
      employeeId: json['employee_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      mobileNumber: json['mobile_number'] ?? '',
      avatar: json['avatar'],
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'designation_id': designationId,
      'employee_id': employeeId,
      'name': name,
      'email': email,
      'mobile_number': mobileNumber,
      'avatar': avatar,
      'status': status,
    };
  }
}
