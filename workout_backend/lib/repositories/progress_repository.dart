import 'package:shared/shared.dart';
import 'package:supabase/supabase.dart';

/// Repository for workout history and daily progress data.
class ProgressRepository {
  /// Creates a progress repository backed by Supabase.
  ProgressRepository(this._supabase);
  final SupabaseClient _supabase;

  // --- Workout History ---
  /// Returns workout history entries for the given user.
  Future<List<WorkoutHistory>> getWorkoutHistory(String userId) async {
    final response = await _supabase
        .from('workout_history')
        .select()
        .eq('user_id', userId)
        .order('completed_at', ascending: false);
    return (response as List)
        .map((data) => WorkoutHistory.fromJson(data as Map<String, dynamic>))
        .toList();
  }

  /// Alias for historical progress retrieval used by legacy endpoints.
  Future<List<WorkoutHistory>> getProgressHistory(String userId) =>
      getWorkoutHistory(userId);

  /// Stores one completed workout history row.
  Future<void> logWorkout(WorkoutHistory history) async {
    await _supabase.from('workout_history').insert(history.toJson());
  }

  // --- Daily Progress Tracking (from ProgressUserRepository) ---
  /// Returns one daily progress entry for the provided date.
  Future<ProgressUser?> getProgress(String userId, DateTime date) async {
    final dateStr = date.toIso8601String().split('T')[0];
    final response = await _supabase
        .from('progress_user')
        .select()
        .eq('user_id', userId)
        .eq('date', dateStr)
        .maybeSingle();
    if (response == null) return null;
    return ProgressUser.fromJson(response);
  }

  /// Returns daily progress entries in the inclusive date range.
  Future<List<ProgressUser>> getProgressRange(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    final startStr = start.toIso8601String().split('T')[0];
    final endStr = end.toIso8601String().split('T')[0];
    final response = await _supabase
        .from('progress_user')
        .select()
        .eq('user_id', userId)
        .gte('date', startStr)
        .lte('date', endStr)
        .order('date', ascending: true);
    return (response as List)
        .map((json) => ProgressUser.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Upserts a full progress row for a date.
  Future<void> saveProgress(ProgressUser progress) async {
    await _supabase
        .from('progress_user')
        .upsert(progress.toJson(), onConflict: 'user_id, date');
  }

  /// Increments activity counters for one date.
  Future<void> updateActivityProgress({
    required String userId,
    required DateTime date,
    int? addWaterMl,
    int? addWaterGlasses,
    int? addSteps,
    double? addEnergy,
    int? addDuration,
    int? addWorkouts,
  }) async {
    final existing = await getProgress(userId, date);
    final dateStr = date.toIso8601String().split('T')[0];

    if (existing == null) {
      final newProgress = ProgressUser(
        userId: userId,
        date: date,
        waterMl: addWaterMl ?? 0,
        waterGlasses: addWaterGlasses ?? 0,
        steps: addSteps ?? 0,
        totalCaloriesBurned: addEnergy ?? 0,
        totalDurationSeconds: addDuration ?? 0,
        workoutsCompleted: addWorkouts ?? 0,
      );
      await saveProgress(newProgress);
    } else {
      final updateData = {
        if (addWaterMl != null) 'water_ml': existing.waterMl + addWaterMl,
        if (addWaterGlasses != null)
          'water_glasses': existing.waterGlasses + addWaterGlasses,
        if (addSteps != null) 'steps': existing.steps + addSteps,
        if (addEnergy != null)
          'total_calories_burned': existing.totalCaloriesBurned + addEnergy,
        if (addDuration != null)
          'total_duration_seconds': existing.totalDurationSeconds + addDuration,
        if (addWorkouts != null)
          'workouts_completed': existing.workoutsCompleted + addWorkouts,
        'updated_at': DateTime.now().toIso8601String(),
      };
      await _supabase
          .from('progress_user')
          .update(updateData)
          .eq('user_id', userId)
          .eq('date', dateStr);
    }
  }

  /// Calculates aggregate statistics from historical progress
  Future<ProgressStats?> getProgressStats(String userId) async {
    final response = await _supabase
        .from('progress_user')
        .select('workouts_completed, total_duration_seconds, total_calories_burned, date')
        .eq('user_id', userId)
        .order('date', ascending: false);

    final data = response as List;
    if (data.isEmpty) return null;

    int totalWorkouts = 0;
    int totalDurationSeconds = 0;
    double totalCalories = 0.0;
    int streak = 0;
    DateTime? lastDate;

    for (var i = 0; i < data.length; i++) {
      final row = data[i] as Map<String, dynamic>;
      totalWorkouts += (row['workouts_completed'] as int? ?? 0);
      totalDurationSeconds += (row['total_duration_seconds'] as int? ?? 0);
      totalCalories += ((row['total_calories_burned'] as num?)?.toDouble() ?? 0.0);

      final dateStr = row['date'] as String?;
      if (dateStr != null) {
        final currentDate = DateTime.parse(dateStr);
        final currentDateOnly = DateTime(currentDate.year, currentDate.month, currentDate.day);
        
        if (lastDate == null) {
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final diff = today.difference(currentDateOnly).inDays;
          if (diff <= 1) { // active today or yesterday
            streak = 1;
            lastDate = currentDateOnly;
          }
        } else {
          final diff = lastDate.difference(currentDateOnly).inDays;
          if (diff == 1) { // Consecutive day
            streak++;
            lastDate = currentDateOnly;
          }
        }
      }
    }

    final totalDurationMinutes = totalDurationSeconds ~/ 60;
    final avgCalories = totalWorkouts > 0 ? (totalCalories / totalWorkouts) : 0.0;

    return ProgressStats(
      totalWorkouts: totalWorkouts,
      totalCalories: totalCalories,
      totalDuration: totalDurationMinutes,
      avgCaloriesPerSession: avgCalories,
      streak: streak,
    );
  }
}
