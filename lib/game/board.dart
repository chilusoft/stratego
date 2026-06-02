import 'piece.dart';

class Board {
  static const int size = 8;
  final List<List<Piece>> grid;

  Board()
      : grid = List.generate(
          size,
          (_) => List.filled(size, Piece.empty),
        ) {
    grid[3][3] = Piece.white;
    grid[3][4] = Piece.black;
    grid[4][3] = Piece.black;
    grid[4][4] = Piece.white;
  }

  Board._(this.grid);

  Board copy() => Board._(grid.map((r) => List<Piece>.from(r)).toList());

  Piece get(int row, int col) => grid[row][col];

  bool inBounds(int row, int col) =>
      row >= 0 && row < size && col >= 0 && col < size;

  List<List<int>> getPotentialMoves(Piece player) {
    final moves = <List<int>>[];
    for (var r = 0; r < size; r++) {
      for (var c = 0; c < size; c++) {
        if (grid[r][c] == Piece.empty && wouldFlip(player, r, c).isNotEmpty) {
          moves.add([r, c]);
        }
      }
    }
    return moves;
  }

  List<List<int>> wouldFlip(Piece player, int row, int col) {
    if (!inBounds(row, col) || grid[row][col] != Piece.empty) return [];
    final flipped = <List<int>>[];
    for (final dr in [-1, 0, 1]) {
      for (final dc in [-1, 0, 1]) {
        if (dr == 0 && dc == 0) continue;
        final flips = _flipsInDir(player, row, col, dr, dc);
        flipped.addAll(flips);
      }
    }
    return flipped;
  }

  List<List<int>> _flipsInDir(
      Piece player, int row, int col, int dr, int dc) {
    final flips = <List<int>>[];
    var r = row + dr;
    var c = col + dc;
    while (inBounds(r, c) && grid[r][c] == player.opponent) {
      flips.add([r, c]);
      r += dr;
      c += dc;
    }
    if (flips.isNotEmpty && inBounds(r, c) && grid[r][c] == player) {
      return flips;
    }
    return [];
  }

  void place(Piece player, int row, int col) {
    final flips = wouldFlip(player, row, col);
    grid[row][col] = player;
    for (final f in flips) {
      grid[f[0]][f[1]] = player;
    }
  }

  int count(Piece p) =>
      grid.fold(0, (sum, r) => sum + r.where((c) => c == p).length);

  bool get isFull => grid.every((r) => r.every((c) => c != Piece.empty));

  int evaluate(Piece player) {
    final opp = player.opponent;

    final posWeight = [
      [100, -20, 10, 5, 5, 10, -20, 100],
      [-20, -50, -2, -2, -2, -2, -50, -20],
      [10, -2, 1, 1, 1, 1, -2, 10],
      [5, -2, 1, 0, 0, 1, -2, 5],
      [5, -2, 1, 0, 0, 1, -2, 5],
      [10, -2, 1, 1, 1, 1, -2, 10],
      [-20, -50, -2, -2, -2, -2, -50, -20],
      [100, -20, 10, 5, 5, 10, -20, 100],
    ];

    var score = 0;
    for (var r = 0; r < size; r++) {
      for (var c = 0; c < size; c++) {
        if (grid[r][c] == player) score += posWeight[r][c];
        if (grid[r][c] == opp) score -= posWeight[r][c];
      }
    }

    final playerMoves = getPotentialMoves(player).length;
    final oppMoves = getPotentialMoves(opp).length;
    score += (playerMoves - oppMoves) * 3;

    score += count(player) * 2;
    score -= count(opp) * 2;

    return score;
  }
}
