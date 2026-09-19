import '../../models/create_shift_request_model.dart';
import '../../models/shift_response_model.dart';
import '../../repositories/shift_repository_interface.dart';

class CreateShiftUseCase {
  final ShiftRepositoryInterface repository;

  CreateShiftUseCase(this.repository);

  Future<ShiftResponseModel> execute(CreateShiftRequestModel request) async {
    return await repository.createShift(request);
  }
}
