import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WorkoutRepository {
  final SupabaseClient _supabase;
  WorkoutRepository({SupabaseClient? supabase}): _supabase = supabase ?? Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getAllWorkouts() async {
    final response = await _supabase.from('workouts').select();
    debugPrint('[WorkoutRepository] getAllWorkouts found: ${response.length} items');
    return response;
  }

  Future<List<Map<String, dynamic>>> getWorkoutsByLevel(String level) async {
    final response = await _supabase.from('workouts').select().eq('level', level).order('id', ascending: true);
    debugPrint('[WorkoutRepository] getWorkoutsByLevel ($level) found: ${response.length} items');
    return response;
  }

  Future<Map<String, dynamic>> getWorkoutById(int id) async {
    return await _supabase.from('workouts').select().eq('id', id).single();
  }

  Future<List<Map<String, dynamic>>> getWorkoutItems(int workoutId) async {
    return await _supabase.from('workout_items').select().eq('workout_id', workoutId);
  }

  Future<List<Map<String, dynamic>>> getExercisesByIds(List<int> exerciseIds) async {
    if (exerciseIds.isEmpty) return [];
    return await _supabase.from('exercises').select().inFilter('id', exerciseIds);
  }

  Future<List<Map<String, dynamic>>> searchWorkouts(String query) async {
    final response = await _supabase.from('workouts').select().or('title.ilike.%$query%,description.ilike.%$query%').order('id', ascending: true);
    debugPrint('[WorkoutRepository] searchWorkouts ($query) found: ${response.length} items');
    return response;
  }

  Future<List<int>> getExerciseIdsByMuscleGroup(String muscleGroup) async {
    debugPrint('[WorkoutRepository] getExerciseIdsByMuscleGroup searching for: $muscleGroup');
    final response = await _supabase.from('exercises').select('id').eq('muscle_group', muscleGroup);   
    final ids = (response as List).map((e) => e['id'] as int).toList();
    debugPrint('[WorkoutRepository] getExerciseIdsByMuscleGroup found IDs: $ids');
    return ids;
  }

  Future<List<int>> getWorkoutIdsByExerciseIds(List<int> exerciseIds) async {
    if (exerciseIds.isEmpty) return [];
    final response = await _supabase.from('workout_items').select('workout_id').inFilter('exercise_id', exerciseIds);
    return (response as List).map((item) => item['workout_id'] as int).toSet().toList();
  }

  Future<List<Map<String, dynamic>>> getWorkoutsByIds(List<int> ids) async {
    if (ids.isEmpty) return [];
    final response = await _supabase.from('workouts').select().inFilter('id', ids).order('id', ascending: true);
    debugPrint('[WorkoutRepository] getWorkoutsByIds found: ${response.length} items');
    return response;
  }

}
