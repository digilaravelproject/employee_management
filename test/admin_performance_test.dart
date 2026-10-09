import 'package:flutter_test/flutter_test.dart';
import 'package:dgm360/features/performance/models/employee_performance_response_model.dart';
import 'package:dgm360/features/performance/repositories/performance_repository_interface.dart';
import 'package:dgm360/features/performance/controllers/performance_controller.dart';
import 'package:dgm360/features/attendance/models/attendance_history_response_model.dart';
import 'package:dgm360/features/performance/controllers/employee_performance_detail_controller.dart';

class MockPerformanceRepository implements PerformanceRepositoryInterface {
  final EmployeePerformanceResponseModel response;
  final EmployeePerformanceDetailResponseModel? detailResponse;
  MockPerformanceRepository(this.response, {this.detailResponse});

  @override
  Future<EmployeePerformanceResponseModel> getEmployeePerformance({
    required String month,
    String view = 'team',
    int page = 1,
    int perPage = 20,
  }) async {
    return response;
  }

  @override
  Future<EmployeePerformanceDetailResponseModel> getEmployeePerformanceDetail({
    required dynamic employeeId,
    required String month,
  }) async {
    return detailResponse ??
        EmployeePerformanceDetailResponseModel(
          status: true,
          message: 'Retrieved successfully',
          data: EmployeePerformanceDetailDataModel.fromJson({
            "employee": {
              "id": 17,
              "employee_id": "EMP-2026-017",
              "name": "Jane Smith",
              "email": "jane@example.com",
              "designation": "Backend Engineer",
              "department": "Engineering"
            },
            "period": {
              "month": month,
              "label": "October 2026"
            },
            "score": 85,
            "evaluation": "Very Good",
            "rank": 2,
            "source_counts": {
              "projects": 3,
              "tasks": 12,
              "quality_reviews": 4
            },
            "metrics": {
              "task_completion": {
                "percent": 90,
                "completed": 9,
                "total": 10
              }
            }
          }),
        );
  }
}

void main() {
  group('PerformanceModel & Repository Tests', () {
    final Map<String, dynamic> sampleJson = {
      "status": true,
      "message": "Employee performance retrieved successfully.",
      "summary": {
        "total_employees": 13,
        "rated_employees": 5,
        "average_performance": 0,
        "top_performer": {
          "employee": {
            "id": 13,
            "employee_id": "EMP-2026-011",
            "name": "Rahul Sharma",
            "email": "darshankondekar02@gmail.com",
            "avatar": "http://127.0.0.1:8000/storage/employee-avatars/0nkZTyqrbNPlTAt1NPcbVOV8tHBgGfd3OvT7Kazr.jpg",
            "designation": "Lead Flutter Developer",
            "department": "Engineering",
            "department_id": null,
            "team": "Team Alpha"
          },
          "score": 0
        }
      },
      "filters": {
        "period": {
          "from": "2026-10-01",
          "to": "2026-10-31",
          "month": "2026-10",
          "label": "October 2026"
        },
        "view": "team"
      },
      "pagination": {
        "current_page": 1,
        "per_page": 20,
        "total": 13,
        "last_page": 1
      },
      "data": [
        {
          "employee": {
            "id": 13,
            "employee_id": "EMP-2026-011",
            "name": "Rahul Sharma",
            "email": "darshankondekar02@gmail.com",
            "avatar": "http://127.0.0.1:8000/storage/employee-avatars/0nkZTyqrbNPlTAt1NPcbVOV8tHBgGfd3OvT7Kazr.jpg",
            "designation": "Lead Flutter Developer",
            "department": "Engineering",
            "department_id": null,
            "team": "Team Alpha"
          },
          "score": 0,
          "evaluation": "Needs Improvement",
          "rank": 1
        },
        {
          "employee": {
            "id": 3,
            "employee_id": "EMP1026",
            "name": "John Doe",
            "email": "john.doe@example.com",
            "avatar": null,
            "designation": "Senior Flutter Developer",
            "department": "Product Engineering",
            "department_id": 1,
            "team": null
          },
          "score": null,
          "evaluation": "Not Rated",
          "rank": 6
        }
      ]
    };

    test('Parses EmployeePerformanceResponseModel successfully', () {
      final res = EmployeePerformanceResponseModel.fromJson(sampleJson);
      expect(res.status, true);
      expect(res.message, 'Employee performance retrieved successfully.');
      expect(res.summary?.totalEmployees, 13);
      expect(res.summary?.averagePerformance, 0);
      expect(res.data.length, 2);

      final item1 = res.data[0];
      expect(item1.employee.name, 'Rahul Sharma');
      expect(item1.employee.employeeId, 'EMP-2026-011');
      expect(item1.employee.resolvedAvatar.contains('127.0.0.1'), false);
      expect(item1.evaluation, 'Needs Improvement');
      expect(item1.score, 0);

      final uiModel1 = item1.toUiModel();
      expect(uiModel1.name, 'Rahul Sharma');
      expect(uiModel1.rank, 1);
      expect(uiModel1.ratingLabel, 'Needs Improvement');

      final item2 = res.data[1];
      expect(item2.employee.name, 'John Doe');
      expect(item2.score, isNull);
      expect(item2.evaluation, 'Not Rated');
    });

    test('PerformanceController loads data from mock repository', () async {
      final res = EmployeePerformanceResponseModel.fromJson(sampleJson);
      final mockRepo = MockPerformanceRepository(res);
      final controller = PerformanceController(repository: mockRepo);

      await controller.fetchPerformanceEmployees();
      expect(controller.employees.length, 2);
      expect(controller.totalEmployeesCount, 13);
      expect(controller.averagePerformancePercent, 0);
      expect(controller.filteredEmployees.length, 2);
      expect(controller.filteredEmployees.first.name, 'Rahul Sharma');

      controller.searchQuery.value = 'John';
      expect(controller.filteredEmployees.length, 1);
      expect(controller.filteredEmployees.first.name, 'John Doe');
    });

    test('EmployeePerformanceDetailController fetches detail successfully', () async {
      final res = EmployeePerformanceResponseModel.fromJson(sampleJson);
      final mockRepo = MockPerformanceRepository(res);
      final detailController = EmployeePerformanceDetailController(repository: mockRepo);

      await detailController.fetchEmployeeDetail(employeeId: 17, month: '2026-10');
      expect(detailController.isLoading.value, false);
      expect(detailController.errorMessage.value, isEmpty);
      expect(detailController.detail.value, isNotNull);
      expect(detailController.detail.value?.employee.name, 'Jane Smith');
      expect(detailController.detail.value?.score, 85);
      expect(detailController.detail.value?.evaluation, 'Very Good');
    });

    test('Parses Employee Attendance History API Response correctly', () {
      final Map<String, dynamic> attendanceJson = {
        "status": true,
        "message": "Attendance details retrieved successfully.",
        "data": {
          "employee": {
            "id": 17,
            "employee_id": "EMP-2026-015",
            "name": "Rahul Sharma",
            "email": "darshankondekar01+12@gmail.com",
            "avatar": "https://yellowgreen-stork-427223.hostingersite.com/storage/avatars/wiS1bnWjQxY81Zkn73BBwSEtNa8tFy6qWT5NpwhU.jpg",
            "designation": "Lead Flutter Developer",
            "department": "Engineering",
            "department_id": null,
            "team": "Team Alpha"
          },
          "period": {
            "from": "2026-10-01",
            "to": "2026-10-31",
            "month": "2026-10",
            "label": "October 2026"
          },
          "summary": {
            "working_days": 20,
            "present": 1,
            "half_day": 0,
            "absent": 0,
            "leave": 0,
            "attendance_percent": 5
          },
          "calendar": [
            {
              "date": "2026-10-01",
              "day": "Thu",
              "status": "Not Recorded",
              "holiday": null,
              "attendance_id": null,
              "check_in_at": null,
              "check_out_at": null,
              "working_minutes": null
            },
            {
              "date": "2026-10-02",
              "day": "Fri",
              "status": "Holiday",
              "holiday": "Gandhi Jayanti",
              "attendance_id": null,
              "check_in_at": null,
              "check_out_at": null,
              "working_minutes": null
            },
            {
              "date": "2026-10-06",
              "day": "Tue",
              "status": "Late",
              "holiday": null,
              "attendance_id": 3,
              "check_in_at": "2026-10-06T06:02:01.000000Z",
              "check_out_at": null,
              "working_minutes": 0
            },
            {
              "date": "2026-10-07",
              "day": "Wed",
              "status": "Present",
              "holiday": null,
              "attendance_id": 5,
              "check_in_at": "2026-10-07T07:15:32.000000Z",
              "check_out_at": null,
              "working_minutes": 0
            }
          ],
          "recent_records": [
            {
              "id": 5,
              "user_id": 17,
              "shift_id": null,
              "attendance_date": "2026-10-07",
              "check_in_at": "2026-10-07T07:15:32.000000Z",
              "check_out_at": null,
              "working_minutes": 0,
              "break_minutes": 0,
              "overtime_minutes": 0,
              "status": "Present"
            }
          ]
        }
      };

      final parsed = AttendanceHistoryResponseModel.fromJson(attendanceJson);
      expect(parsed.status, true);
      expect(parsed.data, isNotNull);
      expect(parsed.data?.month, '2026-10');
      expect(parsed.data?.monthLabel, 'October 2026');

      final summary = parsed.data!.summary!;
      expect(summary.workingDays, 20);
      expect(summary.present, 1);
      expect(summary.attendancePercentage, 5.0);

      final calendar = parsed.data!.calendar;
      expect(calendar.length, 4);

      // Holiday day
      final holidayDay = calendar[1];
      expect(holidayDay.status, 'Holiday');
      expect(holidayDay.holiday, 'Gandhi Jayanti');
      final holidayRecord = holidayDay.toAttendanceRecord();
      expect(holidayRecord.remarks, 'Gandhi Jayanti');

      // Late day
      final lateDay = calendar[2];
      expect(lateDay.status, 'Late');
      expect(lateDay.isLate, true);
      expect(lateDay.checkIn, isNotNull);

      // Present day
      final presentDay = calendar[3];
      expect(presentDay.status, 'Present');
      expect(presentDay.checkIn, isNotNull);

      // Verify future dates comparison
      final today = DateTime(2026, 10, 7);
      expect(DateTime(2026, 10, 6).isAfter(today), false);
      expect(DateTime(2026, 10, 7).isAfter(today), false);
      expect(DateTime(2026, 10, 8).isAfter(today), true);
    });
  });
}
