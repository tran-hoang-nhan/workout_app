import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/daily_summary.dart';
import '../utils/app_error.dart';

class DailySummaryRepository {
  final SupabaseClient _supabase;
  DailySummaryRepository({SupabaseClient? supabase}): _supabase = supabase ?? Supabase.instance.client;

  Future<DailySummary?> getDailySummary(String userId, DateTime date) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0];
      final response = await _supabase.from('daily_summaries').select().eq('user_id', userId).eq('date', dateStr).maybeSingle();
      if (response == null) return null;
      return DailySummary.fromJson(response);
    } catch (e, st) {
      throw handleException(e, st);
    }
  }

  Future<void> upsertDailySummary(DailySummary summary) async {
    try {
      await _supabase.from('daily_summaries').upsert(summary.toJson(), onConflict: 'user_id, date',);
    } catch (e, st) {
      throw handleException(e, st);
    }
  }

  Future<List<DailySummary>> getSummariesRange(String userId, DateTime start, DateTime end) async {
    try {
      final startStr = start.toIso8601String().split('T')[0];
      final endStr = end.toIso8601String().split('T')[0];
      final response = await _supabase.from('daily_summaries').select().eq('user_id', userId).gte('date', startStr).lte('date', endStr).order('date', ascending: true);
      return (response as List).map((json) => DailySummary.fromJson(json)).toList();
    } catch (e, st) {
      throw handleException(e, st);
    }
  }
}
