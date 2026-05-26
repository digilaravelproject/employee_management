class EmployeeModel {
  final String id;
  final String employeeId;
  final String name;
  final String mobile;
  final String email;
  final String designation;
  final double salary;
  final List<String> skills;
  final String joiningDate;
  final String address;
  final String emergencyContact;
  final String? profilePic;

  EmployeeModel({
    required this.id,
    required this.employeeId,
    required this.name,
    required this.mobile,
    required this.email,
    required this.designation,
    required this.salary,
    required this.skills,
    required this.joiningDate,
    required this.address,
    required this.emergencyContact,
    this.profilePic,
  });
}
