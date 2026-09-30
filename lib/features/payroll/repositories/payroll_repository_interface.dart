import '../models/salary_detail_model.dart';
import '../models/salary_history_model.dart';
import '../models/salary_model.dart';

abstract class PayrollRepositoryInterface {
  Future<SalaryListResponseModel?> getSalaries({
    required String month,
    String? search,
    String? status,
  });

  Future<SalaryDetailResponseModel?> getEmployeeSalaryDetails({
    required String employeeId,
    required String month,
  });

  Future<CreateSalaryResponseModel?> createSalary(CreateSalaryRequestModel request);

  Future<SalaryHistoryResponseModel?> getSalaryHistory({int? year});
}

