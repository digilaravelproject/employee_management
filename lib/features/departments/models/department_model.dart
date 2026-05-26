import 'package:flutter/material.dart';
import '../../role_permissions/models/role_permission_models.dart';

class Department {
  final String id;
  final String name;
  final String description;
  final AppUser? head;
  final List<AppUser> employees;
  final int teamsCount;
  final IconData icon;
  final Color themeColor;

  const Department({
    required this.id,
    required this.name,
    required this.description,
    this.head,
    required this.employees,
    this.teamsCount = 5,
    required this.icon,
    required this.themeColor,
  });

  Department copyWith({
    String? id,
    String? name,
    String? description,
    AppUser? head,
    List<AppUser>? employees,
    int? teamsCount,
    IconData? icon,
    Color? themeColor,
  }) {
    return Department(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      head: head ?? this.head,
      employees: employees ?? this.employees,
      teamsCount: teamsCount ?? this.teamsCount,
      icon: icon ?? this.icon,
      themeColor: themeColor ?? this.themeColor,
    );
  }
}
