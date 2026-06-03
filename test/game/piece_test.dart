import 'package:flutter_test/flutter_test.dart';
import 'package:stratego/game/piece.dart';

void main() {
  group('Piece enum', () {
    test('has three values', () {
      expect(Piece.values, hasLength(3));
      expect(Piece.values, containsAll([Piece.empty, Piece.black, Piece.white]));
    });
  });

  group('PieceExtension.opponent', () {
    test('black opponent is white', () {
      expect(Piece.black.opponent, Piece.white);
    });
    test('white opponent is black', () {
      expect(Piece.white.opponent, Piece.black);
    });
    test('empty opponent is empty', () {
      expect(Piece.empty.opponent, Piece.empty);
    });
  });

  group('PieceExtension.label', () {
    test('empty label is empty string', () {
      expect(Piece.empty.label, '');
    });
    test('black label is filled circle', () {
      expect(Piece.black.label, '●');
    });
    test('white label is hollow circle', () {
      expect(Piece.white.label, '○');
    });
  });

  group('PieceExtension.isEmpty', () {
    test('empty is empty', () {
      expect(Piece.empty.isEmpty, isTrue);
    });
    test('black is not empty', () {
      expect(Piece.black.isEmpty, isFalse);
    });
    test('white is not empty', () {
      expect(Piece.white.isEmpty, isFalse);
    });
  });
}
