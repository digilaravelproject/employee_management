import 'package:get/get.dart';
import '../../constants/app_constants.dart';
import '../../utils/logger.dart';
import '../network/api_client.dart';
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

  /// Stores slug -> isAllowed (true/false)
  final RxMap<String, bool> permissions = <String, bool>{}.obs;

  /// Stores module_slug -> isAllowed (true/false)
  final RxMap<String, bool> modules = <String, bool>{}.obs;

  /// Stores full module models for UI rendering
  final RxList<PermissionModuleModel> moduleModels =
      <PermissionModuleModel>[].obs;

  /// Fetch permissions from API
  /// GET /api/admin/permissions?role_id=:role_id
  Future<bool> fetchPermissions({dynamic roleId}) async {
    isLoading.value = true;

    try {
      final query = <String, dynamic>{};
      if (roleId != null && roleId.toString().trim().isNotEmpty) {
        query['role_id'] = roleId.toString().trim();
      }

      final response = await _apiClient.get(
        AppConstants.adminPermissionsUrl,
        queryParameters: query.isNotEmpty ? query : null,
        handleError: false,
        showToaster: false,
      );

      final data =
          response.json ??
          (response.body is Map<String, dynamic> ? response.body : null);
      if (data != null && data['modules'] is List) {
        _parsePermissions(data['modules'] as List);
        return true;
      }
      return false;
    } catch (e) {
      Logger.e;
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Parses module and permission slugs from API response
  void _parsePermissions(List moduleList) {
    final newPerms = <String, bool>{};
    final newMods = <String, bool>{};

    final modulesModelList = moduleList
        .whereType<Map>()
        .map(
          (m) => PermissionModuleModel.fromJson(
            Map<String, dynamic>.from(m),
          ),
        )
        .toList();

    moduleModels.assignAll(modulesModelList);

    for (final module in modulesModelList) {
      bool anyAllowed = module.allAssigned || module.assignedCount > 0;

      for (final perm in module.permissions) {
        if (perm.slug.isNotEmpty) {
          final isAllowed = perm.isAssigned == true && perm.status.toLowerCase() == 'allowed';
          newPerms[perm.slug] = isAllowed;
          if (isAllowed) anyAllowed = true;
        }
      }

      if (module.moduleSlug.isNotEmpty) {
        newMods[module.moduleSlug] = anyAllowed;
      }
    }

    permissions.assignAll(newPerms);
    modules.assignAll(newMods);
  }


  /// Checks if a module is present in the list
  bool hasModule(String moduleSlug) {
    if (moduleSlug.isEmpty) return false;
    final key = moduleSlug.toLowerCase().trim();
    return moduleModels.any((module) => module.moduleSlug == key);
  }

  /// Checks if a module slug, permission slug, or both exist.
  bool hasSlug({String? moduleSlug, String? permissionSlug}) {
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
  /// This checks if the specific item has is_assigned == true AND status == 'allowed'.
  bool hasPermission({String? moduleSlug, String? permissionSlug}) {
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
          for (final perm in module.permissions) {
            if (perm.slug.toLowerCase().trim() == permKey) {
               return perm.isAssigned == true && perm.status.toLowerCase() == 'allowed';
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
