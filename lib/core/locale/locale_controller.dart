import 'package:flutter/material.dart';
import 'package:g8night/core/preferences/app_preferences.dart';
import 'package:g8night/core/localization/json_localization.dart';

class LocalePreferenceKeys {
  static const String localeCode = 'locale_code';
}

class LocaleController {
  LocaleController._();
  static final LocaleController instance = LocaleController._();

  final ValueNotifier<Locale?> locale = ValueNotifier<Locale?>(null);

  Future<void> loadSavedLocale() async {
    await AppPreferences.ensureInitialized();
    final String code = AppPreferences.getString(LocalePreferenceKeys.localeCode, defaultValue: '');
    if (code.isNotEmpty) {
      locale.value = _localeFromCode(code);
    }
  }

  Future<void> setLocale(Locale value) async {
    locale.value = value;
    final String code = _codeFromLocale(value);
    await AppPreferences.setString(LocalePreferenceKeys.localeCode, code);
    await JsonLocalization.instance.load(value);
  }

  static Locale _localeFromCode(String code) {
    if (code.contains('_')) {
      final List<String> parts = code.split('_');
      return Locale(parts[0], parts[1]);
    }
    return Locale(code);
  }

  static String _codeFromLocale(Locale locale) {
    final String lang = locale.languageCode;
    final String? country = locale.countryCode;
    return country == null || country.isEmpty ? lang : '${lang}_${country}';
  }
}


