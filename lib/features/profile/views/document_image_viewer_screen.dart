import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../models/user_document_model.dart';

class DocumentImageViewerScreen extends StatefulWidget {
  final UserDocumentItem document;

  const DocumentImageViewerScreen({super.key, required this.document});

  @override
  State<DocumentImageViewerScreen> createState() =>
      _DocumentImageViewerScreenState();
}

class _DocumentImageViewerScreenState extends State<DocumentImageViewerScreen>
    with SingleTickerProviderStateMixin {
  late final TransformationController _transformationController;
  late AnimationController _animationController;
  Animation<Matrix4>? _animation;

  double _currentScale = 1.0;
  bool _showOverlays = true;

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
    if ((scale - _currentScale).abs() > 0.05) {
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
      // Zoom in to 2.5x around tap position
      final position = details.localPosition;
      final target = Matrix4.diagonal3Values(2.5, 2.5, 1.0)
        ..setTranslationRaw(-position.dx * 1.5, -position.dy * 1.5, 0.0);
      _animateToMatrix(target);
    }
  }

  @override
  Widget build(BuildContext context) {
    final doc = widget.document;
    final isVerified = doc.status.toLowerCase() == 'verified';

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19),
      body: Stack(
        children: [
          // ── Zoomable Image Viewer Area ──
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
                  child: _buildDocumentImage(doc),
                ),
              ),
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

                  // Title and Size
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppText(
                          doc.name,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isVerified
                                    ? Colors.green.withValues(alpha: 0.25)
                                    : Colors.blue.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: AppText(
                                doc.status,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isVerified
                                    ? const Color(0xFF4ADE80)
                                    : const Color(0xFF60A5FA),
                              ),
                            ),
                            const SizedBox(width: 8),
                            AppText(
                              '${doc.type} • ${doc.size}',
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Reset Zoom Button
                  Container(
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
              ),
            ),
          ),

          // ── Bottom Floating Zoom Controls ──
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            bottom: _showOverlays ? MediaQuery.of(context).padding.bottom + 16 : -100,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                  // Zoom Out Button
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline_rounded,
                        color: Colors.white, size: 24),
                    onPressed: _zoomOut,
                    tooltip: 'Zoom Out',
                  ),

                  // Scale Percentage
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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

                  // Zoom In Button
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline_rounded,
                        color: Colors.white, size: 24),
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
                        'Pinch / Double-tap',
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

  Widget _buildDocumentImage(UserDocumentItem doc) {
    if (doc.filePath != null && File(doc.filePath!).existsSync()) {
      return Image.file(
        File(doc.filePath!),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => _buildFallbackCard(doc),
      );
    } else if (doc.assetPath != null && doc.assetPath!.isNotEmpty) {
      return Image.asset(
        doc.assetPath!,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => _buildFallbackCard(doc),
      );
    } else {
      return _buildFallbackCard(doc);
    }
  }

  Widget _buildFallbackCard(UserDocumentItem doc) {
    return Container(
      width: 320,
      height: 440,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 30,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Iconsax.document_text,
              size: 64,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(height: 20),
          AppText(
            doc.name,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          AppText(
            '${doc.type} Document • ${doc.size}',
            fontSize: 14,
            color: AppColors.textColorSecondary,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: doc.status == 'Verified'
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: AppText(
              doc.status,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: doc.status == 'Verified' ? Colors.green : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }
}
