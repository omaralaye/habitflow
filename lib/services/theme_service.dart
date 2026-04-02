import 'package:flutter/material.dart';

class ThemeService {
  // Singleton pattern
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();

  final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

  ThemeMode get themeMode => themeModeNotifier.value;

  bool get isDarkMode => themeModeNotifier.value == ThemeMode.dark;

  void toggleTheme(bool isDark) {
    themeModeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
  }
}
