import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/app_error.dart';
import '../utils/storage_utils.dart';

class WorkoutRepository {
  final SupabaseClient _supabase;
  WorkoutRepository({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getAllWorkouts() async {
    try {
      final response = await _supabase.from('workouts').select().order('id', ascending: true);
      debugPrint( '[WorkoutRepository] getAllWorkouts found: ${response.length} items',);
      return (response as List)
          .map(
            (json) =>
              processWorkoutJson(_supabase, json),
          )
          .toList();
    } catch (e, st) {
      throw handleException(e, st);
    }
  }

  Future<List<Map<String, dynamic>>> getWorkoutsByLevel(String level) async {
    try {
      final response = await _supabase
          .from('workouts')
          .select()
          .eq('level', level)
          .order('id', ascending: true);
      debugPrint(
        '[WorkoutRepository] getWorkoutsByLevel ($level) found: ${response.length} items',
      );
      return (response as List).map( (json) => processWorkoutJson(_supabase, json as Map<String, dynamic>),)
          .toList();
    } catch (e, st) {
      throw handleException(e, st);
    }
  }

  Future<Map<String, dynamic>> getWorkoutById(int id) async {
    try {
      final response = await _supabase.from('workouts').select().eq('id', id).single();
      return processWorkoutJson(_supabase, response);
    } catch (e, st) {
      throw handleException(e, st);
    }
  }

  Future<List<Map<String, dynamic>>> getWorkoutItems(int workoutId) async {
    try {
      final response = await _supabase.from('workout_items').select().eq('workout_id', workoutId);
      debugPrint('[WorkoutRepository] getWorkoutItems ($workoutId) found: ${response.length} items',);
      return response;
    } catch (e, st) {
      throw handleException(e, st);
    }
  }

  Future<List<Map<String, dynamic>>> getExercisesByIds(
    List<int> exerciseIds,
  ) async {
    try {
      if (exerciseIds.isEmpty) return [];
      final response = await _supabase.from('exercises').select().inFilter('id', exerciseIds);
      debugPrint('[WorkoutRepository] getExercisesByIds (${exerciseIds.length} ids) found: ${response.length} exercises',);
      return response;
    } catch (e, st) {
      throw handleException(e, st);
    }
  }

  Future<List<Map<String, dynamic>>> searchWorkouts(String query) async {
    try {
      final response = await _supabase.from('workouts').select().or('title.ilike.%$query%,description.ilike.%$query%').order('id', ascending: true);
      debugPrint('[WorkoutRepository] searchWorkouts ($query) found: ${response.length} items',);
      return (response as List).map((json) => processWorkoutJson(_supabase, json),).toList();
    } catch (e, st) {
      throw handleException(e, st);
    }
  }

  Future<List<int>> getExerciseIdsByMuscleGroup(String muscleGroup) async {
    try {
      debugPrint('[WorkoutRepository] getExerciseIdsByMuscleGroup searching for: $muscleGroup',);
      final response = await _supabase.from('exercises').select('id').eq('muscle_group', muscleGroup);
      final ids = (response as List).map((e) => e['id'] as int).toList();
      debugPrint('[WorkoutRepository] getExerciseIdsByMuscleGroup found IDs: $ids',);
      return ids;
    } catch (e, st) {
      throw handleException(e, st);
    }
  }

  Future<List<int>> getWorkoutIdsByExerciseIds(List<int> exerciseIds) async {
    try {
      if (exerciseIds.isEmpty) return [];
      final response = await _supabase.from('workout_items').select('workout_id').inFilter('exercise_id', exerciseIds);
      return (response as List).map((item) => item['workout_id'] as int).toSet().toList();
    } catch (e, st) {
      throw handleException(e, st);
    }
  }

  Future<List<Map<String, dynamic>>> getWorkoutsByIds(List<int> ids) async {
    try {
      if (ids.isEmpty) return [];
      final response = await _supabase.from('workouts').select().inFilter('id', ids).order('id', ascending: true);
      debugPrint('[WorkoutRepository] getWorkoutsByIds found: ${response.length} items',);
      return (response as List).map((json) =>processWorkoutJson(_supabase, json),).toList();
    } catch (e, st) {
      throw handleException(e, st);
    }
  }
}
