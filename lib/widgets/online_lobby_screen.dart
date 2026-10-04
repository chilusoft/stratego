import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:js' as js;
import 'package:flutter/material.dart';
import '../auth/google_auth.dart';
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
  final _api = ApiClient();
  GameSocket? _socket;
  StreamSubscription? _sub;
  List<Map<String, dynamic>> _openRooms = [];
  String _status = 'Sign in with Google to play online.';
  String? _playerId;
  String? _accountName;
  bool _authed = false;
  bool _opened = false;

  @override
  void dispose() {
    _sub?.cancel();
    _socket?.close();
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
          // Don't open the screen here — the server immediately follows with
          // a 'state' message, and opening on that guarantees the screen gets
          // the room snapshot instead of racing it.
          _playerId = msg['playerId'] as String?;
          break;
        case 'queued':
          setState(() => _status = 'Queued — waiting for a match...');
          break;
        case 'joined':
          _playerId = msg['playerId'] as String?;
          break;
        case 'authed':
          setState(() {
            _authed = true;
            _accountName = msg['name'] as String?;
            _status = 'Signed in as ${msg['name']}';
          });
          break;
        case 'state':
          final room = msg['room'] as Map<String, dynamic>?;
          if (room != null && room['status'] == 'active' && !_opened) {
            String? pid = _playerId;
            if (pid == null && _accountName != null) {
              final players = (room['players'] as List?) ?? [];
              for (final p in players) {
                if (p['name'] == _accountName) pid = p['id'] as String?;
              }
            }
            if (pid != null) {
              _opened = true;
              _playerId = pid;
              _openGame(pid, s, initialRoom: room);
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

  void _openGame(String playerId, GameSocket s, {Map<String, dynamic>? initialRoom}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OnlineGameScreen(
          socket: s,
          playerId: playerId,
          opponentName: '',
          initialRoom: initialRoom,
        ),
      ),
    );
  }

  Future<void> _signIn() async {
    setState(() => _status = 'Signing in...');
    final token = await GoogleAuth.signIn();
    if (token == null) {
      setState(() => _status = 'Sign-in failed or cancelled.');
      return;
    }
    final loc = await _getLocation();
    final payload = <String, dynamic>{'type': 'auth', 'token': token};
    if (loc != null) {
      payload['lat'] = loc['lat'];
      payload['lon'] = loc['lon'];
    }
    _connect((s) => s.send(payload));
  }

  Future<Map<String, double>?> _getLocation() async {
    try {
      html.window.localStorage.remove('gid_geo');
      js.context.callMethod('__geo_js');
      final deadline = DateTime.now().add(const Duration(seconds: 10));
      String? raw;
      while (DateTime.now().isBefore(deadline)) {
        await Future.delayed(const Duration(milliseconds: 300));
        raw = html.window.localStorage['gid_geo'];
        if (raw != null) break;
      }
      if (raw == null || raw.isEmpty) return null;
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return {'lat': (map['lat'] as num).toDouble(), 'lon': (map['lon'] as num).toDouble()};
    } catch (_) {
      return null;
    }
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
            if (_authed)
              Text(
                'Signed in as ${_accountName ?? 'player'}',
                style: const TextStyle(color: Colors.white70),
              )
            else
              ElevatedButton.icon(
                onPressed: _signIn,
                icon: const Icon(Icons.login),
                label: const Text('Sign in with Google'),
              ),
            const SizedBox(height: 12),
            AbsorbPointer(
              absorbing: !_authed,
              child: Opacity(
                opacity: _authed ? 1.0 : 0.4,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _connect((s) => s.send({
                                  'type': 'create_room',
                                })),
                            child: const Text('Create room'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _connect((s) => s.send({
                                  'type': 'queue_join',
                                  'mode': 'reversi',
                                })),
                            child: const Text('Random match'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
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
