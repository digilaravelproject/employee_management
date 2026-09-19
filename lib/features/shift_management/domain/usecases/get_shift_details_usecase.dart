import '../../models/shift_response_model.dart';
import '../../repositories/shift_repository_interface.dart';

class GetShiftDetailsUseCase {
  final ShiftRepositoryInterface repository;

  GetShiftDetailsUseCase(this.repository);

  Future<ShiftResponseModel> execute(String id) async {
    return await repository.getShiftDetails(id);
  }
}
