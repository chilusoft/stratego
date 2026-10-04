import 'package:flutter/material.dart';
import '../net/api_client.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final _api = ApiClient();
  Future<List<Map<String, dynamic>>>? _future;

  @override
  void initState() {
    super.initState();
    _future = _api.leaderboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        title: const Text('Leaderboard'),
        centerTitle: true,
        backgroundColor: const Color(0xFF16213e),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return const Center(
              child: Text('Could not load leaderboard',
                  style: TextStyle(color: Colors.white54)),
            );
          }
          final entries = snap.data ?? [];
          if (entries.isEmpty) {
            return const Center(
              child: Text('No matches yet',
                  style: TextStyle(color: Colors.white54)),
            );
          }
          return ListView.builder(
            itemCount: entries.length,
            itemBuilder: (_, i) {
              final e = entries[i];
              return ListTile(
                leading: CircleAvatar(child: Text('${i + 1}')),
                title: Text(e['name'] as String? ?? '?',
                    style: const TextStyle(color: Colors.white)),
                subtitle: Text(
                  '${e['wins']}W / ${e['losses']}L / ${e['draws']}D',
                  style: const TextStyle(color: Colors.white54),
                ),
                trailing: Text('${e['rating']}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              );
            },
          );
        },
      ),
    );
  }
}
