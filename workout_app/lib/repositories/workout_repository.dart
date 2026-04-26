import 'package:shared/shared.dart';
import '../services/api_client.dart';

class WorkoutRepository {
  WorkoutRepository({ApiClient? apiClient}): _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<WorkoutPlan> createWorkoutSuggestion({required double weight, required double height, required String goal, required String dietType, required List<String> medicalConditions,String? requirement,}) async {
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
}
