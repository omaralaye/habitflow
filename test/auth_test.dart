import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sanctuary/screens/login_screen.dart';
import 'package:sanctuary/screens/signup_screen.dart';
import 'package:sanctuary/widgets/main_navigation.dart';
import 'package:sanctuary/services/auth_service.dart';
import 'package:sanctuary/services/database_service.dart';
import 'package:sanctuary/utils/error_handler.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthService extends Mock implements AuthService {}
class MockDatabaseService extends Mock implements DatabaseService {}

void main() {
  late MockAuthService mockAuthService;
  late MockDatabaseService mockDatabaseService;

  setUp(() {
    mockAuthService = MockAuthService();
    AuthService.setMockInstance(mockAuthService);

    mockDatabaseService = MockDatabaseService();
    DatabaseService.setMockInstance(mockDatabaseService);

    // Default mock behaviors
    when(() => mockAuthService.signIn(any(), any())).thenAnswer((_) async => ServiceResult.success(null));
    when(() => mockAuthService.signUp(any(), any(), name: any(named: 'name'), emoji: any(named: 'emoji')))
        .thenAnswer((_) async => ServiceResult.success(null));
    when(() => mockDatabaseService.hasHabits()).thenAnswer((_) async => true);
    when(() => mockDatabaseService.habitsStream).thenAnswer((_) => Stream.value([]));
  });

  group('LoginScreen Tests', () {
    testWidgets('LoginScreen shows form fields and buttons', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.byIcon(Icons.email_outlined), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline_rounded), findsOneWidget);
      expect(find.text('Log In'), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);
    });

    testWidgets('LoginScreen form validation', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
      await tester.dragUntilVisible(find.text('Log In'), find.byType(SingleChildScrollView), const Offset(0, -100));

      await tester.tap(find.text('Log In'));
      await tester.pump();

      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('LoginScreen navigation to MainNavigation on valid login', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).last, 'password123');

      await tester.dragUntilVisible(find.text('Log In'), find.byType(SingleChildScrollView), const Offset(0, -100));
      await tester.tap(find.text('Log In'));
      await tester.pumpAndSettle();

      verify(() => mockAuthService.signIn('test@example.com', 'password123')).called(1);
      expect(find.byType(MainNavigation), findsOneWidget);
    });
  });

  group('SignupScreen Tests', () {
    testWidgets('SignupScreen shows form fields and buttons', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: SignupScreen()));

      expect(find.text('Join Sanctuary'), findsOneWidget);
      expect(find.byIcon(Icons.person_outline_rounded), findsOneWidget);
      expect(find.byIcon(Icons.email_outlined), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline_rounded), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);
      expect(find.text('Log In'), findsOneWidget);
    });

    testWidgets('SignupScreen form validation', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: SignupScreen()));
      await tester.dragUntilVisible(find.text('Sign Up'), find.byType(SingleChildScrollView), const Offset(0, -100));

      await tester.tap(find.text('Sign Up'));
      await tester.pump();

      expect(find.text('Please enter your name'), findsOneWidget);
      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('SignupScreen navigation to MainNavigation on valid signup', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: SignupScreen()));

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'John Doe');
      await tester.enterText(textFields.at(1), 'test@example.com');
      await tester.enterText(textFields.at(2), 'password123');

      await tester.dragUntilVisible(find.text('Sign Up'), find.byType(SingleChildScrollView), const Offset(0, -100));
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      verify(() => mockAuthService.signUp(
        'test@example.com',
        'password123',
        name: 'John Doe',
        emoji: any(named: 'emoji')
      )).called(1);
      expect(find.byType(MainNavigation), findsOneWidget);
    });
  });
}
