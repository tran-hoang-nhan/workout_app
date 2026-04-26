import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';
import '../repositories/workout_repository.dart';
import '../services/workout_service.dart';

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

final workoutsByLevelProvider = FutureProvider.family<List<Workout>, String>((ref, level,) async {
  final service = ref.watch(workoutServiceProvider);
  return await service.getWorkoutsByLevel(level);
});

final workoutDetailProvider = FutureProvider.family<WorkoutDetail, int>((ref, id,) async {
  final service = ref.watch(workoutServiceProvider);
  return await service.getWorkoutDetail(id);
});

final aiSuggestionHistoryProvider = FutureProvider<List<AISuggestionHistory>>((ref) async {
  return ref.watch(workoutServiceProvider).getAISuggestionsHistory();
});

final searchWorkoutsProvider = FutureProvider.family<List<Workout>, String>((ref, query,) async {
  if (query.isEmpty) return [];
  final service = ref.watch(workoutServiceProvider);
  return await service.searchWorkouts(query);
});

final workoutsByCategoryProvider = FutureProvider.family<List<Workout>, String>((ref, category) async {
    final service = ref.watch(workoutServiceProvider);
    return await service.getWorkoutsByCategory(category);
  },
);
