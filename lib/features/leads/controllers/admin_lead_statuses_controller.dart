import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/network/api_client.dart';
import '../../../core/utils/logger.dart';
import '../domain/usecases/create_lead_status_usecase.dart';
import '../domain/usecases/delete_lead_status_usecase.dart';
import '../domain/usecases/get_lead_status_detail_usecase.dart';
import '../domain/usecases/get_lead_statuses_usecase.dart';
import '../domain/usecases/update_lead_status_usecase.dart';
import '../models/lead_status_model.dart';
import '../repositories/admin_leads_repository.dart';
import '../repositories/admin_leads_repository_interface.dart';

class AdminLeadStatusesController extends GetxController {
  final GetLeadStatusesUseCase getLeadStatusesUseCase;
  final CreateLeadStatusUseCase createLeadStatusUseCase;
  final DeleteLeadStatusUseCase deleteLeadStatusUseCase;
  final GetLeadStatusDetailUseCase? getLeadStatusDetailUseCase;
  final UpdateLeadStatusUseCase? updateLeadStatusUseCase;

  AdminLeadStatusesController({
    required this.getLeadStatusesUseCase,
    required this.createLeadStatusUseCase,
    required this.deleteLeadStatusUseCase,
    this.getLeadStatusDetailUseCase,
    this.updateLeadStatusUseCase,
  });

  static AdminLeadStatusesController get to {
    if (!Get.isRegistered<AdminLeadStatusesController>()) {
      final apiClient = Get.isRegistered<ApiClient>() ? Get.find<ApiClient>() : ApiClient();
      final repository = Get.isRegistered<AdminLeadsRepositoryInterface>()
          ? Get.find<AdminLeadsRepositoryInterface>()
          : AdminLeadsRepository(apiClient: apiClient);
      final getUseCase = GetLeadStatusesUseCase(repository);
      final createUseCase = CreateLeadStatusUseCase(repository);
      final deleteUseCase = DeleteLeadStatusUseCase(repository);
      final detailUseCase = GetLeadStatusDetailUseCase(repository);
      final updateUseCase = UpdateLeadStatusUseCase(repository);

      return Get.put(
        AdminLeadStatusesController(
          getLeadStatusesUseCase: getUseCase,
          createLeadStatusUseCase: createUseCase,
          deleteLeadStatusUseCase: deleteUseCase,
          getLeadStatusDetailUseCase: detailUseCase,
          updateLeadStatusUseCase: updateUseCase,
        ),
      );
    }
    return Get.find<AdminLeadStatusesController>();
  }

  final RxList<LeadStatusModel> leadStatuses = <LeadStatusModel>[].obs;
  final Rxn<LeadStatusModel> statusDetail = Rxn<LeadStatusModel>();
  final RxBool isLoading = false.obs;
  final RxBool isLoadingDetail = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString selectedCategory = 'active_lead'.obs;
  final RxInt totalCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchLeadStatuses(category: selectedCategory.value);
  }

  // ── Fetch Lead Statuses ────────────────────────────────────────────────────
  Future<void> fetchLeadStatuses({String? category, bool showLoading = true}) async {
    if (category != null) {
      selectedCategory.value = category;
    }
    if (showLoading) isLoading.value = true;
    errorMessage.value = '';

    try {
      final categoryFilter = selectedCategory.value.trim().toLowerCase() == 'all'
          ? null
          : selectedCategory.value.trim();

      final response = await getLeadStatusesUseCase(category: categoryFilter);
      if (response.status) {
        leadStatuses.value = response.data;
        totalCount.value = response.total ?? response.data.length;
        errorMessage.value = '';
      } else {
        errorMessage.value = response.message;
      }
    } catch (e) {
      Logger.e('AdminLeadStatusesController => fetchLeadStatuses error: $e');
      errorMessage.value = e.toString();
    } finally {
      if (showLoading) isLoading.value = false;
    }
  }

  void filterByCategory(String cat) {
    if (selectedCategory.value == cat) return;
    fetchLeadStatuses(category: cat);
  }

  // ── Create Lead Status ─────────────────────────────────────────────────────
  Future<bool> createLeadStatus({
    required String name,
    required String category,
    String? description,
    required String badgeColor,
    int? orderPosition,
  }) async {
    isSubmitting.value = true;
    try {
      final request = CreateLeadStatusRequestModel(
        name: name,
        category: category,
        description: description,
        badgeColor: badgeColor,
        orderPosition: orderPosition ?? (leadStatuses.length + 1),
      );

      final response = await createLeadStatusUseCase(request);
      if (response.status) {
        if (response.data != null) {
          leadStatuses.add(response.data!);
        } else {
          // Re-fetch list
          await fetchLeadStatuses(showLoading: false);
        }

        Get.snackbar(
          'Lead Status Created',
          response.message.isNotEmpty
              ? response.message
              : 'Status "$name" created successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return true;
      } else {
        Get.snackbar(
          'Failed to Create Status',
          response.message.isNotEmpty ? response.message : 'Something went wrong.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFEF4444),
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
        return false;
      }
    } catch (e) {
      Logger.e('AdminLeadStatusesController => createLeadStatus error: $e');
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  // ── Fetch Single Status Detail ─────────────────────────────────────────────
  Future<void> fetchLeadStatusDetail(dynamic id, {bool showLoading = true}) async {
    if (showLoading) isLoadingDetail.value = true;
    try {
      if (getLeadStatusDetailUseCase != null) {
        final response = await getLeadStatusDetailUseCase!(id);
        if (response.status && response.data != null) {
          statusDetail.value = response.data;
        }
      }
    } catch (e) {
      Logger.e('AdminLeadStatusesController => fetchLeadStatusDetail error: $e');
    } finally {
      if (showLoading) isLoadingDetail.value = false;
    }
  }

  // ── Update Lead Status ─────────────────────────────────────────────────────
  Future<bool> updateLeadStatus({
    required dynamic id,
    required String name,
    required String category,
    String? description,
    required String badgeColor,
    int? orderPosition,
  }) async {
    isSubmitting.value = true;
    try {
      final request = CreateLeadStatusRequestModel(
        name: name,
        category: category,
        description: description,
        badgeColor: badgeColor,
        orderPosition: orderPosition,
      );

      if (updateLeadStatusUseCase != null) {
        final response = await updateLeadStatusUseCase!(id, request);
        if (response.status) {
          if (response.data != null) {
            statusDetail.value = response.data;
            final idx = leadStatuses.indexWhere((s) => s.id == id);
            if (idx != -1) {
              leadStatuses[idx] = response.data!;
            }
          }
          await fetchLeadStatuses(category: selectedCategory.value, showLoading: false);

          Get.snackbar(
            'Lead Status Updated',
            response.message.isNotEmpty
                ? response.message
                : 'Status "$name" updated successfully.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF10B981),
            colorText: Colors.white,
          );
          return true;
        } else {
          Get.snackbar(
            'Update Failed',
            response.message.isNotEmpty ? response.message : 'Could not update status.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFFEF4444),
            colorText: Colors.white,
          );
          return false;
        }
      }
      return false;
    } catch (e) {
      Logger.e('AdminLeadStatusesController => updateLeadStatus error: $e');
      Get.snackbar('Error', e.toString(), backgroundColor: const Color(0xFFEF4444), colorText: Colors.white);
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  // ── Delete Lead Status ─────────────────────────────────────────────────────
  Future<bool> deleteLeadStatus(dynamic id, {String? statusName}) async {
    isSubmitting.value = true;
    try {
      final success = await deleteLeadStatusUseCase(id);
      if (success) {
        leadStatuses.removeWhere((s) => s.id == id);
        if (statusDetail.value?.id == id) {
          statusDetail.value = null;
        }
        totalCount.value = leadStatuses.length;
        Get.snackbar(
          'Status Deleted',
          'Lead status ${statusName != null ? "\"$statusName\" " : ""}deleted successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
        );
        return true;
      } else {
        Get.snackbar(
          'Delete Failed',
          'Could not delete lead status.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFEF4444),
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      Logger.e('AdminLeadStatusesController => deleteLeadStatus error: $e');
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }
}
