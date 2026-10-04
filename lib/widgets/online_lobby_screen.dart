import 'dart:async';
import 'package:flutter/material.dart';
import '../net/api_client.dart';
import '../net/game_socket.dart';
import 'online_game_screen.dart';

/// Lobby: create/join/queue for online play.
class OnlineLobbyScreen extends StatefulWidget {
  const OnlineLobbyScreen({super.key});

  @override
  State<OnlineLobbyScreen> createState() => _OnlineLobbyScreenState();
}

class _OnlineLobbyScreenState extends State<OnlineLobbyScreen> {
  final _nameCtl = TextEditingController(text: 'player');
  final _api = ApiClient();
  GameSocket? _socket;
  StreamSubscription? _sub;
  List<Map<String, dynamic>> _openRooms = [];
  String _status = 'Enter a name, then create, queue, or join.';
  String? _playerId;
  bool _opened = false;

  @override
  void dispose() {
    _sub?.cancel();
    _socket?.close();
    _nameCtl.dispose();
    super.dispose();
  }

  void _connect(void Function(GameSocket) onReady) {
    if (_socket != null) {
      onReady(_socket!);
      return;
    }
    final s = GameSocket.connect();
    _socket = s;
    _sub = s.messages.listen((msg) {
      if (!mounted) return;
      switch (msg['type']) {
        case 'room_created':
          _playerId = msg['playerId'] as String?;
          setState(() => _status = 'Room ${msg['roomId']} created — waiting for opponent');
          break;
        case 'matched':
          _playerId = msg['playerId'] as String?;
          _openGame(msg['playerId'] as String? ?? '', s);
          break;
        case 'queued':
          setState(() => _status = 'Queued — waiting for a match...');
          break;
        case 'state':
          final room = msg['room'] as Map<String, dynamic>?;
          if (room != null && room['status'] == 'active' && !_opened) {
            String? pid = _playerId;
            if (pid == null) {
              final players = (room['players'] as List?) ?? [];
              for (final p in players) {
                if (p['name'] == _nameCtl.text) pid = p['id'] as String?;
              }
            }
            if (pid != null) {
              _opened = true;
              _playerId = pid;
              _openGame(pid, s);
            }
          }
          break;
        case 'error':
          setState(() => _status = 'Error: ${msg['error']}');
          break;
      }
    });
    onReady(s);
    _refresh();
  }

  void _openGame(String playerId, GameSocket s) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OnlineGameScreen(
          socket: s,
          playerId: playerId,
          opponentName: '',
        ),
      ),
    );
  }

  Future<void> _refresh() async {
    try {
      final rooms = await _api.openRooms();
      if (mounted) setState(() => _openRooms = rooms);
    } catch (e) {
      if (mounted) setState(() => _status = 'Cannot reach server');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        title: const Text('Online Lobby'),
        centerTitle: true,
        backgroundColor: const Color(0xFF16213e),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameCtl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Your name',
                labelStyle: TextStyle(color: Colors.white54),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _connect((s) => s.send({
                          'type': 'create_room',
                          'name': _nameCtl.text,
                        })),
                    child: const Text('Create room'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _connect((s) => s.send({
                          'type': 'queue_join',
                          'name': _nameCtl.text,
                          'mode': 'reversi',
                        })),
                    child: const Text('Random match'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(_status, style: const TextStyle(color: Colors.white54)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Open rooms',
                    style: TextStyle(color: Colors.white, fontSize: 18)),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: _refresh,
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _openRooms.length,
                itemBuilder: (_, i) {
                  final r = _openRooms[i];
                  final players = (r['players'] as List?) ?? [];
                  final host = players.isNotEmpty ? players.first['name'] : '?';
                  return Card(
                    color: const Color(0xFF16213e),
                    child: ListTile(
                      title: Text('Room ${r['id']} — host: $host',
                          style: const TextStyle(color: Colors.white)),
                      trailing: ElevatedButton(
                        onPressed: () => _connect((s) => s.send({
                              'type': 'join_room',
                              'roomId': r['id'],
                              'name': _nameCtl.text,
                            })),
                        child: const Text('Join'),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
