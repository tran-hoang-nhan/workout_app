import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static const String waterChannelKey = 'water_reminder';
  static const String waterChannelGroupKey = 'water_channel_group';

  Future<void> init() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
  }

  Future<void> scheduleWaterReminder({
    required int intervalHours,
    String wakeTime = '07:00',
    String sleepTime = '23:00',
  }) async {
    String localTimeZone = await AwesomeNotifications().getLocalTimeZoneIdentifier();
    
    // Safeguard to ensure interval is at least 1 hour and not 0
    final safeInterval = intervalHours > 0 ? intervalHours : 2;
    
    debugPrint("🕒 Scheduling water reminder every $safeInterval hours (Requested: $intervalHours) (Timezone: $localTimeZone)");
    debugPrint("💤 Active hours: $wakeTime - $sleepTime");

    // Cancel existing notification with the same ID to ensure clean schedule
    await AwesomeNotifications().cancel(10);

    bool created = await AwesomeNotifications().createNotification(
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
          label: 'Đã uống nước!',
          actionType: ActionType.SilentAction,
        ),
      ],
      
      schedule: NotificationInterval(
        // Use Duration for clarity, ensuring it's in hours
        interval: Duration(hours: safeInterval), 
        timeZone: localTimeZone,
        repeats: true,
        allowWhileIdle: true,
      ),
    );
    
    if (created) {
      debugPrint("✅ Water reminder scheduled successfully for every $safeInterval hours");
    } else {
      debugPrint("⚠️ Schedule returned false.");
    }
  }

  Future<void> sendTestNotification() async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 11,
        channelKey: waterChannelKey,
        title: 'Test Notification',
        body: 'This is a test notification to verify the channel.',
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }

  Future<void> cancelAllReminders() async {
    await AwesomeNotifications().cancelAll();
  }
}