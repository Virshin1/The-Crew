import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/api_service.dart';

class NotificationProvider extends ChangeNotifier {
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String _activeFilter = 'All';

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String get activeFilter => _activeFilter;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> fetchNotifications({String? filter}) async {
    if (filter != null) {
      _activeFilter = filter;
    }
    _isLoading = true;
    notifyListeners();

    try {
      String query = '';
      if (_activeFilter != 'All') {
        query = '?type=${_activeFilter.toLowerCase()}';
      }

      final res = await ApiService().get('/notifications$query');
      if (res != null && res['notifications'] != null) {
        _notifications = (res['notifications'] as List)
            .map((n) => NotificationModel.fromJson(n as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await ApiService().post('/notifications/$id/read');
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        final n = _notifications[index];
        _notifications[index] = NotificationModel(
          id: n.id,
          userId: n.userId,
          actorId: n.actorId,
          type: n.type,
          title: n.title,
          body: n.body,
          timeDisplay: n.timeDisplay,
          isRead: true,
          actorUsername: n.actorUsername,
          actorDisplayName: n.actorDisplayName,
          actorAvatar: n.actorAvatar,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error marking notification read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await ApiService().post('/notifications/read-all');
      _notifications = _notifications.map((n) => NotificationModel(
        id: n.id,
        userId: n.userId,
        actorId: n.actorId,
        type: n.type,
        title: n.title,
        body: n.body,
        timeDisplay: n.timeDisplay,
        isRead: true,
        actorUsername: n.actorUsername,
        actorDisplayName: n.actorDisplayName,
        actorAvatar: n.actorAvatar,
      )).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error marking all read: $e');
    }
  }
}

