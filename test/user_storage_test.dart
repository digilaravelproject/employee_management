import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dgm360/core/services/storage/shared_prefs.dart';
import 'package:dgm360/features/auth/domain/models/user_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const sampleJsonStr = '''{
    "status": true,
    "message": "Login successful.",
    "data": {
        "id": 17,
        "name": "Rahul Sharma",
        "company_name": null,
        "owner_name": null,
        "mobile_number": "9876543219",
        "alternate_mobile_number": "9876500019",
        "emergency_contact": "9876500000",
        "phone": "9876543219",
        "department": "Engineering",
        "department_id": null,
        "work_mode": "Office",
        "employee_type": "Full-time",
        "team": "Team Alpha",
        "assigned_shift_id": 2,
        "reporting_manager_id": null,
        "designation": "Lead Flutter Developer",
        "designation_id": 2,
        "employee_id": "EMP-2026-015",
        "gender": "Male",
        "date_of_birth": "1996-05-15",
        "marital_status": "Single",
        "blood_group": "O+",
        "date_of_joining": "2026-09-17",
        "monthly_salary": "60000.00",
        "salary_type": "Monthly",
        "sales_target_enabled": true,
        "sales_target": "500000.00",
        "account_holder_name": "Rahul Sharma",
        "bank_name": "HDFC Bank",
        "account_number": "50100456789123",
        "ifsc_code": "HDFC0001234",
        "branch_name": "Main Branch",
        "skills": [
            "Flutter",
            "Dart",
            "Teamwork"
        ],
        "address": "Flat 402, Sunshine Heights, Bengaluru, Karnataka, 560038, India",
        "street_address": "Flat 402, Sunshine Heights",
        "city": "Bengaluru",
        "postal_code": "560038",
        "state": "Karnataka",
        "country": "India",
        "avatar": "http://127.0.0.1:8000/storage/employee-avatars/FvORdd8RtwnPPv4rfhUQPxIsNyKn53VJwgxIBmPV.jpg",
        "status": "Active",
        "employment_status": "Active",
        "probation_period": "3 Months",
        "notice_period": "30 Days",
        "role": "employee",
        "email": "darshankondekar01+12@gmail.com",
        "email_verified_at": null,
        "created_at": "2026-09-24T00:35:00.000000Z",
        "updated_at": "2026-09-24T00:35:00.000000Z",
        "sales_target_metric_type": "Revenue",
        "sales_target_period": "Monthly",
        "incentive_commission_percent": "5.00",
        "designation_details": {
            "id": 2,
            "name": "Lead Flutter Developer",
            "hierarchy_level": "manager",
            "skills": "[\\"Flutter\\",\\"Dart\\",\\"Firebase\\",\\"Team Leadership\\"]",
            "created_at": "2026-09-16T20:38:11.000000Z",
            "updated_at": "2026-09-16T20:39:58.000000Z"
        },
        "department_details": null,
        "assigned_shift": {
            "id": 2,
            "name": "Morning Shift",
            "code": "MORNING",
            "shift_type": "Fixed Shift",
            "start_time": "10:00",
            "end_time": "19:00",
            "cross_midnight": 0,
            "breaks_enabled": 1,
            "breaks": "[{\\"name\\":\\"Lunch Break\\",\\"type\\":\\"Paid\\",\\"start_time\\":\\"13:00\\",\\"end_time\\":\\"14:00\\",\\"duration_minutes\\":60}]",
            "break_duration": "01:00",
            "total_duration": "8h 00m",
            "grace_time_late": "00:15",
            "grace_period_minutes": 15,
            "late_after_minutes": 15,
            "minimum_working_minutes": 480,
            "early_leaving_allowed": 0,
            "auto_mark_late": 1,
            "auto_mark_half_day": 1,
            "late_threshold_minutes": 45,
            "half_day_after_minutes": 240,
            "overtime_after": "08:00",
            "overtime_enabled": 1,
            "overtime_starts_after_minutes": 480,
            "minimum_overtime_minutes": 30,
            "overtime_calculation": "Hourly",
            "overtime_approval_required": 1,
            "working_days": "[{\\"day\\":\\"Monday\\",\\"enabled\\":true,\\"start_time\\":\\"10:00\\",\\"end_time\\":\\"19:00\\"},{\\"day\\":\\"Tuesday\\",\\"enabled\\":true,\\"start_time\\":\\"10:00\\",\\"end_time\\":\\"19:00\\"},{\\"day\\":\\"Wednesday\\",\\"enabled\\":true,\\"start_time\\":\\"10:00\\",\\"end_time\\":\\"19:00\\"},{\\"day\\":\\"Thursday\\",\\"enabled\\":true,\\"start_time\\":\\"10:00\\",\\"end_time\\":\\"19:00\\"},{\\"day\\":\\"Friday\\",\\"enabled\\":true,\\"start_time\\":\\"10:00\\",\\"end_time\\":\\"19:00\\"},{\\"day\\":\\"Saturday\\",\\"enabled\\":false,\\"start_time\\":\\"10:00\\",\\"end_time\\":\\"19:00\\"},{\\"day\\":\\"Sunday\\",\\"enabled\\":false,\\"start_time\\":\\"10:00\\",\\"end_time\\":\\"19:00\\"}]",
            "description": "Morning working shift for sales and operations team.",
            "status": "Active",
            "created_at": "2026-09-16T20:42:14.000000Z",
            "updated_at": "2026-09-16T20:44:46.000000Z"
        },
        "roles": [
            {
                "id": 10,
                "name": "Manager L1",
                "department": "Information Technology",
                "description": "Builds and maintains mobile applications",
                "status": true
            }
        ],
        "role_ids": [
            10
        ],
        "documents": []
    },
    "access_token": "38|BvqZd46ooUyKkrnSb6j9nNvr3cztRqEBJ1Xw7BO69e4c83bf",
    "token_type": "Bearer"
}''';

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SharedPrefs.init();
  });

  test('UserModel parses all API fields correctly and saves to SharedPrefs', () async {
    final Map<String, dynamic> rootMap = jsonDecode(sampleJsonStr);
    final Map<String, dynamic> dataMap = rootMap['data'];

    final user = UserModel.fromJson(dataMap);

    // Verify basic fields
    expect(user.id, 17);
    expect(user.name, 'Rahul Sharma');
    expect(user.department, 'Engineering');
    expect(user.designation, 'Lead Flutter Developer');
    expect(user.employeeId, 'EMP-2026-015');
    expect(user.workMode, 'Office');
    expect(user.employeeType, 'Full-time');
    expect(user.team, 'Team Alpha');
    expect(user.salesTargetEnabled, true);
    expect(user.isSalesTargetEnabled, true);
    expect(user.salesTarget, '500000.00');
    expect(user.salesTargetMetricType, 'Revenue');
    expect(user.salesTargetPeriod, 'Monthly');
    expect(user.incentiveCommissionPercent, '5.00');

    // Verify skills
    expect(user.skillsList, ['Flutter', 'Dart', 'Teamwork']);
    expect(user.skills, 'Flutter, Dart, Teamwork');

    // Verify designation details
    expect(user.designationDetails, isNotNull);
    expect(user.designationDetails!.name, 'Lead Flutter Developer');
    expect(user.designationDetails!.hierarchyLevel, 'manager');
    expect(user.designationDetails!.skills, ['Flutter', 'Dart', 'Firebase', 'Team Leadership']);

    // Verify assigned shift
    expect(user.assignedShift, isNotNull);
    expect(user.assignedShift!.name, 'Morning Shift');
    expect(user.assignedShift!.code, 'MORNING');
    expect(user.assignedShift!.shiftType, 'Fixed Shift');
    expect(user.assignedShift!.startTime, '10:00');
    expect(user.assignedShift!.endTime, '19:00');
    expect(user.assignedShift!.breakDuration, '01:00');
    expect(user.assignedShift!.totalDuration, '8h 00m');
    expect(user.assignedShift!.breaks, isNotNull);
    expect(user.assignedShift!.breaks!.first.name, 'Lunch Break');
    expect(user.assignedShift!.workingDays, isNotNull);
    expect(user.assignedShift!.workingDays!.length, 7);

    // Verify roles
    expect(user.roles, isNotNull);
    expect(user.roles!.length, 1);
    expect(user.roles!.first.name, 'Manager L1');
    expect(user.roles!.first.department, 'Information Technology');
    expect(user.roleIds, [10]);

    // Save to SharedPreferences
    final saveResult = await SharedPrefs.saveUserData(user);
    expect(saveResult, true);

    // Retrieve from SharedPreferences
    final retrievedUser = SharedPrefs.getUserData();
    expect(retrievedUser, isNotNull);
    expect(retrievedUser!.id, 17);
    expect(retrievedUser.name, 'Rahul Sharma');
    expect(retrievedUser.skillsList, ['Flutter', 'Dart', 'Teamwork']);
    expect(retrievedUser.isSalesTargetEnabled, true);
    expect(retrievedUser.salesTarget, '500000.00');
    expect(retrievedUser.assignedShift, isNotNull);
    expect(retrievedUser.assignedShift!.name, 'Morning Shift');
    expect(retrievedUser.roles!.first.name, 'Manager L1');
    expect(retrievedUser.roleIds, [10]);

    // Verify raw map in SharedPreferences
    final rawMap = SharedPrefs.getUserDataMap();
    expect(rawMap, isNotNull);
    expect(rawMap!['id'], 17);
    expect(rawMap['assigned_shift']['name'], 'Morning Shift');
    expect(rawMap['roles'][0]['name'], 'Manager L1');
  });
}
