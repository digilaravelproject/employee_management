import '../../models/leave_type_model.dart';
import '../../repositories/apply_leave_repository_interface.dart';

class GetLeaveTypesUseCase {
  final ApplyLeaveRepositoryInterface repository;

  GetLeaveTypesUseCase(this.repository);

  Future<LeaveTypeListResponseModel> call() {
    return repository.getLeaveTypes();
  }
}
