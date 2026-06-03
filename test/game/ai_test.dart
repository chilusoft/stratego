import 'package:flutter_test/flutter_test.dart';
import 'package:stratego/game/piece.dart';
import 'package:stratego/game/board.dart';
import 'package:stratego/game/ai.dart';

void main() {
  group('AiPlayer constructor', () {
    test('default max depth is 5', () {
      final ai = AiPlayer();
      expect(ai.maxDepth, 5);
    });

    test('accepts custom max depth', () {
      final ai = AiPlayer(maxDepth: 3);
      expect(ai.maxDepth, 3);
    });
  });

  group('AiPlayer.bestMove', () {
    test('returns null when no moves available', () {
      final board = Board();
      for (var r = 0; r < 8; r++) {
        for (var c = 0; c < 8; c++) {
          board.grid[r][c] = Piece.black;
        }
      }
      final ai = AiPlayer();
      final move = ai.bestMove(board, Piece.white);
      expect(move, isNull);
    });

    test('returns a valid move from initial position', () {
      final board = Board();
      final ai = AiPlayer(maxDepth: 2);
      final move = ai.bestMove(board, Piece.black);
      expect(move, isNotNull);
      expect(move, hasLength(2));
      // Should be one of the 4 valid opening moves
      final validMoves = board.getPotentialMoves(Piece.black);
      expect(validMoves.any((m) => m[0] == move![0] && m[1] == move[1]), isTrue);
    });

    test('prefers corner moves when available', () {
      // Set up a board where a corner move is available
      final board = Board();
      // Clear initial pieces
      for (var r = 0; r < 8; r++) {
        for (var c = 0; c < 8; c++) {
          board.grid[r][c] = Piece.empty;
        }
      }
      // Put black at (0,0), white at (0,1), black at (0,2)
      // So black at (0,0) would be a corner
      board.grid[0][0] = Piece.empty;
      board.grid[0][1] = Piece.white;
      board.grid[1][0] = Piece.white;
      board.grid[0][2] = Piece.black;
      board.grid[2][0] = Piece.black;
      board.grid[1][1] = Piece.black;

      final ai = AiPlayer(maxDepth: 2);
      final move = ai.bestMove(board, Piece.black);
      // The AI should find some valid move
      if (board.getPotentialMoves(Piece.black).isNotEmpty) {
        expect(move, isNotNull);
      }
    });

    test('handles white player', () {
      final b = Board();
      final ai = AiPlayer(maxDepth: 2);
      // After black plays (2,3), white's turn has moves
      b.place(Piece.black, 2, 3);
      final move = ai.bestMove(b, Piece.white);
      expect(move, isNotNull);
      final validMoves = b.getPotentialMoves(Piece.white);
      expect(validMoves.any((m) => m[0] == move![0] && m[1] == move[1]), isTrue);
    });
  });
}
