import 'dart:ui' as ui;
import 'package:flutter_test/flutter_test.dart';
import 'package:stratego/main.dart';

void main() {
  testWidgets('App loads and displays Reversi title', (WidgetTester tester) async {
    tester.view.physicalSize = const ui.Size(1200, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ReversiApp());
    expect(find.text('Reversi'), findsOneWidget);
  });
}
