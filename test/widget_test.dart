import 'package:flutter_test/flutter_test.dart';
import 'package:stratego/main.dart';

void main() {
  testWidgets('App loads and displays Reversi title', (WidgetTester tester) async {
    await tester.pumpWidget(const ReversiApp());
    expect(find.text('Reversi'), findsOneWidget);
  });
}
