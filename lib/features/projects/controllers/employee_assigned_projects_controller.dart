import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/network/api_client.dart';
import '../../../core/utils/logger.dart';
import '../models/employee_assigned_project_model.dart';
import '../repositories/employee_project_repository.dart';
import '../repositories/employee_project_repository_interface.dart';

class EmployeeAssignedProjectsController extends GetxController {
  final EmployeeProjectRepositoryInterface repository;

  EmployeeAssignedProjectsController({EmployeeProjectRepositoryInterface? repository})
      : repository = repository ??
            (Get.isRegistered<EmployeeProjectRepositoryInterface>()
                ? Get.find<EmployeeProjectRepositoryInterface>()
                : EmployeeProjectRepository(
                    apiClient: Get.isRegistered<ApiClient>()
                        ? Get.find<ApiClient>()
                        : Get.put(ApiClient(), permanent: true),
                  ));

  // Projects list
  final RxList<EmployeeAssignedProjectItem> assignedProjects = <EmployeeAssignedProjectItem>[].obs;

  // Loading & Error states
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool isSearching = false.obs;
  final RxString errorMessage = ''.obs;

  // Pagination states
  final RxInt currentPage = 1.obs;
  final RxInt lastPage = 1.obs;
  final RxInt totalProjects = 0.obs;
  final int perPage = 20;

  // Filter & Search states
  // Options: 'all', 'In Progress', 'Not Started', 'Completed', 'On Hold'
  final RxString selectedStatus = 'all'.obs;
  final RxString searchQuery = ''.obs;
  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  bool get hasMore => currentPage.value < lastPage.value;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_scrollListener);

    // Initial fetch
    fetchAssignedProjects(isRefresh: true);

    // Debounced search
    debounce(searchQuery, (query) {
      fetchAssignedProjects(isRefresh: true);
    }, time: const Duration(milliseconds: 350));
  }

  void _scrollListener() {
    if (scrollController.hasClients &&
        scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
      loadMoreAssignedProjects();
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    searchController.dispose();
    super.onClose();
  }

  /// Change Status Filter (all, In Progress, Not Started, Completed, On Hold)
  void changeStatusFilter(String status) {
    if (selectedStatus.value == status) return;
    selectedStatus.value = status;
    fetchAssignedProjects(isRefresh: true);
  }

  /// Fetch initial or filtered page
  Future<void> fetchAssignedProjects({bool isRefresh = false}) async {
    if (isRefresh) {
      currentPage.value = 1;
      isLoading.value = true;
      errorMessage.value = '';
    }

    try {
      final statusParam = selectedStatus.value.toLowerCase() == 'all' ? 'all' : selectedStatus.value;
      final query = searchQuery.value.trim();

      Logger.d('EmployeeAssignedProjectsController => Fetching assigned projects: status=$statusParam, page=1, query=$query');

      final response = await repository.getAssignedProjects(
        status: statusParam,
        page: 1,
        perPage: perPage,
        search: query.isNotEmpty ? query : null,
      );

      if (response.status) {
        assignedProjects.assignAll(response.data);
        currentPage.value = response.pagination?.currentPage ?? 1;
        lastPage.value = response.pagination?.lastPage ?? 1;
        totalProjects.value = response.pagination?.total ?? response.total;
        errorMessage.value = '';
      } else {
        if (assignedProjects.isEmpty) {
          errorMessage.value = response.message.isNotEmpty
              ? response.message
              : 'Failed to load assigned projects.';
        }
      }
    } catch (e) {
      Logger.e('EmployeeAssignedProjectsController => error: $e');
      if (assignedProjects.isEmpty) {
        errorMessage.value = 'Failed to load assigned projects: $e';
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Infinite scroll pagination loader
  Future<void> loadMoreAssignedProjects() async {
    if (isLoading.value || isLoadingMore.value || !hasMore) return;

    isLoadingMore.value = true;
    final nextPage = currentPage.value + 1;

    try {
      final statusParam = selectedStatus.value.toLowerCase() == 'all' ? 'all' : selectedStatus.value;
      final query = searchQuery.value.trim();

      Logger.d('EmployeeAssignedProjectsController => Loading more page: $nextPage');

      final response = await repository.getAssignedProjects(
        status: statusParam,
        page: nextPage,
        perPage: perPage,
        search: query.isNotEmpty ? query : null,
      );

      if (response.status && response.data.isNotEmpty) {
        // Prevent duplicate entries
        final existingIds = assignedProjects.map((p) => p.id).toSet();
        final newItems = response.data.where((p) => !existingIds.contains(p.id)).toList();
        assignedProjects.addAll(newItems);

        currentPage.value = response.pagination?.currentPage ?? nextPage;
        lastPage.value = response.pagination?.lastPage ?? lastPage.value;
        totalProjects.value = response.pagination?.total ?? totalProjects.value;
      } else {
        lastPage.value = currentPage.value; // No more items
      }
    } catch (e) {
      Logger.e('EmployeeAssignedProjectsController => loadMore error: $e');
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// Quick clear search
  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    fetchAssignedProjects(isRefresh: true);
  }
}
