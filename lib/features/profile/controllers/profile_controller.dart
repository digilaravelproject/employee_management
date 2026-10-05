import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide MultipartFile, FormData;
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/controllers/app_controller.dart';
import '../../../core/services/network/api_client.dart';
import '../../../core/services/storage/shared_prefs.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../../../core/utils/app_validators.dart';
import '../../../core/utils/logger.dart';
import '../../auth/domain/models/user_model.dart';
import '../../auth/controllers/auth_controller.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';

class ProfileController extends GetxController {
  final ApiClient apiClient;

  ProfileController({ApiClient? apiClient})
      : apiClient = apiClient ??
            (Get.isRegistered<ApiClient>() ? Get.find<ApiClient>() : ApiClient());

  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isUpdating = false.obs;

  // Form Controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final departmentController = TextEditingController();
  final designationController = TextEditingController();
  final employeeIdController = TextEditingController();
  final dateOfJoiningController = TextEditingController();
  final addressController = TextEditingController();
  final statusController = TextEditingController();

  // Bank Form Controllers (Employee specific)
  final bankNameController = TextEditingController();
  final accountNumberController = TextEditingController();
  final accountHolderNameController = TextEditingController();
  final ifscCodeController = TextEditingController();
  final branchNameController = TextEditingController();

  // Selected Media
  final Rx<File?> selectedAvatar = Rx<File?>(null);
  final RxList<File> selectedDocuments = <File>[].obs;

  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    loadUserFromStorage();
    fetchProfile();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    departmentController.dispose();
    designationController.dispose();
    employeeIdController.dispose();
    dateOfJoiningController.dispose();
    addressController.dispose();
    statusController.dispose();
    bankNameController.dispose();
    accountNumberController.dispose();
    accountHolderNameController.dispose();
    ifscCodeController.dispose();
    branchNameController.dispose();
    super.onClose();
  }

  void loadUserFromStorage() {
    try {
      final user = SharedPrefs.getUserData();
      if (user != null) {
        currentUser.value = user;
        _populateFields(user);
      } else {
        _populateDefaults();
      }
    } catch (e) {
      Logger.e('ProfileController => Error loading user from storage: $e');
      _populateDefaults();
    }
  }

  void _populateDefaults() {
    final bool isAdmin = isUserAdmin;
    nameController.text = 'Rahul Sharma';
    emailController.text = isAdmin ? 'admin@empmanagement.com' : 'rahul.sharma@company.com';
    phoneController.text = '+91 98765 43210';
    departmentController.text = isAdmin ? 'Management' : 'Design';
    designationController.text = isAdmin ? 'Administrator' : 'UI/UX Designer';
    employeeIdController.text = 'EMP1025';
    dateOfJoiningController.text = '2024-01-15';
    addressController.text = '123, Green Park Street, Sector 45, Noida, Uttar Pradesh - 201301';
    statusController.text = 'Active';
    bankNameController.text = 'HDFC Bank';
    accountNumberController.text = '5010 1234 5678 90';
    accountHolderNameController.text = 'Rahul Sharma';
    ifscCodeController.text = 'HDFC0001234';
    branchNameController.text = 'Noida Sector 45';
  }

  void _populateFields(UserModel user) {
    nameController.text = user.name;
    emailController.text = user.email;
    phoneController.text = user.phone ?? user.mobileNumber ?? '';
    departmentController.text = user.department ?? (isUserAdmin ? 'Management' : 'Design');
    designationController.text = user.designation ?? (isUserAdmin ? 'Administrator' : 'UI/UX Designer');
    employeeIdController.text = user.employeeId ?? 'EMP1025';
    dateOfJoiningController.text = user.dateOfJoining ?? '2024-01-15';
    addressController.text = user.address ?? user.streetAddress ?? '';
    statusController.text = user.status ?? user.employmentStatus ?? 'Active';

    // Bank Details
    bankNameController.text = user.bankName ?? 'HDFC Bank';
    accountNumberController.text = user.accountNumber ?? '5010 1234 5678 90';
    accountHolderNameController.text = user.accountHolderName ?? user.name;
    ifscCodeController.text = user.ifscCode ?? 'HDFC0001234';
    branchNameController.text = user.branchName ?? '';
  }

  bool get isUserAdmin {
    if (Get.isRegistered<AppController>()) {
      return Get.find<AppController>().userRole.value.toLowerCase() == 'admin';
    }
    final role = currentUser.value?.role.toLowerCase().trim() ?? '';
    return role == 'admin' || role == 'superadmin' || role == 'super_admin';
  }

  Future<void> fetchProfile() async {
    try {
      isLoading.value = true;
      final endpoint = isUserAdmin ? AppConstants.adminProfileUrl : AppConstants.adminProfileUrl;
      Logger.d('ProfileController => Fetching profile from: $endpoint');

      final response = await apiClient.get(
        endpoint,
        handleError: false,
        showToaster: false,
      );

      Logger.d('ProfileController => Fetch profile statusCode: ${response.statusCode}, isSuccess: ${response.isSuccess}');

      if (response.isSuccess && response.json != null) {
        dynamic raw = response.json!['data'] ?? response.json!['user'] ?? response.json;
        if (raw is Map<String, dynamic> && raw.containsKey('data') && raw['data'] is Map<String, dynamic>) {
          raw = raw['data'];
        }
        if (raw is Map<String, dynamic>) {
          final user = UserModel.fromJson(raw);
          currentUser.value = user;
          await SharedPrefs.saveUserData(user);
          _populateFields(user);
          if (Get.isRegistered<AuthController>()) {
            Get.find<AuthController>().currentUser.value = user;
          }
          if (Get.isRegistered<AppController>()) {
            Get.find<AppController>().setRole(user.role);
          }
          Logger.d('ProfileController => Profile updated for user: ${user.name}, role: ${user.role}');
        }
      } else {
        Logger.e('ProfileController => Failed to fetch profile: ${response.message}');
      }
    } catch (e, stack) {
      Logger.e('ProfileController => Error in fetchProfile: $e\n$stack');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickAvatar(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(source: source, imageQuality: 85);
      if (picked != null) {
        selectedAvatar.value = File(picked.path);
      }
    } catch (e) {
      Logger.e('ProfileController => Error picking avatar: $e');
    }
  }

  Future<File?> pickDocumentImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(source: source, imageQuality: 85);
      if (picked != null) {
        final file = File(picked.path);
        selectedDocuments.add(file);
        return file;
      }
    } catch (e) {
      Logger.e('ProfileController => Error picking document image: $e');
    }
    return null;
  }

  Future<List<File>> pickMultipleDocumentImages() async {
    try {
      final List<XFile> pickedList = await _picker.pickMultiImage(imageQuality: 85);
      if (pickedList.isNotEmpty) {
        final files = pickedList.map((x) => File(x.path)).toList();
        selectedDocuments.addAll(files);
        return files;
      }
    } catch (e) {
      Logger.e('ProfileController => Error picking multi images: $e');
    }
    return [];
  }

  Future<bool> uploadDocumentImageViaEditProfile(File imageFile) async {
    return uploadDocumentImagesViaEditProfile([imageFile]);
  }

  Future<bool> uploadDocumentImagesViaEditProfile(List<File> imageFiles) async {
    if (imageFiles.isEmpty) return false;
    try {
      isUpdating.value = true;
      final bool isAdmin = isUserAdmin;

      final Map<String, dynamic> dataMap = {
        'name': nameController.text.trim().isNotEmpty
            ? nameController.text.trim()
            : (currentUser.value?.name ?? ''),
        'phone': phoneController.text.trim().isNotEmpty
            ? phoneController.text.trim()
            : (currentUser.value?.phone ?? currentUser.value?.mobileNumber ?? ''),
        'department': departmentController.text.trim().isNotEmpty
            ? departmentController.text.trim()
            : (currentUser.value?.department ?? ''),
        'designation': designationController.text.trim().isNotEmpty
            ? designationController.text.trim()
            : (currentUser.value?.designation ?? ''),
        'employee_id': employeeIdController.text.trim().isNotEmpty
            ? employeeIdController.text.trim()
            : (currentUser.value?.employeeId ?? ''),
        'date_of_joining': dateOfJoiningController.text.trim().isNotEmpty
            ? dateOfJoiningController.text.trim()
            : (currentUser.value?.dateOfJoining ?? ''),
        'address': addressController.text.trim().isNotEmpty
            ? addressController.text.trim()
            : (currentUser.value?.address ?? currentUser.value?.streetAddress ?? ''),
        'status': statusController.text.trim().isNotEmpty
            ? statusController.text.trim()
            : (currentUser.value?.status ?? 'Active'),
      };

      if (!isAdmin) {
        if (bankNameController.text.trim().isNotEmpty) {
          dataMap['bank_name'] = bankNameController.text.trim();
        }
        if (accountNumberController.text.trim().isNotEmpty) {
          dataMap['account_number'] = accountNumberController.text.trim();
        }
        if (accountHolderNameController.text.trim().isNotEmpty) {
          dataMap['account_holder_name'] = accountHolderNameController.text.trim();
        }
        if (ifscCodeController.text.trim().isNotEmpty) {
          dataMap['ifsc_code'] = ifscCodeController.text.trim();
        }
        if (branchNameController.text.trim().isNotEmpty) {
          dataMap['branch_name'] = branchNameController.text.trim();
        }
      }

      final formData = FormData.fromMap(dataMap);

      if (selectedAvatar.value != null) {
        final avatarFile = selectedAvatar.value!;
        final filename = avatarFile.path.split(Platform.pathSeparator).last;
        formData.files.add(MapEntry(
          'avatar',
          await MultipartFile.fromFile(avatarFile.path, filename: filename),
        ));
      }

      for (final imageFile in imageFiles) {
        final filename = imageFile.path.split(Platform.pathSeparator).last;
        // Server API expects 'documnts[]' (exact key in curl) and 'document[]'
        formData.files.add(MapEntry(
          'documnts[]',
          await MultipartFile.fromFile(imageFile.path, filename: filename),
        ));
        formData.files.add(MapEntry(
          'document[]',
          await MultipartFile.fromFile(imageFile.path, filename: filename),
        ));
      }

      Logger.d('ProfileController => Uploading ${imageFiles.length} document image(s) via edit profile API: ${AppConstants.adminUpdateProfileUrl}');
      final response = await apiClient.post(
        AppConstants.adminUpdateProfileUrl,
        data: formData,
        handleError: false,
        showToaster: false,
      );

      if (response.isSuccess && response.json != null) {
        final isStatus = response.json!['status'] == true;
        if (isStatus) {
          final rawData = response.json!['data'];
          if (rawData is Map<String, dynamic>) {
            final updatedUser = UserModel.fromJson(rawData);
            currentUser.value = updatedUser;
            await SharedPrefs.saveUserData(updatedUser);
            _populateFields(updatedUser);
            if (Get.isRegistered<AuthController>()) {
              Get.find<AuthController>().currentUser.value = updatedUser;
            }
          }
          for (final f in imageFiles) {
            selectedDocuments.remove(f);
          }
          await fetchProfile();
          CustomSnackbar.showSuccess(
            response.json!['message']?.toString() ?? 'Document(s) uploaded successfully.',
          );
          return true;
        }
      }
      final msg = response.json?['message']?.toString() ??
          (response.message.isNotEmpty ? response.message : 'Failed to upload document.');
      CustomSnackbar.showError(msg);
      return false;
    } catch (e, stack) {
      Logger.e('ProfileController => Error uploading document: $e\n$stack');
      CustomSnackbar.showError('Failed to upload document');
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  void showAddDocumentImagePicker(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Wrap(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: AppText(
                'Add Document Image',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            ListTile(
              leading: const Icon(Iconsax.gallery, color: AppColors.primaryColor),
              title: const AppText('Choose from Gallery (Images only)', fontSize: 15),
              subtitle: const AppText('Select single or multiple photos', fontSize: 11, color: AppColors.textColorSecondary),
              onTap: () async {
                Get.back();
                final files = await pickMultipleDocumentImages();
                if (files.isNotEmpty) {
                  await uploadDocumentImagesViaEditProfile(files);
                }
              },
            ),
            ListTile(
              leading: const Icon(Iconsax.camera, color: AppColors.primaryColor),
              title: const AppText('Take Photo with Camera', fontSize: 15),
              onTap: () async {
                Get.back();
                final file = await pickDocumentImage(ImageSource.camera);
                if (file != null) {
                  await uploadDocumentImagesViaEditProfile([file]);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void removeSelectedDocument(int index) {
    if (index >= 0 && index < selectedDocuments.length) {
      selectedDocuments.removeAt(index);
    }
  }

  Future<bool> updateProfile() async {
    final phone = phoneController.text.trim();
    if (phone.isNotEmpty && !AppValidators.isValidMobile(phone)) {
      CustomSnackbar.showError('Please enter a valid 10-digit phone number');
      return false;
    }

    try {
      isUpdating.value = true;
      final bool isAdmin = isUserAdmin;

      final Map<String, dynamic> dataMap = {
        'name': nameController.text.trim(),
        'phone': phoneController.text.trim(),
        'department': departmentController.text.trim(),
        'designation': designationController.text.trim(),
        'employee_id': employeeIdController.text.trim(),
        'date_of_joining': dateOfJoiningController.text.trim(),
        'address': addressController.text.trim(),
        'status': statusController.text.trim().isNotEmpty
            ? statusController.text.trim()
            : 'Active',
      };

      // Add bank details for employee
      if (!isAdmin) {
        if (bankNameController.text.trim().isNotEmpty) {
          dataMap['bank_name'] = bankNameController.text.trim();
        }
        if (accountNumberController.text.trim().isNotEmpty) {
          dataMap['account_number'] = accountNumberController.text.trim();
        }
        if (accountHolderNameController.text.trim().isNotEmpty) {
          dataMap['account_holder_name'] = accountHolderNameController.text.trim();
        }
        if (ifscCodeController.text.trim().isNotEmpty) {
          dataMap['ifsc_code'] = ifscCodeController.text.trim();
        }
        if (branchNameController.text.trim().isNotEmpty) {
          dataMap['branch_name'] = branchNameController.text.trim();
        }
      }

      final formData = FormData.fromMap(dataMap);

      // Attach avatar if picked
      if (selectedAvatar.value != null) {
        final avatarFile = selectedAvatar.value!;
        final filename = avatarFile.path.split(Platform.pathSeparator).last;
        formData.files.add(MapEntry(
          'avatar',
          await MultipartFile.fromFile(avatarFile.path, filename: filename),
        ));
      }

      // Attach documnts[] and document[] if picked
      if (selectedDocuments.isNotEmpty) {
        for (final docFile in selectedDocuments) {
          final filename = docFile.path.split(Platform.pathSeparator).last;
          formData.files.add(MapEntry(
            'documnts[]',
            await MultipartFile.fromFile(docFile.path, filename: filename),
          ));
          formData.files.add(MapEntry(
            'document[]',
            await MultipartFile.fromFile(docFile.path, filename: filename),
          ));
        }
      }

      Logger.d('ProfileController => Updating profile at ${AppConstants.adminUpdateProfileUrl}');
      final response = await apiClient.post(
        AppConstants.adminUpdateProfileUrl,
        data: formData,
        handleError: false,
        showToaster: false,
      );

      Logger.d('ProfileController => Response: ${response.statusCode}, isSuccess: ${response.isSuccess}');

      if (response.isSuccess && response.json != null) {
        final isStatus = response.json!['status'] == true;
        if (isStatus) {
          final rawData = response.json!['data'];
          if (rawData is Map<String, dynamic>) {
            final updatedUser = UserModel.fromJson(rawData);
            currentUser.value = updatedUser;
            await SharedPrefs.saveUserData(updatedUser);
            _populateFields(updatedUser);
            if (Get.isRegistered<AuthController>()) {
              Get.find<AuthController>().currentUser.value = updatedUser;
            }
            if (Get.isRegistered<AppController>()) {
              Get.find<AppController>().setRole(updatedUser.role);
            }
          }
          selectedAvatar.value = null;
          selectedDocuments.clear();
          await fetchProfile();
          CustomSnackbar.showSuccess(
            response.json!['message']?.toString() ?? 'Profile updated successfully.',
          );
          return true;
        } else {
          final msg = response.json!['message']?.toString() ?? 'Failed to update profile.';
          CustomSnackbar.showError(msg);
          return false;
        }
      } else {
        final msg = response.message.isNotEmpty
            ? response.message
            : 'Failed to update profile. Please try again.';
        CustomSnackbar.showError(msg);
        return false;
      }
    } catch (e, stackTrace) {
      Logger.e('ProfileController => Exception in updateProfile: $e');
      Logger.e('ProfileController => StackTrace: $stackTrace');
      CustomSnackbar.showError('Something went wrong while updating profile: $e');
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  Future<bool> deleteServerDocument(dynamic documentId, {String? docName}) async {
    try {
      final endpoint = AppConstants.adminDeleteDocumentUrl(documentId);
      Logger.d('ProfileController => Deleting document: $documentId from $endpoint');

      final response = await apiClient.delete(
        endpoint,
        handleError: false,
        showToaster: false,
      );

      Logger.d('ProfileController => Delete document status: ${response.statusCode}, isSuccess: ${response.isSuccess}');

      if (response.isSuccess &&
          (response.json == null ||
              response.json!['status'] == true ||
              response.statusCode == 200 ||
              response.statusCode == 204)) {
        if (currentUser.value != null && currentUser.value!.documents != null) {
          final updatedDocs = List<UserDocument>.from(currentUser.value!.documents!)
            ..removeWhere((doc) => doc.id.toString() == documentId.toString());

          final json = currentUser.value!.toJson();
          json['documents'] = updatedDocs.map((d) => d.toJson()).toList();
          final updatedUser = UserModel.fromJson(json);
          currentUser.value = updatedUser;
          await SharedPrefs.saveUserData(updatedUser);
        }

        CustomSnackbar.showSuccess(
          response.json?['message']?.toString() ??
              'Document "${docName ?? ''}" deleted successfully.',
        );
        return true;
      } else {
        final msg = response.json?['message']?.toString() ??
            (response.message.isNotEmpty
                ? response.message
                : 'Failed to delete document');
        CustomSnackbar.showError(msg);
        return false;
      }
    } catch (e, stack) {
      Logger.e('ProfileController => Error deleting document: $e\n$stack');
      CustomSnackbar.showError('An error occurred while deleting document');
      return false;
    }
  }

  void showDeleteDocumentDialog(
    BuildContext context, {
    required dynamic documentId,
    required String documentName,
    VoidCallback? onDeleted,
  }) {
    final RxBool isDeleting = false.obs;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Iconsax.trash,
                  color: Colors.redAccent,
                  size: 28,
                ),
              ),
              const SizedBox(height: 18),
              const AppText(
                'Delete Document',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textColorPrimary,
              ),
              const SizedBox(height: 10),
              AppText(
                'Are you sure you want to permanently delete "$documentName"? This action cannot be undone.',
                fontSize: 13,
                color: AppColors.textColorSecondary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: AppColors.slate200),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const AppText(
                        'Cancel',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColorSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(
                      () => ElevatedButton(
                        onPressed: isDeleting.value
                            ? null
                            : () async {
                                isDeleting.value = true;
                                final success = await deleteServerDocument(
                                  documentId,
                                  docName: documentName,
                                );
                                isDeleting.value = false;
                                if (success) {
                                  Get.back();
                                  onDeleted?.call();
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: isDeleting.value
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const AppText(
                                'Delete',
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
