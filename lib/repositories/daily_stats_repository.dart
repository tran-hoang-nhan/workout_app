import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/daily_stats.dart';
import '../utils/app_error.dart';

class DailyStatsRepository {
  final SupabaseClient _supabase;
  DailyStatsRepository({SupabaseClient? supabase}): 
    _supabase = supabase ?? Supabase.instance.client;

  Future<DailyStats?> getDailyStats(String userId, DateTime date) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0];
      final response = await _supabase.from('daily_stats').select().eq('user_id', userId).eq('date', dateStr).maybeSingle();
      if (response == null) return null;
      return DailyStats.fromJson(response);
    } catch (e, st) {
      throw handleException(e, st);
    }
  }

  Future<List<DailyStats>> getStatsRange(String userId, DateTime start, DateTime end) async {
    try {
      final startStr = start.toIso8601String().split('T')[0];
      final endStr = end.toIso8601String().split('T')[0];
      final response = await _supabase.from('daily_stats').select().eq('user_id', userId).gte('date', startStr).lte('date', endStr).order('date', ascending: true);
      return (response as List).map((json) => DailyStats.fromJson(json)).toList();
    } catch (e, st) {
      throw handleException(e, st);
    }
  }

  Future<void> saveDailyStats(DailyStats stats) async {
    try {
      await _supabase.from('daily_stats').upsert(
            stats.toJson(),
            onConflict: 'user_id, date',
          );
    } catch (e, st) {
      throw handleException(e, st);
    }
  }

  Future<void> updateActivityStats({required String userId, required DateTime date, int? addCalories, int? addDurationMinutes, int? steps, int? waterMl,}) async {
    try {
      final existing = await getDailyStats(userId, date);
      final dateStr = date.toIso8601String().split('T')[0];
      if (existing == null) {
        final newStats = DailyStats(
          userId: userId,
          date: date,
          caloriesBurned: addCalories ?? 0,
          workoutDuration: addDurationMinutes ?? 0,
          stepsCount: steps ?? 0,
          waterIntake: waterMl ?? 0,
        );
        await saveDailyStats(newStats);
      } else {
        final updateData = {
          if (addCalories != null) 'calories_burned': existing.caloriesBurned + addCalories,
          if (addDurationMinutes != null) 'workout_duration': existing.workoutDuration + addDurationMinutes,
          if (steps != null) 'steps_count': steps,
          if (waterMl != null) 'water_intake': waterMl,
        };
        if (updateData.isNotEmpty) {
          await _supabase.from('daily_stats').update(updateData).eq('user_id', userId).eq('date', dateStr);
        }
      }
    } catch (e, st) {
      throw handleException(e, st);
    }
  }
}
