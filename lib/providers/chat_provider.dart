import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';

class ChatProvider extends ChangeNotifier {
  List<MessageModel> _messages = [];
  String? _activeChannelId;
  bool _isLoading = false;

  List<MessageModel> get messages => _messages;
  String? get activeChannelId => _activeChannelId;
  bool get isLoading => _isLoading;

  ChatProvider() {
    _initSocketListeners();
  }

  void _initSocketListeners() {
    SocketService().onNewMessage((data) {
      if (data != null && data is Map<String, dynamic>) {
        final newMsg = MessageModel.fromJson(data);
        if (newMsg.channelId == _activeChannelId) {
          // Avoid duplicate
          if (!_messages.any((m) => m.id == newMsg.id)) {
            _messages.add(newMsg);
            notifyListeners();
          }
        }
      }
    });

    SocketService().onReactionUpdated((data) {
      if (data != null && data is Map<String, dynamic>) {
        final msgId = data['message_id'] as String?;
        final rawReactions = data['reactions'] as List<dynamic>?;

        if (msgId != null && rawReactions != null) {
          final updatedReactions = rawReactions
              .map((r) => MessageReaction.fromJson(r as Map<String, dynamic>))
              .toList();

          final index = _messages.indexWhere((m) => m.id == msgId);
          if (index != -1) {
            _messages[index] = _messages[index].copyWith(reactions: updatedReactions);
            notifyListeners();
          }
        }
      }
    });
  }

  Future<void> loadChannel(String channelId) async {
    if (_activeChannelId != null) {
      SocketService().leaveChannel(_activeChannelId!);
    }

    _activeChannelId = channelId;
    _isLoading = true;
    _messages = [];
    notifyListeners();

    SocketService().joinChannel(channelId);

    try {
      final res = await ApiService().get('/channels/$channelId/messages');
      if (res != null && res['messages'] != null) {
        _messages = (res['messages'] as List)
            .map((m) => MessageModel.fromJson(m as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('Error loading channel messages: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendMessage(String text) async {
    if (_activeChannelId == null || text.trim().isEmpty) return false;

    try {
      final res = await ApiService().post('/channels/$_activeChannelId/messages', {
        'content': text.trim(),
      });

      if (res != null && res['message'] != null) {
        final newMsg = MessageModel.fromJson(res['message']);
        if (!_messages.any((m) => m.id == newMsg.id)) {
          _messages.add(newMsg);
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error sending message: $e');
      return false;
    }
  }

  Future<void> toggleReaction(String messageId, String emoji) async {
    try {
      final res = await ApiService().post('/channels/messages/$messageId/reactions', {
        'emoji': emoji,
      });

      if (res != null && res['reactions'] != null) {
        final updatedReactions = (res['reactions'] as List)
            .map((r) => MessageReaction.fromJson(r as Map<String, dynamic>))
            .toList();

        final index = _messages.indexWhere((m) => m.id == messageId);
        if (index != -1) {
          _messages[index] = _messages[index].copyWith(reactions: updatedReactions);
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error toggling reaction: $e');
    }
  }
}
