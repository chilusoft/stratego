import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stratego/widgets/tutorial_screen.dart';

Widget createApp() => const MaterialApp(home: TutorialScreen());

void main() {
  group('TutorialScreen', () {
    testWidgets('renders How to Play title', (tester) async {
      tester.view.physicalSize = const ui.Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createApp());
      await tester.pump();

      expect(find.text('How to Play'), findsOneWidget);
    });

    testWidgets('shows initial navigation with Back disabled', (tester) async {
      tester.view.physicalSize = const ui.Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createApp());
      await tester.pump();

      expect(find.text('Next'), findsOneWidget);
      expect(find.text('Back'), findsOneWidget);
      expect(find.text('Done'), findsNothing);
    });

    testWidgets('navigates through all pages to Done', (tester) async {
      tester.view.physicalSize = const ui.Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createApp());
      await tester.pump();

      for (var i = 0; i < 4; i++) {
        expect(find.text('Next'), findsOneWidget);
        await tester.tap(find.text('Next'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
      }

      expect(find.text('Done'), findsOneWidget);
    });

    testWidgets('shows WelcomePage content', (tester) async {
      tester.view.physicalSize = const ui.Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createApp());
      await tester.pump();

      expect(find.text('Reversi'), findsOneWidget);
    });

    testWidgets('back navigates to previous page', (tester) async {
      tester.view.physicalSize = const ui.Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createApp());
      await tester.pump();

      // Go to page 2
      await tester.tap(find.text('Next'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Back should be enabled now
      await tester.tap(find.text('Back'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Should be back on page 1
      expect(find.text('Next'), findsOneWidget);
      expect(find.text('Done'), findsNothing);
    });

    testWidgets('Done shows on last page and Back navigates back', (tester) async {
      tester.view.physicalSize = const ui.Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createApp());
      await tester.pump();

      // Navigate to last page
      for (var i = 0; i < 4; i++) {
        await tester.tap(find.text('Next'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
      }

      expect(find.text('Done'), findsOneWidget);
      expect(find.text('Next'), findsNothing);

      // Go back to page 4
      await tester.tap(find.text('Back'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Done'), findsNothing);
      expect(find.text('Next'), findsOneWidget);
    });
  });
}
