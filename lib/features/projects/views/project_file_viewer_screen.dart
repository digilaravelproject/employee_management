import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../models/project_model.dart';

/// Helper entrypoint to open any project file in its appropriate full-screen viewer.
class ProjectFileViewer {
  static void open(BuildContext context, ProjectFile file) {
    if (file.isImage) {
      Get.to(() => ProjectImageViewerScreen(file: file));
    } else if (file.isPdf) {
      Get.to(() => ProjectPdfViewerScreen(file: file));
    } else {
      Get.to(() => ProjectGenericDocViewerScreen(file: file));
    }
  }

  /// Downloads remote file to temporary directory and returns local path.
  static Future<String?> downloadToLocal(
    String url,
    String fileName, {
    void Function(int received, int total)? onProgress,
  }) async {
    try {
      final dir = await getTemporaryDirectory();
      // Sanitize filename
      final safeName = fileName.replaceAll(RegExp(r'[^\w\.\-]'), '_');
      final targetPath = '${dir.path}/$safeName';
      final file = File(targetPath);
      if (await file.exists() && (await file.length()) > 0) {
        return targetPath;
      }

      final dio = Dio();
      await dio.download(
        url,
        targetPath,
        onReceiveProgress: onProgress,
      );
      return targetPath;
    } catch (e) {
      debugPrint('ProjectFileViewer => downloadToLocal error: $e');
      return null;
    }
  }

  /// Opens the file using the device native reader/application.
  static Future<void> openInSystemReader(BuildContext context, ProjectFile file) async {
    String? path = file.localPath;

    if (path == null || !File(path).existsSync()) {
      if (file.url != null && file.url!.isNotEmpty) {
        Get.snackbar(
          'Preparing File',
          'Downloading "${file.name}" to open in default viewer...',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.primaryColor,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
        path = await downloadToLocal(file.url!, file.name);
      }
    }

    if (path != null && File(path).existsSync()) {
      final result = await OpenFilex.open(path);
      if (result.type != ResultType.done) {
        Get.snackbar(
          'Notice',
          result.message.isNotEmpty ? result.message : 'Could not open file in external app.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.slate800,
          colorText: Colors.white,
        );
      }
    } else if (file.url != null && file.url!.isNotEmpty) {
      final uri = Uri.parse(file.url!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          'Error',
          'Unable to open file.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.errorColor,
          colorText: Colors.white,
        );
      }
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 1. FULL-SCREEN IMAGE VIEWER WITH ZOOM IN / ZOOM OUT & PAN
// ─────────────────────────────────────────────────────────────────────────────
class ProjectImageViewerScreen extends StatefulWidget {
  final ProjectFile file;
  const ProjectImageViewerScreen({super.key, required this.file});

  @override
  State<ProjectImageViewerScreen> createState() => _ProjectImageViewerScreenState();
}

class _ProjectImageViewerScreenState extends State<ProjectImageViewerScreen>
    with SingleTickerProviderStateMixin {
  late final TransformationController _transformationController;
  late AnimationController _animationController;
  Animation<Matrix4>? _animation;

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
  }

  void _onTransformationChanged() {
    final scale = _transformationController.value.getMaxScaleOnAxis();
    if ((scale - _currentScale).abs() > 0.03) {
      setState(() {
        _currentScale = scale;
      });
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
    final newScale = (_currentScale * 1.35).clamp(0.5, 6.0);
    final target = Matrix4.diagonal3Values(newScale, newScale, 1.0);
    _animateToMatrix(target);
  }

  void _zoomOut() {
    final newScale = (_currentScale / 1.35).clamp(0.5, 6.0);
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

  Future<void> _handleDownload() async {
    if (_isDownloading) return;
    setState(() => _isDownloading = true);
    await ProjectFileViewer.openInSystemReader(context, widget.file);
    if (mounted) {
      setState(() => _isDownloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final file = widget.file;

    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      body: Stack(
        children: [
          // ── Zoomable Image Canvas ──
          GestureDetector(
            onTap: () {
              setState(() {
                _showOverlays = !_showOverlays;
              });
            },
            onDoubleTapDown: _handleDoubleTap,
            onDoubleTap: () {},
            child: SizedBox.expand(
              child: InteractiveViewer(
                transformationController: _transformationController,
                minScale: 0.5,
                maxScale: 6.0,
                boundaryMargin: const EdgeInsets.all(double.infinity),
                clipBehavior: Clip.none,
                child: Center(
                  child: _buildImageWidget(file),
                ),
              ),
            ),
          ),

          // ── Top Header Overlay ──
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            top: _showOverlays ? 0 : -130,
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
                    Colors.black.withValues(alpha: 0.85),
                    Colors.black.withValues(alpha: 0.4),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                      onPressed: () => Get.back(),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppText(
                          file.name,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: AppText(
                                file.type,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF60A5FA),
                              ),
                            ),
                            const SizedBox(width: 8),
                            AppText(
                              '${file.sizeMb.toStringAsFixed(2)} MB',
                              fontSize: 11,
                              color: Colors.white70,
                            ),
                            if (file.uploadedByName != null && file.uploadedByName!.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              const AppText('•', fontSize: 11, color: Colors.white54),
                              const SizedBox(width: 6),
                              AppText(
                                file.uploadedByName!,
                                fontSize: 11,
                                color: Colors.white70,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Reset Zoom
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      tooltip: 'Reset Zoom',
                      icon: const Icon(Icons.center_focus_strong_rounded, color: Colors.white, size: 20),
                      onPressed: _resetZoom,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Download / Open
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
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Iconsax.document_download, color: Colors.white, size: 20),
                      onPressed: _handleDownload,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom Floating Zoom Controls ──
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            bottom: _showOverlays ? MediaQuery.of(context).padding.bottom + 16 : -110,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B).withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.15),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.45),
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
                    icon: const Icon(Icons.remove_circle_outline_rounded, color: Colors.white, size: 24),
                    onPressed: _zoomOut,
                    tooltip: 'Zoom Out',
                  ),

                  // Scale Percentage
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
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
                    icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 24),
                    onPressed: _zoomIn,
                    tooltip: 'Zoom In',
                  ),

                  // Hint Text
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.pinch_rounded, color: Colors.white54, size: 16),
                      SizedBox(width: 4),
                      AppText(
                        'Pinch to Zoom',
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

  Widget _buildImageWidget(ProjectFile file) {
    if (file.localPath != null && File(file.localPath!).existsSync()) {
      return Image.file(
        File(file.localPath!),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => _buildErrorCard(file),
      );
    } else if (file.url != null && file.url!.isNotEmpty) {
      return Image.network(
        file.url!,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: AppColors.primaryColor,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                      : null,
                ),
                const SizedBox(height: 16),
                const AppText('Loading image...', fontSize: 13, color: Colors.white70),
              ],
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => _buildErrorCard(file),
      );
    } else {
      return _buildErrorCard(file);
    }
  }

  Widget _buildErrorCard(ProjectFile file) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.broken_image_rounded, size: 54, color: AppColors.errorColor),
          const SizedBox(height: 16),
          AppText(
            file.name,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const AppText(
            'Unable to preview image directly.',
            fontSize: 12,
            color: Colors.white60,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Iconsax.document_download, size: 16, color: Colors.white),
            label: const Text('Open External', style: TextStyle(color: Colors.white)),
            onPressed: () => ProjectFileViewer.openInSystemReader(context, file),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. FULL-SCREEN PDF VIEWER (In-app WebView + External Reader Action)
// ─────────────────────────────────────────────────────────────────────────────
class ProjectPdfViewerScreen extends StatefulWidget {
  final ProjectFile file;
  const ProjectPdfViewerScreen({super.key, required this.file});

  @override
  State<ProjectPdfViewerScreen> createState() => _ProjectPdfViewerScreenState();
}

class _ProjectPdfViewerScreenState extends State<ProjectPdfViewerScreen> {
  WebViewController? _webViewController;
  bool _isLoading = true;
  double _loadProgress = 0.0;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _initPdfViewer();
  }

  void _initPdfViewer() {
    final file = widget.file;
    if (file.url != null && file.url!.isNotEmpty) {
      final googleDocsUrl =
          'https://docs.google.com/viewer?embedded=true&url=${Uri.encodeComponent(file.url!)}';

      try {
        _webViewController = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onProgress: (int progress) {
                if (mounted) {
                  setState(() {
                    _loadProgress = progress / 100.0;
                    if (progress >= 100) {
                      _isLoading = false;
                    }
                  });
                }
              },
              onPageStarted: (String url) {
                if (mounted) {
                  setState(() {
                    _isLoading = true;
                    _hasError = false;
                  });
                }
              },
              onPageFinished: (String url) {
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                  });
                }
              },
              onWebResourceError: (WebResourceError error) {
                if (mounted) {
                  setState(() {
                    _hasError = true;
                    _errorMessage = error.description;
                    _isLoading = false;
                  });
                }
              },
            ),
          )
          ..loadRequest(Uri.parse(googleDocsUrl));
      } catch (e) {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      }
    } else {
      _isLoading = false;
    }
  }

  Future<void> _handleDownload() async {
    if (_isDownloading) return;
    setState(() => _isDownloading = true);
    await ProjectFileViewer.openInSystemReader(context, widget.file);
    if (mounted) {
      setState(() => _isDownloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final file = widget.file;
    final isLocal = file.localPath != null && File(file.localPath!).existsSync();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.slate100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textColorPrimary, size: 18),
              onPressed: () => Get.back(),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              file.name,
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textColorPrimary,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            AppText(
              '${file.sizeMb.toStringAsFixed(2)} MB • PDF Document',
              fontSize: 11,
              color: AppColors.textColorHint,
            ),
          ],
        ),
        actions: [
          // Open in System PDF Reader (Adobe / Drive / Files)
          IconButton(
            tooltip: 'Open in System PDF App',
            icon: const Icon(Icons.open_in_new_rounded, color: AppColors.primaryColor),
            onPressed: () => ProjectFileViewer.openInSystemReader(context, file),
          ),
          // Download / Share
          IconButton(
            tooltip: 'Download PDF',
            icon: _isDownloading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryColor),
                  )
                : const Icon(Iconsax.document_download, color: AppColors.primaryColor),
            onPressed: _handleDownload,
          ),
        ],
        bottom: _isLoading && !isLocal
            ? PreferredSize(
                preferredSize: const Size.fromHeight(3.0),
                child: LinearProgressIndicator(
                  value: _loadProgress > 0 ? _loadProgress : null,
                  backgroundColor: AppColors.slate100,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                ),
              )
            : null,
      ),
      body: isLocal
          ? _buildLocalPdfPreview(file)
          : (_hasError ? _buildErrorView(file) : _buildWebViewPdf(file)),
    );
  }

  Widget _buildWebViewPdf(ProjectFile file) {
    if (_webViewController == null) {
      return _buildErrorView(file);
    }

    return Stack(
      children: [
        WebViewWidget(controller: _webViewController!),
        if (_isLoading)
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryColor),
                  ),
                  SizedBox(width: 14),
                  AppText('Rendering PDF document...', fontSize: 13, fontWeight: FontWeight.w600),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLocalPdfPreview(ProjectFile file) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.slate200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.picture_as_pdf_rounded, color: Colors.redAccent, size: 36),
              ),
              const SizedBox(height: 18),
              AppText(
                file.name,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              AppText(
                '${file.sizeMb.toStringAsFixed(2)} MB • Local Document',
                fontSize: 12,
                color: AppColors.textColorHint,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.open_in_new_rounded, color: Colors.white, size: 18),
                  label: const Text(
                    'Open with PDF Viewer',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () => ProjectFileViewer.openInSystemReader(context, file),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView(ProjectFile file) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.slate200),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.picture_as_pdf_rounded, size: 54, color: Colors.redAccent),
              const SizedBox(height: 16),
              AppText(
                file.name,
                fontSize: 15,
                fontWeight: FontWeight.bold,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              AppText(
                _errorMessage.isNotEmpty
                    ? 'In-app preview could not be loaded. Please open in your external PDF reader.'
                    : 'Opening PDF document...',
                fontSize: 12,
                color: AppColors.textColorSecondary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        setState(() {
                          _isLoading = true;
                          _hasError = false;
                        });
                        _initPdfViewer();
                      },
                      child: const Text('Retry'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.open_in_new_rounded, size: 16, color: Colors.white),
                      label: const Text('Open App', style: TextStyle(color: Colors.white)),
                      onPressed: () => ProjectFileViewer.openInSystemReader(context, file),
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

// ─────────────────────────────────────────────────────────────────────────────
// 3. GENERIC FILE PREVIEW SCREEN (DOCX, XLSX, FIG, ZIP, ETC.)
// ─────────────────────────────────────────────────────────────────────────────
class ProjectGenericDocViewerScreen extends StatelessWidget {
  final ProjectFile file;
  const ProjectGenericDocViewerScreen({super.key, required this.file});

  IconData _getFileIcon(String ext) {
    switch (ext.toLowerCase()) {
      case 'doc':
      case 'docx':
        return Iconsax.document_text;
      case 'xls':
      case 'xlsx':
      case 'csv':
        return Iconsax.chart_2;
      case 'zip':
      case 'rar':
        return Iconsax.archive;
      case 'fig':
        return Iconsax.bezier;
      default:
        return Iconsax.document;
    }
  }

  Color _getFileColor(String ext) {
    switch (ext.toLowerCase()) {
      case 'doc':
      case 'docx':
        return const Color(0xFF2563EB);
      case 'xls':
      case 'xlsx':
      case 'csv':
        return const Color(0xFF059669);
      case 'zip':
      case 'rar':
        return const Color(0xFFD97706);
      case 'fig':
        return const Color(0xFF8B5CF6);
      default:
        return AppColors.primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getFileColor(file.type);
    final icon = _getFileIcon(file.type);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.slate100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textColorPrimary, size: 18),
              onPressed: () => Get.back(),
            ),
          ),
        ),
        title: AppText(
          file.name,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.textColorPrimary,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.slate200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 40),
                ),
                const SizedBox(height: 20),
                AppText(
                  file.name,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                AppText(
                  '${file.type.toUpperCase()} • ${file.sizeMb.toStringAsFixed(2)} MB',
                  fontSize: 13,
                  color: AppColors.textColorSecondary,
                ),
                if (file.uploadedByName != null && file.uploadedByName!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  AppText(
                    'Uploaded by ${file.uploadedByName}',
                    fontSize: 12,
                    color: AppColors.textColorHint,
                  ),
                ],
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.open_in_new_rounded, color: Colors.white, size: 18),
                    label: const Text(
                      'Open File in Device App',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () => ProjectFileViewer.openInSystemReader(context, file),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
