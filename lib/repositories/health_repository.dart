import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/health_data.dart';
import '../models/health_params.dart';
import '../utils/app_error.dart';

class HealthRepository {
  final SupabaseClient _supabase;

  HealthRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  // --- 1. LẤY DỮ LIỆU SỨC KHỎE ---
  Future<HealthData?> getHealthData(String userId) async {
    try {
      // Lấy bảng health
      final healthResponse = await _supabase
          .from('health')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (healthResponse == null) return null;

      // Lấy bảng profiles (để lấy height, gender)
      final profileResponse = await _supabase
          .from('profiles')
          .select('height, gender')
          .eq('id', userId)
          .maybeSingle();

      // Merge dữ liệu
      return HealthData.fromJson(
        healthResponse,
        userId,
        height: (profileResponse?['height'] as num?)?.toDouble(),
        gender: profileResponse?['gender'] as String?,
      );
    } catch (e, st) {
      debugPrint('[HealthRepository] Error fetching data: $e');
      throw handleException(e, st);
    }
  }

  // --- 2. LƯU DỮ LIỆU (Cập nhật cả 2 bảng) ---
  Future<void> saveHealthData(HealthUpdateParams params) async {
    try {
      // Upsert bảng health
      await _supabase.from('health').upsert(params.toHealthMap());

      // Update bảng profiles
      await _supabase
          .from('profiles')
          .update(params.toProfileMap())
          .eq('id', params.userId);
          
    } catch (e, st) {
      debugPrint('[HealthRepository] Error saving data: $e');
      throw handleException(e, st);
    }
  }
}