import 'dart:async';
import 'dart:convert';

import 'package:tasker/core/constants/api_constants.dart';
import 'package:tasker/core/error/exceptions.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

abstract class ItemWebsocketDataSource {
  Stream<dynamic> connectAndListen();
  void dispose();
}

class ItemWebSocketDataSourceImpl implements ItemWebsocketDataSource {
  WebSocketChannel? _channel;
  StreamController<dynamic>? _streamController;

  @override
  Stream<dynamic> connectAndListen() {
    _streamController?.close();
    _streamController = StreamController<dynamic>.broadcast();
    try {
      // connect to the websocket
      _channel = WebSocketChannel.connect(Uri.parse(ApiConstants.wsBaseUrl));
      _channel!.stream.listen(
        (message) {
          try {
            final decodedMessage = jsonDecode(message as String);
            _streamController?.add(decodedMessage);
          } catch (e) {
            _streamController?.addError(
              NetworkException('Error processing message: $e'),
            );
          }
        },
        onError: (error) {
          _streamController?.addError(
            NetworkException('WebSocket error: $error'),
          );
        },
        onDone: () {
          _streamController?.close();
        },
      );
    } catch (e) {
      _streamController?.addError(
        NetworkException('WebSocket connection error: $e'),
      );
      _streamController?.close();
    }
    return _streamController!.stream;
  }

  @override
  void dispose() {
    _channel?.sink.close();
    _streamController?.close();
  }
}
