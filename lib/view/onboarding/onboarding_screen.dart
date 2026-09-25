import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../theme/app_theme.dart';
import '../auth/login_screen.dart';

class _OnboardData {
  final String title;
  final String subtitle;
  final IconData icon;
  _OnboardData(this.title, this.subtitle, this.icon);
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardData> _pages = [
    _OnboardData(
      'Just Do It',
      'Discover the latest Nike drops before anyone else.',
      Icons.bolt_rounded,
    ),
    _OnboardData(
      'Your Style, Your Rules',
      'Curate a collection that matches your grind.',
      Icons.style_rounded,
    ),
    _OnboardData(
      'Fast & Secure Checkout',
      'Get your next pair delivered in a few taps.',
      Icons.local_shipping_rounded,
    ),
  ];

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _goToLogin();
    }
  }

  void _goToLogin() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, animation, _) =>
            FadeTransition(opacity: animation, child: const LoginScreen()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton(
                  onPressed: _goToLogin,
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      color: AppColors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                              height: 220,
                              width: 220,
                              decoration: BoxDecoration(
                                color: AppColors.lightGrey,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                page.icon,
                                size: 90,
                                color: AppColors.black,
                              ),
                            )
                            .animate(key: ValueKey(index))
                            .scale(
                              begin: const Offset(0.6, 0.6),
                              duration: 500.ms,
                              curve: Curves.easeOutBack,
                            )
                            .fadeIn(duration: 400.ms),
                        const SizedBox(height: 40),
                        Text(
                              page.title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                              ),
                            )
                            .animate(key: ValueKey('t$index'))
                            .fadeIn(delay: 150.ms)
                            .slideY(begin: 0.3, end: 0),
                        const SizedBox(height: 14),
                        Text(
                              page.subtitle,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 15,
                                color: AppColors.grey,
                                height: 1.5,
                              ),
                            )
                            .animate(key: ValueKey('s$index'))
                            .fadeIn(delay: 250.ms)
                            .slideY(begin: 0.3, end: 0),
                      ],
                    ),
                  );
                },
              ),
            ),
            SmoothPageIndicator(
              controller: _pageController,
              count: _pages.length,
              effect: const ExpandingDotsEffect(
                activeDotColor: AppColors.black,
                dotColor: AppColors.lightGrey,
                dotHeight: 8,
                dotWidth: 8,
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _next,
                  child: Text(
                    _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
