import 'package:shared/shared.dart';
import 'package:supabase/supabase.dart';

class HealthRepository {
  HealthRepository(this._supabase);
  final SupabaseClient _supabase;

  Future<HealthData?> getHealthData(String userId) async {
    final healthResponse = await _supabase.from('health').select().eq('user_id', userId).maybeSingle();
    if (healthResponse == null) return null;

    final profileResponse = await _supabase.from('profiles').select('gender').eq('id', userId).maybeSingle();

    final healthMap = Map<String, dynamic>.from(healthResponse as Map);
    final profileMap = profileResponse == null ? null : Map<String, dynamic>.from(profileResponse as Map);

    healthMap['user_id'] = userId;
    healthMap['gender'] = profileMap?['gender'] ?? healthMap['gender'];

    return HealthData.fromJson(healthMap);
  }

  /// Updates quick body metrics on the health profile.
  Future<void> updateQuickMetrics({required String userId, double? weight, double? height,}) async {
    if (weight != null || height != null) {
      final healthData = <String, dynamic>{
        'user_id': userId,
        'updated_at': DateTime.now().toIso8601String(),
      };
      if (weight != null) {
        healthData['weight'] = weight;
        await addWeightRecord(
          userId: userId,
          weight: weight,
          date: DateTime.now(),
        );
      }
      if (height != null) healthData['height'] = height;
      await _supabase.from('health').upsert(healthData, onConflict: 'user_id');
    }
  }

  /// Updates complete health profile, preferring RPC for atomic behavior.
  Future<void> updateFullProfile(HealthUpdateParams params) async {
    try {
      await _supabase.rpc<void>('update_health_profile_and_log',
        params: {
          'p_user_id': params.userId,
          'p_age': params.age,
          'p_weight': params.weight,
          'p_height': params.height,
          'p_gender': params.gender,
          'p_goal': params.goal,
          'p_activity_level': params.activityLevel,
          'p_diet_type': params.dietType,
          'p_water_intake': params.waterIntake,
          'p_injuries': params.injuries,
          'p_medical_conditions': params.medicalConditions,
          'p_allergies': params.allergies,
          'p_water_reminder_enabled': params.waterReminderEnabled,
          'p_water_reminder_interval': params.waterReminderInterval,
          'p_wake_time': params.wakeTime,
          'p_sleep_time': params.sleepTime,
        },
      );
      await _supabase.from('health').upsert(params.toJson(), onConflict: 'user_id');
      await _supabase.from('profiles').update({'gender': params.gender,'goal': params.goal,}).eq('id', params.userId);
    } catch (e) {
      rethrow;
    }
  }

  /// Returns daily stats for one date.
  Future<DailyStats?> getDailyStats(String userId, DateTime date) async {
    final dateStr = date.toIso8601String().split('T')[0];
    final response = await _supabase.from('daily_summaries').select().eq('user_id', userId).eq('date', dateStr).maybeSingle();
    if (response == null) return null;
    return DailyStats.fromJson(Map<String, dynamic>.from(response as Map));
  }

  /// Returns daily stats for a date range.
  Future<List<DailyStats>> getStatsRange(String userId, DateTime start, DateTime end,) async {
    final startStr = start.toIso8601String().split('T')[0];
    final endStr = end.toIso8601String().split('T')[0];
    final response = await _supabase.from('daily_summaries').select().eq('user_id', userId).gte('date', startStr).lte('date', endStr).order('date', ascending: true);
    final rows = List<Map<String, dynamic>>.from(response as List);
    return rows.map(DailyStats.fromJson).toList();
  }

  /// Saves or updates one daily stats row.
  Future<void> saveDailyStats(DailyStats stats) async {
    await _supabase.from('daily_summaries').upsert(stats.toJson(), onConflict: 'user_id, date');
  }

  /// Returns weight history ordered by most recent date first.
  Future<List<BodyMetric>> getWeightHistory(String userId) async {
    final response = await _supabase.from('body_metrics').select().eq('user_id', userId).order(
      'recorded_at',
      ascending: false,
    ); 
    return (response as List).map((json) => BodyMetric.fromJson(json as Map<String, dynamic>)).toList();
  }

  /// Inserts a new weight record and optional BMI value.
  Future<void> addWeightRecord({required String userId, required double weight, required DateTime date, double? bmi,}) async {
    final dateStr = date.toIso8601String().split('T')[0];
    await _supabase.from('body_metrics').insert({
      'user_id': userId,
      'weight': weight,
      if (bmi != null) 'bmi': bmi,
      'recorded_at': dateStr, 
    });
  }
}
