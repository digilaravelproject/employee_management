import 'designation_employee_model.dart';

class DesignationModel {
  final String id;
  final String name;
  final String hierarchyLevel;
  final List<String> skills;
  final String? createdAt;
  final String? updatedAt;
  final int? employeesCount;
  final List<DesignationEmployeeModel>? employees;

  DesignationModel({
    required this.id,
    required this.name,
    required this.hierarchyLevel,
    this.skills = const [],
    this.createdAt,
    this.updatedAt,
    this.employeesCount,
    this.employees,
  });

  factory DesignationModel.fromJson(Map<String, dynamic> json) {
    return DesignationModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      hierarchyLevel: json['hierarchy_level'] ?? '',
      skills: json['skills'] != null ? List<String>.from(json['skills']) : [],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      employeesCount: json['employees_count'],
      employees: json['employees'] != null 
          ? List<DesignationEmployeeModel>.from(json['employees'].map((x) => DesignationEmployeeModel.fromJson(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'hierarchy_level': hierarchyLevel,
      'skills': skills,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'employees_count': employeesCount,
      'employees': employees?.map((x) => x.toJson()).toList(),
    };
  }
}

