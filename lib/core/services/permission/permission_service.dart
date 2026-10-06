import 'dart:convert';
import 'package:get/get.dart';
import '../../constants/app_constants.dart';
import '../../utils/logger.dart';
import '../network/api_client.dart';
import '../storage/shared_prefs.dart';
import 'permission_model.dart';

/// Simple RBAC Permission Service
class PermissionService extends GetxService {
  final ApiClient _apiClient;

  PermissionService({ApiClient? apiClient})
      : _apiClient =
            apiClient ??
            (Get.isRegistered<ApiClient>()
                ? Get.find<ApiClient>()
                : Get.put(ApiClient(), permanent: true));

  static PermissionService get to => Get.isRegistered<PermissionService>()
      ? Get.find<PermissionService>()
      : Get.put(PermissionService(), permanent: true);

  final RxBool isLoading = false.obs;

  /// Flag indicating whether current user has unrestricted admin access.
  /// If true (default when role_id is null / admin), all permissions are granted.
  final RxBool isAdmin = true.obs;

  /// Stores slug -> isAllowed (true/false)
  final RxMap<String, bool> permissions = <String, bool>{}.obs;

  /// Stores module_slug -> isAllowed (true/false)
  final RxMap<String, bool> modules = <String, bool>{}.obs;

  /// Stores full module models for UI rendering
  final RxList<PermissionModuleModel> moduleModels =
      <PermissionModuleModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    final roleId = SharedPrefs.getRoleId();
    if (roleId != null) {
      isAdmin.value = false;
      loadCachedPermissions();
    } else {
      isAdmin.value = true;
    }
  }

  /// Switch between admin mode (all permitted) and employee mode (gated by permissions)
  void setAdminMode(bool value) {
    isAdmin.value = value;
  }

  /// Load cached permissions from SharedPreferences for immediate offline/startup access
  void loadCachedPermissions() {
    try {
      final cached = SharedPrefs.getString(AppConstants.permissionsCache);
      if (cached != null && cached.isNotEmpty) {
        final decoded = jsonDecode(cached);
        if (decoded is List) {
          _parsePermissions(decoded);
          Logger.d('PermissionService => Loaded ${permissions.length} cached permissions');
        }
      }
    } catch (e) {
      Logger.e('PermissionService => Error loading cached permissions: $e');
    }
  }

  /// Fetch permissions from API
  /// GET /api/admin/permissions?role_id=:role_id
  Future<bool> fetchPermissions({dynamic roleId}) async {
    final effectiveRoleId = roleId ?? SharedPrefs.getRoleId();

    // If role_id is null or empty, user is Admin -> All permissions allowed
    if (effectiveRoleId == null || effectiveRoleId.toString().trim().isEmpty) {
      setAdminMode(true);
      permissions.clear();
      modules.clear();
      Logger.d('PermissionService => No role_id found. Running in unrestricted Admin mode.');
      return true;
    }

    setAdminMode(false);
    isLoading.value = true;

    try {
      final query = <String, dynamic>{
        'role_id': effectiveRoleId.toString().trim(),
      };

      Logger.d('PermissionService => Fetching permissions with role_id=$effectiveRoleId');

      final response = await _apiClient.get(
        AppConstants.adminPermissionsUrl,
        queryParameters: query,
        handleError: false,
        showToaster: false,
      );

      final data =
          response.json ??
          (response.body is Map<String, dynamic> ? response.body : null);
      if (data != null && data['modules'] is List) {
        final moduleList = data['modules'] as List;
        _parsePermissions(moduleList);

        // Cache the raw module response
        await SharedPrefs.setString(
          AppConstants.permissionsCache,
          jsonEncode(moduleList),
        );

        Logger.d(
            'PermissionService => Permissions loaded successfully for role_id=$effectiveRoleId: '
            '${permissions.length} permissions parsed across ${modules.length} modules.');
        return true;
      }
      return false;
    } catch (e) {
      Logger.e('PermissionService => Failed to fetch permissions: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Parses module and permission slugs from API response
  /// Handles both permissions list and actions map
  void _parsePermissions(List moduleList) {
    final newPerms = <String, bool>{};
    final newMods = <String, bool>{};

    final rawMaps = moduleList
        .whereType<Map>()
        .map((m) => Map<String, dynamic>.from(m))
        .toList();

    final modulesModelList = rawMaps
        .map((m) => PermissionModuleModel.fromJson(m))
        .toList();

    moduleModels.assignAll(modulesModelList);

    for (int i = 0; i < modulesModelList.length; i++) {
      final module = modulesModelList[i];
      final rawMap = rawMaps[i];
      bool anyAllowed = module.allAssigned || module.assignedCount > 0;

      // 1. Parse permissions list
      for (final perm in module.permissions) {
        if (perm.slug.isNotEmpty) {
          final isAllowed =
              perm.isAssigned == true || perm.status.toLowerCase().trim() == 'allowed';
          newPerms[perm.slug] = isAllowed;
          if (isAllowed) anyAllowed = true;
        }
      }

      // 2. Parse actions map if present
      final actions = rawMap['actions'];
      if (actions is Map) {
        actions.forEach((key, val) {
          final slug = key.toString().toLowerCase().trim();
          if (slug.isNotEmpty) {
            bool isAllowed = false;
            if (val is Map) {
              final allowedBool = val['allowed'];
              final statusStr = val['status']?.toString().toLowerCase().trim();
              isAllowed = allowedBool == true || statusStr == 'allowed';
            } else if (val is bool) {
              isAllowed = val;
            }
            if (isAllowed) {
              newPerms[slug] = true;
              anyAllowed = true;
            } else if (!newPerms.containsKey(slug)) {
              newPerms[slug] = false;
            }
          }
        });
      }

      if (module.moduleSlug.isNotEmpty) {
        newMods[module.moduleSlug] = anyAllowed;
      }
    }

    permissions.assignAll(newPerms);
    modules.assignAll(newMods);
  }

  /// Convenient helper to check if a specific action or feature is allowed
  /// Always returns true if user is Admin (role_id is null)
  bool isAllowed(String permissionSlug, {String? moduleSlug}) {
    if (isAdmin.value) return true;
    final permKey = permissionSlug.toLowerCase().trim();
    if (permissions.containsKey(permKey)) {
      return permissions[permKey] == true;
    }
    if (moduleSlug != null && moduleSlug.isNotEmpty) {
      final modKey = moduleSlug.toLowerCase().trim();
      return modules[modKey] ?? false;
    }
    return false;
  }

  /// Checks if an entire module is allowed
  /// Always returns true if user is Admin (role_id is null)
  bool isModuleAllowed(String moduleSlug) {
    if (isAdmin.value) return true;
    if (moduleSlug.isEmpty) return false;
    final key = moduleSlug.toLowerCase().trim();
    return modules[key] ?? false;
  }

  /// Checks if a module is present in the list
  bool hasModule(String moduleSlug) {
    if (isAdmin.value) return true;
    if (moduleSlug.isEmpty) return false;
    final key = moduleSlug.toLowerCase().trim();
    return moduleModels.any((module) => module.moduleSlug == key);
  }

  /// Checks if a module slug, permission slug, or both exist.
  bool hasSlug({String? moduleSlug, String? permissionSlug}) {
    if (isAdmin.value) return true;
    if ((moduleSlug == null || moduleSlug.isEmpty) &&
        (permissionSlug == null || permissionSlug.isEmpty)) {
      return false;
    }

    final modKey = moduleSlug?.toLowerCase().trim();
    final permKey = permissionSlug?.toLowerCase().trim();

    // 1. If BOTH are provided
    if (modKey != null && modKey.isNotEmpty && permKey != null && permKey.isNotEmpty) {
      for (final module in moduleModels) {
        if (module.moduleSlug == modKey) {
          return module.permissions.any((p) => p.slug.toLowerCase().trim() == permKey);
        }
      }
      return false;
    }

    // 2. If ONLY moduleSlug is provided
    if (modKey != null && modKey.isNotEmpty) {
      return moduleModels.any((m) => m.moduleSlug == modKey);
    }

    // 3. If ONLY permissionSlug is provided
    if (permKey != null && permKey.isNotEmpty) {
      for (final module in moduleModels) {
        if (module.permissions.any((p) => p.slug.toLowerCase().trim() == permKey)) {
          return true;
        }
      }
    }

    return false;
  }

  /// Checks if a module slug, permission slug, or both are allowed.
  /// If isAdmin == true, always returns true.
  bool hasPermission({String? moduleSlug, String? permissionSlug}) {
    if (isAdmin.value) return true;

    if ((moduleSlug == null || moduleSlug.isEmpty) &&
        (permissionSlug == null || permissionSlug.isEmpty)) {
      return false;
    }

    final modKey = moduleSlug?.toLowerCase().trim();
    final permKey = permissionSlug?.toLowerCase().trim();

    // 1. If BOTH are provided
    if (modKey != null && modKey.isNotEmpty && permKey != null && permKey.isNotEmpty) {
      if (permissions.containsKey(permKey)) {
        return permissions[permKey] == true;
      }
      for (final module in moduleModels) {
        if (module.moduleSlug == modKey) {
          for (final perm in module.permissions) {
            if (perm.slug.toLowerCase().trim() == permKey) {
              return perm.isAssigned == true ||
                  perm.status.toLowerCase().trim() == 'allowed';
            }
          }
        }
      }
      return false;
    }

    // 2. If ONLY moduleSlug is provided
    if (modKey != null && modKey.isNotEmpty) {
      return modules[modKey] ?? false;
    }

    // 3. If ONLY permissionSlug is provided
    if (permKey != null && permKey.isNotEmpty) {
      return permissions[permKey] ?? false;
    }

    return false;
  }

  /// Retrieves the full PermissionModuleModel for a given module slug.
  /// Returns null if not found.
  PermissionModuleModel? getModuleModel(String moduleSlug) {
    if (moduleSlug.isEmpty) return null;
    final key = moduleSlug.toLowerCase().trim();

    for (final module in moduleModels) {
      if (module.moduleSlug == key) {
        return module;
      }
    }
    return null;
  }

  /// Retrieves the full PermissionItemModel for a given permission slug.
  /// Returns null if not found.
  PermissionItemModel? getPermissionModel(String permissionSlug) {
    if (permissionSlug.isEmpty) return null;
    final key = permissionSlug.toLowerCase().trim();

    for (final module in moduleModels) {
      for (final perm in module.permissions) {
        if (perm.slug.toLowerCase().trim() == key) {
          return perm;
        }
      }
    }
    return null;
  }
}
