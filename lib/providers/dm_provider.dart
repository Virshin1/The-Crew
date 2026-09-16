import 'package:flutter/material.dart';
import '../models/dm_model.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';

class DmProvider extends ChangeNotifier {
  List<DmConversationModel> _conversations = [];
  List<UserModel> _activeNow = [];
  List<DmMessageModel> _currentMessages = [];
  UserModel? _currentPartner;
  bool _isLoading = false;

  List<DmConversationModel> get conversations => _conversations;
  List<UserModel> get activeNow => _activeNow;
  List<DmMessageModel> get currentMessages => _currentMessages;
  UserModel? get currentPartner => _currentPartner;
  bool get isLoading => _isLoading;

  DmProvider() {
    SocketService().onNewDm((data) {
      if (data != null && data is Map<String, dynamic>) {
        final newDm = DmMessageModel.fromJson(data);
        if (_currentPartner != null &&
            (newDm.senderId == _currentPartner!.id || newDm.receiverId == _currentPartner!.id)) {
          if (!_currentMessages.any((m) => m.id == newDm.id)) {
            _currentMessages.add(newDm);
            notifyListeners();
          }
        }
        fetchConversations();
      }
    });
  }

  Future<void> fetchConversations() async {
    try {
      final res = await ApiService().get('/dms');
      if (res != null) {
        if (res['conversations'] != null) {
          _conversations = (res['conversations'] as List)
              .map((c) => DmConversationModel.fromJson(c as Map<String, dynamic>))
              .toList();
        }
        if (res['active_now'] != null) {
          _activeNow = (res['active_now'] as List)
              .map((u) => UserModel.fromJson(u as Map<String, dynamic>))
              .toList();
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching DMs: $e');
    }
  }

  Future<void> loadDmThread(String partnerId) async {
    _isLoading = true;
    _currentMessages = [];
    notifyListeners();

    try {
      final res = await ApiService().get('/dms/$partnerId');
      if (res != null) {
        if (res['partner'] != null) {
          _currentPartner = UserModel.fromJson(res['partner']);
        }
        if (res['messages'] != null) {
          _currentMessages = (res['messages'] as List)
              .map((m) => DmMessageModel.fromJson(m as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('Error loading DM thread: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendDm(String partnerId, String text) async {
    if (text.trim().isEmpty) return false;

    try {
      final res = await ApiService().post('/dms/$partnerId', {'content': text.trim()});
      if (res != null && res['message'] != null) {
        final newDm = DmMessageModel.fromJson(res['message']);
        if (!_currentMessages.any((m) => m.id == newDm.id)) {
          _currentMessages.add(newDm);
          notifyListeners();
        }
        fetchConversations();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error sending DM: $e');
      return false;
    }
  }
}
