import 'dart:async';
import 'package:flutter/material.dart';
import '../game/piece.dart';
import '../game/game_state.dart';
import '../game/ai.dart';
import '../audio/audio_service.dart';
import 'board_widget.dart';
import 'tutorial_screen.dart';

enum _GameMode { vsAI, vsHuman }

enum _TimerOption { off, min3, min5, min10 }

Duration _timerDuration(_TimerOption opt) {
  switch (opt) {
    case _TimerOption.min3:
      return const Duration(minutes: 3);
    case _TimerOption.min5:
      return const Duration(minutes: 5);
    case _TimerOption.min10:
      return const Duration(minutes: 10);
    case _TimerOption.off:
      return Duration.zero;
  }
}

String _timerLabel(_TimerOption opt) {
  switch (opt) {
    case _TimerOption.off:
      return 'Off';
    case _TimerOption.min3:
      return '3 min';
    case _TimerOption.min5:
      return '5 min';
    case _TimerOption.min10:
      return '10 min';
  }
}

enum _AIDifficulty { easy, medium, hard, expert }

int _depthFor(_AIDifficulty d) {
  switch (d) {
    case _AIDifficulty.easy:
      return 2;
    case _AIDifficulty.medium:
      return 4;
    case _AIDifficulty.hard:
      return 6;
    case _AIDifficulty.expert:
      return 8;
  }
}

String _difficultyLabel(_AIDifficulty d) {
  switch (d) {
    case _AIDifficulty.easy:
      return 'Easy';
    case _AIDifficulty.medium:
      return 'Medium';
    case _AIDifficulty.hard:
      return 'Hard';
    case _AIDifficulty.expert:
      return 'Expert';
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameState _state;
  AiPlayer _ai = AiPlayer(maxDepth: _depthFor(_AIDifficulty.hard));
  bool _isAiThinking = false;
  _GameMode _gameMode = _GameMode.vsAI;
  _AIDifficulty _aiDifficulty = _AIDifficulty.hard;
  _TimerOption _timerOption = _TimerOption.off;
  Duration _blackTime = Duration.zero;
  Duration _whiteTime = Duration.zero;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _state = GameState.initial();
    _resetTimers();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _resetTimers() {
    final limit = _timerDuration(_timerOption);
    _blackTime = limit;
    _whiteTime = limit;
  }

  void _startClock() {
    _timer?.cancel();
    if (_timerOption == _TimerOption.off) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_state.isGameOver) {
          _timer?.cancel();
          return;
        }
        if (_state.currentPlayer == Piece.black) {
          _blackTime -= const Duration(seconds: 1);
          if (_blackTime.inSeconds <= 0) {
            _blackTime = Duration.zero;
            _timer?.cancel();
            _timeout(Piece.white);
          }
        } else {
          _whiteTime -= const Duration(seconds: 1);
          if (_whiteTime.inSeconds <= 0) {
            _whiteTime = Duration.zero;
            _timer?.cancel();
            _timeout(Piece.black);
          }
        }
      });
    });
  }

  void _stopClock() {
    _timer?.cancel();
  }

  void _timeout(Piece winner) {
    _stopClock();
    setState(() {
      _state = GameState(
        board: _state.board,
        currentPlayer: _state.currentPlayer,
        status: GameStatus.won,
        winner: winner,
        blackScore: _state.blackScore,
        whiteScore: _state.whiteScore,
        validMoves: [],
      );
    });
    AudioService.playWin();
  }

  void _handleTap(int row, int col) {
    if (_isAiThinking || _state.isGameOver) return;
    if (_gameMode == _GameMode.vsAI && _state.currentPlayer != Piece.black) return;

    final newState = _state.makeMove(row, col);
    if (newState == _state) return;

    setState(() => _state = newState);
    AudioService.playMove();

    if (newState.isGameOver) {
      newState.winner == null
          ? AudioService.playDraw()
          : AudioService.playWin();
    }

    if (_gameMode == _GameMode.vsAI) {
      if (!_state.isGameOver && _state.currentPlayer == Piece.white) {
        _stopClock(); // pause human's clock while AI thinks
        _aiMove();
      } else if (!_state.isGameOver) {
        _startClock(); // still human's turn (no valid AI moves, stayed on black)
      } else {
        _stopClock();
      }
    } else {
      if (_state.isGameOver) {
        _stopClock();
      }
      _switchClock();
    }
  }

  void _switchClock() {
    if (_timerOption == _TimerOption.off || _state.isGameOver) return;
    _startClock(); // tick the new current player's clock
  }

  Future<void> _aiMove() async {
    setState(() => _isAiThinking = true);

    await Future.delayed(const Duration(milliseconds: 300));

    final move = _ai.bestMove(_state.board, Piece.white);
    if (move != null && mounted) {
      final aiState = _state.makeMove(move[0], move[1]);
      setState(() {
        _state = aiState;
        _isAiThinking = false;
      });
      AudioService.playMove();

      if (aiState.isGameOver) {
        aiState.winner == null
            ? AudioService.playDraw()
            : AudioService.playWin();
      }

      if (!_state.isGameOver && _state.currentPlayer == Piece.white) {
        _aiMove();
      } else if (!_state.isGameOver) {
        _startClock(); // back to human's turn
      } else {
        _stopClock();
      }
    } else {
      if (mounted) {
        setState(() => _isAiThinking = false);
        if (!_state.isGameOver) {
          _startClock(); // back to human's turn
        }
      }
    }
  }

  void _cycleTimer() {
    final values = _TimerOption.values;
    final idx = (values.indexOf(_timerOption) + 1) % values.length;
    setState(() {
      _timerOption = values[idx];
      _stopClock();
      _resetTimers();
      _state = GameState.initial();
      _isAiThinking = false;
    });
  }

  void _cycleDifficulty() {
    final values = _AIDifficulty.values;
    final idx = (values.indexOf(_aiDifficulty) + 1) % values.length;
    setState(() {
      _aiDifficulty = values[idx];
      _ai = AiPlayer(maxDepth: _depthFor(_aiDifficulty));
      _state = GameState.initial();
      _isAiThinking = false;
      _resetTimers();
    });
  }

  void _toggleMode() {
    setState(() {
      _stopClock();
      _gameMode =
          _gameMode == _GameMode.vsAI ? _GameMode.vsHuman : _GameMode.vsAI;
      _aiDifficulty = _AIDifficulty.hard;
      _ai = AiPlayer(maxDepth: _depthFor(_AIDifficulty.hard));
      _state = GameState.initial();
      _isAiThinking = false;
      _resetTimers();
    });
  }

  void _reset() {
    _stopClock();
    setState(() {
      _state = GameState.initial();
      _isAiThinking = false;
      _resetTimers();
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

    if (_gameMode == _GameMode.vsAI) {
      if (_state.currentPlayer == Piece.white) {
        _stopClock();
        _aiMove();
      } else {
        _startClock();
      }
    } else {
      _switchClock();
    }
  }

  void _showTutorial() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TutorialScreen()),
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
            icon: const Icon(Icons.timer_outlined),
            tooltip: 'Timer: ${_timerLabel(_timerOption)}',
            onPressed: _cycleTimer,
          ),
          if (_gameMode == _GameMode.vsAI)
            IconButton(
              icon: const Icon(Icons.auto_awesome),
              tooltip: 'Difficulty: ${_difficultyLabel(_aiDifficulty)}',
              onPressed: _cycleDifficulty,
            ),
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
          const SizedBox(height: 12),
          _ScoreRow(
            blackScore: _state.blackScore,
            whiteScore: _state.whiteScore,
            currentPlayer: _state.currentPlayer,
            isAiThinking: _isAiThinking,
            blackTime: _timerOption != _TimerOption.off ? _blackTime : null,
            whiteTime: _timerOption != _TimerOption.off ? _whiteTime : null,
          ),
          const SizedBox(height: 12),
          if (_timerOption != _TimerOption.off && !_state.isGameOver)
            _TimerIndicator(
              player: _state.currentPlayer,
              isAiThinking: _isAiThinking,
              isTwoPlayer: _gameMode == _GameMode.vsHuman,
              difficultyLabel: _gameMode == _GameMode.vsAI
                  ? _difficultyLabel(_aiDifficulty)
                  : null,
            ),
          if (_state.isGameOver)
            _GameOverBanner(winner: _state.winner, onReset: _reset)
          else if (_timerOption == _TimerOption.off)
            _TurnIndicator(
              player: _state.currentPlayer,
              isAi: _isAiThinking,
              isTwoPlayer: _gameMode == _GameMode.vsHuman,
              difficultyLabel: _gameMode == _GameMode.vsAI && !_isAiThinking
                  ? _difficultyLabel(_aiDifficulty)
                  : null,
            ),
          const SizedBox(height: 8),
          Expanded(
            child: Center(
              child: BoardWidget(state: _state, onTap: _handleTap),
            ),
          ),
          const SizedBox(height: 12),
          _buildBottomBar(),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final canPass = _state.validMoves.isEmpty &&
        !_state.isGameOver &&
        !_isAiThinking;
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
          onTap: canPass ? _passTurn : null,
        ),
      ],
    );
  }
}

// ---- Score Row ----

class _ScoreRow extends StatelessWidget {
  final int blackScore;
  final int whiteScore;
  final Piece currentPlayer;
  final bool isAiThinking;
  final Duration? blackTime;
  final Duration? whiteTime;

  const _ScoreRow({
    required this.blackScore,
    required this.whiteScore,
    required this.currentPlayer,
    required this.isAiThinking,
    this.blackTime,
    this.whiteTime,
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
            remainingTime: blackTime,
          ),
          const SizedBox(width: 24),
          _ScoreChip(
            piece: Piece.white,
            score: whiteScore,
            isActive: currentPlayer == Piece.white && !isAiThinking,
            remainingTime: whiteTime,
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
  final Duration? remainingTime;

  const _ScoreChip({
    required this.piece,
    required this.score,
    required this.isActive,
    this.remainingTime,
  });

  @override
  Widget build(BuildContext context) {
    final hasTimer = remainingTime != null;

    String timeStr = '';
    Color? timeColor;
    if (hasTimer) {
      final secs = remainingTime!.inSeconds;
      final m = secs ~/ 60;
      final s = secs % 60;
      timeStr = '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
      timeColor = secs <= 10
          ? const Color(0xFFe94560)
          : secs <= 30
              ? const Color(0xFFFFAA44)
              : Colors.white54;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                piece.label,
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.white,
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
          if (hasTimer) ...[
            const SizedBox(height: 4),
            Text(
              timeStr,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'monospace',
                color: timeColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ---- Timer Indicator ----

class _TimerIndicator extends StatelessWidget {
  final Piece player;
  final bool isAiThinking;
  final bool isTwoPlayer;
  final String? difficultyLabel;

  const _TimerIndicator({
    required this.player,
    required this.isAiThinking,
    required this.isTwoPlayer,
    this.difficultyLabel,
  });

  @override
  Widget build(BuildContext context) {
    final label = isAiThinking
        ? difficultyLabel != null
            ? 'AI thinking... ($difficultyLabel)'
            : 'AI thinking...'
        : isTwoPlayer
            ? "${player == Piece.black ? "Black" : "White"}'s clock"
            : difficultyLabel != null
                ? "Your clock ($difficultyLabel)"
                : "Your clock";
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF16213e),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.timer,
              size: 14,
              color: Colors.white.withAlpha(180),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---- Turn Indicator ----

class _TurnIndicator extends StatelessWidget {
  final Piece player;
  final bool isAi;
  final bool isTwoPlayer;
  final String? difficultyLabel;

  const _TurnIndicator({
    required this.player,
    required this.isAi,
    required this.isTwoPlayer,
    this.difficultyLabel,
  });

  @override
  Widget build(BuildContext context) {
    final label = isAi
        ? difficultyLabel != null
            ? 'AI thinking... ($difficultyLabel)'
            : 'AI thinking...'
        : isTwoPlayer
            ? "${player == Piece.black ? "Black" : "White"}'s turn"
            : difficultyLabel != null
                ? "Your turn ($difficultyLabel)"
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

// ---- Game Over Banner ----

class _GameOverBanner extends StatelessWidget {
  final Piece? winner;
  final VoidCallback onReset;

  const _GameOverBanner({required this.winner, required this.onReset});

  @override
  Widget build(BuildContext context) {
    final text = winner == null
        ? "It's a Draw!"
        : '${winner == Piece.black ? "Black" : "White"} Wins!';

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
          const Icon(Icons.emoji_events, color: Colors.white, size: 22),
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

// ---- Action Button ----

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
    final disabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: disabled
              ? const Color(0xFF16213e).withAlpha(80)
              : const Color(0xFF16213e),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: disabled ? Colors.white10 : Colors.white24,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: disabled ? Colors.white30 : Colors.white70,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: disabled ? Colors.white30 : Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
