import 'package:flutter/material.dart';

class EmployeePerformance {
  final String id;
  final String name;
  final String designation;
  final String department;
  final int performanceScore;
  final String ratingLabel;
  final String imageUrl;
  final int rank;

  EmployeePerformance({
    required this.id,
    required this.name,
    required this.designation,
    required this.department,
    required this.performanceScore,
    required this.ratingLabel,
    required this.imageUrl,
    required this.rank,
  });
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
