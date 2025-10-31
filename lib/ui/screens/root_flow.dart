import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:g8night/core/preferences/app_preferences.dart';
import 'package:g8night/ui/screens/login_type_screen.dart';
import 'package:g8night/ui/widgets/dots_indicator.dart';
import 'package:g8night/ui/widgets/gradient_background.dart';

class RootFlow extends StatefulWidget {
  const RootFlow({super.key});

  @override
  State<RootFlow> createState() => _RootFlowState();
}

enum FlowPage { splash, onboarding, loginType, login, home }

class _RootFlowState extends State<RootFlow> {
  FlowPage _page = FlowPage.splash;
  FlowPage _previousPage = FlowPage.splash;
  LoginType _loginType = LoginType.user;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    await AppPreferences.ensureInitialized();
    final bool isOnboarded = AppPreferences.getBool(PreferenceKeys.isOnboarded, defaultValue: false);
    unawaited(Future<void>.delayed(const Duration(milliseconds: 900)).then((_) {
      if (!mounted) return;
      _setPage(isOnboarded ? FlowPage.loginType : FlowPage.onboarding);
    }));
  }

  void _setPage(FlowPage next) {
    setState(() {
      _previousPage = _page;
      _page = next;
    });
  }

  void _toHome() {
    _setPage(FlowPage.home);
  }

  void _toLoginType() {
    _setPage(FlowPage.loginType);
  }

  void _toLogin(LoginType type) {
    setState(() {
      _previousPage = _page;
      _loginType = type;
      _page = FlowPage.login;
    });
  }

  Future<bool> _onWillPop() async {
    switch (_page) {
      case FlowPage.home:
        return true; // allow app to close
      case FlowPage.login:
        _toLoginType();
        return false;
      case FlowPage.loginType:
        setState(() => _page = FlowPage.onboarding);
        return false;
      case FlowPage.onboarding:
      case FlowPage.splash:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool noAnimation = _previousPage == FlowPage.loginType && _page == FlowPage.login;
    return GradientBackground(
      child: WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: noAnimation
                ? _buildPage()
                : AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      final Animation<Offset> offset = Tween<Offset>(begin: const Offset(0.06, 0.0), end: Offset.zero)
                          .chain(CurveTween(curve: Curves.easeOut))
                          .animate(animation);
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(position: offset, child: child),
                      );
                    },
                    child: _buildPage(),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildPage() {
    switch (_page) {
      case FlowPage.splash:
        return const _SplashFragment(key: ValueKey('splash'));
      case FlowPage.onboarding:
        return _OnboardingFragment(key: const ValueKey('onboarding'), onFinish: () async {
          await AppPreferences.setBool(PreferenceKeys.isOnboarded, true);
          _toLoginType();
        });
      case FlowPage.loginType:
        return _LoginTypeFragment(key: const ValueKey('loginType'), onSelect: _toLogin);
      case FlowPage.login:
        return _LoginFragment(key: const ValueKey('login'), type: _loginType, onLoggedIn: _toHome);
      case FlowPage.home:
        return const _HomeFragment(key: ValueKey('home'));
    }
  }
}

// Fragments (no Navigator usage)

class _SplashFragment extends StatelessWidget {
  const _SplashFragment({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const <Widget>[
          Icon(Icons.local_bar, color: Colors.white, size: 80),
          SizedBox(height: 16),
          Text('Pub Bar', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _OnboardingFragment extends StatefulWidget {
  final Future<void> Function() onFinish;
  const _OnboardingFragment({super.key, required this.onFinish});

  @override
  State<_OnboardingFragment> createState() => _OnboardingFragmentState();
}

class _OnboardingFragmentState extends State<_OnboardingFragment> {
  final PageController _pageController = PageController();
  int _index = 0;
  final List<_SlideData> _slides = const <_SlideData>[
    _SlideData(title: 'Discover Pubs', subtitle: 'Find the best pubs nearby'),
    _SlideData(title: 'Exclusive Offers', subtitle: 'Unlock member-only deals'),
    _SlideData(title: 'Join the Community', subtitle: 'Rate and share experiences'),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    if (_index < _slides.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 280), curve: Curves.easeOut);
    } else {
      await widget.onFinish();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 24.0),
          child: Text(
            'Welcome to Pub Bar',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (int i) => setState(() => _index = i),
            itemCount: _slides.length,
            itemBuilder: (BuildContext context, int i) {
              final _SlideData slide = _slides[i];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Icon(Icons.local_bar, size: 120, color: Colors.white),
                    const SizedBox(height: 24),
                    Text(slide.title, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Text(slide.subtitle, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 16)),
                  ],
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              DotsIndicator(dotsCount: _slides.length, position: _index),
              ElevatedButton(
                onPressed: _next,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.deepPurple),
                child: Text(_index == _slides.length - 1 ? 'Finish' : 'Next'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LoginTypeFragment extends StatelessWidget {
  final void Function(LoginType type) onSelect;
  const _LoginTypeFragment({super.key, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => onSelect(LoginType.user),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16.0)),
              child: const Text('User Login / Register'),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => onSelect(LoginType.admin),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16.0)),
              child: const Text('Pub Admin Login / Register'),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginFragment extends StatefulWidget {
  final LoginType type;
  final VoidCallback onLoggedIn;
  const _LoginFragment({super.key, required this.type, required this.onLoggedIn});

  @override
  State<_LoginFragment> createState() => _LoginFragmentState();
}

class _LoginFragmentState extends State<_LoginFragment> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onCreateAccountTapped() {
    Fluttertoast.showToast(msg: 'Create New Account tapped');
  }

  void _onForgotPasswordTapped() {
    Fluttertoast.showToast(msg: 'Forget Password tapped');
  }

  void _onLoginTapped() {
    if (_formKey.currentState?.validate() ?? false) {
      Fluttertoast.showToast(msg: 'Logging in as ${widget.type.name}');
      widget.onLoggedIn();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(height: 24),
            Text(widget.type == LoginType.user ? 'User Login' : 'Pub Admin Login',
                textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 24),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email', filled: true),
              validator: (String? value) {
                if (value == null || value.isEmpty) return 'Enter email';
                if (!value.contains('@')) return 'Enter valid email';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscure,
              decoration: InputDecoration(
                labelText: 'Password',
                filled: true,
                suffixIcon: IconButton(
                  icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              validator: (String? value) {
                if (value == null || value.isEmpty) return 'Enter password';
                if (value.length < 6) return 'Min 6 characters';
                return null;
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _onLoginTapped,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16.0)),
                child: const Text('Login'),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                GestureDetector(
                  onTap: _onCreateAccountTapped,
                  child: const Text('Create New Account',
                      style: TextStyle(decoration: TextDecoration.underline, color: Colors.white)),
                ),
                GestureDetector(
                  onTap: _onForgotPasswordTapped,
                  child: const Text('Forget Password',
                      style: TextStyle(decoration: TextDecoration.underline, color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeFragment extends StatelessWidget {
  const _HomeFragment({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Home'),
          centerTitle: true,
        ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const <Widget>[
                Icon(Icons.home, color: Colors.white, size: 72),
                SizedBox(height: 12),
                Text('Welcome to Pub Bar', style: TextStyle(color: Colors.white, fontSize: 20)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SlideData {
  final String title;
  final String subtitle;
  const _SlideData({required this.title, required this.subtitle});
}


