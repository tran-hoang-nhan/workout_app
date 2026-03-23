import 'package:shared/shared.dart';
import 'package:supabase/supabase.dart';

/// Repository responsible for user notifications.
class NotificationRepository {
  /// Creates a notification repository backed by Supabase.
  NotificationRepository(this._supabase);
  final SupabaseClient _supabase;

  /// Gets all notifications for a user.
  Future<List<NotificationModel>> getNotifications(String userId) async {
    final response = await _supabase
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return (response as List<dynamic>)
        .map(
          (e) => NotificationModel.fromJson(
            Map<String, dynamic>.from(e as Map),
          ),
        )
        .toList();
  }

  /// Marks a notification as read.
  Future<void> markAsRead(String notificationId) async {
    await _supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('id', notificationId);
  }

  /// Saves a notification to the database.
  Future<void> saveNotification(NotificationModel notification, String userId) async {
    final data = notification.toJson();
    data['user_id'] = userId;
    await _supabase.from('notifications').insert(data);
  }
}
