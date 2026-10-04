import 'dart:convert';
import 'package:http/http.dart' as http;
import 'server_config.dart';

class ApiClient {
  Future<List<Map<String, dynamic>>> leaderboard({String game = 'reversi'}) async {
    final res = await http.get(Uri.parse('$kHttpBase/api/leaderboard?game=$game'));
    if (res.statusCode != 200) throw Exception('leaderboard failed');
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    return (body['entries'] as List).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> openRooms() async {
    final res = await http.get(Uri.parse('$kHttpBase/api/rooms'));
    if (res.statusCode != 200) throw Exception('rooms failed');
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    return (body['open'] as List).cast<Map<String, dynamic>>();
  }
}
