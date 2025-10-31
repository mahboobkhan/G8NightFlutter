import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:g8night/core/preferences/app_preferences.dart';
import 'package:g8night/ui/screens/login_type_screen.dart';
import 'package:g8night/ui/widgets/dots_indicator.dart';
import 'package:g8night/ui/widgets/gradient_background.dart';
import 'package:g8night/core/localization/l.dart';
import 'package:g8night/core/locale/locale_controller.dart';

class RootFlow extends StatefulWidget {
  const RootFlow({super.key});

  @override
  State<RootFlow> createState() => _RootFlowState();
}

enum FlowPage { splash, language, onboarding, loginType, login, home }

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
    final String savedLocale = AppPreferences.getString(LocalePreferenceKeys.localeCode, defaultValue: '');
    unawaited(Future<void>.delayed(const Duration(milliseconds: 900)).then((_) {
      if (!mounted) return;
      if (savedLocale.isEmpty) {
        _setPage(FlowPage.language);
      } else {
        _setPage(isOnboarded ? FlowPage.loginType : FlowPage.onboarding);
      }
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
      case FlowPage.language:
        return true;
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
      case FlowPage.language:
        return _LanguageFragment(
          key: const ValueKey('language'),
          onContinue: () {
            final bool isOnboarded = AppPreferences.getBool(PreferenceKeys.isOnboarded, defaultValue: false);
            _setPage(isOnboarded ? FlowPage.loginType : FlowPage.onboarding);
          },
        );
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
    final String title = L.t('splashTitle');
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Icon(Icons.local_bar, color: Colors.white, size: 80),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _LanguageFragment extends StatefulWidget {
  final VoidCallback onContinue;
  const _LanguageFragment({super.key, required this.onContinue});

  @override
  State<_LanguageFragment> createState() => _LanguageFragmentState();
}

class _LanguageFragmentState extends State<_LanguageFragment> {
  Locale? _selected;

  List<_LangOption> _options(BuildContext context) {
    return <_LangOption>[
      _LangOption(locale: const Locale('en', 'US'), label: L.t('englishUS')),
      _LangOption(locale: const Locale('en', 'GB'), label: L.t('englishUK')),
      _LangOption(locale: const Locale('de'), label: L.t('german')),
      _LangOption(locale: const Locale('hi'), label: L.t('hindi')),
      _LangOption(locale: const Locale('ru'), label: L.t('russian')),
      _LangOption(locale: const Locale('ar'), label: L.t('arabic')),
    ];
  }

  Future<void> _apply() async {
    final Locale? choice = _selected;
    if (choice == null) return;
    await LocaleController.instance.setLocale(choice);
    widget.onContinue();
  }

  @override
  Widget build(BuildContext context) {
    final String langTitle = L.t('languageSelectTitle');
    final List<_LangOption> items = _options(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
            child: Text(langTitle, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
          ),
          SizedBox(
            height: 72,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (BuildContext context, int index) {
                final _LangOption opt = items[index];
                final bool selected = _selected == opt.locale;
                return ChoiceChip(
                  selected: selected,
                  label: Text(opt.label),
                  onSelected: (_) => setState(() => _selected = opt.locale),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemCount: items.length,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _apply,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16.0)),
              child: Text(L.t('continueBtn')),
            ),
          ),
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
  static const int _totalSlides = 3;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    if (_index < _totalSlides - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 280), curve: Curves.easeOut);
    } else {
      await widget.onFinish();
    }
  }

  @override
  Widget build(BuildContext context) {
    final String heading = L.t('onboardingWelcome');
    final List<_SlideData> slides = <_SlideData>[
      _SlideData(title: L.t('slide1Title'), subtitle: L.t('slide1Subtitle')),
      _SlideData(title: L.t('slide2Title'), subtitle: L.t('slide2Subtitle')),
      _SlideData(title: L.t('slide3Title'), subtitle: L.t('slide3Subtitle')),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Text(
            heading,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (int i) => setState(() => _index = i),
            itemCount: slides.length,
            itemBuilder: (BuildContext context, int i) {
              final _SlideData slide = slides[i];
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
              DotsIndicator(dotsCount: slides.length, position: _index),
              ElevatedButton(
                onPressed: _next,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.deepPurple),
                child: Text(_index == slides.length - 1 ? L.t('finish') : L.t('next')),
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
    final String userLabel = L.t('userLoginRegister');
    final String adminLabel = L.t('adminLoginRegister');
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
              child: Text(userLabel),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => onSelect(LoginType.admin),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16.0)),
              child: Text(adminLabel),
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
    Fluttertoast.showToast(msg: L.t('toastCreateAccount'));
  }

  void _onForgotPasswordTapped() {
    Fluttertoast.showToast(msg: L.t('toastForgotPassword'));
  }

  void _onLoginTapped() {
    if (_formKey.currentState?.validate() ?? false) {
      Fluttertoast.showToast(msg: L.t('toastLoggingIn'));
      widget.onLoggedIn();
    }
  }

  @override
  Widget build(BuildContext context) {
    final String title = widget.type == LoginType.user ? L.t('userLoginTitle') : L.t('adminLoginTitle');
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(height: 24),
            Text(title,
                textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 24),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: L.t('email'), filled: true),
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
                labelText: L.t('password'),
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
                child: Text(L.t('login')),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                GestureDetector(
                  onTap: _onCreateAccountTapped,
                  child: Text(L.t('createAccount'),
                      style: const TextStyle(decoration: TextDecoration.underline, color: Colors.white)),
                ),
                GestureDetector(
                  onTap: _onForgotPasswordTapped,
                  child: Text(L.t('forgotPassword'),
                      style: const TextStyle(decoration: TextDecoration.underline, color: Colors.white)),
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
    final String homeTitle = L.t('homeTitle');
    final String welcome = L.t('homeWelcome');
    return Column(
      children: <Widget>[
        AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(homeTitle),
          centerTitle: true,
        ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Icon(Icons.home, color: Colors.white, size: 72),
                const SizedBox(height: 12),
                Text(welcome, style: const TextStyle(color: Colors.white, fontSize: 20)),
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

class _LangOption {
  final Locale locale;
  final String label;
  const _LangOption({required this.locale, required this.label});
}


