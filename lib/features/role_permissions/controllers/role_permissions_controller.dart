import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../models/role_permission_models.dart';

class RolePermissionsController extends GetxController {
  // Reactive list of roles
  final RxList<Role> roles = <Role>[].obs;
  
  // Search state
  final RxString searchQuery = ''.obs;

  // Mock list of all system users available for assignment
  final List<AppUser> allUsers = [
    const AppUser(name: 'John Doe', email: 'john.doe@example.com', avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150'),
    const AppUser(name: 'Sarah Smith', email: 'sarah.smith@example.com', avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150'),
    const AppUser(name: 'Michael Brown', email: 'michael.brown@example.com', avatarUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150'),
    const AppUser(name: 'Emily Johnson', email: 'emily.johnson@example.com', avatarUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150'),
    const AppUser(name: 'David Wilson', email: 'david.wilson@example.com', avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150'),
    const AppUser(name: 'Jessica Taylor', email: 'jessica.taylor@example.com', avatarUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150'),
  ];

  // Modules list for matrix
  final List<String> modules = [
    'Dashboard',
    'Users',
    'Employees',
    'Attendance',
    'Leaves',
    'Payroll',
    'Reports',
    'Settings',
  ];

  // Forms / Creation Observables
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final isActive = true.obs;
  final selectedUsers = <AppUser>[].obs;

  // Selected Role for Details / Permission modification
  final Rxn<Role> selectedRole = Rxn<Role>();

  // Temporary list to hold unsaved edits on the Permissions Matrix screen
  final RxList<ModulePermission> tempPermissions = <ModulePermission>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initializeDummyRoles();
  }

  void _initializeDummyRoles() {
    roles.addAll([
      Role(
        id: '1',
        name: 'Admin',
        description: 'Full system access',
        isActive: true,
        assignedUsers: [allUsers[0], allUsers[1], allUsers[2]],
        permissions: _createPermissionsMap(
          dashboard: [true, true, true, true],
          users: [true, true, true, true],
          employees: [true, true, true, true],
          attendance: [true, true, true, true],
          leaves: [true, true, true, true],
          payroll: [true, true, true, false],
          reports: [true, false, false, false],
          settings: [true, true, false, false],
        ),
      ),
      Role(
        id: '2',
        name: 'HR Manager',
        description: 'Manage HR & Employee',
        isActive: true,
        assignedUsers: [allUsers[1], allUsers[3]],
        permissions: _createPermissionsMap(
          dashboard: [true, true, true, false],
          users: [true, true, false, false],
          employees: [true, true, true, true],
          attendance: [true, true, true, false],
          leaves: [true, true, true, true],
          payroll: [true, false, false, false],
          reports: [true, false, false, false],
          settings: [false, false, false, false],
        ),
      ),
      Role(
        id: '3',
        name: 'Manager',
        description: 'Manage team & projects',
        isActive: true,
        assignedUsers: [allUsers[2]],
        permissions: _createPermissionsMap(
          dashboard: [true, false, false, false],
          users: [false, false, false, false],
          employees: [true, false, false, false],
          attendance: [true, true, true, false],
          leaves: [true, true, false, false],
          payroll: [false, false, false, false],
          reports: [true, false, false, false],
          settings: [false, false, false, false],
        ),
      ),
      Role(
        id: '4',
        name: 'Team Lead',
        description: 'Team supervision',
        isActive: true,
        assignedUsers: [allUsers[4], allUsers[5]],
        permissions: _createPermissionsMap(
          dashboard: [true, false, false, false],
          users: [false, false, false, false],
          employees: [true, false, false, false],
          attendance: [true, true, false, false],
          leaves: [true, true, false, false],
          payroll: [false, false, false, false],
          reports: [true, false, false, false],
          settings: [false, false, false, false],
        ),
      ),
      Role(
        id: '5',
        name: 'Employee',
        description: 'Basic employee access',
        isActive: true,
        assignedUsers: [allUsers[5]],
        permissions: _createPermissionsMap(
          dashboard: [true, false, false, false],
          users: [false, false, false, false],
          employees: [false, false, false, false],
          attendance: [true, false, false, false],
          leaves: [true, false, false, false],
          payroll: [false, false, false, false],
          reports: [false, false, false, false],
          settings: [false, false, false, false],
        ),
      ),
      Role(
        id: '6',
        name: 'Accountant',
        description: 'Manage finance & payroll',
        isActive: true,
        assignedUsers: [allUsers[3], allUsers[4]],
        permissions: _createPermissionsMap(
          dashboard: [true, false, false, false],
          users: [false, false, false, false],
          employees: [false, false, false, false],
          attendance: [true, false, false, false],
          leaves: [false, false, false, false],
          payroll: [true, true, true, true],
          reports: [true, true, false, false],
          settings: [false, false, false, false],
        ),
      ),
    ]);
  }

  List<ModulePermission> _createPermissionsMap({
    required List<bool> dashboard,
    required List<bool> users,
    required List<bool> employees,
    required List<bool> attendance,
    required List<bool> leaves,
    required List<bool> payroll,
    required List<bool> reports,
    required List<bool> settings,
  }) {
    return [
      ModulePermission(moduleName: 'Dashboard', view: dashboard[0], add: dashboard[1], edit: dashboard[2], delete: dashboard[3]),
      ModulePermission(moduleName: 'Users', view: users[0], add: users[1], edit: users[2], delete: users[3]),
      ModulePermission(moduleName: 'Employees', view: employees[0], add: employees[1], edit: employees[2], delete: employees[3]),
      ModulePermission(moduleName: 'Attendance', view: attendance[0], add: attendance[1], edit: attendance[2], delete: attendance[3]),
      ModulePermission(moduleName: 'Leaves', view: leaves[0], add: leaves[1], edit: leaves[2], delete: leaves[3]),
      ModulePermission(moduleName: 'Payroll', view: payroll[0], add: payroll[1], edit: payroll[2], delete: payroll[3]),
      ModulePermission(moduleName: 'Reports', view: reports[0], add: reports[1], edit: reports[2], delete: reports[3]),
      ModulePermission(moduleName: 'Settings', view: settings[0], add: settings[1], edit: settings[2], delete: settings[3]),
    ];
  }

  // Filtered Roles List
  List<Role> get filteredRoles {
    if (searchQuery.value.trim().isEmpty) {
      return roles;
    }
    return roles.where((r) {
      return r.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          r.description.toLowerCase().contains(searchQuery.value.toLowerCase());
    }).toList();
  }

  // Clear role form values
  void clearForm() {
    nameController.clear();
    descriptionController.clear();
    isActive.value = true;
    selectedUsers.clear();
  }

  // Add dummy user to current creation form
  void toggleUserSelection(AppUser user) {
    if (selectedUsers.contains(user)) {
      selectedUsers.remove(user);
    } else {
      selectedUsers.add(user);
    }
  }

  // Save new role
  void saveRole() {
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

    final newRole = Role(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: nameController.text.trim(),
      description: descriptionController.text.trim().isEmpty 
          ? 'No description provided' 
          : descriptionController.text.trim(),
      isActive: isActive.value,
      assignedUsers: List<AppUser>.from(selectedUsers),
      permissions: _createPermissionsMap(
        dashboard: [true, false, false, false],
        users: [false, false, false, false],
        employees: [false, false, false, false],
        attendance: [false, false, false, false],
        leaves: [false, false, false, false],
        payroll: [false, false, false, false],
        reports: [false, false, false, false],
        settings: [false, false, false, false],
      ),
    );

    roles.add(newRole);
    clearForm();
    Get.back();
    Get.snackbar(
      'Role Created',
      'New role has been successfully added',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  // Setup temporary permissions for editing matrix
  void editPermissions(Role role) {
    selectedRole.value = role;
    tempPermissions.value = role.permissions.map((p) => p.copyWith()).toList();
  }

  // Toggle permission value in matrix
  void togglePermissionCheckbox(String moduleName, String action) {
    int index = tempPermissions.indexWhere((p) => p.moduleName == moduleName);
    if (index != -1) {
      final perm = tempPermissions[index];
      switch (action) {
        case 'view':
          perm.view = !perm.view;
          break;
        case 'add':
          perm.add = !perm.add;
          break;
        case 'edit':
          perm.edit = !perm.edit;
          break;
        case 'delete':
          perm.delete = !perm.delete;
          break;
      }
      tempPermissions[index] = perm;
      tempPermissions.refresh();
    }
  }

  // Save modified permission matrix
  void savePermissions() {
    if (selectedRole.value == null) return;

    int roleIndex = roles.indexWhere((r) => r.id == selectedRole.value!.id);
    if (roleIndex != -1) {
      final updatedRole = roles[roleIndex].copyWith(
        permissions: List<ModulePermission>.from(tempPermissions),
      );
      roles[roleIndex] = updatedRole;
      selectedRole.value = updatedRole;
      roles.refresh();
      
      Get.back();
      Get.snackbar(
        'Permissions Saved',
        'Permissions for ${updatedRole.name} updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }

  // Delete user from role details
  void removeUserFromRole(Role role, AppUser user) {
    int roleIndex = roles.indexWhere((r) => r.id == role.id);
    if (roleIndex != -1) {
      final updatedUsers = List<AppUser>.from(roles[roleIndex].assignedUsers)..remove(user);
      final updatedRole = roles[roleIndex].copyWith(assignedUsers: updatedUsers);
      roles[roleIndex] = updatedRole;
      selectedRole.value = updatedRole;
      roles.refresh();
      
      Get.snackbar(
        'User Unassigned',
        '${user.name} removed from ${role.name}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
      );
    }
  }

  // Toggle status directly
  void toggleRoleStatus(Role role) {
    int roleIndex = roles.indexWhere((r) => r.id == role.id);
    if (roleIndex != -1) {
      final updatedRole = roles[roleIndex].copyWith(isActive: !roles[roleIndex].isActive);
      roles[roleIndex] = updatedRole;
      if (selectedRole.value?.id == role.id) {
        selectedRole.value = updatedRole;
      }
      roles.refresh();
      
      Get.snackbar(
        'Role Updated',
        '${role.name} status set to ${updatedRole.isActive ? "Active" : "Inactive"}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.primaryColor,
        colorText: Colors.white,
      );
    }
  }

  // Assign users to a role
  void assignUsersToRole(Role role, List<AppUser> usersToAssign) {
    int roleIndex = roles.indexWhere((r) => r.id == role.id);
    if (roleIndex != -1) {
      final updatedUsers = List<AppUser>.from(roles[roleIndex].assignedUsers)..addAll(usersToAssign);
      final updatedRole = roles[roleIndex].copyWith(assignedUsers: updatedUsers);
      roles[roleIndex] = updatedRole;
      selectedRole.value = updatedRole;
      roles.refresh();
      
      Get.snackbar(
        'Users Assigned',
        '${usersToAssign.length} user(s) assigned to ${role.name}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }

  // Setup edit form
  void setupEditForm(Role role) {
    nameController.text = role.name;
    descriptionController.text = role.description;
    isActive.value = role.isActive;
    selectedUsers.value = List<AppUser>.from(role.assignedUsers);
  }

  // Update role details
  void updateRole(String id) {
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

    int index = roles.indexWhere((r) => r.id == id);
    if (index != -1) {
      final updatedRole = roles[index].copyWith(
        name: nameController.text.trim(),
        description: descriptionController.text.trim().isEmpty
            ? 'No description provided'
            : descriptionController.text.trim(),
        isActive: isActive.value,
        assignedUsers: List<AppUser>.from(selectedUsers),
      );
      roles[index] = updatedRole;
      if (selectedRole.value?.id == id) {
        selectedRole.value = updatedRole;
      }
      roles.refresh();
      clearForm();
      Get.back();
      Get.snackbar(
        'Role Updated',
        'Role details updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }

  // Delete role
  void deleteRole(Role role) {
    roles.removeWhere((r) => r.id == role.id);
    if (selectedRole.value?.id == role.id) {
      selectedRole.value = null;
    }
    roles.refresh();
    Get.back(); // Go back from Role Details Screen to Role List Screen
    Get.snackbar(
      'Role Deleted',
      '${role.name} has been deleted successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
    );
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}
