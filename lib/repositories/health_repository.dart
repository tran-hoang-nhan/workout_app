import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/health_data.dart';
import '../models/health_params.dart';
import '../utils/app_error.dart';

class HealthRepository {
  final SupabaseClient _supabase;
  HealthRepository({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  Future<HealthData?> getHealthData(String userId) async {
    try {
      final healthResponse = await _supabase
          .from('health')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      if (healthResponse == null) return null;
      final profileResponse = await _supabase
          .from('profiles')
          .select('gender')
          .eq('id', userId)
          .maybeSingle();
      return HealthData.fromJson(
        healthResponse,
        userId,
        gender: profileResponse?['gender'] as String?,
      );
    } catch (e, st) {
      debugPrint('[HealthRepository] Error fetching data: $e');
      throw handleException(e, st);
    }
  }

  Future<void> saveHealthData(HealthUpdateParams params) async {
    try {
      await _supabase
          .from('health')
          .upsert(params.toHealthMap(), onConflict: 'user_id');
      await _supabase
          .from('profiles')
          .update(params.toProfileMap())
          .eq('id', params.userId);
    } catch (e, st) {
      debugPrint('[HealthRepository] Error saving data: $e');
      throw handleException(e, st);
    }
  }

  Future<void> saveHealthDataWithTransaction(HealthUpdateParams params) async {
    try {
      await _supabase.rpc('save_health_profile_transaction', params: {
        'p_user_id': params.userId,
        'p_age': params.age,
        'p_weight': params.weight,
        'p_height': params.height,
        'p_gender': params.gender,
        'p_activity_level': params.activityLevel,
        'p_goal': params.goal,
        'p_diet_type': params.dietType,
        'p_sleep_hours': params.sleepHours,
        'p_water_intake': params.waterIntake,
        'p_injuries': params.injuries,
        'p_medical_conditions': params.medicalConditions,
        'p_allergies': params.allergies,
        'p_water_reminder_enabled': params.waterReminderEnabled,
        'p_water_reminder_interval': params.waterReminderInterval,
      });
    } catch (e, st) {
      debugPrint('[HealthRepository] Error saving data with transaction: $e');
      throw handleException(e, st);
    }
  }
}
