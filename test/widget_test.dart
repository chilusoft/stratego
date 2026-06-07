import 'dart:ui' as ui;
import 'package:flutter_test/flutter_test.dart';
import 'package:stratego/main.dart';

Future<void> pumpThroughAi(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pump();
}

void main() {
  testWidgets('App loads and displays Reversi title', (WidgetTester tester) async {
    tester.view.physicalSize = const ui.Size(1200, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ReversiApp());
    await pumpThroughAi(tester);

    expect(find.text('Reversi'), findsOneWidget);
  });
}
