import 'package:shared/shared.dart';
import '../services/api_client.dart';

class WorkoutRepository {
  final ApiClient _apiClient;

  WorkoutRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  Future<WorkoutPlan> createWorkoutSuggestion({
    required double weight,
    required double height,
    required String goal,
  }) async {
    return _apiClient.generateWorkout(
      WorkoutGenerationRequest(weight: weight, height: height, goal: goal),
    );
  }

  Future<List<Workout>> getAllWorkouts() async {
    return _apiClient.getAllWorkouts();
  }

  Future<List<Workout>> getWorkoutsByLevel(String level) async {
    return _apiClient.getAllWorkouts(level: level);
  }

  Future<WorkoutDetail> getWorkoutDetail(int workoutId) async {
    return _apiClient.getWorkoutDetail(workoutId);
  }

  Future<List<Workout>> searchWorkouts(String query) async {
    return _apiClient.searchWorkouts(query);
  }

  Future<List<Workout>> getWorkoutsByCategory(String category) async {
    return _apiClient.getWorkoutsByCategory(category);
  }

  // Older methods that are no longer directly used or need to be refactored
  // For the sake of this migration, we are mapping the main entry points.
}
