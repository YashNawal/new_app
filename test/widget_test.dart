// This is a basic Flutter widget test.
import 'package:flutter_test/flutter_test.dart';
import 'package:borrow_manager/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BorrowManagerApp());

    // Verify that login screen text is present.
    expect(find.text('Borrow Manager'), findsAtLeastNWidgets(1));
  });
}
