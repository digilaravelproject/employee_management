class PolicyItem {
  final String id;
  final String title;
  final String category;
  final String version;
  final DateTime updatedDate;
  final DateTime reviewDate;
  final String summary;
  final String description;
  final String status; // 'Published', 'Pending', 'Overdue'
  bool isAcknowledged;
  DateTime? acknowledgedDate;

  PolicyItem({
    required this.id,
    required this.title,
    required this.category,
    required this.version,
    required this.updatedDate,
    required this.reviewDate,
    required this.summary,
    required this.description,
    required this.status,
    this.isAcknowledged = false,
    this.acknowledgedDate,
  });

  PolicyItem copyWith({
    String? id,
    String? title,
    String? category,
    String? version,
    DateTime? updatedDate,
    DateTime? reviewDate,
    String? summary,
    String? description,
    String? status,
    bool? isAcknowledged,
    DateTime? acknowledgedDate,
  }) {
    return PolicyItem(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      version: version ?? this.version,
      updatedDate: updatedDate ?? this.updatedDate,
      reviewDate: reviewDate ?? this.reviewDate,
      summary: summary ?? this.summary,
      description: description ?? this.description,
      status: status ?? this.status,
      isAcknowledged: isAcknowledged ?? this.isAcknowledged,
      acknowledgedDate: acknowledgedDate ?? this.acknowledgedDate,
    );
  }
}

class ComplianceAuditLog {
  final String id;
  final DateTime dateTime;
  final String activity; // 'Policy Created', 'Policy Updated', 'Policy Published', 'Acknowledgement', 'Reminder Sent'
  final String policyTitle;
  final String performedBy;
  final String details;

  ComplianceAuditLog({
    required this.id,
    required this.dateTime,
    required this.activity,
    required this.policyTitle,
    required this.performedBy,
    required this.details,
  });
}

class EmployeeAcknowledgement {
  final String employeeName;
  final String designation;
  final String avatarUrl;
  final String status; // 'Acknowledged', 'Pending', 'Overdue'
  final String? acknowledgedTime;

  EmployeeAcknowledgement({
    required this.employeeName,
    required this.designation,
    required this.avatarUrl,
    required this.status,
    this.acknowledgedTime,
  });
}
