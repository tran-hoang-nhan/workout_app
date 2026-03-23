import 'package:shared/shared.dart';
import 'package:supabase/supabase.dart';

/// Repository responsible for exercise-related data.
class ExerciseRepository {
  /// Creates an exercise repository backed by Supabase.
  ExerciseRepository(this._supabase);
  final SupabaseClient _supabase;

  /// Gets all exercises.
  Future<List<Exercise>> getExercises() async {
    final response = await _supabase.from('exercises').select().order('name');
    return (response as List<dynamic>)
        .map((e) => Exercise.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// Gets an exercise by ID.
  Future<Exercise?> getExerciseById(int id) async {
    final response = await _supabase
        .from('exercises')
        .select()
        .eq('id', id)
        .maybeSingle();
    if (response == null) return null;
    return Exercise.fromJson(Map<String, dynamic>.from(response as Map));
  }

  /// Searches exercises by name.
  Future<List<Exercise>> searchExercises(String query) async {
    final response = await _supabase
        .from('exercises')
        .select()
        .ilike('name', '%$query%')
        .order('name');
    return (response as List<dynamic>)
        .map((e) => Exercise.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// Gets exercises by muscle group.
  Future<List<Exercise>> getExercisesByMuscleGroup(String muscleGroup) async {
    final response = await _supabase
        .from('exercises')
        .select()
        .eq('muscle_group', muscleGroup)
        .order('name');
    return (response as List<dynamic>)
        .map((e) => Exercise.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}
