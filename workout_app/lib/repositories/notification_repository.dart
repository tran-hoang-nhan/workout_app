import 'package:shared/shared.dart';
import '../services/api_client.dart';

class NotificationRepository {
  final ApiClient _apiClient;

  NotificationRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<List<NotificationModel>> getNotifications(String userId) async {
    return _apiClient.getNotifications(userId);
  }

  // Local notifications are handled by NotificationService, 
  // but we can add sync logic here if needed.
}
