import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/permission_keys.dart';
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
        CustomSnackbar.showError(response.message ?? 'Failed to search roles');
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
        CustomSnackbar.showError(response.message ?? 'Failed to fetch roles');
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
        CustomSnackbar.showError(response.message ?? 'Failed to fetch role details');
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
        CustomSnackbar.showError(response.message ?? 'Failed to fetch permissions');
      }
    } catch (e) {
      Logger.e('Error parsing permissions: $e');
      CustomSnackbar.showError('An error occurred while fetching permissions.');
    } finally {
      isLoadingPermissions.value = false;
    }
  }

  /// Generate the full, comprehensive catalog of all 13 modules and their granular action permissions.
  List<ModulePermissionGroup> generateDefaultPermissionCatalog({
    bool allGranted = false,
    Set<String>? grantedKeys,
  }) {
    List<GranularPermissionItem> buildItems(List<Map<String, String>> items) {
      return items.map((item) {
        final key = item['key']!;
        final isGranted = allGranted || (grantedKeys?.contains(key) ?? false);
        return GranularPermissionItem(
          key: key,
          label: item['label']!,
          description: item['desc'],
          isGranted: isGranted,
        );
      }).toList();
    }

    return [
      // 1. Profile & Documents
      ModulePermissionGroup(
        moduleId: 'profile',
        moduleName: 'Profile & Documents',
        iconKey: 'user',
        permissions: buildItems([
          {'key': PermissionKeys.profileView, 'label': 'View Profile Details', 'desc': 'Access to view employee/student profile'},
          {'key': PermissionKeys.profileEdit, 'label': 'Edit Profile Info', 'desc': 'Modify name, contact and personal details'},
          {'key': PermissionKeys.profileChangeAvatar, 'label': 'Change Avatar', 'desc': 'Upload or update profile picture'},
          {'key': PermissionKeys.profileViewAddress, 'label': 'View Address', 'desc': 'View residential address details'},
          {'key': PermissionKeys.profileViewBankDetails, 'label': 'View Bank Details', 'desc': 'View bank account & IFSC information'},
          {'key': PermissionKeys.profileEditBankDetails, 'label': 'Edit Bank Details', 'desc': 'Update bank account information'},
          {'key': PermissionKeys.profileDocumentView, 'label': 'View Documents', 'desc': 'Browse uploaded identity & academic documents'},
          {'key': PermissionKeys.profileDocumentUpload, 'label': 'Upload Documents', 'desc': 'Upload Aadhar, PAN, ID & marksheets'},
          {'key': PermissionKeys.profileDocumentZoom, 'label': 'Zoom & Preview Document', 'desc': 'Open interactive fullscreen zoom viewer'},
          {'key': PermissionKeys.profileDocumentDelete, 'label': 'Delete Documents', 'desc': 'Remove uploaded document records'},
        ]),
      ),

      // 2. Attendance & Regularization
      ModulePermissionGroup(
        moduleId: 'attendance',
        moduleName: 'Attendance & Regularization',
        iconKey: 'calendar',
        permissions: buildItems([
          {'key': PermissionKeys.attendanceView, 'label': 'View Attendance Screen', 'desc': 'Access attendance module'},
          {'key': PermissionKeys.attendanceCheckInOut, 'label': 'Check-In / Check-Out', 'desc': 'Mark self attendance punches'},
          {'key': PermissionKeys.attendanceHistoryView, 'label': 'View Attendance History', 'desc': 'See personal attendance punch logs'},
          {'key': PermissionKeys.attendanceRegularizeRequest, 'label': 'Request Regularization', 'desc': 'Submit regularization requests'},
          {'key': PermissionKeys.attendanceRegularizeApprove, 'label': 'Approve Regularization', 'desc': 'Approve or reject team regularization'},
          {'key': PermissionKeys.attendanceTeamView, 'label': 'View Team Attendance', 'desc': 'See whole team / department attendance'},
          {'key': PermissionKeys.attendanceExport, 'label': 'Export Attendance', 'desc': 'Download attendance excel/pdf reports'},
        ]),
      ),

      // 3. Leave Management
      ModulePermissionGroup(
        moduleId: 'leave',
        moduleName: 'Leave Management',
        iconKey: 'timer',
        permissions: buildItems([
          {'key': PermissionKeys.leaveView, 'label': 'View Leave Dashboard', 'desc': 'Access leave management screen'},
          {'key': PermissionKeys.leaveApply, 'label': 'Apply for Leave', 'desc': 'Submit new leave applications'},
          {'key': PermissionKeys.leaveCancel, 'label': 'Cancel Leave', 'desc': 'Cancel own applied leave requests'},
          {'key': PermissionKeys.leaveBalanceView, 'label': 'View Leave Balance', 'desc': 'See casual, sick, earned leave balances'},
          {'key': PermissionKeys.leaveApproveReject, 'label': 'Approve / Reject Leave', 'desc': 'Review and decide employee leave requests'},
          {'key': PermissionKeys.leaveAllEmployeeRequests, 'label': 'All Employees Requests', 'desc': 'View leave history of all staff'},
          {'key': PermissionKeys.leavePolicyView, 'label': 'View Leave Policy', 'desc': 'Access leave quota and rules document'},
        ]),
      ),

      // 4. Employee Management
      ModulePermissionGroup(
        moduleId: 'employee',
        moduleName: 'Employee Management',
        iconKey: 'profile_2user',
        permissions: buildItems([
          {'key': PermissionKeys.employeeView, 'label': 'View Employee Directory', 'desc': 'Browse company employee records'},
          {'key': PermissionKeys.employeeAdd, 'label': 'Add New Employee', 'desc': 'Onboard and create new employee records'},
          {'key': PermissionKeys.employeeEdit, 'label': 'Edit Employee Details', 'desc': 'Modify employee info & assignments'},
          {'key': PermissionKeys.employeeDelete, 'label': 'Delete Employee', 'desc': 'Remove employee record from system'},
          {'key': PermissionKeys.employeeViewSalary, 'label': 'View Salary Structure', 'desc': 'See monthly CTC and salary details'},
          {'key': PermissionKeys.employeeEditSalary, 'label': 'Edit Salary Structure', 'desc': 'Update compensation package'},
          {'key': PermissionKeys.employeeViewDocuments, 'label': 'View Uploaded Documents', 'desc': 'Inspect employee verification documents'},
          {'key': PermissionKeys.employeeStatusChange, 'label': 'Change Status (Active/Inactive)', 'desc': 'Toggle employee account active status'},
        ]),
      ),

      // 5. Tasks & Projects
      ModulePermissionGroup(
        moduleId: 'tasks',
        moduleName: 'Tasks & Projects',
        iconKey: 'task',
        permissions: buildItems([
          {'key': PermissionKeys.tasksView, 'label': 'View Tasks', 'desc': 'See personal & project task list'},
          {'key': PermissionKeys.tasksCreate, 'label': 'Create Task', 'desc': 'Add new tasks and milestones'},
          {'key': PermissionKeys.tasksEdit, 'label': 'Edit Task', 'desc': 'Update task status, priority, and deadlines'},
          {'key': PermissionKeys.tasksDelete, 'label': 'Delete Task', 'desc': 'Remove task from project board'},
          {'key': PermissionKeys.tasksAssign, 'label': 'Assign Task', 'desc': 'Assign tasks to team members'},
          {'key': PermissionKeys.tasksDailyUpdate, 'label': 'Daily Task Update', 'desc': 'Submit daily work log & timesheet'},
          {'key': PermissionKeys.projectsView, 'label': 'View Projects', 'desc': 'Access projects list and details'},
          {'key': PermissionKeys.projectsCreate, 'label': 'Create Project', 'desc': 'Start and configure new project'},
          {'key': PermissionKeys.projectsEdit, 'label': 'Edit Project', 'desc': 'Update project deadlines and teams'},
          {'key': PermissionKeys.projectsDelete, 'label': 'Delete Project', 'desc': 'Archive or delete project'},
        ]),
      ),

      // 6. Departments & Designations
      ModulePermissionGroup(
        moduleId: 'departments',
        moduleName: 'Departments & Designations',
        iconKey: 'hierarchy',
        permissions: buildItems([
          {'key': PermissionKeys.departmentView, 'label': 'View Departments', 'desc': 'Browse company departments'},
          {'key': PermissionKeys.departmentAdd, 'label': 'Add Department', 'desc': 'Create new organizational department'},
          {'key': PermissionKeys.departmentEdit, 'label': 'Edit Department', 'desc': 'Update department head and info'},
          {'key': PermissionKeys.departmentDelete, 'label': 'Delete Department', 'desc': 'Remove empty department'},
          {'key': PermissionKeys.designationView, 'label': 'View Designations', 'desc': 'Browse job designations'},
          {'key': PermissionKeys.designationAdd, 'label': 'Add Designation', 'desc': 'Create new job designation'},
          {'key': PermissionKeys.designationEdit, 'label': 'Edit Designation', 'desc': 'Modify job title and level'},
          {'key': PermissionKeys.designationDelete, 'label': 'Delete Designation', 'desc': 'Remove unused designation'},
        ]),
      ),

      // 7. Payroll & Salary
      ModulePermissionGroup(
        moduleId: 'payroll',
        moduleName: 'Payroll & Salary',
        iconKey: 'card',
        permissions: buildItems([
          {'key': PermissionKeys.payrollViewMy, 'label': 'View My Salary', 'desc': 'See personal payslip and salary history'},
          {'key': PermissionKeys.payrollManageAll, 'label': 'Manage Company Payroll', 'desc': 'Access company-wide payroll module'},
          {'key': PermissionKeys.payrollProcess, 'label': 'Process Monthly Payroll', 'desc': 'Calculate and generate monthly payroll'},
          {'key': PermissionKeys.payrollDownloadPayslip, 'label': 'Download Payslip', 'desc': 'Generate and download salary PDF slip'},
        ]),
      ),

      // 8. Assets Management
      ModulePermissionGroup(
        moduleId: 'assets',
        moduleName: 'Assets Management',
        iconKey: 'monitor',
        permissions: buildItems([
          {'key': PermissionKeys.assetsView, 'label': 'View Assets', 'desc': 'View company hardware & software assets'},
          {'key': PermissionKeys.assetsAdd, 'label': 'Add New Asset', 'desc': 'Register new asset with serial number'},
          {'key': PermissionKeys.assetsEdit, 'label': 'Edit Asset Details', 'desc': 'Update asset status and condition'},
          {'key': PermissionKeys.assetsAssign, 'label': 'Assign Asset to Staff', 'desc': 'Handover asset to employee'},
          {'key': PermissionKeys.assetsReturn, 'label': 'Accept Asset Return', 'desc': 'Return asset to company inventory'},
        ]),
      ),

      // 9. Clients & Leads (CRM)
      ModulePermissionGroup(
        moduleId: 'leads',
        moduleName: 'Clients & Leads (CRM)',
        iconKey: 'people',
        permissions: buildItems([
          {'key': PermissionKeys.leadsView, 'label': 'View Leads', 'desc': 'Access lead pipeline and contacts'},
          {'key': PermissionKeys.leadsCreate, 'label': 'Add Lead', 'desc': 'Capture new sales prospect'},
          {'key': PermissionKeys.leadsEdit, 'label': 'Edit Lead', 'desc': 'Update lead details and budget'},
          {'key': PermissionKeys.leadsDelete, 'label': 'Delete Lead', 'desc': 'Remove invalid lead'},
          {'key': PermissionKeys.leadsAssignTeam, 'label': 'Assign Sales Team', 'desc': 'Route lead to sales executive'},
          {'key': PermissionKeys.leadsUpdateStatus, 'label': 'Update Lead Status', 'desc': 'Move lead across sales pipeline stages'},
          {'key': PermissionKeys.clientsView, 'label': 'View Clients', 'desc': 'Access client directory'},
          {'key': PermissionKeys.clientsCreate, 'label': 'Create Client', 'desc': 'Onboard new client profile'},
          {'key': PermissionKeys.clientsEdit, 'label': 'Edit Client', 'desc': 'Update client contact and agreements'},
        ]),
      ),

      // 10. Meetings & Follow-ups
      ModulePermissionGroup(
        moduleId: 'meetings',
        moduleName: 'Meetings & Follow-ups',
        iconKey: 'clock',
        permissions: buildItems([
          {'key': PermissionKeys.meetingsView, 'label': 'View Meetings', 'desc': 'See scheduled meetings & calls'},
          {'key': PermissionKeys.meetingsCreate, 'label': 'Schedule Meeting', 'desc': 'Set up client or internal meeting'},
          {'key': PermissionKeys.meetingsEdit, 'label': 'Edit / Reschedule Meeting', 'desc': 'Change meeting time & agenda'},
          {'key': PermissionKeys.meetingsNotes, 'label': 'Add Meeting Notes', 'desc': 'Save discussion notes and action items'},
        ]),
      ),

      // 11. Documents & Folders
      ModulePermissionGroup(
        moduleId: 'documents',
        moduleName: 'Documents & Folders',
        iconKey: 'folder',
        permissions: buildItems([
          {'key': PermissionKeys.documentsView, 'label': 'Browse Document Folders', 'desc': 'Access shared company folders'},
          {'key': PermissionKeys.documentsUpload, 'label': 'Upload Documents', 'desc': 'Upload templates, certificates, files'},
          {'key': PermissionKeys.documentsDelete, 'label': 'Delete Documents', 'desc': 'Remove uploaded company files'},
          {'key': PermissionKeys.documentsAccessControl, 'label': 'Manage Access Control', 'desc': 'Set folder permissions and restrictions'},
        ]),
      ),

      // 12. Company Profile & Policies
      ModulePermissionGroup(
        moduleId: 'company',
        moduleName: 'Company Profile & Policies',
        iconKey: 'buildings',
        permissions: buildItems([
          {'key': PermissionKeys.companyProfileView, 'label': 'View Company Profile', 'desc': 'View corporate organization details'},
          {'key': PermissionKeys.companyProfileEdit, 'label': 'Edit Company Profile', 'desc': 'Modify address, logo, and contacts'},
          {'key': PermissionKeys.compliancePolicyView, 'label': 'Read Compliance Policies', 'desc': 'Access employee handbook and policy docs'},
          {'key': PermissionKeys.compliancePolicyUpload, 'label': 'Upload Compliance Policies', 'desc': 'Add new organization policy documents'},
        ]),
      ),

      // 13. Roles & Permissions (RBAC)
      ModulePermissionGroup(
        moduleId: 'roles',
        moduleName: 'Roles & Permissions (RBAC)',
        iconKey: 'shield_security',
        permissions: buildItems([
          {'key': PermissionKeys.rolesView, 'label': 'View Roles List', 'desc': 'Browse all created roles and matrix'},
          {'key': PermissionKeys.rolesCreate, 'label': 'Create New Role', 'desc': 'Define custom role with department/designation'},
          {'key': PermissionKeys.rolesEdit, 'label': 'Edit Role & Permissions', 'desc': 'Configure granular permissions per role'},
          {'key': PermissionKeys.rolesDelete, 'label': 'Delete Role', 'desc': 'Remove obsolete role from system'},
        ]),
      ),
    ];
  }

  void _initializeDummyRoles() {
    roles.addAll([
      Role(
        id: '1',
        name: 'Super Admin',
        description: 'Complete administrative access across all modules and submodules',
        departmentName: 'Management',
        designationName: 'Admin',
        isActive: true,
        permissionGroups: generateDefaultPermissionCatalog(allGranted: true),
      ),
      Role(
        id: '2',
        name: 'HR Manager',
        description: 'Manage HR, employee onboardings, leaves, and attendance',
        departmentName: 'Human Resources',
        designationName: 'HR Manager',
        isActive: true,
        permissionGroups: generateDefaultPermissionCatalog(
          grantedKeys: {
            PermissionKeys.profileView,
            PermissionKeys.profileEdit,
            PermissionKeys.profileDocumentView,
            PermissionKeys.profileDocumentUpload,
            PermissionKeys.profileDocumentZoom,
            PermissionKeys.attendanceView,
            PermissionKeys.attendanceTeamView,
            PermissionKeys.attendanceRegularizeApprove,
            PermissionKeys.attendanceExport,
            PermissionKeys.leaveView,
            PermissionKeys.leaveApproveReject,
            PermissionKeys.leaveAllEmployeeRequests,
            PermissionKeys.leaveBalanceView,
            PermissionKeys.leavePolicyView,
            PermissionKeys.employeeView,
            PermissionKeys.employeeAdd,
            PermissionKeys.employeeEdit,
            PermissionKeys.employeeViewDocuments,
            PermissionKeys.employeeStatusChange,
            PermissionKeys.departmentView,
            PermissionKeys.designationView,
            PermissionKeys.compliancePolicyView,
            PermissionKeys.compliancePolicyUpload,
          },
        ),
      ),
      Role(
        id: '3',
        name: 'Project Manager',
        description: 'Manage development projects, assign tasks, and review daily updates',
        departmentName: 'Engineering',
        designationName: 'Project Manager',
        isActive: true,
        permissionGroups: generateDefaultPermissionCatalog(
          grantedKeys: {
            PermissionKeys.profileView,
            PermissionKeys.profileEdit,
            PermissionKeys.profileDocumentView,
            PermissionKeys.profileDocumentZoom,
            PermissionKeys.attendanceView,
            PermissionKeys.attendanceCheckInOut,
            PermissionKeys.attendanceHistoryView,
            PermissionKeys.attendanceTeamView,
            PermissionKeys.attendanceRegularizeRequest,
            PermissionKeys.leaveView,
            PermissionKeys.leaveApply,
            PermissionKeys.leaveBalanceView,
            PermissionKeys.tasksView,
            PermissionKeys.tasksCreate,
            PermissionKeys.tasksEdit,
            PermissionKeys.tasksAssign,
            PermissionKeys.tasksDailyUpdate,
            PermissionKeys.projectsView,
            PermissionKeys.projectsCreate,
            PermissionKeys.projectsEdit,
            PermissionKeys.meetingsView,
            PermissionKeys.meetingsCreate,
            PermissionKeys.meetingsNotes,
          },
        ),
      ),
      Role(
        id: '4',
        name: 'Software Engineer',
        description: 'Standard technical employee with daily task and attendance access',
        departmentName: 'Engineering',
        designationName: 'Senior Flutter Developer',
        isActive: true,
        permissionGroups: generateDefaultPermissionCatalog(
          grantedKeys: {
            PermissionKeys.profileView,
            PermissionKeys.profileEdit,
            PermissionKeys.profileChangeAvatar,
            PermissionKeys.profileViewAddress,
            PermissionKeys.profileDocumentView,
            PermissionKeys.profileDocumentUpload,
            PermissionKeys.profileDocumentZoom,
            PermissionKeys.attendanceView,
            PermissionKeys.attendanceCheckInOut,
            PermissionKeys.attendanceHistoryView,
            PermissionKeys.attendanceRegularizeRequest,
            PermissionKeys.leaveView,
            PermissionKeys.leaveApply,
            PermissionKeys.leaveBalanceView,
            PermissionKeys.tasksView,
            PermissionKeys.tasksDailyUpdate,
            PermissionKeys.projectsView,
            PermissionKeys.payrollViewMy,
            PermissionKeys.payrollDownloadPayslip,
            PermissionKeys.assetsView,
            PermissionKeys.compliancePolicyView,
          },
        ),
      ),
    ]);
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
    tempPermissionGroups.assignAll(generateDefaultPermissionCatalog());
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
        CustomSnackbar.showError(response.message ?? 'Failed to create role');
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
        CustomSnackbar.showError(response.message ?? 'Failed to update role');
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
        CustomSnackbar.showError(response.message ?? 'Failed to delete role');
      }
    } catch (e) {
      Logger.e('RolePermissionsController => Failed to delete role: $e');
      CustomSnackbar.showError('An error occurred while deleting the role');
    }
  }
}
