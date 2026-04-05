import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../screens/add_habit_screen.dart';
import '../widgets/main_navigation.dart';

class NavigationHelper {
  static Future<void> navigateAfterAuth(BuildContext context) async {
    final hasHabits = await DatabaseService().hasHabits();

    if (!context.mounted) return;

    if (hasHabits) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigation()),
        (route) => false,
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const AddHabitScreen(isFirstHabit: true),
        ),
        (route) => false,
      );
    }
  }
}
