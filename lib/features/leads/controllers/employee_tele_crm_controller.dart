import 'dart:async';
import 'package:get/get.dart';
import '../../../core/services/network/api_client.dart';
import '../../../core/utils/logger.dart';
import '../models/employee_leads_response_model.dart';
import '../models/lead_status_model.dart';
import '../models/sales_employee_model.dart';
import '../repositories/employee_leads_repository.dart';

class EmployeeTeleCrmController extends GetxController {
  final EmployeeLeadsRepositoryInterface repository;

  EmployeeTeleCrmController({required this.repository});

  static EmployeeTeleCrmController get to {
    if (!Get.isRegistered<EmployeeTeleCrmController>()) {
      final apiClient = Get.isRegistered<ApiClient>() ? Get.find<ApiClient>() : ApiClient();
      final repo = EmployeeLeadsRepository(apiClient: apiClient);
      return Get.put(EmployeeTeleCrmController(repository: repo));
    }
    return Get.find<EmployeeTeleCrmController>();
  }

  // Observable state
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxList<EmployeeLeadItemModel> leads = <EmployeeLeadItemModel>[].obs;
  final Rx<EmployeeLeadsSummaryModel?> summary = Rx<EmployeeLeadsSummaryModel?>(null);
  final Rx<EmployeeLeadsPaginationModel?> pagination = Rx<EmployeeLeadsPaginationModel?>(null);

  final RxInt currentPage = 1.obs;
  final RxInt lastPage = 1.obs;
  final RxInt totalLeads = 0.obs;

  final RxString selectedTab = 'All Leads'.obs;
  final RxString selectedStatus = ''.obs;
  final RxString searchQuery = ''.obs;
  final RxString errorMessage = ''.obs;

  final RxBool isLoadingDetail = false.obs;
  final Rx<EmployeeLeadItemModel?> selectedLeadDetail = Rx<EmployeeLeadItemModel?>(null);

  final RxBool isLoadingSalesEmployees = false.obs;
  final RxList<SalesEmployeeModel> salesEmployees = <SalesEmployeeModel>[].obs;

  // ── Lead Statuses from GET /api/admin/lead-statuses ──────────────────────
  static final List<LeadStatusModel> defaultLeadStatuses = [
    LeadStatusModel(
      id: 1,
      name: 'New',
      slug: 'new',
      category: 'prospecting',
      categoryLabel: 'Prospecting',
      description: 'Fresh lead captured, pending first outreach call.',
      badgeColor: '#3B82F6',
      orderPosition: 1,
      isSystem: true,
      leadsCount: 217,
    ),
    LeadStatusModel(
      id: 3,
      name: 'Follow-up',
      slug: 'follow_up',
      category: 'active_lead',
      categoryLabel: 'Active Lead (In negotiation)',
      description: 'Callback scheduled; active discussions are ongoing.',
      badgeColor: '#F59E0B',
      orderPosition: 3,
      isSystem: false,
      leadsCount: 1,
    ),
    LeadStatusModel(
      id: 4,
      name: 'Pending Call',
      slug: 'pending_call',
      category: 'active_lead',
      categoryLabel: 'Active Lead (In negotiation)',
      description: 'Lead is waiting for the next call.',
      badgeColor: '#8B5CF6',
      orderPosition: 4,
      isSystem: false,
      leadsCount: 0,
    ),
    LeadStatusModel(
      id: 13,
      name: 'In Progress',
      slug: 'in_progress',
      category: 'active_lead',
      categoryLabel: 'Active Lead (In negotiation)',
      description: 'Technical evaluation or contract review is in progress.',
      badgeColor: '#6366F1',
      orderPosition: 4,
      isSystem: false,
      leadsCount: 0,
    ),
    LeadStatusModel(
      id: 5,
      name: 'Contacted',
      slug: 'contacted',
      category: 'won',
      categoryLabel: 'Won',
      description: 'Initial contact has been completed.',
      badgeColor: '#6366F1',
      orderPosition: 5,
      isSystem: false,
      leadsCount: 0,
    ),
    LeadStatusModel(
      id: 6,
      name: 'Qualified',
      slug: 'qualified',
      category: 'active_lead',
      categoryLabel: 'Active Lead (In negotiation)',
      description: 'Lead meets the qualification criteria.',
      badgeColor: '#0D9488',
      orderPosition: 6,
      isSystem: false,
      leadsCount: 0,
    ),
    LeadStatusModel(
      id: 7,
      name: 'Proposal Sent',
      slug: 'proposal_sent',
      category: 'active_lead',
      categoryLabel: 'Active Lead (In negotiation)',
      description: 'Proposal or quotation has been sent.',
      badgeColor: '#7C3AED',
      orderPosition: 7,
      isSystem: false,
      leadsCount: 0,
    ),
    LeadStatusModel(
      id: 8,
      name: 'Converted',
      slug: 'converted',
      category: 'won',
      categoryLabel: 'Won',
      description: 'Deal closed and advance payment received.',
      badgeColor: '#059669',
      orderPosition: 8,
      isSystem: false,
      leadsCount: 1,
    ),
    LeadStatusModel(
      id: 9,
      name: 'Unreachable',
      slug: 'unreachable',
      category: 'lost',
      categoryLabel: 'Lost',
      description: 'The lead could not be reached after repeated attempts.',
      badgeColor: '#EF4444',
      orderPosition: 9,
      isSystem: false,
      leadsCount: 0,
    ),
    LeadStatusModel(
      id: 10,
      name: 'Wrong Number',
      slug: 'wrong_number',
      category: 'lost',
      categoryLabel: 'Lost',
      description: 'The supplied contact number is invalid.',
      badgeColor: '#64748B',
      orderPosition: 10,
      isSystem: false,
      leadsCount: 0,
    ),
    LeadStatusModel(
      id: 11,
      name: 'Lost',
      slug: 'lost',
      category: 'lost',
      categoryLabel: 'Lost',
      description: 'The opportunity has been closed as lost.',
      badgeColor: '#DC2626',
      orderPosition: 11,
      isSystem: false,
      leadsCount: 0,
    ),
  ];

  final RxBool isLoadingStatuses = false.obs;
  final RxList<LeadStatusModel> leadStatuses = RxList<LeadStatusModel>(List.from(defaultLeadStatuses));

  Timer? _searchDebounce;

  @override
  void onInit() {
    super.onInit();
    fetchLeads(isRefresh: true);
    fetchLeadStatuses();
  }

  /// Fetch dynamic lead statuses from GET /api/admin/lead-statuses
  Future<void> fetchLeadStatuses() async {
    isLoadingStatuses.value = true;
    try {
      final res = await repository.getLeadStatuses();
      if (res.data.isNotEmpty) {
        final sorted = List<LeadStatusModel>.from(res.data)
          ..sort((a, b) => (a.orderPosition ?? 99).compareTo(b.orderPosition ?? 99));
        leadStatuses.assignAll(sorted);
      }
    } catch (e) {
      Logger.e('EmployeeTeleCrmController => Failed to fetch statuses: $e');
    } finally {
      isLoadingStatuses.value = false;
    }
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    super.onClose();
  }

  bool get hasMore => currentPage.value < lastPage.value;

  String? _mapTabToStatus(String tab) {
    switch (tab.trim()) {
      case 'Follow-ups Today':
      case 'Follow-up':
      case 'Follow-ups':
      case 'follow_up':
        return 'follow_up';
      case 'Interested':
      case 'interested':
        return 'interested';
      case 'Pending Call':
      case 'pending_call':
        return 'pending_call';
      case 'Converted':
      case 'converted':
        return 'converted';
      case 'Unreachable':
      case 'unreachable':
        return 'unreachable';
      case 'Wrong Number':
      case 'wrong_number':
        return 'wrong_number';
      case 'All Leads':
      case 'All':
      case 'all':
      default:
        return null;
    }
  }

  String? get activeStatusParam {
    final s = selectedStatus.value.trim();
    if (s == '__reminders__') return null;
    if (s.isNotEmpty) {
      return s;
    }
    return _mapTabToStatus(selectedTab.value);
  }

  /// Initial or Pull-to-refresh lead fetch
  Future<void> fetchLeads({bool isRefresh = false, String? status}) async {
    if (isRefresh) {
      currentPage.value = 1;
    }

    if (status != null) {
      selectedStatus.value = status.trim();
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final statusParam = status?.trim() ?? activeStatusParam;
      final searchParam = searchQuery.value.trim();

      final response = await repository.getEmployeeLeads(
        page: currentPage.value,
        perPage: 20,
        status: statusParam,
        search: searchParam.isNotEmpty ? searchParam : null,
      );

      if (response.status) {
        leads.assignAll(response.data);
        if (response.summary != null) {
          summary.value = response.summary;
        }
        if (response.pagination != null) {
          pagination.value = response.pagination;
          currentPage.value = response.pagination!.currentPage;
          lastPage.value = response.pagination!.lastPage;
          totalLeads.value = response.pagination!.total;
        } else {
          totalLeads.value = response.data.length;
          lastPage.value = 1;
        }
      } else {
        errorMessage.value = response.message.isNotEmpty
            ? response.message
            : 'Could not retrieve assigned leads.';
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// Lazy load next page when scrolled near bottom
  Future<void> loadMoreLeads() async {
    if (isLoading.value || isLoadingMore.value || !hasMore) {
      return;
    }

    isLoadingMore.value = true;
    final nextPage = currentPage.value + 1;

    try {
      final statusParam = activeStatusParam;
      final searchParam = searchQuery.value.trim();

      final response = await repository.getEmployeeLeads(
        page: nextPage,
        perPage: 20,
        status: statusParam,
        search: searchParam.isNotEmpty ? searchParam : null,
      );

      if (response.status) {
        leads.addAll(response.data);
        if (response.summary != null) {
          summary.value = response.summary;
        }
        if (response.pagination != null) {
          pagination.value = response.pagination;
          currentPage.value = response.pagination!.currentPage;
          lastPage.value = response.pagination!.lastPage;
          totalLeads.value = response.pagination!.total;
        } else {
          currentPage.value = nextPage;
        }
      }
    } catch (_) {
      // keep existing leads on pagination error
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// Change active tab filter and re-fetch from page 1
  void changeTab(String tab, {String? status}) {
    final newStatus = status ?? _mapTabToStatus(tab) ?? '';
    if (selectedTab.value == tab && selectedStatus.value == newStatus) return;
    selectedTab.value = tab;
    selectedStatus.value = newStatus;
    fetchLeads(isRefresh: true);
  }

  /// Filter leads by specific API status (e.g. 'follow_up', 'interested', 'all')
  void filterByStatus(String status) {
    final s = status.trim().toLowerCase();
    final newStatus = (s == 'all' || s.isEmpty) ? '' : s;
    selectedStatus.value = newStatus;
    if (s == 'follow_up' || s == 'follow-up') {
      selectedTab.value = 'Follow-up';
    } else if (s == 'interested') {
      selectedTab.value = 'Interested';
    } else if (s == 'pending_call') {
      selectedTab.value = 'Pending Call';
    } else if (s == 'converted') {
      selectedTab.value = 'Converted';
    } else if (s == 'unreachable') {
      selectedTab.value = 'Unreachable';
    } else if (s == 'wrong_number') {
      selectedTab.value = 'Wrong Number';
    } else {
      selectedTab.value = 'All Leads';
    }
    fetchLeads(isRefresh: true);
  }

  /// Search with debouncing
  void onSearchChanged(String query) {
    searchQuery.value = query;
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      fetchLeads(isRefresh: true);
    });
  }

  /// Instant search on submit (Enter/keyboard search press)
  void onSearchSubmitted(String query) {
    _searchDebounce?.cancel();
    searchQuery.value = query;
    fetchLeads(isRefresh: true);
  }

  /// Clear active search
  void clearSearch() {
    _searchDebounce?.cancel();
    searchQuery.value = '';
    fetchLeads(isRefresh: true);
  }

  /// Manually update or remove a lead locally after an action
  void updateLeadStatusLocally(int leadId, String newStatus) {
    final index = leads.indexWhere((l) => l.id == leadId);
    if (index != -1) {
      fetchLeads(isRefresh: true);
    }
  }

  /// Fetch full lead details by lead ID (GET /api/employee/leads/{id})
  Future<EmployeeLeadItemModel?> fetchLeadDetail(dynamic leadId) async {
    isLoadingDetail.value = true;
    try {
      final response = await repository.getEmployeeLeadDetail(leadId);
      if (response.status && response.data != null) {
        selectedLeadDetail.value = response.data;
        return response.data;
      }
    } catch (_) {
      // ignore
    } finally {
      isLoadingDetail.value = false;
    }
    return null;
  }

  /// Fetch sales employees for assignment (GET /api/employee/leads/sales-employees?q=...)
  Future<List<SalesEmployeeModel>> fetchSalesEmployees({String? search}) async {
    isLoadingSalesEmployees.value = true;
    try {
      final response = await repository.getSalesEmployees(search: search);
      if (response.status) {
        salesEmployees.assignAll(response.data);
        return response.data;
      }
    } catch (_) {
      // ignore
    } finally {
      isLoadingSalesEmployees.value = false;
    }
    return salesEmployees;
  }

  final RxBool isAssigningLead = false.obs;

  /// Assign lead to another sales employee (POST /api/employee/leads/{id}/assign)
  Future<({bool success, String message})> assignLead(
    dynamic leadId, {
    required int employeeId,
    required String reason,
    String? notes,
  }) async {
    isAssigningLead.value = true;
    try {
      final response = await repository.assignLead(
        leadId,
        employeeId: employeeId,
        reason: reason,
        notes: notes,
      );

      if (response.isSuccess) {
        // Refresh leads list in background to sync backend state
        fetchLeads(isRefresh: false);
        return (
          success: true,
          message: response.message.isNotEmpty
              ? response.message
              : 'Lead reassigned successfully.',
        );
      } else {
        return (
          success: false,
          message: response.message.isNotEmpty
              ? response.message
              : 'Failed to reassign lead.',
        );
      }
    } catch (e) {
      return (success: false, message: e.toString());
    } finally {
      isAssigningLead.value = false;
    }
  }

  final RxBool isUpdatingStatus = false.obs;

  /// Update lead status (PATCH /api/employee/leads/{id}/status)
  Future<({bool success, String message, dynamic data})> updateLeadStatus(
    dynamic leadId, {
    required String status,
    String? callNote,
    dynamic statusId,
    String? slug,
  }) async {
    isUpdatingStatus.value = true;
    try {
      final response = await repository.updateLeadStatus(
        leadId,
        status: status,
        callNote: callNote,
        statusId: statusId,
        slug: slug,
      );

      if (response.isSuccess) {
        // Refresh leads list in background to sync counts and statuses
        fetchLeads(isRefresh: false);
        return (
          success: true,
          message: response.message.isNotEmpty
              ? response.message
              : 'Lead status updated successfully.',
          data: response.body,
        );
      } else {
        return (
          success: false,
          message: response.message.isNotEmpty
              ? response.message
              : 'Failed to update lead status.',
          data: null,
        );
      }
    } catch (e) {
      return (success: false, message: e.toString(), data: null);
    } finally {
      isUpdatingStatus.value = false;
    }
  }
}

