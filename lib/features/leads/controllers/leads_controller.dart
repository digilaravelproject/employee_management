import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../role_permissions/models/role_permission_models.dart';
import '../models/lead_model.dart';

class LeadsController extends GetxController {
  // Main reactive leads state
  final leads = <Lead>[].obs;

  // Selected lead
  final selectedLead = Rxn<Lead>();

  // Leads navigation and tabs shell state
  final currentTabIdx = 0.obs; // 0 for Leads list/Kanban, 1 for Follow-ups, 2 for Customers
  final isKanbanView = false.obs; // toggle list vs. kanban view

  // Detail tab state (0 for Notes & Follow-ups, 1 for Activity Timeline)
  final selectedTabIdx = 0.obs;

  // Search filters
  final searchQuery = ''.obs;
  final selectedFilter = 'All'.obs; // All, New, Contacted, Converted

  // Dropdown option lists
  final List<String> leadSources = ['Website', 'Google Ads', 'Referral', 'Facebook Ads'];
  final List<String> leadStatuses = ['New', 'Contacted', 'Converted'];

  final List<AppUser> salesReps = [
    const AppUser(
      name: 'Rahul Sharma',
      email: 'rahul.sharma@company.com',
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&auto=format&fit=crop&q=80',
    ),
    const AppUser(
      name: 'Neha Verma',
      email: 'neha.verma@company.com',
      avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150&auto=format&fit=crop&q=80',
    ),
    const AppUser(
      name: 'Aman Khan',
      email: 'aman.khan@company.com',
      avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150&auto=format&fit=crop&q=80',
    ),
    const AppUser(
      name: 'Pooja Singh',
      email: 'pooja.singh@company.com',
      avatarUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150&auto=format&fit=crop&q=80',
    ),
  ];

  // Text Editing Controllers for Add / Edit Screen
  late TextEditingController nameController;
  late TextEditingController companyController;
  late TextEditingController emailController;
  late TextEditingController mobileController;
  late TextEditingController designationController;
  late TextEditingController locationController;
  late TextEditingController estimatedValueController;
  late TextEditingController notesController;

  // Conversion Text Controllers
  late TextEditingController conversionCompanyController;
  late TextEditingController conversionValueController;
  late TextEditingController conversionNotesController;

  // Dropdown states in form
  final selectedSource = Rxn<String>();
  final selectedStatus = Rxn<String>();
  final selectedAssignee = Rxn<AppUser>();
  final expectedClosingDate = Rxn<DateTime>();

  // Search salesperson state in assignment
  final salespersonSearchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeFormControllers();
    _seedDummyLeads();
  }

  void _initializeFormControllers() {
    nameController = TextEditingController();
    companyController = TextEditingController();
    emailController = TextEditingController();
    mobileController = TextEditingController();
    designationController = TextEditingController();
    locationController = TextEditingController();
    estimatedValueController = TextEditingController();
    notesController = TextEditingController();

    conversionCompanyController = TextEditingController();
    conversionValueController = TextEditingController();
    conversionNotesController = TextEditingController();
    
    selectedAssignee.value = null;
  }

  @override
  void onClose() {
    nameController.dispose();
    companyController.dispose();
    emailController.dispose();
    mobileController.dispose();
    designationController.dispose();
    locationController.dispose();
    estimatedValueController.dispose();
    notesController.dispose();

    conversionCompanyController.dispose();
    conversionValueController.dispose();
    conversionNotesController.dispose();
    super.onClose();
  }

  // Seed initial high-fidelity mock data matching the Leads completed flow mockup
  void _seedDummyLeads() {
    final arjun = salesReps[0]; // Rahul Sharma
    final neha = salesReps[1]; // Neha Verma

    leads.assignAll([
      Lead(
        id: 'L001',
        name: 'Rohit Kumar',
        companyName: 'R K Enterprises',
        email: 'rohit.kumar@email.com',
        mobile: '+91 98765 43210',
        designation: 'Director',
        leadSource: 'Website',
        leadStatus: 'New',
        leadScore: 75,
        assignedTo: arjun,
        location: 'Mumbai, Maharashtra',
        estimatedValue: 50000.00,
        expectedClosingDate: DateTime(2024, 5, 31),
        notes: 'Interested in our premium plan. Looking for demo.',
        createdOn: DateTime(2024, 5, 15, 10, 30),
        followUps: [
          LeadFollowUp(
            id: 'F001',
            title: 'Setup Consultation Call',
            content: 'Client requested pricing quote and system requirement overview.',
            dateTime: DateTime(2024, 5, 20, 11, 00),
            representative: 'Rahul Sharma',
            isCompleted: false,
            type: 'call',
          ),
        ],
      ),
      Lead(
        id: 'L002',
        name: 'Priya Sharma',
        companyName: 'PS Services',
        email: 'priya.sharma@services.com',
        mobile: '+91 87654 32109',
        designation: 'Manager',
        leadSource: 'Facebook Ad',
        leadStatus: 'Contacted',
        leadScore: 60,
        assignedTo: neha,
        location: 'Delhi, NCR',
        estimatedValue: 60000.00,
        expectedClosingDate: DateTime(2024, 6, 15),
        notes: 'Requested bulk user onboarding proposal.',
        createdOn: DateTime(2024, 5, 15, 14, 20),
        followUps: [
          LeadFollowUp(
            id: 'F002',
            title: 'Proposal Callback',
            content: 'Discuss license model details with Priya.',
            dateTime: DateTime(2024, 5, 21, 14, 00),
            representative: 'Neha Verma',
            isCompleted: false,
            type: 'call',
          ),
        ],
      ),
      Lead(
        id: 'L003',
        name: 'Amit Singh',
        companyName: 'AS Technologies',
        email: 'amit@astech.com',
        mobile: '+91 76543 21098',
        designation: 'CEO',
        leadSource: 'Referral',
        leadStatus: 'New',
        leadScore: 40,
        assignedTo: arjun,
        location: 'Bengaluru, Karnataka',
        estimatedValue: 40000.00,
        expectedClosingDate: DateTime(2024, 5, 25),
        notes: 'Referred by standard client. Extremely eager to buy.',
        createdOn: DateTime(2024, 5, 14, 9, 00),
        followUps: [
          LeadFollowUp(
            id: 'F003',
            title: 'Introductory Call',
            content: 'Establish initial requirements and schedule platform walkthrough.',
            dateTime: DateTime(2024, 5, 22, 11, 30),
            representative: 'Rahul Sharma',
            isCompleted: false,
            type: 'call',
          ),
        ],
      ),
      Lead(
        id: 'L004',
        name: 'Neha Joshi',
        companyName: 'NJ Solutions',
        email: 'neha.joshi@nj.com',
        mobile: '+91 65432 10987',
        designation: 'Director',
        leadSource: 'Google Ads',
        leadStatus: 'Converted',
        leadScore: 100,
        assignedTo: neha,
        location: 'Pune, Maharashtra',
        estimatedValue: 75000.00,
        expectedClosingDate: DateTime(2024, 5, 18),
        notes: 'Evaluated bulk features. Converted.',
        createdOn: DateTime(2024, 5, 12, 16, 45),
        dealValue: 75000.00,
        conversionDate: DateTime(2024, 5, 18),
        conversionNotes: 'Converted after productive product demo.',
        followUps: [
          LeadFollowUp(
            id: 'F004',
            title: 'Deal Finalization',
            content: 'Client onboarded successfully on premium features.',
            dateTime: DateTime(2024, 5, 18, 12, 00),
            representative: 'Neha Verma',
            isCompleted: true,
            type: 'proposal',
          ),
        ],
      ),
      Lead(
        id: 'L005',
        name: 'Vikram Patil',
        companyName: 'Patil Exports',
        email: 'vikram@patil.com',
        mobile: '+91 54321 09876',
        designation: 'Owner',
        leadSource: 'Website',
        leadStatus: 'Contacted',
        leadScore: 55,
        assignedTo: arjun,
        location: 'Ahmedabad, Gujarat',
        estimatedValue: 30000.00,
        expectedClosingDate: DateTime(2024, 5, 23),
        notes: 'Reviewing proposal details.',
        createdOn: DateTime(2024, 5, 14, 11, 15),
        followUps: [
          LeadFollowUp(
            id: 'F005',
            title: 'Quote Discussion',
            content: 'Answer questions regarding standard contract terms.',
            dateTime: DateTime(2024, 5, 23, 15, 00),
            representative: 'Rahul Sharma',
            isCompleted: false,
            type: 'call',
          ),
        ],
      ),
    ]);
  }

  // Statistics properties
  int get totalLeadsCount => leads.length;
  int get newLeadsCount => leads.where((l) => l.leadStatus == 'New').length;
  int get contactedLeadsCount => leads.where((l) => l.leadStatus == 'Contacted').length;
  int get convertedLeadsCount => leads.where((l) => l.leadStatus == 'Converted').length;

  // Filtered leads list
  List<Lead> get filteredLeads {
    List<Lead> temp = List.from(leads);

    if (selectedFilter.value != 'All') {
      temp = temp.where((l) => l.leadStatus.toLowerCase() == selectedFilter.value.toLowerCase()).toList();
    }

    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      temp = temp.where((l) =>
        l.name.toLowerCase().contains(query) ||
        l.companyName.toLowerCase().contains(query) ||
        l.email.toLowerCase().contains(query) ||
        l.leadSource.toLowerCase().contains(query)
      ).toList();
    }

    temp.sort((a, b) => b.createdOn.compareTo(a.createdOn));
    return temp;
  }

  // Flattened followups across all leads
  List<LeadFollowUp> get allFollowUps {
    List<LeadFollowUp> temp = [];
    for (var lead in leads) {
      for (var f in lead.followUps) {
        temp.add(f);
      }
    }
    temp.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return temp;
  }

  List<LeadFollowUp> get upcomingFollowUps => allFollowUps.where((f) => !f.isCompleted).toList();
  List<LeadFollowUp> get completedFollowUps => allFollowUps.where((f) => f.isCompleted).toList();

  // Find parent lead of follow-up
  Lead? getParentLeadOfFollowUp(String followupId) {
    for (var lead in leads) {
      if (lead.followUps.any((f) => f.id == followupId)) {
        return lead;
      }
    }
    return null;
  }

  // Filtered sales team search in Assign view
  List<AppUser> get filteredSalesReps {
    if (salespersonSearchQuery.value.isEmpty) return salesReps;
    final q = salespersonSearchQuery.value.toLowerCase();
    return salesReps.where((rep) => rep.name.toLowerCase().contains(q) || rep.email.toLowerCase().contains(q)).toList();
  }

  // Form helpers
  void clearForm() {
    nameController.clear();
    companyController.clear();
    emailController.clear();
    mobileController.clear();
    designationController.clear();
    locationController.clear();
    estimatedValueController.clear();
    notesController.clear();
    selectedSource.value = null;
    selectedStatus.value = null;
    selectedAssignee.value = null;
    expectedClosingDate.value = null;
  }

  void initializeEditing(Lead lead) {
    nameController.text = lead.name;
    companyController.text = lead.companyName;
    emailController.text = lead.email;
    mobileController.text = lead.mobile;
    designationController.text = lead.designation;
    locationController.text = lead.location;
    estimatedValueController.text = lead.estimatedValue.toInt().toString();
    notesController.text = lead.notes;
    selectedSource.value = lead.leadSource;
    selectedStatus.value = lead.leadStatus;
    selectedAssignee.value = lead.assignedTo;
    expectedClosingDate.value = lead.expectedClosingDate;
  }

  // Save new or edit existing lead
  void saveLead({String? id}) {
    if (id == null) {
      final newLead = Lead(
        id: 'L00${leads.length + 1}',
        name: nameController.text.trim(),
        companyName: companyController.text.trim().isNotEmpty ? companyController.text.trim() : 'Company Inc.',
        email: emailController.text.trim(),
        mobile: mobileController.text.trim(),
        designation: designationController.text.trim(),
        leadSource: selectedSource.value ?? 'Website',
        leadStatus: selectedStatus.value ?? 'New',
        leadScore: selectedStatus.value == 'Converted' ? 100 : 50,
        assignedTo: selectedAssignee.value ?? salesReps[0],
        location: locationController.text.trim().isNotEmpty ? locationController.text.trim() : 'Unassigned Location',
        estimatedValue: double.tryParse(estimatedValueController.text.trim()) ?? 10000.0,
        expectedClosingDate: expectedClosingDate.value ?? DateTime.now().add(const Duration(days: 30)),
        notes: notesController.text.trim().isNotEmpty ? notesController.text.trim() : 'Interested client.',
        createdOn: DateTime.now(),
        followUps: [],
      );
      leads.add(newLead);
      _showSnackbar('Lead Created', 'Lead has been added successfully!', const Color(0xFF10B981));
    } else {
      final index = leads.indexWhere((l) => l.id == id);
      if (index != -1) {
        final existing = leads[index];
        final updatedLead = existing.copyWith(
          name: nameController.text.trim(),
          companyName: companyController.text.trim(),
          email: emailController.text.trim(),
          mobile: mobileController.text.trim(),
          designation: designationController.text.trim(),
          leadSource: selectedSource.value ?? existing.leadSource,
          leadStatus: selectedStatus.value ?? existing.leadStatus,
          leadScore: selectedStatus.value == 'Converted' ? 100 : existing.leadScore,
          assignedTo: selectedAssignee.value ?? existing.assignedTo,
          location: locationController.text.trim(),
          estimatedValue: double.tryParse(estimatedValueController.text.trim()) ?? 0.0,
          expectedClosingDate: expectedClosingDate.value ?? existing.expectedClosingDate,
          notes: notesController.text.trim(),
        );
        leads[index] = updatedLead;
        if (selectedLead.value?.id == id) {
          selectedLead.value = updatedLead;
        }
        _showSnackbar('Lead Updated', 'Lead has been updated successfully!', const Color(0xFF2563EB));
      }
    }
  }

  // Delete lead
  void deleteLead(String id) {
    leads.removeWhere((l) => l.id == id);
    if (selectedLead.value?.id == id) {
      selectedLead.value = null;
    }
    Get.back();
    _showSnackbar('Lead Deleted', 'Lead removed from CRM database.', const Color(0xFFEF4444));
  }

  // Assign lead salesperson
  void assignSalesperson(String leadId, AppUser representative, String comment) {
    final index = leads.indexWhere((l) => l.id == leadId);
    if (index != -1) {
      final existing = leads[index];
      
      final assignmentFollowup = LeadFollowUp(
        id: 'F00${existing.followUps.length + 10}',
        title: 'Assigned to ${representative.name}',
        content: comment.trim().isNotEmpty ? comment.trim() : 'Lead assigned for further tracking.',
        dateTime: DateTime.now(),
        representative: representative.name,
        isCompleted: true,
        type: 'proposal',
      );
      
      final updatedList = List<LeadFollowUp>.from(existing.followUps)..add(assignmentFollowup);
      final updated = existing.copyWith(
        assignedTo: representative,
        followUps: updatedList,
      );

      leads[index] = updated;
      if (selectedLead.value?.id == leadId) {
        selectedLead.value = updated;
      }
      _showSnackbar('Lead Assigned', 'Lead successfully assigned to ${representative.name}!', const Color(0xFF10B981));
    }
  }

  // Complete conversion and record deal logs
  void processLeadConversion(String leadId, double value, String company, String notes) {
    final index = leads.indexWhere((l) => l.id == leadId);
    if (index != -1) {
      final existing = leads[index];
      
      final conversionEvent = LeadFollowUp(
        id: 'F00${existing.followUps.length + 10}',
        title: 'Converted to Customer 🎉',
        content: notes.trim().isNotEmpty ? notes.trim() : 'Lead converted successfully! Contract generated.',
        dateTime: DateTime.now(),
        representative: existing.assignedTo.name,
        isCompleted: true,
        type: 'proposal',
      );

      final updatedList = List<LeadFollowUp>.from(existing.followUps)..add(conversionEvent);
      final updated = existing.copyWith(
        leadStatus: 'Converted',
        leadScore: 100,
        companyName: company.trim().isNotEmpty ? company.trim() : existing.companyName,
        dealValue: value,
        conversionDate: DateTime.now(),
        conversionNotes: notes.trim().isNotEmpty ? notes.trim() : 'Deal closed successfully.',
        followUps: updatedList,
      );

      leads[index] = updated;
      if (selectedLead.value?.id == leadId) {
        selectedLead.value = updated;
      }
      
      _showSnackbar('Congratulations 🎉', '${existing.name} is now a Customer!', const Color(0xFF10B981));
    }
  }

  // Complete a followup
  void markFollowupCompleted(String leadId, String followupId) {
    final index = leads.indexWhere((l) => l.id == leadId);
    if (index != -1) {
      final existing = leads[index];
      final followups = List<LeadFollowUp>.from(existing.followUps);
      final fIdx = followups.indexWhere((f) => f.id == followupId);
      
      if (fIdx != -1) {
        final existingF = followups[fIdx];
        followups[fIdx] = existingF.copyWith(isCompleted: true);
        final updated = existing.copyWith(followUps: followups);
        leads[index] = updated;
        if (selectedLead.value?.id == leadId) {
          selectedLead.value = updated;
        }
        _showSnackbar('Followup Completed', 'Follow-up has been marked as completed.', const Color(0xFF10B981));
      }
    }
  }

  // Add follow-up timeline activities
  void addFollowUpNote({
    required String title,
    required String content,
    required String type,
    required DateTime date,
    required bool isCompleted,
  }) {
    if (selectedLead.value != null) {
      final id = selectedLead.value!.id;
      final index = leads.indexWhere((l) => l.id == id);
      if (index != -1) {
        final existing = leads[index];
        final newFollowUp = LeadFollowUp(
          id: 'F00${existing.followUps.length + 10}',
          title: title,
          content: content,
          dateTime: date,
          representative: existing.assignedTo.name,
          isCompleted: isCompleted,
          type: type,
        );

        final updatedList = List<LeadFollowUp>.from(existing.followUps)..add(newFollowUp);
        updatedList.sort((a, b) => b.dateTime.compareTo(a.dateTime));

        final updated = existing.copyWith(followUps: updatedList);
        leads[index] = updated;
        selectedLead.value = updated;

        _showSnackbar('Activity Added', 'Note / Follow-up saved successfully.', const Color(0xFF10B981));
      }
    }
  }

  void _showSnackbar(String title, String message, Color bgColor) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: bgColor,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      borderRadius: 16,
      boxShadows: [
        BoxShadow(
          color: bgColor.withValues(alpha: 0.25),
          blurRadius: 16,
          offset: const Offset(0, 8),
        )
      ],
    );
  }
}
