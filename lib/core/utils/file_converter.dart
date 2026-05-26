import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;

class FileConverter {
  static Future<String?> toBase64(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return null;

      final bytes = await file.readAsBytes();
      final base64String = base64Encode(bytes);
      
      final extension = p.extension(filePath).toLowerCase().replaceAll('.', '');
      String mimeType = 'application/octet-stream';
      
      if (['jpg', 'jpeg', 'png'].contains(extension)) {
        mimeType = 'image/${extension == 'jpg' ? 'jpeg' : extension}';
      } else if (extension == 'pdf') {
        mimeType = 'application/pdf';
      }
      
      return 'data:$mimeType;base64,$base64String';
    } catch (e) {
      return null;
    }
  }
}
