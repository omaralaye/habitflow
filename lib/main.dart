import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'utils/constants.dart';
import 'utils/env_validator.dart';
import 'screens/onboarding_screen.dart';
import 'screens/add_habit_screen.dart';
import 'widgets/main_navigation.dart';
import 'services/database_service.dart';
import 'services/theme_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Validate environment variables before initialization
  EnvValidator.validate();

  await Supabase.initialize(
    url: SupabaseConstants.SUPABASE_URL,
    anonKey: SupabaseConstants.SUPABASE_ANON_KEY,
  );

  await NotificationService().init();

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
          home: const AuthWrapper(),
        );
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = snapshot.data?.session;
        if (session != null) {
          return FutureBuilder<bool>(
            future: DatabaseService().hasHabits(),
            builder: (context, habitSnapshot) {
              if (habitSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              if (habitSnapshot.data == true) {
                return const MainNavigation();
              } else {
                return const AddHabitScreen(isFirstHabit: true);
              }
            },
          );
        }
        return const OnboardingScreen();
      },
    );
  }
}
