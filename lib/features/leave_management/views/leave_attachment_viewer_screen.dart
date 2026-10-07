import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text.dart';

class LeaveAttachmentViewerScreen extends StatefulWidget {
  final String title;
  final String url;
  final String? originalPath;

  const LeaveAttachmentViewerScreen({
    super.key,
    required this.title,
    required this.url,
    this.originalPath,
  });

  @override
  State<LeaveAttachmentViewerScreen> createState() =>
      _LeaveAttachmentViewerScreenState();
}

class _LeaveAttachmentViewerScreenState
    extends State<LeaveAttachmentViewerScreen>
    with SingleTickerProviderStateMixin {
  late final TransformationController _transformationController;
  late AnimationController _animationController;
  Animation<Matrix4>? _animation;

  WebViewController? _webViewController;
  bool _isPdfLoading = true;
  double _pdfProgress = 0.0;
  bool _pdfHasError = false;

  double _currentScale = 1.0;
  bool _showOverlays = true;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _transformationController.addListener(_onTransformationChanged);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    )..addListener(() {
        if (_animation != null) {
          _transformationController.value = _animation!.value;
        }
      });

    final isPdf = _isPdf(widget.url) || _isPdf(widget.title);
    if (isPdf) {
      _initPdfViewer();
    }
  }

  void _onTransformationChanged() {
    final scale = _transformationController.value.getMaxScaleOnAxis();
    if ((scale - _currentScale).abs() > 0.05) {
      setState(() {
        _currentScale = scale;
      });
    }
  }

  void _initPdfViewer() {
    final url = widget.url;
    if (File(url).existsSync()) {
      _isPdfLoading = false;
      return;
    }

    if (url.startsWith('http://') || url.startsWith('https://')) {
      final googleDocsUrl =
          'https://docs.google.com/viewer?embedded=true&url=${Uri.encodeComponent(url)}';
      try {
        _webViewController = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onProgress: (int progress) {
                if (mounted) {
                  setState(() {
                    _pdfProgress = progress / 100.0;
                    if (progress >= 100) {
                      _isPdfLoading = false;
                    }
                  });
                }
              },
              onPageStarted: (String url) {
                if (mounted) {
                  setState(() {
                    _isPdfLoading = true;
                    _pdfHasError = false;
                  });
                }
              },
              onPageFinished: (String url) {
                if (mounted) {
                  setState(() {
                    _isPdfLoading = false;
                  });
                }
              },
              onWebResourceError: (WebResourceError error) {
                if (mounted) {
                  setState(() {
                    _pdfHasError = true;
                    _isPdfLoading = false;
                  });
                }
              },
            ),
          )
          ..loadRequest(Uri.parse(googleDocsUrl));
      } catch (e) {
        _pdfHasError = true;
        _isPdfLoading = false;
      }
    } else {
      _isPdfLoading = false;
    }
  }

  @override
  void dispose() {
    _transformationController.removeListener(_onTransformationChanged);
    _transformationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _animateToMatrix(Matrix4 targetMatrix) {
    _animation = Matrix4Tween(
      begin: _transformationController.value,
      end: targetMatrix,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
    _animationController.forward(from: 0.0);
  }

  void _zoomIn() {
    final newScale = (_currentScale * 1.3).clamp(0.5, 6.0);
    final target = Matrix4.diagonal3Values(newScale, newScale, 1.0);
    _animateToMatrix(target);
  }

  void _zoomOut() {
    final newScale = (_currentScale / 1.3).clamp(0.5, 6.0);
    final target = Matrix4.diagonal3Values(newScale, newScale, 1.0);
    _animateToMatrix(target);
  }

  void _resetZoom() {
    _animateToMatrix(Matrix4.identity());
  }

  void _handleDoubleTap(TapDownDetails details) {
    if (_currentScale > 1.2) {
      _resetZoom();
    } else {
      final position = details.localPosition;
      final target = Matrix4.diagonal3Values(2.5, 2.5, 1.0)
        ..setTranslationRaw(-position.dx * 1.5, -position.dy * 1.5, 0.0);
      _animateToMatrix(target);
    }
  }

  bool _isImage(String path) {
    final clean = path.split('?').first.toLowerCase();
    return clean.endsWith('.jpg') ||
        clean.endsWith('.jpeg') ||
        clean.endsWith('.png') ||
        clean.endsWith('.webp') ||
        clean.endsWith('.gif') ||
        clean.endsWith('.bmp');
  }

  bool _isPdf(String path) {
    final clean = path.split('?').first.toLowerCase();
    return clean.endsWith('.pdf');
  }

  Future<void> _handleDownloadOrOpen() async {
    if (_isDownloading) return;

    final targetUrl = widget.url;
    if (targetUrl.isEmpty) {
      Get.snackbar('Notice', 'Attachment URL is empty',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.slate800,
          colorText: Colors.white);
      return;
    }

    // If local file already exists
    if (File(targetUrl).existsSync()) {
      await OpenFilex.open(targetUrl);
      return;
    }

    try {
      setState(() => _isDownloading = true);
      Get.snackbar(
        'Opening Document',
        'Downloading "${widget.title}" to open in default viewer...',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.primaryColor,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      final dir = await getTemporaryDirectory();
      final safeName = widget.title.replaceAll(RegExp(r'[^\w\.\-]'), '_');
      final targetPath = '${dir.path}/$safeName';

      final file = File(targetPath);
      if (!await file.exists() || (await file.length()) == 0) {
        final dio = Dio();
        await dio.download(targetUrl, targetPath);
      }

      setState(() => _isDownloading = false);

      if (await file.exists()) {
        final result = await OpenFilex.open(targetPath);
        if (result.type != ResultType.done) {
          Get.snackbar(
            'Saved',
            'File saved at: $targetPath',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      setState(() => _isDownloading = false);
      // Fallback: Launch in external browser
      final uri = Uri.tryParse(targetUrl);
      if (uri != null && await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          'Error',
          'Could not open attachment: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isImage = _isImage(widget.url) || _isImage(widget.title);
    final isPdf = _isPdf(widget.url) || _isPdf(widget.title);

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19),
      body: Stack(
        children: [
          // ── Main Content Area ──
          GestureDetector(
            onTap: () {
              setState(() {
                _showOverlays = !_showOverlays;
              });
            },
            onDoubleTapDown: isImage ? _handleDoubleTap : null,
            onDoubleTap: isImage ? () {} : null,
            child: SizedBox.expand(
              child: isImage
                  ? InteractiveViewer(
                      transformationController: _transformationController,
                      minScale: 0.5,
                      maxScale: 6.0,
                      boundaryMargin: const EdgeInsets.all(double.infinity),
                      clipBehavior: Clip.none,
                      child: Center(
                        child: _buildImageViewer(),
                      ),
                    )
                  : (isPdf ? _buildPdfViewer() : Center(child: _buildDocumentViewer())),
            ),
          ),

          // ── Top Header Overlay ──
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            top: _showOverlays ? 0 : -120,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8,
                left: 16,
                right: 16,
                bottom: 16,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.9),
                    Colors.black.withValues(alpha: 0.4),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Row(
                children: [
                  // Back Button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      onPressed: () => Get.back(),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // File Name
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppText(
                          widget.title,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        AppText(
                          isPdf
                              ? 'PDF Document'
                              : (isImage ? 'Image Attachment' : 'Leave Attachment'),
                          fontSize: 11,
                          color: Colors.white70,
                        ),
                      ],
                    ),
                  ),

                  // Reset Zoom (if image)
                  if (isImage) ...[
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
                        tooltip: 'Reset Zoom',
                        icon: const Icon(
                          Icons.center_focus_strong_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: _resetZoom,
                      ),
                    ),
                  ],

                  // Open in Native PDF App (if PDF)
                  if (isPdf) ...[
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
                        tooltip: 'Open in System PDF Reader',
                        icon: const Icon(
                          Icons.open_in_new_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: _handleDownloadOrOpen,
                      ),
                    ),
                  ],

                  // Download / Open Externally Button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      tooltip: 'Download / Open',
                      icon: _isDownloading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              Iconsax.document_download,
                              color: Colors.white,
                              size: 20,
                            ),
                      onPressed: _isDownloading ? null : _handleDownloadOrOpen,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom Floating Controls (Zoom controls for image) ──
          if (isImage)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              bottom: _showOverlays
                  ? MediaQuery.of(context).padding.bottom + 16
                  : -100,
              left: 20,
              right: 20,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B).withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Zoom Out
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline_rounded,
                          color: Colors.white, size: 24),
                      onPressed: _zoomOut,
                      tooltip: 'Zoom Out',
                    ),

                    // Scale Percentage
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: AppText(
                        '${(_currentScale * 100).toInt()}%',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),

                    // Zoom In
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline_rounded,
                          color: Colors.white, size: 24),
                      onPressed: _zoomIn,
                      tooltip: 'Zoom In',
                    ),

                    // Hint
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.pinch_rounded,
                            color: Colors.white54, size: 16),
                        SizedBox(width: 4),
                        AppText(
                          'Pinch to zoom',
                          fontSize: 11,
                          color: Colors.white54,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImageViewer() {
    final url = widget.url;

    if (File(url).existsSync()) {
      return Image.file(
        File(url),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => _buildErrorCard(),
      );
    }

    return Image.network(
      url,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        final total = loadingProgress.expectedTotalBytes;
        final loaded = loadingProgress.cumulativeBytesLoaded;
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                value: total != null && total > 0 ? loaded / total : null,
                color: AppColors.primaryColor,
                strokeWidth: 2.5,
              ),
              const SizedBox(height: 12),
              const AppText(
                'Loading attachment...',
                fontSize: 12,
                color: Colors.white70,
              ),
            ],
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => _buildErrorCard(),
    );
  }

  Widget _buildPdfViewer() {
    final url = widget.url;

    // If local file
    if (File(url).existsSync()) {
      return Center(
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.picture_as_pdf_rounded, size: 54, color: Colors.redAccent),
              const SizedBox(height: 18),
              AppText(
                widget.title,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              const AppText('Local PDF Document', fontSize: 12, color: Colors.white60),
              const SizedBox(height: 24),
              AppButton(
                text: 'Open PDF',
                onPressed: () => OpenFilex.open(url),
                color: AppColors.primaryColor,
                textColor: Colors.white,
                borderRadius: 12,
              ),
            ],
          ),
        ),
      );
    }

    if (_pdfHasError) {
      return Center(
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.picture_as_pdf_rounded, size: 54, color: Colors.redAccent),
              const SizedBox(height: 18),
              AppText(
                widget.title,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const AppText(
                'Could not load in-app PDF preview. Tap below to open in your device PDF reader.',
                fontSize: 12,
                color: Colors.white70,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              AppButton(
                text: _isDownloading ? 'Opening...' : 'Open in PDF App',
                onPressed: _isDownloading ? null : _handleDownloadOrOpen,
                color: AppColors.primaryColor,
                textColor: Colors.white,
                borderRadius: 12,
              ),
            ],
          ),
        ),
      );
    }

    if (_webViewController != null) {
      return Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 60),
            child: WebViewWidget(controller: _webViewController!),
          ),
          if (_isPdfLoading)
            Positioned(
              top: MediaQuery.of(context).padding.top + 60,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                value: _pdfProgress > 0 ? _pdfProgress : null,
                color: AppColors.primaryColor,
                backgroundColor: Colors.white24,
                minHeight: 3,
              ),
            ),
        ],
      );
    }

    return _buildDocumentViewer();
  }

  Widget _buildDocumentViewer() {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Iconsax.document,
              size: 54,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(height: 18),
          AppText(
            widget.title,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          const AppText(
            'Document Attachment',
            fontSize: 12,
            color: Colors.white60,
          ),
          const SizedBox(height: 24),
          AppButton(
            text: _isDownloading ? 'Opening...' : 'Open Document',
            onPressed: _isDownloading ? null : _handleDownloadOrOpen,
            color: AppColors.primaryColor,
            textColor: Colors.white,
            borderRadius: 12,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.broken_image_rounded, size: 50, color: Colors.orangeAccent),
          const SizedBox(height: 12),
          AppText(
            widget.title,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          const AppText(
            'Unable to preview image directly.',
            fontSize: 11,
            color: Colors.white60,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          AppButton(
            text: 'Open Externally',
            onPressed: _handleDownloadOrOpen,
            color: AppColors.primaryColor,
            textColor: Colors.white,
            borderRadius: 10,
          ),
        ],
      ),
    );
  }
}
