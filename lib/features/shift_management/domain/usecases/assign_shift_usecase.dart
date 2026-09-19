import '../../models/shift_response_model.dart';
import '../../repositories/shift_repository_interface.dart';

class AssignShiftUseCase {
  final ShiftRepositoryInterface repository;

  AssignShiftUseCase(this.repository);

  Future<ShiftResponseModel> execute(String shiftId, List<int> employeeIds) async {
    return await repository.assignEmployeesToShift(shiftId, employeeIds);
  }
}
