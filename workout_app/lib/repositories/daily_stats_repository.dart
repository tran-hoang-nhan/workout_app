import 'package:shared/shared.dart';
import '../services/api_client.dart';

class DailyStatsRepository {
  final ApiClient _apiClient;
  DailyStatsRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  Future<DailyStats?> getDailyStats(String userId, DateTime date) async {
    return _apiClient.getDailyStats(userId, date);
  }

  Future<List<DailyStats>> getStatsRange(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    // For now returning empty or proxying
    return [];
  }

  Future<void> updateActivityStats({
    required String userId,
    required DateTime date,
    double? addEnergy,
    int? addMinutes,
    double? distance,
  }) async {
    final existing = await getDailyStats(userId, date);
    final newStats = DailyStats(
      userId: userId,
      date: date,
      activeEnergyBurned:
          (existing?.activeEnergyBurned ?? 0) + (addEnergy ?? 0),
      activeMinutes: (existing?.activeMinutes ?? 0) + (addMinutes ?? 0),
      distanceMeters: (existing?.distanceMeters ?? 0) + (distance ?? 0),
    );
    await _apiClient.saveDailyStats(newStats);
  }
}
