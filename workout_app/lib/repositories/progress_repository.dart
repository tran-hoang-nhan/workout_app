import 'package:shared/shared.dart';
import '../services/api_client.dart';

class ProgressRepository {
  final ApiClient _apiClient;
  ProgressRepository({ApiClient? apiClient}): _apiClient = apiClient ?? ApiClient();

  Future<List<WorkoutHistory>> getWorkoutHistory(String userId) async {
    return _apiClient.getWorkoutHistory(userId);
  }

  Future<List<WorkoutHistory>> getProgressHistory(String userId) => getWorkoutHistory(userId);

  Future<void> logWorkout(WorkoutHistory history) async {
    await _apiClient.logWorkout(history);
  }

  Future<void> syncDailySummary(String userId, DateTime date) async {
    final targetDate = DateTime(date.year, date.month, date.day);
    final progress = await _apiClient.getDailyProgress(userId, targetDate);
    final totalCalories = progress?.totalCaloriesBurned ?? 0.0;
    final durationSeconds = progress?.totalDurationSeconds ?? 0;
    final activeMinutes = (durationSeconds / 60).round();

    final stats = DailyStats(
      userId: userId,
      date: targetDate,
      activeEnergyBurned: totalCalories,
      activeMinutes: activeMinutes,
    );

    await _apiClient.saveDailyStats(stats);
  }

  Future<ProgressStats?> getProgressStats(String userId) async {
    return _apiClient.getProgressStats(userId);
  }
}
