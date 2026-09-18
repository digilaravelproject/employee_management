class DepartmentMemberModel {
  final int id;
  final String? employeeId;
  final String name;
  final String email;
  final String? avatar;
  final String? status;
  final String? designation;
  final String? phone;

  DepartmentMemberModel({
    required this.id,
    this.employeeId,
    required this.name,
    required this.email,
    this.avatar,
    this.status,
    this.designation,
    this.phone,
  });

  factory DepartmentMemberModel.fromJson(Map<String, dynamic> json) {
    return DepartmentMemberModel(
      id: json['id'] ?? 0,
      employeeId: json['employee_id']?.toString(),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      avatar: json['avatar'],
      status: json['status']?.toString(),
      designation: json['designation'] is Map
          ? json['designation']['name']?.toString()
          : json['designation']?.toString(),
      phone: json['phone']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'name': name,
      'email': email,
      'avatar': avatar,
      'status': status,
      'designation': designation,
      'phone': phone,
    };
  }
}

typedef DepartmentHeadModel = DepartmentMemberModel;

class DepartmentApiModel {
  final int id;
  final String name;
  final String? description;
  final int? headUserId;
  final String status;
  final String? createdAt;
  final String? updatedAt;
  final int employeesCount;
  final int employeeCount;
  final int teamCount;
  final DepartmentMemberModel? head;
  final List<DepartmentMemberModel> employees;

  DepartmentApiModel({
    required this.id,
    required this.name,
    this.description,
    this.headUserId,
    this.status = 'Active',
    this.createdAt,
    this.updatedAt,
    this.employeesCount = 0,
    this.employeeCount = 0,
    this.teamCount = 0,
    this.head,
    this.employees = const [],
  });

  factory DepartmentApiModel.fromJson(Map<String, dynamic> json) {
    List<DepartmentMemberModel> parsedEmployees = [];
    if (json['employees'] != null && json['employees'] is List) {
      parsedEmployees = (json['employees'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => DepartmentMemberModel.fromJson(e))
          .toList();
    }

    return DepartmentApiModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      headUserId: json['head_user_id'] is int ? json['head_user_id'] : int.tryParse(json['head_user_id']?.toString() ?? ''),
      status: json['status'] ?? 'Active',
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      employeesCount: json['employees_count'] ?? json['employee_count'] ?? parsedEmployees.length,
      employeeCount: json['employee_count'] ?? json['employees_count'] ?? parsedEmployees.length,
      teamCount: json['team_count'] ?? 0,
      head: json['head'] != null && json['head'] is Map<String, dynamic>
          ? DepartmentMemberModel.fromJson(json['head'])
          : null,
      employees: parsedEmployees,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'head_user_id': headUserId,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'employees_count': employeesCount,
      'employee_count': employeeCount,
      'team_count': teamCount,
      'head': head?.toJson(),
      'employees': employees.map((e) => e.toJson()).toList(),
    };
  }
}
