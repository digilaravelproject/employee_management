import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:iconsax/iconsax.dart';
import '../theme/app_colors.dart';

/// A universal, robust Network Image widget that always renders a stylish
/// placeholder during loading and when the image fails to load or is empty/null.
class AppNetworkImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final IconData fallbackIcon;
  final Color? backgroundColor;
  final Color? iconColor;
  final BoxBorder? border;

  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.fallbackIcon = Iconsax.image,
    this.backgroundColor,
    this.iconColor,
    this.border,
  });

  Widget _buildPlaceholder() {
    final double iconSize = (height != null && width != null)
        ? (height! < width! ? height! * 0.4 : width! * 0.4).clamp(16.0, 48.0)
        : 24.0;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.slate100,
        borderRadius: borderRadius,
        border: border,
      ),
      alignment: Alignment.center,
      child: errorWidget ??
          Icon(
            fallbackIcon,
            size: iconSize,
            color: iconColor ?? AppColors.textColorHint,
          ),
    );
  }

  Widget _buildLoading() {
    if (placeholder != null) return placeholder!;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.slate100,
        borderRadius: borderRadius,
        border: border,
      ),
      alignment: Alignment.center,
      child: SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.primaryColor.withValues(alpha: 0.6),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String? url = imageUrl?.trim();
    if (url == null || url.isEmpty || (!url.startsWith('http://') && !url.startsWith('https://'))) {
      return _buildPlaceholder();
    }

    Widget image = CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => _buildLoading(),
      errorWidget: (context, url, error) => _buildPlaceholder(),
    );

    if (borderRadius != null) {
      image = ClipRRect(
        borderRadius: borderRadius!,
        child: image,
      );
    }

    if (border != null) {
      image = Container(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          border: border,
        ),
        child: image,
      );
    }

    return image;
  }
}
