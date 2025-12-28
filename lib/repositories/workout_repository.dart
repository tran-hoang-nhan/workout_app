import 'package:supabase_flutter/supabase_flutter.dart';

class WorkoutRepository {
  final SupabaseClient _supabase;
  WorkoutRepository({SupabaseClient? supabase}): _supabase = supabase ?? Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getAllWorkouts() async {
    return await _supabase.from('workouts').select();
  }

  Future<List<Map<String, dynamic>>> getWorkoutsByLevel(String level) async {
    return await _supabase.from('workouts').select().eq('level', level).order('id', ascending: true);
  }

  Future<Map<String, dynamic>> getWorkoutById(int id) async {
    return await _supabase.from('workouts').select().eq('id', id).single();
  }

  Future<List<Map<String, dynamic>>> getWorkoutItems(int workoutId) async {
    return await _supabase.from('workout_items').select().eq('workout_id', workoutId);
  }

  Future<List<Map<String, dynamic>>> getExercisesByIds(List<int> exerciseIds) async {
    return await _supabase.from('exercises').select().inFilter('id', exerciseIds);
  }

  Future<List<Map<String, dynamic>>> searchWorkouts(String query) async {
    return await _supabase.from('workouts').select().or('title.ilike.%$query%,description.ilike.%$query%').order('id', ascending: true);
  }

  Future<List<int>> getExerciseIdsByMuscleGroup(String muscleGroup) async {
    final response = await _supabase.from('exercises').select('id').eq('muscle_group', muscleGroup);   
    return (response as List).map((e) => e['id'] as int).toList();
  }

  Future<List<int>> getWorkoutIdsByExerciseIds(List<int> exerciseIds) async {
    if (exerciseIds.isEmpty) return [];
    final response = await _supabase.from('workout_items').select('workout_id').inFilter('exercise_id', exerciseIds);
    return (response as List).map((item) => item['workout_id'] as int).toSet().toList();
  }

  Future<List<Map<String, dynamic>>> getWorkoutsByIds(List<int> ids) async {
    if (ids.isEmpty) return [];
    return await _supabase.from('workouts').select().inFilter('id', ids).order('id', ascending: true);
  }
}
