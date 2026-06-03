class AppDocument {
  final String id;
  final String name;
  final String type; // 'pdf', 'xlsx', 'docx', 'zip', etc.
  final String size;
  final String folderName;
  final String uploadedBy;
  final String uploadedDate;
  final String lastModified;
  final String status; // 'Public', 'HR Only', 'Team'
  final String filePath;
  final String description;

  AppDocument({
    required this.id,
    required this.name,
    required this.type,
    required this.size,
    required this.folderName,
    required this.uploadedBy,
    required this.uploadedDate,
    required this.lastModified,
    required this.status,
    required this.filePath,
    required this.description,
  });

  AppDocument copyWith({
    String? id,
    String? name,
    String? type,
    String? size,
    String? folderName,
    String? uploadedBy,
    String? uploadedDate,
    String? lastModified,
    String? status,
    String? filePath,
    String? description,
  }) {
    return AppDocument(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      size: size ?? this.size,
      folderName: folderName ?? this.folderName,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      uploadedDate: uploadedDate ?? this.uploadedDate,
      lastModified: lastModified ?? this.lastModified,
      status: status ?? this.status,
      filePath: filePath ?? this.filePath,
      description: description ?? this.description,
    );
  }
}

class DocumentFolder {
  final String id;
  final String name;
  final int fileCount;

  DocumentFolder({
    required this.id,
    required this.name,
    required this.fileCount,
  });

  DocumentFolder copyWith({
    String? id,
    String? name,
    int? fileCount,
  }) {
    return DocumentFolder(
      id: id ?? this.id,
      name: name ?? this.name,
      fileCount: fileCount ?? this.fileCount,
    );
  }
}

class DocumentAccess {
  final String id;
  final String name;
  final String details; // e.g. email or employee count
  final String role; // 'Viewer', 'Editor'
  final String? avatarUrl;
  final String type; // 'Group', 'Department', 'Individual'

  DocumentAccess({
    required this.id,
    required this.name,
    required this.details,
    required this.role,
    this.avatarUrl,
    required this.type,
  });

  DocumentAccess copyWith({
    String? id,
    String? name,
    String? details,
    String? role,
    String? avatarUrl,
    String? type,
  }) {
    return DocumentAccess(
      id: id ?? this.id,
      name: name ?? this.name,
      details: details ?? this.details,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      type: type ?? this.type,
    );
  }
}

class DocumentVersion {
  final String version;
  final String updatedDate;
  final String updatedBy;
  final String changeLog;

  DocumentVersion({
    required this.version,
    required this.updatedDate,
    required this.updatedBy,
    required this.changeLog,
  });
}

class DocumentActivity {
  final String id;
  final String activity;
  final String user;
  final String timestamp;
  final String iconType; // 'view', 'download', 'share', 'update'

  DocumentActivity({
    required this.id,
    required this.activity,
    required this.user,
    required this.timestamp,
    required this.iconType,
  });
}
