import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/main.dart';
import 'package:habitflow/widgets/main_navigation.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Expecting to find MyApp
    expect(find.byType(MyApp), findsOneWidget);
  });
}
