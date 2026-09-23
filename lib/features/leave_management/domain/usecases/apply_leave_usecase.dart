import '../../models/apply_leave_request_model.dart';
import '../../models/apply_leave_response_model.dart';
import '../../repositories/apply_leave_repository_interface.dart';

class ApplyLeaveUseCase {
  final ApplyLeaveRepositoryInterface repository;

  ApplyLeaveUseCase(this.repository);

  Future<ApplyLeaveResponseModel> call(ApplyLeaveRequestModel request) {
    return repository.applyLeave(request);
  }
}
