import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:io';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
      },
    );
  }

  Future<void> scheduleWaterReminder({required int intervalHours}) async {
    if (!kIsWeb && Platform.isAndroid) {
      // Need to request permission for Android 13+
      await _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>() ?.requestNotificationsPermission();
    }

    await _notificationsPlugin.zonedSchedule(
      0,
      'Thời gian uống nước!',
      'Đã đến lúc bổ sung nước cho cơ thể rồi bạn ơi. Cùng uống một cốc nước nhé!',
      tz.TZDateTime.now(tz.local).add(Duration(hours: intervalHours)),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'water_reminder_channel',
          'Water Reminders',
          channelDescription: 'Reminders to drink water periodically',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // This makes it repeat daily at that time if we want
    );
  }

  Future<void> cancelAllReminders() async {
    await _notificationsPlugin.cancelAll();
  }
}
