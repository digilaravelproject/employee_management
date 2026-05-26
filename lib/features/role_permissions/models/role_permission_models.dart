class AppUser {
  final String name;
  final String email;
  final String avatarUrl;

  const AppUser({
    required this.name,
    required this.email,
    required this.avatarUrl,
  });
}

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

  ModulePermission copyWith({
    String? moduleName,
    bool? view,
    bool? add,
    bool? edit,
    bool? delete,
  }) {
    return ModulePermission(
      moduleName: moduleName ?? this.moduleName,
      view: view ?? this.view,
      add: add ?? this.add,
      edit: edit ?? this.edit,
      delete: delete ?? this.delete,
    );
  }

  int get allowedCount {
    int count = 0;
    if (view) count++;
    if (add) count++;
    if (edit) count++;
    if (delete) count++;
    return count;
  }
}

class Role {
  final String id;
  final String name;
  final String description;
  final bool isActive;
  final List<AppUser> assignedUsers;
  final List<ModulePermission> permissions;

  const Role({
    required this.id,
    required this.name,
    required this.description,
    this.isActive = true,
    required this.assignedUsers,
    required this.permissions,
  });

  Role copyWith({
    String? id,
    String? name,
    String? description,
    bool? isActive,
    List<AppUser>? assignedUsers,
    List<ModulePermission>? permissions,
  }) {
    return Role(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      assignedUsers: assignedUsers ?? this.assignedUsers,
      permissions: permissions ?? this.permissions,
    );
  }

  int get totalPermissionsCount {
    return permissions.fold(0, (sum, perm) => sum + perm.allowedCount);
  }
}
