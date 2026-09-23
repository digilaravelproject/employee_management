import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../core/services/network/api_client.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../../../core/utils/logger.dart';
import '../domain/usecases/apply_leave_usecase.dart';
import '../domain/usecases/get_leave_types_usecase.dart';
import '../models/apply_leave_request_model.dart';
import '../models/apply_leave_response_model.dart';
import '../models/leave_type_model.dart';
import '../repositories/apply_leave_repository.dart';
import '../repositories/apply_leave_repository_interface.dart';

class ApplyLeaveController extends GetxController {
  final GetLeaveTypesUseCase? getLeaveTypesUseCase;
  final ApplyLeaveUseCase? applyLeaveUseCase;
  final ApplyLeaveRepositoryInterface? repository;

  ApplyLeaveController({
    this.getLeaveTypesUseCase,
    this.applyLeaveUseCase,
    this.repository,
  });

  // Observables
  final RxBool isLoadingLeaveTypes = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxList<LeaveTypeModel> leaveTypes = <LeaveTypeModel>[].obs;
  final Rxn<LeaveTypeModel> selectedLeaveTypeModel = Rxn<LeaveTypeModel>();
  final RxString selectedLeaveType = ''.obs;

  // Assign To field (with static list and user ids)
  final RxString selectedAssignee = 'Rahul Sharma (EMP1021)'.obs;
  final List<Map<String, dynamic>> assignees = const [
    {'id': 1, 'name': 'Rahul Sharma (EMP1021)'},
    {'id': 2, 'name': 'Priya Verma (EMP1024)'},
    {'id': 3, 'name': 'Amit Patel (EMP1028)'},
    {'id': 4, 'name': 'Sneha Roy (EMP1032)'},
    {'id': 5, 'name': 'Vikas Gupta (EMP1035)'},
    {'id': 6, 'name': 'Ananya Mishra (EMP1040)'},
  ];

  List<String> get assigneeList => assignees.map((e) => e['name'] as String).toList();

  final Rx<DateTime?> fromDate = Rx<DateTime?>(null);
  final Rx<DateTime?> toDate = Rx<DateTime?>(null);
  final RxString sessionType = 'Full Day'.obs; // Full Day, 1st Half, 2nd Half
  final RxDouble totalDays = 0.0.obs;

  // Form Controllers
  final TextEditingController reasonController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final Rx<File?> selectedAttachment = Rx<File?>(null);

  final ImagePicker _imagePicker = ImagePicker();

  // Helper getter for dropdown strings from API data only
  List<String> get leaveTypeNames => leaveTypes.map((e) => e.name).toList();

  @override
  void onInit() {
    super.onInit();
    final now = DateTime.now();
    fromDate.value = now;
    toDate.value = now.add(const Duration(days: 1));
    calculateTotalDays();

    fetchLeaveTypes();
  }

  @override
  void onClose() {
    reasonController.dispose();
    contactController.dispose();
    addressController.dispose();
    super.onClose();
  }

  // ----------------------------------------------------
  // Fetch Leave Types from API
  // ----------------------------------------------------
  Future<void> fetchLeaveTypes() async {
    try {
      isLoadingLeaveTypes.value = true;

      LeaveTypeListResponseModel? response;
      if (getLeaveTypesUseCase != null) {
        response = await getLeaveTypesUseCase!.call();
      } else if (repository != null) {
        response = await repository!.getLeaveTypes();
      } else {
        final apiClient = Get.isRegistered<ApiClient>() ? Get.find<ApiClient>() : ApiClient();
        final repo = ApplyLeaveRepository(apiClient: apiClient);
        response = await repo.getLeaveTypes();
      }

      if (response.status && response.data.isNotEmpty) {
        leaveTypes.assignAll(response.data);

        // Pre-select active leave type from API
        final activeLeaves = response.data.where((l) => l.status.toLowerCase() == 'active').toList();
        final initialLeave = activeLeaves.isNotEmpty ? activeLeaves.first : response.data.first;
        selectedLeaveTypeModel.value = initialLeave;
        selectedLeaveType.value = initialLeave.name;
      } else {
        leaveTypes.clear();
        selectedLeaveTypeModel.value = null;
        selectedLeaveType.value = '';
      }
    } catch (e) {
      Logger.e('ApplyLeaveController => fetchLeaveTypes error: $e');
      leaveTypes.clear();
      selectedLeaveTypeModel.value = null;
      selectedLeaveType.value = '';
    } finally {
      isLoadingLeaveTypes.value = false;
    }
  }

  void setAssignee(String assignee) {
    selectedAssignee.value = assignee;
  }

  // ----------------------------------------------------
  // Select Leave Type
  // ----------------------------------------------------
  void setLeaveType(String typeName) {
    selectedLeaveType.value = typeName;
    final match = leaveTypes.firstWhereOrNull((e) => e.name.toLowerCase().trim() == typeName.toLowerCase().trim());
    if (match != null) {
      selectedLeaveTypeModel.value = match;
    }
  }

  void selectLeaveTypeModel(LeaveTypeModel model) {
    selectedLeaveTypeModel.value = model;
    selectedLeaveType.value = model.name;
  }

  // ----------------------------------------------------
  // Session & Days Calculation
  // ----------------------------------------------------
  void setSessionType(String type) {
    sessionType.value = type;
    calculateTotalDays();
  }

  Future<void> selectFromDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: fromDate.value ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      fromDate.value = picked;
      if (toDate.value != null && picked.isAfter(toDate.value!)) {
        toDate.value = picked;
      }
      calculateTotalDays();
    }
  }

  Future<void> selectToDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: toDate.value ?? fromDate.value ?? DateTime.now(),
      firstDate: fromDate.value ?? DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      toDate.value = picked;
      calculateTotalDays();
    }
  }

  void calculateTotalDays() {
    if (fromDate.value == null || toDate.value == null) {
      totalDays.value = 0;
      return;
    }

    int diffInDays = toDate.value!.difference(fromDate.value!).inDays + 1;
    if (diffInDays < 1) diffInDays = 1;

    if (sessionType.value == '1st Half' || sessionType.value == '2nd Half') {
      if (diffInDays == 1) {
        totalDays.value = 0.5;
      } else {
        totalDays.value = diffInDays - 0.5;
      }
    } else {
      totalDays.value = diffInDays.toDouble();
    }
  }

  String getFormattedFromDate() {
    if (fromDate.value == null) return 'Select Date';
    return DateFormat('dd MMM yyyy').format(fromDate.value!);
  }

  String getFormattedToDate() {
    if (toDate.value == null) return 'Select Date';
    return DateFormat('dd MMM yyyy').format(toDate.value!);
  }

  // ----------------------------------------------------
  // Attachment Handling
  // ----------------------------------------------------
  Future<void> pickAttachment({ImageSource source = ImageSource.gallery}) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        selectedAttachment.value = File(pickedFile.path);
      }
    } catch (e) {
      Logger.e('ApplyLeaveController => pickAttachment error: $e');
      CustomSnackbar.showError('Failed to pick document: $e');
    }
  }

  void removeAttachment() {
    selectedAttachment.value = null;
  }

  // ----------------------------------------------------
  // Submit Leave Application via API
  // ----------------------------------------------------
  Future<void> submitLeaveApplication() async {
    final reason = reasonController.text.trim();
    if (reason.isEmpty) {
      CustomSnackbar.showError('Please provide a reason for your leave.');
      return;
    }

    if (fromDate.value == null || toDate.value == null) {
      CustomSnackbar.showError('Please select both From and To dates.');
      return;
    }

    final leaveModel = selectedLeaveTypeModel.value ?? (leaveTypes.isNotEmpty ? leaveTypes.first : null);
    if (leaveModel == null) {
      CustomSnackbar.showError('Please select a valid Leave Type.');
      return;
    }

    if (leaveModel.requiresAttachment && selectedAttachment.value == null) {
      CustomSnackbar.showError('${leaveModel.name} requires supporting document/attachment.');
      return;
    }

    try {
      isSubmitting.value = true;

      int assignedUserId = 1;
      for (final a in assignees) {
        if (a['name'] == selectedAssignee.value) {
          assignedUserId = a['id'] as int;
          break;
        }
      }

      final request = ApplyLeaveRequestModel(
        leaveTypeId: leaveModel.id,
        fromDate: DateFormat('yyyy-MM-dd').format(fromDate.value!),
        toDate: DateFormat('yyyy-MM-dd').format(toDate.value!),
        session: sessionType.value,
        reason: reason,
        contactDuringLeave: contactController.text.trim(),
        addressDuringLeave: addressController.text.trim(),
        assignedToUserId: assignedUserId,
        attachmentPath: selectedAttachment.value?.path,
      );

      ApplyLeaveResponseModel response;
      if (applyLeaveUseCase != null) {
        response = await applyLeaveUseCase!.call(request);
      } else if (repository != null) {
        response = await repository!.applyLeave(request);
      } else {
        final apiClient = Get.isRegistered<ApiClient>() ? Get.find<ApiClient>() : ApiClient();
        final repo = ApplyLeaveRepository(apiClient: apiClient);
        response = await repo.applyLeave(request);
      }

      if (response.status) {
        CustomSnackbar.showSuccess(
          response.message.isNotEmpty ? response.message : 'Leave application submitted successfully!',
        );
        Get.back(result: true);
      } else {
        CustomSnackbar.showError(
          response.message.isNotEmpty ? response.message : 'Failed to submit leave request.',
        );
      }
    } catch (e) {
      Logger.e('ApplyLeaveController => submitLeaveApplication error: $e');
      CustomSnackbar.showError('Something went wrong while applying for leave.');
    } finally {
      isSubmitting.value = false;
    }
  }
}
