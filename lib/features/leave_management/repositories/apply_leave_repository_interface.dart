import '../models/apply_leave_request_model.dart';
import '../models/apply_leave_response_model.dart';
import '../models/leave_type_model.dart';

abstract class ApplyLeaveRepositoryInterface {
  Future<LeaveTypeListResponseModel> getLeaveTypes();
  Future<ApplyLeaveResponseModel> applyLeave(ApplyLeaveRequestModel request);
}
