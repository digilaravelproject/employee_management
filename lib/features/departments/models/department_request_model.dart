class DepartmentRequestModel {
  final String name;
  final String description;
  final String status;
  final int? headUserId;
  final List<int>? employeeIds;

  DepartmentRequestModel({
    required this.name,
    required this.description,
    this.status = 'Active',
    this.headUserId,
    this.employeeIds,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'name': name,
      'description': description,
      'status': status,
    };
    if (headUserId != null) {
      data['head_user_id'] = headUserId;
    }
    if (employeeIds != null) {
      data['employee_ids'] = employeeIds;
    }
    return data;
  }
}
