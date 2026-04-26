import 'package:shared/shared.dart';
import '../services/api_client.dart';

class ExerciseRepository {
  final ApiClient _apiClient;
  ExerciseRepository({ApiClient? apiClient}): _apiClient = apiClient ?? ApiClient();

  Future<List<Exercise>> getExercises() => _apiClient.getExercises();
  
  Future<Exercise?> getExerciseById(String id) async {
    final all = await getExercises();
    try {
      return all.firstWhere((e) => e.id.toString() == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<Exercise>> searchExercises(String query) async {
    return _apiClient.searchExercises(query);
  }

  Future<List<Exercise>> getExercisesByMuscleGroup(String muscleGroup) async {
    return _apiClient.getExercises(muscleGroup: muscleGroup);
  }
}
