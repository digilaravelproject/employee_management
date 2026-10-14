import '../../models/sales_employee_model.dart';
import '../../repositories/admin_leads_repository_interface.dart';

class GetSalesEmployeesUseCase {
  final AdminLeadsRepositoryInterface repository;

  GetSalesEmployeesUseCase(this.repository);

  Future<SalesEmployeesResponseModel> call() async {
    return await repository.getSalesEmployees();
  }
}
