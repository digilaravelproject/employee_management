import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:iconsax/iconsax.dart';
import '../theme/app_colors.dart';

/// A universal, beautiful Avatar widget that displays employee/user profile pictures,
/// handling loading and automatically displaying a styled placeholder with initials
/// or a user icon whenever the image fails to load, is empty, or is null.
class AppAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double radius;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Widget? fallback;
  final BoxBorder? border;

  const AppAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.radius = 20,
    this.backgroundColor,
    this.foregroundColor,
    this.fallback,
    this.border,
  });

  String _getInitial() {
    if (name != null && name!.trim().isNotEmpty) {
      final trimmed = name!.trim();
      return trimmed[0].toUpperCase();
    }
    return '';
  }

  Widget _buildPlaceholder(BuildContext context) {
    final initial = _getInitial();
    final Color bgColor = backgroundColor ?? AppColors.primaryLight;
    final Color fgColor = foregroundColor ?? AppColors.primaryColor;

    Widget content;
    if (fallback != null) {
      content = fallback!;
    } else if (initial.isNotEmpty) {
      content = Text(
        initial,
        style: TextStyle(
          fontSize: (radius * 0.85).clamp(9.0, 32.0),
          fontWeight: FontWeight.bold,
          color: fgColor,
        ),
      );
    } else {
      content = Icon(
        Iconsax.user,
        size: (radius * 1.0).clamp(10.0, 36.0),
        color: fgColor,
      );
    }

    final avatar = CircleAvatar(
      radius: radius,
      backgroundColor: bgColor,
      child: content,
    );

    if (border != null) {
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: border,
        ),
        child: avatar,
      );
    }

    return avatar;
  }

  @override
  Widget build(BuildContext context) {
    final String? url = imageUrl?.trim();
    if (url == null || url.isEmpty || (!url.startsWith('http://') && !url.startsWith('https://'))) {
      return _buildPlaceholder(context);
    }

    final widget = CachedNetworkImage(
      imageUrl: url,
      imageBuilder: (context, imageProvider) {
        final avatar = CircleAvatar(
          radius: radius,
          backgroundColor: backgroundColor ?? AppColors.slate200,
          backgroundImage: imageProvider,
        );
        if (border != null) {
          return Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: border,
            ),
            child: avatar,
          );
        }
        return avatar;
      },
      placeholder: (context, url) => _buildPlaceholder(context),
      errorWidget: (context, url, error) => _buildPlaceholder(context),
    );

    return widget;
  }
}
