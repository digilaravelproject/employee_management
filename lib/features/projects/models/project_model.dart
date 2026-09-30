import '../../role_permissions/models/role_permission_models.dart';

class ProjectSubModule {
  final String id;
  final String name;
  final String description;

  const ProjectSubModule({
    required this.id,
    required this.name,
    this.description = '',
  });

  ProjectSubModule copyWith({
    String? id,
    String? name,
    String? description,
  }) {
    return ProjectSubModule(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }
}

class ProjectModule {
  final String id;
  final String name;
  final String description;
  final List<ProjectSubModule> subModules;

  const ProjectModule({
    required this.id,
    required this.name,
    this.description = '',
    this.subModules = const [],
  });

  ProjectModule copyWith({
    String? id,
    String? name,
    String? description,
    List<ProjectSubModule>? subModules,
  }) {
    return ProjectModule(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      subModules: subModules ?? this.subModules,
    );
  }
}

class ProjectTask {
  final String id;
  final String title;
  final String category; // e.g. Design, Development, Testing
  String status;         // To Do, In Progress, Review, Done
  final DateTime dueDate;
  final AppUser? assignee;
  final String moduleName;
  final String subModuleName;

  ProjectTask({
    required this.id,
    required this.title,
    required this.category,
    this.status = 'To Do',
    required this.dueDate,
    this.assignee,
    this.moduleName = 'General',
    this.subModuleName = 'Default',
  });

  ProjectTask copyWith({
    String? id,
    String? title,
    String? category,
    String? status,
    DateTime? dueDate,
    AppUser? assignee,
    String? moduleName,
    String? subModuleName,
  }) {
    return ProjectTask(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      assignee: assignee ?? this.assignee,
      moduleName: moduleName ?? this.moduleName,
      subModuleName: subModuleName ?? this.subModuleName,
    );
  }
}

class ProjectTimelineEvent {
  final String id;
  final String title;
  final String subtitle;
  final DateTime date;
  final bool isCompleted;
  final String? actorName;

  const ProjectTimelineEvent({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.date,
    this.isCompleted = false,
    this.actorName,
  });
}

class ProjectFile {
  final String id;
  final String name;
  final double sizeMb;
  final String type; // PDF, FIG, PNG, etc.
  final String? url;
  final String? uploadedByName;
  final String? createdAt;
  final String? localPath;

  const ProjectFile({
    required this.id,
    required this.name,
    required this.sizeMb,
    required this.type,
    this.url,
    this.uploadedByName,
    this.createdAt,
    this.localPath,
  });

  bool get isPdf {
    final t = type.toLowerCase();
    final n = name.toLowerCase();
    return t == 'pdf' || n.endsWith('.pdf');
  }

  bool get isImage {
    final t = type.toLowerCase();
    final n = name.toLowerCase();
    return ['png', 'jpg', 'jpeg', 'webp', 'gif', 'bmp', 'svg'].contains(t) ||
        n.endsWith('.png') ||
        n.endsWith('.jpg') ||
        n.endsWith('.jpeg') ||
        n.endsWith('.webp') ||
        n.endsWith('.gif') ||
        n.endsWith('.bmp') ||
        n.endsWith('.svg');
  }
}

class Project {
  final String id;
  final String name;
  final String description;
  final String category; // e.g. Web Development
  final String status;   // Not Started, In Progress, On Hold, Completed, Review
  final DateTime startDate;
  final DateTime endDate;
  final List<AppUser> teamMembers;
  final List<ProjectTask> tasks;
  final List<ProjectTimelineEvent> timeline;
  final List<ProjectFile> files;
  final List<ProjectModule> modules;
  final double? progress;
  final int? membersCount;
  final int? filesCount;

  const Project({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.status = 'Not Started',
    required this.startDate,
    required this.endDate,
    required this.teamMembers,
    required this.tasks,
    required this.timeline,
    required this.files,
    this.modules = const [],
    this.progress,
    this.membersCount,
    this.filesCount,
  });

  // Dynamic progress calculation based on tasks or API progress field
  double get progressPercentage {
    if (tasks.isNotEmpty) {
      final doneCount = tasks.where((task) => task.status == 'Done' || task.status == 'Completed').length;
      return (doneCount / tasks.length);
    }
    if (progress != null) {
      return progress! > 1.0 ? (progress! / 100.0).clamp(0.0, 1.0) : progress!.clamp(0.0, 1.0);
    }
    return 0.0;
  }

  Project copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    List<AppUser>? teamMembers,
    List<ProjectTask>? tasks,
    List<ProjectTimelineEvent>? timeline,
    List<ProjectFile>? files,
    List<ProjectModule>? modules,
    double? progress,
    int? membersCount,
    int? filesCount,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      teamMembers: teamMembers ?? this.teamMembers,
      tasks: tasks ?? this.tasks,
      timeline: timeline ?? this.timeline,
      files: files ?? this.files,
      modules: modules ?? this.modules,
      progress: progress ?? this.progress,
      membersCount: membersCount ?? this.membersCount,
      filesCount: filesCount ?? this.filesCount,
    );
  }
}

