import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/services/storage/shared_prefs.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../../../core/utils/logger.dart';
import '../models/user_document_model.dart';

class UserDocumentController extends GetxController {
  static const String _storageKey = 'user_uploaded_documents';

  final documents = <UserDocumentItem>[].obs;
  final isLoading = false.obs;
  final isUploading = false.obs;

  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    loadDocuments();
  }

  void loadDocuments() {
    try {
      final savedData = SharedPrefs.getString(_storageKey);
      if (savedData != null && savedData.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(savedData);
        final list = decoded
            .map((item) => UserDocumentItem.fromJson(item as Map<String, dynamic>))
            .toList();
        documents.assignAll(list);
      } else {
        // Initial default documents
        documents.assignAll([
          UserDocumentItem(
            id: 'doc_1',
            name: 'Aadhar Card',
            type: 'Image',
            size: '2.4 MB',
            status: 'Verified',
            assetPath: 'assets/images/intro_img_1.png',
            uploadDate: DateTime.now().subtract(const Duration(days: 30)),
          ),
          UserDocumentItem(
            id: 'doc_2',
            name: 'PAN Card',
            type: 'Image',
            size: '1.1 MB',
            status: 'Verified',
            assetPath: 'assets/images/intro_img_2.png',
            uploadDate: DateTime.now().subtract(const Duration(days: 20)),
          ),
          UserDocumentItem(
            id: 'doc_3',
            name: 'Student ID Card',
            type: 'Image',
            size: '1.8 MB',
            status: 'Verified',
            assetPath: 'assets/images/intro_img_3.png',
            uploadDate: DateTime.now().subtract(const Duration(days: 10)),
          ),
          UserDocumentItem(
            id: 'doc_4',
            name: 'Marksheet / Certificate',
            type: 'Image',
            size: '3.2 MB',
            status: 'Uploaded',
            assetPath: 'assets/images/holiday_banner.png',
            uploadDate: DateTime.now().subtract(const Duration(days: 2)),
          ),
        ]);
        saveDocuments();
      }
    } catch (e) {
      Logger.e('UserDocumentController => Error loading documents: $e');
    }
  }

  Future<void> saveDocuments() async {
    try {
      final jsonList = documents.map((doc) => doc.toJson()).toList();
      await SharedPrefs.setString(_storageKey, jsonEncode(jsonList));
    } catch (e) {
      Logger.e('UserDocumentController => Error saving documents: $e');
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<bool> pickAndUploadImage({
    required String documentName,
    required ImageSource source,
  }) async {
    try {
      isUploading.value = true;
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        return false;
      }

      final file = File(pickedFile.path);
      final int bytes = await file.length();
      final String formattedSize = _formatFileSize(bytes);

      final newDoc = UserDocumentItem(
        id: 'doc_${DateTime.now().millisecondsSinceEpoch}',
        name: documentName.trim().isEmpty ? 'Document' : documentName.trim(),
        type: 'Image',
        size: formattedSize,
        status: 'Uploaded',
        filePath: file.path,
        uploadDate: DateTime.now(),
      );

      documents.insert(0, newDoc);
      await saveDocuments();

      CustomSnackbar.showSuccess('Document "$documentName" uploaded successfully');
      return true;
    } catch (e) {
      Logger.e('UserDocumentController => Image Pick Error: $e');
      CustomSnackbar.showError('Failed to pick document image: ${e.toString()}');
      return false;
    } finally {
      isUploading.value = false;
    }
  }

  Future<bool> pickAndUploadFile({
    required String documentName,
  }) async {
    try {
      isUploading.value = true;
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'webp'],
      );

      if (result == null || result.files.single.path == null) {
        return false;
      }

      final file = File(result.files.single.path!);
      final int bytes = await file.length();
      final String formattedSize = _formatFileSize(bytes);
      final extension = (result.files.single.extension ?? '').toLowerCase();
      final isPdf = extension == 'pdf';

      final newDoc = UserDocumentItem(
        id: 'doc_${DateTime.now().millisecondsSinceEpoch}',
        name: documentName.trim().isEmpty
            ? (result.files.single.name)
            : documentName.trim(),
        type: isPdf ? 'PDF' : 'Image',
        size: formattedSize,
        status: 'Uploaded',
        filePath: file.path,
        uploadDate: DateTime.now(),
      );

      documents.insert(0, newDoc);
      await saveDocuments();

      CustomSnackbar.showSuccess('Document "$documentName" uploaded successfully');
      return true;
    } catch (e) {
      Logger.e('UserDocumentController => File Pick Error: $e');
      CustomSnackbar.showError('Failed to pick file: ${e.toString()}');
      return false;
    } finally {
      isUploading.value = false;
    }
  }

  Future<void> deleteDocument(String id) async {
    final index = documents.indexWhere((doc) => doc.id == id);
    if (index != -1) {
      final removed = documents.removeAt(index);
      await saveDocuments();
      CustomSnackbar.showSuccess('"${removed.name}" deleted');
    }
  }
}
