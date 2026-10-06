class AppUser {
  final int? id;
  final String name;
  final String email;
  final String avatarUrl;
  final String? designation;
  final String? employeeId;
  final String? status;

  const AppUser({
    this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
    this.designation,
    this.employeeId,
    this.status,
  });

  AppUser copyWith({
    int? id,
    String? name,
    String? email,
    String? avatarUrl,
    String? designation,
    String? employeeId,
    String? status,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      designation: designation ?? this.designation,
      employeeId: employeeId ?? this.employeeId,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'name': name,
        'email': email,
        'avatarUrl': avatarUrl,
        'designation': designation,
        'employeeId': employeeId,
        'status': status,
      };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] is int
            ? json['id']
            : int.tryParse(json['id']?.toString() ?? ''),
        name: json['name']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        avatarUrl: json['avatarUrl']?.toString() ??
            json['avatar']?.toString() ??
            json['profile_pic']?.toString() ??
            '',
        designation: json['designation']?.toString() ?? json['role']?.toString(),
        employeeId: json['employeeId']?.toString() ??
            json['employee_id']?.toString() ??
            json['id']?.toString(),
        status: json['status']?.toString(),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppUser &&
          runtimeType == other.runtimeType &&
          ((id != null && other.id != null && id == other.id) ||
              (email.isNotEmpty && email.toLowerCase() == other.email.toLowerCase()) ||
              (employeeId != null && employeeId == other.employeeId));

  @override
  int get hashCode => (id != null ? id.hashCode : email.toLowerCase().hashCode);
}

class GranularPermissionItem {
  final String key; // Now used for slug or generic string ID
  final int? id;    // Database ID required for API submission
  final String label;
  final String? description;
  bool isGranted;
  final String? status;

  GranularPermissionItem({
    required this.key,
    this.id,
    required this.label,
    this.description,
    this.isGranted = false,
    this.status,
  });

  GranularPermissionItem copyWith({
    String? key,
    int? id,
    String? label,
    String? description,
    bool? isGranted,
    String? status,
  }) {
    return GranularPermissionItem(
      key: key ?? this.key,
      id: id ?? this.id,
      label: label ?? this.label,
      description: description ?? this.description,
      isGranted: isGranted ?? this.isGranted,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() => {
        'key': key,
        'slug': key,
        'id': id,
        'label': label,
        'name': label,
        'description': description,
        'isGranted': isGranted,
        'is_assigned': isGranted,
        'status': status,
      };

  factory GranularPermissionItem.fromJson(Map<String, dynamic> json) =>
      GranularPermissionItem(
        key: json['slug']?.toString() ??
            json['key']?.toString() ??
            json['id']?.toString() ??
            '',
        id: json['id'] is int
            ? json['id']
            : int.tryParse(json['id']?.toString() ?? ''),
        label: json['name']?.toString() ?? json['label']?.toString() ?? '',
        description: json['description']?.toString(),
        isGranted: json['is_assigned'] == true ||
            json['isGranted'] == true ||
            json['status']?.toString().toLowerCase() == 'allowed',
        status: json['status']?.toString(),
      );
}

/// A group of granular permissions belonging to a Module / Submodule.
class ModulePermissionGroup {
  final String moduleId;
  final String moduleName;
  final String iconKey; // e.g. 'user', 'calendar', 'briefcase', etc.
  final List<GranularPermissionItem> permissions;
  final int? totalPermissions;
  final int? assignedCountApi;
  final bool? allAssigned;

  ModulePermissionGroup({
    required this.moduleId,
    required this.moduleName,
    required this.iconKey,
    required this.permissions,
    this.totalPermissions,
    this.assignedCountApi,
    this.allAssigned,
  });

  int get grantedCount => permissions.where((p) => p.isGranted).length;
  int get totalCount => permissions.length;
  bool get isAllGranted => totalCount > 0 && grantedCount == totalCount;

  ModulePermissionGroup copyWith({
    String? moduleId,
    String? moduleName,
    String? iconKey,
    List<GranularPermissionItem>? permissions,
    int? totalPermissions,
    int? assignedCountApi,
    bool? allAssigned,
  }) {
    return ModulePermissionGroup(
      moduleId: moduleId ?? this.moduleId,
      moduleName: moduleName ?? this.moduleName,
      iconKey: iconKey ?? this.iconKey,
      permissions: permissions ??
          this.permissions.map((p) => p.copyWith()).toList(),
      totalPermissions: totalPermissions ?? this.totalPermissions,
      assignedCountApi: assignedCountApi ?? this.assignedCountApi,
      allAssigned: allAssigned ?? this.allAssigned,
    );
  }

  Map<String, dynamic> toJson() => {
        'moduleId': moduleId,
        'module_slug': moduleId,
        'moduleName': moduleName,
        'module': moduleName,
        'iconKey': iconKey,
        'permissions': permissions.map((p) => p.toJson()).toList(),
        if (totalPermissions != null) 'total_permissions': totalPermissions,
        if (assignedCountApi != null)
          'assigned_permissions_count': assignedCountApi,
        if (allAssigned != null) 'all_assigned': allAssigned,
      };

  factory ModulePermissionGroup.fromJson(Map<String, dynamic> json) =>
      ModulePermissionGroup(
        moduleId: json['module_slug']?.toString() ??
            json['moduleId']?.toString() ??
            '',
        moduleName: json['module']?.toString() ??
            json['moduleName']?.toString() ??
            '',
        iconKey: json['iconKey']?.toString() ?? 'element',
        permissions: (json['permissions'] as List<dynamic>?)
                ?.map((item) => GranularPermissionItem.fromJson(
                    item is Map<String, dynamic>
                        ? item
                        : Map<String, dynamic>.from(item)))
                .toList() ??
            [],
        totalPermissions: json['total_permissions'] is int
            ? json['total_permissions']
            : int.tryParse(json['total_permissions']?.toString() ?? ''),
        assignedCountApi: json['assigned_permissions_count'] is int
            ? json['assigned_permissions_count']
            : int.tryParse(
                json['assigned_permissions_count']?.toString() ?? ''),
        allAssigned: json['all_assigned'] == true,
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
  final int? grantedPermissionsApi;
  final int? totalPermissionsApi;

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
    this.grantedPermissionsApi,
    this.totalPermissionsApi,
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
    int? grantedPermissionsApi,
    int? totalPermissionsApi,
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
      grantedPermissionsApi:
          grantedPermissionsApi ?? this.grantedPermissionsApi,
      totalPermissionsApi: totalPermissionsApi ?? this.totalPermissionsApi,
    );
  }

  int get totalPermissionsCount {
    if (grantedPermissionsApi != null) return grantedPermissionsApi!;
    return permissionGroups.fold(
        0, (sum, group) => sum + group.grantedCount);
  }

  int get maxPermissionsCount {
    if (totalPermissionsApi != null) return totalPermissionsApi!;
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
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        departmentId: json['departmentId']?.toString() ??
            json['department_id']?.toString(),
        departmentName: json['departmentName']?.toString() ??
            json['department']?.toString(),
        designationId: json['designationId']?.toString() ??
            json['designation_id']?.toString(),
        designationName: json['designationName']?.toString() ??
            json['designation']?.toString(),
        isActive: json['status'] == true ||
            json['status'] == 1 ||
            json['status']?.toString().toLowerCase() == 'true' ||
            json['isActive'] == true,
        permissionGroups: (json['modules'] as List<dynamic>?)
                ?.map((g) => ModulePermissionGroup.fromJson(
                    g is Map<String, dynamic>
                        ? g
                        : Map<String, dynamic>.from(g)))
                .toList() ??
            (json['permissionGroups'] as List<dynamic>?)
                ?.map((g) => ModulePermissionGroup.fromJson(
                    g is Map<String, dynamic>
                        ? g
                        : Map<String, dynamic>.from(g)))
                .toList() ??
            [],
        grantedPermissionsApi: json['assigned_permissions_count'] != null
            ? int.tryParse(json['assigned_permissions_count'].toString())
            : (json['granted_permissions'] != null
                ? int.tryParse(json['granted_permissions'].toString())
                : null),
        totalPermissionsApi: json['total_permissions'] != null
            ? int.tryParse(json['total_permissions'].toString())
            : null,
      );
}
