import 'package:shared/shared.dart';
import '../api/api_client.dart';

class ProgressRepository {
  final ApiClient _apiClient;
  ProgressRepository({ApiClient? apiClient}): _apiClient = apiClient ?? ApiClient();

  Future<List<WorkoutHistory>> getWorkoutHistory(String userId) async {
    return _apiClient.getWorkoutHistory(userId);
  }

  Future<List<WorkoutHistory>> getProgressHistory(String userId) =>
      getWorkoutHistory(userId);

  Future<void> logWorkout(WorkoutHistory history) async {
    await _apiClient.logWorkout(history);
  }

  Future<void> syncDailySummary(String userId, DateTime date) async {
    // Implement or proxy
  }

  Future<ProgressStats?> getProgressStats(String userId) async {
    return _apiClient.getProgressStats(userId);
  }
}
