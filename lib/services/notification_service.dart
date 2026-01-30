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
    debugPrint("🕒 Scheduling water reminder every $intervalHours hours (Timezone: $localTimeZone)");
    debugPrint("💤 Active hours: $wakeTime - $sleepTime");

    bool created = await AwesomeNotifications().createNotification(
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
        // Reverting to real interval
        interval: Duration(hours: intervalHours), 
        timeZone: localTimeZone,
        repeats: true,
      ),
    );
    
    if (created) {
      debugPrint("✅ Water reminder scheduled successfully for every $intervalHours hours");
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