import '../../../core/services/network/response_model.dart';
import '../models/admin_leave_model.dart';
import '../models/leave_report_model.dart';

abstract class AdminLeaveRepositoryInterface {
  Future<AdminLeaveListResponseModel> getLeaveRequests({
    String? status,
    String? dateRange,
    String? startDate,
    String? endDate,
    dynamic departmentId,
    dynamic leaveTypeId,
    String? search,
    int? page,
    int? perPage,
    int? year,
  });
  Future<AdminLeaveListResponseModel> getEmployeeLeaves({
    String status = 'all',
    required String fromDate,
    required String toDate,
    int perPage = 100,
  });
  Future<LeaveReportResponseModel> getLeaveReports({
    required String fromDate,
    required String toDate,
    dynamic departmentId,
    dynamic leaveTypeId,
    String status = 'all',
  });
  Future<AdminLeaveDetailResponseModel> getLeaveRequestDetails(int id);
  Future<ResponseModel> approveLeaveRequest(int id, {String? note});
  Future<ResponseModel> rejectLeaveRequest(int id, {String? note});
}
