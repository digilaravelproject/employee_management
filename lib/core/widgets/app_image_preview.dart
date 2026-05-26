import 'dart:io';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:open_filex/open_filex.dart';
import '../theme/app_colors.dart';
import './app_text.dart';
import './app_button.dart';

class AppImagePreview extends StatelessWidget {
  final String? imageUrl;
  final String? imagePath;
  final String? title;

  final VoidCallback? onDownload;

  const AppImagePreview({
    super.key,
    this.imageUrl,
    this.imagePath,
    this.title,
    this.onDownload,
  });

  static void show(BuildContext context, {String? imageUrl, String? imagePath, String? title, VoidCallback? onDownload}) {
    showDialog(
      context: context,
      useSafeArea: false,
      builder: (context) => AppImagePreview(imageUrl: imageUrl, imagePath: imagePath, title: title, onDownload: onDownload),
    );
  }

  bool _isImage(String? path) {
    if (path == null) return false;
    final String ext = path.toLowerCase();
    return ext.endsWith('.jpg') || ext.endsWith('.jpeg') || ext.endsWith('.png') || ext.endsWith('.webp');
  }

  @override
  Widget build(BuildContext context) {
    final bool isImageFile = _isImage(imagePath ?? imageUrl);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: isImageFile
                ? InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: imagePath != null
                        ? Image.file(File(imagePath!))
                        : Image.network(
                            imageUrl!,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(Icons.error_outline, color: Colors.white, size: 40),
                              );
                            },
                          ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Iconsax.document_text, size: 80, color: Colors.white),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: AppText(
                          title ?? 'Document',
                          style: AppTextStyle.subheading,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          imagePath != null ? imagePath!.split('/').last : 'Remote Document',
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ),
                      const SizedBox(height: 40),
                      AppButton(
                        text: 'View Full Document',
                        onPressed: () {
                          if (imagePath != null) {
                            OpenFilex.open(imagePath!);
                          }
                        },
                        width: 220,
                        color: AppColors.white,
                        textColor: AppColors.primaryColor,
                      ),
                    ],
                  ),
          ),

          // Header with Close and Title
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8,
                bottom: 12,
                left: 16,
                right: 16,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.8),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                children: [
                   IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Iconsax.arrow_left_2, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  if (title != null)
                    Expanded(
                      child: AppText(
                        title!,
                        style: AppTextStyle.subheading,
                        color: Colors.white,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  if (onDownload != null)
                    IconButton(
                      onPressed: onDownload,
                      icon: const Icon(Iconsax.document_download, color: Colors.white),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
