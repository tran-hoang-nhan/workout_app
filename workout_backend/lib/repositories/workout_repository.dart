import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:shared/shared.dart';
import 'package:supabase/supabase.dart';

/// Repository for workout-related data operations and AI generation.
class WorkoutRepository {
  WorkoutRepository(this._supabase);
  final SupabaseClient _supabase;
  final String _aiApiUrl = 'https://api.your-python-ai.com/generate';

  /// Generates a workout plan using an external AI service and saves metadata.
  Future<WorkoutPlan> generateAndSaveWorkout({
    required double weight,
    required double height,
    required String goal,
    required String dietType,
    required List<String> medicalConditions,
    String? requirement,
  }) async {
    try {
      final aiResponse = await http.post(
        Uri.parse(_aiApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'weight': weight,
          'height': height,
          'goal': goal,
          'requirement': requirement,
          'diet_type': dietType,
          'medical_conditions': medicalConditions,
        }),
      );

      developer.log(
        'AI Response Status: ${aiResponse.statusCode}',
        name: 'WorkoutRepository',
      );
      try {
        final dynamic decoded = jsonDecode(aiResponse.body);
        final encoder = JsonEncoder.withIndent('  ');
        developer.log(
          'AI Response Body:\n${encoder.convert(decoded)}',
          name: 'WorkoutRepository',
        );
      } catch (_) {
        developer.log(
          'AI Response Body (Raw): ${aiResponse.body}',
          name: 'WorkoutRepository',
        );
      }

      if (aiResponse.statusCode != 200) {
        throw Exception(
          'Failed to generate workout from AI: ${aiResponse.body}',
        );
      }

      final aiData = jsonDecode(aiResponse.body) as Map<String, dynamic>;
      final workoutPlan = WorkoutPlan.fromJson(aiData);

      await _supabase.from('workouts').insert({
        'title': workoutPlan.title,
        'goal': workoutPlan.goal,
        'level': workoutPlan.level,
        'notes': workoutPlan.notes,
      });

      return workoutPlan;
    } catch (e) {
      developer.log(
        'Error in generateAndSaveWorkout: $e',
        name: 'WorkoutRepository',
        error: e,
      );
      rethrow;
    }
  }

  /// Returns all workouts ordered by ID ascending.
  Future<List<Workout>> getAllWorkouts() async {
    final response = await _supabase
        .from('workouts')
        .select()
        .order('id', ascending: true);
    return (response as List)
        .map((dynamic json) => Workout.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Returns workouts filtered by workout level.
  Future<List<Workout>> getWorkoutsByLevel(String level) async {
    final response = await _supabase
        .from('workouts')
        .select()
        .eq('level', level)
        .order('id', ascending: true);
    return (response as List)
        .map((dynamic json) => Workout.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Returns detailed information for a specific workout.
  Future<WorkoutDetail> getWorkoutDetail(int workoutId) async {
    final workoutData = await _supabase
        .from('workouts')
        .select()
        .eq('id', workoutId)
        .single();
    final workout = Workout.fromJson(workoutData);

    final itemsData = await _supabase
        .from('workout_items')
        .select()
        .eq('workout_id', workoutId);
    final items = (itemsData as List)
        .map((dynamic data) => WorkoutItem.fromJson(data as Map<String, dynamic>))
        .toList();
    items.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

    if (items.isEmpty) {
      return WorkoutDetail(workout: workout, items: [], exercises: []);
    }

    final exerciseIds = items.map((item) => item.exerciseId).toSet().toList();
    final exercisesData = await _supabase
        .from('exercises')
        .select()
        .inFilter('id', exerciseIds);
    final exercises = (exercisesData as List)
        .map((dynamic data) => Exercise.fromJson(data as Map<String, dynamic>))
        .toList();

    return WorkoutDetail(workout: workout, items: items, exercises: exercises);
  }

  /// Searches workouts by title or description matching the query.
  Future<List<Workout>> searchWorkouts(String query) async {
    final response = await _supabase
        .from('workouts')
        .select()
        .or('title.ilike.*$query*,description.ilike.*$query*')
        .order('id', ascending: true);
    return (response as List)
        .map((dynamic json) => Workout.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Returns workouts matching a specific category label.
  Future<List<Workout>> getWorkoutsByCategory(String category) async {
    final key = category.trim().toLowerCase();
    if (key == 'tất cả' || key == 'all') return getAllWorkouts();

    final (titleKeywords, muscleKeywords) = _mapFilterKeywords(category);

    final titleOr = titleKeywords.map((k) => 'title.ilike.*$k*').join(',');
    final descOr = titleKeywords.map((k) => 'description.ilike.*$k*').join(',');

    final byTitleDesc = await _supabase
        .from('workouts')
        .select()
        .or('$titleOr,$descOr');

    final resultsMap = {
      for (final dynamic json in byTitleDesc as List)
        (json as Map<String, dynamic>)['id'] as int: Workout.fromJson(json)
    };

    final muscleOr = muscleKeywords.map((k) => 'muscle_group.ilike.*$k*').join(',');
    final exercisesByMuscle = await _supabase
        .from('exercises')
        .select('id')
        .or(muscleOr);

    final exerciseIds = (exercisesByMuscle as List)
        .map((dynamic e) => (e as Map<String, dynamic>)['id'] as int)
        .toList();
    if (exerciseIds.isNotEmpty) {
      final workoutItems = await _supabase
          .from('workout_items')
          .select('workout_id')
          .inFilter('exercise_id', exerciseIds);

      final workoutIds = (workoutItems as List)
          .map((dynamic item) => (item as Map<String, dynamic>)['workout_id'] as int)
          .toSet()
          .toList();
      if (workoutIds.isNotEmpty) {
        final workoutsByIds = await _supabase
            .from('workouts')
            .select()
            .inFilter('id', workoutIds);
        for (final dynamic json in workoutsByIds as List) {
          final workoutJson = json as Map<String, dynamic>;
          resultsMap[workoutJson['id'] as int] = Workout.fromJson(workoutJson);
        }
      }
    }

    final merged = resultsMap.values.toList()
      ..sort((a, b) => a.id.compareTo(b.id));
    return merged;
  }

  (List<String> titleKeywords, List<String> muscleKeywords) _mapFilterKeywords(
    String category,
  ) {
    final key = category.trim().toLowerCase();
    switch (key) {
      case 'toàn thân':
        return (
          ['toàn thân', 'toan than', 'full body'],
          ['toàn thân', 'toan than', 'full body']
        );
      case 'ngực':
        return (['ngực', 'nguc', 'chest'], ['ngực', 'nguc', 'chest']);
      case 'lưng':
        return (['lưng', 'lung', 'back'], ['lưng', 'lung', 'back']);
      case 'chân':
        return (['chân', 'chan', 'legs'], ['chân', 'chan', 'legs']);
      case 'tay':
        return (['tay', 'arms', 'arm'], ['tay', 'arms', 'arm']);
      case 'cardio':
        return (['cardio'], ['cardio']);
      case 'yoga':
        return (['yoga'], ['yoga']);
      case 'hiit':
        return (['hiit'], ['hiit']);
      default:
        return ([key], [key]);
    }
  }
}
