import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stratego/widgets/game_screen.dart';

void main() {
  group('GameScreen', () {
    testWidgets('renders app bar with Reversi title', (tester) async {
      tester.view.physicalSize = const ui.Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const MaterialApp(home: GameScreen()));
      await tester.pump();

      expect(find.text('Reversi'), findsOneWidget);
    });

    testWidgets('shows initial scores of 2-2', (tester) async {
      tester.view.physicalSize = const ui.Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const MaterialApp(home: GameScreen()));
      await tester.pump();

      // Both scores should be displayed
      expect(find.text('2'), findsAtLeast(2));
    });

    testWidgets('shows bottom action bar with New Game and Pass', (tester) async {
      tester.view.physicalSize = const ui.Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const MaterialApp(home: GameScreen()));
      await tester.pump();

      expect(find.text('New Game'), findsOneWidget);
      expect(find.text('Pass'), findsOneWidget);
    });

    testWidgets('tapping New Game resets board', (tester) async {
      tester.view.physicalSize = const ui.Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const MaterialApp(home: GameScreen()));
      await tester.pump();

      // Tap New Game button
      await tester.tap(find.text('New Game'));
      await tester.pump();

      // Should still be showing scores
      expect(find.text('2'), findsAtLeast(2));
    });

    testWidgets('shows timer icon in app bar', (tester) async {
      tester.view.physicalSize = const ui.Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const MaterialApp(home: GameScreen()));
      await tester.pump();

      expect(find.byIcon(Icons.timer_outlined), findsOneWidget);
    });

    testWidgets('shows info tutorial button', (tester) async {
      tester.view.physicalSize = const ui.Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const MaterialApp(home: GameScreen()));
      await tester.pump();

      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('shows mode toggle button (people icon for vsAI)', (tester) async {
      tester.view.physicalSize = const ui.Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const MaterialApp(home: GameScreen()));
      await tester.pump();

      expect(find.byIcon(Icons.people_outline), findsOneWidget);
    });

    testWidgets('shows difficulty button in vsAI mode', (tester) async {
      tester.view.physicalSize = const ui.Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const MaterialApp(home: GameScreen()));
      await tester.pump();

      expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
    });

    testWidgets('cycling timer button changes tooltip', (tester) async {
      tester.view.physicalSize = const ui.Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const MaterialApp(home: GameScreen()));
      await tester.pump();

      // Tap timer button to cycle
      await tester.tap(find.byIcon(Icons.timer_outlined));
      await tester.pump();

      // After cycling once, should be '3 min'
      expect(find.byTooltip('Timer: 3 min'), findsOneWidget);
    });

    testWidgets('cycling difficulty button changes tooltip', (tester) async {
      tester.view.physicalSize = const ui.Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const MaterialApp(home: GameScreen()));
      await tester.pump();

      // Tap difficulty button to cycle
      await tester.tap(find.byIcon(Icons.auto_awesome));
      await tester.pump();

      // After cycling from Hard -> Expert
      expect(find.byTooltip('Difficulty: Expert'), findsOneWidget);
    });

    testWidgets('tapping tutorial button navigates', (tester) async {
      tester.view.physicalSize = const ui.Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const MaterialApp(home: GameScreen()));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.info_outline));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Tutorial should be visible - check for the title
      expect(find.text('How to Play'), findsOneWidget);
    });

    testWidgets('tapping mode toggle switches icon', (tester) async {
      tester.view.physicalSize = const ui.Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const MaterialApp(home: GameScreen()));
      await tester.pump();

      // Initially vsAI mode -> people icon
      expect(find.byIcon(Icons.people_outline), findsOneWidget);

      // Toggle to vsHuman
      await tester.tap(find.byIcon(Icons.people_outline));
      await tester.pump();

      // Should show AI icon now
      expect(find.byIcon(Icons.memory), findsOneWidget);
    });

    testWidgets('shows turn indicator', (tester) async {
      tester.view.physicalSize = const ui.Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const MaterialApp(home: GameScreen()));
      await tester.pump();

      expect(find.textContaining('Your turn'), findsOneWidget);
    });

    testWidgets('two-player mode shows different turn text', (tester) async {
      tester.view.physicalSize = const ui.Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const MaterialApp(home: GameScreen()));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.people_outline));
      await tester.pump();

      expect(find.textContaining("Black's turn"), findsOneWidget);
    });

    testWidgets('timer cycling shows timer indicator', (tester) async {
      tester.view.physicalSize = const ui.Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const MaterialApp(home: GameScreen()));
      await tester.pump();

      // Enable 3 min timer
      await tester.tap(find.byIcon(Icons.timer_outlined));
      await tester.pump();

      // Should show timer icon in the indicator
      expect(find.byIcon(Icons.timer), findsAtLeast(1));
    });

    testWidgets('cycle through all timer options', (tester) async {
      tester.view.physicalSize = const ui.Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const MaterialApp(home: GameScreen()));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.timer_outlined));
      await tester.pump();
      expect(find.byTooltip('Timer: 3 min'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.timer_outlined));
      await tester.pump();
      expect(find.byTooltip('Timer: 5 min'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.timer_outlined));
      await tester.pump();
      expect(find.byTooltip('Timer: 10 min'), findsOneWidget);

      // Cycle back to off
      await tester.tap(find.byIcon(Icons.timer_outlined));
      await tester.pump();
      expect(find.byTooltip('Timer: Off'), findsOneWidget);
    });

    testWidgets('cycle through all difficulty options', (tester) async {
      tester.view.physicalSize = const ui.Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const MaterialApp(home: GameScreen()));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.auto_awesome));
      await tester.pump();
      expect(find.byTooltip('Difficulty: Expert'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.auto_awesome));
      await tester.pump();
      expect(find.byTooltip('Difficulty: Easy'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.auto_awesome));
      await tester.pump();
      expect(find.byTooltip('Difficulty: Medium'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.auto_awesome));
      await tester.pump();
      expect(find.byTooltip('Difficulty: Hard'), findsOneWidget);
    });

    testWidgets('tutorial page navigation', (tester) async {
      tester.view.physicalSize = const ui.Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const MaterialApp(home: GameScreen()));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.info_outline));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('How to Play'), findsOneWidget);

      // Find the "Next" button on the bottom nav
      final nextButton = find.text('Next');
      expect(nextButton, findsOneWidget);

      // Tap Next to go to page 2
      await tester.tap(nextButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Tap Next to go to page 3
      await tester.tap(find.text('Next'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Tap Next to go to page 4
      await tester.tap(find.text('Next'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Tap Next to go to page 5 (last)
      await tester.tap(find.text('Next'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Should show "Done" button on last page
      expect(find.text('Done'), findsOneWidget);

      // Should also show "Back" button
      expect(find.text('Back'), findsOneWidget);

      // Go back
      await tester.tap(find.text('Back'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    });
  });
}
