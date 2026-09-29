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
            .where((doc) =>
                !doc.id.startsWith('doc_1') &&
                !doc.id.startsWith('doc_2') &&
                !doc.id.startsWith('doc_3') &&
                !doc.id.startsWith('doc_4'))
            .toList();
        documents.assignAll(list);
      } else {
        documents.clear();
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
