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

  Future<void> scheduleWaterReminder({required int intervalHours}) async {
    String localTimeZone = await AwesomeNotifications().getLocalTimeZoneIdentifier();
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 10, 
        channelKey: waterChannelKey,
        title: 'Thời gian uống nước!',
        body: 'Đã đến lúc bổ sung nước cho cơ thể rồi bạn ơi. Cùng uống một cốc nước nhé!',
        notificationLayout: NotificationLayout.Default,
        category: NotificationCategory.Reminder,
        wakeUpScreen: true, 
      ),

      actionButtons: [
        NotificationActionButton(
          key: 'DRANK_WATER',
          label: 'Đã uống nước!',
          actionType: ActionType.SilentAction,
        ),
      ],
      
      schedule: NotificationInterval(
        interval: Duration(seconds: 10), 
        timeZone: localTimeZone,
        repeats: true,
        preciseAlarm: true, 
        allowWhileIdle: true, 
      ),
    );
  }

  Future<void> cancelAllReminders() async {
    await AwesomeNotifications().cancelAll();
  }
}