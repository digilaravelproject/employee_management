import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:attendence_tracking_app/core/services/storage/shared_prefs.dart';
import 'package:attendence_tracking_app/core/services/permission/permission_service.dart';
import 'package:attendence_tracking_app/core/services/permission/permission_constant.dart';
import 'package:attendence_tracking_app/features/auth/domain/models/user_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // The sample API response provided by the user in prompt
  final sampleApiResponse = {
    "status": true,
    "message": "Permissions retrieved successfully.",
    "role": {
      "id": 8,
      "name": "Senior Backend Developer",
      "description": "Leads Flutter application development",
      "department": "Engineering",
      "status": true
    },
    "total_permissions1": 83,
    "total_categories": 13,
    "assigned_permissions_count": 2,
    "modules": [
      {
        "module": "Profile & Documents",
        "module_slug": "profile_documents",
        "permissions": [
          {
            "id": 33,
            "name": "View Profile Details",
            "slug": "view_profile_details",
            "description": "View Profile Details",
            "is_assigned": true,
            "status": "allowed"
          },
          {
            "id": 34,
            "name": "Edit Profile Info",
            "slug": "edit_profile_info",
            "description": "Edit Profile Info",
            "is_assigned": true,
            "status": "allowed"
          },
          {
            "id": 35,
            "name": "Change Avatar",
            "slug": "change_avatar",
            "description": "Change Avatar",
            "is_assigned": false,
            "status": "not_allowed"
          }
        ],
        "actions": {
          "view_profile_details": {
            "id": 33,
            "name": "View Profile Details",
            "status": "allowed",
            "allowed": true
          },
          "edit_profile_info": {
            "id": 34,
            "name": "Edit Profile Info",
            "status": "allowed",
            "allowed": true
          },
          "change_avatar": {
            "id": 35,
            "name": "Change Avatar",
            "status": "not_allowed",
            "allowed": false
          }
        },
        "total_permissions3": 3,
        "assigned_permissions_count": 2,
        "all_assigned": false
      },
      {
        "module": "Attendance & Regularization",
        "module_slug": "attendance_regularization",
        "permissions": [
          {
            "id": 43,
            "name": "View Attendance Screen",
            "slug": "view_attendance_screen",
            "description": "View Attendance Screen",
            "is_assigned": false,
            "status": "not_allowed"
          },
          {
            "id": 44,
            "name": "Check-In / Check-Out",
            "slug": "check_in_check_out",
            "description": "Check-In / Check-Out",
            "is_assigned": false,
            "status": "not_allowed"
          }
        ],
        "actions": {
          "view_attendance_screen": {
            "id": 43,
            "name": "View Attendance Screen",
            "status": "not_allowed",
            "allowed": false
          },
          "check_in_check_out": {
            "id": 44,
            "name": "Check-In / Check-Out",
            "status": "not_allowed",
            "allowed": false
          }
        },
        "total_permissions3": 2,
        "assigned_permissions_count": 0,
        "all_assigned": false
      },
      {
        "module": "Tasks & Projects",
        "module_slug": "tasks_projects",
        "permissions": [
          {
            "id": 64,
            "name": "View Tasks",
            "slug": "view_tasks",
            "description": "View Tasks",
            "is_assigned": false,
            "status": "not_allowed"
          },
          {
            "id": 65,
            "name": "Create Task",
            "slug": "create_task",
            "description": "Create Task",
            "is_assigned": false,
            "status": "not_allowed"
          },
          {
            "id": 71,
            "name": "Create Project",
            "slug": "create_project",
            "description": "Create Project",
            "is_assigned": false,
            "status": "not_allowed"
          }
        ],
        "actions": {
          "view_tasks": {
            "id": 64,
            "name": "View Tasks",
            "status": "not_allowed",
            "allowed": false
          },
          "create_task": {
            "id": 65,
            "name": "Create Task",
            "status": "not_allowed",
            "allowed": false
          },
          "create_project": {
            "id": 71,
            "name": "Create Project",
            "status": "not_allowed",
            "allowed": false
          }
        },
        "total_permissions3": 3,
        "assigned_permissions_count": 0,
        "all_assigned": false
      }
    ]
  };

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SharedPrefs.init();
  });

  group('UserModel primaryRoleId extraction tests', () {
    test('Extracts role_id from role_ids array', () {
      final user = UserModel.fromJson({
        'id': 17,
        'name': 'Rahul Sharma',
        'role': 'employee',
        'role_ids': [8, 9],
      });

      expect(user.primaryRoleId, 8);
    });

    test('Extracts role_id from roles objects array', () {
      final user = UserModel.fromJson({
        'id': 17,
        'name': 'Rahul Sharma',
        'role': 'employee',
        'roles': [
          {'id': 8, 'name': 'Senior Backend Developer'}
        ],
      });

      expect(user.primaryRoleId, 8);
    });

    test('Extracts role_id directly from raw json role_id key', () {
      final user = UserModel.fromJson({
        'id': 17,
        'name': 'Rahul Sharma',
        'role': 'employee',
        'role_id': 8,
      });

      expect(user.primaryRoleId, 8);
    });

    test('Returns null if user is admin and has no role_id', () {
      final user = UserModel.fromJson({
        'id': 1,
        'name': 'Super Admin',
        'role': 'admin',
      });

      expect(user.primaryRoleId, isNull);
    });
  });

  group('SharedPrefs role_id management tests', () {
    test('saveUserData stores role_id when user has primaryRoleId', () async {
      final user = UserModel.fromJson({
        'id': 17,
        'name': 'Rahul Sharma',
        'role': 'employee',
        'role_ids': [8],
      });

      await SharedPrefs.saveUserData(user);
      expect(SharedPrefs.getRoleId(), 8);
      expect(SharedPrefs.hasRoleId(), isTrue);
    });

    test('saveUserData removes role_id when user is admin (no role_id)', () async {
      await SharedPrefs.setRoleId(8);
      expect(SharedPrefs.getRoleId(), 8);

      final adminUser = UserModel.fromJson({
        'id': 1,
        'name': 'Administrator',
        'role': 'admin',
      });

      await SharedPrefs.saveUserData(adminUser);
      expect(SharedPrefs.getRoleId(), isNull);
      expect(SharedPrefs.hasRoleId(), isFalse);
    });

    test('clearUserData removes role_id and permissions cache', () async {
      await SharedPrefs.setRoleId(8);
      await SharedPrefs.setString('permissions_cache', '{"some":"data"}');

      await SharedPrefs.clearUserData();
      expect(SharedPrefs.getRoleId(), isNull);
      expect(SharedPrefs.getString('permissions_cache'), isNull);
    });
  });

  group('PermissionService Admin vs Employee tests', () {
    test('Admin mode: all actions and modules are allowed by default', () {
      final service = PermissionService();
      service.setAdminMode(true);

      expect(service.isAdmin.value, isTrue);
      expect(service.isAllowed(PermissionConstant.createProject), isTrue);
      expect(service.isAllowed(PermissionConstant.createTask), isTrue);
      expect(service.isAllowed('any_random_action'), isTrue);
      expect(service.isModuleAllowed(PermissionConstant.moduleTasksProjects), isTrue);
    });

    test('Employee mode: role 8 permissions are parsed and enforced', () {
      final service = PermissionService();
      service.setAdminMode(false);

      // Simulating parsed response
      final modulesList = sampleApiResponse['modules'] as List;
      // Call internal parser by populating permissions cache or via mock
      final jsonStr = jsonEncode(modulesList);
      SharedPrefs.setString('permissions_cache', jsonStr);
      service.loadCachedPermissions();

      expect(service.isAdmin.value, isFalse);

      // 1. Allowed permissions
      expect(service.isAllowed(PermissionConstant.viewProfileDetails), isTrue);
      expect(service.isAllowed(PermissionConstant.editProfileInfo), isTrue);
      expect(service.isModuleAllowed(PermissionConstant.moduleProfileDocuments), isTrue);

      // 2. Disallowed permissions (like user asked: project create allowed tbhi dikhega nhi to nhi)
      expect(service.isAllowed(PermissionConstant.changeAvatar), isFalse);
      expect(service.isAllowed(PermissionConstant.createProject), isFalse);
      expect(service.isAllowed(PermissionConstant.createTask), isFalse);
      expect(service.isAllowed(PermissionConstant.viewTasks), isFalse);
      expect(service.isAllowed(PermissionConstant.checkInCheckOut), isFalse);
      expect(service.isModuleAllowed(PermissionConstant.moduleAttendanceRegularization), isFalse);
    });
  });
}
