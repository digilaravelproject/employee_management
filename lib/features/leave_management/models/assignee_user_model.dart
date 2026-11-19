class AssigneeUserModel {
  final int id;
  final String? employeeId;
  final String name;
  final String? email;
  final String? role;
  final String? designation;
  final String? department;
  final String? avatar;
  final String? status;
  final String displayName;

  AssigneeUserModel({
    required this.id,
    this.employeeId,
    required this.name,
    this.email,
    this.role,
    this.designation,
    this.department,
    this.avatar,
    this.status,
    String? displayName,
  }) : displayName = displayName ?? _generateDisplayName(name, employeeId, designation, role, id);

  static String _generateDisplayName(
    String name,
    String? employeeId,
    String? designation,
    String? role,
    int id,
  ) {
    final sub = (employeeId != null && employeeId.trim().isNotEmpty)
        ? employeeId.trim()
        : (designation != null && designation.trim().isNotEmpty)
            ? designation.trim()
            : (role != null && role.trim().isNotEmpty)
                ? role.trim()
                : '';
    if (sub.isEmpty) {
      return name;
    }
    return '$name ($sub)';
  }

  AssigneeUserModel copyWith({
    int? id,
    String? employeeId,
    String? name,
    String? email,
    String? role,
    String? designation,
    String? department,
    String? avatar,
    String? status,
    String? displayName,
  }) {
    return AssigneeUserModel(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      designation: designation ?? this.designation,
      department: department ?? this.department,
      avatar: avatar ?? this.avatar,
      status: status ?? this.status,
      displayName: displayName ?? this.displayName,
    );
  }

  factory AssigneeUserModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final id = rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '0') ?? 0;

    String name = json['name']?.toString() ?? '';
    if (name.trim().isEmpty) {
      final fName = json['first_name']?.toString() ?? '';
      final lName = json['last_name']?.toString() ?? '';
      name = '$fName $lName'.trim();
      if (name.isEmpty) {
        name = json['email']?.toString() ?? 'User #$id';
      }
    }

    final empId = json['employee_id']?.toString() ?? json['emp_id']?.toString();
    final desig = json['designation'] is Map
        ? (json['designation'] as Map)['name']?.toString()
        : json['designation']?.toString();
    final role = json['role'] is Map
        ? (json['role'] as Map)['name']?.toString()
        : json['role']?.toString();
    final dept = json['department'] is Map
        ? (json['department'] as Map)['name']?.toString()
        : json['department']?.toString();

    return AssigneeUserModel(
      id: id,
      employeeId: empId,
      name: name,
      email: json['email']?.toString(),
      role: role,
      designation: desig,
      department: dept,
      avatar: json['avatar']?.toString() ?? json['profile_image']?.toString(),
      status: json['status']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'name': name,
      'email': email,
      'role': role,
      'designation': designation,
      'department': department,
      'avatar': avatar,
      'status': status,
    };
  }
}

class AssigneeUsersResponseModel {
  final bool status;
  final String message;
  final List<AssigneeUserModel> data;

  AssigneeUsersResponseModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory AssigneeUsersResponseModel.fromJson(Map<String, dynamic> json) {
    List<AssigneeUserModel> users = [];
    if (json['data'] is List) {
      users = (json['data'] as List)
          .whereType<Map>()
          .map((item) => AssigneeUserModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }
    return AssigneeUsersResponseModel(
      status: json['status'] == true ||
          json['status'] == 1 ||
          json['status']?.toString().toLowerCase() == 'true',
      message: json['message']?.toString() ?? '',
      data: users,
    );
  }
}
