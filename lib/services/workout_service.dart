import '../models/workout.dart';
import '../models/workout_item.dart';
import '../models/exercise.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WorkoutService {
  final SupabaseClient _supabaseClient;

  WorkoutService({SupabaseClient? supabaseClient})
      : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  /// Lấy tất cả workouts
  Future<List<Workout>> getAllWorkouts() async {
    try {
      final response = await _supabaseClient
          .from('workouts')
          .select()
          .order('id', ascending: true);

      return (response as List)
          .map((data) => Workout.fromJson(data))
          .toList();
    } catch (e) {
      throw Exception('Lỗi lấy danh sách workouts: ${e.toString()}');
    }
  }

  /// Lấy workouts theo level
  Future<List<Workout>> getWorkoutsByLevel(String level) async {
    try {
      final response = await _supabaseClient
          .from('workouts')
          .select()
          .eq('level', level)
          .order('id', ascending: true);

      return (response as List)
          .map((data) => Workout.fromJson(data))
          .toList();
    } catch (e) {
      throw Exception('Lỗi lấy workouts theo level: ${e.toString()}');
    }
  }

  /// Lấy chi tiết workout (bao gồm các exercises)
  Future<({Workout workout, List<WorkoutItem> items, List<Exercise> exercises})>
      getWorkoutDetail(int workoutId) async {
    try {
      // Lấy thông tin workout
      final workoutData = await _supabaseClient
          .from('workouts')
          .select()
          .eq('id', workoutId)
          .single();

      final workout = Workout.fromJson(workoutData);

      // Lấy workout items
      final itemsData = await _supabaseClient
          .from('workout_items')
          .select()
          .eq('workout_id', workoutId)
          .order('order_index', ascending: true);

      final items = (itemsData as List)
          .map((data) => WorkoutItem.fromJson(data))
          .toList();

      // Lấy exercises
      final exerciseIds = items.map((item) => item.exerciseId).toList();
      final exercisesData = await _supabaseClient
          .from('exercises')
          .select()
          .inFilter('id', exerciseIds);

      final exercises = (exercisesData as List)
          .map((data) => Exercise.fromJson(data))
          .toList();

      return (workout: workout, items: items, exercises: exercises);
    } catch (e) {
      throw Exception('Lỗi lấy chi tiết workout: ${e.toString()}');
    }
  }

  /// Tìm kiếm workouts
  Future<List<Workout>> searchWorkouts(String query) async {
    try {
      final response = await _supabaseClient
          .from('workouts')
          .select()
          .or('title.ilike.%$query%,description.ilike.%$query%')
          .order('id', ascending: true);

      return (response as List)
          .map((data) => Workout.fromJson(data))
          .toList();
    } catch (e) {
      throw Exception('Lỗi tìm kiếm workouts: ${e.toString()}');
    }
  }

  /// Lấy workouts theo category (muscleGroup từ exercises)
  Future<List<Workout>> getWorkoutsByCategory(String category) async {
    try {
      // Lấy exercises theo muscle group
      final exercisesData = await _supabaseClient
          .from('exercises')
          .select('id')
          .eq('muscle_group', category);

      final exerciseIds =
          (exercisesData as List).map((e) => e['id'] as int).toList();

      if (exerciseIds.isEmpty) return [];

      // Lấy workout items chứa những exercises này
      final itemsData = await _supabaseClient
          .from('workout_items')
          .select('workout_id')
          .inFilter('exercise_id', exerciseIds);

      final workoutIds = (itemsData as List)
          .map((item) => item['workout_id'] as int)
          .toSet() // Loại bỏ duplicates
          .toList();

      if (workoutIds.isEmpty) return [];

      // Lấy workouts
      final workoutsData = await _supabaseClient
          .from('workouts')
          .select()
          .inFilter('id', workoutIds)
          .order('id', ascending: true);

      return (workoutsData as List)
          .map((data) => Workout.fromJson(data))
          .toList();
    } catch (e) {
      throw Exception('Lỗi lấy workouts theo category: ${e.toString()}');
    }
  }
}
