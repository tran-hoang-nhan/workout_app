import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/daily_stats.dart';
import '../utils/app_error.dart';

class DailyStatsRepository {
  final SupabaseClient _supabase;
  DailyStatsRepository({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  Future<DailyStats?> getDailyStats(String userId, DateTime date) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0];
      final response = await _supabase
          .from('daily_summaries')
          .select()
          .eq('user_id', userId)
          .eq('date', dateStr)
          .maybeSingle();
      if (response == null) return null;
      return DailyStats.fromJson(response);
    } catch (e, st) {
      throw handleException(e, st);
    }
  }

  Future<List<DailyStats>> getStatsRange(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    try {
      final startStr = start.toIso8601String().split('T')[0];
      final endStr = end.toIso8601String().split('T')[0];
      final response = await _supabase
          .from('daily_summaries')
          .select()
          .eq('user_id', userId)
          .gte('date', startStr)
          .lte('date', endStr)
          .order('date', ascending: true);
      return (response as List)
          .map((json) => DailyStats.fromJson(json))
          .toList();
    } catch (e, st) {
      throw handleException(e, st);
    }
  }

  Future<void> saveDailyStats(DailyStats stats) async {
    try {
      await _supabase
          .from('daily_summaries')
          .upsert(stats.toJson(), onConflict: 'user_id, date');
    } catch (e, st) {
      throw handleException(e, st);
    }
  }

  Future<void> updateActivityStats({
    required String userId,
    required DateTime date,
    double? addEnergy,
    int? addMinutes,
    int? steps,
    double? distance,
  }) async {
    try {
      final existing = await getDailyStats(userId, date);
      final dateStr = date.toIso8601String().split('T')[0];
      if (existing == null) {
        final newStats = DailyStats(
          userId: userId,
          date: date,
          activeEnergyBurned: addEnergy ?? 0,
          activeMinutes: addMinutes ?? 0,
          stepsCount: steps ?? 0,
          distanceMeters: distance ?? 0,
        );
        await saveDailyStats(newStats);
      } else {
        final updateData = {
          if (addEnergy != null)
            'active_energy_burned': existing.activeEnergyBurned + addEnergy,
          if (addMinutes != null)
            'active_minutes': existing.activeMinutes + addMinutes,
          if (steps != null) 'steps_count': steps,
          if (distance != null)
            'distance_meters': existing.distanceMeters + distance,
        };
        if (updateData.isNotEmpty) {
          await _supabase
              .from('daily_summaries')
              .update(updateData)
              .eq('user_id', userId)
              .eq('date', dateStr);
        }
      }
    } catch (e, st) {
      throw handleException(e, st);
    }
  }
}
