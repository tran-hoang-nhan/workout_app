import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/health_data.dart';
import '../models/health_params.dart';
import '../utils/app_error.dart';

class HealthRepository {
  final SupabaseClient _supabase;
  HealthRepository({SupabaseClient? supabase}): _supabase = supabase ?? Supabase.instance.client;

  Future<HealthData?> getHealthData(String userId) async {
    try {
      final healthResponse = await _supabase.from('health').select().eq('user_id', userId).maybeSingle();
      if (healthResponse == null) return null;
    
      final profileResponse = await _supabase.from('profiles').select('gender').eq('id', userId).maybeSingle();
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
      await _supabase.from('health').upsert(params.toHealthMap(), onConflict: 'user_id');
      await _supabase.from('profiles').update(params.toProfileMap()).eq('id', params.userId);
    } catch (e, st) {
      debugPrint('[HealthRepository] Error saving data: $e');
      throw handleException(e, st);
    }
  }

  Future<void> saveHealthDataWithTransaction(HealthUpdateParams params) async {
    bool healthCreated = false;
    bool profileUpdated = false;
    try {
      await _supabase.from('health').upsert(params.toHealthMap(), onConflict: 'user_id');
      healthCreated = true;
      await _supabase.from('profiles').update(params.toProfileMap()).eq('id', params.userId);
      profileUpdated = true;
    } catch (e, st) {
      if (healthCreated && !profileUpdated) {
        try {
          await _supabase.from('health').delete().eq('user_id', params.userId);
          debugPrint('✅ Rolled back health data');
        } catch (rollbackError) {
          debugPrint('⚠️ Failed to rollback health data: $rollbackError');
        }
      }
      throw handleException(e, st);
    }
  }
}
