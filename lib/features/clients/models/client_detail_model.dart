class ClientDetailResponse {
  final bool status;
  final String message;
  final ClientDetailData? data;

  ClientDetailResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory ClientDetailResponse.fromJson(Map<String, dynamic> json) {
    return ClientDetailResponse(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? ClientDetailData.fromJson(json['data'])
          : null,
    );
  }
}

class ClientCreatedBy {
  final int id;
  final String name;
  final String email;
  final String? designation;
  final String? avatar;
  final String? phone;

  ClientCreatedBy({
    required this.id,
    required this.name,
    required this.email,
    this.designation,
    this.avatar,
    this.phone,
  });

  factory ClientCreatedBy.fromJson(Map<String, dynamic> json) {
    return ClientCreatedBy(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      designation: json['designation']?.toString(),
      avatar: json['avatar']?.toString(),
      phone: (json['mobile_number'] ?? json['phone'])?.toString(),
    );
  }
}

class ProjectManagerSummary {
  final int id;
  final String name;
  final String? email;
  final String? phone;
  final String? designation;
  final String? employeeId;
  final String? avatar;
  final String? department;

  ProjectManagerSummary({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.designation,
    this.employeeId,
    this.avatar,
    this.department,
  });

  factory ProjectManagerSummary.fromJson(Map<String, dynamic> json) {
    return ProjectManagerSummary(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString(),
      phone: (json['mobile_number'] ?? json['phone'])?.toString(),
      designation: json['designation']?.toString(),
      employeeId: json['employee_id']?.toString(),
      avatar: json['avatar']?.toString(),
      department: json['department']?.toString(),
    );
  }
}

class ProjectTeamMember {
  final int id;
  final String? employeeId;
  final String name;
  final String? email;
  final String? designation;
  final String? avatar;

  ProjectTeamMember({
    required this.id,
    this.employeeId,
    required this.name,
    this.email,
    this.designation,
    this.avatar,
  });

  factory ProjectTeamMember.fromJson(Map<String, dynamic> json) {
    return ProjectTeamMember(
      id: (json['id'] as num?)?.toInt() ?? 0,
      employeeId: json['employee_id']?.toString(),
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString(),
      designation: json['designation']?.toString(),
      avatar: json['avatar']?.toString(),
    );
  }
}

class ClientDetailProject {
  final int id;
  final int? leadId;
  final int? clientId;
  final String name;
  final String description;
  final String category;
  final String priority;
  final String startDate;
  final String endDate;
  final int workingDays;
  final double estimatedValue;
  final String status;
  final int progress;
  final ProjectManagerSummary? projectManager;
  final List<ProjectTeamMember> team;

  ClientDetailProject({
    required this.id,
    this.leadId,
    this.clientId,
    required this.name,
    required this.description,
    required this.category,
    required this.priority,
    required this.startDate,
    required this.endDate,
    required this.workingDays,
    required this.estimatedValue,
    required this.status,
    required this.progress,
    this.projectManager,
    this.team = const [],
  });

  factory ClientDetailProject.fromJson(Map<String, dynamic> json) {
    List<ProjectTeamMember> parsedTeam = [];
    if (json['team'] is List) {
      parsedTeam = (json['team'] as List)
          .whereType<Map<String, dynamic>>()
          .map((m) => ProjectTeamMember.fromJson(m))
          .toList();
    }

    double parsedVal = 0.0;
    if (json['estimated_value'] != null) {
      parsedVal = double.tryParse(json['estimated_value'].toString()) ?? 0.0;
    }

    return ClientDetailProject(
      id: (json['id'] as num?)?.toInt() ?? 0,
      leadId: (json['lead_id'] as num?)?.toInt(),
      clientId: (json['client_id'] as num?)?.toInt(),
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? 'General',
      priority: json['priority']?.toString() ?? 'Standard',
      startDate: json['start_date']?.toString() ?? '',
      endDate: json['end_date']?.toString() ?? '',
      workingDays: (json['working_days'] as num?)?.toInt() ?? 0,
      estimatedValue: parsedVal,
      status: json['status']?.toString() ?? 'In Progress',
      progress: (json['progress'] as num?)?.toInt() ?? 0,
      projectManager: json['project_manager'] is Map<String, dynamic>
          ? ProjectManagerSummary.fromJson(json['project_manager'])
          : null,
      team: parsedTeam,
    );
  }
}

class ClientDetailCommunication {
  final int id;
  final int? clientId;
  final String type;
  final String subject;
  final DateTime? communicatedAt;
  final String recipient;
  final String description;
  final String? attachmentName;
  final String? attachmentUrl;
  final ClientCreatedBy? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ClientDetailCommunication({
    required this.id,
    this.clientId,
    required this.type,
    required this.subject,
    this.communicatedAt,
    required this.recipient,
    required this.description,
    this.attachmentName,
    this.attachmentUrl,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  factory ClientDetailCommunication.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      try {
        return DateTime.parse(v.toString());
      } catch (_) {
        return null;
      }
    }

    return ClientDetailCommunication(
      id: (json['id'] as num?)?.toInt() ?? 0,
      clientId: (json['client_id'] as num?)?.toInt(),
      type: json['type']?.toString() ?? 'Communication',
      subject: json['subject']?.toString() ?? '',
      communicatedAt: parseDate(json['communicated_at']),
      recipient: json['recipient']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      attachmentName: json['attachment_name']?.toString(),
      attachmentUrl: json['attachment_url']?.toString(),
      createdBy: json['created_by'] is Map<String, dynamic>
          ? ClientCreatedBy.fromJson(json['created_by'])
          : null,
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
    );
  }
}

class ClientDetailData {
  final int id;
  final String name;
  final String email;
  final String mobileNumber;
  final String website;
  final String address;
  final String status;
  final String notes;
  final int? leadId;
  final int projectsCount;
  final int communicationsCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? lead;
  final ClientCreatedBy? createdBy;
  final List<ClientDetailProject> projects;
  final List<ClientDetailCommunication> communications;

  ClientDetailData({
    required this.id,
    required this.name,
    required this.email,
    required this.mobileNumber,
    required this.website,
    required this.address,
    required this.status,
    required this.notes,
    this.leadId,
    this.projectsCount = 0,
    this.communicationsCount = 0,
    this.createdAt,
    this.updatedAt,
    this.lead,
    this.createdBy,
    this.projects = const [],
    this.communications = const [],
  });

  factory ClientDetailData.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      try {
        return DateTime.parse(v.toString());
      } catch (_) {
        return null;
      }
    }

    List<ClientDetailProject> parsedProjects = [];
    if (json['projects'] is List) {
      parsedProjects = (json['projects'] as List)
          .whereType<Map<String, dynamic>>()
          .map((m) => ClientDetailProject.fromJson(m))
          .toList();
    }

    List<ClientDetailCommunication> parsedComms = [];
    if (json['communications'] is List) {
      parsedComms = (json['communications'] as List)
          .whereType<Map<String, dynamic>>()
          .map((m) => ClientDetailCommunication.fromJson(m))
          .toList();
    }

    return ClientDetailData(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      mobileNumber: (json['mobile_number'] ?? json['mobile'])?.toString() ?? '',
      website: json['website']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Active',
      notes: json['notes']?.toString() ?? '',
      leadId: (json['lead_id'] as num?)?.toInt(),
      projectsCount: (json['projects_count'] as num?)?.toInt() ?? parsedProjects.length,
      communicationsCount: (json['communications_count'] as num?)?.toInt() ?? parsedComms.length,
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
      lead: json['lead'] is Map<String, dynamic> ? json['lead'] : null,
      createdBy: json['created_by'] is Map<String, dynamic>
          ? ClientCreatedBy.fromJson(json['created_by'])
          : null,
      projects: parsedProjects,
      communications: parsedComms,
    );
  }
}
