import '../../models/shift_response_model.dart';
import '../../repositories/shift_repository_interface.dart';

class DeleteShiftUseCase {
  final ShiftRepositoryInterface repository;

  DeleteShiftUseCase(this.repository);

  Future<ShiftResponseModel> execute(String id) async {
    return await repository.deleteShift(id);
  }
}
