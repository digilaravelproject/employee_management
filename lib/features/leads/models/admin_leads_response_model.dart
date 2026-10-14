class AdminLeadsResponseModel {
  final bool status;
  final String message;
  final AdminLeadsSummaryModel? summary;
  final List<AdminLeadDataModel> data;
  final AdminLeadsPaginationModel? pagination;

  AdminLeadsResponseModel({
    required this.status,
    required this.message,
    this.summary,
    this.data = const [],
    this.pagination,
  });

  factory AdminLeadsResponseModel.fromJson(Map<String, dynamic> json) {
    return AdminLeadsResponseModel(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      summary: json['summary'] != null && json['summary'] is Map<String, dynamic>
          ? AdminLeadsSummaryModel.fromJson(json['summary'])
          : null,
      data: json['data'] != null && json['data'] is List
          ? (json['data'] as List)
              .map((item) => AdminLeadDataModel.fromJson(item as Map<String, dynamic>))
              .toList()
          : [],
      pagination: json['pagination'] != null && json['pagination'] is Map<String, dynamic>
          ? AdminLeadsPaginationModel.fromJson(json['pagination'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'summary': summary?.toJson(),
      'data': data.map((x) => x.toJson()).toList(),
      'pagination': pagination?.toJson(),
    };
  }
}

class AdminLeadsSummaryModel {
  final int all;
  final int unassigned;
  final int assigned;
  final Map<String, dynamic> bySource;

  AdminLeadsSummaryModel({
    required this.all,
    required this.unassigned,
    required this.assigned,
    required this.bySource,
  });

  factory AdminLeadsSummaryModel.fromJson(Map<String, dynamic> json) {
    return AdminLeadsSummaryModel(
      all: int.tryParse(json['all']?.toString() ?? '') ?? 0,
      unassigned: int.tryParse(json['unassigned']?.toString() ?? '') ?? 0,
      assigned: int.tryParse(json['assigned']?.toString() ?? '') ?? 0,
      bySource: json['by_source'] is Map ? Map<String, dynamic>.from(json['by_source']) : {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'all': all,
      'unassigned': unassigned,
      'assigned': assigned,
      'by_source': bySource,
    };
  }
}

class AdminLeadsPaginationModel {
  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;

  AdminLeadsPaginationModel({
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
  });

  factory AdminLeadsPaginationModel.fromJson(Map<String, dynamic> json) {
    return AdminLeadsPaginationModel(
      currentPage: int.tryParse(json['current_page']?.toString() ?? '') ?? 1,
      perPage: int.tryParse(json['per_page']?.toString() ?? '') ?? 20,
      total: int.tryParse(json['total']?.toString() ?? '') ?? 0,
      lastPage: int.tryParse(json['last_page']?.toString() ?? '') ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'per_page': perPage,
      'total': total,
      'last_page': lastPage,
    };
  }
}

class AdminLeadDataModel {
  final int id;
  final String? leadCode;
  final String? source;
  final String? fullName;
  final String? companyName;
  final String? email;
  final String? mobileNumber;
  final String? designation;
  final String? requirement;
  final String? status;
  final dynamic assignedTo;
  final dynamic assignedEmployee;
  final String? location;
  final dynamic estimatedValue;
  final String? expectedClosingDate;
  final String? notes;
  final String? sourceCreatedAt;
  final String? createdAt;
  final String? updatedAt;
  final Map<String, dynamic>? sourcePayload;
  final List<AdminLeadHistoryItemModel> history;

  AdminLeadDataModel({
    required this.id,
    this.leadCode,
    this.source,
    this.fullName,
    this.companyName,
    this.email,
    this.mobileNumber,
    this.designation,
    this.requirement,
    this.status,
    this.assignedTo,
    this.assignedEmployee,
    this.location,
    this.estimatedValue,
    this.expectedClosingDate,
    this.notes,
    this.sourceCreatedAt,
    this.createdAt,
    this.updatedAt,
    this.sourcePayload,
    this.history = const [],
  });

  factory AdminLeadDataModel.fromJson(Map<String, dynamic> json) {
    return AdminLeadDataModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      leadCode: json['lead_code']?.toString(),
      source: json['source']?.toString(),
      fullName: json['full_name']?.toString(),
      companyName: json['company_name']?.toString(),
      email: json['email']?.toString(),
      mobileNumber: json['mobile_number']?.toString(),
      designation: json['designation']?.toString(),
      requirement: json['requirement']?.toString(),
      status: json['status']?.toString(),
      assignedTo: json['assigned_to'],
      assignedEmployee: json['assigned_employee'],
      location: json['location']?.toString(),
      estimatedValue: json['estimated_value'],
      expectedClosingDate: json['expected_closing_date']?.toString(),
      notes: json['notes']?.toString(),
      sourceCreatedAt: json['source_created_at']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      sourcePayload: json['source_payload'] is Map<String, dynamic>
          ? json['source_payload'] as Map<String, dynamic>
          : null,
      history: json['history'] is List
          ? (json['history'] as List)
              .map((h) => AdminLeadHistoryItemModel.fromJson(h as Map<String, dynamic>))
              .toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lead_code': leadCode,
      'source': source,
      'full_name': fullName,
      'company_name': companyName,
      'email': email,
      'mobile_number': mobileNumber,
      'designation': designation,
      'requirement': requirement,
      'status': status,
      'assigned_to': assignedTo,
      'assigned_employee': assignedEmployee,
      'location': location,
      'estimated_value': estimatedValue,
      'expected_closing_date': expectedClosingDate,
      'notes': notes,
      'source_created_at': sourceCreatedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // Presentation Getters
  String get displayName => (fullName != null && fullName!.trim().isNotEmpty) ? fullName!.trim() : 'Unnamed Lead';
  String get displayCompany => (companyName != null && companyName!.trim().isNotEmpty) ? companyName!.trim() : '';
  String get displayPhone => (mobileNumber != null && mobileNumber!.trim().isNotEmpty) ? mobileNumber!.trim() : 'N/A';
  String get displayEmail => (email != null && email!.trim().isNotEmpty) ? email!.trim() : 'N/A';
  String get displaySource => (source != null && source!.trim().isNotEmpty) ? source!.trim() : 'Website';
  String get displayStatus => (status != null && status!.trim().isNotEmpty) ? status!.trim() : 'new';
  String get displayRequirement => (requirement != null && requirement!.trim().isNotEmpty) ? requirement!.trim() : 'General Inquiry';
  String get displayNotes => (notes != null && notes!.trim().isNotEmpty) ? notes!.trim() : '';
  String get displayLeadCode => (leadCode != null && leadCode!.isNotEmpty) ? leadCode! : 'LD-$id';

  bool get isAssigned {
    if (assignedTo != null && assignedTo.toString() != 'null' && assignedTo.toString().isNotEmpty) {
      return true;
    }
    if (assignedEmployee != null && assignedEmployee.toString() != 'null' && assignedEmployee.toString().isNotEmpty) {
      return true;
    }
    return false;
  }

  String get assignedExecutiveName {
    if (assignedEmployee != null) {
      if (assignedEmployee is Map) {
        return (assignedEmployee['name'] ?? assignedEmployee['full_name'] ?? 'Assigned').toString();
      }
      return assignedEmployee.toString();
    }
    if (assignedTo != null && assignedTo.toString() != 'null') {
      return 'Executive #${assignedTo.toString()}';
    }
    return 'Unassigned';
  }

  AdminLeadDataModel copyWith({
    int? id,
    String? leadCode,
    String? source,
    String? fullName,
    String? companyName,
    String? email,
    String? mobileNumber,
    String? designation,
    String? requirement,
    String? status,
    dynamic assignedTo,
    dynamic assignedEmployee,
    String? location,
    dynamic estimatedValue,
    String? expectedClosingDate,
    String? notes,
    String? sourceCreatedAt,
    String? createdAt,
    String? updatedAt,
    Map<String, dynamic>? sourcePayload,
    List<AdminLeadHistoryItemModel>? history,
  }) {
    return AdminLeadDataModel(
      id: id ?? this.id,
      leadCode: leadCode ?? this.leadCode,
      source: source ?? this.source,
      fullName: fullName ?? this.fullName,
      companyName: companyName ?? this.companyName,
      email: email ?? this.email,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      designation: designation ?? this.designation,
      requirement: requirement ?? this.requirement,
      status: status ?? this.status,
      assignedTo: assignedTo ?? this.assignedTo,
      assignedEmployee: assignedEmployee ?? this.assignedEmployee,
      location: location ?? this.location,
      estimatedValue: estimatedValue ?? this.estimatedValue,
      expectedClosingDate: expectedClosingDate ?? this.expectedClosingDate,
      notes: notes ?? this.notes,
      sourceCreatedAt: sourceCreatedAt ?? this.sourceCreatedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sourcePayload: sourcePayload ?? this.sourcePayload,
      history: history ?? this.history,
    );
  }
}

class AdminLeadDetailResponseModel {
  final bool status;
  final String message;
  final AdminLeadDataModel? data;

  AdminLeadDetailResponseModel({
    required this.status,
    required this.message,
    this.data,
  });

  factory AdminLeadDetailResponseModel.fromJson(Map<String, dynamic> json) {
    return AdminLeadDetailResponseModel(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? AdminLeadDataModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class AdminLeadHistoryItemModel {
  final int id;
  final String? eventType;
  final String? title;
  final String? description;
  final dynamic actor;
  final String? actorName;
  final Map<String, dynamic>? metadata;
  final String? occurredAt;

  AdminLeadHistoryItemModel({
    required this.id,
    this.eventType,
    this.title,
    this.description,
    this.actor,
    this.actorName,
    this.metadata,
    this.occurredAt,
  });

  factory AdminLeadHistoryItemModel.fromJson(Map<String, dynamic> json) {
    return AdminLeadHistoryItemModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      eventType: json['event_type']?.toString(),
      title: json['title']?.toString(),
      description: json['description']?.toString(),
      actor: json['actor'],
      actorName: json['actor_name']?.toString(),
      metadata: json['metadata'] is Map ? Map<String, dynamic>.from(json['metadata']) : null,
      occurredAt: json['occurred_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_type': eventType,
      'title': title,
      'description': description,
      'actor': actor,
      'actor_name': actorName,
      'metadata': metadata,
      'occurred_at': occurredAt,
    };
  }
}
