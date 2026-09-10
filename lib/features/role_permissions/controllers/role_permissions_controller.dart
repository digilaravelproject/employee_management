import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/permission_keys.dart';
import '../models/role_permission_models.dart';

class RolePermissionsController extends GetxController {
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

  @override
  void onInit() {
    super.onInit();
    _initializeDummyRoles();
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
      departmentName: selectedDepartmentName.value ?? 'General',
      designationName: selectedDesignationName.value ?? 'Staff',
      isActive: isActive.value,
      permissionGroups: List<ModulePermissionGroup>.from(tempPermissionGroups),
    );

    roles.add(newRole);
    clearForm();
    Get.back();
    Get.snackbar(
      'Role Created',
      'New role "${newRole.name}" created with ${newRole.totalPermissionsCount} permissions granted.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  // Update existing role
  void updateRole(String id) {
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

    final index = roles.indexWhere((r) => r.id == id);
    if (index != -1) {
      final updatedRole = roles[index].copyWith(
        name: nameController.text.trim(),
        description: descriptionController.text.trim(),
        departmentName: selectedDepartmentName.value,
        designationName: selectedDesignationName.value,
        isActive: isActive.value,
        permissionGroups: List<ModulePermissionGroup>.from(tempPermissionGroups),
      );

      roles[index] = updatedRole;
      if (selectedRole.value?.id == id) {
        selectedRole.value = updatedRole;
      }
      roles.refresh();

      Get.back();
      Get.snackbar(
        'Role Updated',
        'Role "${updatedRole.name}" updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }

  // Delete role
  void deleteRole(String id) {
    roles.removeWhere((r) => r.id == id);
    if (selectedRole.value?.id == id) {
      selectedRole.value = null;
    }
    Get.back(); // close dialog or details
    Get.snackbar(
      'Role Deleted',
      'The role has been permanently removed',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
    );
  }
}
