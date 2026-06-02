enum Piece { empty, black, white }

extension PieceExtension on Piece {
  Piece get opponent => switch (this) {
        Piece.black => Piece.white,
        Piece.white => Piece.black,
        Piece.empty => Piece.empty,
      };

  String get label => switch (this) {
        Piece.empty => '',
        Piece.black => '●',
        Piece.white => '○',
      };

  bool get isEmpty => this == Piece.empty;
}
