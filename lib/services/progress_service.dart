import '../models/workout_history.dart';
import '../models/body_metric.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProgressService {
  final SupabaseClient _supabaseClient;

  ProgressService({SupabaseClient? supabaseClient})
      : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  /// Lấy lịch sử tập luyện của user
  Future<List<WorkoutHistory>> getWorkoutHistory({
    required String userId,
    int limit = 50,
  }) async {
    try {
      final response = await _supabaseClient
          .from('workout_history')
          .select()
          .eq('user_id', userId)
          .order('completed_at', ascending: false)
          .limit(limit);

      return (response as List)
          .map((data) => WorkoutHistory.fromJson(data))
          .toList();
    } catch (e) {
      throw Exception('Lỗi lấy lịch sử tập: ${e.toString()}');
    }
  }

  /// Lấy lịch sử body metrics (cân nặng, BMI,...)
  Future<List<BodyMetric>> getBodyMetricsHistory({
    required String userId,
    int limit = 50,
  }) async {
    try {
      final response = await _supabaseClient
          .from('body_metrics')
          .select()
          .eq('user_id', userId)
          .order('recorded_at', ascending: false)
          .limit(limit);

      return (response as List)
          .map((data) => BodyMetric.fromJson(data))
          .toList();
    } catch (e) {
      throw Exception('Lỗi lấy lịch sử body metrics: ${e.toString()}');
    }
  }

  /// Tính toán tiến độ (calories burned, duration,...)
  Future<({
    double totalCalories,
    int totalDuration,
    int totalWorkouts,
    double avgCaloriesPerSession,
  })> getProgressStats({
    required String userId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      var query = _supabaseClient
          .from('workout_history')
          .select()
          .eq('user_id', userId);

      if (fromDate != null) {
        query = query.gte('completed_at', fromDate.toIso8601String());
      }
      if (toDate != null) {
        query = query.lte('completed_at', toDate.toIso8601String());
      }

      final response = await query.order('completed_at', ascending: false);

      final histories = (response as List)
          .map((data) => WorkoutHistory.fromJson(data))
          .toList();

      double totalCalories = 0;
      int totalDuration = 0;

      for (var history in histories) {
        totalCalories += history.totalCaloriesBurned ?? 0;
        totalDuration += history.durationSeconds ?? 0;
      }

      final avgCalories = histories.isEmpty
          ? 0.0
          : totalCalories / histories.length;

      return (
        totalCalories: totalCalories,
        totalDuration: totalDuration,
        totalWorkouts: histories.length,
        avgCaloriesPerSession: avgCalories,
      );
    } catch (e) {
      throw Exception('Lỗi tính toán tiến độ: ${e.toString()}');
    }
  }

  /// Ghi lại lịch sử workout mới
  Future<WorkoutHistory> recordWorkout({
    required String userId,
    required int workoutId,
    required String workoutTitle,
    required double caloriesBurned,
    required int durationSeconds,
  }) async {
    try {
      final response = await _supabaseClient
          .from('workout_history')
          .insert({
            'user_id': userId,
            'workout_id': workoutId,
            'workout_title_snapshot': workoutTitle,
            'total_calories_burned': caloriesBurned,
            'duration_seconds': durationSeconds,
            'completed_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      return WorkoutHistory.fromJson(response);
    } catch (e) {
      throw Exception('Lỗi ghi lại lịch sử workout: ${e.toString()}');
    }
  }

  /// Ghi lại body metric mới
  Future<BodyMetric> recordBodyMetric({
    required String userId,
    required double weight,
    double? bmi,
  }) async {
    try {
      final response = await _supabaseClient
          .from('body_metrics')
          .insert({
            'user_id': userId,
            'weight': weight,
            'bmi': bmi,
            'recorded_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      return BodyMetric.fromJson(response);
    } catch (e) {
      throw Exception('Lỗi ghi lại body metric: ${e.toString()}');
    }
  }

  /// Lấy body metric mới nhất
  Future<BodyMetric?> getLatestBodyMetric(String userId) async {
    try {
      final response = await _supabaseClient
          .from('body_metrics')
          .select()
          .eq('user_id', userId)
          .order('recorded_at', ascending: false)
          .limit(1);

      if ((response as List).isEmpty) return null;

      return BodyMetric.fromJson(response.first);
    } catch (e) {
      throw Exception('Lỗi lấy body metric mới nhất: ${e.toString()}');
    }
  }
}
