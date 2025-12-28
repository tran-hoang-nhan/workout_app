import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/workout_repository.dart';
import '../services/workout_service.dart';
import '../models/workout.dart';
import '../models/workout_item.dart';
import '../models/exercise.dart';

final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  return WorkoutRepository();
});

final workoutServiceProvider = Provider<WorkoutService>((ref) {
  return WorkoutService();
});

final workoutsProvider = FutureProvider<List<Workout>>((ref) async {
  final service = ref.watch(workoutServiceProvider);
  return await service.getAllWorkouts();
});

final workoutsByLevelProvider = FutureProvider.family<List<Workout>, String>((ref, level) async {
  final service = ref.watch(workoutServiceProvider);
  return await service.getWorkoutsByLevel(level);
});

final workoutDetailProvider = FutureProvider.family<({Workout workout, List<WorkoutItem> items, List<Exercise> exercises}),int>((ref, id) async {
  final service = ref.watch(workoutServiceProvider);
  return await service.getWorkoutDetail(id);
});

final searchWorkoutsProvider = FutureProvider.family<List<Workout>, String>((ref, query) async {
  if (query.isEmpty) return [];
  final service = ref.watch(workoutServiceProvider);
  return await service.searchWorkouts(query);
});

final workoutsByCategoryProvider = FutureProvider.family<List<Workout>, String>((ref, category) async {
  final service = ref.watch(workoutServiceProvider);
  return await service.getWorkoutsByCategory(category);
});
