import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/workout_history.dart';
import '../models/body_metric.dart';
import '../utils/app_error.dart';

class ProgressRepository {
  final SupabaseClient _supabase;
  ProgressRepository({SupabaseClient? supabase}): 
    _supabase = supabase ?? Supabase.instance.client;
  Future<List<WorkoutHistory>> getWorkoutHistory(String userId) async {
    try {
      final response = await _supabase.from('workout_history').select().eq('user_id', userId).order('completed_at', ascending: false);
      return (response as List).map((data) => WorkoutHistory.fromJson(data)).toList();
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
}
