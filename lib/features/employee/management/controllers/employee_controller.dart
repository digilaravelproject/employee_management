import 'package:get/get.dart';
import '../models/employee_model.dart';

class EmployeeController extends GetxController {
  var employees = <EmployeeModel>[].obs;
  var filteredEmployees = <EmployeeModel>[].obs;
  
  // Form State
  var selectedSkills = <String>[].obs;
  var availableSkills = ['Flutter', 'React Native', 'PHP', 'Python', 'Node.js', 'UI/UX', 'Marketing', 'Sales'].obs;
  var designations = ['Senior Flutter Developer', 'HR Manager', 'PHP Developer', 'Sales Executive', 'Project Manager'].obs;
  
  @override
  void onInit() {
    super.onInit();
    // Initial Mock Data
    employees.addAll([
      EmployeeModel(
        id: '1',
        employeeId: 'EMP-2025-001',
        name: 'Rohit Sharma',
        mobile: '9876543210',
        email: 'rohit@example.com',
        designation: 'Senior Flutter Developer',
        salary: 85000,
        skills: ['Flutter', 'Firebase', 'Dart'],
        joiningDate: '10 May 2024',
        address: '123, Tech Park, Bangalore',
        emergencyContact: '9876543219',
      ),
      EmployeeModel(
        id: '2',
        employeeId: 'EMP-2025-002',
        name: 'Neha Gupta',
        mobile: '9876543211',
        email: 'neha@example.com',
        designation: 'HR Manager',
        salary: 65000,
        skills: ['Recruitment', 'Operations'],
        joiningDate: '15 June 2024',
        address: '456, Green View, Mumbai',
        emergencyContact: '9876543218',
      ),
    ]);
    filteredEmployees.value = employees;
  }

  void filterEmployees(String query) {
    if (query.isEmpty) {
      filteredEmployees.value = employees;
    } else {
      filteredEmployees.value = employees
          .where((e) => e.name.toLowerCase().contains(query.toLowerCase()) || 
                       e.designation.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  void addEmployee(EmployeeModel employee) {
    employees.add(employee);
    filterEmployees('');
  }

  void updateEmployee(EmployeeModel updatedEmployee) {
    int index = employees.indexWhere((e) => e.id == updatedEmployee.id);
    if (index != -1) {
      employees[index] = updatedEmployee;
      filterEmployees('');
    }
  }

  void deleteEmployee(String id) {
    employees.removeWhere((e) => e.id == id);
    filterEmployees('');
  }

  void toggleSkill(String skill) {
    if (selectedSkills.contains(skill)) {
      selectedSkills.remove(skill);
    } else {
      selectedSkills.add(skill);
    }
  }
}
