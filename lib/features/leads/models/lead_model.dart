import '../../role_permissions/models/role_permission_models.dart';

class LeadFollowUp {
  final String id;
  final String title;
  final String content;
  final DateTime dateTime;
  final String representative;
  final bool isCompleted;
  final String type; // call, proposal, note, email, whatsapp

  const LeadFollowUp({
    required this.id,
    required this.title,
    required this.content,
    required this.dateTime,
    required this.representative,
    this.isCompleted = false,
    required this.type,
  });

  LeadFollowUp copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? dateTime,
    String? representative,
    bool? isCompleted,
    String? type,
  }) {
    return LeadFollowUp(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      dateTime: dateTime ?? this.dateTime,
      representative: representative ?? this.representative,
      isCompleted: isCompleted ?? this.isCompleted,
      type: type ?? this.type,
    );
  }
}

class Lead {
  final String id;
  final String name;
  final String companyName;
  final String email;
  final String mobile;
  final String designation;
  final String leadSource; // e.g. Website, Google Ads, Referral, Facebook Ads
  final String leadStatus; // e.g. New, Contacted, Converted
  final int leadScore; // out of 100
  final AppUser assignedTo;
  final String location;
  final double estimatedValue;
  final DateTime expectedClosingDate;
  final String notes;
  final DateTime createdOn;
  final List<LeadFollowUp> followUps;
  
  // New Conversion logs for Converted Customers List
  final double? dealValue;
  final DateTime? conversionDate;
  final String? conversionNotes;

  const Lead({
    required this.id,
    required this.name,
    required this.companyName,
    required this.email,
    required this.mobile,
    required this.designation,
    required this.leadSource,
    required this.leadStatus,
    required this.leadScore,
    required this.assignedTo,
    required this.location,
    required this.estimatedValue,
    required this.expectedClosingDate,
    required this.notes,
    required this.createdOn,
    required this.followUps,
    this.dealValue,
    this.conversionDate,
    this.conversionNotes,
  });

  Lead copyWith({
    String? id,
    String? name,
    String? companyName,
    String? email,
    String? mobile,
    String? designation,
    String? leadSource,
    String? leadStatus,
    int? leadScore,
    AppUser? assignedTo,
    String? location,
    double? estimatedValue,
    DateTime? expectedClosingDate,
    String? notes,
    DateTime? createdOn,
    List<LeadFollowUp>? followUps,
    double? dealValue,
    DateTime? conversionDate,
    String? conversionNotes,
  }) {
    return Lead(
      id: id ?? this.id,
      name: name ?? this.name,
      companyName: companyName ?? this.companyName,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      designation: designation ?? this.designation,
      leadSource: leadSource ?? this.leadSource,
      leadStatus: leadStatus ?? this.leadStatus,
      leadScore: leadScore ?? this.leadScore,
      assignedTo: assignedTo ?? this.assignedTo,
      location: location ?? this.location,
      estimatedValue: estimatedValue ?? this.estimatedValue,
      expectedClosingDate: expectedClosingDate ?? this.expectedClosingDate,
      notes: notes ?? this.notes,
      createdOn: createdOn ?? this.createdOn,
      followUps: followUps ?? this.followUps,
      dealValue: dealValue ?? this.dealValue,
      conversionDate: conversionDate ?? this.conversionDate,
      conversionNotes: conversionNotes ?? this.conversionNotes,
    );
  }
}
