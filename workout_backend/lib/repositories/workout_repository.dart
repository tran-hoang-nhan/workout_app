import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:shared/shared.dart';
import 'package:supabase/supabase.dart';

/// Repository for workout-related data operations and AI generation.
class WorkoutRepository {
  WorkoutRepository(this._supabase, {String? aiApiUrl}): _aiApiUrl = aiApiUrl ?? 'http://localhost:8000/api/v1/chat/workout';
  final SupabaseClient _supabase;
  final String _aiApiUrl;

  Future<WorkoutPlan> generateWorkoutSuggestion({
    required String? userId,
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

      if (aiResponse.statusCode != 200) {
        if (userId != null) {
          await _supabase.from('workout_ai_suggestions').insert({
            'user_id': userId,
            'user_prompt': requirement,
            'status': 'failed',
          });
        }
        throw Exception(
          'Failed to generate workout from AI: ${aiResponse.body}',
        );
      }

      final aiData = jsonDecode(aiResponse.body) as Map<String, dynamic>;

      if (userId != null) {
        try {
          await _supabase.from('workout_ai_suggestions').insert({
            'user_id': userId,
            'health_context_snapshot': {
              'weight': weight,
              'height': height,
              'goal': goal,
              'diet_type': dietType,
              'medical_conditions': medicalConditions,
            },
            'user_prompt': requirement,
            'ai_response_data': aiData,
            'status': 'completed',
          });
        } catch (e) {
          developer.log('Failed to log AI suggestion: $e', name: 'WorkoutRepository', error: e);
        }
      }

      final aiPlan = WorkoutPlan.fromJson(aiData);
      final aiItems = aiPlan.items ?? [];

      List<Exercise> fullExercises = [];
      if (aiItems.isNotEmpty) {
        final List<int> exerciseIds = aiItems.map((e) => e.exerciseId).toList();
        final exercisesData = await _supabase
            .from('exercises')
            .select()
            .inFilter('id', exerciseIds);
        fullExercises = (exercisesData as List)
            .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      return WorkoutPlan(
        id: null,
        title: aiPlan.title,
        goal: aiPlan.goal.isNotEmpty ? aiPlan.goal : goal,
        level: aiPlan.level,
        exercises: fullExercises,
        items: aiItems,
        notes: aiPlan.notes,
      );
    } catch (e) {
      rethrow;
    }
  }
  /// Filter ALL
  Future<List<Workout>> getAllWorkouts() async {
    final response = await _supabase
        .from('workouts')
        .select()
        .order('id', ascending: true);
    return (response as List)
        .map((dynamic json) => Workout.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Filter by level
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

  /// Returns detail workout 
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

  /// Searching workout
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
  ///
  /// Dùng join trong bộ nhớ (workouts + workout_items + exercises) thay vì
  /// chuỗi `.or(title.ilike...)` — PostgREST dễ trả [] khi title không chứa
  /// đúng từ khóa tiếng Việt nhưng bài vẫn có động tác đúng nhóm cơ.
  Future<List<Workout>> getWorkoutsByCategory(String category) async {
    final key = category.trim().toLowerCase();
    if (key == 'tất cả' || key == 'all') return getAllWorkouts();

    final (titleKeywords, muscleKeywords) = _mapFilterKeywords(category);

    final workouts = await getAllWorkouts();
    if (workouts.isEmpty) return [];

    final itemsData = await _supabase.from('workout_items').select('workout_id, exercise_id');
    final items = itemsData as List;

    final exerciseIds = items
        .map((dynamic e) => (e as Map<String, dynamic>)['exercise_id'] as int)
        .toSet()
        .toList();

    final idToMuscle = <int, String>{};
    if (exerciseIds.isNotEmpty) {
      final exercisesData = await _supabase
          .from('exercises')
          .select('id, muscle_group')
          .inFilter('id', exerciseIds);
      for (final dynamic row in exercisesData as List) {
        final m = row as Map<String, dynamic>;
        final id = m['id'] as int;
        final mg = m['muscle_group'] as String?;
        idToMuscle[id] = (mg ?? '').toLowerCase();
      }
    }

    final workoutToExerciseIds = <int, List<int>>{};
    for (final dynamic row in items) {
      final m = row as Map<String, dynamic>;
      final wid = m['workout_id'] as int;
      final eid = m['exercise_id'] as int;
      (workoutToExerciseIds[wid] ??= <int>[]).add(eid);
    }

    bool textMatches(String? title, String? description, List<String> kws) {
      final text = '${title ?? ''} ${description ?? ''}'.toLowerCase();
      return kws.any((k) => k.isNotEmpty && text.contains(k.toLowerCase()));
    }

    bool muscleMatches(String muscleLower, List<String> kws) {
      if (muscleLower.isEmpty) return false;
      return kws.any((k) => k.isNotEmpty && muscleLower.contains(k.toLowerCase()));
    }

    final out = <Workout>[];
    for (final w in workouts) {
      if (textMatches(w.title, w.description, titleKeywords)) {
        out.add(w);
        continue;
      }
      final eids = workoutToExerciseIds[w.id] ?? const <int>[];
      var hit = false;
      for (final eid in eids) {
        final mg = idToMuscle[eid] ?? '';
        if (muscleMatches(mg, muscleKeywords)) {
          hit = true;
          break;
        }
      }
      if (hit) out.add(w);
    }

    out.sort((a, b) => a.id.compareTo(b.id));
    return out;
  }

  (List<String> titleKeywords, List<String> muscleKeywords) _mapFilterKeywords(
    String category,
  ) {
    final key = category.trim().toLowerCase();
    switch (key) {
      case 'toàn thân':
      case 'toan than':
        return (
          [
            'toàn thân',
            'toan than',
            'full body',
            'fullbody',
            'total body',
            'whole body',
          ],
          [
            'toàn thân',
            'toan than',
            'full body',
            'fullbody',
            'total body',
            'whole body',
          ],
        );
      case 'ngực':
      case 'nguc':
        return (
          ['ngực', 'nguc', 'chest', 'pectoral', 'pec'],
          ['ngực', 'nguc', 'chest', 'pectoral', 'pec'],
        );
      case 'lưng':
      case 'lung':
        return (['lưng', 'lung', 'back'], ['lưng', 'lung', 'back']);
      case 'chân':
      case 'chan':
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
