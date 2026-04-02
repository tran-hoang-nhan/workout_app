import 'package:shared/shared.dart';
import '../services/api_client.dart';

/// Repository responsible for interacting with workout-related API endpoints.
class WorkoutRepository {
  /// Creates a [WorkoutRepository] instance.
  WorkoutRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  /// Requests a workout suggestion from the AI based on health metrics.
  Future<WorkoutPlan> createWorkoutSuggestion({
    required double weight,
    required double height,
    required String goal,
    required String dietType,
    required List<String> medicalConditions,
    String? requirement,
  }) async {
    final req = WorkoutGenerationRequest(
      weight: weight,
      height: height,
      goal: goal,
      dietType: dietType,
      medicalConditions: medicalConditions,
      requirement: requirement,
    );
    return _apiClient.generateWorkout(req);
  }

  Future<List<AISuggestionHistory>> getAISuggestionsHistory() async {
    return _apiClient.getAISuggestionsHistory();
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

  Future<void> logWorkout(WorkoutHistory history) async {
    await _apiClient.logWorkout(history);
  }

  // Older methods that are no longer directly used or need to be refactored
  // For the sake of this migration, we are mapping the main entry points.
}
