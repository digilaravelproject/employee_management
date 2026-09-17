class BdeTargetModel {
  final String id;
  final String employeeName;
  final String employeeEmail;
  final String avatarUrl;
  final String month; // e.g. "September 2026", "August 2026"
  final double targetAmount;
  final int targetDealsCount;

  const BdeTargetModel({
    required this.id,
    required this.employeeName,
    required this.employeeEmail,
    required this.avatarUrl,
    required this.month,
    required this.targetAmount,
    required this.targetDealsCount,
  });

  BdeTargetModel copyWith({
    String? id,
    String? employeeName,
    String? employeeEmail,
    String? avatarUrl,
    String? month,
    double? targetAmount,
    int? targetDealsCount,
  }) {
    return BdeTargetModel(
      id: id ?? this.id,
      employeeName: employeeName ?? this.employeeName,
      employeeEmail: employeeEmail ?? this.employeeEmail,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      month: month ?? this.month,
      targetAmount: targetAmount ?? this.targetAmount,
      targetDealsCount: targetDealsCount ?? this.targetDealsCount,
    );
  }
}
