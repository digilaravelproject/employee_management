import 'package:flutter_test/flutter_test.dart';
import 'package:attendence_tracking_app/features/attendance/models/admin_attendance_model.dart';

void main() {
  group('AdminAttendanceModel Tests', () {
    test('Parses nested employees list correctly', () {
      final json = {
        'status': true,
        'message': 'Employee attendance retrieved successfully.',
        'data': {
          'date': '2026-10-06',
          'summary': {
            'total_employees': 2,
            'present': 1,
            'absent': 1,
            'on_leave': 0,
            'present_percentage': 50,
            'absent_percentage': 50,
          },
          'employees': [
            {
              'attendance_id': 101,
              'status': 'Present',
              'check_in': '09:30 AM',
              'check_out': '06:30 PM',
              'employee': {
                'id': 1,
                'employee_id': 'EMP001',
                'name': 'Rahul Sharma',
              }
            },
            {
              'attendance_id': 102,
              'status': 'Absent',
              'employee': {
                'id': 2,
                'employee_id': 'EMP002',
                'name': 'Pooja Verma',
              }
            }
          ]
        }
      };

      final response = AdminAttendanceResponseModel.fromJson(json);
      expect(response.status, true);
      expect(response.data, isNotNull);
      expect(response.data!.employees.length, 2);
      expect(response.data!.employees[0].employee?.name, 'Rahul Sharma');
      expect(response.data!.employees[0].status, 'Present');
      expect(response.data!.employees[1].status, 'Absent');
    });

    test('Parses paginated employees map correctly', () {
      final json = {
        'status': true,
        'message': 'Success',
        'data': {
          'date': '2026-10-06',
          'summary': {
            'total_employees': 1,
            'present': 1,
            'absent': 0,
            'on_leave': 0,
          },
          'employees': {
            'current_page': 1,
            'total': 1,
            'data': [
              {
                'id': 1,
                'name': 'Vikram Singh',
                'employee_id': 'EMP003',
                'status': 'Present',
                'check_in': '09:15 AM'
              }
            ]
          }
        }
      };

      final response = AdminAttendanceResponseModel.fromJson(json);
      expect(response.status, true);
      expect(response.data!.employees.length, 1);
      expect(response.data!.employees[0].employee?.name, 'Vikram Singh');
      expect(response.data!.employees[0].employee?.employeeId, 'EMP003');
    });

    test('Parses flat employee structure and infers status from check-in', () {
      final json = {
        'status': true,
        'message': 'Success',
        'data': {
          'date': '2026-10-06',
          'employees': [
            {
              'id': 5,
              'first_name': 'Amit',
              'last_name': 'Kumar',
              'check_in': '10:05 AM',
              'status': '', // Empty status should infer Present from check_in
            }
          ]
        }
      };

      final response = AdminAttendanceResponseModel.fromJson(json);
      expect(response.data!.employees.length, 1);
      final item = response.data!.employees[0];
      expect(item.employee?.name, 'Amit Kumar');
      expect(item.status, 'Present');
    });
  });
}
