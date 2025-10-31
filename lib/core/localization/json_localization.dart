import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';

class JsonLocalization {
  JsonLocalization._();
  static final JsonLocalization instance = JsonLocalization._();

  final ValueNotifier<int> reloadTick = ValueNotifier<int>(0);
  Map<String, String> _strings = <String, String>{};

  String t(String key) => _strings[key] ?? key;

  Future<void> load(Locale locale) async {
    Map<String, String> loaded = <String, String>{};
    final String lang = locale.languageCode;
    final String? country = locale.countryCode;

    Future<Map<String, String>?> tryLoad(String path) async {
      try {
        final String data = await rootBundle.loadString(path);
        final Map<String, dynamic> jsonMap = json.decode(data) as Map<String, dynamic>;
        return jsonMap.map((String k, dynamic v) => MapEntry<String, String>(k, v.toString()));
      } catch (_) {
        return null;
      }
    }

    final List<String> candidates = <String>[
      if (country != null && country.isNotEmpty) 'assets/locales/${lang}_${country}.json',
      'assets/locales/${lang}.json',
      'assets/locales/en_US.json',
    ];

    for (final String path in candidates) {
      final Map<String, String>? m = await tryLoad(path);
      if (m != null) {
        loaded = m;
        break;
      }
    }

    _strings = loaded;
    reloadTick.value++;
  }
}


