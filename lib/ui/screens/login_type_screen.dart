import 'package:flutter/material.dart';
import 'package:g8night/ui/widgets/gradient_background.dart';

class LoginTypeScreen extends StatelessWidget {
  const LoginTypeScreen({super.key});

  static const String routeName = '/loginType';

  void _goToLogin(BuildContext context, LoginType type) {
    Navigator.of(context).pushNamed('/login', arguments: type);
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Choose Login'),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _goToLogin(context, LoginType.user),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16.0)),
                  child: const Text('User Login / Register'),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _goToLogin(context, LoginType.admin),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16.0)),
                  child: const Text('Pub Admin Login / Register'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum LoginType { user, admin }


