import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/services/storage/shared_prefs.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/employee_tele_crm_controller.dart';
import '../models/employee_leads_response_model.dart';
import '../models/lead_status_model.dart';
import '../models/sales_employee_model.dart';
import 'sales_executive_create_lead_screen.dart';
import 'sales_convert_to_project_screen.dart';
import '../../projects/views/project_details_screen.dart';

Future<void> _makePhoneCall(String phoneNumber) async {
  final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
  if (cleanNumber.isEmpty) {
    Get.snackbar(
      'Invalid Phone',
      'Phone number is not available for this lead.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFEF4444),
      colorText: Colors.white,
    );
    return;
  }

  final uri = Uri.parse('tel:$cleanNumber');
  try {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  } catch (e) {
    Get.snackbar(
      'Dialer Error',
      'Could not launch phone dialer: $e',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFEF4444),
      colorText: Colors.white,
    );
  }
}

Future<void> _sendWhatsAppMessage(String phoneNumber, {String? message}) async {
  final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
  if (cleanNumber.isEmpty) {
    Get.snackbar(
      'Invalid Phone',
      'Phone number is not valid for WhatsApp.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFEF4444),
      colorText: Colors.white,
    );
    return;
  }
  final text = message ?? 'Hello, following up regarding your requirement.';
  final uri = Uri.parse('https://wa.me/$cleanNumber?text=${Uri.encodeComponent(text)}');
  try {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      await launchUrl(uri);
    }
  } catch (e) {
    Get.snackbar(
      'WhatsApp Error',
      'Could not open WhatsApp: $e',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFEF4444),
      colorText: Colors.white,
    );
  }
}

Future<void> _sendSmsMessage(String phoneNumber, {String? message}) async {
  final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
  if (cleanNumber.isEmpty) return;
  final text = message ?? 'Hello, following up regarding your requirement.';
  final uri = Uri.parse('sms:$cleanNumber?body=${Uri.encodeComponent(text)}');
  try {
    await launchUrl(uri);
  } catch (_) {}
}

// ── LEAD REMINDER MODEL & PERSISTENT MANAGER ────────────────────────────────
class LeadReminderModel {
  final int leadId;
  final String leadCode;
  final String customerName;
  final String phone;
  final DateTime scheduledAt;
  final String reminderType; // 'Call', 'WhatsApp', 'SMS', 'Meeting'
  final String note;
  final bool isCompleted;

  LeadReminderModel({
    required this.leadId,
    required this.leadCode,
    required this.customerName,
    required this.phone,
    required this.scheduledAt,
    this.reminderType = 'Call',
    this.note = '',
    this.isCompleted = false,
  });

  bool get isDueToday {
    final now = DateTime.now();
    return scheduledAt.year == now.year &&
        scheduledAt.month == now.month &&
        scheduledAt.day == now.day;
  }

  bool get isOverdue {
    return !isCompleted && scheduledAt.isBefore(DateTime.now());
  }

  Map<String, dynamic> toJson() => {
    'leadId': leadId,
    'leadCode': leadCode,
    'customerName': customerName,
    'phone': phone,
    'scheduledAt': scheduledAt.toIso8601String(),
    'reminderType': reminderType,
    'note': note,
    'isCompleted': isCompleted,
  };

  factory LeadReminderModel.fromJson(Map<String, dynamic> json) => LeadReminderModel(
    leadId: int.tryParse(json['leadId']?.toString() ?? '') ?? 0,
    leadCode: json['leadCode']?.toString() ?? '',
    customerName: json['customerName']?.toString() ?? '',
    phone: json['phone']?.toString() ?? '',
    scheduledAt: DateTime.tryParse(json['scheduledAt']?.toString() ?? '') ?? DateTime.now(),
    reminderType: json['reminderType']?.toString() ?? 'Call',
    note: json['note']?.toString() ?? '',
    isCompleted: json['isCompleted'] == true,
  );
}

class LeadReminderManager {
  static const String _storageKey = 'employee_lead_reminders_map_v1';
  static final RxMap<int, LeadReminderModel> reminders = <int, LeadReminderModel>{}.obs;

  static void init() {
    loadReminders();
  }

  static void loadReminders() {
    try {
      final jsonStr = SharedPrefs.getString(_storageKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final decoded = jsonDecode(jsonStr);
        if (decoded is Map<String, dynamic>) {
          final Map<int, LeadReminderModel> map = {};
          decoded.forEach((key, val) {
            final id = int.tryParse(key);
            if (id != null && val is Map<String, dynamic>) {
              map[id] = LeadReminderModel.fromJson(val);
            }
          });
          reminders.assignAll(map);
        }
      }
    } catch (_) {}
  }

  static Future<void> saveReminder(LeadReminderModel reminder) async {
    reminders[reminder.leadId] = reminder;
    await _persist();
  }

  static Future<void> removeReminder(int leadId) async {
    reminders.remove(leadId);
    await _persist();
  }

  static Future<void> toggleComplete(int leadId) async {
    final current = reminders[leadId];
    if (current != null) {
      reminders[leadId] = LeadReminderModel(
        leadId: current.leadId,
        leadCode: current.leadCode,
        customerName: current.customerName,
        phone: current.phone,
        scheduledAt: current.scheduledAt,
        reminderType: current.reminderType,
        note: current.note,
        isCompleted: !current.isCompleted,
      );
      await _persist();
    }
  }

  static Future<void> _persist() async {
    try {
      final mapToSave = <String, dynamic>{};
      reminders.forEach((id, rem) {
        mapToSave[id.toString()] = rem.toJson();
      });
      await SharedPrefs.setString(_storageKey, jsonEncode(mapToSave));
    } catch (_) {}
  }

  static LeadReminderModel? getReminder(int leadId) => reminders[leadId];

  static int get activeRemindersCount =>
      reminders.values.where((r) => !r.isCompleted).length;

  static int get todayRemindersCount =>
      reminders.values.where((r) => !r.isCompleted && (r.isDueToday || r.isOverdue)).length;
}

// ── MODELS ───────────────────────────────────────────────────────────────────
class ExecLeadProcessStep {
  final String title;
  final String date;
  final String time;
  final String note;
  final String performedBy;
  final bool isCompleted;

  ExecLeadProcessStep({
    required this.title,
    required this.date,
    this.time = '',
    required this.note,
    this.performedBy = '',
    required this.isCompleted,
  });
}

class TeleCrmLeadItem {
  final String id;
  final String customerName;
  final String phone;
  final String email;
  final String city;
  final String source;
  final String sourceColorHex;
  String status; // Interested, Follow-up, Pending Call, Converted, Unreachable, Wrong Number
  DateTime? nextFollowupDateTime;
  String requirement;
  double potentialValue;
  bool isSelfGenerated; // True = self brought, False = admin assigned
  List<ExecLeadProcessStep> processSteps;
  
  String lastCallNote;
  String lastCallDuration;
  String lastCallDate;

  final int rawId;
  String assignedEmployee;
  String assignedEmployeeAvatar;
  String assignedEmployeeRole;
  bool isReassigned;

  TeleCrmLeadItem({
    this.rawId = 0,
    required this.id,
    required this.customerName,
    required this.phone,
    this.email = 'client@example.com',
    required this.city,
    required this.source,
    required this.sourceColorHex,
    required this.status,
    this.nextFollowupDateTime,
    this.requirement = 'N/A',
    this.potentialValue = 0,
    this.isSelfGenerated = false,
    required this.processSteps,
    this.lastCallNote = '',
    this.lastCallDuration = '',
    this.lastCallDate = '',
    this.assignedEmployee = 'Rahul Sharma (You)',
    this.assignedEmployeeAvatar = 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&auto=format&fit=crop&q=80',
    this.assignedEmployeeRole = 'Sales Executive',
    this.isReassigned = false,
  });

  factory TeleCrmLeadItem.fromEmployeeLead(EmployeeLeadItemModel item) {
    // Format UI status
    String formattedStatus = 'Interested';
    final s = (item.status ?? '').toLowerCase().trim();
    if (s == 'interested') {
      formattedStatus = 'Interested';
    } else if (s == 'follow_up' || s == 'follow-up') {
      formattedStatus = 'Follow-up';
    } else if (s == 'pending_call' || s == 'pending call') {
      formattedStatus = 'Pending Call';
    } else if (s == 'converted') {
      formattedStatus = 'Converted';
    } else if (s == 'unreachable') {
      formattedStatus = 'Unreachable';
    } else if (s == 'wrong_number' || s == 'wrong number') {
      formattedStatus = 'Wrong Number';
    } else if (s.isNotEmpty) {
      formattedStatus = s[0].toUpperCase() + s.substring(1);
    }

    // Format UI source & color
    String formattedSource = 'Referral';
    String colorHex = '0xFF059669';
    final src = (item.source ?? '').toLowerCase().trim();
    if (src.contains('facebook') || src.contains('meta')) {
      formattedSource = 'Facebook Ads';
      colorHex = '0xFF1877F2';
    } else if (src.contains('google')) {
      formattedSource = 'Google Ads';
      colorHex = '0xFFEA4335';
    } else if (src.contains('referral')) {
      formattedSource = 'Referral';
      colorHex = '0xFF059669';
    } else if (src.contains('website')) {
      formattedSource = 'Website';
      colorHex = '0xFF10B981';
    } else if (src.contains('self')) {
      formattedSource = 'Self Generated';
      colorHex = '0xFF7C3AED';
    } else if (src.isNotEmpty) {
      formattedSource = src[0].toUpperCase() + src.substring(1);
      colorHex = '0xFF64748B';
    }

    // Parse potential value
    double val = 0;
    if (item.estimatedValue != null) {
      val = double.tryParse(item.estimatedValue.toString().replaceAll(',', '')) ?? 0.0;
    }

    // Format created date
    String createdDateStr = 'Recent';
    if (item.createdAt != null) {
      try {
        final dt = DateTime.parse(item.createdAt!);
        createdDateStr = DateFormat('dd MMM yyyy').format(dt);
      } catch (_) {}
    }

    final steps = <ExecLeadProcessStep>[];
    if (item.history.isNotEmpty) {
      for (final h in item.history) {
        String dateStr = '';
        String timeStr = '';
        if (h.occurredAt != null) {
          try {
            final dt = DateTime.parse(h.occurredAt!);
            dateStr = DateFormat('dd MMM yyyy').format(dt);
            timeStr = DateFormat('hh:mm a').format(dt);
          } catch (_) {
            dateStr = h.occurredAt!;
          }
        }
        steps.add(ExecLeadProcessStep(
          title: h.title?.isNotEmpty == true ? h.title! : (h.eventType ?? 'Event'),
          date: dateStr,
          time: timeStr,
          note: h.description ?? '',
          performedBy: h.actorName ?? h.actor?.name ?? '',
          isCompleted: true,
        ));
      }
    } else {
      steps.add(ExecLeadProcessStep(
        title: item.assignmentOrigin == 'admin_assigned'
            ? 'Lead Assigned by Admin'
            : 'Lead Created',
        date: createdDateStr,
        time: '',
        note: item.notes?.isNotEmpty == true ? item.notes! : 'Source: $formattedSource',
        performedBy: item.createdBy?.name ?? (item.assignmentOrigin == 'admin_assigned' ? 'Admin' : 'You'),
        isCompleted: true,
      ));
    }

    return TeleCrmLeadItem(
      rawId: item.id,
      id: item.leadCode?.isNotEmpty == true ? item.leadCode! : 'LD-${item.id}',
      customerName: item.fullName?.isNotEmpty == true
          ? item.fullName!
          : (item.companyName?.isNotEmpty == true ? item.companyName! : 'Customer #${item.id}'),
      phone: item.mobileNumber ?? '',
      email: item.email ?? 'client@example.com',
      city: item.location?.isNotEmpty == true ? item.location! : (item.companyName ?? 'N/A'),
      source: formattedSource,
      sourceColorHex: colorHex,
      status: formattedStatus,
      isSelfGenerated: item.assignmentOrigin != 'admin_assigned',
      requirement: item.requirement?.isNotEmpty == true ? item.requirement! : 'N/A',
      potentialValue: val,
      lastCallNote: item.notes ?? '',
      lastCallDate: createdDateStr,
      assignedEmployee: item.assignedEmployee?.name ?? 'Rahul Sharma (You)',
      assignedEmployeeAvatar: item.assignedEmployee?.avatar?.isNotEmpty == true
          ? item.assignedEmployee!.avatar!
          : 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&auto=format&fit=crop&q=80',
      assignedEmployeeRole: item.assignedEmployee?.designation ?? 'Sales Executive',
      isReassigned: !item.isOwner,
      processSteps: steps,
    );
  }
}

// ── SALES EXECUTIVE TELE-CRM SCREEN ──────────────────────────────────────────
class SalesExecutiveTeleCrmScreen extends StatefulWidget {
  const SalesExecutiveTeleCrmScreen({super.key});

  @override
  State<SalesExecutiveTeleCrmScreen> createState() => _SalesExecutiveTeleCrmScreenState();
}

class _SalesExecutiveTeleCrmScreenState extends State<SalesExecutiveTeleCrmScreen> {
  late final EmployeeTeleCrmController _controller;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _targetFilter = 'Today'; // Today, Weekly, Monthly

  @override
  void initState() {
    super.initState();
    LeadReminderManager.init();
    LeadProjectHandoverManager.init();
    _controller = EmployeeTeleCrmController.to;
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.hasClients &&
        _scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _controller.loadMoreLeads();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<EmployeeLeadItemModel> get _displayedLeads {
    final query = _searchController.text.trim().toLowerCase();
    List<EmployeeLeadItemModel> leads = _controller.leads;

    // Filter leads if Reminders tab is active
    if (_controller.selectedStatus.value == '__reminders__' || _controller.selectedTab.value == 'Reminders ⏰') {
      final activeReminderIds = LeadReminderManager.reminders.keys.toSet();
      leads = leads.where((item) => activeReminderIds.contains(item.id)).toList();
    }

    if (query.isEmpty) {
      return leads;
    }
    // If controller leads are already from the search API for this query
    if (_controller.searchQuery.value.trim().toLowerCase() == query && !_controller.isLoading.value) {
      return leads;
    }
    // Keystroke-instant in-memory filter
    final matches = leads.where((item) {
      final combined = '${item.fullName ?? ''} ${item.companyName ?? ''} ${item.mobileNumber ?? ''} ${item.email ?? ''} ${item.leadCode ?? ''} ${item.location ?? ''} ${item.requirement ?? ''} ${item.notes ?? ''} ${item.designation ?? ''}'.toLowerCase();
      return combined.contains(query);
    }).toList();

    return matches.isNotEmpty ? matches : leads;
  }

  // Target calculation mock with live converted revenue
  Map<String, dynamic> _getTargetData() {
    final liveRevenue = _controller.summary.value?.convertedRevenue ?? 0.0;
    if (_targetFilter == 'Today') {
      return {
        'target': 20000.0,
        'achieved': liveRevenue > 0 ? liveRevenue : 5000.0,
        'callsTarget': 50,
        'callsMade': 28,
      };
    } else if (_targetFilter == 'Weekly') {
      return {
        'target': 150000.0,
        'achieved': liveRevenue > 0 ? liveRevenue : 65000.0,
        'callsTarget': 300,
        'callsMade': 142,
      };
    } else {
      return {
        'target': 600000.0,
        'achieved': liveRevenue > 0 ? liveRevenue : 420000.0,
        'callsTarget': 1200,
        'callsMade': 850,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 18),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              'Sales Executive Tele-CRM',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
            AppText(
              'Manage your assigned leads, targets & follow-ups',
              fontSize: 11,
              color: AppColors.textColorSecondary,
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => Get.to(() => const SalesExecutiveCreateLeadScreen())?.then((_) {
              _controller.fetchLeads(isRefresh: true);
            }),
            icon: const Icon(Icons.add_circle_rounded, color: AppColors.primaryColor),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => const SalesExecutiveCreateLeadScreen())?.then((_) {
          _controller.fetchLeads(isRefresh: true);
        }),
        backgroundColor: AppColors.primaryColor,
        icon: const Icon(Iconsax.add, color: Colors.white, size: 20),
        label: const AppText('New Lead', color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
      ),
      body: RefreshIndicator(
        onRefresh: () => _controller.fetchLeads(isRefresh: true),
        color: AppColors.primaryColor,
        child: ListView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          children: [
            // ── 1. Target & Performance Header Banner ──
            Obx(() {
              final targetData = _getTargetData();
              double revenueProgress = ((targetData['achieved'] as double) / (targetData['target'] as double)).clamp(0.0, 1.0);
              double callProgress = ((targetData['callsMade'] as int) / (targetData['callsTarget'] as int)).clamp(0.0, 1.0);

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryColor, AppColors.primaryColor.withValues(alpha: 0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Filter dropdown
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const AppText('My Performance Target', fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                        Container(
                          height: 28,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _targetFilter,
                              dropdownColor: AppColors.primaryColor,
                              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 16),
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                              items: ['Today', 'Weekly', 'Monthly'].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _targetFilter = val);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Revenue Progress
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const AppText('Revenue Achieved', fontSize: 11, color: Color(0xFFE0E7FF)),
                        AppText(
                          '₹${((targetData['achieved'] as double) / 1000).toStringAsFixed(0)}k / ₹${((targetData['target'] as double) / 1000).toStringAsFixed(0)}k',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: revenueProgress,
                        backgroundColor: Colors.black.withValues(alpha: 0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Calls Progress
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const AppText('Calls Made', fontSize: 11, color: Color(0xFFE0E7FF)),
                        AppText('${targetData['callsMade']} / ${targetData['callsTarget']} calls', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: callProgress,
                        backgroundColor: Colors.black.withValues(alpha: 0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFDE047)),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 14),

            // ── Follow-up Reminders Notification Alert (if any due today or overdue) ──
            Obx(() {
              final dueCount = LeadReminderManager.todayRemindersCount;
              final overdueCount = LeadReminderManager.reminders.values.where((r) => !r.isCompleted && r.isOverdue).length;
              if (dueCount == 0 && overdueCount == 0) return const SizedBox.shrink();

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFDE68A), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.alarm_on_rounded, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                "Today's Follow-up Schedule",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF92400E),
                                ),
                              ),
                              if (overdueCount > 0) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEE2E2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '$overdueCount Overdue',
                                    style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFFDC2626)),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            overdueCount > 0
                                ? '$dueCount follow-up(s) need attention today. Call/Message clients on time!'
                                : 'You have $dueCount client follow-up reminder(s) due today.',
                            style: const TextStyle(fontSize: 11, color: Color(0xFFB45309)),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        _controller.changeTab('Reminders ⏰', status: '__reminders__');
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFD97706),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('View All', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            }),

            // ── 2. Search & Segregation Tabs ──
            TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {});
                _controller.onSearchChanged(val);
              },
              onSubmitted: (val) => _controller.onSearchSubmitted(val),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search customer name, phone, city, code...',
                hintStyle: const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
                prefixIcon: const Icon(Iconsax.search_normal_1, size: 18, color: Color(0xFF64748B)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 16, color: Color(0xFF64748B)),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                          _controller.clearSearch();
                        },
                      )
                    : null,
                fillColor: Colors.white,
                filled: true,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Tabs with Live Counts from Summary
            Obx(() {
              final summary = _controller.summary.value;
              final allCount = summary?.all ?? _controller.totalLeads.value;
              final followupsCount = summary?.followUp ?? 0;
              final interestedCount = summary?.interested ?? 0;
              final pendingCallCount = summary?.pendingCall ?? 0;
              final convertedCount = summary?.converted ?? 0;
              final unreachableCount = summary?.unreachable ?? 0;
              final wrongNumberCount = summary?.wrongNumber ?? 0;
              final remindersCount = LeadReminderManager.activeRemindersCount;

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildTabChip('All Leads', statusKey: '', count: allCount),
                    _buildTabChip('Reminders ⏰', statusKey: '__reminders__', count: remindersCount),
                    _buildTabChip('Follow-up', statusKey: 'follow_up', count: followupsCount),
                    _buildTabChip('Interested', statusKey: 'interested', count: interestedCount),
                    _buildTabChip('Pending Call', statusKey: 'pending_call', count: pendingCallCount),
                    _buildTabChip('Converted', statusKey: 'converted', count: convertedCount),
                    _buildTabChip('Unreachable', statusKey: 'unreachable', count: unreachableCount),
                    _buildTabChip('Wrong Number', statusKey: 'wrong_number', count: wrongNumberCount),
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),

            // ── 3. Leads List (Live API Data & Pagination) ──
            Obx(() {
              final displayed = _displayedLeads;
              final isInitialLoading = _controller.isLoading.value && displayed.isEmpty;
              final isPaginating = _controller.isLoadingMore.value;
              final currentTab = _controller.selectedTab.value;
              final count = displayed.length;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText(
                        '${currentTab.endsWith('Leads') ? currentTab : '$currentTab Leads'} ($count)',
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                      if (_controller.isLoading.value)
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryColor),
                        )
                      else
                        const AppText(
                          'Tap for full details',
                          fontSize: 10.5,
                          color: AppColors.textColorHint,
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  if (isInitialLoading)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(color: AppColors.primaryColor),
                            SizedBox(height: 14),
                            AppText(
                              'Loading assigned leads...',
                              fontSize: 13,
                              color: AppColors.textColorSecondary,
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (displayed.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        children: [
                          const Icon(Iconsax.folder_open, size: 40, color: AppColors.textColorHint),
                          const SizedBox(height: 10),
                          AppText(
                            _controller.errorMessage.value.isNotEmpty
                                ? _controller.errorMessage.value
                                : 'No leads found matching your search.',
                            color: AppColors.textColorSecondary,
                            fontSize: 13,
                            textAlign: TextAlign.center,
                          ),
                          if (_controller.errorMessage.value.isNotEmpty) ...[
                            const SizedBox(height: 14),
                            OutlinedButton.icon(
                              onPressed: () => _controller.fetchLeads(isRefresh: true),
                              icon: const Icon(Icons.refresh, size: 16),
                              label: const Text('Try Again'),
                            ),
                          ],
                        ],
                      ),
                    )
                  else ...[
                    ...displayed.map((item) => _buildTeleCrmLeadCard(TeleCrmLeadItem.fromEmployeeLead(item))),
                    
                    if (isPaginating)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryColor),
                              ),
                              const SizedBox(width: 8),
                              AppText(
                                'Loading more leads (Page ${_controller.currentPage.value + 1} of ${_controller.lastPage.value})...',
                                fontSize: 12,
                                color: AppColors.textColorSecondary,
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (!_controller.hasMore && displayed.length >= 10)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Center(
                          child: AppText(
                            'All ${_controller.totalLeads.value} leads loaded',
                            fontSize: 11,
                            color: AppColors.textColorHint,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ],
              );
            }),

            const SizedBox(height: 100), // Generous FAB spacing so cards are never covered
          ],
        ),
      ),
    );
  }

  Widget _buildTabChip(String label, {String? statusKey, int? count}) {
    final isSelected = statusKey != null && statusKey.isNotEmpty
        ? (_controller.selectedStatus.value == statusKey || _controller.selectedTab.value == label)
        : (_controller.selectedStatus.value.isEmpty && _controller.selectedTab.value == label);
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        selected: isSelected,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppText(
              label,
              fontSize: 11.5,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected ? Colors.white : const Color(0xFF475569),
            ),
            if (count != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white.withValues(alpha: 0.3) : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: AppText(
                  '$count',
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : const Color(0xFF334155),
                ),
              ),
            ],
          ],
        ),
        backgroundColor: Colors.white,
        selectedColor: AppColors.primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: isSelected ? AppColors.primaryColor : const Color(0xFFCBD5E1)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        onSelected: (val) {
          _controller.changeTab(label, status: statusKey);
        },
      ),
    );
  }


  Widget _buildTeleCrmLeadCard(TeleCrmLeadItem lead) {
    final reminder = LeadReminderManager.getReminder(lead.rawId);
    Color statusColor;
    Color statusBgColor;

    final matchingStatus = _controller.leadStatuses.firstWhereOrNull(
      (s) => s.name.toLowerCase() == lead.status.toLowerCase() ||
             (s.slug != null && s.slug!.toLowerCase() == lead.status.toLowerCase()),
    );
    if (matchingStatus != null) {
      statusColor = matchingStatus.color;
      statusBgColor = matchingStatus.color.withValues(alpha: 0.12);
    } else {
      switch (lead.status) {
        case 'Interested':
        case 'interested':
          statusColor = const Color(0xFF16A34A);
          statusBgColor = const Color(0xFFDCFCE7);
          break;
        case 'Follow-up':
        case 'Follow-ups Today':
        case 'follow_up':
        case 'follow-up':
          statusColor = const Color(0xFFD97706);
          statusBgColor = const Color(0xFFFEF3C7);
          break;
        case 'Pending Call':
        case 'pending_call':
        case 'pending call':
          statusColor = const Color(0xFF0284C7);
          statusBgColor = const Color(0xFFE0F2FE);
          break;
        case 'Converted':
        case 'converted':
          statusColor = const Color(0xFF2563EB);
          statusBgColor = const Color(0xFFDBEAFE);
          break;
        case 'Unreachable':
        case 'unreachable':
          statusColor = const Color(0xFF7C3AED);
          statusBgColor = const Color(0xFFEDE9FE);
          break;
        case 'Wrong Number':
        case 'wrong_number':
        case 'wrong number':
          statusColor = const Color(0xFFDC2626);
          statusBgColor = const Color(0xFFFEE2E2);
          break;
        default:
          statusColor = const Color(0xFF475569);
          statusBgColor = const Color(0xFFF1F5F9);
      }
    }

    return GestureDetector(
      onTap: () => Get.to(() => ExecLeadFullDetailScreen(
        lead: lead,
        leadId: lead.rawId,
        onStatusUpdated: () => _controller.fetchLeads(isRefresh: true),
      )),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: lead.isSelfGenerated ? const Color(0xFFE9D5FF) : const Color(0xFFE2E8F0),
            width: lead.isSelfGenerated ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: lead.isSelfGenerated ? const Color(0xFFF3E8FF) : const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: AppText(
                        lead.isSelfGenerated ? 'Self Brought' : 'Admin Assigned',
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        color: lead.isSelfGenerated ? const Color(0xFF7C3AED) : const Color(0xFF2563EB),
                      ),
                    ),
                    const SizedBox(width: 8),
                    AppText(
                      lead.id,
                      fontSize: 10.5,
                      color: AppColors.textColorHint,
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: AppText(
                    lead.status,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        lead.customerName,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textColorPrimary,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Iconsax.location, size: 12, color: AppColors.textColorSecondary),
                          const SizedBox(width: 4),
                          AppText(
                            lead.city,
                            fontSize: 11,
                            color: AppColors.textColorSecondary,
                          ),
                          const SizedBox(width: 10),
                          const Icon(Iconsax.call, size: 12, color: AppColors.textColorSecondary),
                          const SizedBox(width: 4),
                          AppText(
                            lead.phone,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColorPrimary,
                          ),
                          const SizedBox(width: 10),
                          const Icon(Iconsax.wallet_3, size: 12, color: AppColors.textColorSecondary),
                          const SizedBox(width: 4),
                          AppText(
                            '₹${(lead.potentialValue / 1000).toStringAsFixed(0)}k',
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF15803D),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Assigned Employee Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: lead.isReassigned ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: lead.isReassigned ? const Color(0xFFDBEAFE) : const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 11,
                    backgroundImage: NetworkImage(lead.assignedEmployeeAvatar),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                        children: [
                          TextSpan(
                            text: lead.isReassigned ? 'Transferred to: ' : 'Assigned to: ',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          TextSpan(
                            text: lead.assignedEmployee,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: lead.isReassigned ? const Color(0xFF1D4ED8) : const Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: lead.isReassigned ? const Color(0xFFDBEAFE) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: AppText(
                      lead.isReassigned ? 'Transferred' : 'Owner',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: lead.isReassigned ? const Color(0xFF1D4ED8) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Follow-up Reminder Banner (if reminder set or follow-up date set)
            if (reminder != null) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: reminder.isCompleted
                      ? const Color(0xFFF0FDF4)
                      : reminder.isOverdue
                          ? const Color(0xFFFEF2F2)
                          : reminder.isDueToday
                              ? const Color(0xFFFFFBEB)
                              : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: reminder.isCompleted
                        ? const Color(0xFFBBF7D0)
                        : reminder.isOverdue
                            ? const Color(0xFFFECACA)
                            : reminder.isDueToday
                                ? const Color(0xFFFDE68A)
                                : const Color(0xFFBFDBFE),
                    width: 1.2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          reminder.isCompleted
                              ? Icons.check_circle_rounded
                              : reminder.isOverdue
                                  ? Icons.error_outline_rounded
                                  : Iconsax.timer_1,
                          size: 16,
                          color: reminder.isCompleted
                              ? const Color(0xFF16A34A)
                              : reminder.isOverdue
                                  ? const Color(0xFFDC2626)
                                  : reminder.isDueToday
                                      ? const Color(0xFFD97706)
                                      : const Color(0xFF2563EB),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            reminder.isCompleted
                                ? 'Follow-up Reminder Completed'
                                : reminder.isOverdue
                                    ? 'Overdue Follow-up ${reminder.reminderType}: ${DateFormat('dd MMM, hh:mm a').format(reminder.scheduledAt)}'
                                    : reminder.isDueToday
                                        ? 'Due Today: ${DateFormat('hh:mm a').format(reminder.scheduledAt)} • ${reminder.reminderType}'
                                        : 'Follow-up ${reminder.reminderType}: ${DateFormat('EEE, dd MMM • hh:mm a').format(reminder.scheduledAt)}',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: reminder.isCompleted
                                  ? const Color(0xFF15803D)
                                  : reminder.isOverdue
                                      ? const Color(0xFFB91C1C)
                                      : reminder.isDueToday
                                          ? const Color(0xFFB45309)
                                          : const Color(0xFF1D4ED8),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () => showLeadReminderModal(
                            context: context,
                            lead: lead,
                            onUpdated: () => setState(() {}),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            child: Icon(Icons.more_vert_rounded, size: 16, color: Color(0xFF64748B)),
                          ),
                        ),
                      ],
                    ),
                    if (reminder.note.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        '"${reminder.note}"',
                        style: const TextStyle(
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    // Quick Action Buttons on Reminder Banner
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (reminder.reminderType == 'Call')
                          TextButton.icon(
                            onPressed: () => _makePhoneCall(lead.phone),
                            icon: const Icon(Icons.phone_rounded, size: 13, color: Color(0xFF059669)),
                            label: const Text('Call Client', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF059669))),
                            style: TextButton.styleFrom(
                              backgroundColor: const Color(0xFFDCFCE7),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        if (reminder.reminderType == 'WhatsApp') ...[
                          TextButton.icon(
                            onPressed: () => _sendWhatsAppMessage(lead.phone, message: reminder.note.isNotEmpty ? reminder.note : null),
                            icon: const Icon(Icons.chat_rounded, size: 13, color: Color(0xFF16A34A)),
                            label: const Text('WhatsApp', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF16A34A))),
                            style: TextButton.styleFrom(
                              backgroundColor: const Color(0xFFDCFCE7),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ],
                        if (reminder.reminderType == 'SMS') ...[
                          TextButton.icon(
                            onPressed: () => _sendSmsMessage(lead.phone, message: reminder.note.isNotEmpty ? reminder.note : null),
                            icon: const Icon(Icons.message_rounded, size: 13, color: Color(0xFF2563EB)),
                            label: const Text('Send SMS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                            style: TextButton.styleFrom(
                              backgroundColor: const Color(0xFFEFF6FF),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ],
                        const SizedBox(width: 8),
                        TextButton.icon(
                          onPressed: () async {
                            await LeadReminderManager.toggleComplete(lead.rawId);
                            setState(() {});
                          },
                          icon: Icon(
                            reminder.isCompleted ? Icons.undo_rounded : Icons.check_circle_outline_rounded,
                            size: 13,
                            color: const Color(0xFF64748B),
                          ),
                          label: Text(
                            reminder.isCompleted ? 'Reopen' : 'Mark Done',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xFFF1F5F9),
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ] else if (lead.nextFollowupDateTime != null) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFCD34D)),
                ),
                child: Row(
                  children: [
                    const Icon(Iconsax.timer_1, size: 14, color: Color(0xFFD97706)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: AppText(
                        'Next Follow-up Call: ${DateFormat('dd MMM, hh:mm a').format(lead.nextFollowupDateTime!)}',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFB45309),
                      ),
                    ),
                    InkWell(
                      onTap: () => showLeadReminderModal(context: context, lead: lead, onUpdated: () => setState(() {})),
                      child: const AppText('Configure', fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFFD97706)),
                    ),
                  ],
                ),
              ),
            ],

            // 🚀 Converted Lead: Project Handover Banner
            if (lead.status == 'Converted') ...[
              Builder(
                builder: (context) {
                  final handover = LeadProjectHandoverManager.getHandover(lead.rawId);
                  final hasProject = handover != null;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: hasProject
                            ? [const Color(0xFFF0FDF4), const Color(0xFFDCFCE7)]
                            : [const Color(0xFFEFF6FF), const Color(0xFFEEF2FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: hasProject ? const Color(0xFF86EFAC) : const Color(0xFFC7D2FE),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: hasProject ? const Color(0xFF16A34A) : AppColors.primaryColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            hasProject ? Icons.folder_special_rounded : Icons.rocket_launch_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                hasProject ? 'Project Handover Active 🚀' : 'Deal Converted! Project Handover',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: hasProject ? const Color(0xFF15803D) : const Color(0xFF1E1B4B),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                hasProject
                                    ? '${handover.projectName} • ${handover.durationDays} Days target'
                                    : 'Create active project & attach client documents',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  color: hasProject ? const Color(0xFF166534) : const Color(0xFF4338CA),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (hasProject && handover.createdProjectId != null) {
                              Get.to(() => ProjectDetailsScreen(projectId: handover.createdProjectId));
                            } else {
                              Get.to(() => SalesConvertToProjectScreen(
                                    lead: lead,
                                    onProjectCreated: () => setState(() {}),
                                  ));
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: hasProject ? const Color(0xFF16A34A) : AppColors.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            elevation: 0,
                          ),
                          child: Text(
                            hasProject ? 'View' : 'Create 🚀',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],

            // Last Discussion Note
            if (lead.lastCallNote.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const AppText('Last Call Discussion:', fontSize: 9.5, color: AppColors.textColorHint, fontWeight: FontWeight.bold),
                        AppText('Duration: ${lead.lastCallDuration}', fontSize: 9.5, color: AppColors.textColorSecondary),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      lead.lastCallNote,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF334155),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 12),

            // ── Modern Unified Action Toolbar (4 Professional Balanced Buttons) ──
            Row(
              children: [
                // 1. Call Action (Emerald Tonal)
                Expanded(
                  child: Material(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () => _makePhoneCall(lead.phone),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 38,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFA7F3D0)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.phone_rounded, size: 13, color: Color(0xFF059669)),
                            SizedBox(width: 3),
                            AppText('Call', fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF059669)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),

                // 2. Status Action (Slate Tonal)
                Expanded(
                  child: Material(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () => _showUpdateStatusModal(lead),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 38,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.edit_note_rounded, size: 15, color: Color(0xFF334155)),
                            SizedBox(width: 3),
                            AppText('Status', fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),

                // 3. Reminder Action (Purple/Amber Tonal with active badge)
                Expanded(
                  child: Material(
                    color: reminder != null
                        ? (reminder.isCompleted ? const Color(0xFFF0FDF4) : const Color(0xFFFFFBEB))
                        : const Color(0xFFFAF5FF),
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () => showLeadReminderModal(
                        context: context,
                        lead: lead,
                        onUpdated: () => setState(() {}),
                      ),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 38,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: reminder != null
                                ? (reminder.isCompleted ? const Color(0xFF86EFAC) : const Color(0xFFFDE68A))
                                : const Color(0xFFE9D5FF),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Iconsax.timer_1,
                              size: 13,
                              color: reminder != null
                                  ? (reminder.isCompleted ? const Color(0xFF16A34A) : const Color(0xFFD97706))
                                  : const Color(0xFF7C3AED),
                            ),
                            const SizedBox(width: 3),
                            AppText(
                              reminder != null ? (reminder.isCompleted ? 'Done' : 'Remind') : 'Remind',
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: reminder != null
                                  ? (reminder.isCompleted ? const Color(0xFF16A34A) : const Color(0xFFD97706))
                                  : const Color(0xFF7C3AED),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),

                // 4. Assign / Project Action (Dynamic for Converted Leads)
                Builder(
                  builder: (context) {
                    final isConverted = lead.status == 'Converted';
                    final handover = isConverted ? LeadProjectHandoverManager.getHandover(lead.rawId) : null;
                    final hasProject = handover != null;

                    return Expanded(
                      child: Material(
                        color: isConverted
                            ? (hasProject ? const Color(0xFFECFDF5) : const Color(0xFFEFF6FF))
                            : const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          onTap: () {
                            if (isConverted) {
                              if (hasProject && handover.createdProjectId != null) {
                                Get.to(() => ProjectDetailsScreen(projectId: handover.createdProjectId));
                              } else {
                                Get.to(() => SalesConvertToProjectScreen(
                                      lead: lead,
                                      onProjectCreated: () => setState(() {}),
                                    ));
                              }
                            } else {
                              showAssignLeadToColleagueModal(
                                context: context,
                                lead: lead,
                                onAssigned: () => _controller.fetchLeads(isRefresh: true),
                              );
                            }
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            height: 38,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isConverted
                                    ? (hasProject ? const Color(0xFFA7F3D0) : const Color(0xFFBFDBFE))
                                    : const Color(0xFFBFDBFE),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isConverted
                                      ? (hasProject ? Icons.folder_special_rounded : Icons.rocket_launch_rounded)
                                      : Icons.swap_horiz_rounded,
                                  size: 14,
                                  color: isConverted
                                      ? (hasProject ? const Color(0xFF059669) : const Color(0xFF2563EB))
                                      : const Color(0xFF2563EB),
                                ),
                                const SizedBox(width: 3),
                                AppText(
                                  isConverted
                                      ? (hasProject ? 'Project' : 'Create Proj')
                                      : 'Assign',
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: isConverted
                                      ? (hasProject ? const Color(0xFF059669) : const Color(0xFF2563EB))
                                      : const Color(0xFF2563EB),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdateStatusModal(TeleCrmLeadItem lead) {
    showUpdateLeadStatusModal(
      context: context,
      lead: lead,
      onUpdated: () {
        setState(() {});
        _controller.fetchLeads(isRefresh: true);
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 🎉 IMMEDIATE PROJECT HANDOVER PROMPT AFTER CONVERSION
// ─────────────────────────────────────────────────────────────────────────────
void _showConvertedLeadHandoverPrompt(TeleCrmLeadItem lead, VoidCallback onUpdated) {
  Get.bottomSheet(
    Container(
      padding: const EdgeInsets.all(22),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Icon(Icons.rocket_launch_rounded, color: Color(0xFF16A34A), size: 30),
            ),
            const SizedBox(height: 14),
            const Text(
              'Lead Converted to Customer! 🎉',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              '${lead.customerName} (${lead.id}) is now converted with deal value ₹${(lead.potentialValue / 1000).toStringAsFixed(0)}k.',
              style: const TextStyle(
                fontSize: 12.5,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: Color(0xFF2563EB), size: 18),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Sales handover: You can create the active project now, set completion duration, and attach all client documents.',
                      style: TextStyle(fontSize: 11.5, color: Color(0xFF334155), height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.back(); // close sheet
                  Get.to(() => SalesConvertToProjectScreen(
                        lead: lead,
                        onProjectCreated: onUpdated,
                      ));
                },
                icon: const Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 18),
                label: const Text(
                  'Create Project Handover Now 🚀',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Get.back(),
                child: const Text(
                  'I Will Create Project Later',
                  style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// 🚀 UPDATE LEAD STATUS MODAL (PATCH /api/employee/leads/{id}/status)
// ─────────────────────────────────────────────────────────────────────────────
void showUpdateLeadStatusModal({
  required BuildContext context,
  required TeleCrmLeadItem lead,
  required VoidCallback onUpdated,
}) {
  final controller = EmployeeTeleCrmController.to;
  if (controller.leadStatuses.isEmpty) {
    controller.fetchLeadStatuses();
  }

  // Find initial status model matching current lead.status
  LeadStatusModel? initialMatched;
  final currentStatusLower = lead.status.trim().toLowerCase();
  for (final s in controller.leadStatuses) {
    if (s.name.toLowerCase() == currentStatusLower ||
        (s.slug != null && s.slug!.toLowerCase() == currentStatusLower) ||
        (s.slug != null && s.slug!.replaceAll('_', ' ').toLowerCase() == currentStatusLower)) {
      initialMatched = s;
      break;
    }
  }

  LeadStatusModel? selectedStatus = initialMatched ??
      (controller.leadStatuses.isNotEmpty ? controller.leadStatuses.first : null);

  final noteController = TextEditingController();
  bool isSubmitting = false;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (modalCtx) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          final currentColor = selectedStatus?.color ?? AppColors.primaryColor;
          final statusNameLower = selectedStatus?.name.toLowerCase() ?? '';
          final statusSlugLower = selectedStatus?.slug?.toLowerCase() ?? '';
          final isConverted = statusNameLower == 'converted' ||
              statusSlugLower == 'converted' ||
              (selectedStatus?.category.toLowerCase() == 'won');
          final isFollowUp = statusNameLower.contains('follow') || statusSlugLower.contains('follow');
          final isPendingCall = statusNameLower.contains('pending') || statusSlugLower.contains('pending');

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(modalCtx).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle Bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const AppText(
                            'Update Lead Status',
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                          const SizedBox(height: 3),
                          AppText(
                            '${lead.customerName} (${lead.id})',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF64748B),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 22, color: Color(0xFF64748B)),
                        onPressed: () => Navigator.pop(modalCtx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Status Chips (Loaded dynamically from GET /api/admin/lead-statuses)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const AppText(
                        'Select Status *',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF334155),
                      ),
                      Obx(() {
                        if (controller.isLoadingStatuses.value) {
                          return const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF64748B)),
                          );
                        }
                        return Text(
                          '${controller.leadStatuses.length} statuses',
                          style: const TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Obx(() {
                    final statuses = controller.leadStatuses;
                    if (statuses.isEmpty && controller.isLoadingStatuses.value) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      );
                    }

                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: statuses.map((statusItem) {
                        final isSelected = selectedStatus?.id == statusItem.id ||
                            (selectedStatus?.name.toLowerCase() == statusItem.name.toLowerCase());
                        final chipColor = statusItem.color;

                        return InkWell(
                          onTap: () {
                            setModalState(() {
                              selectedStatus = statusItem;
                            });
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7.5),
                            decoration: BoxDecoration(
                              color: isSelected ? chipColor : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected ? chipColor : const Color(0xFFE2E8F0),
                                width: isSelected ? 1.5 : 1,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: chipColor.withValues(alpha: 0.25),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isSelected) ...[
                                  const Icon(Icons.check_rounded, size: 14, color: Colors.white),
                                  const SizedBox(width: 5),
                                ] else ...[
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: BoxDecoration(
                                      color: chipColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                ],
                                Text(
                                  statusItem.name,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isSelected ? Colors.white : const Color(0xFF334155),
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  }),

                  if (isConverted) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 18),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Converting this lead will permanently lock reassignment and mark the deal as won.',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: Color(0xFF065F46),
                                fontWeight: FontWeight.w600,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),

                  // Call Note / Update Details
                  const AppText(
                    'Call Note / Update Details',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF334155),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: noteController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'E.g., Client wants a product demo tomorrow...',
                      hintStyle: const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                  if (isFollowUp || isPendingCall) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Iconsax.timer_1, color: Color(0xFFD97706), size: 20),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Set Follow-up Reminder', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF92400E))),
                                SizedBox(height: 1),
                                Text('Schedule next call or message alert for this client', style: TextStyle(fontSize: 10.5, color: Color(0xFFB45309))),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(modalCtx);
                              showLeadReminderModal(context: context, lead: lead, onUpdated: onUpdated);
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: const Color(0xFFFBBF24),
                              foregroundColor: const Color(0xFF78350F),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Set ⏰', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),

                  // Submit Button calling PATCH /api/employee/leads/{id}/status
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isSubmitting || selectedStatus == null
                          ? null
                          : () async {
                              setModalState(() {
                                isSubmitting = true;
                              });

                              final callNote = noteController.text.trim();
                              final statusNameToSet = selectedStatus!.name;

                              // Call PATCH /api/employee/leads/{id}/status
                              final result = await controller.updateLeadStatus(
                                lead.rawId,
                                status: statusNameToSet,
                                statusId: selectedStatus!.id,
                                slug: selectedStatus!.slug,
                                callNote: callNote.isNotEmpty ? callNote : null,
                              );

                              if (result.success) {
                                final prevStatus = lead.status;
                                lead.status = statusNameToSet;
                                lead.processSteps.insert(
                                  0,
                                  ExecLeadProcessStep(
                                    title: isConverted
                                        ? 'Converted to Customer 🎉'
                                        : 'Status updated from $prevStatus to $statusNameToSet',
                                    date: DateFormat('dd MMM yyyy').format(DateTime.now()),
                                    time: DateFormat('hh:mm a').format(DateTime.now()),
                                    note: callNote.isNotEmpty
                                        ? callNote
                                        : (isConverted
                                            ? 'Lead closed & converted successfully.'
                                            : 'Updated via Executive App'),
                                    performedBy: 'You',
                                    isCompleted: true,
                                  ),
                                );

                                if (modalCtx.mounted) {
                                  Navigator.pop(modalCtx);
                                }
                                onUpdated();

                                if (isConverted) {
                                  Future.delayed(const Duration(milliseconds: 350), () {
                                    _showConvertedLeadHandoverPrompt(lead, onUpdated);
                                  });
                                }

                                Get.snackbar(
                                  isConverted
                                      ? 'Lead Converted 🎉'
                                      : 'Status Updated',
                                  result.message.isNotEmpty
                                      ? result.message
                                      : (isConverted
                                          ? 'Congratulations! Deal successfully closed.'
                                          : 'Lead status has been updated to $statusNameToSet.'),
                                  backgroundColor: isConverted
                                      ? const Color(0xFF10B981)
                                      : currentColor,
                                  colorText: Colors.white,
                                  snackPosition: SnackPosition.BOTTOM,
                                  icon: Icon(
                                    isConverted
                                        ? Icons.celebration_rounded
                                        : Icons.check_circle_rounded,
                                    color: Colors.white,
                                  ),
                                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                                  borderRadius: 14,
                                );
                              } else {
                                setModalState(() {
                                  isSubmitting = false;
                                });
                                Get.snackbar(
                                  'Update Failed',
                                  result.message.isNotEmpty
                                      ? result.message
                                      : 'Could not update lead status. Please try again.',
                                  backgroundColor: const Color(0xFFEF4444),
                                  colorText: Colors.white,
                                  snackPosition: SnackPosition.BOTTOM,
                                  icon: const Icon(Icons.error_outline_rounded, color: Colors.white),
                                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                                  borderRadius: 14,
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: currentColor,
                        disabledBackgroundColor: currentColor.withValues(alpha: 0.6),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: isSubmitting
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Updating Status...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isConverted ? Icons.celebration_rounded : Icons.save_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Update Status to ${selectedStatus?.name ?? lead.status}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// ⏰ SET / MANAGE FOLLOW-UP REMINDER MODAL
// ─────────────────────────────────────────────────────────────────────────────
void showLeadReminderModal({
  required BuildContext context,
  required TeleCrmLeadItem lead,
  VoidCallback? onUpdated,
}) {
  final existingReminder = LeadReminderManager.getReminder(lead.rawId);
  String selectedType = existingReminder?.reminderType ?? 'Call';
  DateTime selectedDateTime = existingReminder?.scheduledAt ?? DateTime.now().add(const Duration(hours: 2));
  final noteController = TextEditingController(text: existingReminder?.note ?? '');
  bool isCompleted = existingReminder?.isCompleted ?? false;
  bool isSubmitting = false;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (modalCtx) {
      return StatefulBuilder(
        builder: (ctx, setModalState) {
          final isOverdue = !isCompleted && selectedDateTime.isBefore(DateTime.now());
          final isToday = !isCompleted &&
              selectedDateTime.year == DateTime.now().year &&
              selectedDateTime.month == DateTime.now().month &&
              selectedDateTime.day == DateTime.now().day;

          return Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(modalCtx).viewInsets.bottom + 24,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Header with Client Info & Action Icon
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Iconsax.timer_1, color: Color(0xFFD97706), size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              existingReminder != null ? 'Manage Follow-up Reminder' : 'Set Follow-up Reminder',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${lead.customerName} (${lead.id})',
                              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(modalCtx),
                        icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  const SizedBox(height: 16),

                  // Reminder Type selector: Call, WhatsApp, SMS, Meeting
                  const Text(
                    'Reminder Type / Action',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildReminderTypeBtn(
                        label: 'Call',
                        icon: Icons.phone_rounded,
                        activeColor: const Color(0xFF059669),
                        isSelected: selectedType == 'Call',
                        onTap: () => setModalState(() => selectedType = 'Call'),
                      ),
                      const SizedBox(width: 8),
                      _buildReminderTypeBtn(
                        label: 'WhatsApp',
                        icon: Icons.chat_rounded,
                        activeColor: const Color(0xFF16A34A),
                        isSelected: selectedType == 'WhatsApp',
                        onTap: () => setModalState(() => selectedType = 'WhatsApp'),
                      ),
                      const SizedBox(width: 8),
                      _buildReminderTypeBtn(
                        label: 'SMS',
                        icon: Icons.sms_rounded,
                        activeColor: const Color(0xFF2563EB),
                        isSelected: selectedType == 'SMS',
                        onTap: () => setModalState(() => selectedType = 'SMS'),
                      ),
                      const SizedBox(width: 8),
                      _buildReminderTypeBtn(
                        label: 'Meeting',
                        icon: Icons.video_call_rounded,
                        activeColor: const Color(0xFF7C3AED),
                        isSelected: selectedType == 'Meeting',
                        onTap: () => setModalState(() => selectedType = 'Meeting'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Quick Schedule Presets
                  const Text(
                    'Quick Presets',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildPresetChip('+1 Hour', () {
                          setModalState(() {
                            selectedDateTime = DateTime.now().add(const Duration(hours: 1));
                          });
                        }),
                        const SizedBox(width: 8),
                        _buildPresetChip('+3 Hours', () {
                          setModalState(() {
                            selectedDateTime = DateTime.now().add(const Duration(hours: 3));
                          });
                        }),
                        const SizedBox(width: 8),
                        _buildPresetChip('Today 4:00 PM', () {
                          final now = DateTime.now();
                          setModalState(() {
                            selectedDateTime = DateTime(now.year, now.month, now.day, 16, 0);
                          });
                        }),
                        const SizedBox(width: 8),
                        _buildPresetChip('Tomorrow 10:00 AM', () {
                          final tmrw = DateTime.now().add(const Duration(days: 1));
                          setModalState(() {
                            selectedDateTime = DateTime(tmrw.year, tmrw.month, tmrw.day, 10, 0);
                          });
                        }),
                        const SizedBox(width: 8),
                        _buildPresetChip('Tomorrow 3:00 PM', () {
                          final tmrw = DateTime.now().add(const Duration(days: 1));
                          setModalState(() {
                            selectedDateTime = DateTime(tmrw.year, tmrw.month, tmrw.day, 15, 0);
                          });
                        }),
                        const SizedBox(width: 8),
                        _buildPresetChip('In 2 Days', () {
                          final inTwoDays = DateTime.now().add(const Duration(days: 2));
                          setModalState(() {
                            selectedDateTime = DateTime(inTwoDays.year, inTwoDays.month, inTwoDays.day, 11, 0);
                          });
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Scheduled Date & Time Display + Pickers
                  const Text(
                    'Scheduled Date & Time',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat('EEEE, dd MMM yyyy').format(selectedDateTime),
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(Icons.access_time_filled_rounded, size: 13, color: AppColors.primaryColor),
                                  const SizedBox(width: 4),
                                  Text(
                                    DateFormat('hh:mm a').format(selectedDateTime),
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                                  ),
                                  const SizedBox(width: 8),
                                  if (isToday)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFEF3C7),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text('Today', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFFB45309))),
                                    ),
                                  if (isOverdue)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFEE2E2),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text('Overdue', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFFDC2626))),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Date picker button
                        OutlinedButton.icon(
                          onPressed: () async {
                            final pickedDate = await showDatePicker(
                              context: modalCtx,
                              initialDate: selectedDateTime,
                              firstDate: DateTime.now().subtract(const Duration(days: 1)),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (pickedDate != null) {
                              setModalState(() {
                                selectedDateTime = DateTime(
                                  pickedDate.year,
                                  pickedDate.month,
                                  pickedDate.day,
                                  selectedDateTime.hour,
                                  selectedDateTime.minute,
                                );
                              });
                            }
                          },
                          icon: const Icon(Icons.calendar_today_rounded, size: 14),
                          label: const Text('Date', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF334155),
                            side: const BorderSide(color: Color(0xFFCBD5E1)),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Time picker button
                        OutlinedButton.icon(
                          onPressed: () async {
                            final pickedTime = await showTimePicker(
                              context: modalCtx,
                              initialTime: TimeOfDay.fromDateTime(selectedDateTime),
                            );
                            if (pickedTime != null) {
                              setModalState(() {
                                selectedDateTime = DateTime(
                                  selectedDateTime.year,
                                  selectedDateTime.month,
                                  selectedDateTime.day,
                                  pickedTime.hour,
                                  pickedTime.minute,
                                );
                              });
                            }
                          },
                          icon: const Icon(Icons.schedule_rounded, size: 14),
                          label: const Text('Time', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF334155),
                            side: const BorderSide(color: Color(0xFFCBD5E1)),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Reminder Note / Agenda
                  const Text(
                    'Follow-up Note / Discussion Agenda',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: noteController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'e.g. Call client for price quotation and demo follow-up...',
                      hintStyle: const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // If existing, complete toggle
                  if (existingReminder != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isCompleted ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isCompleted ? const Color(0xFFBBF7D0) : const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                            color: isCompleted ? const Color(0xFF16A34A) : const Color(0xFF64748B),
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              isCompleted ? 'Marked as Completed' : 'Pending Follow-up Action',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: isCompleted ? const Color(0xFF15803D) : const Color(0xFF334155),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setModalState(() {
                                isCompleted = !isCompleted;
                              });
                            },
                            child: Text(
                              isCompleted ? 'Reopen' : 'Mark Done',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isCompleted ? const Color(0xFF64748B) : const Color(0xFF16A34A),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Action Buttons: Delete (if exists) & Save Reminder
                  Row(
                    children: [
                      if (existingReminder != null) ...[
                        OutlinedButton(
                          onPressed: () async {
                            await LeadReminderManager.removeReminder(lead.rawId);
                            if (modalCtx.mounted) Navigator.pop(modalCtx);
                            onUpdated?.call();
                            Get.snackbar(
                              'Reminder Removed',
                              'Follow-up reminder has been removed for ${lead.customerName}.',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: const Color(0xFF475569),
                              colorText: Colors.white,
                              margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                              borderRadius: 14,
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFDC2626),
                            side: const BorderSide(color: Color(0xFFFCA5A5)),
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Icon(Icons.delete_outline_rounded, size: 20, color: Color(0xFFDC2626)),
                        ),
                        const SizedBox(width: 10),
                      ],
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  final note = noteController.text.trim();
                                  final action = selectedType.toLowerCase();
                                  final agenda = note.isNotEmpty
                                      ? note
                                      : 'Scheduled $selectedType follow-up with client.';

                                  // Format scheduled_at with timezone offset (e.g. 2026-10-23T16:00:00+05:30)
                                  final offset = selectedDateTime.timeZoneOffset;
                                  final sign = offset.isNegative ? '-' : '+';
                                  final hours = offset.inHours.abs().toString().padLeft(2, '0');
                                  final minutes = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');
                                  final formattedScheduledAt =
                                      '${DateFormat('yyyy-MM-ddTHH:mm:ss').format(selectedDateTime)}$sign$hours:$minutes';

                                  final targetLeadId = lead.rawId != 0
                                      ? lead.rawId
                                      : (int.tryParse(lead.id.replaceAll(RegExp(r'[^0-9]'), '')) ?? lead.rawId);

                                  setModalState(() {
                                    isSubmitting = true;
                                  });

                                  final controller = EmployeeTeleCrmController.to;
                                  final res = await controller.createLeadReminder(
                                    targetLeadId,
                                    action: action,
                                    scheduledAt: formattedScheduledAt,
                                    agenda: agenda,
                                  );

                                  if (!modalCtx.mounted) return;

                                  if (res.success) {
                                    final reminder = LeadReminderModel(
                                      leadId: lead.rawId,
                                      leadCode: lead.id,
                                      customerName: lead.customerName,
                                      phone: lead.phone,
                                      scheduledAt: selectedDateTime,
                                      reminderType: selectedType,
                                      note: note,
                                      isCompleted: isCompleted,
                                    );

                                    await LeadReminderManager.saveReminder(reminder);

                                    // Also append step to timeline
                                    lead.nextFollowupDateTime = selectedDateTime;
                                    lead.processSteps.insert(
                                      0,
                                      ExecLeadProcessStep(
                                        title: '⏰ Reminder Set: $selectedType',
                                        date: DateFormat('dd MMM yyyy').format(selectedDateTime),
                                        time: DateFormat('hh:mm a').format(selectedDateTime),
                                        note: agenda,
                                        performedBy: 'You',
                                        isCompleted: isCompleted,
                                      ),
                                    );

                                    if (modalCtx.mounted) Navigator.pop(modalCtx);
                                    onUpdated?.call();

                                    Get.snackbar(
                                      'Reminder Set ⏰',
                                      res.message.isNotEmpty
                                          ? res.message
                                          : 'Scheduled $selectedType with ${lead.customerName} on ${DateFormat('EEE, dd MMM • hh:mm a').format(selectedDateTime)}',
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: const Color(0xFF0F172A),
                                      colorText: Colors.white,
                                      icon: const Icon(Iconsax.timer_1, color: Color(0xFFFBBF24)),
                                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                                      borderRadius: 14,
                                    );
                                  } else {
                                    setModalState(() {
                                      isSubmitting = false;
                                    });
                                    Get.snackbar(
                                      'Failed to Set Reminder',
                                      res.message.isNotEmpty
                                          ? res.message
                                          : 'Please check your details and try again.',
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: const Color(0xFFDC2626),
                                      colorText: Colors.white,
                                      icon: const Icon(Icons.error_outline_rounded, color: Colors.white),
                                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                                      borderRadius: 14,
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            disabledBackgroundColor: AppColors.primaryColor.withValues(alpha: 0.6),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            elevation: 0,
                          ),
                          child: isSubmitting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.alarm_on_rounded, color: Colors.white, size: 18),
                                    const SizedBox(width: 8),
                                    Text(
                                      existingReminder != null ? 'Update Reminder' : 'Set Reminder',
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

Widget _buildReminderTypeBtn({
  required String label,
  required IconData icon,
  required Color activeColor,
  required bool isSelected,
  required VoidCallback onTap,
}) {
  return Expanded(
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withValues(alpha: 0.12) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? activeColor : const Color(0xFFE2E8F0),
            width: isSelected ? 1.6 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: isSelected ? activeColor : const Color(0xFF64748B)),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? activeColor : const Color(0xFF475569),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildPresetChip(String label, VoidCallback onTap) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(18),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// 🚀 REASSIGN LEAD TO ANOTHER EMPLOYEE MODAL (PROVISION FOR UNCONVERTED LEADS)
// ─────────────────────────────────────────────────────────────────────────────
void showAssignLeadToColleagueModal({
  required BuildContext context,
  required TeleCrmLeadItem lead,
  required VoidCallback onAssigned,
}) {
  // Guard check: cannot reassign converted lead
  if (lead.status == 'Converted') {
    Get.snackbar(
      'Reassignment Locked',
      'This lead is already converted and cannot be reassigned to another employee.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF475569),
      colorText: Colors.white,
      icon: const Icon(Icons.lock_rounded, color: Colors.white),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      borderRadius: 14,
    );
    return;
  }

  final controller = EmployeeTeleCrmController.to;
  SalesEmployeeModel? selectedEmployee;
  String selectedReason = 'Workload Balancing';
  final noteController = TextEditingController(text: 'Assigned for follow-up and client meeting.');
  final searchController = TextEditingController();
  Timer? searchDebounce;
  bool isSubmitting = false;

  // Trigger initial fetch of live sales employees from API
  controller.fetchSalesEmployees();

  final List<String> transferReasons = [
    'Workload Balancing',
    'Branch / Location Transfer',
    'Language Preference',
    'Enterprise Specialist',
    'Client Requested Callback',
    'Special Deal Term Requirement',
  ];

  String mapReasonToSnakeCase(String reason) {
    switch (reason) {
      case 'Workload Balancing':
        return 'workload_balancing';
      case 'Branch / Location Transfer':
        return 'branch_location_transfer';
      case 'Language Preference':
        return 'language_preference';
      case 'Enterprise Specialist':
        return 'enterprise_specialist';
      case 'Client Requested Callback':
        return 'client_requested_callback';
      case 'Special Deal Term Requirement':
        return 'special_deal_term_requirement';
      default:
        return reason.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_').replaceAll(RegExp(r'^_+|_+$'), '');
    }
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (modalCtx) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(modalCtx).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle Bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const AppText(
                            'Assign Lead to Colleague',
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                          const SizedBox(height: 3),
                          AppText(
                            '${lead.customerName} (${lead.id})',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF64748B),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 22, color: Color(0xFF64748B)),
                        onPressed: () {
                          searchDebounce?.cancel();
                          Navigator.pop(modalCtx);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Provision Policy Information Banner
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline_rounded, color: Color(0xFF2563EB), size: 18),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Provision: You can transfer this lead to another sales executive as long as it has not been converted. Once converted, the deal is permanently won.',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF1E40AF),
                              fontWeight: FontWeight.w500,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Search Sales Executive Colleague
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: TextField(
                      controller: searchController,
                      onChanged: (val) {
                        setModalState(() {});
                        searchDebounce?.cancel();
                        searchDebounce = Timer(const Duration(milliseconds: 350), () {
                          controller.fetchSalesEmployees(search: val.trim());
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search colleague name, role, email...',
                        hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                        prefixIcon: const Icon(Iconsax.search_normal, size: 18, color: Color(0xFF94A3B8)),
                        suffixIcon: searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close_rounded, size: 16, color: Color(0xFF94A3B8)),
                                onPressed: () {
                                  searchController.clear();
                                  setModalState(() {});
                                  controller.fetchSalesEmployees();
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Header with Count
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const AppText(
                        'Select Colleague *',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF334155),
                      ),
                      Obx(() {
                        if (controller.isLoadingSalesEmployees.value) {
                          return const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryColor),
                          );
                        }
                        return AppText(
                          '${controller.salesEmployees.length} Available',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Live Sales Employees Selectable Cards List
                  Container(
                    constraints: const BoxConstraints(maxHeight: 230),
                    child: Obx(() {
                      final query = searchController.text.trim().toLowerCase();
                      final allEmployees = controller.salesEmployees;
                      final filteredColleagues = query.isEmpty
                          ? allEmployees
                          : allEmployees.where((c) {
                              final nameMatch = c.name.toLowerCase().contains(query);
                              final roleMatch = (c.designation ?? c.role ?? '').toLowerCase().contains(query);
                              final emailMatch = (c.email ?? '').toLowerCase().contains(query);
                              final deptMatch = (c.department ?? '').toLowerCase().contains(query);
                              return nameMatch || roleMatch || emailMatch || deptMatch;
                            }).toList();

                      if (controller.isLoadingSalesEmployees.value && allEmployees.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primaryColor),
                                SizedBox(height: 12),
                                AppText(
                                  'Loading sales colleagues...',
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w500,
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      if (filteredColleagues.isEmpty) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.person_search_rounded, size: 36, color: Color(0xFF94A3B8)),
                              const SizedBox(height: 8),
                              AppText(
                                query.isNotEmpty
                                    ? 'No colleague found matching "$query"'
                                    : 'No sales colleagues found.',
                                fontSize: 12.5,
                                color: const Color(0xFF64748B),
                                fontWeight: FontWeight.w600,
                              ),
                              if (query.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                TextButton(
                                  onPressed: () {
                                    searchController.clear();
                                    setModalState(() {});
                                    controller.fetchSalesEmployees();
                                  },
                                  child: const Text('Clear search filter', style: TextStyle(fontSize: 12)),
                                ),
                              ],
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        itemCount: filteredColleagues.length,
                        itemBuilder: (context, index) {
                          final colleague = filteredColleagues[index];
                          final isSelected = selectedEmployee?.id == colleague.id;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  setModalState(() {
                                    selectedEmployee = colleague;
                                  });
                                },
                                borderRadius: BorderRadius.circular(14),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                                  decoration: BoxDecoration(
                                    color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                                      width: isSelected ? 1.6 : 1.0,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: const Color(0xFF2563EB).withValues(alpha: 0.10),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.02),
                                              blurRadius: 4,
                                              offset: const Offset(0, 1),
                                            ),
                                          ],
                                  ),
                                  child: Row(
                                    children: [
                                      // Avatar
                                      Stack(
                                        children: [
                                          CircleAvatar(
                                            radius: 19,
                                            backgroundColor: isSelected ? const Color(0xFFDBEAFE) : const Color(0xFFF1F5F9),
                                            backgroundImage: (colleague.avatar != null && colleague.avatar!.isNotEmpty)
                                                ? NetworkImage(colleague.avatar!)
                                                : null,
                                            child: (colleague.avatar == null || colleague.avatar!.isEmpty)
                                                ? Text(
                                                    colleague.name.isNotEmpty ? colleague.name[0].toUpperCase() : 'E',
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.bold,
                                                      color: isSelected ? const Color(0xFF1D4ED8) : const Color(0xFF334155),
                                                    ),
                                                  )
                                                : null,
                                          ),
                                          if (isSelected)
                                            Positioned(
                                              right: 0,
                                              bottom: 0,
                                              child: Container(
                                                width: 12,
                                                height: 12,
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFF2563EB),
                                                  shape: BoxShape.circle,
                                                  border: Border.all(color: Colors.white, width: 2),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(width: 12),

                                      // Colleague Details
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    colleague.displayName,
                                                    style: TextStyle(
                                                      fontSize: 13.5,
                                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                                      color: isSelected ? const Color(0xFF1E3A8A) : const Color(0xFF0F172A),
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                if (colleague.employeeId != null && colleague.employeeId!.isNotEmpty) ...[
                                                  const SizedBox(width: 6),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                                    decoration: BoxDecoration(
                                                      color: isSelected ? const Color(0xFFDBEAFE) : const Color(0xFFF1F5F9),
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                    child: Text(
                                                      colleague.employeeId!,
                                                      style: TextStyle(
                                                        fontSize: 9.5,
                                                        fontWeight: FontWeight.w600,
                                                        color: isSelected ? const Color(0xFF1E40AF) : const Color(0xFF64748B),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                            const SizedBox(height: 3),
                                            Row(
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    colleague.displayDesignation,
                                                    style: const TextStyle(
                                                      fontSize: 11.5,
                                                      color: Color(0xFF64748B),
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                if (colleague.department != null && colleague.department!.isNotEmpty) ...[
                                                  const Text(' • ', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                                                  Flexible(
                                                    child: Text(
                                                      colleague.department!,
                                                      style: const TextStyle(
                                                        fontSize: 11,
                                                        color: Color(0xFF64748B),
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),

                                      // Assigned Leads Pill Badge
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                                        decoration: BoxDecoration(
                                          color: isSelected ? const Color(0xFFDBEAFE) : const Color(0xFFF1F5F9),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          '${colleague.assignedLeadsCount} Leads',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: isSelected ? const Color(0xFF1D4ED8) : const Color(0xFF475569),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),

                                      // Custom Radio Indicator
                                      AnimatedContainer(
                                        duration: const Duration(milliseconds: 180),
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isSelected ? const Color(0xFF2563EB) : Colors.transparent,
                                          border: Border.all(
                                            color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFCBD5E1),
                                            width: isSelected ? 2 : 1.5,
                                          ),
                                        ),
                                        child: isSelected
                                            ? const Center(
                                                child: Icon(
                                                  Icons.check_rounded,
                                                  size: 13,
                                                  color: Colors.white,
                                                ),
                                              )
                                            : null,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 14),

                  // Reason for Reassignment
                  const AppText(
                    'Reason for Reassignment',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF334155),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: transferReasons.map((reason) {
                      final isSelected = selectedReason == reason;
                      return ChoiceChip(
                        label: Text(
                          reason,
                          style: TextStyle(
                            fontSize: 11,
                            color: isSelected ? Colors.white : const Color(0xFF334155),
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: const Color(0xFF2563EB),
                        backgroundColor: const Color(0xFFF8FAFC),
                        side: BorderSide(
                          color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                        ),
                        onSelected: (val) {
                          setModalState(() {
                            selectedReason = reason;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),

                  // Instructions for Colleague
                  const AppText(
                    'Notes / Handoff Instructions',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF334155),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: noteController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Add client requirement or specific instructions...',
                      hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Submit Assignment Button with Live API Call
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              if (selectedEmployee == null) {
                                Get.snackbar(
                                  'Select Colleague',
                                  'Please pick a sales employee to transfer this lead.',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: const Color(0xFFEF4444),
                                  colorText: Colors.white,
                                );
                                return;
                              }

                              setModalState(() {
                                isSubmitting = true;
                              });

                              final chosen = selectedEmployee!;
                              final snakeCaseReason = mapReasonToSnakeCase(selectedReason);
                              final noteText = noteController.text.trim();

                              // Call POST /api/employee/leads/{id}/assign
                              final result = await controller.assignLead(
                                lead.rawId,
                                employeeId: chosen.id,
                                reason: snakeCaseReason,
                                notes: noteText.isNotEmpty ? noteText : null,
                              );

                              if (result.success) {
                                lead.assignedEmployee = chosen.displayName;
                                lead.assignedEmployeeAvatar = chosen.avatar ?? '';
                                lead.assignedEmployeeRole = chosen.displayDesignation;
                                lead.isReassigned = true;

                                lead.processSteps.insert(
                                  0,
                                  ExecLeadProcessStep(
                                    title: 'Lead Reassigned to ${chosen.displayName}',
                                    date: DateFormat('dd MMM yyyy').format(DateTime.now()),
                                    time: DateFormat('hh:mm a').format(DateTime.now()),
                                    note: 'Transferred by You. Reason: $selectedReason.${noteText.isNotEmpty ? ' Note: $noteText' : ''}',
                                    performedBy: 'You',
                                    isCompleted: true,
                                  ),
                                );

                                searchDebounce?.cancel();
                                if (modalCtx.mounted) {
                                  Navigator.pop(modalCtx);
                                }
                                onAssigned();

                                Get.snackbar(
                                  'Lead Assigned 🎉',
                                  result.message.isNotEmpty
                                      ? result.message
                                      : 'Lead ${lead.id} successfully reassigned to ${chosen.displayName}.',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: const Color(0xFF10B981),
                                  colorText: Colors.white,
                                  icon: const Icon(Icons.swap_horiz_rounded, color: Colors.white),
                                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                                  borderRadius: 14,
                                );
                              } else {
                                setModalState(() {
                                  isSubmitting = false;
                                });
                                Get.snackbar(
                                  'Assignment Failed',
                                  result.message.isNotEmpty
                                      ? result.message
                                      : 'Could not assign lead. Please try again.',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: const Color(0xFFEF4444),
                                  colorText: Colors.white,
                                  icon: const Icon(Icons.error_outline_rounded, color: Colors.white),
                                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                                  borderRadius: 14,
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        disabledBackgroundColor: const Color(0xFF93C5FD),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: isSubmitting
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Assigning Lead...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.swap_horiz_rounded, color: Colors.white, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Assign Lead to ${selectedEmployee?.displayName ?? 'Colleague'}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}


// ─────────────────────────────────────────────────────────────────────────────
// 📱 FULL SCREEN LEAD DETAIL VIEW FOR EXECUTIVE (TREE FORMAT)
// ─────────────────────────────────────────────────────────────────────────────
class ExecLeadFullDetailScreen extends StatefulWidget {
  final TeleCrmLeadItem? lead;
  final dynamic leadId;
  final VoidCallback onStatusUpdated;

  const ExecLeadFullDetailScreen({
    super.key,
    this.lead,
    this.leadId,
    required this.onStatusUpdated,
  });

  @override
  State<ExecLeadFullDetailScreen> createState() => _ExecLeadFullDetailScreenState();
}

class _ExecLeadFullDetailScreenState extends State<ExecLeadFullDetailScreen> {
  TeleCrmLeadItem? _lead;
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _lead = widget.lead;
    final targetId = widget.leadId ?? widget.lead?.rawId;
    if (targetId != null) {
      _fetchLeadDetail(targetId);
    }
  }

  Future<void> _fetchLeadDetail(dynamic id) async {
    if (_lead == null) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
    }

    try {
      final controller = EmployeeTeleCrmController.to;
      final result = await controller.fetchLeadDetail(id);
      if (result != null && mounted) {
        setState(() {
          _lead = TeleCrmLeadItem.fromEmployeeLead(result);
          _isLoading = false;
        });
      } else if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _lead == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 20),
            onPressed: () => Get.back(),
          ),
          title: const AppText('Lead Details', fontSize: 18, fontWeight: FontWeight.bold),
          centerTitle: true,
        ),
        body: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.primaryColor),
              SizedBox(height: 14),
              AppText('Loading lead details...', fontSize: 13, color: AppColors.textColorSecondary),
            ],
          ),
        ),
      );
    }

    if (_lead == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 20),
            onPressed: () => Get.back(),
          ),
          title: const AppText('Lead Details', fontSize: 18, fontWeight: FontWeight.bold),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48, color: Color(0xFFEF4444)),
              const SizedBox(height: 12),
              AppText(_errorMessage.isNotEmpty ? _errorMessage : 'Lead details not found', color: const Color(0xFF64748B)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  final targetId = widget.leadId ?? widget.lead?.rawId;
                  if (targetId != null) _fetchLeadDetail(targetId);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final lead = _lead!;
    final isConverted = lead.status == 'Converted';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 20),
              onPressed: () => Get.back(),
            ),
          ),
        ),
        title: const AppText(
          'Lead Details',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF0F172A),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Iconsax.timer_1, color: Color(0xFFD97706)),
            tooltip: 'Set Reminder',
            onPressed: () => showLeadReminderModal(
              context: context,
              lead: lead,
              onUpdated: () {
                setState(() {});
                widget.onStatusUpdated();
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_note_rounded, color: Color(0xFF0F172A)),
            tooltip: 'Update Status',
            onPressed: () => showUpdateLeadStatusModal(
              context: context,
              lead: lead,
              onUpdated: () {
                setState(() {});
                widget.onStatusUpdated();
              },
            ),
          ),
          if (isConverted)
            IconButton(
              icon: const Icon(Icons.rocket_launch_rounded, color: Color(0xFF16A34A)),
              tooltip: 'Project Handover',
              onPressed: () {
                final handover = LeadProjectHandoverManager.getHandover(lead.rawId);
                if (handover?.createdProjectId != null) {
                  Get.to(() => ProjectDetailsScreen(projectId: handover!.createdProjectId));
                } else {
                  Get.to(() => SalesConvertToProjectScreen(
                        lead: lead,
                        onProjectCreated: () {
                          setState(() {});
                          widget.onStatusUpdated();
                        },
                      ));
                }
              },
            ),
          if (!isConverted)
            IconButton(
              icon: const Icon(Icons.swap_horiz_rounded, color: Color(0xFF2563EB)),
              tooltip: 'Assign to Colleague',
              onPressed: () => showAssignLeadToColleagueModal(
                context: context,
                lead: lead,
                onAssigned: () {
                  setState(() {});
                  widget.onStatusUpdated();
                },
              ),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5)),
          ],
        ),
        child: Row(
          children: [
            if (!isConverted) ...[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => showAssignLeadToColleagueModal(
                    context: context,
                    lead: lead,
                    onAssigned: () {
                      setState(() {});
                      widget.onStatusUpdated();
                    },
                  ),
                  icon: const Icon(Icons.swap_horiz_rounded, size: 17, color: Color(0xFF2563EB)),
                  label: const AppText(
                    'Assign Lead',
                    color: Color(0xFF2563EB),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFBFDBFE)),
                    backgroundColor: const Color(0xFFEFF6FF),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ] else ...[
              Expanded(
                child: Builder(
                  builder: (context) {
                    final handover = LeadProjectHandoverManager.getHandover(lead.rawId);
                    final hasProject = handover != null;

                    return OutlinedButton.icon(
                      onPressed: () {
                        if (hasProject && handover.createdProjectId != null) {
                          Get.to(() => ProjectDetailsScreen(projectId: handover.createdProjectId));
                        } else {
                          Get.to(() => SalesConvertToProjectScreen(
                                lead: lead,
                                onProjectCreated: () {
                                  setState(() {});
                                  widget.onStatusUpdated();
                                },
                              ));
                        }
                      },
                      icon: Icon(
                        hasProject ? Icons.folder_special_rounded : Icons.rocket_launch_rounded,
                        size: 16,
                        color: hasProject ? const Color(0xFF059669) : const Color(0xFF2563EB),
                      ),
                      label: AppText(
                        hasProject ? 'View Project' : 'Create Project',
                        color: hasProject ? const Color(0xFF059669) : const Color(0xFF2563EB),
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: hasProject ? const Color(0xFFA7F3D0) : const Color(0xFFBFDBFE),
                        ),
                        backgroundColor: hasProject ? const Color(0xFFECFDF5) : const Color(0xFFEFF6FF),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              flex: isConverted ? 1 : 2,
              child: ElevatedButton.icon(
                onPressed: () => _makePhoneCall(lead.phone),
                icon: const Icon(Icons.phone_rounded, color: Colors.white, size: 18),
                label: const AppText('Call Client Now', color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final targetId = widget.leadId ?? lead.rawId;
          if (targetId != null) {
            await _fetchLeadDetail(targetId);
          }
        },
        color: AppColors.primaryColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ⏰ Follow-up Reminder Banner (if scheduled)
              Builder(
                builder: (ctx) {
                  final reminder = LeadReminderManager.getReminder(lead.rawId);
                  if (reminder == null) return const SizedBox.shrink();

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: reminder.isCompleted
                          ? const Color(0xFFF0FDF4)
                          : reminder.isOverdue
                              ? const Color(0xFFFEF2F2)
                              : reminder.isDueToday
                                  ? const Color(0xFFFFFBEB)
                                  : const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: reminder.isCompleted
                            ? const Color(0xFF86EFAC)
                            : reminder.isOverdue
                                ? const Color(0xFFFECACA)
                                : reminder.isDueToday
                                    ? const Color(0xFFFDE68A)
                                    : const Color(0xFFBFDBFE),
                        width: 1.2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: reminder.isCompleted
                                    ? const Color(0xFF16A34A)
                                    : reminder.isOverdue
                                        ? const Color(0xFFDC2626)
                                        : reminder.isDueToday
                                            ? const Color(0xFFD97706)
                                            : const Color(0xFF2563EB),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                reminder.reminderType == 'WhatsApp'
                                    ? Icons.chat_rounded
                                    : reminder.reminderType == 'SMS'
                                        ? Icons.sms_rounded
                                        : Icons.phone_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    reminder.isCompleted
                                        ? 'Follow-up Reminder Completed'
                                        : reminder.isOverdue
                                            ? 'Overdue Follow-up Reminder'
                                            : reminder.isDueToday
                                                ? 'Follow-up Due Today!'
                                                : 'Scheduled Follow-up Reminder',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: reminder.isCompleted
                                          ? const Color(0xFF15803D)
                                          : reminder.isOverdue
                                              ? const Color(0xFFB91C1C)
                                              : reminder.isDueToday
                                                  ? const Color(0xFFB45309)
                                                  : const Color(0xFF1D4ED8),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${reminder.reminderType} scheduled for ${DateFormat('EEE, dd MMM yyyy • hh:mm a').format(reminder.scheduledAt)}',
                                    style: const TextStyle(fontSize: 11.5, color: Color(0xFF475569)),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_calendar_rounded, size: 20, color: Color(0xFF475569)),
                              tooltip: 'Edit Reminder',
                              onPressed: () => showLeadReminderModal(
                                context: context,
                                lead: lead,
                                onUpdated: () {
                                  setState(() {});
                                  widget.onStatusUpdated();
                                },
                              ),
                            ),
                          ],
                        ),
                        if (reminder.note.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Agenda: "${reminder.note}"',
                              style: const TextStyle(fontSize: 11.5, fontStyle: FontStyle.italic, color: Color(0xFF334155)),
                            ),
                          ),
                        ],
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (reminder.reminderType == 'Call')
                              ElevatedButton.icon(
                                onPressed: () => _makePhoneCall(lead.phone),
                                icon: const Icon(Icons.phone_rounded, size: 14, color: Colors.white),
                                label: const Text('Call Client', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.white)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF059669),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            if (reminder.reminderType == 'WhatsApp') ...[
                              ElevatedButton.icon(
                                onPressed: () => _sendWhatsAppMessage(lead.phone, message: reminder.note.isNotEmpty ? reminder.note : null),
                                icon: const Icon(Icons.chat_rounded, size: 14, color: Colors.white),
                                label: const Text('WhatsApp', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.white)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF16A34A),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ],
                            if (reminder.reminderType == 'SMS') ...[
                              ElevatedButton.icon(
                                onPressed: () => _sendSmsMessage(lead.phone, message: reminder.note.isNotEmpty ? reminder.note : null),
                                icon: const Icon(Icons.message_rounded, size: 14, color: Colors.white),
                                label: const Text('Send SMS', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.white)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2563EB),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ],
                            const SizedBox(width: 8),
                            OutlinedButton.icon(
                              onPressed: () async {
                                await LeadReminderManager.toggleComplete(lead.rawId);
                                setState(() {});
                                widget.onStatusUpdated();
                              },
                              icon: Icon(
                                reminder.isCompleted ? Icons.undo_rounded : Icons.check_circle_outline_rounded,
                                size: 14,
                                color: const Color(0xFF475569),
                              ),
                              label: Text(
                                reminder.isCompleted ? 'Reopen' : 'Mark Done',
                                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFFCBD5E1)),
                                backgroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),

              // 🚀 Project Handover Card (if converted)
              if (lead.status == 'Converted') ...[
                Builder(
                  builder: (context) {
                    final handover = LeadProjectHandoverManager.getHandover(lead.rawId);
                    final hasProject = handover != null;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: hasProject
                              ? [const Color(0xFFF0FDF4), const Color(0xFFDCFCE7)]
                              : [const Color(0xFFEFF6FF), const Color(0xFFDBEAFE)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: hasProject ? const Color(0xFF86EFAC) : const Color(0xFF93C5FD),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (hasProject ? const Color(0xFF16A34A) : AppColors.primaryColor)
                                .withValues(alpha: 0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: hasProject ? const Color(0xFF16A34A) : AppColors.primaryColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  hasProject ? Icons.folder_special_rounded : Icons.rocket_launch_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          hasProject ? 'Project Handover Active 🚀' : 'Deal Converted to Project',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: hasProject ? const Color(0xFF15803D) : const Color(0xFF1E3A8A),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                          decoration: BoxDecoration(
                                            color: hasProject ? const Color(0xFFBBF7D0) : const Color(0xFFBFDBFE),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            hasProject ? 'Created' : 'Pending Handover',
                                            style: TextStyle(
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.bold,
                                              color: hasProject ? const Color(0xFF166534) : const Color(0xFF1D4ED8),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      hasProject
                                          ? '${handover.projectName} • ${handover.durationDays} Days committed'
                                          : 'Create operational project and attach client documents/brief.',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        color: hasProject ? const Color(0xFF166534) : const Color(0xFF3B82F6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (hasProject) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    children: [
                                      const Text('Deal Budget', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                                      const SizedBox(height: 2),
                                      Text(
                                        '₹${(handover.agreedBudget / 1000).toStringAsFixed(0)}k',
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF15803D)),
                                      ),
                                    ],
                                  ),
                                  Container(width: 1, height: 24, color: const Color(0xFFE2E8F0)),
                                  Column(
                                    children: [
                                      const Text('Advance', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                                      const SizedBox(height: 2),
                                      Text(
                                        '₹${(handover.advanceReceived / 1000).toStringAsFixed(0)}k',
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                                      ),
                                    ],
                                  ),
                                  Container(width: 1, height: 24, color: const Color(0xFFE2E8F0)),
                                  Column(
                                    children: [
                                      const Text('Duration', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${handover.durationDays} Days',
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFD97706)),
                                      ),
                                    ],
                                  ),
                                  Container(width: 1, height: 24, color: const Color(0xFFE2E8F0)),
                                  Column(
                                    children: [
                                      const Text('Docs Attached', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${handover.attachments.length} files',
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF7C3AED)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                if (hasProject && handover.createdProjectId != null) {
                                  Get.to(() => ProjectDetailsScreen(projectId: handover.createdProjectId));
                                } else {
                                  Get.to(() => SalesConvertToProjectScreen(
                                        lead: lead,
                                        onProjectCreated: () {
                                          setState(() {});
                                          widget.onStatusUpdated();
                                        },
                                      ));
                                }
                              },
                              icon: Icon(
                                hasProject ? Icons.folder_special_rounded : Icons.rocket_launch_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                              label: Text(
                                hasProject ? 'Open Project Workspace' : 'Create Project Handover 🚀',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: hasProject ? const Color(0xFF16A34A) : AppColors.primaryColor,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],

              // 1. Client Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: const Color(0xFFEFF6FF),
                          child: Text(
                            lead.customerName.isNotEmpty ? lead.customerName[0].toUpperCase() : 'C',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(lead.customerName, fontSize: 16, fontWeight: FontWeight.bold),
                              const SizedBox(height: 4),
                              AppText('Lead ID: ${lead.id}', fontSize: 12, color: const Color(0xFF64748B)),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            showUpdateLeadStatusModal(
                              context: context,
                              lead: lead,
                              onUpdated: () {
                                setState(() {});
                                widget.onStatusUpdated();
                              },
                            );
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isConverted ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isConverted ? const Color(0xFF86EFAC) : const Color(0xFFFDE68A),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AppText(
                                  lead.status,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isConverted ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.edit_note_rounded,
                                  size: 13,
                                  color: isConverted ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    const SizedBox(height: 14),

                    // Assigned Employee Detailed Row with Reassign action
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: lead.isReassigned ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: lead.isReassigned ? const Color(0xFFBFDBFE) : const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundImage: NetworkImage(lead.assignedEmployeeAvatar),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    AppText(
                                      lead.isReassigned ? 'Transferred Employee' : 'Assigned Executive',
                                      fontSize: 10.5,
                                      color: const Color(0xFF64748B),
                                    ),
                                    if (lead.isReassigned) ...[
                                      const SizedBox(width: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFDBEAFE),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const AppText('Handed Over', fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF1D4ED8)),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 2),
                                AppText(
                                  lead.assignedEmployee,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF0F172A),
                                ),
                              ],
                            ),
                          ),
                          if (!isConverted)
                            ElevatedButton.icon(
                              onPressed: () => showAssignLeadToColleagueModal(
                                context: context,
                                lead: lead,
                                onAssigned: () {
                                  setState(() {});
                                  widget.onStatusUpdated();
                                },
                              ),
                              icon: const Icon(Icons.swap_horiz_rounded, size: 14, color: Colors.white),
                              label: const AppText('Reassign', fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.lock_rounded, size: 12, color: Color(0xFF64748B)),
                                  SizedBox(width: 4),
                                  AppText('Locked (Converted)', fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    InkWell(
                      onTap: () => _makePhoneCall(lead.phone),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Row(
                          children: [
                            const Icon(Icons.phone_rounded, size: 16, color: Color(0xFF2563EB)),
                            const SizedBox(width: 8),
                            AppText(lead.phone, fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF2563EB)),
                            const SizedBox(width: 6),
                            const Icon(Icons.call_made_rounded, size: 13, color: Color(0xFF2563EB)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.email_rounded, size: 16, color: Color(0xFF64748B)),
                        const SizedBox(width: 8),
                        AppText(lead.email, fontSize: 13, fontWeight: FontWeight.w600),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.assignment_rounded, size: 16, color: Color(0xFF64748B)),
                        const SizedBox(width: 8),
                        Expanded(child: AppText('Requirement: ${lead.requirement}', fontSize: 13, fontWeight: FontWeight.w600, maxLines: 3)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.attach_money_rounded, size: 16, color: Color(0xFF64748B)),
                        const SizedBox(width: 8),
                        AppText('Potential Value: ₹${(lead.potentialValue / 1000).toStringAsFixed(0)}k', fontSize: 13, fontWeight: FontWeight.w800, color: const Color(0xFF15803D)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.campaign_rounded, size: 16, color: Color(0xFF64748B)),
                        const SizedBox(width: 8),
                        AppText(lead.isSelfGenerated ? 'Self Brought by You' : 'Assigned by Admin', fontSize: 13, fontWeight: FontWeight.w600, color: lead.isSelfGenerated ? const Color(0xFF7C3AED) : const Color(0xFF2563EB)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // 2. Process & Interactions History Tree
              const AppText(
                'Process & Interactions History',
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
              const SizedBox(height: 16),
              ...List.generate(lead.processSteps.length, (index) {
                final step = lead.processSteps[index];
                final isLast = index == lead.processSteps.length - 1;
                final isReassignStep = step.title.toLowerCase().contains('reassigned') || step.title.toLowerCase().contains('assigned');

                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Tree Connector (Line & Dot)
                      Column(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: isReassignStep 
                                  ? const Color(0xFF2563EB) 
                                  : (step.isCompleted ? const Color(0xFF10B981) : Colors.white),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isReassignStep 
                                    ? const Color(0xFF2563EB) 
                                    : (step.isCompleted ? const Color(0xFF10B981) : const Color(0xFFCBD5E1)),
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              isReassignStep ? Icons.swap_horiz_rounded : Icons.check_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                          if (!isLast)
                            Expanded(
                              child: Container(
                                width: 2,
                                color: step.isCompleted ? const Color(0xFF10B981) : const Color(0xFFE2E8F0),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      // Step Content Card
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isReassignStep ? const Color(0xFFF8FAFC) : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: isReassignStep ? const Color(0xFFBFDBFE) : const Color(0xFFE2E8F0)),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2)),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(child: AppText(step.title, fontSize: 13.5, fontWeight: FontWeight.bold)),
                                    AppText('${step.date} ${step.time}'.trim(), fontSize: 11, color: const Color(0xFF64748B)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.person_outline_rounded, size: 12, color: Color(0xFF94A3B8)),
                                    const SizedBox(width: 4),
                                    AppText(step.performedBy.isNotEmpty ? step.performedBy : 'Unknown', fontSize: 11, color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
                                  ],
                                ),
                                if (step.note.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  AppText(step.note, fontSize: 12, color: const Color(0xFF475569)),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

