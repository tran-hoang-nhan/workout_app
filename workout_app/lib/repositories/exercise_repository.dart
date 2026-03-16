import 'package:shared/shared.dart';
import '../services/api_client.dart';

class ExerciseRepository {
  final ApiClient _apiClient;
  ExerciseRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  Future<List<Exercise>> getExercises() => _apiClient.getExercises();

  Future<Exercise?> getExerciseById(String id) async {
    // Implement proxy if needed
    return null;
  }

  Future<List<Exercise>> searchExercises(String query) async {
    return [];
  }

  Future<List<Exercise>> getExercisesByMuscleGroup(String muscleGroup) async {
    return [];
  }
}
