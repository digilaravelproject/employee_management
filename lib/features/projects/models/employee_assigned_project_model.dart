import '../../../core/constants/app_constants.dart';
import '../../role_permissions/models/role_permission_models.dart';
import 'create_project_model.dart';
import 'project_model.dart';

class EmployeeAssignedProjectResponseModel {
  final bool status;
  final String message;
  final int total;
  final List<EmployeeAssignedProjectItem> data;
  final EmployeeAssignedPagination? pagination;

  EmployeeAssignedProjectResponseModel({
    required this.status,
    required this.message,
    required this.total,
    required this.data,
    this.pagination,
  });

  factory EmployeeAssignedProjectResponseModel.fromJson(Map<String, dynamic> json) {
    // Robust parsing for projects list
    List<EmployeeAssignedProjectItem> items = [];
    if (json['data'] is List) {
      items = (json['data'] as List)
          .whereType<Map>()
          .map((e) => EmployeeAssignedProjectItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } else if (json['projects'] is List) {
      items = (json['projects'] as List)
          .whereType<Map>()
          .map((e) => EmployeeAssignedProjectItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    // Robust parsing for pagination
    EmployeeAssignedPagination? pag;
    if (json['pagination'] is Map) {
      pag = EmployeeAssignedPagination.fromJson(Map<String, dynamic>.from(json['pagination']));
    } else if (json['meta'] is Map) {
      pag = EmployeeAssignedPagination.fromJson(Map<String, dynamic>.from(json['meta']));
    } else if (json.containsKey('current_page') || json.containsKey('last_page')) {
      pag = EmployeeAssignedPagination.fromJson(json);
    }

    int totalCount = _parseInt(json['total']);
    if (totalCount == 0 && pag != null) {
      totalCount = pag.total;
    }
    if (totalCount == 0) {
      totalCount = items.length;
    }

    return EmployeeAssignedProjectResponseModel(
      status: json['status'] == true ||
          json['status'] == 1 ||
          json['status']?.toString().toLowerCase() == 'true',
      message: json['message']?.toString() ?? '',
      total: totalCount,
      data: items,
      pagination: pag,
    );
  }
}

class EmployeeAssignedPagination {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  EmployeeAssignedPagination({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  bool get hasMore => currentPage < lastPage;

  factory EmployeeAssignedPagination.fromJson(Map<String, dynamic> json) {
    return EmployeeAssignedPagination(
      currentPage: _parseInt(json['current_page'] ?? json['currentPage'] ?? 1),
      lastPage: _parseInt(json['last_page'] ?? json['lastPage'] ?? 1),
      perPage: _parseInt(json['per_page'] ?? json['perPage'] ?? 20),
      total: _parseInt(json['total'] ?? 0),
    );
  }
}

class EmployeeAssignedProjectItem {
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
  final int tasksCount;
  final int completedTasksCount;
  final List<ProjectTeamMember> team;
  final List<ProjectFileItemModel> files;

  EmployeeAssignedProjectItem({
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
    this.tasksCount = 0,
    this.completedTasksCount = 0,
    required this.team,
    required this.files,
  });

  int get progressPercent {
    if (progress <= 1.0 && progress > 0) {
      return (progress * 100).toInt();
    }
    return progress.toInt().clamp(0, 100);
  }

  factory EmployeeAssignedProjectItem.fromJson(Map<String, dynamic> json) {
    return EmployeeAssignedProjectItem(
      id: _parseInt(json['id']),
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? 'General',
      startDate: json['start_date']?.toString() ?? '',
      endDate: json['end_date']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Not Started',
      progress: _parseNum(json['progress']),
      membersCount: _parseInt(json['members_count']),
      filesCount: _parseInt(json['files_count']),
      tasksCount: _parseInt(json['tasks_count']),
      completedTasksCount: _parseInt(json['completed_tasks_count']),
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
    );
  }

  /// Converts this model to the domain [Project] model for ProjectDetailsScreen
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

    return Project(
      id: id.toString(),
      name: name,
      description: description,
      category: category,
      status: status,
      startDate: start,
      endDate: end,
      teamMembers: teamAppUsers,
      tasks: const [],
      timeline: const [],
      files: projectFiles,
      modules: const [],
      progress: progress.toDouble(),
      membersCount: membersCount > 0 ? membersCount : team.length,
      filesCount: filesCount > 0 ? filesCount : files.length,
    );
  }
}

int _parseInt(dynamic val) {
  if (val is int) return val;
  if (val != null) return int.tryParse(val.toString()) ?? 0;
  return 0;
}

num _parseNum(dynamic val) {
  if (val is num) return val;
  if (val != null) return num.tryParse(val.toString()) ?? 0;
  return 0;
}
