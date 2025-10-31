import 'package:flutter/material.dart';
import 'package:g8night/ui/screens/root_flow.dart';

void main() {
  runApp(const PubBarApp());
}

class PubBarApp extends StatelessWidget {
  const PubBarApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData base = ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple));
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pub Bar',
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
      home: const RootFlow(),
    );
  }
}
