class CallLog {
  final String id;
  final String clientName;
  final String type; // Outgoing, Incoming, Missed
  final String employeeName;
  final String timeStr;
  final String durationStr;

  CallLog({
    required this.id,
    required this.clientName,
    required this.type,
    required this.employeeName,
    required this.timeStr,
    required this.durationStr,
  });
}

class FollowupMeeting {
  final String id;
  final String title;
  final String clientName;
  final String employeeName;
  final DateTime dateTime;
  final String duration;
  final String mode; // Office, Online
  final String notes;

  FollowupMeeting({
    required this.id,
    required this.title,
    required this.clientName,
    required this.employeeName,
    required this.dateTime,
    required this.duration,
    required this.mode,
    required this.notes,
  });
}

class FollowupReminder {
  final String id;
  final String title;
  final String category; // Call, Meeting, Task, Follow-up
  final DateTime dateTime;
  final String employeeName;
  final bool isCompleted;

  FollowupReminder({
    required this.id,
    required this.title,
    required this.category,
    required this.dateTime,
    required this.employeeName,
    this.isCompleted = false,
  });

  FollowupReminder copyWith({
    String? id,
    String? title,
    String? category,
    DateTime? dateTime,
    String? employeeName,
    bool? isCompleted,
  }) {
    return FollowupReminder(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      dateTime: dateTime ?? this.dateTime,
      employeeName: employeeName ?? this.employeeName,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class ActivityNote {
  final String id;
  final String clientName;
  final String title;
  final String note;
  final DateTime dateTime;
  final String employeeName;

  ActivityNote({
    required this.id,
    required this.clientName,
    required this.title,
    required this.note,
    required this.dateTime,
    required this.employeeName,
  });
}
