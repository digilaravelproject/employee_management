import '../models/create_shift_request_model.dart';
import '../models/shift_response_model.dart';

abstract class ShiftRepositoryInterface {
  Future<ShiftResponseModel> createShift(CreateShiftRequestModel request);
  Future<ShiftResponseModel> updateShift(String id, CreateShiftRequestModel request);
  Future<ShiftResponseModel> assignEmployeesToShift(String shiftId, List<int> employeeIds);
  Future<ShiftResponseModel> deleteShift(String id);
  Future<ShiftListResponseModel> getShifts({String? status});
  Future<ShiftResponseModel> getShiftDetails(String id);
}
