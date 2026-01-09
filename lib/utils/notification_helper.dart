import 'dart:async';
import 'package:awesome_notifications/awesome_notifications.dart';

Future<void> scheduleWaterReminder() async {
  // Lấy giờ hiện tại trên máy
  String localTimeZone = await AwesomeNotifications().getLocalTimeZoneIdentifier();

  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: 10, // ID cố định để nếu chạy lại nó sẽ update cái cũ chứ không tạo cái mới trùng lặp
      channelKey: 'water_reminder',
      title: 'Đã đến giờ uống nước rồi! 💧',
      body: 'Hãy bổ sung 200ml nước để cơ thể khỏe mạnh nhé.',
      notificationLayout: NotificationLayout.Default,
      category: NotificationCategory.Reminder,
    ),
    
    // Lên lịch: Lặp lại mỗi giây/phút/giờ
    schedule: NotificationInterval(
      interval: Duration(seconds: 3600), // Sử dụng Duration thay vì int
      timeZone: localTimeZone,
      repeats: true, // Lặp lại mãi mãi
      allowWhileIdle: true, // Chạy cả khi máy đang nghỉ
    ),

    // Thêm nút bấm hành động (Tính năng hay nhất của Awesome Notifications)
    actionButtons: [
      NotificationActionButton(
        key: 'DRANK_WATER',
        label: 'Đã uống 200ml',
        actionType: ActionType.SilentAction, // Bấm xong không cần mở app lên, xử lý ngầm
      ),
      NotificationActionButton(
        key: 'LATER',
        label: 'Để sau 15p',
        actionType: ActionType.SilentBackgroundAction,
      ),
    ],
  );
}