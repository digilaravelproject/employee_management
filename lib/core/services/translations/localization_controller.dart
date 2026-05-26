import 'dart:ui';
import 'package:get/get.dart';
import '../../constants/app_constants.dart';
import '../storage/shared_prefs.dart';

class LocalizationController extends GetxController {
  final _locale = const Locale('en', 'US').obs;

  Locale get locale => _locale.value;

  @override
  void onInit() {
    super.onInit();
    _loadCurrentLanguage();
  }

  void _loadCurrentLanguage() {
    String? languageCode = SharedPrefs.getString(AppConstants.language);
    if (languageCode != null) {
      final parts = languageCode.split('_');
      if (parts.length == 2) {
        _locale.value = Locale(parts[0], parts[1]);
      }
    }
  }

  Future<void> setLanguage(String languageCode) async {
    final parts = languageCode.split('_');
    if (parts.length == 2) {
      _locale.value = Locale(parts[0], parts[1]);
      Get.updateLocale(_locale.value);
      await SharedPrefs.setString(AppConstants.language, languageCode);
    }
  }

  String get currentLanguageCode => '${_locale.value.languageCode}_${_locale.value.countryCode}';
}
