import 'package:shared_preferences/shared_preferences.dart';

class PreferenceKeys {
  static const String isOnboarded = 'is_onboarded';
}

class AppPreferences {
  AppPreferences._();

  static SharedPreferences? _prefs;

  static Future<void> ensureInitialized() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static Future<bool> setBool(String key, bool value) async {
    await ensureInitialized();
    return _prefs!.setBool(key, value);
  }

  static Future<bool> setInt(String key, int value) async {
    await ensureInitialized();
    return _prefs!.setInt(key, value);
  }

  static Future<bool> setString(String key, String value) async {
    await ensureInitialized();
    return _prefs!.setString(key, value);
  }

  static bool getBool(String key, {bool defaultValue = false}) {
    final prefs = _prefs;
    if (prefs == null) return defaultValue;
    return prefs.getBool(key) ?? defaultValue;
  }

  static int getInt(String key, {int defaultValue = 0}) {
    final prefs = _prefs;
    if (prefs == null) return defaultValue;
    return prefs.getInt(key) ?? defaultValue;
  }

  static String getString(String key, {String defaultValue = ''}) {
    final prefs = _prefs;
    if (prefs == null) return defaultValue;
    return prefs.getString(key) ?? defaultValue;
  }

  static Future<bool> remove(String key) async {
    await ensureInitialized();
    return _prefs!.remove(key);
  }

  static Future<bool> clear() async {
    await ensureInitialized();
    return _prefs!.clear();
  }
}


