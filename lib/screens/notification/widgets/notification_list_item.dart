import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../constants/app_constants.dart';
import 'package:shared/shared.dart';
import '../../../providers/notification_provider.dart';
import '../../../providers/health_provider.dart';
import './water_countdown_circle.dart';

class NotificationListItem extends ConsumerWidget {
  final NotificationModel notification;
  const NotificationListItem({super.key, required this.notification});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeStr = _formatDateTime(notification.createdAt);

    Color colorFromHex(String hexString) {
      var hexColor = hexString.toUpperCase().replaceAll('#', '');
      if (hexColor.startsWith('0X')) {
        hexColor = hexColor.substring(2);
      }
      if (hexColor.length == 6) {
        hexColor = 'FF$hexColor';
      }
      return Color(int.parse(hexColor, radix: 16));
    }

    IconData iconFromString(String iconString) {
      switch (iconString) {
        case 'fitness_center':
          return Icons.fitness_center;
        case 'water_drop':
          return Icons.water_drop;
        case 'emoji_events':
          return Icons.emoji_events;
        case 'notifications_active':
          return Icons.notifications_active;
        case 'info':
          return Icons.info;
        default:
          return Icons.notifications;
      }
    }

    final notifColor = colorFromHex(notification.color);
    final notifIcon = iconFromString(notification.icon);

    return GestureDetector(
      onTap: () {
        if (!notification.isRead) {
          ref.read(notificationProvider.notifier).markAsRead(notification.id);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: notification.isRead
              ? AppColors.white
              : AppColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: notification.isRead
                ? AppColors.cardBorder.withValues(alpha: 0.5)
                : AppColors.primary.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: notifColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(notifIcon, color: notifColor, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: AppFontSize.md,
                            fontWeight: notification.isRead
                                ? FontWeight.w600
                                : FontWeight.bold,
                            color: AppColors.black,
                          ),
                        ),
                      ),
                      Text(
                        timeStr,
                        style: TextStyle(
                          fontSize: AppFontSize.xs,
                          color: AppColors.grey.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: const TextStyle(
                      fontSize: AppFontSize.sm,
                      color: AppColors.grey,
                      height: 1.4,
                    ),
                  ),
                  _buildActionArea(context, ref),
                ],
              ),
            ),
            if (!notification.isRead && notification.drankAt == null)
              Container(
                margin: const EdgeInsets.only(left: AppSpacing.sm, top: 12),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionArea(BuildContext context, WidgetRef ref) {
    if (notification.type != NotificationType.water) {
      return const SizedBox.shrink();
    }

    if (notification.drankAt != null) {
      final healthDataAsync = ref.watch(healthDataProvider);

      return healthDataAsync.when(
        data: (healthData) {
          final interval = healthData?.waterReminderInterval ?? 1;
          final duration = Duration(hours: interval);
          final now = DateTime.now();
          final limit = notification.drankAt!.add(duration);

          if (now.isBefore(limit)) {
            return Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              child: WaterCountdownCircle(
                startTime: notification.drankAt!,
                duration: duration,
              ),
            );
          }
          return const SizedBox.shrink();
        },
        loading: () => const SizedBox.shrink(),
        error: (_, _) => const SizedBox.shrink(),
      );
    }

    // Nút "Đã uống" sẽ hiển thị cho đến khi người dùng bấm "Đã uống"
    // Việc đánh dấu thông báo là "Đã đọc" (isRead) sẽ KHÔNG làm mất nút này
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: ElevatedButton.icon(
        onPressed: () =>
            ref.read(notificationProvider.notifier).drinkWater(notification.id),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 8,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.shopping_basket, size: 16),
        label: const Text(
          'Đã uống',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) return 'Vừa xong';
    if (difference.inMinutes < 60) return '${difference.inMinutes} phút trước';
    if (difference.inHours < 24) return '${difference.inHours} giờ trước';
    if (difference.inDays < 7) return '${difference.inDays} ngày trước';
    return DateFormat('dd/MM/yyyy').format(dateTime);
  }
}
