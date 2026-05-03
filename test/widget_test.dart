import 'package:flutter_test/flutter_test.dart';
import 'package:borrow_manager/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const BorrowManagerApp(
      userName: 'User',
      userEmail: '',
      userMobile: '',
    ));

    expect(find.text('Borrow Manager'), findsAtLeastNWidgets(1));
  });
}
