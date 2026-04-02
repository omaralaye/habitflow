import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../services/theme_service.dart';
import '../widgets/main_navigation.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      'title': 'Grow Habits with\nYour Animal Friends',
      'description': 'Build lasting routines and watch your personal sanctuary flourish as you progress.',
      'icon': '🌱',
      'color': 'bgLavender',
    },
    {
      'title': 'Track Progress &\nEvolve Mascots',
      'description': 'Every habit you complete helps your animal companions grow and evolve to new levels.',
      'icon': '🦊',
      'color': 'bgMint',
    },
    {
      'title': 'Relaxing Sounds\n& Deep Focus',
      'description': 'Listen to soothing ambient music while you focus on your daily tasks and reflections.',
      'icon': '🎵',
      'color': 'bgSky',
    },
  ];

  Color _getBackgroundColor(String colorName) {
    final isDark = ThemeService().isDarkMode;
    if (isDark) return AppColors.darkSurface;

    switch (colorName) {
      case 'bgLavender':
        return AppColors.bgLavender;
      case 'bgMint':
        return AppColors.bgMint;
      case 'bgSky':
        return AppColors.bgSky;
      default:
        return AppColors.bgLavender;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = ThemeService().isDarkMode;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              color: _getBackgroundColor(_onboardingData[index]['color']!),
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: Center(
                              child: Text(
                                _onboardingData[index]['icon']!,
                                style: const TextStyle(fontSize: 70),
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                          Text(
                            _onboardingData[index]['title']!,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.displayLarge?.copyWith(
                              height: 1.2,
                              fontSize: 28,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _onboardingData[index]['description']!,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: isDark ? AppColors.darkTextSecondary : AppColors.textGrey,
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _onboardingData.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 8),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index ? AppColors.primary : AppColors.primaryLight.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage < _onboardingData.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const MainNavigation()),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _currentPage == _onboardingData.length - 1 ? 'Get Started' : 'Next',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.textGrey),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const MainNavigation()),
                          );
                        },
                        child: const Text(
                          'Log In',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
