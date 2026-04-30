import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';
import './auth_provider.dart';
import './daily_stats_provider.dart';
import './progress_user_provider.dart';
import './progress_provider.dart';
import './health_provider.dart';
import '../utils/logger.dart';
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

final workoutSessionControllerProvider = Provider<WorkoutSessionController>((ref) {
  return WorkoutSessionController(ref);
});

class WorkoutSessionController {
  final Ref _ref;
  WorkoutSessionController(this._ref);

  Future<void> logWorkoutCompletion({
    required Workout workout,
    required double calories,
    required int durationSeconds,
  }) async {
    try {
      final userId = await _ref.read(currentUserIdProvider.future);
      if (userId == null) return;

      final history = WorkoutHistory(
        userId: userId,
        workoutId: workout.id != 0 ? workout.id : null,
        workoutTitleSnapshot: workout.title,
        totalCaloriesBurned: calories,
        durationSeconds: durationSeconds,
        completedAt: DateTime.now(),
      );

      await _ref.read(workoutServiceProvider).logWorkout(history);

      final now = DateTime.now();
      
      _ref.invalidate(progressDailyProvider(now));
      _ref.invalidate(dailyStatsProvider(now));
      _ref.invalidate(workoutHistoryProvider);
      _ref.invalidate(progressStatsProvider);
      _ref.invalidate(progressWeeklyProvider);
      _ref.invalidate(weeklyStatsProvider);
      _ref.invalidate(healthDataProvider);
      _ref.invalidate(aiSuggestionHistoryProvider);
    } catch (e) {
      logger.e('[WorkoutSession] Error logging workout: $e');
    }
  }
}
