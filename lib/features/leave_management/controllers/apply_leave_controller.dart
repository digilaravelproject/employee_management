import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../core/services/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../../../core/utils/app_validators.dart';
import '../../../core/utils/logger.dart';
import '../domain/usecases/apply_leave_usecase.dart';
import '../domain/usecases/get_leave_types_usecase.dart';
import '../models/apply_leave_request_model.dart';
import '../models/apply_leave_response_model.dart';
import '../models/assignee_user_model.dart';
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

  // Assign To field (dynamic from all-users API)
  final RxBool isLoadingAssignees = false.obs;
  final RxList<AssigneeUserModel> assigneeUsers = <AssigneeUserModel>[].obs;
  final Rxn<AssigneeUserModel> selectedAssigneeUser = Rxn<AssigneeUserModel>();
  final RxString selectedAssignee = ''.obs;

  List<String> get assigneeList => assigneeUsers.map((e) => e.displayName).toList();

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

    _loadInitialAssignees();
    fetchLeaveTypes();
    fetchAssignees();
  }

  @override
  void onClose() {
    reasonController.dispose();
    contactController.dispose();
    addressController.dispose();
    super.onClose();
  }

  // ----------------------------------------------------
  // Load Initial Fallback Assignees from All-Users schema
  // ----------------------------------------------------
  void _loadInitialAssignees() {
    final initialList = [
      AssigneeUserModel(id: 20, name: 'Rahul Sharma', employeeId: 'EMP-2026-019', designation: 'Lead Flutter Developer'),
      AssigneeUserModel(id: 19, name: 'Rahul Sharma', employeeId: 'EMP-2026-018', designation: 'Lead Flutter Developer'),
      AssigneeUserModel(id: 18, name: 'saurabh sawant', employeeId: 'EMP-2026-010', designation: 'Lead Flutter Developer'),
      AssigneeUserModel(id: 17, name: 'Rahul Sharma', employeeId: 'EMP-2026-015', designation: 'Lead Flutter Developer'),
      AssigneeUserModel(id: 16, name: 'Rahul Sharma', employeeId: 'EMP-2026-014', designation: 'Lead Flutter Developer'),
      AssigneeUserModel(id: 15, name: 'Rahul Sharma', employeeId: 'EMP-2026-013', designation: 'Lead Flutter Developer'),
      AssigneeUserModel(id: 14, name: 'Rahul Sharma', employeeId: 'EMP-2026-012', designation: 'Lead Flutter Developer'),
      AssigneeUserModel(id: 13, name: 'Rahul Sharma', employeeId: 'EMP-2026-011', designation: 'Lead Flutter Developer'),
      AssigneeUserModel(id: 12, name: 'Rahul Sharma01', employeeId: 'EMP1025', designation: 'UI/UX Designer'),
      AssigneeUserModel(id: 7, name: 'Rahul Sharma', employeeId: 'EMP-2026-007', designation: 'Lead Flutter Developer'),
      AssigneeUserModel(id: 8, name: 'Administrator', employeeId: 'EMP1025', designation: 'Administrator'),
      AssigneeUserModel(id: 6, name: 'Rohit S. Sharma', employeeId: 'EMP-2026-003', designation: 'Lead Flutter Developer'),
      AssigneeUserModel(id: 4, name: 'Sarah Smith', designation: 'HR Executive'),
      AssigneeUserModel(id: 5, name: 'Michael Brown', designation: 'Lead Developer'),
      AssigneeUserModel(id: 3, name: 'John Doe', employeeId: 'EMP1026', designation: 'Senior Flutter Developer'),
      AssigneeUserModel(id: 2, name: 'Rahul Sharma', employeeId: 'EMP1025', designation: 'UI/UX Designer'),
      AssigneeUserModel(id: 1, name: 'Rahul Sharma', employeeId: 'EMP1025', role: 'admin'),
    ];

    final Map<String, int> nameCounts = {};
    for (final u in initialList) {
      nameCounts[u.displayName] = (nameCounts[u.displayName] ?? 0) + 1;
    }

    final processed = initialList.map((u) {
      if ((nameCounts[u.displayName] ?? 0) > 1) {
        return u.copyWith(displayName: '${u.displayName} (#${u.id})');
      }
      return u;
    }).toList();

    assigneeUsers.assignAll(processed);
    if (processed.isNotEmpty && selectedAssigneeUser.value == null) {
      selectedAssigneeUser.value = processed.first;
      selectedAssignee.value = processed.first.displayName;
    }
  }

  // ----------------------------------------------------
  // Fetch All Users / Assignees from API
  // ----------------------------------------------------
  Future<void> fetchAssignees() async {
    try {
      isLoadingAssignees.value = true;
      final apiClient = Get.isRegistered<ApiClient>() ? Get.find<ApiClient>() : ApiClient();
      final repo = repository ?? ApplyLeaveRepository(apiClient: apiClient);
      final response = await repo.getAllUsers();

      if (response.status && response.data.isNotEmpty) {
        // Disambiguate if duplicate display names exist
        final Map<String, int> nameCounts = {};
        for (final u in response.data) {
          nameCounts[u.displayName] = (nameCounts[u.displayName] ?? 0) + 1;
        }

        final processedUsers = response.data.map((u) {
          if ((nameCounts[u.displayName] ?? 0) > 1) {
            return u.copyWith(displayName: '${u.displayName} (#${u.id})');
          }
          return u;
        }).toList();

        assigneeUsers.assignAll(processedUsers);

        // Retain current selection if valid, otherwise select first
        if (selectedAssigneeUser.value != null &&
            assigneeUsers.any((u) => u.id == selectedAssigneeUser.value!.id)) {
          final matched = assigneeUsers.firstWhere((u) => u.id == selectedAssigneeUser.value!.id);
          selectedAssigneeUser.value = matched;
          selectedAssignee.value = matched.displayName;
        } else if (assigneeUsers.isNotEmpty) {
          selectedAssigneeUser.value = assigneeUsers.first;
          selectedAssignee.value = assigneeUsers.first.displayName;
        }
      }
    } catch (e) {
      Logger.e('ApplyLeaveController => fetchAssignees error: $e');
    } finally {
      isLoadingAssignees.value = false;
    }
  }

  void setAssignee(String assigneeDisplayName) {
    selectedAssignee.value = assigneeDisplayName;
    final match = assigneeUsers.firstWhereOrNull((u) => u.displayName == assigneeDisplayName);
    if (match != null) {
      selectedAssigneeUser.value = match;
    }
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

  Future<void> pickPdf() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result != null && result.files.single.path != null) {
        selectedAttachment.value = File(result.files.single.path!);
      }
    } catch (e) {
      Logger.e('ApplyLeaveController => pickPdf error: $e');
      CustomSnackbar.showError('Failed to pick PDF: $e');
    }
  }

  Future<void> pickDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'webp'],
      );
      if (result != null && result.files.single.path != null) {
        selectedAttachment.value = File(result.files.single.path!);
      }
    } catch (e) {
      Logger.e('ApplyLeaveController => pickDocument error: $e');
      CustomSnackbar.showError('Failed to pick document: $e');
    }
  }

  void showAttachmentPickerModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const AppText(
                      'Upload Document',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColorPrimary,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.textColorHint),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const AppText(
                  'Select a document format to attach to your leave request',
                  fontSize: 12,
                  color: AppColors.textColorSecondary,
                ),
                const SizedBox(height: 20),

                // Option 1: PDF Document
                _buildPickerOption(
                  icon: Icons.picture_as_pdf_rounded,
                  iconColor: const Color(0xFFEF4444),
                  iconBgColor: const Color(0xFFEF4444).withValues(alpha: 0.1),
                  title: 'Upload PDF Document',
                  subtitle: 'Select .pdf file from your device files',
                  onTap: () {
                    Navigator.pop(ctx);
                    pickPdf();
                  },
                ),
                const SizedBox(height: 12),

                // Option 2: Image from Gallery
                _buildPickerOption(
                  icon: Iconsax.gallery,
                  iconColor: AppColors.primaryColor,
                  iconBgColor: AppColors.primaryLight,
                  title: 'Choose from Gallery',
                  subtitle: 'Select JPG, PNG photo from gallery',
                  onTap: () {
                    Navigator.pop(ctx);
                    pickAttachment(source: ImageSource.gallery);
                  },
                ),
                const SizedBox(height: 12),

                // Option 3: Camera
                _buildPickerOption(
                  icon: Iconsax.camera,
                  iconColor: const Color(0xFF10B981),
                  iconBgColor: const Color(0xFF10B981).withValues(alpha: 0.1),
                  title: 'Take a Photo',
                  subtitle: 'Capture document with your camera',
                  onTap: () {
                    Navigator.pop(ctx);
                    pickAttachment(source: ImageSource.camera);
                  },
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPickerOption({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.slate200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(title, fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textColorPrimary),
                  const SizedBox(height: 2),
                  AppText(subtitle, fontSize: 11, color: AppColors.textColorSecondary),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textColorHint, size: 20),
          ],
        ),
      ),
    );
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

    final contactNum = contactController.text.trim();
    if (contactNum.isNotEmpty && !AppValidators.isValidMobile(contactNum)) {
      CustomSnackbar.showError('Please enter a valid 10-digit contact number.');
      return;
    }

    try {
      isSubmitting.value = true;

      int? assignedUserId = selectedAssigneeUser.value?.id;
      if (assignedUserId == null) {
        for (final a in assigneeUsers) {
          if (a.displayName == selectedAssignee.value || a.name == selectedAssignee.value) {
            assignedUserId = a.id;
            break;
          }
        }
      }
      assignedUserId ??= assigneeUsers.isNotEmpty ? assigneeUsers.first.id : 1;

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
