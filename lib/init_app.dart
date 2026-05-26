import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/services/DynamicAppIcon/dynamic_app_icon_manager.dart';
import 'core/services/config/env_config.dart';
import 'core/theme/theme_controller.dart';
import 'core/services/storage/shared_prefs.dart';
import 'core/services/translations/localization_controller.dart';
import 'core/services/translations/translation_loader.dart';
import 'core/constants/app_constants.dart';

Future<void> initApp() async {
  // Set environment configuration
  WidgetsFlutterBinding.ensureInitialized();
  await EnvConfig.load();
  // EnvConfig.setEnvironment(Environment.development); // Change as needed


  // Initialize dynamic app icon manager
  // await DynamicAppIconManager.init();


  // Initialize shared preferences
  await SharedPrefs.init();

  // Register controllers
  // Get.lazyPut(() => ThemeController());
  Get.put(ThemeController()); // instead of Get.lazyPut

  // Load translations
//  Map<String, Map<String, String>> languages = {};
  // for (var language in AppConstants.languages) {
  //   languages[language.code] = await TranslationLoader.load(language.code);
  // }
 // Get.put(languages, tag: 'languages');

  // Initialize localization
 // Get.put(LocalizationController());

  // Initialize theme
  // await Get.find<ThemeController>().initTheme();


}
