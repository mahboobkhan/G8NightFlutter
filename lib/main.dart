import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:g8night/core/locale/locale_controller.dart';
import 'package:g8night/core/localization/json_localization.dart';
import 'package:g8night/core/localization/l.dart';
import 'package:g8night/ui/screens/root_flow.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocaleController.instance.loadSavedLocale();
  final Locale initial = LocaleController.instance.locale.value ?? const Locale('en', 'US');
  await JsonLocalization.instance.load(initial);
  runApp(const PubBarApp());
}

class PubBarApp extends StatelessWidget {
  const PubBarApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData base = ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple));
    return ValueListenableBuilder<Locale?>(
      valueListenable: LocaleController.instance.locale,
      builder: (BuildContext context, Locale? locale, Widget? child) {
        return ValueListenableBuilder<int>(
          valueListenable: JsonLocalization.instance.reloadTick,
          builder: (BuildContext context, int _, Widget? __) {
            return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: L.t('appTitle'),
      theme: base.copyWith(
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0x33FFFFFF),
          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide.none),
          labelStyle: TextStyle(color: Colors.white),
        ),
        textTheme: base.textTheme.apply(bodyColor: Colors.white, displayColor: Colors.white),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.deepPurple,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
          ),
        ),
        appBarTheme: const AppBarTheme(foregroundColor: Colors.white),
      ),
      locale: locale,
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const <Locale>[
        Locale('en', 'US'),
        Locale('en', 'GB'),
        Locale('de'),
        Locale('hi'),
        Locale('ru'),
        Locale('ar'),
      ],
      home: const RootFlow(),
            );
          },
        );
      },
    );
  }
}
