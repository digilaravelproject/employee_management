import '../../models/create_employee_request_model.dart';
import '../../models/create_employee_response_model.dart';
import '../../repositories/employee_repository_interface.dart';

class CreateEmployeeUseCase {
  final EmployeeRepositoryInterface repository;

  CreateEmployeeUseCase(this.repository);

  Future<CreateEmployeeResponseModel> execute(CreateEmployeeRequestModel request) {
    return repository.createEmployee(request);
  }
}
