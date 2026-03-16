import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';
import 'health_base_provider.dart';
import './progress_user_provider.dart';
import '../utils/logger.dart';

final notificationProvider = NotifierProvider<NotificationNotifier, List<NotificationModel>>(() {
  return NotificationNotifier();
});

final unreadNotificationCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationProvider);
  return notifications.where((n) => !n.isRead).length;
});

class NotificationNotifier extends Notifier<List<NotificationModel>> {
  @override
  List<NotificationModel> build() {
    return _loadMockNotifications();
  }

  List<NotificationModel> _loadMockNotifications() {
    return [
      NotificationModel(
        id: 'w1',
        title: 'Đã đến giờ uống nước! 💧',
        message:
            'Hãy bổ sung 250ml nước để cơ thể khỏe mạnh và tràn đầy năng lượng nhé.',
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        type: NotificationType.water,
        isRead: false,
      ),
      NotificationModel(
        id: '1',
        title: 'Bắt đầu ngày mới!',
        message: 'Đừng quên lịch tập hôm nay bạn nhé. Đã đến lúc Cardio rồi!',
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        type: NotificationType.workout,
        isRead: false,
      ),
    ];
  }

  Future<void> drinkWater(String id) async {
    final now = DateTime.now();
    state = [
      for (final notification in state)
        if (notification.id == id)
          notification.copyWith(isRead: true, drankAt: now)
        else
          notification,
    ];
    try {
      await ref.read(progressUserControllerProvider.notifier).updateWater(250);
      ref.invalidate(progressWeeklyProvider);
      ref.invalidate(healthDataProvider);
    } catch (e) {
      logger.e('Error updating water progress from notification: $e');
    }
  }

  /// Called when water is added globally (e.g., from the WaterCard '+')
  /// to ensure any active water notifications and their UI cards also reflect this.
  void handleGlobalWaterIntake() {
    final now = DateTime.now();
    // Find the latest water notification that hasn't been marked as "drank" yet
    // and mark it as drank to trigger the countdown UI.
    bool updated = false;
    state = [
      for (final notification in state)
        if (!updated &&
            notification.type == NotificationType.water &&
            notification.drankAt == null)
          () {
            updated = true;
            return notification.copyWith(isRead: true, drankAt: now);
          }()
        else
          notification,
    ];
  }

  void markAsRead(String id) {
    state = [
      for (final notification in state)
        if (notification.id == id)
          notification.copyWith(isRead: true)
        else
          notification,
    ];
  }

  void markAllAsRead() {
    state = [
      for (final notification in state) notification.copyWith(isRead: true),
    ];
  }

  void addNotification(NotificationModel notification) {
    state = [notification, ...state];
  }

  void deleteNotification(String id) {
    state = state.where((n) => n.id != id).toList();
  }
}
