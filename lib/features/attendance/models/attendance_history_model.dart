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
  });

  // Helper getter to determine if the day has check-in data
  bool get hasCheckIn => checkIn != '--:-- --' && checkIn != '--';
}
