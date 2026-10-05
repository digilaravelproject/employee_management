import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/role_permission_models.dart';
import '../repositories/role_permissions_repository.dart';
import '../../../core/services/network/api_client.dart';
import '../../../core/utils/logger.dart';
import '../../../core/utils/custom_snackbar.dart';

class RolePermissionsController extends GetxController {
  late final RolePermissionsRepository _repository;

  RolePermissionsController() {
    _repository = RolePermissionsRepository(apiClient: Get.find<ApiClient>());
  }

  // Reactive list of roles
  final RxList<Role> roles = <Role>[].obs;

  // Search state
  final RxString searchQuery = ''.obs;

  // Forms / Creation Observables
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final isActive = true.obs;

  // Department & Designation (Selectable for the Role)
  final RxnString selectedDepartmentName = RxnString();
  final RxnString selectedDesignationName = RxnString();

  // Selected Role for Details
  final Rxn<Role> selectedRole = Rxn<Role>();

  // Temporary list to hold unsaved edits on the Granular Permissions Matrix screen
  final RxList<ModulePermissionGroup> tempPermissionGroups =
      <ModulePermissionGroup>[].obs;

  final isLoadingPermissions = false.obs;

  final isLoadingRoles = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchRolesFromApi();
    fetchPermissionsFromApi();
    
    debounce(searchQuery, (String query) {
      if (query.trim().isEmpty) {
        fetchRolesFromApi(showLoader: false);
      } else {
        searchRolesFromApi(query);
      }
    }, time: const Duration(milliseconds: 500));
  }

  Future<void> searchRolesFromApi(String query) async {
    try {
      final response = await _repository.searchRoles(query);
      if (response.isSuccess && response.json != null && response.json!['status'] == true) {
        final data = response.json!['data'] as List;
        final fetchedRoles = data.map((json) => Role.fromJson(json)).toList();
        roles.assignAll(fetchedRoles);
      } else {
        CustomSnackbar.showError(response.message);
      }
    } catch (e) {
      Logger.e('RolePermissionsController => Failed to search roles: $e');
      CustomSnackbar.showError('An error occurred while searching roles.');
    }
  }

  Future<void> fetchRolesFromApi({bool showLoader = true}) async {
    try {
      if (showLoader) isLoadingRoles.value = true;
      final response = await _repository.getRoles();
      if (response.isSuccess && response.json != null && response.json!['status'] == true) {
        final data = response.json!['data'] as List;
        final fetchedRoles = data.map((json) => Role.fromJson(json)).toList();
        roles.assignAll(fetchedRoles);
      } else {
        CustomSnackbar.showError(response.message);
      }
    } catch (e) {
      Logger.e('RolePermissionsController => Failed to fetch roles: $e');
      CustomSnackbar.showError('An error occurred while fetching roles.');
    } finally {
      if (showLoader) isLoadingRoles.value = false;
    }
  }

  final isLoadingRoleDetails = false.obs;

  Future<void> fetchRoleDetails(String id) async {
    try {
      isLoadingRoleDetails.value = true;
      final response = await _repository.getRoleDetails(id);
      
      if (response.isSuccess && response.json != null && response.json!['status'] == true) {
        final data = response.json!['data'];
        
        // Extract granted permission IDs
        final List<int> grantedIds = [];
        if (data['permission_ids'] != null) {
          grantedIds.addAll(List<int>.from(data['permission_ids']));
        }
        
        // Deep copy tempPermissionGroups to create this role's specific groups
        final List<ModulePermissionGroup> roleGroups = tempPermissionGroups.map((group) {
          final updatedPermissions = group.permissions.map((p) {
            final isGranted = p.id != null && grantedIds.contains(p.id);
            return p.copyWith(isGranted: isGranted);
          }).toList();
          
          return group.copyWith(permissions: updatedPermissions);
        }).toList();

        // Update the basic details but inject the detailed groups
        final detailedRole = Role.fromJson(data).copyWith(
          permissionGroups: roleGroups,
        );
        
        selectedRole.value = detailedRole;
        
        // Optionally update it in the local list so the list view also knows
        final index = roles.indexWhere((r) => r.id == id);
        if (index != -1) {
          roles[index] = detailedRole;
        }
      } else {
        CustomSnackbar.showError(response.message);
      }
    } catch (e) {
      Logger.e('RolePermissionsController => Failed to fetch role details: $e');
      CustomSnackbar.showError('An error occurred while fetching role details.');
    } finally {
      isLoadingRoleDetails.value = false;
    }
  }

  Future<void> fetchPermissionsFromApi() async {
    try {
      isLoadingPermissions.value = true;
      final response = await _repository.getPermissions();
      if (response.isSuccess && response.json != null && response.json!['status'] == true) {
        final modulesList = response.json!['modules'] as List;
        final List<ModulePermissionGroup> groups = [];
        
        for (var moduleMap in modulesList) {
          final permissionsList = moduleMap['permissions'] as List;
          final List<GranularPermissionItem> permissions = permissionsList.map((p) {
            return GranularPermissionItem(
              key: p['slug'] ?? p['id'].toString(),
              id: p['id'] != null ? int.tryParse(p['id'].toString()) : null,
              label: p['name'] ?? '',
              description: p['description'],
              isGranted: p['is_assigned'] ?? false,
            );
          }).toList();

          groups.add(ModulePermissionGroup(
            moduleId: moduleMap['module_slug'] ?? '',
            moduleName: moduleMap['module'] ?? '',
            iconKey: 'element', // Default icon, adjust if mapping exists
            permissions: permissions,
          ));
        }

        if (groups.isNotEmpty) {
          tempPermissionGroups.assignAll(groups);
        }
      } else {
        CustomSnackbar.showError(response.message);
      }
    } catch (e) {
      Logger.e('Error parsing permissions: $e');
      CustomSnackbar.showError('An error occurred while fetching permissions.');
    } finally {
      isLoadingPermissions.value = false;
    }
  }

  // Filtered Roles List
  List<Role> get filteredRoles {
    if (searchQuery.value.trim().isEmpty) {
      return roles;
    }
    return roles.where((r) {
      return r.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          r.description.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          (r.departmentName?.toLowerCase().contains(searchQuery.value.toLowerCase()) ?? false) ||
          (r.designationName?.toLowerCase().contains(searchQuery.value.toLowerCase()) ?? false);
    }).toList();
  }

  // Clear role form values for New Role
  void clearForm() {
    nameController.clear();
    descriptionController.clear();
    isActive.value = true;
    selectedDepartmentName.value = null;
    selectedDesignationName.value = null;
    if (tempPermissionGroups.isNotEmpty) {
      tempPermissionGroups.assignAll(
        tempPermissionGroups.map((group) {
          return group.copyWith(
            permissions: group.permissions.map((p) => p.copyWith(isGranted: false)).toList(),
          );
        }).toList(),
      );
    } else {
      fetchPermissionsFromApi();
    }
  }

  // Populate form for Editing an existing Role
  void populateForEdit(Role role) {
    selectedRole.value = role;
    nameController.text = role.name;
    descriptionController.text = role.description;
    isActive.value = role.isActive;
    selectedDepartmentName.value = role.departmentName;
    selectedDesignationName.value = role.designationName;

    // Deep copy permission groups into temp
    tempPermissionGroups.assignAll(
      role.permissionGroups.map((group) => group.copyWith()).toList(),
    );
  }

  // Toggle a single permission switch
  void togglePermission(String moduleId, String permissionKey, bool value) {
    final groupIndex = tempPermissionGroups.indexWhere((g) => g.moduleId == moduleId);
    if (groupIndex != -1) {
      final group = tempPermissionGroups[groupIndex];
      final itemIndex = group.permissions.indexWhere((p) => p.key == permissionKey);
      if (itemIndex != -1) {
        group.permissions[itemIndex].isGranted = value;
        tempPermissionGroups[groupIndex] = group.copyWith(
          permissions: List<GranularPermissionItem>.from(group.permissions),
        );
      }
    }
  }

  // Toggle all permissions inside a module
  void toggleModuleAll(String moduleId, bool value) {
    final groupIndex = tempPermissionGroups.indexWhere((g) => g.moduleId == moduleId);
    if (groupIndex != -1) {
      final group = tempPermissionGroups[groupIndex];
      final updatedPermissions = group.permissions.map((p) {
        return p.copyWith(isGranted: value);
      }).toList();

      tempPermissionGroups[groupIndex] = group.copyWith(
        permissions: updatedPermissions,
      );
    }
  }

  // Toggle all permissions in the whole system (Grant All / Revoke All)
  void toggleAllPermissions(bool value) {
    final updated = tempPermissionGroups.map((group) {
      return group.copyWith(
        permissions: group.permissions.map((p) => p.copyWith(isGranted: value)).toList(),
      );
    }).toList();
    tempPermissionGroups.assignAll(updated);
  }

  final isSavingRole = false.obs;

  // Save new role via API
  Future<void> saveRole() async {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar(
        'Required Field',
        'Please enter a role name',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isSavingRole.value = true;

      // Extract permission IDs that are granted
      final List<int> permissionIds = [];
      for (final group in tempPermissionGroups) {
        for (final p in group.permissions) {
          if (p.isGranted && p.id != null) {
            permissionIds.add(p.id!);
          }
        }
      }

      final requestData = {
        "name": nameController.text.trim(),
        "department": selectedDepartmentName.value ?? "General",
        "description": descriptionController.text.trim().isEmpty
            ? 'No description provided'
            : descriptionController.text.trim(),
        "status": isActive.value,
        "permission_ids": permissionIds
      };

      final response = await _repository.createRole(requestData);

      if (response.isSuccess && response.json != null && response.json!['status'] == true) {
        final data = response.json!['data'];
        
        // Add locally
        final newRole = Role.fromJson(data);
        
        // Ensure local groups match the UI for immediate display if parsing didn't match perfectly
        final finalRole = newRole.copyWith(
          permissionGroups: List<ModulePermissionGroup>.from(tempPermissionGroups),
        );
        
        roles.add(finalRole);
        clearForm();
        Get.back();
        CustomSnackbar.showSuccess(response.json!['message'] ?? 'Role created successfully.');
      } else {
        CustomSnackbar.showError(response.message);
      }
    } catch (e) {
      Logger.e('RolePermissionsController => Failed to save role: $e');
      CustomSnackbar.showError('An error occurred while creating the role');
    } finally {
      isSavingRole.value = false;
    }
  }

  // Update existing role
  Future<void> updateRole(String id) async {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar(
        'Required Field',
        'Role name cannot be empty',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isSavingRole.value = true;

      // Extract permission IDs that are granted
      final List<int> permissionIds = [];
      for (final group in tempPermissionGroups) {
        for (final p in group.permissions) {
          if (p.isGranted && p.id != null) {
            permissionIds.add(p.id!);
          }
        }
      }

      final requestData = {
        "name": nameController.text.trim(),
        "department": selectedDepartmentName.value ?? "General",
        "description": descriptionController.text.trim().isEmpty
            ? 'No description provided'
            : descriptionController.text.trim(),
        "status": isActive.value,
        "permission_ids": permissionIds
      };

      final response = await _repository.updateRole(id, requestData);

      if (response.isSuccess && response.json != null && response.json!['status'] == true) {
        final data = response.json!['data'];
        
        // Update locally
        final newRole = Role.fromJson(data);
        
        final finalRole = newRole.copyWith(
          permissionGroups: List<ModulePermissionGroup>.from(tempPermissionGroups),
        );
        
        final index = roles.indexWhere((r) => r.id == id);
        if (index != -1) {
          roles[index] = finalRole;
        }

        if (selectedRole.value?.id == id) {
          selectedRole.value = finalRole;
        }
        roles.refresh();
        
        Get.back();
        CustomSnackbar.showSuccess(response.json!['message'] ?? 'Role updated successfully.');
      } else {
        CustomSnackbar.showError(response.message);
      }
    } catch (e) {
      Logger.e('RolePermissionsController => Failed to update role: $e');
      CustomSnackbar.showError('An error occurred while updating the role');
    } finally {
      isSavingRole.value = false;
    }
  }

  // Delete role
  Future<void> deleteRole(String id) async {
    try {
      Get.back(); // close the dialog immediately

      // Optimistically remove from UI
      final roleIndex = roles.indexWhere((r) => r.id == id);
      Role? removedRole;
      if (roleIndex != -1) {
        removedRole = roles.removeAt(roleIndex);
      }
      
      if (selectedRole.value?.id == id) {
        selectedRole.value = null;
        Get.back(); // close details screen if it's open
      }

      final response = await _repository.deleteRole(id);

      if (response.isSuccess && response.json != null && response.json!['status'] == true) {
        CustomSnackbar.showSuccess(response.json!['message'] ?? 'Role deleted successfully.');
      } else {
        // Rollback on failure
        if (removedRole != null) {
          roles.insert(roleIndex, removedRole);
        }
        CustomSnackbar.showError(response.message);
      }
    } catch (e) {
      Logger.e('RolePermissionsController => Failed to delete role: $e');
      CustomSnackbar.showError('An error occurred while deleting the role');
    }
  }
}
