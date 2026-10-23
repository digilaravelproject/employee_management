import 'package:flutter/material.dart';

class LeadSourcesResponseModel {
  final bool status;
  final String message;
  final LeadSourcesSummaryModel? summary;
  final List<LeadSourceModel> data;

  LeadSourcesResponseModel({
    required this.status,
    required this.message,
    this.summary,
    this.data = const [],
  });

  factory LeadSourcesResponseModel.fromJson(Map<String, dynamic> json) {
    return LeadSourcesResponseModel(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      summary: json['summary'] is Map<String, dynamic>
          ? LeadSourcesSummaryModel.fromJson(json['summary'] as Map<String, dynamic>)
          : null,
      data: json['data'] is List
          ? (json['data'] as List)
              .whereType<Map<String, dynamic>>()
              .map((item) => LeadSourceModel.fromJson(item))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'summary': summary?.toJson(),
    'data': data.map((x) => x.toJson()).toList(),
  };
}

class LeadSourceDetailResponseModel {
  final bool status;
  final String message;
  final LeadSourceModel? data;

  LeadSourceDetailResponseModel({
    required this.status,
    required this.message,
    this.data,
  });

  factory LeadSourceDetailResponseModel.fromJson(Map<String, dynamic> json) {
    return LeadSourceDetailResponseModel(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      data: json['data'] is Map<String, dynamic>
          ? LeadSourceModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'data': data?.toJson(),
  };
}

class UpdateLeadSourceRequestModel {
  final String? name;
  final String? sourceKey;
  final String? allocationStrategy;
  final List<int>? employeeIds;
  final bool? isActive;
  final String? color;

  UpdateLeadSourceRequestModel({
    this.name,
    this.sourceKey,
    this.allocationStrategy,
    this.employeeIds,
    this.isActive,
    this.color,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (name != null) map['name'] = name;
    if (sourceKey != null) map['source_key'] = sourceKey;
    if (allocationStrategy != null) map['allocation_strategy'] = allocationStrategy;
    if (employeeIds != null) map['employee_ids'] = employeeIds;
    if (isActive != null) map['is_active'] = isActive;
    if (color != null) map['color'] = color;
    return map;
  }
}

class CreateLeadSourceRequestModel {
  final String name;
  final String sourceKey;
  final String allocationStrategy;
  final List<int> employeeIds;
  final bool isActive;
  final String color;

  CreateLeadSourceRequestModel({
    required this.name,
    required this.sourceKey,
    this.allocationStrategy = 'round_robin',
    this.employeeIds = const [],
    this.isActive = true,
    this.color = '#3B82F6',
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'source_key': sourceKey,
    'allocation_strategy': allocationStrategy,
    'employee_ids': employeeIds,
    'is_active': isActive,
    'color': color,
  };
}

class LeadSourcesSummaryModel {
  final int total;
  final int active;
  final int inactive;
  final int unassignedLeads;

  LeadSourcesSummaryModel({
    required this.total,
    required this.active,
    required this.inactive,
    required this.unassignedLeads,
  });

  factory LeadSourcesSummaryModel.fromJson(Map<String, dynamic> json) {
    return LeadSourcesSummaryModel(
      total: int.tryParse(json['total']?.toString() ?? '') ?? 0,
      active: int.tryParse(json['active']?.toString() ?? '') ?? 0,
      inactive: int.tryParse(json['inactive']?.toString() ?? '') ?? 0,
      unassignedLeads: int.tryParse(json['unassigned_leads']?.toString() ?? '') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'total': total,
    'active': active,
    'inactive': inactive,
    'unassigned_leads': unassignedLeads,
  };
}

class LeadSourceModel {
  final int id;
  final String name;
  final String sourceKey;
  final String allocationStrategy;
  final bool isActive;
  final bool isConfigured;
  final String color;
  final int leadsCount;
  final int unassignedLeadsCount;
  final List<LeadSourceEmployeeModel> employees;
  final String? createdAt;
  final String? updatedAt;

  LeadSourceModel({
    required this.id,
    required this.name,
    required this.sourceKey,
    required this.allocationStrategy,
    this.isActive = true,
    this.isConfigured = false,
    this.color = '#3B82F6',
    this.leadsCount = 0,
    this.unassignedLeadsCount = 0,
    this.employees = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory LeadSourceModel.fromJson(Map<String, dynamic> json) {
    return LeadSourceModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      sourceKey: json['source_key']?.toString() ?? '',
      allocationStrategy: json['allocation_strategy']?.toString() ?? 'round_robin',
      isActive: json['is_active'] == true || json['is_active'] == 1,
      isConfigured: json['is_configured'] == true || json['is_configured'] == 1,
      color: json['color']?.toString() ?? '#3B82F6',
      leadsCount: int.tryParse(json['leads_count']?.toString() ?? '') ?? 0,
      unassignedLeadsCount: int.tryParse(json['unassigned_leads_count']?.toString() ?? '') ?? 0,
      employees: json['employees'] is List
          ? (json['employees'] as List)
              .whereType<Map<String, dynamic>>()
              .map((item) => LeadSourceEmployeeModel.fromJson(item))
              .toList()
          : [],
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'source_key': sourceKey,
    'allocation_strategy': allocationStrategy,
    'is_active': isActive,
    'is_configured': isConfigured,
    'color': color,
    'leads_count': leadsCount,
    'unassigned_leads_count': unassignedLeadsCount,
    'employees': employees.map((x) => x.toJson()).toList(),
    'created_at': createdAt,
    'updated_at': updatedAt,
  };

  // UI Presentation Getters
  Color get colorValue {
    try {
      String hex = color.replaceAll('#', '').trim();
      if (hex.length == 6) hex = 'FF$hex';
      return Color(int.parse('0x$hex'));
    } catch (_) {
      return const Color(0xFF3B82F6);
    }
  }

  String get strategyDisplayName {
    final s = allocationStrategy.toLowerCase().replaceAll('_', ' ').trim();
    if (s == 'round robin') return 'Round-Robin';
    if (s == 'primary') return 'Primary';
    if (s.isEmpty) return 'Round-Robin';
    return s.split(' ').map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '').join(' ');
  }

  LeadSourceModel copyWith({
    int? id,
    String? name,
    String? sourceKey,
    String? allocationStrategy,
    bool? isActive,
    bool? isConfigured,
    String? color,
    int? leadsCount,
    int? unassignedLeadsCount,
    List<LeadSourceEmployeeModel>? employees,
    String? createdAt,
    String? updatedAt,
  }) {
    return LeadSourceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      sourceKey: sourceKey ?? this.sourceKey,
      allocationStrategy: allocationStrategy ?? this.allocationStrategy,
      isActive: isActive ?? this.isActive,
      isConfigured: isConfigured ?? this.isConfigured,
      color: color ?? this.color,
      leadsCount: leadsCount ?? this.leadsCount,
      unassignedLeadsCount: unassignedLeadsCount ?? this.unassignedLeadsCount,
      employees: employees ?? this.employees,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class LeadSourceEmployeeModel {
  final int id;
  final String? employeeId;
  final String name;
  final String? email;
  final String? designation;
  final String? avatar;
  final String? status;
  final LeadSourcePivotModel? pivot;

  LeadSourceEmployeeModel({
    required this.id,
    this.employeeId,
    required this.name,
    this.email,
    this.designation,
    this.avatar,
    this.status,
    this.pivot,
  });

  factory LeadSourceEmployeeModel.fromJson(Map<String, dynamic> json) {
    return LeadSourceEmployeeModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      employeeId: json['employee_id']?.toString(),
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString(),
      designation: json['designation']?.toString(),
      avatar: json['avatar']?.toString(),
      status: json['status']?.toString(),
      pivot: json['pivot'] is Map<String, dynamic>
          ? LeadSourcePivotModel.fromJson(json['pivot'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'employee_id': employeeId,
    'name': name,
    'email': email,
    'designation': designation,
    'avatar': avatar,
    'status': status,
    'pivot': pivot?.toJson(),
  };
}

class LeadSourcePivotModel {
  final int leadSourceId;
  final int userId;
  final int position;
  final String? createdAt;
  final String? updatedAt;

  LeadSourcePivotModel({
    required this.leadSourceId,
    required this.userId,
    required this.position,
    this.createdAt,
    this.updatedAt,
  });

  factory LeadSourcePivotModel.fromJson(Map<String, dynamic> json) {
    return LeadSourcePivotModel(
      leadSourceId: int.tryParse(json['lead_source_id']?.toString() ?? '') ?? 0,
      userId: int.tryParse(json['user_id']?.toString() ?? '') ?? 0,
      position: int.tryParse(json['position']?.toString() ?? '') ?? 0,
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'lead_source_id': leadSourceId,
    'user_id': userId,
    'position': position,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}
