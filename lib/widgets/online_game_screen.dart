import 'dart:async';
import 'package:flutter/material.dart';
import '../net/game_socket.dart';
import '../game/board.dart';
import '../game/game_state.dart';
import '../game/piece.dart';
import 'board_widget.dart';

/// Online game screen: renders server-authoritative Reversi state.
class OnlineGameScreen extends StatefulWidget {
  final GameSocket socket;
  final String playerId;
  final String opponentName;
  final Map<String, dynamic>? initialRoom;

  const OnlineGameScreen({
    super.key,
    required this.socket,
    required this.playerId,
    required this.opponentName,
    this.initialRoom,
  });

  @override
  State<OnlineGameScreen> createState() => _OnlineGameScreenState();
}

class _OnlineGameScreenState extends State<OnlineGameScreen> {
  Map<String, dynamic>? _room;
  String? _error;
  late final StreamSubscription _sub;

  @override
  void initState() {
    super.initState();
    _sub = widget.socket.messages.listen((msg) {
      if (!mounted) return;
      if (msg['type'] == 'state') {
        setState(() => _room = msg['room'] as Map<String, dynamic>);
      } else if (msg['type'] == 'error') {
        setState(() => _error = msg['error'] as String?);
      }
    });
    if (widget.initialRoom != null) {
      _room = widget.initialRoom;
    }
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  Piece _playerColor() {
    final players = (_room?['players'] as List?) ?? [];
    for (final p in players) {
      if (p['id'] == widget.playerId) {
        return p['color'] == 'black' ? Piece.black : Piece.white;
      }
    }
    return Piece.black;
  }

  bool get _myTurn {
    final st = _room?['state'] as Map<String, dynamic>?;
    if (st == null) return false;
    final current = st['currentPlayer'] == 'black' ? Piece.black : Piece.white;
    return current == _playerColor() && _room?['status'] == 'active';
  }

  GameState? _toGameState() {
    final st = _room?['state'] as Map<String, dynamic>?;
    if (st == null) return null;
    final board = Board();
    final grid = st['grid'] as List;
    for (var r = 0; r < Board.size; r++) {
      for (var c = 0; c < Board.size; c++) {
        board.grid[r][c] = grid[r][c] == 1
            ? Piece.black
            : grid[r][c] == 2
                ? Piece.white
                : Piece.empty;
      }
    }
    final moves = (st['validMoves'] as List? ?? [])
        .map((m) => [m['row'] as int, m['col'] as int])
        .toList();
    final last = st['lastMove'];
    return GameState(
      board: board,
      currentPlayer: st['currentPlayer'] == 'black' ? Piece.black : Piece.white,
      status: st['status'] == 'won' ? GameStatus.won : GameStatus.playing,
      winner: st['winner'] == null
          ? null
          : st['winner'] == 'black'
              ? Piece.black
              : Piece.white,
      validMoves: moves,
      lastMove: last == null
          ? null
          : [[last['row'] as int, last['col'] as int]],
      blackScore: st['blackScore'] as int,
      whiteScore: st['whiteScore'] as int,
    );
  }

  void _onTap(int row, int col) {
    if (!_myTurn) return;
    widget.socket.send({'type': 'move', 'row': row, 'col': col});
  }

  @override
  Widget build(BuildContext context) {
    final state = _toGameState();
    final status = _room?['status'] as String? ?? 'connecting...';
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        title: const Text('Online Reversi'),
        centerTitle: true,
        backgroundColor: const Color(0xFF16213e),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.flag_outlined),
            tooltip: 'Resign',
            onPressed: () => widget.socket.send({'type': 'resign'}),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          if (state != null) ...[
            Text(
              'Black ${state.blackScore} — ${state.whiteScore} White   ($status)',
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              _myTurn ? 'Your turn (${_playerColor().label})' : 'Opponent\'s turn',
              style: const TextStyle(color: Colors.white54),
            ),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Color(0xFFe94560))),
            Expanded(
              child: Center(
                child: BoardWidget(state: state, onTap: _onTap),
              ),
            ),
            if (state.isGameOver)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  state.winner == null
                      ? 'Draw — game over'
                      : '${state.winner == Piece.black ? "Black" : "White"} wins!',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
          ] else
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
