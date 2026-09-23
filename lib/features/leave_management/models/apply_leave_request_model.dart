import 'dart:io';
import 'package:dio/dio.dart';

class ApplyLeaveRequestModel {
  final int leaveTypeId;
  final String fromDate; // YYYY-MM-DD
  final String toDate; // YYYY-MM-DD
  final String session; // Full Day, 1st Half, 2nd Half
  final String reason;
  final String? contactDuringLeave;
  final String? addressDuringLeave;
  final int? assignedToUserId;
  final String? attachmentPath;

  ApplyLeaveRequestModel({
    required this.leaveTypeId,
    required this.fromDate,
    required this.toDate,
    this.session = 'Full Day',
    required this.reason,
    this.contactDuringLeave,
    this.addressDuringLeave,
    this.assignedToUserId,
    this.attachmentPath,
  });

  Map<String, dynamic> toJson() {
    return {
      'leave_type_id': leaveTypeId.toString(),
      'from_date': fromDate,
      'to_date': toDate,
      'session': session,
      'reason': reason,
      if (contactDuringLeave != null && contactDuringLeave!.isNotEmpty)
        'contact_during_leave': contactDuringLeave,
      if (addressDuringLeave != null && addressDuringLeave!.isNotEmpty)
        'address_during_leave': addressDuringLeave,
      if (assignedToUserId != null)
        'assigned_to_user_id': assignedToUserId.toString(),
    };
  }

  Future<FormData> toFormData() async {
    final Map<String, dynamic> map = {
      'leave_type_id': leaveTypeId.toString(),
      'from_date': fromDate,
      'to_date': toDate,
      'session': session,
      'reason': reason,
      if (contactDuringLeave != null && contactDuringLeave!.isNotEmpty)
        'contact_during_leave': contactDuringLeave!,
      if (addressDuringLeave != null && addressDuringLeave!.isNotEmpty)
        'address_during_leave': addressDuringLeave!,
      if (assignedToUserId != null)
        'assigned_to_user_id': assignedToUserId.toString(),
    };

    final formData = FormData.fromMap(map);

    if (attachmentPath != null && attachmentPath!.isNotEmpty) {
      final file = File(attachmentPath!);
      if (await file.exists()) {
        final filename = attachmentPath!.split(Platform.pathSeparator).last;
        formData.files.add(
          MapEntry(
            'attachment',
            await MultipartFile.fromFile(
              attachmentPath!,
              filename: filename,
            ),
          ),
        );
      }
    }

    return formData;
  }
}
