import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'api_service.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  io.Socket? _socket;
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  void connect(String? token) {
    if (_socket != null && _isConnected) return;

    final uri = ApiService.socketUrl;
    debugPrint('🔌 Connecting to Socket.io: $uri');

    _socket = io.io(
      uri,
      io.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .disableAutoConnect()
          .setAuth({'token': token})
          .build(),
    );

    _socket?.onConnect((_) {
      _isConnected = true;
      debugPrint('⚡ Socket.io connected successfully');
    });

    _socket?.onDisconnect((_) {
      _isConnected = false;
      debugPrint('🔌 Socket.io disconnected');
    });

    _socket?.onConnectError((err) {
      _isConnected = false;
      debugPrint('⚠️ Socket.io connection error: $err');
    });

    _socket?.connect();
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _isConnected = false;
  }

  void joinChannel(String channelId) {
    _socket?.emit('channel:join', {'channelId': channelId});
  }

  void leaveChannel(String channelId) {
    _socket?.emit('channel:leave', {'channelId': channelId});
  }

  void onNewMessage(Function(dynamic data) callback) {
    _socket?.off('message:new');
    _socket?.on('message:new', callback);
  }

  void onReactionUpdated(Function(dynamic data) callback) {
    _socket?.off('reaction:updated');
    _socket?.on('reaction:updated', callback);
  }

  void onNewDm(Function(dynamic data) callback) {
    _socket?.off('dm:new');
    _socket?.on('dm:new', callback);
  }

  void onVoiceJoined(Function(dynamic data) callback) {
    _socket?.off('voice:joined');
    _socket?.on('voice:joined', callback);
  }

  void onVoiceLeft(Function(dynamic data) callback) {
    _socket?.off('voice:left');
    _socket?.on('voice:left', callback);
  }

  void onVoiceMuteUpdated(Function(dynamic data) callback) {
    _socket?.off('voice:mute_updated');
    _socket?.on('voice:mute_updated', callback);
  }

  void onVoiceSpeakingUpdated(Function(dynamic data) callback) {
    _socket?.off('voice:speaking_updated');
    _socket?.on('voice:speaking_updated', callback);
  }
}
