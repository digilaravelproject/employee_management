import 'package:dio/dio.dart';
import '../../../core/constants/app_constants.dart';
import '../../employee/management/models/employee_model.dart';
import '../../role_permissions/models/role_permission_models.dart';
import 'project_model.dart';

class CreateProjectRequestModel {
  final String name;
  final String description;
  final String category;
  final String startDate; // yyyy-MM-dd
  final String endDate;   // yyyy-MM-dd
  final String status;
  final num progress;
  final List<String> employeeIds;
  final List<String> filePaths;

  CreateProjectRequestModel({
    required this.name,
    required this.description,
    required this.category,
    required this.startDate,
    required this.endDate,
    this.status = 'Not Started',
    this.progress = 0,
    required this.employeeIds,
    this.filePaths = const [],
  });

  Future<FormData> toFormData() async {
    final formData = FormData();

    formData.fields.add(MapEntry('name', name));
    formData.fields.add(MapEntry('description', description));
    formData.fields.add(MapEntry('category', category));
    formData.fields.add(MapEntry('start_date', startDate));
    formData.fields.add(MapEntry('end_date', endDate));
    formData.fields.add(MapEntry('status', status));
    formData.fields.add(MapEntry('progress', progress.toString()));

    for (final id in employeeIds) {
      if (id.trim().isNotEmpty) {
        formData.fields.add(MapEntry('employee_ids[]', id.trim()));
      }
    }

    for (int i = 0; i < filePaths.length; i++) {
      final path = filePaths[i];
      if (path.isNotEmpty) {
        final fileName = path.split('/').last;
        formData.files.add(
          MapEntry(
            'files[$i]',
            await MultipartFile.fromFile(path, filename: fileName),
          ),
        );
      }
    }

    return formData;
  }
}

class UpdateProjectRequestModel {
  final String name;
  final String status;
  final num progress;
  final List<dynamic> employeeIds;
  final String? description;
  final String? category;
  final String? startDate;
  final String? endDate;

  UpdateProjectRequestModel({
    required this.name,
    required this.status,
    required this.progress,
    required this.employeeIds,
    this.description,
    this.category,
    this.startDate,
    this.endDate,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {
      'name': name,
      'status': status,
      'progress': progress,
      'employee_ids': employeeIds,
    };
    if (description != null && description!.isNotEmpty) {
      map['description'] = description;
    }
    if (category != null && category!.isNotEmpty) {
      map['category'] = category;
    }
    if (startDate != null && startDate!.isNotEmpty) {
      map['start_date'] = startDate;
    }
    if (endDate != null && endDate!.isNotEmpty) {
      map['end_date'] = endDate;
    }
    return map;
  }
}

class CreateProjectResponseModel {
  final bool status;
  final String message;
  final ProjectApiData? data;

  CreateProjectResponseModel({
    required this.status,
    required this.message,
    this.data,
  });

  factory CreateProjectResponseModel.fromJson(Map<String, dynamic> json) {
    return CreateProjectResponseModel(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      data: json['data'] is Map<String, dynamic>
          ? ProjectApiData.fromJson(Map<String, dynamic>.from(json['data']))
          : (json['data'] is Map
              ? ProjectApiData.fromJson(Map<String, dynamic>.from(json['data']))
              : null),
    );
  }
}

class ProjectCreatedBy {
  final int id;
  final String name;
  final String email;
  final String role;

  ProjectCreatedBy({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory ProjectCreatedBy.fromJson(Map<String, dynamic> json) {
    return ProjectCreatedBy(
      id: _parseInt(json['id']),
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
    );
  }
}

class ProjectStatusTrackItem {
  final String status;
  final bool isCurrent;
  final bool isCompleted;

  ProjectStatusTrackItem({
    required this.status,
    required this.isCurrent,
    required this.isCompleted,
  });

  factory ProjectStatusTrackItem.fromJson(Map<String, dynamic> json) {
    return ProjectStatusTrackItem(
      status: json['status']?.toString() ?? '',
      isCurrent: json['is_current'] == true,
      isCompleted: json['is_completed'] == true,
    );
  }
}

class ProjectOverviewData {
  final String description;
  final String startDate;
  final String endDate;
  final String status;
  final num progress;
  final List<ProjectStatusTrackItem> statusTrack;

  ProjectOverviewData({
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.progress,
    required this.statusTrack,
  });

  factory ProjectOverviewData.fromJson(Map<String, dynamic> json) {
    return ProjectOverviewData(
      description: json['description']?.toString() ?? '',
      startDate: json['start_date']?.toString() ?? '',
      endDate: json['end_date']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      progress: _parseNum(json['progress']),
      statusTrack: json['status_track'] is List
          ? (json['status_track'] as List)
              .whereType<Map>()
              .map((e) => ProjectStatusTrackItem.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : [],
    );
  }
}

class ProjectTasksSummary {
  final int total;
  final int completed;
  final int inProgress;
  final int testing;
  final int toDo;

  ProjectTasksSummary({
    required this.total,
    required this.completed,
    required this.inProgress,
    required this.testing,
    required this.toDo,
  });

  factory ProjectTasksSummary.fromJson(Map<String, dynamic> json) {
    return ProjectTasksSummary(
      total: _parseInt(json['total']),
      completed: _parseInt(json['completed']),
      inProgress: _parseInt(json['in_progress']),
      testing: _parseInt(json['testing']),
      toDo: _parseInt(json['to_do']),
    );
  }
}

class ProjectTasksData {
  final bool isStatic;
  final String message;
  final ProjectTasksSummary? summary;
  final List<dynamic> items;

  ProjectTasksData({
    required this.isStatic,
    required this.message,
    this.summary,
    required this.items,
  });

  factory ProjectTasksData.fromJson(Map<String, dynamic> json) {
    return ProjectTasksData(
      isStatic: json['is_static'] == true,
      message: json['message']?.toString() ?? '',
      summary: json['summary'] is Map
          ? ProjectTasksSummary.fromJson(Map<String, dynamic>.from(json['summary']))
          : null,
      items: json['items'] is List ? (json['items'] as List) : [],
    );
  }
}

class ProjectApiData {
  final int id;
  final String name;
  final String description;
  final String category;
  final String startDate;
  final String endDate;
  final String status;
  final num progress;
  final int membersCount;
  final int filesCount;
  final List<ProjectTeamMember> team;
  final List<ProjectFileItemModel> files;
  final List<ProjectTimelineItemModel> timeline;
  final ProjectCreatedBy? createdBy;
  final ProjectOverviewData? overview;
  final ProjectTasksData? tasksData;
  final String createdAt;
  final String updatedAt;

  ProjectApiData({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.progress,
    required this.membersCount,
    required this.filesCount,
    required this.team,
    required this.files,
    required this.timeline,
    this.createdBy,
    this.overview,
    this.tasksData,
    this.createdAt = '',
    this.updatedAt = '',
  });

  factory ProjectApiData.fromJson(Map<String, dynamic> json) {
    return ProjectApiData(
      id: _parseInt(json['id']),
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Web Development',
      startDate: json['start_date']?.toString() ?? '',
      endDate: json['end_date']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Not Started',
      progress: _parseNum(json['progress']),
      membersCount: _parseInt(json['members_count']),
      filesCount: _parseInt(json['files_count']),
      team: json['team'] is List
          ? (json['team'] as List)
              .whereType<Map>()
              .map((e) => ProjectTeamMember.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : [],
      files: json['files'] is List
          ? (json['files'] as List)
              .whereType<Map>()
              .map((e) => ProjectFileItemModel.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : [],
      timeline: json['timeline'] is List
          ? (json['timeline'] as List)
              .whereType<Map>()
              .map((e) => ProjectTimelineItemModel.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : [],
      createdBy: json['created_by'] is Map
          ? ProjectCreatedBy.fromJson(Map<String, dynamic>.from(json['created_by']))
          : null,
      overview: json['overview'] is Map
          ? ProjectOverviewData.fromJson(Map<String, dynamic>.from(json['overview']))
          : null,
      tasksData: json['tasks'] is Map
          ? ProjectTasksData.fromJson(Map<String, dynamic>.from(json['tasks']))
          : null,
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }

  /// Converts API Data to Domain [Project] model
  Project toProject() {
    DateTime start = DateTime.tryParse(startDate) ?? DateTime.now();
    DateTime end = DateTime.tryParse(endDate) ?? DateTime.now().add(const Duration(days: 30));

    final teamAppUsers = team.map((t) {
      String avatar = t.avatar.trim();
      if (avatar.contains('127.0.0.1:8000') || avatar.contains('localhost:8000')) {
        avatar = avatar
            .replaceFirst('http://127.0.0.1:8000', AppConstants.baseUrl)
            .replaceFirst('https://127.0.0.1:8000', AppConstants.baseUrl)
            .replaceFirst('http://localhost:8000', AppConstants.baseUrl)
            .replaceFirst('https://localhost:8000', AppConstants.baseUrl);
      }
      return AppUser(
        name: t.name,
        email: t.email,
        avatarUrl: avatar.isNotEmpty
            ? avatar
            : 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
        designation: t.designation.isNotEmpty ? t.designation : null,
        employeeId: t.employeeId.isNotEmpty ? t.employeeId : null,
        status: t.status.isNotEmpty ? t.status : null,
      );
    }).toList();

    final projectFiles = files.map((f) {
      final ext = f.name.contains('.') ? f.name.split('.').last.toUpperCase() : 'FILE';
      final sizeMb = (f.size / (1024 * 1024)).toStringAsFixed(2);
      String fileUrl = f.url.trim();
      if (fileUrl.isNotEmpty) {
        if (fileUrl.contains('127.0.0.1:8000') || fileUrl.contains('localhost:8000')) {
          fileUrl = fileUrl
              .replaceFirst('http://127.0.0.1:8000', AppConstants.baseUrl)
              .replaceFirst('https://127.0.0.1:8000', AppConstants.baseUrl)
              .replaceFirst('http://localhost:8000', AppConstants.baseUrl)
              .replaceFirst('https://localhost:8000', AppConstants.baseUrl);
        } else if (!fileUrl.startsWith('http://') && !fileUrl.startsWith('https://')) {
          fileUrl = '${AppConstants.baseUrl}/${fileUrl.startsWith('/') ? fileUrl.substring(1) : fileUrl}';
        }
      }
      return ProjectFile(
        id: f.id.toString(),
        name: f.name,
        sizeMb: double.tryParse(sizeMb) ?? 0.0,
        type: ext,
        url: fileUrl.isNotEmpty ? fileUrl : null,
        uploadedByName: f.uploadedByName,
        createdAt: f.createdAt,
      );
    }).toList();

    final timelineEvents = timeline.map((tl) {
      DateTime dt = DateTime.tryParse(tl.eventAt) ?? DateTime.now();
      return ProjectTimelineEvent(
        id: tl.id.toString(),
        title: tl.event,
        subtitle: tl.description,
        date: dt,
        isCompleted: true,
        actorName: tl.actorName,
      );
    }).toList();

    return Project(
      id: id.toString(),
      name: name,
      description: description,
      category: category,
      status: status,
      startDate: start,
      endDate: end,
      teamMembers: teamAppUsers,
      tasks: [],
      timeline: timelineEvents.isNotEmpty
          ? timelineEvents
          : [
              ProjectTimelineEvent(
                id: 'tl_$id',
                title: 'Project Created',
                subtitle: 'Created via admin panel',
                date: start,
                isCompleted: true,
              )
            ],
      files: projectFiles,
      modules: const [],
      progress: progress.toDouble(),
      membersCount: membersCount > 0 ? membersCount : team.length,
      filesCount: filesCount > 0 ? filesCount : files.length,
    );
  }
}

class ProjectTeamMember {
  final int id;
  final String employeeId;
  final String name;
  final String email;
  final String designation;
  final String avatar;
  final String status;

  ProjectTeamMember({
    required this.id,
    required this.employeeId,
    required this.name,
    required this.email,
    required this.designation,
    required this.avatar,
    required this.status,
  });

  factory ProjectTeamMember.fromJson(Map<String, dynamic> json) {
    return ProjectTeamMember(
      id: _parseInt(json['id']),
      employeeId: json['employee_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      designation: json['designation']?.toString() ?? '',
      avatar: json['avatar']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Active',
    );
  }

  EmployeeModel toEmployeeModel() {
    return EmployeeModel(
      id: id.toString(),
      employeeId: employeeId,
      name: name,
      mobile: '',
      email: email,
      designation: designation,
      joiningDate: '',
      address: '',
      profilePic: avatar.isNotEmpty ? avatar : null,
      isActive: status.toLowerCase() == 'active',
      role: designation,
    );
  }
}

class ProjectFileItemModel {
  final int id;
  final String name;
  final String mimeType;
  final int size;
  final String url;
  final String uploadedByName;
  final String createdAt;

  ProjectFileItemModel({
    required this.id,
    required this.name,
    required this.mimeType,
    required this.size,
    required this.url,
    this.uploadedByName = '',
    this.createdAt = '',
  });

  factory ProjectFileItemModel.fromJson(Map<String, dynamic> json) {
    String uploader = '';
    if (json['uploaded_by'] is Map) {
      uploader = json['uploaded_by']['name']?.toString() ?? '';
    }
    return ProjectFileItemModel(
      id: _parseInt(json['id']),
      name: json['name']?.toString() ?? '',
      mimeType: json['mime_type']?.toString() ?? '',
      size: _parseInt(json['size']),
      url: json['url']?.toString() ?? '',
      uploadedByName: uploader,
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}

class ProjectTimelineItemModel {
  final int id;
  final String event;
  final String description;
  final String eventAt;
  final String actorName;

  ProjectTimelineItemModel({
    required this.id,
    required this.event,
    required this.description,
    required this.eventAt,
    this.actorName = '',
  });

  factory ProjectTimelineItemModel.fromJson(Map<String, dynamic> json) {
    String actor = '';
    if (json['actor'] is Map) {
      actor = json['actor']['name']?.toString() ?? '';
    }
    return ProjectTimelineItemModel(
      id: _parseInt(json['id']),
      event: json['event']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      eventAt: json['event_at']?.toString() ?? '',
      actorName: actor,
    );
  }
}

class ProjectDetailsResponseModel {
  final bool status;
  final String message;
  final ProjectApiData? data;

  ProjectDetailsResponseModel({
    required this.status,
    required this.message,
    this.data,
  });

  factory ProjectDetailsResponseModel.fromJson(Map<String, dynamic> json) {
    return ProjectDetailsResponseModel(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      data: json['data'] is Map ? ProjectApiData.fromJson(Map<String, dynamic>.from(json['data'])) : null,
    );
  }
}

num _parseNum(dynamic val) {
  if (val is num) return val;
  if (val != null) return num.tryParse(val.toString()) ?? 0;
  return 0;
}

int _parseInt(dynamic val) {
  if (val is int) return val;
  if (val != null) return int.tryParse(val.toString()) ?? 0;
  return 0;
}

class ProjectPaginationModel {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  ProjectPaginationModel({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory ProjectPaginationModel.fromJson(Map<String, dynamic> json) {
    return ProjectPaginationModel(
      currentPage: _parseInt(json['current_page']),
      lastPage: _parseInt(json['last_page']),
      perPage: _parseInt(json['per_page']),
      total: _parseInt(json['total']),
    );
  }
}

class ProjectListResponseModel {
  final bool status;
  final String message;
  final int total;
  final List<ProjectApiData> data;
  final ProjectPaginationModel? pagination;

  ProjectListResponseModel({
    required this.status,
    required this.message,
    required this.total,
    required this.data,
    this.pagination,
  });

  factory ProjectListResponseModel.fromJson(Map<String, dynamic> json) {
    return ProjectListResponseModel(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      total: _parseInt(json['total']),
      data: json['data'] is List
          ? (json['data'] as List)
              .whereType<Map>()
              .map((e) => ProjectApiData.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : [],
      pagination: json['pagination'] is Map
          ? ProjectPaginationModel.fromJson(Map<String, dynamic>.from(json['pagination']))
          : null,
    );
  }
}

class DeleteProjectResponseModel {
  final bool status;
  final String message;

  DeleteProjectResponseModel({
    required this.status,
    required this.message,
  });

  factory DeleteProjectResponseModel.fromJson(Map<String, dynamic> json) {
    return DeleteProjectResponseModel(
      status: json['status'] == true ||
          json['status'] == 1 ||
          json['status']?.toString().toLowerCase() == 'true',
      message: json['message']?.toString() ?? '',
    );
  }
}
