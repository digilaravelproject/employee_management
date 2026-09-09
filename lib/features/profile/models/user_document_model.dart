class UserDocumentItem {
  final String id;
  final String name;
  final String type; // 'Image' or 'PDF'
  final String size;
  final String status; // 'Verified', 'Uploaded', 'Under Review'
  final String? filePath; // Local path from file picker / camera
  final String? assetPath; // Fallback asset path
  final DateTime uploadDate;

  UserDocumentItem({
    required this.id,
    required this.name,
    required this.type,
    required this.size,
    this.status = 'Uploaded',
    this.filePath,
    this.assetPath,
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
        uploadDate: json['uploadDate'] != null
            ? DateTime.tryParse(json['uploadDate'].toString()) ?? DateTime.now()
            : DateTime.now(),
      );
}
