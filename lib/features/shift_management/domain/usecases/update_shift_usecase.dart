import '../../models/create_shift_request_model.dart';
import '../../models/shift_response_model.dart';
import '../../repositories/shift_repository_interface.dart';

class UpdateShiftUseCase {
  final ShiftRepositoryInterface repository;

  UpdateShiftUseCase(this.repository);

  Future<ShiftResponseModel> execute(String id, CreateShiftRequestModel request) async {
    return await repository.updateShift(id, request);
  }
}
