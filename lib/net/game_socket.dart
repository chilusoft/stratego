import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'server_config.dart';

/// Thin wrapper around the server's WebSocket protocol.
class GameSocket {
  final WebSocketChannel _channel;
  final StreamController<Map<String, dynamic>> _controller =
      StreamController.broadcast();

  GameSocket._(this._channel) {
    _channel.stream.listen(
      (data) {
        try {
          _controller.add(jsonDecode(data as String) as Map<String, dynamic>);
        } catch (_) {}
      },
      onDone: () => _controller.close(),
      onError: _controller.addError,
    );
  }

  factory GameSocket.connect() => GameSocket._(
        WebSocketChannel.connect(Uri.parse(kWsUrl)),
      );

  Stream<Map<String, dynamic>> get messages => _controller.stream;

  void send(Map<String, dynamic> msg) => _channel.sink.add(jsonEncode(msg));

  Future<void> close() => _channel.sink.close();
}
