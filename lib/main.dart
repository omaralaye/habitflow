import 'package:flutter/material.dart';
import 'utils/constants.dart';
import 'screens/onboarding_screen.dart';
import 'services/theme_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService().themeModeNotifier,
      builder: (context, currentThemeMode, child) {
        return MaterialApp(
          title: 'Sanctuary',
          debugShowCheckedModeBanner: false,
          theme: AppStyles.lightTheme,
          darkTheme: AppStyles.darkTheme,
          themeMode: currentThemeMode,
          home: const OnboardingScreen(),
        );
      },
    );
  }
}
