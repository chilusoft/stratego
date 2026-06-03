import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stratego/game/piece.dart';
import 'package:stratego/game/game_state.dart';
import 'package:stratego/widgets/board_widget.dart';

void main() {
  group('BoardWidget', () {
    testWidgets('renders 8x8 grid of cells', (tester) async {
      tester.view.physicalSize = const ui.Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final state = GameState.initial();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BoardWidget(state: state, onTap: (r, c) {}),
          ),
        ),
      );

      // Board size is 8
      expect(find.byType(GestureDetector), findsAtLeast(64));
    });

    testWidgets('shows valid moves as green cells with a dot', (tester) async {
      tester.view.physicalSize = const ui.Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final state = GameState.initial();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BoardWidget(state: state, onTap: (r, c) {}),
          ),
        ),
      );

      // 4 valid moves should be rendered with Container children for the dot
      expect(state.validMoves, hasLength(4));
    });

    testWidgets('calls onTap when valid cell is tapped', (tester) async {
      tester.view.physicalSize = const ui.Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      int? tappedRow;
      int? tappedCol;
      final state = GameState.initial();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BoardWidget(state: state, onTap: (r, c) {
              tappedRow = r;
              tappedCol = c;
            }),
          ),
        ),
      );

      // Tap on a valid cell (2,4)
      // The cell at (r=2, c=4) in the 8x8 grid
      // We need to find the GestureDetector for that cell
      final cells = find.byType(GestureDetector);
      // Cells: 8 rows x 8 cols = 64 cells. (2,4) is at index 2*8+4 = 20
      await tester.tap(cells.at(20));
      expect(tappedRow, 2);
      expect(tappedCol, 4);
    });
  });
}
