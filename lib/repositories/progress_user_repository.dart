import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/progress_user.dart';
import '../utils/app_error.dart';

class ProgressUserRepository {
  final SupabaseClient _supabase;
  ProgressUserRepository({SupabaseClient? supabase}): _supabase = supabase ?? Supabase.instance.client;
    
  Future<ProgressUser?> getProgress(String userId, DateTime date) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0];
      final response = await _supabase.from('progress_user').select().eq('user_id', userId).eq('date', dateStr).maybeSingle();
      if (response == null) return null;
      return ProgressUser.fromJson(response);
    } catch (e, st) {
      throw handleException(e, st);
    }
  }

  Future<List<ProgressUser>> getProgressRange(String userId, DateTime start, DateTime end) async {
    try {
      final startStr = start.toIso8601String().split('T')[0];
      final endStr = end.toIso8601String().split('T')[0];
      final response = await _supabase.from('progress_user').select().eq('user_id', userId).gte('date', startStr).lte('date', endStr).order('date', ascending: true);
      return (response as List).map((json) => ProgressUser.fromJson(json)).toList();
    } catch (e, st) {
      throw handleException(e, st);
    }
  }

  Future<void> saveProgress(ProgressUser progress) async {
    try {
      await _supabase.from('progress_user').upsert(progress.toJson(), onConflict: 'user_id, date',);
    } catch (e, st) {
      throw handleException(e, st);
    }
  }
}