import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/progress_repository.dart';
import '../models/workout_history.dart';
import '../models/body_metric.dart';
import './auth_provider.dart';

import './daily_stats_provider.dart';

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  return ProgressRepository();
});

final syncDailySummaryProvider = FutureProvider<void>((ref) async {
  final userId = await ref.watch(currentUserIdProvider.future);
  if (userId == null) return;

  final repo = ref.watch(progressRepositoryProvider);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));

  // Sync today (for real-time steps etc, though workout calo is now UI-realtime)
  await repo.syncDailySummary(userId, today);

  // Also finalize yesterday
  await repo.syncDailySummary(userId, yesterday);

  // Refresh the stats providers
  ref.invalidate(dailyStatsProvider(today));
  ref.invalidate(dailyStatsProvider(yesterday));
});

final workoutHistoryProvider = FutureProvider<List<WorkoutHistory>>((
  ref,
) async {
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

final dailyWorkoutStatsProvider =
    Provider.family<AsyncValue<({double calories, int minutes})>, DateTime>((
      ref,
      date,
    ) {
      final historyAsync = ref.watch(workoutHistoryProvider);
      return historyAsync.whenData((history) {
        final targetDate = DateTime(date.year, date.month, date.day);
        final dayWorkouts = history.where((w) {
          final wDate = DateTime(
            w.completedAt.year,
            w.completedAt.month,
            w.completedAt.day,
          );
          return wDate.isAtSameMomentAs(targetDate);
        });

        final calories = dayWorkouts.fold<double>(
          0,
          (sum, w) => sum + (w.totalCaloriesBurned ?? 0),
        );
        final minutes = dayWorkouts.fold<int>(
          0,
          (sum, w) => sum + ((w.durationSeconds ?? 0) / 60).round(),
        );

        return (calories: calories, minutes: minutes);
      });
    });
