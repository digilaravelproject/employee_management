class PermissionResponseModel {
  final bool status;
  final String message;
  final PermissionRoleModel? role;
  final int totalPermissions;
  final int totalCategories;
  final int assignedPermissionsCount;
  final List<PermissionModuleModel> modules;

  const PermissionResponseModel({
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
      role: json['role'] != null && json['role'] is Map
          ? PermissionRoleModel.fromJson(Map<String, dynamic>.from(json['role']))
          : null,
      totalPermissions: json['total_permissions'] is int
          ? json['total_permissions']
          : int.tryParse(json['total_permissions']?.toString() ?? '') ?? 0,
      totalCategories: json['total_categories'] is int
          ? json['total_categories']
          : int.tryParse(json['total_categories']?.toString() ?? '') ?? 0,
      assignedPermissionsCount: json['assigned_permissions_count'] is int
          ? json['assigned_permissions_count']
          : int.tryParse(json['assigned_permissions_count']?.toString() ?? '') ?? 0,
      modules: (json['modules'] as List?)
              ?.map((e) => e is Map
                  ? PermissionModuleModel.fromJson(Map<String, dynamic>.from(e))
                  : null)
              .whereType<PermissionModuleModel>()
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        if (role != null) 'role': role!.toJson(),
        'total_permissions': totalPermissions,
        'total_categories': totalCategories,
        'assigned_permissions_count': assignedPermissionsCount,
        'modules': modules.map((e) => e.toJson()).toList(),
      };

  PermissionResponseModel copyWith({
    bool? status,
    String? message,
    PermissionRoleModel? role,
    int? totalPermissions,
    int? totalCategories,
    int? assignedPermissionsCount,
    List<PermissionModuleModel>? modules,
  }) {
    return PermissionResponseModel(
      status: status ?? this.status,
      message: message ?? this.message,
      role: role ?? this.role,
      totalPermissions: totalPermissions ?? this.totalPermissions,
      totalCategories: totalCategories ?? this.totalCategories,
      assignedPermissionsCount:
          assignedPermissionsCount ?? this.assignedPermissionsCount,
      modules: modules ?? this.modules,
    );
  }
}

class PermissionRoleModel {
  final int id;
  final String name;
  final String description;
  final String department;
  final bool status;

  const PermissionRoleModel({
    required this.id,
    required this.name,
    required this.description,
    required this.department,
    required this.status,
  });

  factory PermissionRoleModel.fromJson(Map<String, dynamic> json) {
    return PermissionRoleModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      department: json['department']?.toString() ?? '',
      status: json['status'] == true ||
          json['status'] == 1 ||
          json['status']?.toString().toLowerCase() == 'true',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'department': department,
        'status': status,
      };

  PermissionRoleModel copyWith({
    int? id,
    String? name,
    String? description,
    String? department,
    bool? status,
  }) {
    return PermissionRoleModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      department: department ?? this.department,
      status: status ?? this.status,
    );
  }
}

class PermissionModuleModel {
  final String module;
  final String moduleSlug;
  final List<PermissionItemModel> permissions;
  final int totalPermissions;
  final int assignedPermissionsCount;
  final bool allAssigned;

  PermissionModuleModel({
    String? module,
    String? moduleName,
    required this.moduleSlug,
    required this.permissions,
    required this.totalPermissions,
    int? assignedPermissionsCount,
    int? assignedCount,
    required this.allAssigned,
  })  : module = module ?? moduleName ?? '',
        assignedPermissionsCount =
            assignedPermissionsCount ?? assignedCount ?? 0;

  /// Backward-compatibility getters
  String get moduleName => module;
  int get assignedCount => assignedPermissionsCount;

  factory PermissionModuleModel.fromJson(Map<String, dynamic> json) {
    return PermissionModuleModel(
      module: json['module']?.toString() ??
          json['module_name']?.toString() ??
          '',
      moduleSlug:
          json['module_slug']?.toString().toLowerCase().trim() ?? '',
      permissions: (json['permissions'] as List?)
              ?.map((e) => e is Map
                  ? PermissionItemModel.fromJson(Map<String, dynamic>.from(e))
                  : null)
              .whereType<PermissionItemModel>()
              .toList() ??
          [],
      totalPermissions: json['total_permissions'] is int
          ? json['total_permissions']
          : int.tryParse(json['total_permissions']?.toString() ?? '') ?? 0,
      assignedPermissionsCount: json['assigned_permissions_count'] is int
          ? json['assigned_permissions_count']
          : int.tryParse(
                  json['assigned_permissions_count']?.toString() ?? '') ??
              0,
      allAssigned: json['all_assigned'] == true ||
          json['all_assigned'] == 1 ||
          json['all_assigned']?.toString().toLowerCase() == 'true',
    );
  }

  Map<String, dynamic> toJson() => {
        'module': module,
        'module_slug': moduleSlug,
        'permissions': permissions.map((e) => e.toJson()).toList(),
        'total_permissions': totalPermissions,
        'assigned_permissions_count': assignedPermissionsCount,
        'all_assigned': allAssigned,
      };

  PermissionModuleModel copyWith({
    String? module,
    String? moduleSlug,
    List<PermissionItemModel>? permissions,
    int? totalPermissions,
    int? assignedPermissionsCount,
    bool? allAssigned,
  }) {
    return PermissionModuleModel(
      module: module ?? this.module,
      moduleSlug: moduleSlug ?? this.moduleSlug,
      permissions: permissions ?? this.permissions,
      totalPermissions: totalPermissions ?? this.totalPermissions,
      assignedPermissionsCount:
          assignedPermissionsCount ?? this.assignedPermissionsCount,
      allAssigned: allAssigned ?? this.allAssigned,
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

  const PermissionItemModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.isAssigned,
    required this.status,
  });

  /// Helper to check whether this permission is allowed
  bool get isAllowed =>
      isAssigned || status.toLowerCase().trim() == 'allowed';

  factory PermissionItemModel.fromJson(Map<String, dynamic> json) {
    return PermissionItemModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString().toLowerCase().trim() ?? '',
      description: json['description']?.toString() ?? '',
      isAssigned: json['is_assigned'] == true ||
          json['is_assigned'] == 1 ||
          json['is_assigned']?.toString().toLowerCase() == 'true',
      status: json['status']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'slug': slug,
        'description': description,
        'is_assigned': isAssigned,
        'status': status,
      };

  PermissionItemModel copyWith({
    int? id,
    String? name,
    String? slug,
    String? description,
    bool? isAssigned,
    String? status,
  }) {
    return PermissionItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      isAssigned: isAssigned ?? this.isAssigned,
      status: status ?? this.status,
    );
  }
}
