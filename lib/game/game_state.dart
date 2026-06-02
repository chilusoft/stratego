import 'board.dart';
import 'piece.dart';

enum GameStatus { playing, won, draw }

class GameState {
  final Board board;
  final Piece currentPlayer;
  final Piece? winner;
  final GameStatus status;
  final List<List<int>> validMoves;
  final List<List<int>>? lastMove;
  final int blackScore;
  final int whiteScore;

  GameState({
    Board? board,
    this.currentPlayer = Piece.black,
    this.winner,
    this.status = GameStatus.playing,
    List<List<int>>? validMoves,
    this.lastMove,
    int? blackScore,
    int? whiteScore,
  })  : board = board ?? Board(),
        validMoves = validMoves ?? [],
        blackScore = blackScore ?? 2,
        whiteScore = whiteScore ?? 2;

  static GameState initial() {
    final b = Board();
    return GameState(
      board: b,
      validMoves: b.getPotentialMoves(Piece.black),
    );
  }

  GameState makeMove(int row, int col) {
    if (!validMoves.any((m) => m[0] == row && m[1] == col)) return this;

    final newBoard = board.copy();
    newBoard.place(currentPlayer, row, col);

    final nextPlayer = currentPlayer.opponent;
    var nextMoves = newBoard.getPotentialMoves(nextPlayer);

    if (nextMoves.isEmpty) {
      nextMoves = newBoard.getPotentialMoves(currentPlayer);
      if (nextMoves.isEmpty) {
        final bCount = newBoard.count(Piece.black);
        final wCount = newBoard.count(Piece.white);
        return GameState(
          board: newBoard,
          currentPlayer: currentPlayer,
          status: GameStatus.won,
          winner: bCount > wCount ? Piece.black : Piece.white,
          lastMove: [[row, col]],
          blackScore: bCount,
          whiteScore: wCount,
          validMoves: [],
        );
      }
      return GameState(
        board: newBoard,
        currentPlayer: currentPlayer,
        lastMove: [[row, col]],
        blackScore: newBoard.count(Piece.black),
        whiteScore: newBoard.count(Piece.white),
        validMoves: nextMoves,
      );
    }

    return GameState(
      board: newBoard,
      currentPlayer: nextPlayer,
      lastMove: [[row, col]],
      blackScore: newBoard.count(Piece.black),
      whiteScore: newBoard.count(Piece.white),
      validMoves: nextMoves,
    );
  }

  bool get isGameOver => status != GameStatus.playing;
}
