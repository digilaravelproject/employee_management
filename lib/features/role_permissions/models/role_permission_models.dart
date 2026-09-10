class AppUser {
  final String name;
  final String email;
  final String avatarUrl;

  const AppUser({
    required this.name,
    required this.email,
    required this.avatarUrl,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'avatarUrl': avatarUrl,
      };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        avatarUrl: json['avatarUrl'] ?? '',
      );
}

/// A single granular permission item (screen, card, or specific action).
class GranularPermissionItem {
  final String key;
  final String label;
  final String? description;
  bool isGranted;

  GranularPermissionItem({
    required this.key,
    required this.label,
    this.description,
    this.isGranted = false,
  });

  GranularPermissionItem copyWith({
    String? key,
    String? label,
    String? description,
    bool? isGranted,
  }) {
    return GranularPermissionItem(
      key: key ?? this.key,
      label: label ?? this.label,
      description: description ?? this.description,
      isGranted: isGranted ?? this.isGranted,
    );
  }

  Map<String, dynamic> toJson() => {
        'key': key,
        'label': label,
        'description': description,
        'isGranted': isGranted,
      };

  factory GranularPermissionItem.fromJson(Map<String, dynamic> json) =>
      GranularPermissionItem(
        key: json['key'] ?? '',
        label: json['label'] ?? '',
        description: json['description'],
        isGranted: json['isGranted'] ?? false,
      );
}

/// A group of granular permissions belonging to a Module / Submodule.
class ModulePermissionGroup {
  final String moduleId;
  final String moduleName;
  final String iconKey; // e.g. 'user', 'calendar', 'briefcase', etc.
  final List<GranularPermissionItem> permissions;

  ModulePermissionGroup({
    required this.moduleId,
    required this.moduleName,
    required this.iconKey,
    required this.permissions,
  });

  int get grantedCount => permissions.where((p) => p.isGranted).length;
  int get totalCount => permissions.length;
  bool get isAllGranted => totalCount > 0 && grantedCount == totalCount;

  ModulePermissionGroup copyWith({
    String? moduleId,
    String? moduleName,
    String? iconKey,
    List<GranularPermissionItem>? permissions,
  }) {
    return ModulePermissionGroup(
      moduleId: moduleId ?? this.moduleId,
      moduleName: moduleName ?? this.moduleName,
      iconKey: iconKey ?? this.iconKey,
      permissions: permissions ??
          this.permissions.map((p) => p.copyWith()).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'moduleId': moduleId,
        'moduleName': moduleName,
        'iconKey': iconKey,
        'permissions': permissions.map((p) => p.toJson()).toList(),
      };

  factory ModulePermissionGroup.fromJson(Map<String, dynamic> json) =>
      ModulePermissionGroup(
        moduleId: json['moduleId'] ?? '',
        moduleName: json['moduleName'] ?? '',
        iconKey: json['iconKey'] ?? 'element',
        permissions: (json['permissions'] as List<dynamic>?)
                ?.map((item) => GranularPermissionItem.fromJson(item))
                .toList() ??
            [],
      );
}

/// Legacy helper kept for backward compatibility if needed
class ModulePermission {
  final String moduleName;
  bool view;
  bool add;
  bool edit;
  bool delete;

  ModulePermission({
    required this.moduleName,
    this.view = false,
    this.add = false,
    this.edit = false,
    this.delete = false,
  });

  int get allowedCount {
    int count = 0;
    if (view) count++;
    if (add) count++;
    if (edit) count++;
    if (delete) count++;
    return count;
  }
}

/// Role Model (Decoupled from User assignment; contains Department, Designation, and Granular Permissions)
class Role {
  final String id;
  final String name;
  final String description;
  final String? departmentId;
  final String? departmentName;
  final String? designationId;
  final String? designationName;
  final bool isActive;
  final List<ModulePermissionGroup> permissionGroups;

  const Role({
    required this.id,
    required this.name,
    required this.description,
    this.departmentId,
    this.departmentName,
    this.designationId,
    this.designationName,
    this.isActive = true,
    required this.permissionGroups,
  });

  Role copyWith({
    String? id,
    String? name,
    String? description,
    String? departmentId,
    String? departmentName,
    String? designationId,
    String? designationName,
    bool? isActive,
    List<ModulePermissionGroup>? permissionGroups,
  }) {
    return Role(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      departmentId: departmentId ?? this.departmentId,
      departmentName: departmentName ?? this.departmentName,
      designationId: designationId ?? this.designationId,
      designationName: designationName ?? this.designationName,
      isActive: isActive ?? this.isActive,
      permissionGroups: permissionGroups ??
          this.permissionGroups.map((g) => g.copyWith()).toList(),
    );
  }

  int get totalPermissionsCount {
    return permissionGroups.fold(
        0, (sum, group) => sum + group.grantedCount);
  }

  int get maxPermissionsCount {
    return permissionGroups.fold(
        0, (sum, group) => sum + group.totalCount);
  }

  bool hasPermission(String permissionKey) {
    for (final group in permissionGroups) {
      for (final perm in group.permissions) {
        if (perm.key == permissionKey && perm.isGranted) {
          return true;
        }
      }
    }
    return false;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'departmentId': departmentId,
        'departmentName': departmentName,
        'designationId': designationId,
        'designationName': designationName,
        'isActive': isActive,
        'permissionGroups':
            permissionGroups.map((group) => group.toJson()).toList(),
      };

  factory Role.fromJson(Map<String, dynamic> json) => Role(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        description: json['description'] ?? '',
        departmentId: json['departmentId'],
        departmentName: json['departmentName'],
        designationId: json['designationId'],
        designationName: json['designationName'],
        isActive: json['isActive'] ?? true,
        permissionGroups: (json['permissionGroups'] as List<dynamic>?)
                ?.map((g) => ModulePermissionGroup.fromJson(g))
                .toList() ??
            [],
      );
}
