class PermissionResponseModel {
  final bool status;
  final String message;
  final dynamic role;
  final int totalPermissions;
  final int totalCategories;
  final int assignedPermissionsCount;
  final List<PermissionModuleModel> modules;

  PermissionResponseModel({
    required this.status,
    required this.message,
    this.role,
    required this.totalPermissions,
    required this.totalCategories,
    required this.assignedPermissionsCount,
    required this.modules,
  });

  factory PermissionResponseModel.fromJson(Map<String, dynamic> json) {
    return PermissionResponseModel(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      role: json['role'],
      totalPermissions: json['total_permissions'] ?? 0,
      totalCategories: json['total_categories'] ?? 0,
      assignedPermissionsCount: json['assigned_permissions_count'] ?? 0,
      modules: (json['modules'] as List?)
              ?.map((e) => e is Map ? PermissionModuleModel.fromJson(Map<String, dynamic>.from(e)) : null)
              .whereType<PermissionModuleModel>()
              .toList() ??
          [],
    );
  }
}

class PermissionModuleModel {
  final String moduleName;
  final String moduleSlug;
  final bool allAssigned;
  final int assignedCount;
  final int totalPermissions;
  final List<PermissionItemModel> permissions;

  PermissionModuleModel({
    required this.moduleName,
    required this.moduleSlug,
    required this.allAssigned,
    required this.assignedCount,
    required this.totalPermissions,
    required this.permissions,
  });

  factory PermissionModuleModel.fromJson(Map<String, dynamic> json) {
    return PermissionModuleModel(
      moduleName: json['module']?.toString() ?? '',
      moduleSlug: json['module_slug']?.toString().toLowerCase().trim() ?? '',
      allAssigned: json['all_assigned'] == true,
      assignedCount: json['assigned_permissions_count'] ?? 0,
      totalPermissions: json['total_permissions'] ?? 0,
      permissions: (json['permissions'] as List?)
              ?.map((e) => PermissionItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class PermissionItemModel {
  final int id;
  final String name;
  final String slug;
  final String description;
  final bool isAssigned;
  final String status;

  PermissionItemModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.isAssigned,
    required this.status,
  });

  factory PermissionItemModel.fromJson(Map<String, dynamic> json) {
    return PermissionItemModel(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString().toLowerCase().trim() ?? '',
      description: json['description']?.toString() ?? '',
      isAssigned: json['is_assigned'] ?? false,
      status: json['status']?.toString() ?? '',
    );
  }
}
