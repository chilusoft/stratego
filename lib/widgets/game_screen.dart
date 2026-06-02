import 'package:flutter/material.dart';
import '../game/piece.dart';
import '../game/game_state.dart';
import '../game/ai.dart';
import 'board_widget.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameState _state;
  final _ai = AiPlayer(maxDepth: 6);
  bool _isAiThinking = false;

  @override
  void initState() {
    super.initState();
    _state = GameState.initial();
  }

  void _handleTap(int row, int col) {
    if (_isAiThinking || _state.isGameOver) return;
    if (_state.currentPlayer != Piece.black) return;

    final newState = _state.makeMove(row, col);
    if (newState == _state) return;

    setState(() => _state = newState);

    if (!_state.isGameOver && _state.currentPlayer == Piece.white) {
      _aiMove();
    }
  }

  Future<void> _aiMove() async {
    setState(() => _isAiThinking = true);

    await Future.delayed(const Duration(milliseconds: 300));

    final move = _ai.bestMove(_state.board, Piece.white);
    if (move != null && mounted) {
      setState(() {
        _state = _state.makeMove(move[0], move[1]);
        _isAiThinking = false;
      });

      if (!_state.isGameOver && _state.currentPlayer == Piece.white) {
        _aiMove();
      }
    } else {
      if (mounted) setState(() => _isAiThinking = false);
    }
  }

  void _reset() {
    setState(() {
      _state = GameState.initial();
      _isAiThinking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        title: const Text(
          'Reversi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF16213e),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          _ScoreRow(
            blackScore: _state.blackScore,
            whiteScore: _state.whiteScore,
            currentPlayer: _state.currentPlayer,
            isAiThinking: _isAiThinking,
          ),
          const SizedBox(height: 16),
          if (_state.isGameOver)
            _GameOverBanner(winner: _state.winner, onReset: _reset)
          else
            _TurnIndicator(
              player: _state.currentPlayer,
              isAi: _isAiThinking,
            ),
          const SizedBox(height: 12),
          Expanded(
            child: Center(
              child: BoardWidget(state: _state, onTap: _handleTap),
            ),
          ),
          const SizedBox(height: 16),
          _buildBottomBar(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ActionButton(
          icon: Icons.refresh,
          label: 'New Game',
          onTap: _reset,
        ),
        const SizedBox(width: 16),
        _ActionButton(
          icon: Icons.undo,
          label: 'Pass',
          onTap: _state.validMoves.isEmpty && !_state.isGameOver && !_isAiThinking
              ? () {
                  final newState = GameState(
                    board: _state.board,
                    currentPlayer: _state.currentPlayer.opponent,
                    validMoves: _state.board
                        .getPotentialMoves(_state.currentPlayer.opponent),
                    blackScore: _state.blackScore,
                    whiteScore: _state.whiteScore,
                    lastMove: _state.lastMove,
                  );
                  setState(() => _state = newState);
                  if (_state.currentPlayer == Piece.white) _aiMove();
                }
              : null,
        ),
      ],
    );
  }
}

class _ScoreRow extends StatelessWidget {
  final int blackScore;
  final int whiteScore;
  final Piece currentPlayer;
  final bool isAiThinking;

  const _ScoreRow({
    required this.blackScore,
    required this.whiteScore,
    required this.currentPlayer,
    required this.isAiThinking,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _ScoreChip(
            piece: Piece.black,
            score: blackScore,
            isActive: currentPlayer == Piece.black && !isAiThinking,
          ),
          const SizedBox(width: 32),
          _ScoreChip(
            piece: Piece.white,
            score: whiteScore,
            isActive: currentPlayer == Piece.white && !isAiThinking,
          ),
        ],
      ),
    );
  }
}

class _ScoreChip extends StatelessWidget {
  final Piece piece;
  final int score;
  final bool isActive;

  const _ScoreChip({
    required this.piece,
    required this.score,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isActive
            ? (piece == Piece.black ? Colors.black87 : Colors.white12)
            : const Color(0xFF16213e),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive
              ? (piece == Piece.black ? Colors.white : Colors.white54)
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            piece.label,
            style: TextStyle(
              fontSize: 24,
              color: piece == Piece.black ? Colors.white : Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$score',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _TurnIndicator extends StatelessWidget {
  final Piece player;
  final bool isAi;

  const _TurnIndicator({required this.player, required this.isAi});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF16213e),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            player.label,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 8),
          Text(
            isAi
                ? 'AI thinking...'
                : "Your turn",
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          if (isAi)
            const Padding(
              padding: EdgeInsets.only(left: 6),
              child: SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white54,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _GameOverBanner extends StatelessWidget {
  final Piece? winner;
  final VoidCallback onReset;

  const _GameOverBanner({required this.winner, required this.onReset});

  @override
  Widget build(BuildContext context) {
    final text = winner == null
        ? "It's a Draw!"
        : '${winner == Piece.black ? "Black" : "White"} Wins!';
    final color = winner == Piece.black
        ? Colors.white
        : Colors.white;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFe94560), Color(0xFFc23152)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.emoji_events, color: color, size: 22),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onReset,
            child: const Icon(Icons.refresh, color: Colors.white, size: 22),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: onTap != null
              ? const Color(0xFF16213e)
              : const Color(0xFF16213e).withAlpha(80),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: onTap != null ? Colors.white24 : Colors.white10,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: onTap != null ? Colors.white70 : Colors.white30, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: onTap != null ? Colors.white70 : Colors.white30,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
