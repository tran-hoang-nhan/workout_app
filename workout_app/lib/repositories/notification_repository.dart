import 'package:shared/shared.dart';
import '../api/api_client.dart';

class NotificationRepository {
  final ApiClient _apiClient;
  NotificationRepository({ApiClient? apiClient}): _apiClient = apiClient ?? ApiClient();

  Future<List<NotificationModel>> getNotifications(String userId) async {
    return _apiClient.getNotifications(userId);
  }
}
