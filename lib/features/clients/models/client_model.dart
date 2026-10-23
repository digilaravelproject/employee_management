import '../../role_permissions/models/role_permission_models.dart';

class KeyContact {
  final String name;
  final String designation;
  final String mobile;
  final String email;

  const KeyContact({
    required this.name,
    required this.designation,
    required this.mobile,
    required this.email,
  });

  KeyContact copyWith({
    String? name,
    String? designation,
    String? mobile,
    String? email,
  }) {
    return KeyContact(
      name: name ?? this.name,
      designation: designation ?? this.designation,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
    );
  }
}

class ClientProject {
  final String id;
  final String name;
  final String description;
  final DateTime startDate;
  final DateTime dueDate;
  final AppUser projectManager;
  final double estimatedValue;
  final String status; // Active, Completed, On Hold

  const ClientProject({
    required this.id,
    required this.name,
    required this.description,
    required this.startDate,
    required this.dueDate,
    required this.projectManager,
    required this.estimatedValue,
    required this.status,
  });

  ClientProject copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? startDate,
    DateTime? dueDate,
    AppUser? projectManager,
    double? estimatedValue,
    String? status,
  }) {
    return ClientProject(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      dueDate: dueDate ?? this.dueDate,
      projectManager: projectManager ?? this.projectManager,
      estimatedValue: estimatedValue ?? this.estimatedValue,
      status: status ?? this.status,
    );
  }
}

class ClientCommunication {
  final String id;
  final String type; // Email, Call, Meeting, Note
  final String subject;
  final DateTime dateTime;
  final String to;
  final String description;
  final String? attachmentName;

  const ClientCommunication({
    required this.id,
    required this.type,
    required this.subject,
    required this.dateTime,
    required this.to,
    required this.description,
    this.attachmentName,
  });

  ClientCommunication copyWith({
    String? id,
    String? type,
    String? subject,
    DateTime? dateTime,
    String? to,
    String? description,
    String? attachmentName,
  }) {
    return ClientCommunication(
      id: id ?? this.id,
      type: type ?? this.type,
      subject: subject ?? this.subject,
      dateTime: dateTime ?? this.dateTime,
      to: to ?? this.to,
      description: description ?? this.description,
      attachmentName: attachmentName ?? this.attachmentName,
    );
  }
}

class Client {
  final String id;
  final String name;
  final String email;
  final String mobile;
  final String website;
  final String address;
  final String status; // Active, Inactive
  final String notes;
  final int? leadId;
  final int projectsCount;
  final int communicationsCount;
  final List<KeyContact> keyContacts;
  final List<ClientProject> projects;
  final List<ClientCommunication> communications;
  final DateTime createdOn;
  final DateTime? updatedAt;

  const Client({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
    required this.website,
    required this.address,
    required this.status,
    required this.notes,
    this.leadId,
    this.projectsCount = 0,
    this.communicationsCount = 0,
    required this.keyContacts,
    required this.projects,
    required this.communications,
    required this.createdOn,
    this.updatedAt,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    DateTime parsedCreated = DateTime.now();
    if (json['created_at'] != null) {
      try {
        parsedCreated = DateTime.parse(json['created_at'].toString());
      } catch (_) {}
    } else if (json['created_on'] != null) {
      try {
        parsedCreated = DateTime.parse(json['created_on'].toString());
      } catch (_) {}
    }

    DateTime? parsedUpdated;
    if (json['updated_at'] != null) {
      try {
        parsedUpdated = DateTime.parse(json['updated_at'].toString());
      } catch (_) {}
    }

    final pCount = (json['projects_count'] as num?)?.toInt() ?? 0;
    final cCount = (json['communications_count'] as num?)?.toInt() ?? 0;

    return Client(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      mobile: (json['mobile_number'] ?? json['mobile'])?.toString() ?? '',
      website: json['website']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Active',
      notes: json['notes']?.toString() ?? '',
      leadId: (json['lead_id'] as num?)?.toInt(),
      projectsCount: pCount,
      communicationsCount: cCount,
      keyContacts: const [],
      projects: const [],
      communications: const [],
      createdOn: parsedCreated,
      updatedAt: parsedUpdated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'mobile_number': mobile,
      'website': website,
      'address': address,
      'status': status,
      'notes': notes,
      'lead_id': leadId,
      'projects_count': projectsCount,
      'communications_count': communicationsCount,
      'created_at': createdOn.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Client copyWith({
    String? id,
    String? name,
    String? email,
    String? mobile,
    String? website,
    String? address,
    String? status,
    String? notes,
    int? leadId,
    int? projectsCount,
    int? communicationsCount,
    List<KeyContact>? keyContacts,
    List<ClientProject>? projects,
    List<ClientCommunication>? communications,
    DateTime? createdOn,
    DateTime? updatedAt,
  }) {
    return Client(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      website: website ?? this.website,
      address: address ?? this.address,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      leadId: leadId ?? this.leadId,
      projectsCount: projectsCount ?? this.projectsCount,
      communicationsCount: communicationsCount ?? this.communicationsCount,
      keyContacts: keyContacts ?? this.keyContacts,
      projects: projects ?? this.projects,
      communications: communications ?? this.communications,
      createdOn: createdOn ?? this.createdOn,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
