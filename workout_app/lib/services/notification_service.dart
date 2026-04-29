import 'package:awesome_notifications/awesome_notifications.dart';

class NotificationService {
  static const String waterChannelKey = 'water_reminder';
  static const String waterChannelGroupKey = 'water_channel_group';

  Future<void> init() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
  }

  Future<void> scheduleWaterReminder({required int intervalHours, String wakeTime = '07:00', String sleepTime = '23:00', bool isActive = true,}) async {
    String localTimeZone = await AwesomeNotifications().getLocalTimeZoneIdentifier();
    final safeInterval = intervalHours > 0 ? intervalHours : 2;
    await AwesomeNotifications().cancel(10);
    final wakeHour = int.tryParse(wakeTime.split(':')[0]) ?? 7;
    final sleepHour = int.tryParse(sleepTime.split(':')[0]) ?? 23;
    final now = DateTime.now();
    final nowHour = now.hour;

    if (!isActive) {
      DateTime nextWake = DateTime(now.year, now.month, now.day, wakeHour, 0);
      if (nowHour >= sleepHour) {
        nextWake = nextWake.add(const Duration(days: 1));
      }
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 10,
          channelKey: waterChannelKey,
          title: 'Chào buổi sáng! 💧',
          body: 'Đã đến lúc bắt đầu ngày mới với một cốc nước rồi!',
          notificationLayout: NotificationLayout.Default,
          category: NotificationCategory.Reminder,
        ),
        schedule: NotificationCalendar(
          hour: wakeHour,
          minute: 0,
          second: 0,
          millisecond: 0,
          repeats: true,
          allowWhileIdle: true,
        ),
      );
      return;
    }

    // 1. Gửi ngay 1 thông báo tức thì để kiểm tra (Background test)
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 11,
        channelKey: waterChannelKey,
        title: 'Kích hoạt thành công! 💧',
        body: 'Thông báo nhắc nước đã được đặt mỗi $safeInterval phút.',
        notificationLayout: NotificationLayout.Default,
        category: NotificationCategory.Reminder,
      ),
    );

    // 2. Lập lịch định kỳ theo khoảng thời gian demo
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 10,
        channelKey: waterChannelKey,
        title: 'Thời gian uống nước! 💧',
        body: 'Đã đến lúc bổ sung nước rồi. Hãy uống một cốc nước để cơ thể khỏe mạnh nhé!',
        notificationLayout: NotificationLayout.Default,
        category: NotificationCategory.Reminder,
        wakeUpScreen: true,
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'DRANK_WATER',
          label: 'Đã uống',
          actionType: ActionType.Default,
        ),
      ],
      schedule: NotificationInterval(
        interval: Duration(minutes: safeInterval),
        timeZone: localTimeZone,
        repeats: true,
        allowWhileIdle: true,
      ),
    );
  }

  Future<void> cancelAllReminders() async {
    await AwesomeNotifications().cancelAll();
  }

  Future<void> cancelAllWaterReminders() async {
    await AwesomeNotifications().cancel(10);
  }
}
