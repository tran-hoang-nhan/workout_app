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

  Future<List<Workout>> getWorkoutsByCategory(String category) async {
    final key = category.trim().toLowerCase();
    if (key == 'tất cả' || key == 'all') {
      debugPrint('[WorkoutService] getWorkoutsByCategory: all → getAllWorkouts()');
      return getAllWorkouts();
    }

    final forApi = category.trim();

    debugPrint('[WorkoutService] getWorkoutsByCategory: $forApi');
    try {
      final workouts = await _workoutRepository.getWorkoutsByCategory(forApi);
      debugPrint('[WorkoutService] getWorkoutsByCategory returned ${workouts.length} items');
      return workouts;
    } catch (e) {
      debugPrint('[WorkoutService] Error in getWorkoutsByCategory: $e');
      return []; // Return empty list on error to keep UI stable
    }
  }

  Future<List<AISuggestionHistory>> getAISuggestionsHistory() async {
    try {
      return await _workoutRepository.getAISuggestionsHistory();
    } catch (e) {
      debugPrint('[WorkoutService] Error fetching AI suggestions history: $e');
      return [];
    }
  }

  Future<void> logWorkout(WorkoutHistory history) async {
    try {
      await _workoutRepository.logWorkout(history);
    } catch (e) {
      debugPrint('[WorkoutService] Error logging workout: $e');
      rethrow;
    }
  }
}
