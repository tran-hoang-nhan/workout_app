import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification.dart';
import './health_provider.dart';
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
        message: 'Hãy bổ sung 250ml nước để cơ thể khỏe mạnh và tràn đầy năng lượng nhé.',
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
      NotificationModel(
        id: '2',
        title: 'Nhắc nhở uống nước',
        message: 'Đã 1 giờ trôi qua, hãy bổ sung cho mình một cốc nước nhé.',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        type: NotificationType.water,
        isRead: true,
      ),
    ];
  }

  Future<void> drinkWater(String id) async {
    // 1. Mark notification as read with timestamp
    final now = DateTime.now();
    state = [
      for (final notification in state)
        if (notification.id == id)
          notification.copyWith(isRead: true, drankAt: now)
        else
          notification,
    ];

    // 2. Add water to health progress using ProgressUserController
    try {
      // Call the controller's updateWater method which handles user session, repo call and invalidation
      await ref.read(progressUserControllerProvider.notifier).updateWater(250);

      // Additional refresh for related providers
      ref.invalidate(progressWeeklyProvider);
      ref.invalidate(healthDataProvider);
    } catch (e) {
      logger.e('Error updating water progress from notification: $e');
    }
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
