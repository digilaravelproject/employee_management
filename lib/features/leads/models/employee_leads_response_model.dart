class EmployeeLeadsResponseModel {
  final bool status;
  final String message;
  final EmployeeLeadsSummaryModel? summary;
  final List<EmployeeLeadItemModel> data;
  final EmployeeLeadsPaginationModel? pagination;

  EmployeeLeadsResponseModel({
    required this.status,
    required this.message,
    this.summary,
    this.data = const [],
    this.pagination,
  });

  factory EmployeeLeadsResponseModel.fromJson(Map<String, dynamic> json) {
    return EmployeeLeadsResponseModel(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      summary: json['summary'] != null && json['summary'] is Map<String, dynamic>
          ? EmployeeLeadsSummaryModel.fromJson(json['summary'])
          : null,
      data: json['data'] != null && json['data'] is List
          ? (json['data'] as List)
              .map((item) => EmployeeLeadItemModel.fromJson(item as Map<String, dynamic>))
              .toList()
          : [],
      pagination: json['pagination'] != null && json['pagination'] is Map<String, dynamic>
          ? EmployeeLeadsPaginationModel.fromJson(json['pagination'])
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

class EmployeeLeadsSummaryModel {
  final int all;
  final int interested;
  final int followUp;
  final int pendingCall;
  final int converted;
  final int unreachable;
  final int wrongNumber;
  final double convertedRevenue;

  EmployeeLeadsSummaryModel({
    this.all = 0,
    this.interested = 0,
    this.followUp = 0,
    this.pendingCall = 0,
    this.converted = 0,
    this.unreachable = 0,
    this.wrongNumber = 0,
    this.convertedRevenue = 0.0,
  });

  factory EmployeeLeadsSummaryModel.fromJson(Map<String, dynamic> json) {
    return EmployeeLeadsSummaryModel(
      all: int.tryParse(json['all']?.toString() ?? '') ?? 0,
      interested: int.tryParse(json['interested']?.toString() ?? '') ?? 0,
      followUp: int.tryParse(json['follow_up']?.toString() ?? '') ?? 0,
      pendingCall: int.tryParse(json['pending_call']?.toString() ?? '') ?? 0,
      converted: int.tryParse(json['converted']?.toString() ?? '') ?? 0,
      unreachable: int.tryParse(json['unreachable']?.toString() ?? '') ?? 0,
      wrongNumber: int.tryParse(json['wrong_number']?.toString() ?? '') ?? 0,
      convertedRevenue: double.tryParse(json['converted_revenue']?.toString() ?? '') ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'all': all,
      'interested': interested,
      'follow_up': followUp,
      'pending_call': pendingCall,
      'converted': converted,
      'unreachable': unreachable,
      'wrong_number': wrongNumber,
      'converted_revenue': convertedRevenue,
    };
  }
}

class EmployeeLeadsPaginationModel {
  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;

  EmployeeLeadsPaginationModel({
    this.currentPage = 1,
    this.perPage = 20,
    this.total = 0,
    this.lastPage = 1,
  });

  factory EmployeeLeadsPaginationModel.fromJson(Map<String, dynamic> json) {
    return EmployeeLeadsPaginationModel(
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

class EmployeeLeadAssignedEmployeeModel {
  final int id;
  final String? employeeId;
  final String? name;
  final String? email;
  final String? mobileNumber;
  final String? designation;
  final String? avatar;

  EmployeeLeadAssignedEmployeeModel({
    required this.id,
    this.employeeId,
    this.name,
    this.email,
    this.mobileNumber,
    this.designation,
    this.avatar,
  });

  factory EmployeeLeadAssignedEmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeLeadAssignedEmployeeModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      employeeId: json['employee_id']?.toString(),
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      mobileNumber: json['mobile_number']?.toString(),
      designation: json['designation']?.toString(),
      avatar: json['avatar']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'name': name,
      'email': email,
      'mobile_number': mobileNumber,
      'designation': designation,
      'avatar': avatar,
    };
  }
}

class EmployeeLeadCreatedByModel {
  final int id;
  final String? employeeId;
  final String? name;
  final String? role;

  EmployeeLeadCreatedByModel({
    required this.id,
    this.employeeId,
    this.name,
    this.role,
  });

  factory EmployeeLeadCreatedByModel.fromJson(Map<String, dynamic> json) {
    return EmployeeLeadCreatedByModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      employeeId: json['employee_id']?.toString(),
      name: json['name']?.toString(),
      role: json['role']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'name': name,
      'role': role,
    };
  }
}

class EmployeeLeadHistoryItemModel {
  final int id;
  final String? eventType;
  final String? title;
  final String? description;
  final EmployeeLeadCreatedByModel? actor;
  final String? actorName;
  final dynamic metadata;
  final String? occurredAt;

  EmployeeLeadHistoryItemModel({
    required this.id,
    this.eventType,
    this.title,
    this.description,
    this.actor,
    this.actorName,
    this.metadata,
    this.occurredAt,
  });

  factory EmployeeLeadHistoryItemModel.fromJson(Map<String, dynamic> json) {
    return EmployeeLeadHistoryItemModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      eventType: json['event_type']?.toString(),
      title: json['title']?.toString(),
      description: json['description']?.toString(),
      actor: json['actor'] is Map<String, dynamic>
          ? EmployeeLeadCreatedByModel.fromJson(json['actor'])
          : null,
      actorName: json['actor_name']?.toString(),
      metadata: json['metadata'],
      occurredAt: json['occurred_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_type': eventType,
      'title': title,
      'description': description,
      'actor': actor?.toJson(),
      'actor_name': actorName,
      'metadata': metadata,
      'occurred_at': occurredAt,
    };
  }
}

class EmployeeLeadItemModel {
  final int id;
  final String? leadCode;
  final String? source;
  final String? assignmentOrigin;
  final String? fullName;
  final String? companyName;
  final String? email;
  final String? mobileNumber;
  final String? designation;
  final String? requirement;
  final String? status;
  final int? assignedTo;
  final bool isOwner;
  final EmployeeLeadAssignedEmployeeModel? assignedEmployee;
  final EmployeeLeadCreatedByModel? createdBy;
  final String? location;
  final dynamic estimatedValue;
  final String? expectedClosingDate;
  final String? notes;
  final String? sourceCreatedAt;
  final String? createdAt;
  final String? updatedAt;
  final List<EmployeeLeadHistoryItemModel> history;

  EmployeeLeadItemModel({
    required this.id,
    this.leadCode,
    this.source,
    this.assignmentOrigin,
    this.fullName,
    this.companyName,
    this.email,
    this.mobileNumber,
    this.designation,
    this.requirement,
    this.status,
    this.assignedTo,
    this.isOwner = true,
    this.assignedEmployee,
    this.createdBy,
    this.location,
    this.estimatedValue,
    this.expectedClosingDate,
    this.notes,
    this.sourceCreatedAt,
    this.createdAt,
    this.updatedAt,
    this.history = const [],
  });

  factory EmployeeLeadItemModel.fromJson(Map<String, dynamic> json) {
    return EmployeeLeadItemModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      leadCode: json['lead_code']?.toString(),
      source: json['source']?.toString(),
      assignmentOrigin: json['assignment_origin']?.toString(),
      fullName: json['full_name']?.toString(),
      companyName: json['company_name']?.toString(),
      email: json['email']?.toString(),
      mobileNumber: json['mobile_number']?.toString(),
      designation: json['designation']?.toString(),
      requirement: json['requirement']?.toString(),
      status: json['status']?.toString(),
      assignedTo: int.tryParse(json['assigned_to']?.toString() ?? ''),
      isOwner: json['is_owner'] == true,
      assignedEmployee: json['assigned_employee'] is Map<String, dynamic>
          ? EmployeeLeadAssignedEmployeeModel.fromJson(json['assigned_employee'])
          : null,
      createdBy: json['created_by'] is Map<String, dynamic>
          ? EmployeeLeadCreatedByModel.fromJson(json['created_by'])
          : null,
      location: json['location']?.toString(),
      estimatedValue: json['estimated_value'],
      expectedClosingDate: json['expected_closing_date']?.toString(),
      notes: json['notes']?.toString(),
      sourceCreatedAt: json['source_created_at']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      history: json['history'] != null && json['history'] is List
          ? (json['history'] as List)
              .map((x) => EmployeeLeadHistoryItemModel.fromJson(x as Map<String, dynamic>))
              .toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lead_code': leadCode,
      'source': source,
      'assignment_origin': assignmentOrigin,
      'full_name': fullName,
      'company_name': companyName,
      'email': email,
      'mobile_number': mobileNumber,
      'designation': designation,
      'requirement': requirement,
      'status': status,
      'assigned_to': assignedTo,
      'is_owner': isOwner,
      'assigned_employee': assignedEmployee?.toJson(),
      'created_by': createdBy?.toJson(),
      'location': location,
      'estimated_value': estimatedValue,
      'expected_closing_date': expectedClosingDate,
      'notes': notes,
      'source_created_at': sourceCreatedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'history': history.map((x) => x.toJson()).toList(),
    };
  }
}

class EmployeeLeadDetailResponseModel {
  final bool status;
  final String message;
  final EmployeeLeadItemModel? data;

  EmployeeLeadDetailResponseModel({
    required this.status,
    required this.message,
    this.data,
  });

  factory EmployeeLeadDetailResponseModel.fromJson(Map<String, dynamic> json) {
    return EmployeeLeadDetailResponseModel(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? EmployeeLeadItemModel.fromJson(json['data'])
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
