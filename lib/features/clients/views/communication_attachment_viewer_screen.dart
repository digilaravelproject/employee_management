import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../../../core/widgets/app_text.dart';

class CommunicationAttachmentViewerScreen extends StatefulWidget {
  final String fileName;
  final String fileUrl;
  final String? fileType;

  const CommunicationAttachmentViewerScreen({
    super.key,
    required this.fileName,
    required this.fileUrl,
    this.fileType,
  });

  @override
  State<CommunicationAttachmentViewerScreen> createState() =>
      _CommunicationAttachmentViewerScreenState();
}

class _CommunicationAttachmentViewerScreenState
    extends State<CommunicationAttachmentViewerScreen> {
  final TransformationController _transformationController =
      TransformationController();
  WebViewController? _webViewController;
  bool _isLoading = true;
  double _loadProgress = 0.0;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  String? _localSavedPath;

  String get _finalUrl => AppConstants.getFileUrl(widget.fileUrl);

  String get _extension {
    if (widget.fileType != null && widget.fileType!.isNotEmpty) {
      return widget.fileType!.toLowerCase().replaceAll('.', '');
    }
    final name = widget.fileName.isNotEmpty ? widget.fileName : widget.fileUrl;
    final dotIndex = name.lastIndexOf('.');
    if (dotIndex != -1 && dotIndex < name.length - 1) {
      final ext = name.substring(dotIndex + 1).split('?').first.toLowerCase();
      return ext;
    }
    return '';
  }

  bool get _isImage =>
      ['png', 'jpg', 'jpeg', 'webp', 'gif', 'bmp'].contains(_extension) ||
      _finalUrl.toLowerCase().contains('.png') ||
      _finalUrl.toLowerCase().contains('.jpg') ||
      _finalUrl.toLowerCase().contains('.jpeg') ||
      _finalUrl.toLowerCase().contains('.webp');

  bool get _isPdf =>
      _extension == 'pdf' || _finalUrl.toLowerCase().contains('.pdf');

  @override
  void initState() {
    super.initState();
    if (_isPdf) {
      _initPdfWebView();
    } else {
      _isLoading = false;
    }
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _initPdfWebView() {
    final url = _finalUrl.trim();
    if (url.isEmpty) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Attachment URL is empty.';
        _isLoading = false;
      });
      return;
    }

    // Android webview cannot render raw PDF directly, so use Google Docs viewer.
    // iOS WebKit handles PDFs natively.
    String finalPdfUrl = url;
    if (!kIsWeb && Platform.isAndroid) {
      finalPdfUrl =
          'https://docs.google.com/viewer?embedded=true&url=${Uri.encodeComponent(url)}';
    }

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
            onPageStarted: (String _) {
              if (mounted) {
                setState(() {
                  _isLoading = true;
                  _hasError = false;
                });
              }
            },
            onPageFinished: (String _) {
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
        ..loadRequest(Uri.parse(finalPdfUrl));
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<String?> _downloadAndGetLocalFile() async {
    if (_localSavedPath != null && File(_localSavedPath!).existsSync()) {
      return _localSavedPath;
    }

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });

    try {
      final tempDir = await getApplicationDocumentsDirectory();
      final sanitizedName = widget.fileName.replaceAll(RegExp(r'[^\w\.-]'), '_');
      final savePath = '${tempDir.path}/$sanitizedName';

      final dio = Dio();
      await dio.download(
        _finalUrl,
        savePath,
        onReceiveProgress: (received, total) {
          if (total > 0 && mounted) {
            setState(() {
              _downloadProgress = received / total;
            });
          }
        },
      );

      _localSavedPath = savePath;
      return savePath;
    } catch (e) {
      CustomSnackbar.showError('Download error: $e');
      return null;
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  Future<void> _downloadFile() async {
    final path = await _downloadAndGetLocalFile();
    if (path != null) {
      CustomSnackbar.showSuccess(
        'Attachment downloaded successfully to device storage.',
      );
    }
  }

  Future<void> _openInExternalApp() async {
    final localPath = await _downloadAndGetLocalFile();
    if (localPath != null) {
      final result = await OpenFilex.open(localPath);
      if (result.type != ResultType.done) {
        // Fallback to browser url
        final uri = Uri.parse(_finalUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      }
    } else {
      final uri = Uri.parse(_finalUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  Future<void> _shareFile() async {
    final localPath = await _downloadAndGetLocalFile();
    if (localPath != null) {
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(localPath)],
          text: widget.fileName,
          subject: widget.fileName,
        ),
      );
    } else {
      await SharePlus.instance.share(
        ShareParams(
          text: '${widget.fileName}\n$_finalUrl',
          subject: widget.fileName,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isImage) {
      return _buildImageViewer();
    } else if (_isPdf) {
      return _buildPdfViewer();
    } else {
      return _buildGenericDocViewer();
    }
  }

  Widget _buildImageViewer() {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
              onPressed: () => Get.back(),
            ),
          ),
        ),
        title: AppText(
          widget.fileName.isNotEmpty ? widget.fileName : 'Image Preview',
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: _isDownloading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      value: _downloadProgress > 0 ? _downloadProgress : null,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.download_rounded, color: Colors.white),
            tooltip: 'Download',
            onPressed: _isDownloading ? null : _downloadFile,
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded, color: Colors.white),
            tooltip: 'Share',
            onPressed: _shareFile,
          ),
          IconButton(
            icon: const Icon(Icons.fullscreen_exit_rounded, color: Colors.white),
            tooltip: 'Reset Zoom',
            onPressed: () {
              _transformationController.value = Matrix4.identity();
            },
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          transformationController: _transformationController,
          minScale: 0.5,
          maxScale: 4.5,
          child: Image.network(
            _finalUrl,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              final percent = (progress.expectedTotalBytes != null && progress.expectedTotalBytes! > 0)
                  ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                  : null;
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      value: percent,
                      color: AppColors.primaryColor,
                    ),
                    const SizedBox(height: 12),
                    const AppText(
                      'Loading Image...',
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                  ],
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.broken_image_rounded, size: 54, color: AppColors.errorColor),
                      const SizedBox(height: 14),
                      AppText(
                        'Unable to load image\n${widget.fileName}',
                        fontSize: 14,
                        textAlign: TextAlign.center,
                        color: Colors.white70,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _openInExternalApp,
                        icon: const Icon(Icons.open_in_browser_rounded, size: 16),
                        label: const AppText('Open in Browser', fontSize: 13, color: Colors.white),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPdfViewer() {
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
              widget.fileName.isNotEmpty ? widget.fileName : 'PDF Viewer',
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textColorPrimary,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const AppText(
              'PDF Document',
              fontSize: 11,
              color: AppColors.textColorHint,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: _isDownloading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      value: _downloadProgress > 0 ? _downloadProgress : null,
                    ),
                  )
                : const Icon(Icons.download_rounded, color: AppColors.textColorPrimary),
            tooltip: 'Download PDF',
            onPressed: _isDownloading ? null : _downloadFile,
          ),
          IconButton(
            icon: const Icon(Icons.open_in_new_rounded, color: AppColors.textColorPrimary),
            tooltip: 'Open in System Viewer',
            onPressed: _openInExternalApp,
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded, color: AppColors.textColorPrimary),
            tooltip: 'Share',
            onPressed: _shareFile,
          ),
        ],
        bottom: _isLoading
            ? PreferredSize(
                preferredSize: const Size.fromHeight(3),
                child: LinearProgressIndicator(
                  value: _loadProgress > 0 ? _loadProgress : null,
                  backgroundColor: AppColors.slate100,
                  color: AppColors.primaryColor,
                  minHeight: 3,
                ),
              )
            : null,
      ),
      body: _hasError
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.picture_as_pdf_rounded, size: 56, color: AppColors.errorColor),
                    const SizedBox(height: 14),
                    AppText(
                      'Could not preview PDF embedded viewer.\n$_errorMessage',
                      fontSize: 13,
                      textAlign: TextAlign.center,
                      color: AppColors.textColorSecondary,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _openInExternalApp,
                      icon: const Icon(Icons.open_in_new_rounded, size: 16, color: Colors.white),
                      label: const AppText('Open in System PDF Viewer', fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : (_webViewController != null
              ? WebViewWidget(controller: _webViewController!)
              : const Center(child: CircularProgressIndicator())),
    );
  }

  Widget _buildGenericDocViewer() {
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
          widget.fileName.isNotEmpty ? widget.fileName : 'Document View',
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.textColorPrimary,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.slate200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.description_rounded, size: 48, color: AppColors.primaryColor),
                ),
                const SizedBox(height: 16),
                AppText(
                  widget.fileName,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  textAlign: TextAlign.center,
                  color: AppColors.textColorPrimary,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.slate100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: AppText(
                    _extension.isNotEmpty ? _extension.toUpperCase() : 'DOCUMENT',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textColorSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _openInExternalApp,
                    icon: const Icon(Icons.open_in_new_rounded, color: Colors.white, size: 18),
                    label: const AppText(
                      'Open File',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _downloadFile,
                    icon: const Icon(Icons.download_rounded, color: AppColors.textColorPrimary, size: 18),
                    label: const AppText(
                      'Save to Device',
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColorPrimary,
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.slate200),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
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
