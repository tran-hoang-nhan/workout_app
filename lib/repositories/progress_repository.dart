import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/workout_history.dart';
import '../models/body_metric.dart';
import '../models/progress_user.dart';
import '../models/daily_stats.dart';
import '../utils/app_error.dart';
import '../utils/logger.dart';
import './daily_stats_repository.dart';
import './progress_user_repository.dart';

class ProgressRepository {
  final SupabaseClient _supabase;
  ProgressRepository({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  Future<List<WorkoutHistory>> getWorkoutHistory(String userId) async {
    try {
      final response = await _supabase
          .from('workout_history')
          .select()
          .eq('user_id', userId)
          .order('completed_at', ascending: false);
      return (response as List)
          .map((data) => WorkoutHistory.fromJson(data))
          .toList();
    } catch (e, st) {
      throw handleException(e, st);
    }
  }

  Future<ProgressStats> getProgressStats(String userId) async {
    try {
      final history = await getWorkoutHistory(userId);
      if (history.isEmpty) {
        return ProgressStats(
          totalCalories: 0,
          totalDuration: 0,
          totalWorkouts: 0,
          avgCaloriesPerSession: 0,
        );
      }

      final totalCalories = history.fold<double>(
        0,
        (sum, item) => sum + (item.totalCaloriesBurned ?? 0),
      );

      final totalDuration = history.fold<int>(
        0,
        (sum, item) => sum + (item.durationSeconds ?? 0),
      );

      return ProgressStats(
        totalCalories: totalCalories,
        totalDuration: totalDuration,
        totalWorkouts: history.length,
        avgCaloriesPerSession: totalCalories / history.length,
      );
    } catch (e, st) {
      throw handleException(e, st);
    }
  }

  Future<WorkoutHistory> recordWorkout({
    required String userId,
    required int? workoutId,
    required String workoutTitle,
    required double caloriesBurned,
    required int durationSeconds,
  }) async {
    try {
      final response = await _supabase
          .from('workout_history')
          .insert({
            'user_id': userId,
            'workout_id': workoutId,
            'workout_title_snapshot': workoutTitle,
            'total_calories_burned': caloriesBurned * 1000,
            'duration_seconds': durationSeconds,
            'completed_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      try {
        final now = DateTime.now();
        final date = DateTime(now.year, now.month, now.day);
        final dailyRepo = DailyStatsRepository(supabase: _supabase);
        await dailyRepo.updateActivityStats(
          userId: userId,
          date: date,
          addEnergy: caloriesBurned * 1000,
          addMinutes: (durationSeconds / 60).round(),
        );
        final userProgressRepo = ProgressUserRepository(supabase: _supabase);
        await userProgressRepo.updateActivityProgress(
          userId: userId,
          date: date,
          addEnergy: caloriesBurned * 1000,
          addDuration: durationSeconds,
          addWorkouts: 1,
        );
      } catch (e) {
        logger.e('Error syncing daily stats: $e');
      }

      return WorkoutHistory.fromJson(response);
    } catch (e, st) {
      throw handleException(e, st);
    }
  }

  Future<void> syncDailySummary(String userId, DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final nextDay = startOfDay.add(const Duration(days: 1));
      final workoutsResponse = await _supabase
          .from('workout_history')
          .select()
          .eq('user_id', userId)
          .gte('completed_at', startOfDay.toIso8601String())
          .lt('completed_at', nextDay.toIso8601String());
      final history = (workoutsResponse as List)
          .map((data) => WorkoutHistory.fromJson(data))
          .toList();

      final totalCalories = history.fold<double>(
        0,
        (sum, item) => sum + (item.totalCaloriesBurned ?? 0),
      );

      final totalDurationSeconds = history.fold<int>(
        0,
        (sum, item) => sum + (item.durationSeconds ?? 0),
      );

      final totalDurationMinutes = (totalDurationSeconds / 60).round();
      final workoutsCompleted = history.length;
      final dailyRepo = DailyStatsRepository(supabase: _supabase);
      final existingStats = await dailyRepo.getDailyStats(userId, startOfDay);
      final updatedStats =
          (existingStats ?? DailyStats(userId: userId, date: startOfDay))
              .copyWith(
                activeEnergyBurned: totalCalories,
                activeMinutes: totalDurationMinutes,
              );
      await dailyRepo.saveDailyStats(updatedStats);

      final progressRepo = ProgressUserRepository(supabase: _supabase);
      final existingProgress = await progressRepo.getProgress(
        userId,
        startOfDay,
      );
      final updatedProgress =
          (existingProgress ?? ProgressUser(userId: userId, date: startOfDay))
              .copyWith(
                totalCaloriesBurned: totalCalories,
                totalDurationSeconds: totalDurationSeconds,
                workoutsCompleted: workoutsCompleted,
              );
      await progressRepo.saveProgress(updatedProgress);
    } catch (e, st) {
      logger.e('Error syncing daily summary: $e');
      throw handleException(e, st);
    }
  }
}
