import '../../auth/domain/models/user_model.dart';

class UserDocumentItem {
  final String id;
  final String name;
  final String type; // 'Image' or 'PDF'
  final String size;
  final String status; // 'Verified', 'Uploaded', 'Under Review'
  final String? filePath; // Local path from file picker / camera
  final String? assetPath; // Fallback asset path
  final String? url; // Network URL from backend
  final DateTime uploadDate;

  UserDocumentItem({
    required this.id,
    required this.name,
    required this.type,
    required this.size,
    this.status = 'Uploaded',
    this.filePath,
    this.assetPath,
    this.url,
    DateTime? uploadDate,
  }) : uploadDate = uploadDate ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'size': size,
        'status': status,
        'filePath': filePath,
        'assetPath': assetPath,
        'url': url,
        'uploadDate': uploadDate.toIso8601String(),
      };

  factory UserDocumentItem.fromJson(Map<String, dynamic> json) =>
      UserDocumentItem(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        type: json['type']?.toString() ?? 'Image',
        size: json['size']?.toString() ?? '1.0 MB',
        status: json['status']?.toString() ?? 'Uploaded',
        filePath: json['filePath']?.toString(),
        assetPath: json['assetPath']?.toString(),
        url: json['url']?.toString(),
        uploadDate: json['uploadDate'] != null
            ? DateTime.tryParse(json['uploadDate'].toString()) ?? DateTime.now()
            : DateTime.now(),
      );

  factory UserDocumentItem.fromUserDocument(UserDocument doc) {
    final sizeStr = doc.size != null
        ? '${(doc.size! / 1024).toStringAsFixed(1)} KB'
        : 'File';
    final fileName = (doc.fileName ?? '').toLowerCase();
    final origName = (doc.originalName ?? '').toLowerCase();
    final mime = (doc.mimeType ?? '').toLowerCase();
    final isImage = mime.contains('image') ||
        fileName.endsWith('.jpg') ||
        fileName.endsWith('.png') ||
        fileName.endsWith('.jpeg') ||
        fileName.endsWith('.webp') ||
        origName.endsWith('.jpg') ||
        origName.endsWith('.png') ||
        origName.endsWith('.jpeg') ||
        origName.endsWith('.webp');

    return UserDocumentItem(
      id: doc.id?.toString() ?? '',
      name: doc.originalName ?? doc.fileName ?? 'Document #${doc.id ?? ''}',
      type: isImage ? 'Image' : 'Document',
      size: sizeStr,
      status: 'Verified',
      url: doc.url,
      uploadDate: doc.createdAt != null
          ? DateTime.tryParse(doc.createdAt!) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
