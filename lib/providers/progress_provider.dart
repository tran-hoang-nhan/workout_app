import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/progress_repository.dart';
import '../models/workout_history.dart';
import '../models/body_metric.dart';
import './auth_provider.dart';

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  return ProgressRepository();
});

final workoutHistoryProvider = FutureProvider<List<WorkoutHistory>>((ref) async {
  final userId = await ref.watch(currentUserIdProvider.future);
  if (userId == null) return [];
  
  final repo = ref.watch(progressRepositoryProvider);
  return await repo.getWorkoutHistory(userId);
});

final progressStatsProvider = FutureProvider<ProgressStats>((ref) async {
  final userId = await ref.watch(currentUserIdProvider.future);
  if (userId == null) {
    return ProgressStats(
      totalCalories: 0,
      totalDuration: 0,
      totalWorkouts: 0,
      avgCaloriesPerSession: 0,
    );
  }
  
  final repo = ref.watch(progressRepositoryProvider);
  return await repo.getProgressStats(userId);
});
