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

  EmployeeModel copyWith({
    String? id,
    String? employeeId,
    String? name,
    String? mobile,
    String? email,
    String? designation,
    double? salary,
    List<String>? skills,
    String? joiningDate,
    String? address,
    String? emergencyContact,
    String? profilePic,
  }) {
    return EmployeeModel(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      designation: designation ?? this.designation,
      salary: salary ?? this.salary,
      skills: skills ?? this.skills,
      joiningDate: joiningDate ?? this.joiningDate,
      address: address ?? this.address,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      profilePic: profilePic ?? this.profilePic,
    );
  }
}
