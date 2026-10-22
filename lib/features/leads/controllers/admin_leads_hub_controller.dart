import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../domain/usecases/assign_lead_usecase.dart';
import '../domain/usecases/create_admin_lead_usecase.dart';
import '../domain/usecases/get_admin_lead_detail_usecase.dart';
import '../domain/usecases/get_admin_leads_usecase.dart';
import '../domain/usecases/get_sales_employees_usecase.dart';
import '../models/admin_leads_request_model.dart';
import '../models/admin_leads_response_model.dart';
import '../models/sales_employee_model.dart';
import '../repositories/admin_leads_repository_interface.dart';

class AdminLeadsHubController extends GetxController {
  final AdminLeadsRepositoryInterface? repository;
  final GetAdminLeadsUseCase getAdminLeadsUseCase;
  final GetAdminLeadDetailUseCase getAdminLeadDetailUseCase;
  final GetSalesEmployeesUseCase getSalesEmployeesUseCase;
  final CreateAdminLeadUseCase createAdminLeadUseCase;
  final AssignLeadUseCase assignLeadUseCase;

  AdminLeadsHubController({
    required this.getAdminLeadsUseCase,
    required this.getAdminLeadDetailUseCase,
    required this.getSalesEmployeesUseCase,
    required this.createAdminLeadUseCase,
    required this.assignLeadUseCase,
    this.repository,
  });

  AdminLeadsRepositoryInterface get _repo =>
      repository ?? Get.find<AdminLeadsRepositoryInterface>();

  // State Observables
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxString errorMessage = ''.obs;

  final RxList<AdminLeadDataModel> leadsList = <AdminLeadDataModel>[].obs;
  final Rxn<AdminLeadsSummaryModel> summary = Rxn<AdminLeadsSummaryModel>();
  final Rxn<AdminLeadsPaginationModel> pagination = Rxn<AdminLeadsPaginationModel>();

  // Sales Employees Observable
  final RxList<SalesEmployeeModel> salesEmployees = <SalesEmployeeModel>[].obs;
  final RxBool isLoadingSalesEmployees = false.obs;

  // Single Sales Employee Lead Details Observable
  final RxBool isLoadingEmployeeDetails = false.obs;
  final Rx<SalesEmployeeLeadDetailsData?> currentEmployeeLeadDetails =
      Rx<SalesEmployeeLeadDetailsData?>(null);

  // Filter Observables
  // Assignment: 'all', 'unassigned', 'assigned'
  final RxString selectedAssignment = 'all'.obs;
  // Source: 'all_channels', 'website', 'google', 'facebook', 'justdial', 'referral'
  final RxString selectedSource = 'all_channels'.obs;
  // Status: 'all', 'new', 'interested', etc.
  final RxString selectedStatus = 'all'.obs;
  final RxString searchQuery = ''.obs;

  final RxInt currentPage = 1.obs;
  final int perPage = 20;

  Timer? _searchDebounceTimer;
  final ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _setupScrollListener();
    fetchLeads();
    fetchSalesEmployees();
  }

  @override
  void onClose() {
    _searchDebounceTimer?.cancel();
    scrollController.dispose();
    searchController.dispose();
    super.onClose();
  }

  void _setupScrollListener() {
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 200 &&
          !isLoading.value &&
          !isLoadingMore.value &&
          hasMorePages) {
        loadMoreLeads();
      }
    });
  }

  bool get hasMorePages {
    final pag = pagination.value;
    if (pag == null) return false;
    return pag.currentPage < pag.lastPage;
  }

  // ── Fetch Leads API ────────────────────────────────────────────────────────
  Future<void> fetchLeads({bool isRefresh = false}) async {
    if (isRefresh) {
      currentPage.value = 1;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final request = AdminLeadsRequestModel(
        assignment: selectedAssignment.value,
        source: selectedSource.value,
        status: selectedStatus.value,
        page: currentPage.value,
        perPage: perPage,
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
      );

      final response = await getAdminLeadsUseCase.execute(request);

      if (response.status) {
        leadsList.assignAll(response.data);
        if (response.summary != null) {
          summary.value = response.summary;
        }
        pagination.value = response.pagination;
      } else {
        errorMessage.value = response.message.isNotEmpty
            ? response.message
            : 'Unable to fetch leads. Please try again.';
      }
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  // ── Load More Leads (Pagination) ──────────────────────────────────────────
  Future<void> loadMoreLeads() async {
    if (isLoadingMore.value || !hasMorePages) return;

    isLoadingMore.value = true;
    final nextPage = currentPage.value + 1;

    try {
      final request = AdminLeadsRequestModel(
        assignment: selectedAssignment.value,
        source: selectedSource.value,
        status: selectedStatus.value,
        page: nextPage,
        perPage: perPage,
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
      );

      final response = await getAdminLeadsUseCase.execute(request);

      if (response.status && response.data.isNotEmpty) {
        currentPage.value = nextPage;
        leadsList.addAll(response.data);
        if (response.summary != null) {
          summary.value = response.summary;
        }
        pagination.value = response.pagination;
      }
    } catch (_) {
      // Keep existing leads intact on pagination failure
    } finally {
      isLoadingMore.value = false;
    }
  }

  // ── Filter Modifiers ───────────────────────────────────────────────────────
  void setAssignmentFilter(String assignment) {
    if (selectedAssignment.value == assignment) return;
    selectedAssignment.value = assignment;
    currentPage.value = 1;
    fetchLeads();
  }

  void setSourceFilter(String source) {
    if (selectedSource.value == source) return;
    selectedSource.value = source;
    currentPage.value = 1;
    fetchLeads();
  }

  void setStatusFilter(String status) {
    if (selectedStatus.value == status) return;
    selectedStatus.value = status;
    currentPage.value = 1;
    fetchLeads();
  }

  void applyFilters({String? assignment, String? source, String? status}) {
    bool changed = false;
    if (assignment != null && selectedAssignment.value != assignment) {
      selectedAssignment.value = assignment;
      changed = true;
    }
    if (source != null && selectedSource.value != source) {
      selectedSource.value = source;
      changed = true;
    }
    if (status != null && selectedStatus.value != status) {
      selectedStatus.value = status;
      changed = true;
    }
    if (changed) {
      currentPage.value = 1;
      fetchLeads();
    }
  }

  void onSearchChanged(String query) {
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (searchQuery.value != query) {
        searchQuery.value = query;
        currentPage.value = 1;
        fetchLeads();
      }
    });
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    currentPage.value = 1;
    fetchLeads();
  }

  void resetAllFilters() {
    selectedAssignment.value = 'all';
    selectedSource.value = 'all_channels';
    selectedStatus.value = 'all';
    searchQuery.value = '';
    searchController.clear();
    currentPage.value = 1;
    fetchLeads();
  }

  // Leads list populated by API (or search endpoint when query is active)
  List<AdminLeadDataModel> get filteredLeads => leadsList;

  // Single Lead Details Fetch
  Future<AdminLeadDataModel?> fetchLeadDetail(dynamic id) async {
    try {
      final response = await getAdminLeadDetailUseCase.execute(id);
      if (response.status && response.data != null) {
        return response.data;
      }
    } catch (_) {}
    return null;
  }

  // Fetch Sales Employees
  Future<void> fetchSalesEmployees() async {
    isLoadingSalesEmployees.value = true;
    try {
      final response = await getSalesEmployeesUseCase();
      if (response.status) {
        salesEmployees.assignAll(response.data);
      }
    } catch (_) {
    } finally {
      isLoadingSalesEmployees.value = false;
    }
  }

  // Create Lead API
  Future<AdminLeadDetailResponseModel> createLead(CreateAdminLeadRequestModel request) async {
    final response = await createAdminLeadUseCase(request);
    if (response.status) {
      // Refresh leads list with fresh data
      fetchLeads(isRefresh: true);
    }
    return response;
  }

  // Assign / Re-Assign Lead API
  Future<AdminLeadDetailResponseModel> assignLead(dynamic leadId, AssignLeadRequestModel request) async {
    final response = await assignLeadUseCase(leadId, request);
    if (response.status && response.data != null) {
      final updatedLead = response.data!;
      final index = leadsList.indexWhere((l) => l.id == updatedLead.id);
      if (index != -1) {
        leadsList[index] = updatedLead;
        leadsList.refresh();
      }
      // Silently refresh summary count and leads
      fetchLeads(isRefresh: false);
    }
    return response;
  }

  // Fetch Single Sales Employee Lead Details (GET /api/admin/leads/sales-employees/{id}?per_page=20)
  Future<SalesEmployeeLeadDetailsResponseModel?> fetchSalesEmployeeLeadDetails(
    dynamic employeeId, {
    int page = 1,
    int perPage = 20,
  }) async {
    isLoadingEmployeeDetails.value = true;
    try {
      final response = await _repo.getSalesEmployeeLeadDetails(
        employeeId,
        page: page,
        perPage: perPage,
      );
      if (response.status && response.data != null) {
        currentEmployeeLeadDetails.value = response.data;
      }
      return response;
    } catch (_) {
      return null;
    } finally {
      isLoadingEmployeeDetails.value = false;
    }
  }
}
