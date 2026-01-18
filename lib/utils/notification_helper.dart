import 'dart:async';
import 'package:awesome_notifications/awesome_notifications.dart';

Future<void> scheduleWaterReminder() async {
  String localTimeZone = await AwesomeNotifications().getLocalTimeZoneIdentifier();
  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: 10,
      channelKey: 'water_reminder',
      title: 'Đã đến giờ uống nước rồi! 💧',
      body: 'Hãy bổ sung 200ml nước để cơ thể khỏe mạnh nhé.',
      notificationLayout: NotificationLayout.Default,
      category: NotificationCategory.Reminder,
    ),
    
    schedule: NotificationInterval(
      interval: Duration(seconds: 3600),
      timeZone: localTimeZone,
      repeats: true, 
      allowWhileIdle: true, 
    ),

    actionButtons: [
      NotificationActionButton(
        key: 'DRANK_WATER',
        label: 'Đã uống 200ml',
        actionType: ActionType.SilentAction, 
      ),
      NotificationActionButton(
        key: 'LATER',
        label: 'Để sau 15p',
        actionType: ActionType.SilentBackgroundAction,
      ),
    ],
  );
}