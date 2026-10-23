import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/network/api_client.dart';
import '../../../core/utils/logger.dart';
import '../domain/usecases/create_lead_source_usecase.dart';
import '../domain/usecases/get_lead_source_detail_usecase.dart';
import '../domain/usecases/get_lead_sources_usecase.dart';
import '../domain/usecases/update_lead_source_usecase.dart';
import '../models/lead_source_model.dart';
import '../repositories/admin_leads_repository.dart';
import '../repositories/admin_leads_repository_interface.dart';

class AdminLeadSourcesController extends GetxController {
  final GetLeadSourcesUseCase getLeadSourcesUseCase;
  final GetLeadSourceDetailUseCase getLeadSourceDetailUseCase;
  final UpdateLeadSourceUseCase updateLeadSourceUseCase;
  final CreateLeadSourceUseCase createLeadSourceUseCase;

  AdminLeadSourcesController({
    required this.getLeadSourcesUseCase,
    required this.getLeadSourceDetailUseCase,
    required this.updateLeadSourceUseCase,
    required this.createLeadSourceUseCase,
  });

  static AdminLeadSourcesController get to {
    if (!Get.isRegistered<AdminLeadSourcesController>()) {
      final apiClient = Get.isRegistered<ApiClient>() ? Get.find<ApiClient>() : ApiClient();
      final repository = Get.isRegistered<AdminLeadsRepositoryInterface>()
          ? Get.find<AdminLeadsRepositoryInterface>()
          : AdminLeadsRepository(apiClient: apiClient);
      final useCase = GetLeadSourcesUseCase(repository);
      final detailUseCase = GetLeadSourceDetailUseCase(repository);
      final updateUseCase = UpdateLeadSourceUseCase(repository);
      final createUseCase = CreateLeadSourceUseCase(repository);

      return Get.put(
        AdminLeadSourcesController(
          getLeadSourcesUseCase: useCase,
          getLeadSourceDetailUseCase: detailUseCase,
          updateLeadSourceUseCase: updateUseCase,
          createLeadSourceUseCase: createUseCase,
        ),
      );
    }
    return Get.find<AdminLeadSourcesController>();
  }

  // Lead Sources List State
  final RxList<LeadSourceModel> leadSources = <LeadSourceModel>[].obs;
  final Rxn<LeadSourcesSummaryModel> summary = Rxn<LeadSourcesSummaryModel>();
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString selectedFilter = 'all'.obs;

  // Single Lead Source By ID Detail State
  final Rxn<LeadSourceModel> sourceDetail = Rxn<LeadSourceModel>();
  final RxBool isDetailLoading = false.obs;
  final RxString detailErrorMessage = ''.obs;

  // Update State
  final RxBool isUpdating = false.obs;
  final RxBool isCreating = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchLeadSources(status: selectedFilter.value);
  }

  Future<void> fetchLeadSources({String? status}) async {
    final filterStatus = status ?? selectedFilter.value;
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await getLeadSourcesUseCase.call(status: filterStatus);

      if (response.status) {
        leadSources.assignAll(response.data);
        summary.value = response.summary;
      } else {
        errorMessage.value = response.message.isNotEmpty
            ? response.message
            : 'Failed to load lead sources';
      }
    } catch (e) {
      Logger.e('AdminLeadSourcesController.fetchLeadSources => Error: $e');
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<LeadSourceModel?> fetchLeadSourceDetail(dynamic id) async {
    isDetailLoading.value = true;
    detailErrorMessage.value = '';

    try {
      final response = await getLeadSourceDetailUseCase.call(id);

      if (response.status && response.data != null) {
        sourceDetail.value = response.data;

        // Sync with existing list entry if available
        final idx = leadSources.indexWhere((element) => element.id == response.data!.id);
        if (idx != -1) {
          leadSources[idx] = response.data!;
        }
        return response.data;
      } else {
        detailErrorMessage.value = response.message.isNotEmpty
            ? response.message
            : 'Failed to load lead source details';
        return null;
      }
    } catch (e) {
      Logger.e('AdminLeadSourcesController.fetchLeadSourceDetail => Error: $e');
      detailErrorMessage.value = e.toString();
      return null;
    } finally {
      isDetailLoading.value = false;
    }
  }

  Future<bool> updateLeadSource(
    dynamic id,
    UpdateLeadSourceRequestModel request, {
    bool showSnackbar = true,
  }) async {
    isUpdating.value = true;
    try {
      final response = await updateLeadSourceUseCase.call(id, request);

      if (response.status && response.data != null) {
        final updatedData = response.data!;

        // Update in list
        final idx = leadSources.indexWhere((element) => element.id == updatedData.id);
        if (idx != -1) {
          leadSources[idx] = updatedData;
        }

        // Update in single detail
        if (sourceDetail.value?.id == updatedData.id) {
          sourceDetail.value = updatedData;
        }

        if (showSnackbar) {
          Get.snackbar(
            'Lead Source Updated 🎯',
            response.message.isNotEmpty ? response.message : 'Lead source updated successfully.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF10B981),
            colorText: Colors.white,
          );
        }
        return true;
      } else {
        Get.snackbar(
          'Update Failed',
          response.message.isNotEmpty ? response.message : 'Failed to update lead source.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFEF4444),
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      Logger.e('AdminLeadSourcesController.updateLeadSource => Error: $e');
      Get.snackbar(
        'Update Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  Future<bool> createLeadSource(
    CreateLeadSourceRequestModel request, {
    bool showSnackbar = true,
  }) async {
    isCreating.value = true;
    try {
      final response = await createLeadSourceUseCase.call(request);

      if (response.status && response.data != null) {
        final newSource = response.data!;
        leadSources.insert(0, newSource);

        final currentSummary = summary.value;
        if (currentSummary != null) {
          summary.value = LeadSourcesSummaryModel(
            total: currentSummary.total + 1,
            active: newSource.isActive ? currentSummary.active + 1 : currentSummary.active,
            inactive: !newSource.isActive ? currentSummary.inactive + 1 : currentSummary.inactive,
            unassignedLeads: currentSummary.unassignedLeads + newSource.unassignedLeadsCount,
          );
        }

        if (showSnackbar) {
          Get.snackbar(
            'Lead Source Created 🎯',
            response.message.isNotEmpty ? response.message : 'Lead source created successfully.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF10B981),
            colorText: Colors.white,
          );
        }
        return true;
      } else {
        Get.snackbar(
          'Creation Failed',
          response.message.isNotEmpty ? response.message : 'Failed to create lead source.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFEF4444),
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
        return false;
      }
    } catch (e) {
      Logger.e('AdminLeadSourcesController.createLeadSource => Error: $e');
      Get.snackbar(
        'Creation Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
      return false;
    } finally {
      isCreating.value = false;
    }
  }

  Future<void> toggleSourceStatus(int sourceId, bool isActive) async {
    // 1. Optimistically update local state for instant UI response
    toggleSourceStatusLocally(sourceId, isActive);

    // 2. Call PATCH API with { "is_active": isActive }
    final request = UpdateLeadSourceRequestModel(isActive: isActive);
    try {
      final response = await updateLeadSourceUseCase.call(sourceId, request);
      if (response.status && response.data != null) {
        final idx = leadSources.indexWhere((element) => element.id == response.data!.id);
        if (idx != -1) {
          leadSources[idx] = response.data!;
        }
        if (sourceDetail.value?.id == response.data!.id) {
          sourceDetail.value = response.data!;
        }
      } else {
        // Rollback on server failure
        toggleSourceStatusLocally(sourceId, !isActive);
        Get.snackbar(
          'Status Update Failed',
          response.message.isNotEmpty ? response.message : 'Could not update source status',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFEF4444),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      // Rollback on network error
      toggleSourceStatusLocally(sourceId, !isActive);
      Logger.e('AdminLeadSourcesController.toggleSourceStatus => Error: $e');
    }
  }

  void toggleSourceStatusLocally(int sourceId, bool isActive) {
    final index = leadSources.indexWhere((element) => element.id == sourceId);
    if (index != -1) {
      final updated = leadSources[index].copyWith(isActive: isActive);
      leadSources[index] = updated;
      if (sourceDetail.value?.id == sourceId) {
        sourceDetail.value = updated;
      }
      // Update summary counts locally if present
      final currentSummary = summary.value;
      if (currentSummary != null) {
        final activeDelta = isActive ? 1 : -1;
        summary.value = LeadSourcesSummaryModel(
          total: currentSummary.total,
          active: (currentSummary.active + activeDelta).clamp(0, currentSummary.total),
          inactive: (currentSummary.inactive - activeDelta).clamp(0, currentSummary.total),
          unassignedLeads: currentSummary.unassignedLeads,
        );
      }
    }
  }

  int get totalSources => summary.value?.total ?? leadSources.length;
  int get activeSources => summary.value?.active ?? leadSources.where((s) => s.isActive).length;
  int get inactiveSources => summary.value?.inactive ?? leadSources.where((s) => !s.isActive).length;
  int get unassignedLeads => summary.value?.unassignedLeads ?? 
      leadSources.fold<int>(0, (sum, item) => sum + item.unassignedLeadsCount);
}
