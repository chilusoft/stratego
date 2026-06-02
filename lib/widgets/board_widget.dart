import 'dart:math';
import 'package:flutter/material.dart';
import '../game/board.dart';
import '../game/piece.dart';
import '../game/game_state.dart';

class BoardWidget extends StatelessWidget {
  final GameState state;
  final void Function(int row, int col) onTap;

  const BoardWidget({super.key, required this.state, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cellSize = (min(MediaQuery.of(context).size.width - 32, 400)) / Board.size;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.brown.shade800, width: 3),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: List.generate(Board.size, (r) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(Board.size, (c) {
              final isLast = state.lastMove?.any((m) => m[0] == r && m[1] == c) ?? false;
              final isValid =
                  state.validMoves.any((m) => m[0] == r && m[1] == c);
              return _Cell(
                size: cellSize,
                piece: state.board.get(r, c),
                isValid: isValid,
                isLastMove: isLast,
                onTap: isValid ? () => onTap(r, c) : null,
              );
            }),
          );
        }),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  final double size;
  final Piece piece;
  final bool isValid;
  final bool isLastMove;
  final VoidCallback? onTap;

  const _Cell({
    required this.size,
    required this.piece,
    required this.isValid,
    required this.isLastMove,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isValid
              ? const Color(0xFF448844)
              : const Color(0xFF2D6B2D),
          border: Border.all(color: const Color(0xFF1B5E20), width: 0.5),
        ),
        child: Center(
          child: piece != Piece.empty
              ? _PieceWidget(
                  piece: piece,
                  size: size * 0.8,
                  isLastMove: isLastMove,
                )
              : isValid
                  ? Container(
                      width: size * 0.25,
                      height: size * 0.25,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black26,
                      ),
                    )
                  : null,
        ),
      ),
    );
  }
}

class _PieceWidget extends StatelessWidget {
  final Piece piece;
  final double size;
  final bool isLastMove;

  const _PieceWidget({
    required this.piece,
    required this.size,
    required this.isLastMove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.3, -0.3),
          colors: piece == Piece.black
              ? [Colors.grey.shade700, Colors.black]
              : [Colors.white, Colors.grey.shade300],
        ),
        border: Border.all(
          color: isLastMove ? Colors.yellow : Colors.black26,
          width: isLastMove ? 2.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(60),
            blurRadius: 3,
            offset: const Offset(1, 2),
          ),
        ],
      ),
    );
  }
}
