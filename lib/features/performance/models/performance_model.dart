import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';

class EmployeePerformance {
  final String id;
  final String name;
  final String designation;
  final String department;
  final int performanceScore;
  final String ratingLabel;
  final String imageUrl;
  final int rank;
  final String? employeeCode;
  final String? email;
  final String? team;
  final num? rawScore;
  final Map<String, dynamic>? metricsData;
  final Map<String, dynamic>? sourceCountsData;

  EmployeePerformance({
    required this.id,
    required this.name,
    required this.designation,
    required this.department,
    required this.performanceScore,
    required this.ratingLabel,
    required this.imageUrl,
    required this.rank,
    this.employeeCode,
    this.email,
    this.team,
    this.rawScore,
    this.metricsData,
    this.sourceCountsData,
  });

  static String resolveAvatarUrl(String? url) {
    if (url == null || url.trim().isEmpty) return '';
    var p = url.trim();
    if (p.contains('127.0.0.1:8000') || p.contains('localhost:8000')) {
      p = p
          .replaceFirst('http://127.0.0.1:8000', AppConstants.baseUrl)
          .replaceFirst('http://localhost:8000', AppConstants.baseUrl);
    }
    if (p.startsWith('http://') || p.startsWith('https://')) {
      return p;
    }
    final base = AppConstants.baseUrl.endsWith('/')
        ? AppConstants.baseUrl.substring(0, AppConstants.baseUrl.length - 1)
        : AppConstants.baseUrl;
    if (p.startsWith('/')) {
      return '$base$p';
    } else if (p.startsWith('storage/')) {
      return '$base/$p';
    } else {
      return '$base/storage/$p';
    }
  }

  factory EmployeePerformance.fromApiJson(Map<String, dynamic> json) {
    final empJson = json['employee'] is Map<String, dynamic>
        ? json['employee'] as Map<String, dynamic>
        : <String, dynamic>{};

    final id = empJson['id']?.toString() ?? json['id']?.toString() ?? '0';
    final name = empJson['name']?.toString() ?? 'Unknown Employee';
    final designation = empJson['designation']?.toString() ?? '';
    final department = empJson['department']?.toString() ?? '';
    final rawAvatar = empJson['avatar']?.toString() ?? '';
    final imageUrl = resolveAvatarUrl(rawAvatar);

    final rawScoreNum = json['score'] is num ? (json['score'] as num) : null;
    final int score = rawScoreNum?.round() ?? 0;
    final eval = json['evaluation']?.toString() ?? (rawScoreNum != null ? 'Rated' : 'Not Rated');
    final rank = int.tryParse(json['rank']?.toString() ?? '1') ?? 1;

    return EmployeePerformance(
      id: id,
      name: name,
      designation: designation.isNotEmpty ? designation : (department.isNotEmpty ? department : 'Employee'),
      department: department.isNotEmpty ? department : 'General',
      performanceScore: score,
      ratingLabel: eval,
      imageUrl: imageUrl,
      rank: rank,
      employeeCode: empJson['employee_id']?.toString(),
      email: empJson['email']?.toString(),
      team: empJson['team']?.toString(),
      rawScore: rawScoreNum,
      metricsData: json['metrics'] is Map<String, dynamic> ? json['metrics'] as Map<String, dynamic> : null,
      sourceCountsData: json['source_counts'] is Map<String, dynamic> ? json['source_counts'] as Map<String, dynamic> : null,
    );
  }
}

class PerformanceSummaryModel {
  final int totalEmployees;
  final int ratedEmployees;
  final num averagePerformance;
  final PerformanceTopPerformerModel? topPerformer;

  PerformanceSummaryModel({
    this.totalEmployees = 0,
    this.ratedEmployees = 0,
    this.averagePerformance = 0,
    this.topPerformer,
  });

  factory PerformanceSummaryModel.fromJson(Map<String, dynamic> json) {
    return PerformanceSummaryModel(
      totalEmployees: int.tryParse(json['total_employees']?.toString() ?? '0') ?? 0,
      ratedEmployees: int.tryParse(json['rated_employees']?.toString() ?? '0') ?? 0,
      averagePerformance: num.tryParse(json['average_performance']?.toString() ?? '0') ?? 0,
      topPerformer: json['top_performer'] is Map<String, dynamic>
          ? PerformanceTopPerformerModel.fromJson(json['top_performer'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_employees': totalEmployees,
      'rated_employees': ratedEmployees,
      'average_performance': averagePerformance,
      if (topPerformer != null) 'top_performer': topPerformer!.toJson(),
    };
  }
}

class PerformanceTopPerformerModel {
  final String id;
  final String name;
  final String avatar;
  final String designation;
  final String department;
  final num score;

  PerformanceTopPerformerModel({
    required this.id,
    required this.name,
    required this.avatar,
    this.designation = '',
    this.department = '',
    this.score = 0,
  });

  factory PerformanceTopPerformerModel.fromJson(Map<String, dynamic> json) {
    final emp = json['employee'] is Map<String, dynamic>
        ? json['employee'] as Map<String, dynamic>
        : <String, dynamic>{};
    return PerformanceTopPerformerModel(
      id: emp['id']?.toString() ?? '',
      name: emp['name']?.toString() ?? 'N/A',
      avatar: EmployeePerformance.resolveAvatarUrl(emp['avatar']?.toString()),
      designation: emp['designation']?.toString() ?? '',
      department: emp['department']?.toString() ?? '',
      score: num.tryParse(json['score']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employee': {
        'id': id,
        'name': name,
        'avatar': avatar,
        'designation': designation,
        'department': department,
      },
      'score': score,
    };
  }
}

class PerformanceMetric {
  final String name;
  final String label;
  final double progress; // 0.0 to 1.0
  final IconData icon;
  final Color accentColor;
  final Color bgLightColor;

  PerformanceMetric({
    required this.name,
    required this.label,
    required this.progress,
    required this.icon,
    required this.accentColor,
    required this.bgLightColor,
  });
}

class PerformanceTarget {
  final String id;
  final String title;
  final String description;
  final String targetValue;
  final String achievedValue;
  final double progress; // 0.0 to 1.0
  final String status; // 'On Track', 'In Progress', 'Completed'
  final String frequency; // 'Monthly'
  final DateTime dueDate;
  final bool isCompleted;
  final String goalType;
  final DateTime assignedOn;
  final String assignedByName;
  final String assignedByImage;
  final int estimatedIncentive;
  final Map<String, double> progressHistory; // e.g. {"May 1": 20, "May 8": 40, ...}

  PerformanceTarget({
    required this.id,
    required this.title,
    required this.description,
    required this.targetValue,
    required this.achievedValue,
    required this.progress,
    required this.status,
    required this.frequency,
    required this.dueDate,
    this.isCompleted = false,
    required this.goalType,
    required this.assignedOn,
    required this.assignedByName,
    required this.assignedByImage,
    required this.estimatedIncentive,
    required this.progressHistory,
  });

  PerformanceTarget copyWith({
    String? achievedValue,
    double? progress,
    String? status,
    bool? isCompleted,
    Map<String, double>? progressHistory,
  }) {
    return PerformanceTarget(
      id: id,
      title: title,
      description: description,
      targetValue: targetValue,
      achievedValue: achievedValue ?? this.achievedValue,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      frequency: frequency,
      dueDate: dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      goalType: goalType,
      assignedOn: assignedOn,
      assignedByName: assignedByName,
      assignedByImage: assignedByImage,
      estimatedIncentive: estimatedIncentive,
      progressHistory: progressHistory ?? this.progressHistory,
    );
  }
}
