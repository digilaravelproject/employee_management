import '../../role_permissions/models/role_permission_models.dart';

class ProjectTask {
  final String id;
  final String title;
  final String category; // e.g. Design, Development, Testing
  String status;         // To Do, In Progress, Review, Done
  final DateTime dueDate;
  final AppUser? assignee;

  ProjectTask({
    required this.id,
    required this.title,
    required this.category,
    this.status = 'To Do',
    required this.dueDate,
    this.assignee,
  });

  ProjectTask copyWith({
    String? id,
    String? title,
    String? category,
    String? status,
    DateTime? dueDate,
    AppUser? assignee,
  }) {
    return ProjectTask(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      assignee: assignee ?? this.assignee,
    );
  }
}

class ProjectTimelineEvent {
  final String id;
  final String title;
  final String subtitle;
  final DateTime date;
  final bool isCompleted;

  const ProjectTimelineEvent({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.date,
    this.isCompleted = false,
  });
}

class ProjectFile {
  final String id;
  final String name;
  final double sizeMb;
  final String type; // PDF, FIG, PNG, etc.

  const ProjectFile({
    required this.id,
    required this.name,
    required this.sizeMb,
    required this.type,
  });
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
  });

  // Dynamic progress calculation based on tasks
  double get progressPercentage {
    if (tasks.isEmpty) return 0.0;
    final doneCount = tasks.where((task) => task.status == 'Done' || task.status == 'Completed').length;
    return (doneCount / tasks.length);
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
    );
  }
}
