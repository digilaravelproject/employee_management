import 'package:get/get.dart';
import '../../../core/services/network/api_client.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../../../core/utils/logger.dart';
import '../models/admin_leave_model.dart';
import '../repositories/admin_leave_repository.dart';
import '../repositories/admin_leave_repository_interface.dart';

class MyLeavesController extends GetxController {
  final AdminLeaveRepositoryInterface repository;

  MyLeavesController({AdminLeaveRepositoryInterface? repository})
      : repository = repository ??
            AdminLeaveRepository(
              apiClient: Get.isRegistered<ApiClient>() ? Get.find<ApiClient>() : ApiClient(),
            );

  // Observables
  final RxBool isLoading = false.obs;
  final RxBool isActionLoading = false.obs;
  final RxString selectedStatus = 'All'.obs; // All, Pending, Approved, Rejected, Cancelled
  final RxInt selectedYear = 2026.obs;

  final RxList<AdminLeaveItemModel> leaveRequests = <AdminLeaveItemModel>[].obs;
  final Rx<AdminLeaveCountsModel?> counts = Rx<AdminLeaveCountsModel?>(null);
  final RxList<LeaveBalanceOverviewModel> leaveBalances = <LeaveBalanceOverviewModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchLeaveRequests();
  }

  // ----------------------------------------------------
  // Fetch Leave Requests (GET /api/admin/leave-requests)
  // ----------------------------------------------------
  Future<void> fetchLeaveRequests({String? status, int? year}) async {
    try {
      isLoading.value = true;
      final targetStatus = (status ?? selectedStatus.value).toLowerCase();
      final targetYear = year ?? selectedYear.value;

      Logger.d('MyLeavesController => fetchLeaveRequests with status=$targetStatus, year=$targetYear, per_page=15');

      final response = await repository.getLeaveRequests(
        status: targetStatus,
        year: targetYear,
        perPage: 15,
      );

      if (response.status) {
        leaveRequests.assignAll(response.data);
        if (response.counts != null) {
          counts.value = response.counts;
        }
        if (response.leaveBalances.isNotEmpty) {
          leaveBalances.assignAll(response.leaveBalances);
        }
        Logger.d('MyLeavesController => Successfully fetched ${leaveRequests.length} requests');
      } else {
        Logger.w('MyLeavesController => Response returned status false: ${response.message}');
      }
    } catch (e, stack) {
      Logger.e('MyLeavesController => fetchLeaveRequests error: $e');
      Logger.e('MyLeavesController => StackTrace: $stack');
    } finally {
      isLoading.value = false;
    }
  }

  void setStatus(String status) {
    if (selectedStatus.value == status) return;
    selectedStatus.value = status;
    fetchLeaveRequests(status: status);
  }

  void setYear(int year) {
    if (selectedYear.value == year) return;
    selectedYear.value = year;
    fetchLeaveRequests(year: year);
  }

  // ----------------------------------------------------
  // Approve Leave Request
  // ----------------------------------------------------
  Future<void> approveLeave(int leaveId, {String? note}) async {
    try {
      isActionLoading.value = true;
      final response = await repository.approveLeaveRequest(leaveId, note: note);
      if (response.isSuccess) {
        CustomSnackbar.showSuccess(response.message.isNotEmpty ? response.message : 'Leave approved successfully');
        await fetchLeaveRequests();
      } else {
        CustomSnackbar.showError(response.message.isNotEmpty ? response.message : 'Failed to approve leave');
      }
    } catch (e) {
      Logger.e('MyLeavesController => approveLeave error: $e');
      CustomSnackbar.showError('Error approving leave request');
    } finally {
      isActionLoading.value = false;
    }
  }

  // ----------------------------------------------------
  // Reject Leave Request
  // ----------------------------------------------------
  Future<void> rejectLeave(int leaveId, {String? note}) async {
    try {
      isActionLoading.value = true;
      final response = await repository.rejectLeaveRequest(leaveId, note: note);
      if (response.isSuccess) {
        CustomSnackbar.showSuccess(response.message.isNotEmpty ? response.message : 'Leave rejected successfully');
        await fetchLeaveRequests();
      } else {
        CustomSnackbar.showError(response.message.isNotEmpty ? response.message : 'Failed to reject leave');
      }
    } catch (e) {
      Logger.e('MyLeavesController => rejectLeave error: $e');
      CustomSnackbar.showError('Error rejecting leave request');
    } finally {
      isActionLoading.value = false;
    }
  }
}
