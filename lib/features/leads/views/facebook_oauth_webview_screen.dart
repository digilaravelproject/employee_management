import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';

class FacebookOAuthWebViewScreen extends StatefulWidget {
  final String url;
  final String? redirectUri;
  final String? title;

  const FacebookOAuthWebViewScreen({
    super.key,
    required this.url,
    this.redirectUri,
    this.title,
  });

  @override
  State<FacebookOAuthWebViewScreen> createState() => _FacebookOAuthWebViewScreenState();
}

class _FacebookOAuthWebViewScreenState extends State<FacebookOAuthWebViewScreen> {
  late final WebViewController _webViewController;
  bool _isLoading = true;
  double _progress = 0.0;
  bool _hasError = false;
  String _errorMessage = '';
  late String _currentUrl;
  bool _callbackHandled = false;

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.url;
    _initWebViewController();
  }

  void _initWebViewController() {
    try {
      _webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.white)
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {
              if (mounted) {
                setState(() {
                  _progress = progress / 100.0;
                  if (progress >= 100) {
                    _isLoading = false;
                  }
                });
              }
            },
            onPageStarted: (String url) {
              if (_isCallbackUrl(url)) {
                _checkCallback(url);
                return;
              }
              if (mounted) {
                setState(() {
                  _currentUrl = url;
                  _isLoading = true;
                  _hasError = false;
                });
              }
            },
            onPageFinished: (String url) {
              if (_isCallbackUrl(url)) {
                _checkCallback(url);
                return;
              }
              if (mounted) {
                setState(() {
                  _currentUrl = url;
                  _isLoading = false;
                });
              }
            },
            onWebResourceError: (WebResourceError error) {
              // Ignore errors if callback has already succeeded or if it's unknown url scheme for custom redirect
              if (_callbackHandled) return;

              // Only treat main-frame errors as fatal page loading errors
              if (error.isForMainFrame ?? true) {
                if (mounted) {
                  setState(() {
                    _hasError = true;
                    _errorMessage = error.description;
                    _isLoading = false;
                  });
                }
              }
            },
            onNavigationRequest: (NavigationRequest request) {
              if (_isCallbackUrl(request.url)) {
                _checkCallback(request.url);
                return NavigationDecision.prevent;
              }
              return NavigationDecision.navigate;
            },
          ),
        )
        ..loadRequest(Uri.parse(widget.url));
    } catch (e) {
      _hasError = true;
      _errorMessage = e.toString();
      _isLoading = false;
    }
  }

  bool _isCallbackUrl(String url) {
    final redirect = widget.redirectUri;
    if (redirect != null && redirect.isNotEmpty) {
      if (url.startsWith(redirect) || url.contains(redirect)) {
        return true;
      }
    }

    if (url.contains('code=') ||
        url.contains('access_token=') ||
        url.contains('oauth_callback')) {
      return true;
    }

    // Check for custom app schemes (e.g., app://, fbconnect://) which cannot be loaded as http pages
    final uri = Uri.tryParse(url);
    if (uri != null && uri.hasScheme && uri.scheme != 'http' && uri.scheme != 'https') {
      return true;
    }

    return false;
  }

  void _checkCallback(String url) {
    if (_callbackHandled) return;
    _callbackHandled = true;

    Get.snackbar(
      'OAuth Connected 🚀',
      'Facebook OAuth callback received successfully.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF10B981),
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );

    // Automatically close WebView screen and return back to integrations screen
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    });
  }

  String _getHostName(String urlStr) {
    try {
      final uri = Uri.parse(urlStr);
      return uri.host.isNotEmpty ? uri.host : urlStr;
    } catch (_) {
      return urlStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final titleText = widget.title ?? 'Facebook (Meta) Ads';
    final hostText = _getHostName(_currentUrl);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        try {
          if (await _webViewController.canGoBack()) {
            await _webViewController.goBack();
            return;
          }
        } catch (_) {}
        if (mounted) {
          Get.back();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded, color: Color(0xFF0F172A), size: 22),
            onPressed: () => Navigator.of(context).pop(),
          ),
          titleSpacing: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.facebook, color: Color(0xFF1877F2), size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: AppText(
                      titleText,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(Icons.lock_rounded, size: 11, color: Color(0xFF10B981)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: AppText(
                      hostText,
                      fontSize: 11,
                      color: AppColors.textColorSecondary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Color(0xFF475569), size: 20),
              tooltip: 'Reload',
              onPressed: () {
                setState(() {
                  _hasError = false;
                  _isLoading = true;
                });
                _webViewController.reload();
              },
            ),
            IconButton(
              icon: const Icon(Iconsax.export_3, color: Color(0xFF475569), size: 18),
              tooltip: 'Open in Browser',
              onPressed: () async {
                final uri = Uri.tryParse(_currentUrl);
                if (uri != null) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
            ),
            const SizedBox(width: 4),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(3.0),
            child: _isLoading && _progress < 1.0
                ? LinearProgressIndicator(
                    value: _progress > 0 ? _progress : null,
                    minHeight: 3,
                    color: const Color(0xFF1877F2),
                    backgroundColor: const Color(0xFFE2E8F0),
                  )
                : const SizedBox(height: 3),
          ),
        ),
        body: _hasError ? _buildErrorView() : _buildWebView(),
      ),
    );
  }

  Widget _buildWebView() {
    return Stack(
      children: [
        WebViewWidget(controller: _webViewController),
        if (_isLoading && _progress < 0.2)
          Container(
            color: Colors.white,
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Color(0xFF1877F2),
                    ),
                  ),
                  SizedBox(height: 14),
                  AppText(
                    'Opening Facebook Authorization...',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFCA5A5)),
              ),
              child: const Icon(Icons.error_outline_rounded, size: 28, color: Color(0xFFEF4444)),
            ),
            const SizedBox(height: 16),
            const AppText(
              'Unable to Load Page',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
            const SizedBox(height: 6),
            AppText(
              _errorMessage.isNotEmpty ? _errorMessage : 'A network error occurred while loading the page.',
              fontSize: 12,
              color: AppColors.textColorSecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _hasError = false;
                      _isLoading = true;
                    });
                    _webViewController.reload();
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Try Again'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1877F2),
                    side: const BorderSide(color: Color(0xFF1877F2)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () async {
                    final uri = Uri.tryParse(_currentUrl);
                    if (uri != null) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                  icon: const Icon(Iconsax.export_3, size: 14, color: Colors.white),
                  label: const Text('Open in Browser'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1877F2),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
