# Permission Service Guide & Source Code

Yeh document `PermissionService` ke methods ko use karne ka tareeka aur teeno core files (`permission_constant.dart`, `permission_model.dart`, aur `permission_service.dart`) ka pura source code contain karta hai.

---

## 🚀 KAISE USE KARNA HAI (Usage Guide)

### 1. `hasPermission()`
Ye strictly check karta hai ki permission allowed hai ya nahi (`is_assigned == true` **AND** `status == 'allowed'`).

```dart
// 1. Sirf Module Check:
bool isModuleAllowed = PermissionService.to.hasPermission(moduleSlug: 'leave_management');

// 2. Sirf Permission Check (kisi bhi module me):
bool isPermAllowed = PermissionService.to.hasPermission(permissionSlug: 'apply_for_leave');

// 3. Dono ek sath (Specific module ke andar specific permission):
bool isStrictlyAllowed = PermissionService.to.hasPermission(
  moduleSlug: 'leave_management',
  permissionSlug: 'apply_for_leave',
);
```

### 2. `hasSlug()`
Ye sirf check karta hai ki slug backend response me maujood (exist) hai ya nahi, `status` nahi dekhta.

```dart
bool moduleExists = PermissionService.to.hasSlug(moduleSlug: 'leave_management');
bool exactExists = PermissionService.to.hasSlug(
  moduleSlug: 'leave_management', 
  permissionSlug: 'apply_for_leave'
);
```

### 3. `hasModule()`
Ye check karta hai ki module list mein hai ya nahi.
```dart
bool isModulePresent = PermissionService.to.hasModule('profile_documents');
```

### 4. `getModuleModel()` & `getPermissionModel()`
Agar aapko raw object/data chahiye.
```dart
final module = PermissionService.to.getModuleModel('leave_management');
if (module != null) print(module.totalPermissions);

final perm = PermissionService.to.getPermissionModel('apply_for_leave');
if (perm != null) print(perm.isAssigned);
```

---

## 📄 FULL SOURCE CODE BACKUP

### 1. `permission_constant.dart`
```dart
class PermissionConstant {
  // ── Module Slugs ──
  static const String moduleProfileDocuments = 'profile_documents';
  static const String moduleAttendanceRegularization = 'attendance_regularization';
  static const String moduleLeaveManagement = 'leave_management';
  static const String moduleEmployeeManagement = 'employee_management';
  static const String moduleTasksProjects = 'tasks_projects';
  static const String moduleDepartmentsDesignations = 'departments_designations';
  static const String modulePayrollSalary = 'payroll_salary';
  static const String moduleAssetsManagement = 'assets_management';
  static const String moduleClientsLeadsCrm = 'clients_leads_crm';
  static const String moduleMeetingsFollowUps = 'meetings_follow_ups';
  static const String moduleDocumentsFolders = 'documents_folders';
  static const String moduleCompanyProfilePolicies = 'company_profile_policies';
  static const String moduleRolesPermissionsRbac = 'roles_permissions_rbac';

  // ── 1. Profile & Documents ──
  static const String viewProfileDetails = 'view_profile_details';
  static const String editProfileInfo = 'edit_profile_info';
  static const String changeAvatar = 'change_avatar';
  static const String viewAddress = 'view_address';
  static const String viewBankDetails = 'view_bank_details';
  static const String editBankDetails = 'edit_bank_details';
  static const String viewDocuments = 'view_documents';
  static const String uploadDocuments = 'upload_documents';
  static const String zoomPreviewDocument = 'zoom_preview_document';
  static const String deleteDocuments = 'delete_documents';

  // ── 2. Attendance & Regularization ──
  static const String viewAttendanceScreen = 'view_attendance_screen';
  static const String checkInCheckOut = 'check_in_check_out';
  static const String viewAttendanceHistory = 'view_attendance_history';
  static const String requestRegularization = 'request_regularization';
  static const String approveRegularization = 'approve_regularization';
  static const String viewTeamAttendance = 'view_team_attendance';
  static const String exportAttendance = 'export_attendance';

  // ── 3. Leave Management ──
  static const String viewLeaveDashboard = 'view_leave_dashboard';
  static const String applyForLeave = 'apply_for_leave';
  static const String cancelLeave = 'cancel_leave';
  static const String viewLeaveBalance = 'view_leave_balance';
  static const String approveRejectLeave = 'approve_reject_leave';
  static const String allEmployeesRequests = 'all_employees_requests';
  static const String viewLeavePolicy = 'view_leave_policy';

  // ── 4. Employee Management ──
  static const String viewEmployeeDirectory = 'view_employee_directory';
  static const String addNewEmployee = 'add_new_employee';
  static const String editEmployeeDetails = 'edit_employee_details';
  static const String deleteEmployee = 'delete_employee';
  static const String viewSalaryStructure = 'view_salary_structure';
  static const String editSalaryStructure = 'edit_salary_structure';
  static const String viewUploadedDocuments = 'view_uploaded_documents';

  // ── 5. Tasks & Projects ──
  static const String viewTasks = 'view_tasks';
  static const String createTask = 'create_task';
  static const String editTask = 'edit_task';
  static const String deleteTask = 'delete_task';
  static const String assignTask = 'assign_task';
  static const String dailyTaskUpdate = 'daily_task_update';
  static const String viewProjects = 'view_projects';
  static const String createProject = 'create_project';
  static const String editProject = 'edit_project';
  static const String deleteProject = 'delete_project';

  // ── 6. Departments & Designations ──
  static const String viewDepartments = 'view_departments';
  static const String addDepartment = 'add_department';
  static const String editDepartment = 'edit_department';
  static const String deleteDepartment = 'delete_department';
  static const String viewDesignations = 'view_designations';
  static const String addDesignation = 'add_designation';
  static const String editDesignation = 'edit_designation';
  static const String deleteDesignation = 'delete_designation';

  // ── 7. Payroll & Salary ──
  static const String viewMySalary = 'view_my_salary';
  static const String manageCompanyPayroll = 'manage_company_payroll';
  static const String processMonthlyPayroll = 'process_monthly_payroll';
  static const String downloadPayslip = 'download_payslip';

  // ── 8. Assets Management ──
  static const String viewAssets = 'view_assets';
  static const String addNewAsset = 'add_new_asset';
  static const String editAssetDetails = 'edit_asset_details';
  static const String assignAssetToStaff = 'assign_asset_to_staff';
  static const String acceptAssetReturn = 'accept_asset_return';

  // ── 9. Clients & Leads (CRM) ──
  static const String viewLeads = 'view_leads';
  static const String addLead = 'add_lead';
  static const String editLead = 'edit_lead';
  static const String deleteLead = 'delete_lead';
  static const String assignSalesTeam = 'assign_sales_team';
  static const String updateLeadStatus = 'update_lead_status';
  static const String viewClients = 'view_clients';
  static const String createClient = 'create_client';
  static const String editClient = 'edit_client';

  // ── 10. Meetings & Follow-ups ──
  static const String viewMeetings = 'view_meetings';
  static const String scheduleMeeting = 'schedule_meeting';
  static const String editRescheduleMeeting = 'edit_reschedule_meeting';
  static const String addMeetingNotes = 'add_meeting_notes';

  // ── 11. Documents & Folders ──
  static const String browseDocumentFolders = 'browse_document_folders';
  static const String uploadFolderDocuments = 'upload_documents';
  static const String deleteFolderDocuments = 'delete_documents';
  static const String manageAccessControl = 'manage_access_control';

  // ── 12. Company Profile & Policies ──
  static const String viewCompanyProfile = 'view_company_profile';
  static const String editCompanyProfile = 'edit_company_profile';
  static const String readCompliancePolicies = 'read_compliance_policies';
  static const String uploadCompliancePolicies = 'upload_compliance_policies';

  // ── 13. Roles & Permissions (RBAC) ──
  static const String viewRolesList = 'view_roles_list';
  static const String createNewRole = 'create_new_role';
  static const String editRolePermissions = 'edit_role_permissions';
  static const String deleteRole = 'delete_role';
}
```

### 2. `permission_model.dart`
```dart
class PermissionResponseModel {
  final bool status;
  final String message;
  final dynamic role;
  final int totalPermissions;
  final int totalCategories;
  final int assignedPermissionsCount;
  final List<PermissionModuleModel> modules;

  PermissionResponseModel({
    required this.status,
    required this.message,
    this.role,
    required this.totalPermissions,
    required this.totalCategories,
    required this.assignedPermissionsCount,
    required this.modules,
  });

  factory PermissionResponseModel.fromJson(Map<String, dynamic> json) {
    return PermissionResponseModel(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      role: json['role'],
      totalPermissions: json['total_permissions'] ?? 0,
      totalCategories: json['total_categories'] ?? 0,
      assignedPermissionsCount: json['assigned_permissions_count'] ?? 0,
      modules: (json['modules'] as List?)
              ?.map((e) => e is Map ? PermissionModuleModel.fromJson(Map<String, dynamic>.from(e)) : null)
              .whereType<PermissionModuleModel>()
              .toList() ??
          [],
    );
  }
}

class PermissionModuleModel {
  final String moduleName;
  final String moduleSlug;
  final bool allAssigned;
  final int assignedCount;
  final int totalPermissions;
  final List<PermissionItemModel> permissions;

  PermissionModuleModel({
    required this.moduleName,
    required this.moduleSlug,
    required this.allAssigned,
    required this.assignedCount,
    required this.totalPermissions,
    required this.permissions,
  });

  factory PermissionModuleModel.fromJson(Map<String, dynamic> json) {
    return PermissionModuleModel(
      moduleName: json['module']?.toString() ?? '',
      moduleSlug: json['module_slug']?.toString().toLowerCase().trim() ?? '',
      allAssigned: json['all_assigned'] == true,
      assignedCount: json['assigned_permissions_count'] ?? 0,
      totalPermissions: json['total_permissions'] ?? 0,
      permissions: (json['permissions'] as List?)
              ?.map((e) => PermissionItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class PermissionItemModel {
  final int id;
  final String name;
  final String slug;
  final String description;
  final bool isAssigned;
  final String status;

  PermissionItemModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.isAssigned,
    required this.status,
  });

  factory PermissionItemModel.fromJson(Map<String, dynamic> json) {
    return PermissionItemModel(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString().toLowerCase().trim() ?? '',
      description: json['description']?.toString() ?? '',
      isAssigned: json['is_assigned'] ?? false,
      status: json['status']?.toString() ?? '',
    );
  }
}
```

### 3. `permission_service.dart`
```dart
import 'package:get/get.dart';
import '../core/constants/app_constants.dart';
import '../core/services/network/api_client.dart';
import '../core/utils/logger.dart';
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

    final modulesModelList = moduleList
        .where((m) => m is Map)
        .map(
          (m) => PermissionModuleModel.fromJson(
            Map<String, dynamic>.from(m as Map),
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
```
