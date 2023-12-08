import 'dart:async';

import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketManager {
  static final WebSocketManager _instance = WebSocketManager._internal();
  WebSocketChannel? _channel;
  final _messageController = StreamController<String>.broadcast();

  factory WebSocketManager() {
    return _instance;
  }

  WebSocketManager._internal();

  void connect(String url) {
    _channel = WebSocketChannel.connect(Uri.parse(url));
    _channel?.stream.listen((message) {
      _messageController.add(message);
    });
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
    _messageController.close();
  }

  void sendMessage(String message) {
    _channel?.sink.add(message + "\n");
  }

  Stream<String> get messages => _messageController.stream;

  bool get isConnected => _channel != null && _channel?.closeCode == null;

}
