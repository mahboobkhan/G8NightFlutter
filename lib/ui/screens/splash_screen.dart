import 'dart:async';

import 'package:flutter/material.dart';
import 'package:g8night/core/preferences/app_preferences.dart' as core;
import 'package:g8night/ui/widgets/gradient_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const String routeName = '/splash';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await core.AppPreferences.ensureInitialized();
    final bool isOnboarded = core.AppPreferences.getBool(core.PreferenceKeys.isOnboarded, defaultValue: false);
    unawaited(Future<void>.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(isOnboarded ? '/loginType' : '/onboarding');
    }));
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const <Widget>[
              Icon(Icons.local_bar, color: Colors.white, size: 80),
              SizedBox(height: 16),
              Text('Pub Bar', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}


