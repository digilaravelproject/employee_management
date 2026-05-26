import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../models/hr_models.dart';

class HrController extends GetxController {
  // Navigation Shell State
  var currentTabIdx = 0.obs;

  // Policies State
  var policies = <CompanyPolicy>[].obs;
  var selectedPolicyFilter = 'All Policies'.obs;
  
  // Policy Categories
  final List<String> policyFilters = [
    'All Policies',
    'HR Policies',
    'Work Policies',
    'Leave Policies'
  ];

  // Announcements State
  var announcements = <HrAnnouncement>[].obs;
  var selectedAnnFilter = 'All'.obs;

  // Announcement Categories
  final List<String> annFilters = [
    'All',
    'General',
    'Events',
    'Updates',
    'Important'
  ];

  // Engagement Updates State
  var recentEngagements = <EngagementUpdate>[].obs;

  // Interactive Engagement logs
  var suggestions = <String>[].obs;
  var kudosLogs = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    _seedDummyData();
  }

  void _seedDummyData() {
    // 1. Seed Policies
    policies.assignAll([
      CompanyPolicy(
        id: 'pol_1',
        title: 'Code of Conduct',
        type: 'HR Policies',
        updatedDate: DateTime(2026, 5, 10),
        description: 'This policy defines the standard guidelines and rules for professional workplace behavior, ethics, and mutual respect expected from all employees at our organization.',
      ),
      CompanyPolicy(
        id: 'pol_2',
        title: 'Leave Policy',
        type: 'Leave Policies',
        updatedDate: DateTime(2026, 5, 8),
        description: 'Comprehensive guidelines about annual paid leave, medical sick leaves, casual leaves, and maternity/paternity leave allocations and how to apply via the app.',
      ),
      CompanyPolicy(
        id: 'pol_3',
        title: 'Attendance Policy',
        type: 'HR Policies',
        updatedDate: DateTime(2026, 5, 5),
        description: 'Defines standard office timings, flexible work bandwidth hours, remote log-in requirements, and attendance markers validation rules.',
      ),
      CompanyPolicy(
        id: 'pol_4',
        title: 'Work From Home Policy',
        type: 'Work Policies',
        updatedDate: DateTime(2026, 5, 1),
        description: 'Guidelines regarding remote work setups, data privacy compliance during home working, internet reimbursement limits, and core productivity criteria.',
      ),
      CompanyPolicy(
        id: 'pol_5',
        title: 'Data Security Policy',
        type: 'HR Policies',
        updatedDate: DateTime(2026, 4, 28),
        description: 'Ensuring all company intellectual assets, client portfolios, employee records, and source code are treated with high confidentiality and handled securely.',
      ),
      CompanyPolicy(
        id: 'pol_6',
        title: 'Dress Code Policy',
        type: 'Work Policies',
        updatedDate: DateTime(2026, 4, 20),
        description: 'Defines the professional casual dress code rules for weekdays, and casual dressing protocols for Fridays or company outdoor activities.',
      ),
      CompanyPolicy(
        id: 'pol_7',
        title: 'Disciplinary Policy',
        type: 'HR Policies',
        updatedDate: DateTime(2026, 4, 15),
        description: 'Outlines behavioral boundaries, code-of-conduct breach indicators, escalation matrices, and structured corrective action timelines.',
      ),
      CompanyPolicy(
        id: 'pol_8',
        title: 'POSH Policy',
        type: 'HR Policies',
        updatedDate: DateTime(2026, 4, 10),
        description: 'Outlines our zero-tolerance policy against sexual harassment at the workplace, establishing a POSH Internal Complaints Committee for active resolution.',
      ),
    ]);

    // 2. Seed Announcements
    announcements.assignAll([
      HrAnnouncement(
        id: 'ann_1',
        title: 'Office Timing Update',
        type: 'General',
        publishDate: DateTime(2026, 5, 20, 10, 30),
        priority: 'Important',
        isPinned: true,
        content: 'New office timings will be effective from 1st June 2026. Please be informed that shift gates will open at 9:00 AM and close at 6:00 PM for operational ease.',
      ),
      HrAnnouncement(
        id: 'ann_2',
        title: 'Annual Day Celebration',
        type: 'Events',
        publishDate: DateTime(2026, 5, 18, 14, 15),
        priority: 'Normal',
        isPinned: true,
        content: 'We are excited to announce our Annual Day Celebration on 25th June 2026. Get ready for sports events, stage programs, food decks, and awards night!',
      ),
      HrAnnouncement(
        id: 'ann_3',
        title: 'Work From Home on Friday',
        type: 'Updates',
        publishDate: DateTime(2026, 5, 16, 9, 0),
        priority: 'Normal',
        content: 'This Friday will be a Work From Home day for all employees. Please coordinate with your respective team leads to ensure seamless project deliverables.',
      ),
      HrAnnouncement(
        id: 'ann_4',
        title: 'New Joiners This Month',
        type: 'General',
        publishDate: DateTime(2026, 5, 15, 11, 20),
        priority: 'Low',
        content: 'Please join us in welcoming our new team members who have joined us this month in development and business development roles. Let us support their onboarding!',
      ),
      HrAnnouncement(
        id: 'ann_5',
        title: 'System Maintenance',
        type: 'Updates',
        publishDate: DateTime(2026, 5, 14, 16, 45),
        priority: 'Normal',
        content: 'Our core HR portal database will be under scheduled server maintenance on 30th May from 10:00 PM to 2:00 AM. Portal login might be temporarily unavailable.',
      ),
      HrAnnouncement(
        id: 'ann_6',
        title: 'Employee Recognition Program',
        type: 'Updates',
        publishDate: DateTime(2026, 5, 12, 15, 0),
        priority: 'High',
        content: 'Nominations are open for the employee peer recognition program for Q2. Appreciate your colleagues and nominate them before 30th May!',
      ),
      HrAnnouncement(
        id: 'ann_7',
        title: 'Birthday Wishes',
        type: 'General',
        publishDate: DateTime(2026, 5, 10, 9, 30),
        priority: 'Low',
        content: 'Wishing all the team members celebrating their birthdays this month a spectacular and fulfilling year ahead! Let us enjoy the cake-cutting at 5 PM.',
      ),
    ]);

    // 3. Seed Engagement
    recentEngagements.assignAll([
      EngagementUpdate(
        id: 'eng_1',
        title: 'Team Outing',
        category: 'Team Outing',
        description: 'Marketing team enjoyed their outdoor outing at Imagicaa. Theme park rides and group dinners boosted synergy!',
        timeAgo: '1d ago',
      ),
      EngagementUpdate(
        id: 'eng_2',
        title: 'Work Anniversary',
        category: 'Work Anniversary',
        description: 'Amit Singh completed 3 years with us today. Huge congratulations and thank you for your incredible contributions!',
        timeAgo: '2d ago',
      ),
      EngagementUpdate(
        id: 'eng_3',
        title: 'Employee of the Month',
        category: 'Employee of the Month',
        description: 'Rahul Verma has been recognized as Employee of the Month for April 2026 for outstanding support tickets resolution!',
        timeAgo: '3d ago',
      ),
      EngagementUpdate(
        id: 'eng_4',
        title: 'Wellness Webinar',
        category: 'Wellness Webinar',
        description: 'A company-wide interactive webinar on "Stress Management" was organized successfully with expert clinical guides.',
        timeAgo: '5d ago',
      ),
    ]);
  }

  // Setters
  void changeTab(int idx) {
    currentTabIdx.value = idx;
  }

  void setPolicyFilter(String filter) {
    selectedPolicyFilter.value = filter;
  }

  void setAnnFilter(String filter) {
    selectedAnnFilter.value = filter;
  }

  // Getters (filtered)
  List<CompanyPolicy> get filteredPolicies {
    if (selectedPolicyFilter.value == 'All Policies') {
      return policies;
    }
    return policies.where((p) => p.type == selectedPolicyFilter.value).toList();
  }

  List<HrAnnouncement> get filteredAnnouncements {
    if (selectedAnnFilter.value == 'All') {
      return announcements;
    }
    
    // Map chip filter string to announcement models category type
    String targetType = selectedAnnFilter.value;
    if (targetType == 'Important') {
      return announcements.where((a) => a.priority == 'Urgent' || a.priority == 'High').toList();
    }
    
    return announcements.where((a) => a.type == targetType).toList();
  }

  // Actions
  void addPolicy(CompanyPolicy policy) {
    policies.insert(0, policy);
    Get.snackbar(
      'Success',
      'New policy "${policy.title}" added successfully!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  void addAnnouncement(HrAnnouncement announcement) {
    announcements.insert(0, announcement);
    Get.snackbar(
      'Success',
      'Announcement published successfully!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  void submitSuggestion(String suggestion) {
    if (suggestion.trim().isEmpty) return;
    suggestions.add(suggestion.trim());
    Get.snackbar(
      'Feedback Received',
      'Thank you! Your anonymous suggestion has been recorded.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primaryColor,
      colorText: Colors.white,
    );
  }

  void submitKudos(String peerName, String peerMsg) {
    if (peerName.trim().isEmpty || peerMsg.trim().isEmpty) return;
    kudosLogs.add('Kudos to $peerName: $peerMsg');
    
    // Dynamically insert into recent engagements list!
    recentEngagements.insert(0, EngagementUpdate(
      id: 'eng_${recentEngagements.length + 1}',
      title: 'Peer Kudos Recipient',
      category: 'Kudos & Recognition',
      description: 'Peers appreciated $peerName: "$peerMsg"',
      timeAgo: 'Just now',
    ));

    Get.snackbar(
      'Kudos Published',
      'Peer recognition posted to the engagement wall!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }
}
