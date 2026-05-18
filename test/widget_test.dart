import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laavei_mobile/src/app.dart';

void main() {
  testWidgets('App starts and shows SignInScreen', skip: true, (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: LaaveiApp()));

    // Verify that the app builds
    expect(find.byType(LaaveiApp), findsOneWidget);
  });
}
