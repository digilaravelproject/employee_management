import 'package:get/get.dart';
import '../core/constants/app_constants.dart';
import '../core/services/network/api_client.dart';
import '../core/utils/logger.dart';

/// Simple RBAC Permission Service
class PermissionService extends GetxService {
  final ApiClient _apiClient;

  PermissionService({ApiClient? apiClient})
      : _apiClient = apiClient ??
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

      final data = response.json ?? (response.body is Map<String, dynamic> ? response.body : null);
      if (data != null && data['modules'] is List) {
        _parsePermissions(data['modules'] as List);
        return true;
      }
      return false;
    } catch (e) {
      Logger.e('PermissionService error: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Parses module and permission slugs from API response
  void _parsePermissions(List moduleList) {
    final newPerms = <String, bool>{};
    final newMods = <String, bool>{};

    for (final m in moduleList) {
      if (m is! Map) continue;
      final modSlug = m['module_slug']?.toString().toLowerCase().trim() ?? '';
      final permsList = m['permissions'] is List ? m['permissions'] as List : [];

      bool anyAllowed = m['all_assigned'] == true || (m['assigned_permissions_count'] ?? 0) > 0;

      for (final p in permsList) {
        if (p is! Map) continue;
        final slug = p['slug']?.toString().toLowerCase().trim() ?? '';
        final isAllowed = p['is_assigned'] == true ||
            p['status']?.toString().toLowerCase() == 'allowed';

        if (slug.isNotEmpty) {
          newPerms[slug] = isAllowed;
          if (isAllowed) anyAllowed = true;
        }
      }

      if (modSlug.isNotEmpty) {
        newMods[modSlug] = anyAllowed;
      }
    }

    permissions.assignAll(newPerms);
    modules.assignAll(newMods);
  }

  /// Check permission by slug or module_slug (returns true/false)
  bool hasPermission(String slug) {
    final key = slug.toLowerCase().trim();
    return permissions[key] ?? modules[key] ?? false;
  }

  /// Alias for hasPermission
  bool hasAllowed(String slug) => hasPermission(slug);

  /// Check if an entire module has permission
  bool hasModule(String moduleSlug) {
    return modules[moduleSlug.toLowerCase().trim()] ?? false;
  }
}
