import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/exercise.dart';
import '../utils/storage_utils.dart';

class ExerciseRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Exercise>> getExercises() async {
    try {
      final response = await _supabase
          .from('exercises')
          .select()
          .order('id', ascending: true);

      return (response as List)
          .map(
            (json) => Exercise.fromJson(
              processExerciseJson(_supabase, json as Map<String, dynamic>),
            ),
          )
          .toList();
    } catch (e) {
      throw Exception('Lỗi khi tải danh sách bài tập: $e');
    }
  }

  Future<Exercise?> getExerciseById(int id) async {
    try {
      final response = await _supabase
          .from('exercises')
          .select()
          .eq('id', id)
          .single();

      return Exercise.fromJson(processExerciseJson(_supabase, response));
    } catch (e) {
      throw Exception('Lỗi khi tải bài tập: $e');
    }
  }

  Future<List<Exercise>> searchExercises(String query) async {
    try {
      final response = await _supabase
          .from('exercises')
          .select()
          .ilike('name', '%$query%')
          .order('id', ascending: true);

      return (response as List)
          .map(
            (json) => Exercise.fromJson(
              processExerciseJson(_supabase, json as Map<String, dynamic>),
            ),
          )
          .toList();
    } catch (e) {
      throw Exception('Lỗi khi tìm kiếm bài tập: $e');
    }
  }

  Future<List<Exercise>> getExercisesByMuscleGroup(String muscleGroup) async {
    try {
      final response = await _supabase
          .from('exercises')
          .select()
          .ilike('muscle_group', '%$muscleGroup%')
          .order('id', ascending: true);

      return (response as List)
          .map(
            (json) => Exercise.fromJson(
              processExerciseJson(_supabase, json as Map<String, dynamic>),
            ),
          )
          .toList();
    } catch (e) {
      throw Exception('Lỗi khi tải bài tập theo nhóm cơ: $e');
    }
  }
}