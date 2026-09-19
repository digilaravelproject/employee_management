import '../../models/shift_response_model.dart';
import '../../repositories/shift_repository_interface.dart';

class GetShiftsUseCase {
  final ShiftRepositoryInterface repository;

  GetShiftsUseCase(this.repository);

  Future<ShiftListResponseModel> execute({String? status}) async {
    return await repository.getShifts(status: status);
  }
}
