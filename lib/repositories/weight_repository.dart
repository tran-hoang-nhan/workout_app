import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/body_metric.dart';
import '../utils/app_error.dart';

class WeightRepository {
  final SupabaseClient _supabase;
  WeightRepository({SupabaseClient? supabase}): _supabase = supabase ?? Supabase.instance.client;

  Future<List<BodyMetric>> getWeightHistory(String userId) async {
    try {
      final response = await _supabase.from('body_metrics').select().eq('user_id', userId).order('recorded_at', ascending: false);
      return (response as List).map((data) => BodyMetric.fromJson(data)).toList();
    } catch (e, st) {
      debugPrint('[WeightRepo] Error fetching history: $e');
      throw handleException(e, st);
    }
  }

  Future<({double? weight, double? height})> getLatestMetrics(String userId) async {
    try {
      final response = await _supabase.from('health').select('weight, height').eq('user_id', userId).maybeSingle();
      return (
        weight: (response?['weight'] as num?)?.toDouble(),
        height: (response?['height'] as num?)?.toDouble(),
      );
    } catch (e, st) {
      debugPrint('[WeightRepo] Error fetching metrics: $e');
      throw handleException(e, st);
    }
  }

  Future<double?> getUserHeight(String userId) async {
    final metrics = await getLatestMetrics(userId);
    return metrics.height;
  }

  Future<void> addWeightRecord({required String userId,required double weight,required double? bmi,required DateTime date,}) async {
    try {
      await _supabase.rpc('add_weight_transaction',
        params: {
          'p_user_id': userId,
          'p_weight': weight,
          'p_bmi': bmi,
          'p_date': date.toIso8601String(),
        },
      );
    } catch (e, st) {
      debugPrint('[WeightRepo] Error adding weight: $e');
      throw handleException(e, st);
    }
  }

  Future<void> deleteWeightRecord(int id) async {
    try {
      await _supabase.from('body_metrics').delete().eq('id', id);
    } catch (e, st) {
      debugPrint('[WeightRepo] Error deleting weight: $e');
      throw handleException(e, st);
    }
  }
}
