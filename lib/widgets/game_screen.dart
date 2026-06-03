import 'package:flutter/material.dart';
import '../game/piece.dart';
import '../game/game_state.dart';
import '../game/ai.dart';
import 'board_widget.dart';

enum _GameMode { vsAI, vsHuman }

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameState _state;
  final _ai = AiPlayer(maxDepth: 6);
  bool _isAiThinking = false;
  _GameMode _gameMode = _GameMode.vsAI;

  @override
  void initState() {
    super.initState();
    _state = GameState.initial();
  }

  void _handleTap(int row, int col) {
    if (_isAiThinking || _state.isGameOver) return;
    if (_gameMode == _GameMode.vsAI && _state.currentPlayer != Piece.black) return;

    final newState = _state.makeMove(row, col);
    if (newState == _state) return;

    setState(() => _state = newState);

    if (_gameMode == _GameMode.vsAI &&
        !_state.isGameOver &&
        _state.currentPlayer == Piece.white) {
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

  void _toggleMode() {
    setState(() {
      _gameMode =
          _gameMode == _GameMode.vsAI ? _GameMode.vsHuman : _GameMode.vsAI;
      _state = GameState.initial();
      _isAiThinking = false;
    });
  }

  void _reset() {
    setState(() {
      _state = GameState.initial();
      _isAiThinking = false;
    });
  }

  void _passTurn() {
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
    if (_gameMode == _GameMode.vsAI && _state.currentPlayer == Piece.white) {
      _aiMove();
    }
  }

  void _showTutorial() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        title: const Row(
          children: [
            Icon(Icons.school, color: Colors.white70),
            SizedBox(width: 8),
            Text('How to Play', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: SingleChildScrollView(
          child: DefaultTextStyle(
            style: const TextStyle(
                color: Colors.white70, fontSize: 15, height: 1.5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _tutSection('Objective',
                    'Have the most pieces of your color on the board when the game ends.'),
                const SizedBox(height: 12),
                _tutSection('Setup',
                    'The game starts with 4 pieces in the center: two black and two white, arranged diagonally.'),
                const SizedBox(height: 12),
                _tutSection('Gameplay',
                    'Black moves first. On your turn, place one piece on an empty cell that outflanks one or more opponent pieces.'),
                const SizedBox(height: 12),
                _tutSection('Outflanking',
                    'A move outflanks opponent pieces when your new piece forms a straight line (horizontal, vertical, or diagonal) with another of your pieces, with opponent pieces in between.'),
                const SizedBox(height: 12),
                _tutSection('Flipping',
                    'All outflanked opponent pieces are flipped to your color. You must flip at least one piece each turn.'),
                const SizedBox(height: 12),
                _tutSection('Passing',
                    'If you have no valid moves, you pass and your opponent goes again.'),
                const SizedBox(height: 12),
                _tutSection('Game Over',
                    'The game ends when neither player can move. The player with the most pieces wins.'),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Got it!',
                style: TextStyle(color: Color(0xFFe94560))),
          ),
        ],
      ),
    );
  }

  Widget _tutSection(String title, String body) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        const SizedBox(height: 4),
        Text(body),
      ],
    );
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
        actions: [
          IconButton(
            icon: Icon(_gameMode == _GameMode.vsAI
                ? Icons.people_outline
                : Icons.memory),
            tooltip: _gameMode == _GameMode.vsAI
                ? 'Two-player mode'
                : 'AI opponent',
            onPressed: _toggleMode,
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'How to play',
            onPressed: _showTutorial,
          ),
        ],
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
              isTwoPlayer: _gameMode == _GameMode.vsHuman,
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
          onTap: _state.validMoves.isEmpty &&
                  !_state.isGameOver &&
                  !_isAiThinking
              ? _passTurn
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
  final bool isTwoPlayer;

  const _TurnIndicator({
    required this.player,
    required this.isAi,
    required this.isTwoPlayer,
  });

  @override
  Widget build(BuildContext context) {
    final label = isAi
        ? 'AI thinking...'
        : isTwoPlayer
            ? "${player == Piece.black ? "Black" : "White"}'s turn"
            : "Your turn";

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
            label,
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
    final color = Colors.white;

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
            Icon(icon,
                color: onTap != null ? Colors.white70 : Colors.white30,
                size: 18),
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
