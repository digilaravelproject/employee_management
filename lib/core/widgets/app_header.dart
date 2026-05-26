import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../theme/app_colors.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget? rightWidget;
  final VoidCallback? onBack;
  final bool showBackButton;
  final PreferredSizeWidget? bottom;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const AppHeader({
    Key? key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.rightWidget,
    this.onBack,
    this.showBackButton = true,
    this.bottom,
    this.backgroundColor,
    this.foregroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool showLead = showBackButton && Navigator.of(context).canPop();

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: backgroundColor ?? AppColors.white,
      elevation: 0,
      centerTitle: false,
      toolbarHeight: preferredSize.height,
      leadingWidth: showLead ? 40 : 16,
      leading: showLead
          ? IconButton(
              onPressed: onBack ?? () => Navigator.of(context).pop(),
              icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: foregroundColor ?? AppColors.textColorPrimary),
              splashRadius: 24,
            )
          : const SizedBox(),
      titleSpacing: 0,
      title: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: foregroundColor ?? AppColors.textColorPrimary,
              letterSpacing: -0.5,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 1),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 11,
                color: foregroundColor?.withOpacity(0.7) ?? AppColors.textColorSecondary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ],
      ),
      actions: (trailing != null || rightWidget != null) ? [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: trailing ?? rightWidget!,
        )
      ] : null,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize {
    return Size.fromHeight(
      56.0 + (subtitle != null ? 14.0 : 0) + (bottom != null ? bottom!.preferredSize.height : 0)
    );
  }
}
