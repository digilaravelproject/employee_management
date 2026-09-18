import 'package:attendence_tracking_app/routes/route_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';

import 'core/bindings/initial_bindings.dart';
import 'core/constants/app_constants.dart';
import 'core/services/storage/shared_prefs.dart';
import 'core/theme/light_theme.dart';
import 'core/utils/custom_snackbar.dart';
import 'init_app.dart';

void main() async {
  await initApp();
  final bool isLoggedIn = SharedPrefs.getBool(AppConstants.isLoggedIn) ?? false;
  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({Key? key, required this.isLoggedIn}) : super(key: key);

  @override
  Widget build(BuildContext context) {
   // final localizationController = Get.find<LocalizationController>();
   // final Map<String, Map<String, String>> languages = Get.find(tag: 'languages');

    return GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: CustomSnackbar.messengerKey,
      initialBinding: InitialBindings(),
     // translations: Messages(languages: languages),
      //locale: localizationController.locale,
     // fallbackLocale: const Locale('en', 'US'),
      theme: lightTheme,
      themeMode: ThemeMode.light,
      initialRoute: isLoggedIn ? RouteHelper.getDashboardRoute() : RouteHelper.getIntroRoute(),
      getPages: RouteHelper.routes,
      defaultTransition: Transition.fadeIn,
    );
  }
}
