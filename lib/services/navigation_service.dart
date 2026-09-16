import 'package:flutter/foundation.dart';

/// Service managing global navigation bar visibility and toggling
class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  /// Reactive notifier for floating bottom nav bar visibility
  final ValueNotifier<bool> isBottomNavVisible = ValueNotifier<bool>(true);

  void toggleBottomNav() {
    isBottomNavVisible.value = !isBottomNavVisible.value;
  }

  void setBottomNavVisible(bool visible) {
    if (isBottomNavVisible.value != visible) {
      isBottomNavVisible.value = visible;
    }
  }
}
