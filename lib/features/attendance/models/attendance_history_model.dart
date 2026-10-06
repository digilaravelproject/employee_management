class AttendanceRecord {
  final DateTime date;
  final String status; // 'Present', 'Half Day', 'Absent', 'Leave'
  final String checkIn;
  final String checkOut;
  final String workingHours;
  final String breakTime;
  final String lateBy;
  final String earlyLeave;
  final String location; // 'Office', 'Remote', etc.
  final String remarks;
  final bool isLate;

  const AttendanceRecord({
    required this.date,
    required this.status,
    required this.checkIn,
    required this.checkOut,
    required this.workingHours,
    required this.breakTime,
    required this.lateBy,
    required this.earlyLeave,
    required this.location,
    required this.remarks,
    this.isLate = false,
  });

  // Helper getter to determine if the day has check-in data
  bool get hasCheckIn => checkIn != '--:-- --' && checkIn != '--';

  // Helper getter to determine if there is a late indication
  bool get hasLateIndication =>
      isLate ||
      (lateBy != '--' &&
          lateBy != '0' &&
          lateBy.trim().isNotEmpty &&
          lateBy != '00m' &&
          lateBy != '0m') ||
      status.trim().toLowerCase().contains('late');
}
