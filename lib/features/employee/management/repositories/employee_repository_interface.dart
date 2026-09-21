import '../models/create_employee_request_model.dart';
import '../models/create_employee_response_model.dart';

abstract class EmployeeRepositoryInterface {
  Future<CreateEmployeeResponseModel> createEmployee(CreateEmployeeRequestModel request);
}
