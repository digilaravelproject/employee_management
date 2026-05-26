import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final Widget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Color? backgroundColor;
  final bool safeArea;
  final bool resizeToAvoidBottomInset;
  final bool useScaffold;
  final bool extendBody;

  const AppScaffold({
    Key? key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.drawer,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.backgroundColor,
    this.safeArea = false,
    this.resizeToAvoidBottomInset = true,
    this.useScaffold = true,
    this.extendBody = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final systemOverlay = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    );

    if (!useScaffold) {
      Widget content = body;
      if (appBar != null) {
        content = Column(
          children: [
            appBar!,
            Expanded(child: body),
          ],
        );
      }
      
      if (floatingActionButton != null) {
        content = Stack(
          children: [
            content,
            Positioned(
              right: 16,
              bottom: 16,
              child: floatingActionButton!,
            ),
          ],
        );
      }

      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: systemOverlay,
        child: Material(
          color: backgroundColor ?? AppColors.scaffoldBackgroundColor,
          child: safeArea ? SafeArea(child: content) : content,
        ),
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemOverlay,
      child: Scaffold(
        backgroundColor: backgroundColor ?? AppColors.scaffoldBackgroundColor,
        appBar: appBar != null ? (appBar is PreferredSizeWidget 
            ? (appBar as PreferredSizeWidget) 
            : PreferredSize(
                preferredSize: const Size.fromHeight(kToolbarHeight),
                child: appBar!,
              )) : null,
        body: safeArea ? SafeArea(child: body) : body,
        bottomNavigationBar: bottomNavigationBar,
        drawer: drawer,
        floatingActionButton: floatingActionButton,
        floatingActionButtonLocation: floatingActionButtonLocation,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        extendBody: extendBody,
      ),
    );
  }
}
