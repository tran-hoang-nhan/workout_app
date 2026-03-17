import 'dart:convert';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;
import 'package:shared/shared.dart';
import 'package:supabase/supabase.dart';

/// Repository for workout retrieval and AI-assisted generation.
class WorkoutRepository {
  /// Creates a workout repository backed by Supabase.
  WorkoutRepository(this._supabase);
  final SupabaseClient _supabase;
  final String _aiApiUrl = 'https://api.your-python-ai.com/generate';

  void _log(String msg) =>
      developer.log(msg, name: 'WorkoutRepository');

  /// Generates a workout plan via AI and stores the workout metadata.
  Future<WorkoutPlan> generateAndSaveWorkout({
    required double weight,
    required double height,
    required String goal,
  }) async {
    try {
      final aiResponse = await http.post(
        Uri.parse(_aiApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'weight': weight,
          'height': height,
          'goal': goal,
        }),
      );

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
      rethrow;
    }
  }

  /// Returns all workouts ordered by id ascending.
  Future<List<Workout>> getAllWorkouts() async {
    _log('getAllWorkouts called');
    final response =
        await _supabase.from('workouts').select().order('id', ascending: true);
    final workouts = (response as List)
        .map((json) => Workout.fromJson(json as Map<String, dynamic>))
        .toList();
    _log('getAllWorkouts returning ${workouts.length} items');
    return workouts;
  }

  /// Returns workouts filtered by level.
  Future<List<Workout>> getWorkoutsByLevel(String level) async {
    final response = await _supabase
        .from('workouts')
        .select()
        .eq('level', level)
        .order('id', ascending: true);
    return (response as List)
        .map((json) => Workout.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Returns workout details including ordered items and related exercises.
  Future<WorkoutDetail> getWorkoutDetail(int workoutId) async {
    final workoutData =
        await _supabase.from('workouts').select().eq('id', workoutId).single();
    final workout = Workout.fromJson(workoutData);

    final itemsData = await _supabase
        .from('workout_items')
        .select()
        .eq('workout_id', workoutId);
    final items = (itemsData as List)
        .map((data) => WorkoutItem.fromJson(data as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

    if (items.isEmpty) {
      return WorkoutDetail(workout: workout, items: [], exercises: []);
    }

    final exerciseIds = items.map((item) => item.exerciseId).toSet().toList();
    final exercisesData =
        await _supabase.from('exercises').select().inFilter('id', exerciseIds);
    final exercises = (exercisesData as List)
        .map((data) => Exercise.fromJson(data as Map<String, dynamic>))
        .toList();

    return WorkoutDetail(workout: workout, items: items, exercises: exercises);
  }

  /// Searches workouts by title or description.
  Future<List<Workout>> searchWorkouts(String query) async {
    // Simplified search logic for backend
    final response = await _supabase
        .from('workouts')
        .select()
        .or('title.ilike.*$query*,description.ilike.*$query*')
        .order('id', ascending: true);
    return (response as List)
        .map((json) => Workout.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Returns workouts matching a localized category filter.
  String _simplify(String s) {
    var str = s.toLowerCase();
    const vietnamese =
      'aáàảãạâấầẩẫậăắằẳẵặeéèẻẽẹêếềểễệiíìỉĩị'
      'oóòỏõọôốồổỗộơớờởỡợuúùủũụưứừửữựyýỳỷỹỵdđ';
    const latin =
      'aaaaaaaaaaaaaaaaaeeeeeeeeeeeeiiiiiii'
      'ooooooooooooooooooouuuuuuuuuuuuyyyyyydd';
    // Both now have 72 chars
    for (var i = 0; i < vietnamese.length; i++) {
      if (i < latin.length) {
        str = str.replaceAll(vietnamese[i], latin[i]);
      }
    }
    return str;
  }

  /// Returns workouts filtered by localized category keywords.
  Future<List<Workout>> getWorkoutsByCategory(String category) async {
    final rawKey = category.trim().toLowerCase();
    final key = _simplify(rawKey);
    _log(
      'getWorkoutsByCategory (Robust) called with: '
      '"$category" (simple: "$key")',
    );

    if (
        key.isEmpty ||
        key == 'all' ||
        key.contains('tatca') ||
        key.contains('all')) {
      _log('Matching "Tất cả" - returning all');
      return getAllWorkouts();
    }

    final (titleKeywords, _) = _mapFilterKeywords(category);
    final simpleKeywords = titleKeywords.map(_simplify).toList();

    final allWorkouts = await getAllWorkouts();
    _log(
      'Starting in-memory match for ${allWorkouts.length} workouts '
      'against $simpleKeywords',
    );

    final results = <Workout>[];

    for (final workout in allWorkouts) {
      final simpleTitle = _simplify(workout.title);
      final simpleDesc = _simplify(workout.description ?? '');

      _log('Checking ID ${workout.id}: "$simpleTitle"');
      
      var matched = false;
      for (final kw in simpleKeywords) {
        if (simpleTitle.contains(kw) || simpleDesc.contains(kw)) {
          _log('  MATCHED! kw="$kw"');
          matched = true;
          break;
        }
      }

      if (matched) {
        results.add(workout);
      }
    }

    _log('Robust filter returning ${results.length} items for "$category"');
    return results;
  }

  /// Maps UI category labels to searchable title and muscle keywords.
  (List<String> titleKeywords, List<String> muscleKeywords) _mapFilterKeywords(
    String category,
  ) {
    final key = _simplify(category.trim());

    if (key.contains('toan') || key.contains('body')) {
      return (
        ['toàn thân', 'toan than', 'full body'],
        ['toàn thân', 'toan than', 'full body'],
      );
    }
    if (key.contains('nguc') || key.contains('chest')) {
      return (['ngực', 'nguc', 'chest'], ['ngực', 'nguc', 'chest']);
    }
    if (key.contains('lung') || key.contains('back')) {
      return (['lưng', 'lung', 'back'], ['lưng', 'lung', 'back']);
    }
    if (key.contains('chan') || key.contains('leg')) {
      return (['chân', 'chan', 'legs'], ['chân', 'chan', 'legs']);
    }
    if (key.contains('tay') || key.contains('arm')) {
      return (['tay', 'arms', 'arm'], ['tay', 'arms', 'arm']);
    }
    if (key.contains('cardio')) {
      return (['cardio'], ['cardio']);
    }
    if (key.contains('yoga')) {
      return (['yoga'], ['yoga']);
    }
    if (key.contains('hiit')) {
      return (['hiit'], ['hiit']);
    }

    return ([category.toLowerCase()], [category.toLowerCase()]);
  }
}
