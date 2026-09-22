import 'dart:io';
import '../../../../core/services/network/response_model.dart';
import '../models/create_employee_request_model.dart';
import '../models/create_employee_response_model.dart';
import '../models/employee_model.dart';

abstract class EmployeeRepositoryInterface {
  Future<CreateEmployeeResponseModel> createEmployee(CreateEmployeeRequestModel request);
  Future<EmployeeListResponseModel> getEmployees();
  Future<EmployeeDetailResponseModel> getEmployeeById(String id);
  Future<ResponseModel> updateEmployee(String id, Map<String, dynamic> data);
  Future<ResponseModel> updateEmployeeAvatar(String id, File imageFile);
  Future<ResponseModel> deleteEmployee(String id);
}
