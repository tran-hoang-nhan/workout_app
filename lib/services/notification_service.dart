import 'package:awesome_notifications/awesome_notifications.dart';

class NotificationService {
  // Key trùng với main.dart
  static const String waterChannelKey = 'water_reminder';
  static const String waterChannelGroupKey = 'water_channel_group';

  /// Hàm init này có thể gọi ở main hoặc home
  Future<void> init() async {
    // Xin quyền ngay khi init service (tùy chọn, hoặc để lúc bấm nút mới xin)
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
  }

  Future<void> scheduleWaterReminder({required int intervalHours}) async {
    // Lấy múi giờ hiện tại của máy user
    String localTimeZone = await AwesomeNotifications().getLocalTimeZoneIdentifier();

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 10, 
        channelKey: waterChannelKey,
        title: 'Thời gian uống nước!',
        body: 'Đã đến lúc bổ sung nước cho cơ thể rồi bạn ơi. Cùng uống một cốc nước nhé!',
        notificationLayout: NotificationLayout.Default,
        category: NotificationCategory.Reminder,
        wakeUpScreen: true, // Sáng màn hình khi có thông báo
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'DRANK_WATER',
          label: 'Đã uống nước!',
          actionType: ActionType.SilentAction, // SilentAction: Bấm xong xử lý ngầm, không mở App lên
        ),
      ],
      schedule: NotificationInterval(
        interval: Duration(seconds: 10), 
        timeZone: localTimeZone,
        repeats: true,
        preciseAlarm: true, // Đảm bảo giờ giấc chính xác
        allowWhileIdle: true, // Chạy cả khi điện thoại đang ở chế độ nghỉ (Doze mode)
      ),
    );
  }

  Future<void> cancelAllReminders() async {
    await AwesomeNotifications().cancelAll();
  }
}