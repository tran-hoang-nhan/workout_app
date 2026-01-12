import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/workout.dart';
import '../models/workout_item.dart';
import '../models/exercise.dart';
import '../repositories/workout_repository.dart';
import '../utils/storage_utils.dart';

class WorkoutService {
  final WorkoutRepository _workoutRepository;
  final SupabaseClient _supabase = Supabase.instance.client;

  WorkoutService({WorkoutRepository? repository})
    : _workoutRepository = repository ?? WorkoutRepository();

  Future<List<Workout>> getAllWorkouts() async {
    final response = await _workoutRepository.getAllWorkouts();
    return response.map((data) => Workout.fromJson(data)).toList();
  }

  Future<List<Workout>> getWorkoutsByLevel(String level) async {
    final response = await _workoutRepository.getWorkoutsByLevel(level);
    return response.map((data) => Workout.fromJson(data)).toList();
  }

  Future<({Workout workout, List<WorkoutItem> items, List<Exercise> exercises})>
  getWorkoutDetail(int workoutId) async {
    final workoutData = await _workoutRepository.getWorkoutById(workoutId);
    final workout = Workout.fromJson(workoutData);
    final itemsData = await _workoutRepository.getWorkoutItems(workoutId);

    List<WorkoutItem> items = itemsData
        .map((data) => WorkoutItem.fromJson(data))
        .toList();
    // Sort items by orderIndex
    items.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

    if (items.isEmpty) {
      return (
        workout: workout,
        items: <WorkoutItem>[],
        exercises: <Exercise>[],
      );
    }

    final exerciseIds = items
        .map((item) => item.exerciseId)
        .where((id) => id > 0)
        .toSet()
        .toList();
    final exercisesData = await _workoutRepository.getExercisesByIds(
      exerciseIds,
    );

    // Create a map of exercise by ID for easier lookup
    final exerciseMap = <int, Exercise>{};
    for (var data in exercisesData) {
      final processedData = processExerciseJson(_supabase, data);
      final exercise = Exercise.fromJson(processedData);
      exerciseMap[exercise.id] = exercise;
    }

    // Sort exercises to match the order of items
    List<Exercise> exercises = items
        .map((item) => exerciseMap[item.exerciseId])
        .whereType<Exercise>()
        .toList();

    return (workout: workout, items: items, exercises: exercises);
  }

  Future<List<Workout>> searchWorkouts(String query) async {
    final response = await _workoutRepository.searchWorkouts(query);
    return response.map((data) => Workout.fromJson(data)).toList();
  }

  Future<List<Workout>> getWorkoutsByCategory(String category) async {
    final muscleGroup = _mapCategoryToMuscleGroup(category);
    final exerciseIds = await _workoutRepository.getExerciseIdsByMuscleGroup(
      muscleGroup,
    );
    if (exerciseIds.isEmpty) return [];

    final workoutIds = await _workoutRepository.getWorkoutIdsByExerciseIds(
      exerciseIds,
    );
    if (workoutIds.isEmpty) return [];

    final workoutsData = await _workoutRepository.getWorkoutsByIds(workoutIds);
    return workoutsData.map((data) => Workout.fromJson(data)).toList();
  }

  String _mapCategoryToMuscleGroup(String category) {
    switch (category.toLowerCase()) {
      case 'sức mạnh':
        return 'strength';
      case 'cardio':
        return 'cardio';
      case 'yoga':
        return 'yoga';
      case 'hiit':
        return 'hiit';
      default:
        return category.toLowerCase();
    }
  }
}
