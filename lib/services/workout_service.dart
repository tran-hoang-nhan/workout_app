import 'package:flutter/foundation.dart';
import 'package:shared/shared.dart';
import '../repositories/workout_repository.dart';
import '../utils/logger.dart';

class WorkoutService {
  final WorkoutRepository _workoutRepository;

  WorkoutService({WorkoutRepository? repository}): _workoutRepository = repository ?? WorkoutRepository();

  Future<List<Workout>> getAllWorkouts() async {
    debugPrint('[WorkoutService] getAllWorkouts called');
    final workouts = await _workoutRepository.getAllWorkouts();
    debugPrint('[WorkoutService] getAllWorkouts returned ${workouts.length} items');
    if (workouts.isEmpty) {
      debugPrint('[WorkoutService] WARNING: Workouts list is empty');
    }
    return workouts;
  }

  Future<List<Workout>> getWorkoutsByLevel(String level) async {
    try {
      return await _workoutRepository.getWorkoutsByLevel(level);
    } catch (e) {
      logger.e('[WorkoutService] Error fetching workouts by level: $e');
      return [];
    }
  }

  Future<WorkoutDetail> getWorkoutDetail(int workoutId) async {
    try {
      return await _workoutRepository.getWorkoutDetail(workoutId);
    } catch (e) {
      logger.e('[WorkoutService] Error fetching workout detail: $e');
      rethrow;
    }
  }

  Future<List<Workout>> searchWorkouts(String query) async {
    try {
      return await _workoutRepository.searchWorkouts(query);
    } catch (e) {
      logger.e('[WorkoutService] Error searching workouts: $e');
      return [];
    }
  }

  String _simplify(String s) {
    var str = s.toLowerCase();
    const vietnamese = 'aáàảãạâấầẩẫậăắằẳẵặeéèẻẽẹêếềểễệiíìỉĩịoóòỏõọôốồổỗộơớờởỡợuúùủũụưứừửữựyýỳỷỹỵdđ';
    const latin = 'aaaaaaaaaaaaaaaaaeeeeeeeeeeeeiiiiiiioooooooooooooooooouuuuuuuuuuuuyyyyyydd';
    for (var i = 0; i < vietnamese.length; i++) {
      str = str.replaceAll(vietnamese[i], latin[i]);
    }
    return str;
  }

  Future<List<Workout>> getWorkoutsByCategory(String category) async {
    final key = category.trim().toLowerCase();

    // Map UI label to internal key
    final mappedCategory = (key == 'tất cả' || key == 'all') ? 'all' : _simplify(category);

    // Direct bypass for "All" category since /api/workouts/ is confirmed working
    if (mappedCategory == 'all') {
      debugPrint('[WorkoutService] Bypassing category for "All" - calling getAllWorkouts()');
      return getAllWorkouts();
    }

    debugPrint('[WorkoutService] getWorkoutsByCategory called: $category -> $mappedCategory');
    try {
      final workouts = await _workoutRepository.getWorkoutsByCategory(mappedCategory);
      debugPrint('[WorkoutService] getWorkoutsByCategory returned ${workouts.length} items');
      return workouts;
    } catch (e) {
      debugPrint('[WorkoutService] Error in getWorkoutsByCategory: $e');
      return []; // Return empty list on error to keep UI stable
    }
  }
}
