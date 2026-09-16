import 'package:flutter/material.dart';
import '../models/voice_participant_model.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';

class VoiceProvider extends ChangeNotifier {
  List<VoiceParticipantModel> _participants = [];
  String? _channelId;
  bool _isMuted = false;
  bool _isDeafened = false;
  bool _isSpeaking = false;
  bool _isConnected = false;

  List<VoiceParticipantModel> get participants => _participants;
  String? get channelId => _channelId;
  bool get isMuted => _isMuted;
  bool get isDeafened => _isDeafened;
  bool get isSpeaking => _isSpeaking;
  bool get isConnected => _isConnected;

  VoiceProvider() {
    _initSocketListeners();
  }

  void _initSocketListeners() {
    SocketService().onVoiceJoined((data) {
      if (data != null && data is Map<String, dynamic>) {
        final p = VoiceParticipantModel.fromJson(data);
        if (p.channelId == _channelId) {
          _participants.removeWhere((item) => item.userId == p.userId);
          _participants.add(p);
          notifyListeners();
        }
      }
    });

    SocketService().onVoiceLeft((data) {
      if (data != null && data is Map<String, dynamic>) {
        final userId = data['userId'] as String?;
        if (userId != null) {
          _participants.removeWhere((item) => item.userId == userId);
          notifyListeners();
        }
      }
    });

    SocketService().onVoiceMuteUpdated((data) {
      if (data != null && data is Map<String, dynamic>) {
        final userId = data['userId'] as String?;
        final isMuted = data['is_muted'] == true;
        if (userId != null) {
          final idx = _participants.indexWhere((p) => p.userId == userId);
          if (idx != -1) {
            _participants[idx] = _participants[idx].copyWith(
              isMuted: isMuted,
              statusText: isMuted ? 'Muted' : 'Listening',
            );
            notifyListeners();
          }
        }
      }
    });

    SocketService().onVoiceSpeakingUpdated((data) {
      if (data != null && data is Map<String, dynamic>) {
        final userId = data['userId'] as String?;
        final isSpeaking = data['is_speaking'] == true;
        if (userId != null) {
          final idx = _participants.indexWhere((p) => p.userId == userId);
          if (idx != -1) {
            _participants[idx] = _participants[idx].copyWith(
              isSpeaking: isSpeaking,
              statusText: isSpeaking ? 'Speaking...' : 'Listening',
            );
            notifyListeners();
          }
        }
      }
    });
  }

  Future<void> loadParticipants(String channelId) async {
    _channelId = channelId;
    try {
      final res = await ApiService().get('/voice/$channelId');
      if (res != null && res['participants'] != null) {
        _participants = (res['participants'] as List)
            .map((p) => VoiceParticipantModel.fromJson(p as Map<String, dynamic>))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading voice participants: $e');
    }
  }

  Future<void> joinVoice(String channelId) async {
    _channelId = channelId;
    _isConnected = true;
    notifyListeners();

    try {
      await ApiService().post('/voice/$channelId/join');
      await loadParticipants(channelId);
    } catch (e) {
      debugPrint('Error joining voice: $e');
    }
  }

  Future<void> leaveVoice() async {
    if (_channelId == null) return;
    final chId = _channelId!;
    _isConnected = false;
    _channelId = null;
    notifyListeners();

    try {
      await ApiService().post('/voice/$chId/leave');
    } catch (e) {
      debugPrint('Error leaving voice: $e');
    }
  }

  Future<void> toggleMute() async {
    if (_channelId == null) return;
    _isMuted = !_isMuted;
    notifyListeners();

    try {
      final res = await ApiService().post('/voice/$_channelId/toggle-mute');
      if (res != null && res['is_muted'] != null) {
        _isMuted = res['is_muted'] as bool;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error toggling mute: $e');
    }
  }

  void toggleDeafen() {
    _isDeafened = !_isDeafened;
    notifyListeners();
  }

  Future<void> toggleSpeaking() async {
    if (_channelId == null) return;
    _isSpeaking = !_isSpeaking;
    notifyListeners();

    try {
      await ApiService().post('/voice/$_channelId/speaking', {'is_speaking': _isSpeaking});
    } catch (e) {
      debugPrint('Error toggling speaking: $e');
    }
  }
}
