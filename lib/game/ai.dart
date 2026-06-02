import 'board.dart';
import 'piece.dart';

class AiPlayer {
  final int maxDepth;

  AiPlayer({this.maxDepth = 5});

  List<int>? bestMove(Board board, Piece player) {
    final moves = board.getPotentialMoves(player);
    if (moves.isEmpty) return null;

    List<int>? best;
    var bestScore = -999999;

    for (final move in moves) {
      final b = board.copy();
      b.place(player, move[0], move[1]);
      final score = _minimax(b, maxDepth - 1, -999999, 999999, false, player);
      if (score > bestScore) {
        bestScore = score;
        best = move;
      }
    }
    return best;
  }

  int _minimax(Board board, int depth, int alpha, int beta, bool maximizing,
      Piece player) {
    final moves = board.getPotentialMoves(maximizing ? player : player.opponent);

    if (depth == 0 || (moves.isEmpty && board.getPotentialMoves(
                maximizing ? player.opponent : player)
            .isEmpty)) {
      return board.evaluate(player);
    }

    if (moves.isEmpty) {
      return _minimax(
          board, depth - 1, alpha, beta, !maximizing, player);
    }

    if (maximizing) {
      var maxEval = -999999;
      for (final move in moves) {
        final b = board.copy();
        b.place(player, move[0], move[1]);
        final eval =
            _minimax(b, depth - 1, alpha, beta, false, player);
        maxEval = eval > maxEval ? eval : maxEval;
        alpha = alpha > eval ? alpha : eval;
        if (beta <= alpha) break;
      }
      return maxEval;
    } else {
      var minEval = 999999;
      for (final move in moves) {
        final b = board.copy();
        b.place(player.opponent, move[0], move[1]);
        final eval =
            _minimax(b, depth - 1, alpha, beta, true, player);
        minEval = eval < minEval ? eval : minEval;
        beta = beta < eval ? beta : eval;
        if (beta <= alpha) break;
      }
      return minEval;
    }
  }
}
