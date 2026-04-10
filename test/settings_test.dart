import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sanctuary/screens/settings_screen.dart';
import 'package:sanctuary/screens/onboarding_screen.dart';
import 'package:sanctuary/services/auth_service.dart';
import 'package:sanctuary/services/notification_service.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthService extends Mock implements AuthService {}
class MockNotificationService extends Mock implements NotificationService {}

void main() {
  late MockAuthService mockAuthService;
  late MockNotificationService mockNotificationService;

  setUp(() {
    mockAuthService = MockAuthService();
    AuthService.setMockInstance(mockAuthService);

    mockNotificationService = MockNotificationService();
    NotificationService.setMockInstance(mockNotificationService);

    when(() => mockAuthService.signOut()).thenAnswer((_) async {});
    when(() => mockAuthService.user).thenReturn(null);
    when(() => mockNotificationService.cancelAllNotifications()).thenAnswer((_) async {});
  });

  testWidgets('SettingsScreen shows Sign Out button and opens confirmation dialog', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));

    // Scroll to the sign out button
    await tester.dragUntilVisible(
      find.text('Sign Out'),
      find.byType(SingleChildScrollView),
      const Offset(0, -200),
    );

    expect(find.text('Sign Out'), findsOneWidget);

    // Tap the sign out button
    await tester.tap(find.text('Sign Out'));
    await tester.pumpAndSettle();

    // Check if the confirmation dialog is shown
    expect(find.text('Are you sure you want to sign out of your sanctuary?'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Sign Out'), findsNWidgets(1));
  });

  testWidgets('Confirming Sign Out calls AuthService and navigates to Onboarding', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));

    // Scroll and tap Sign Out
    await tester.dragUntilVisible(
      find.text('Sign Out'),
      find.byType(SingleChildScrollView),
      const Offset(0, -200),
    );
    await tester.tap(find.text('Sign Out'));
    await tester.pumpAndSettle();

    // Tap confirm in dialog.
    final confirmButton = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.widgetWithText(TextButton, 'Sign Out'),
    );
    await tester.tap(confirmButton);
    await tester.pumpAndSettle();

    verify(() => mockAuthService.signOut()).called(1);
    expect(find.byType(OnboardingScreen), findsOneWidget);
  });

  testWidgets('Canceling Sign Out does not call AuthService', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));

    // Scroll and tap Sign Out
    await tester.dragUntilVisible(
      find.text('Sign Out'),
      find.byType(SingleChildScrollView),
      const Offset(0, -200),
    );
    await tester.tap(find.text('Sign Out'));
    await tester.pumpAndSettle();

    // Tap cancel
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    verifyNever(() => mockAuthService.signOut());
    expect(find.byType(SettingsScreen), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
  });
}
