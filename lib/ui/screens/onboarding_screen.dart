import 'package:flutter/material.dart';
import 'package:g8night/core/preferences/app_preferences.dart';
import 'package:g8night/ui/widgets/dots_indicator.dart';
import 'package:g8night/ui/widgets/gradient_background.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  static const String routeName = '/onboarding';

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

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

  Future<void> _onNext() async {
    if (_currentIndex < _slides.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      await AppPreferences.setBool(PreferenceKeys.isOnboarded, true);
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/loginType');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
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
                  onPageChanged: (int idx) => setState(() => _currentIndex = idx),
                  itemCount: _slides.length,
                  itemBuilder: (BuildContext context, int index) {
                    final _SlideData slide = _slides[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          const Icon(Icons.local_bar, size: 120, color: Colors.white),
                          const SizedBox(height: 24),
                          Text(slide.title, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          Text(
                            slide.subtitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white70, fontSize: 16),
                          ),
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
                    DotsIndicator(dotsCount: _slides.length, position: _currentIndex),
                    ElevatedButton(
                      onPressed: _onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.deepPurple,
                      ),
                      child: Text(_currentIndex == _slides.length - 1 ? 'Finish' : 'Next'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlideData {
  final String title;
  final String subtitle;
  const _SlideData({required this.title, required this.subtitle});
}


