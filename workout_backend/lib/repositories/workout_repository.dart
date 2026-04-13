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
    // Giải mã URL (ví dụ: Ng%E1%BB%B1c -> Ngực) 
    final decodedCategory = Uri.decodeComponent(category);
    final key = decodedCategory.trim().toLowerCase();
    print('DEBUG: [WorkoutRepository] getWorkoutsByCategory called with category="$category", decoded="$decodedCategory", key="$key"');

    if (key == 'tất cả' || key == 'all') {
      print('DEBUG: [WorkoutRepository] Fetching all workouts...');
      return getAllWorkouts();
    }

    final (titleKeywords, muscleKeywords) = _mapFilterKeywords(decodedCategory);
    print('DEBUG: [WorkoutRepository] Mapping keywords: titleKeywords=$titleKeywords, muscleKeywords=$muscleKeywords');

    final workouts = await getAllWorkouts();
    print('DEBUG: [WorkoutRepository] Total workouts from DB: ${workouts.length}');
    if (workouts.isEmpty) return [];

    final itemsData = await _supabase.from('workout_items').select('workout_id, exercise_id');
    final items = itemsData as List;
    print('DEBUG: [WorkoutRepository] Total items from DB: ${items.length}');

    final exerciseIds = items
        .map((dynamic e) => (e as Map<String, dynamic>)['exercise_id'] as int)
        .toSet()
        .toList();
    print('DEBUG: [WorkoutRepository] Unique exercises needed: ${exerciseIds.length}');

    final idToMuscle = <int, String>{};
    if (exerciseIds.isNotEmpty) {
      final exercisesData = await _supabase
          .from('exercises')
          .select('id, muscle_group')
          .inFilter('id', exerciseIds);
      final exerciseList = exercisesData as List;
      print('DEBUG: [WorkoutRepository] Exercises fetched from DB: ${exerciseList.length}');

      for (final dynamic row in exerciseList) {
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
      bool matched = false;
      if (textMatches(w.title, w.description, titleKeywords)) {
        print('DEBUG: [WorkoutRepository] Workout "${w.title}" (id: ${w.id}) matched by TITLE');
        matched = true;
      } else {
        final eids = workoutToExerciseIds[w.id] ?? const <int>[];
        for (final eid in eids) {
          final mg = idToMuscle[eid] ?? '';
          if (muscleMatches(mg, muscleKeywords)) {
            print('DEBUG: [WorkoutRepository] Workout "${w.title}" (id: ${w.id}) matched by EXERCISE muscle_group: "$mg"');
            matched = true;
            break;
          }
        }
      }
      if (matched) out.add(w);
    }

    print('DEBUG: [WorkoutRepository] Final matched count: ${out.length}');
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
        final kws = [
          'toàn thân',
          'toan than',
          'full body',
          'fullbody',
          'full_body',
          'total body',
          'whole body',
        ];
        return (kws, kws);
      case 'ngực':
      case 'nguc':
        final kws = ['ngực', 'nguc', 'chest', 'pectoral', 'pec', 'pectorals'];
        return (kws, kws);
      case 'lưng':
      case 'lung':
        final kws = ['lưng', 'lung', 'back', 'lats', 'traps', 'lower back'];
        return (kws, kws);
      case 'chân':
      case 'chan':
        final kws = [
          'chân',
          'chan',
          'legs',
          'leg',
          'quads',
          'hamstrings',
          'calves',
          'glutes',
        ];
        return (kws, kws);
      case 'tay':
        final kws = [
          'tay',
          'arms',
          'arm',
          'biceps',
          'triceps',
          'forearms',
          'bicep',
          'tricep',
        ];
        return (kws, kws);
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

  /// Returns a list of past AI workout suggestions for the specified user.
  Future<List<AISuggestionHistory>> getAISuggestionsHistory(String userId) async {
    final response = await _supabase
        .from('workout_ai_suggestions')
        .select()
        .eq('user_id', userId)
        .order('id', ascending: false);

    final historyList = (response as List)
        .map((dynamic json) => AISuggestionHistory.fromJson(json as Map<String, dynamic>))
        .toList();

    if (historyList.isEmpty) return [];

    // Collect all unique exercise IDs across all history items
    final Set<int> exerciseIds = {};
    for (final history in historyList) {
      if (history.plan != null && history.plan!.items != null) {
        for (final item in history.plan!.items!) {
          exerciseIds.add(item.exerciseId);
        }
      }
    }

    if (exerciseIds.isEmpty) return historyList;

    // Fetch all needed exercises in one batch
    final exercisesData = await _supabase
        .from('exercises')
        .select()
        .inFilter('id', exerciseIds.toList());
    
    final allExercises = (exercisesData as List)
        .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
        .toList();
    
    final exerciseMap = { for (final ex in allExercises) ex.id : ex };

    // Map exercises back to each history item's plan
    return historyList.map((history) {
      if (history.plan != null && history.plan!.items != null) {
        final planExercises = <Exercise>[];
        for (final item in history.plan!.items!) {
          final ex = exerciseMap[item.exerciseId];
          if (ex != null) {
            planExercises.add(ex);
          }
        }
        
        // Return enriched history with full exercises definitions, 
        // while preserving the original workout items (steps).
        return history.copyWith(
          plan: history.plan!.copyWith(
            exercises: planExercises,
            items: history.plan!.items, // Explicitly keep items
          ),
        );
      }
      return history;
    }).toList();
  }
}
