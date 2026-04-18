import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sanctuary/screens/onboarding_screen.dart';
import 'package:sanctuary/screens/signup_screen.dart';
import 'package:sanctuary/screens/login_screen.dart';

void main() {
  testWidgets('OnboardingScreen has 3 pages and navigates to SignupScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: OnboardingScreen()));

    // Page 1
    expect(find.text('Grow Habits with\nYour Animal Friends'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
    expect(find.text('🌱'), findsOneWidget);

    // Tap Next
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    // Page 2
    expect(find.text('Track Progress &\nEvolve Mascots'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
    expect(find.text('🦊'), findsOneWidget);

    // Tap Next
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    // Page 3
    expect(find.text('Relaxing Sounds\n& Deep Focus'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
    expect(find.text('🎵'), findsOneWidget);

    // Tap Get Started
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    // Should be on SignupScreen
    expect(find.byType(SignupScreen), findsOneWidget);
  });

  testWidgets('OnboardingScreen Log In link navigates to LoginScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: OnboardingScreen()));

    await tester.tap(find.text('Log In'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
