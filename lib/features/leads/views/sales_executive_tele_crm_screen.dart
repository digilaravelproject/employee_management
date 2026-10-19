import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/employee_tele_crm_controller.dart';
import '../models/employee_leads_response_model.dart';
import '../models/sales_employee_model.dart';
import 'sales_executive_create_lead_screen.dart';

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
    final leads = _controller.leads;
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
            const SizedBox(height: 20),

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

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildTabChip('All Leads', statusKey: '', count: allCount),
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
    Color statusColor;
    Color statusBgColor;

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

            // Follow-up Timer Alert Bar (if follow-up date set)
            if (lead.nextFollowupDateTime != null) ...[
              Container(
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
                    AppText(
                      'Next Follow-up Call: ${DateFormat('dd MMM, hh:mm a').format(lead.nextFollowupDateTime!)}',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFB45309),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
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

            // ── Modern Unified Action Toolbar (3 Professional Balanced Buttons) ──
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
                            Icon(Icons.phone_rounded, size: 14, color: Color(0xFF059669)),
                            SizedBox(width: 5),
                            AppText('Call', fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF059669)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

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
                            Icon(Icons.edit_note_rounded, size: 16, color: Color(0xFF334155)),
                            SizedBox(width: 4),
                            AppText('Status', fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // 3. Assign Action (Royal Blue Tonal / Grey Locked if Converted)
                Expanded(
                  child: Material(
                    color: lead.status == 'Converted' ? const Color(0xFFF1F5F9) : const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () {
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
                            color: lead.status == 'Converted' ? const Color(0xFFE2E8F0) : const Color(0xFFBFDBFE),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              lead.status == 'Converted' ? Icons.lock_outline_rounded : Icons.swap_horiz_rounded,
                              size: 15,
                              color: lead.status == 'Converted' ? const Color(0xFF94A3B8) : const Color(0xFF2563EB),
                            ),
                            const SizedBox(width: 4),
                            AppText(
                              lead.status == 'Converted' ? 'Locked' : 'Assign',
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: lead.status == 'Converted' ? const Color(0xFF94A3B8) : const Color(0xFF2563EB),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
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
// 🚀 UPDATE LEAD STATUS MODAL (PATCH /api/employee/leads/{id}/status)
// ─────────────────────────────────────────────────────────────────────────────
void showUpdateLeadStatusModal({
  required BuildContext context,
  required TeleCrmLeadItem lead,
  required VoidCallback onUpdated,
}) {
  final controller = EmployeeTeleCrmController.to;
  String selectedStatus = lead.status;
  final noteController = TextEditingController();
  bool isSubmitting = false;

  final statusColors = {
    'Interested': const Color(0xFF2563EB),
    'Follow-up': const Color(0xFFD97706),
    'Pending Call': const Color(0xFF0284C7),
    'Converted': const Color(0xFF10B981),
    'Unreachable': const Color(0xFFDC2626),
    'Wrong Number': const Color(0xFF475569),
  };

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
          final currentColor = statusColors[selectedStatus] ?? AppColors.primaryColor;

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

                  // Status Chips
                  const AppText(
                    'Select Status *',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF334155),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      'Interested',
                      'Follow-up',
                      'Pending Call',
                      'Converted',
                      'Unreachable',
                      'Wrong Number',
                    ].map((s) {
                      final isSelected = selectedStatus == s;
                      final chipColor = statusColors[s] ?? AppColors.primaryColor;
                      return ChoiceChip(
                        label: Text(
                          s,
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected ? Colors.white : const Color(0xFF334155),
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: chipColor,
                        backgroundColor: const Color(0xFFF8FAFC),
                        side: BorderSide(
                          color: isSelected ? chipColor : const Color(0xFFE2E8F0),
                          width: isSelected ? 1.5 : 1,
                        ),
                        onSelected: (bool selected) {
                          setModalState(() {
                            selectedStatus = s;
                          });
                        },
                      );
                    }).toList(),
                  ),

                  if (selectedStatus == 'Converted') ...[
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
                  const SizedBox(height: 20),

                  // Submit Button calling PATCH /api/employee/leads/{id}/status
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              setModalState(() {
                                isSubmitting = true;
                              });

                              final callNote = noteController.text.trim();

                              // Call PATCH /api/employee/leads/{id}/status
                              final result = await controller.updateLeadStatus(
                                lead.rawId,
                                status: selectedStatus,
                                callNote: callNote.isNotEmpty ? callNote : null,
                              );

                              if (result.success) {
                                final prevStatus = lead.status;
                                lead.status = selectedStatus;
                                lead.processSteps.insert(
                                  0,
                                  ExecLeadProcessStep(
                                    title: selectedStatus == 'Converted'
                                        ? 'Converted to Customer 🎉'
                                        : 'Status updated from $prevStatus to $selectedStatus',
                                    date: DateFormat('dd MMM yyyy').format(DateTime.now()),
                                    time: DateFormat('hh:mm a').format(DateTime.now()),
                                    note: callNote.isNotEmpty
                                        ? callNote
                                        : (selectedStatus == 'Converted'
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

                                Get.snackbar(
                                  selectedStatus == 'Converted'
                                      ? 'Lead Converted 🎉'
                                      : 'Status Updated',
                                  result.message.isNotEmpty
                                      ? result.message
                                      : (selectedStatus == 'Converted'
                                          ? 'Congratulations! Deal successfully closed.'
                                          : 'Lead status has been updated to $selectedStatus.'),
                                  backgroundColor: selectedStatus == 'Converted'
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFF2563EB),
                                  colorText: Colors.white,
                                  snackPosition: SnackPosition.BOTTOM,
                                  icon: Icon(
                                    selectedStatus == 'Converted'
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
                                const Icon(Icons.save_rounded, color: Colors.white, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  'Update Status to $selectedStatus',
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

