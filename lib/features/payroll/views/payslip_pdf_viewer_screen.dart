import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';

class PayslipPdfViewerScreen extends StatefulWidget {
  final String payslipUrl;
  final String? downloadUrl;
  final String monthLabel;
  final num? netPayable;
  final String? status;
  final String? paymentDate;

  const PayslipPdfViewerScreen({
    super.key,
    required this.payslipUrl,
    this.downloadUrl,
    required this.monthLabel,
    this.netPayable,
    this.status,
    this.paymentDate,
  });

  @override
  State<PayslipPdfViewerScreen> createState() => _PayslipPdfViewerScreenState();
}

class _PayslipPdfViewerScreenState extends State<PayslipPdfViewerScreen> {
  WebViewController? _webViewController;
  bool _isLoading = true;
  double _loadProgress = 0.0;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  String? _cachedLocalPath;

  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    final url = widget.payslipUrl.trim();
    if (url.isEmpty) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Payslip URL is empty.';
        _isLoading = false;
      });
      return;
    }

    // On iOS, WebKit renders PDFs natively with built-in pinch zoom.
    // On Android, use Google Docs viewer for embedded rendering.
    String finalUrl = url;
    if (!kIsWeb && Platform.isAndroid) {
      finalUrl =
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
        ..loadRequest(Uri.parse(finalUrl));
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  String get _sanitizedFileName {
    final safeMonth =
        widget.monthLabel.replaceAll(RegExp(r'[^\w\-]'), '_').trim();
    return 'Payslip_$safeMonth.pdf';
  }

  String get _effectiveDownloadUrl {
    if (widget.downloadUrl != null && widget.downloadUrl!.trim().isNotEmpty) {
      return widget.downloadUrl!.trim();
    }
    return widget.payslipUrl.trim();
  }

  Future<String?> _downloadFileLocally() async {
    if (_cachedLocalPath != null && File(_cachedLocalPath!).existsSync()) {
      return _cachedLocalPath;
    }

    final downloadUrl = _effectiveDownloadUrl;
    if (downloadUrl.isEmpty) return null;

    try {
      final dir = await getApplicationDocumentsDirectory();
      final targetPath = '${dir.path}/$_sanitizedFileName';
      final file = File(targetPath);

      if (await file.exists() && (await file.length()) > 0) {
        _cachedLocalPath = targetPath;
        return targetPath;
      }

      final dio = Dio();
      await dio.download(
        downloadUrl,
        targetPath,
        onReceiveProgress: (received, total) {
          if (total > 0 && mounted) {
            setState(() {
              _downloadProgress = received / total;
            });
          }
        },
      );

      if (await file.exists() && (await file.length()) > 0) {
        _cachedLocalPath = targetPath;
        return targetPath;
      }
    } catch (e) {
      debugPrint('PayslipPdfViewerScreen => Download error: $e');
    }
    return null;
  }

  Future<void> _handleDownloadAndOpen() async {
    if (_isDownloading) return;

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });

    Get.snackbar(
      'Downloading Payslip',
      'Saving "${widget.monthLabel}" payslip to your device...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primaryColor,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      icon: const Icon(Iconsax.document_download, color: Colors.white),
    );

    try {
      final localPath = await _downloadFileLocally();

      if (localPath != null && File(localPath).existsSync()) {
        Get.snackbar(
          'Download Complete',
          'Payslip saved successfully. Opening file...',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF16A34A),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
          icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.white),
        );

        final result = await OpenFilex.open(localPath);
        if (result.type != ResultType.done) {
          // If system reader fails or not installed, fallback to browser
          await _launchExternal();
        }
      } else {
        // Fallback: trigger external application download directly
        await _launchExternal();
      }
    } catch (e) {
      await _launchExternal();
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  Future<void> _launchExternal() async {
    final downloadUrl = _effectiveDownloadUrl;
    final uri = Uri.tryParse(downloadUrl);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        'Notice',
        'Could not open download link.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.warningColor,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _sharePayslip() async {
    final localPath = await _downloadFileLocally();
    if (localPath != null && File(localPath).existsSync()) {
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(localPath, mimeType: 'application/pdf', name: _sanitizedFileName)],
          text: 'Payslip for ${widget.monthLabel}',
        ),
      );
    } else {
      await SharePlus.instance.share(
        ShareParams(
          text: 'Payslip for ${widget.monthLabel}: $_effectiveDownloadUrl',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPaid = (widget.status ?? '').toLowerCase() == 'paid';
    final statusColor = isPaid ? const Color(0xFF16A34A) : const Color(0xFFF59E0B);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textColorPrimary, size: 18),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              'Payslip - ${widget.monthLabel}',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textColorPrimary,
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                if (widget.netPayable != null) ...[
                  AppText(
                    'Net: ${_currencyFormat.format(widget.netPayable)}',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  const AppText('•', fontSize: 11, color: AppColors.slate400),
                  const SizedBox(width: 8),
                ],
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: AppText(
                    (widget.status ?? 'PAID').toUpperCase(),
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Reload',
            icon: const Icon(Icons.refresh_rounded, color: AppColors.slate700, size: 20),
            onPressed: () {
              if (_webViewController != null) {
                _webViewController!.reload();
              } else {
                _initWebView();
              }
            },
          ),
          IconButton(
            tooltip: 'Share',
            icon: const Icon(Iconsax.share, color: AppColors.slate700, size: 20),
            onPressed: _sharePayslip,
          ),
          IconButton(
            tooltip: 'Download',
            icon: _isDownloading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryColor),
                  )
                : const Icon(Iconsax.document_download, color: AppColors.primaryColor, size: 22),
            onPressed: _handleDownloadAndOpen,
          ),
          const SizedBox(width: 4),
        ],
        bottom: _isLoading
            ? PreferredSize(
                preferredSize: const Size.fromHeight(3),
                child: LinearProgressIndicator(
                  value: _loadProgress > 0 ? _loadProgress : null,
                  backgroundColor: AppColors.slate100,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                  minHeight: 3,
                ),
              )
            : null,
      ),
      body: Stack(
        children: [
          // ── PDF WebView ──
          if (_webViewController != null && !_hasError)
            WebViewWidget(controller: _webViewController!),

          // ── Loading Overlay (initial) ──
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.white.withValues(alpha: 0.85),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const SizedBox(
                          width: 36,
                          height: 36,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppText(
                        'Loading Payslip PDF...',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColorPrimary,
                      ),
                      const SizedBox(height: 4),
                      AppText(
                        widget.monthLabel,
                        fontSize: 12,
                        color: AppColors.textColorSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // ── Error State Fallback ──
          if (_hasError)
            Positioned.fill(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.errorColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.picture_as_pdf_rounded,
                          size: 48,
                          color: AppColors.errorColor,
                        ),
                      ),
                      const SizedBox(height: 18),
                      const AppText(
                        'Unable to Render In-App Preview',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      AppText(
                        _errorMessage.isNotEmpty
                            ? 'Error: $_errorMessage\n\nYou can still download or open the payslip directly using your device\'s PDF reader.'
                            : 'You can still download or open the payslip directly using your device\'s PDF reader.',
                        fontSize: 13,
                        color: AppColors.textColorSecondary,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _handleDownloadAndOpen,
                        icon: const Icon(Iconsax.document_download, size: 18),
                        label: const Text('Download & Open PDF'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _hasError = false;
                            _isLoading = true;
                          });
                          _initWebView();
                        },
                        icon: const Icon(Icons.refresh_rounded, size: 16),
                        label: const Text('Try Again'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textColorPrimary,
                          side: const BorderSide(color: AppColors.borderColor),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: MediaQuery.of(context).padding.bottom + 12,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Open in External / Browser button
            Expanded(
              flex: 2,
              child: OutlinedButton.icon(
                onPressed: _launchExternal,
                icon: const Icon(Iconsax.export_1, size: 16),
                label: const Text('Open Browser', maxLines: 1, overflow: TextOverflow.ellipsis),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.slate800,
                  side: const BorderSide(color: AppColors.slate200),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Primary Download Button
            Expanded(
              flex: 3,
              child: ElevatedButton.icon(
                onPressed: _isDownloading ? null : _handleDownloadAndOpen,
                icon: _isDownloading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Iconsax.document_download, size: 18),
                label: Text(
                  _isDownloading
                      ? (_downloadProgress > 0
                          ? 'Saving ${(_downloadProgress * 100).toInt()}%'
                          : 'Downloading...')
                      : 'Download Payslip',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
