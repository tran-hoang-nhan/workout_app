import 'package:shared/shared.dart';
import '../services/api_client.dart';

class ProgressUserRepository {
  final ApiClient _apiClient;
  ProgressUserRepository({ApiClient? apiClient}): _apiClient = apiClient ?? ApiClient();

  Future<ProgressUser?> getDailyProgress(String userId, DateTime date) async {
    return _apiClient.getDailyProgress(userId, date);
  }

  Future<List<ProgressUser>> getProgressRange(String userId, DateTime start, DateTime end,) async {
    return [];
  }

  Future<void> updateActivityProgress({required String userId, required DateTime date, int? addWaterMl, int? addWaterGlasses, double? addEnergy, int? addDuration, int? addWorkouts,}) async {
    await _apiClient.updateActivityProgress(
      userId: userId,
      date: date,
      addWaterMl: addWaterMl,
      addWaterGlasses: addWaterGlasses,
      addEnergy: addEnergy,
      addDuration: addDuration,
      addWorkouts: addWorkouts,
    );
  }

  Future<ProgressUser?> getProgress(String userId, DateTime date) => getDailyProgress(userId, date);

  Future<void> saveDailyProgress(ProgressUser progress) async {
    await _apiClient.updateActivityProgress(
      userId: progress.userId,
      date: progress.date,
      addWaterMl: progress.waterMl,
      addWorkouts: progress.workoutsCompleted,
      addDuration: progress.totalDurationSeconds,
      addEnergy: progress.totalCaloriesBurned,
    );
  }
}
