import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/workout.dart';
import '../models/workout_item.dart';
import '../models/exercise.dart';
import '../repositories/workout_repository.dart';

class WorkoutService {
  final WorkoutRepository _workoutRepository;
  final SupabaseClient _supabase = Supabase.instance.client;
  
  WorkoutService({WorkoutRepository? repository}): _workoutRepository = repository ?? WorkoutRepository();

  /// Chuyển đổi storage path thành public URL nếu cần
  String? _convertToPublicUrl(String? url, String bucketName) {
    if (url == null || url.isEmpty) return null;
    
    // Nếu đã là full URL (bắt đầu với http/https), trả về nguyên
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    
    // Nếu là storage path, chuyển đổi thành public URL
    try {
      return _supabase.storage.from(bucketName).getPublicUrl(url);
    } catch (e) {
      debugPrint('⚠️ Lỗi chuyển đổi URL trong WorkoutService: $e (URL: $url)');
      return url;
    }
  }

  /// Xử lý và chuyển đổi URLs trong JSON response của exercise
  Map<String, dynamic> _processExerciseJson(Map<String, dynamic> json) {
    final processed = Map<String, dynamic>.from(json);
    
    // Chuyển đổi animation_url nếu có
    if (processed['animation_url'] != null) {
      processed['animation_url'] = _convertToPublicUrl(
        processed['animation_url'] as String?,
        'exercises',
      );
    }
    
    // Chuyển đổi thumbnail_url nếu có
    if (processed['thumbnail_url'] != null) {
      processed['thumbnail_url'] = _convertToPublicUrl(
        processed['thumbnail_url'] as String?,
        'exercises',
      );
    }
    
    return processed;
  }

  Future<List<Workout>> getAllWorkouts() async {
    final response = await _workoutRepository.getAllWorkouts();
    return response.map((data) => Workout.fromJson(data)).toList();
  }

  Future<List<Workout>> getWorkoutsByLevel(String level) async {
    final response = await _workoutRepository.getWorkoutsByLevel(level);
    return response.map((data) => Workout.fromJson(data)).toList();
  }

  Future<({Workout workout, List<WorkoutItem> items, List<Exercise> exercises})> getWorkoutDetail(int workoutId) async {
    final workoutData = await _workoutRepository.getWorkoutById(workoutId);
    final workout = Workout.fromJson(workoutData);
    final itemsData = await _workoutRepository.getWorkoutItems(workoutId);
  
    List<WorkoutItem> items = itemsData.map((data) => WorkoutItem.fromJson(data)).toList();
    // Sort items by orderIndex
    items.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    
    if (items.isEmpty) {
      return (workout: workout, items: <WorkoutItem>[], exercises: <Exercise>[]);
    }

    final exerciseIds = items.map((item) => item.exerciseId).toList();
    final exercisesData = await _workoutRepository.getExercisesByIds(exerciseIds);
    
    // Create a map of exercise by ID for easier lookup
    final exerciseMap = <int, Exercise>{};
    for (var data in exercisesData) {
      final processedData = _processExerciseJson(data);
      final exercise = Exercise.fromJson(processedData);
      exerciseMap[exercise.id] = exercise;
    }
    
    // Sort exercises to match the order of items
    List<Exercise> exercises = items
        .map((item) => exerciseMap[item.exerciseId])
        .whereType<Exercise>()
        .toList();

    return (workout: workout, items: items, exercises: exercises);
  }

  Future<List<Workout>> searchWorkouts(String query) async {
    final response = await _workoutRepository.searchWorkouts(query);
    return response.map((data) => Workout.fromJson(data)).toList();
  }

  Future<List<Workout>> getWorkoutsByCategory(String category) async {
    final muscleGroup = _mapCategoryToMuscleGroup(category);
    final exerciseIds = await _workoutRepository.getExerciseIdsByMuscleGroup(muscleGroup);
    if (exerciseIds.isEmpty) return [];

    final workoutIds = await _workoutRepository.getWorkoutIdsByExerciseIds(exerciseIds);
    if (workoutIds.isEmpty) return [];

    final workoutsData = await _workoutRepository.getWorkoutsByIds(workoutIds);
    return workoutsData.map((data) => Workout.fromJson(data)).toList();
  }

  String _mapCategoryToMuscleGroup(String category) {
    switch (category.toLowerCase()) {
      case 'sức mạnh':
        return 'strength';
      case 'cardio':
        return 'cardio';
      case 'yoga':
        return 'yoga';
      case 'hiit':
        return 'hiit';
      default:
        return category.toLowerCase();
    }
  }
}