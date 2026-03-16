import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared/shared.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ApiClient {
  final String _baseUrl = 'http://localhost:8080/api';

  // --- Helper ---
  Future<dynamic> _request(
    String method,
    String path, {
    Object? body,
    Map<String, String>? queryParams,
  }) async {
    final urlString = '$_baseUrl$path';
    final uri = Uri.parse(urlString).replace(queryParameters: queryParams);
    debugPrint('[ApiClient] $method Request: $uri');
    final session = Supabase.instance.client.auth.currentSession;
    final token = session?.accessToken;
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    try {
      final http.Response response;
      switch (method.toUpperCase()) {
        case 'POST':
          response =
              await http.post(uri, headers: headers, body: jsonEncode(body));
        case 'PUT':
          response =
              await http.put(uri, headers: headers, body: jsonEncode(body));
        case 'DELETE':
          response = await http.delete(uri, headers: headers);
        case 'GET':
        default:
          response = await http.get(uri, headers: headers);
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint('[ApiClient] Response (${response.statusCode}): ${response.body}');
        if (response.body.isEmpty) return null;
        try {
          return jsonDecode(response.body);
        } catch (e) {
          debugPrint('[ApiClient] JSON Decode Error: $e\nBody: ${response.body}');
          rethrow;
        }
      }
      throw Exception('API Error (${response.statusCode}): ${response.body}');
    } catch (e) {
      debugPrint('[ApiClient] Request Error: $e');
      rethrow;
    }
  }

  // --- Auth ---
  Future<Map<String, dynamic>> login(SignInParams p) async => 
      await _request('POST', '/auth/login', body: p.toJson());

  Future<Map<String, dynamic>> register(SignUpParams p) async => 
      await _request('POST', '/auth/register', body: p.toJson());

  Future<AppUser?> getProfile(String userId) async {
    final data = await _request('GET', '/auth/profile/$userId');
    return data != null ? AppUser.fromJson(data) : null;
  }

  Future<void> updateProfile(String userId, UpdateProfileParams p) async => 
      await _request('PUT', '/auth/profile/$userId', body: p.toJson());

  Future<Map<String, dynamic>> verifyOtp(
    String email,
    String token,
    String type,
  ) async =>
      await _request(
        'POST',
        '/auth/verify-otp',
        body: {'email': email, 'token': token, 'type': type},
      );

  Future<void> resendOtp(String email, String type) async => 
      await _request('POST', '/auth/resend-otp', body: {'email': email, 'type': type});

  Future<Map<String, dynamic>> completeRegistration(
    SignUpParams s,
    HealthUpdateParams h,
  ) async =>
      await _request('POST', '/auth/complete-registration', body: {
        'signUpParams': s.toJson(),
        'healthParams': h.toJson(),
      });

  // --- Workouts ---
  Future<WorkoutPlan> generateWorkout(WorkoutGenerationRequest r) async => 
      WorkoutPlan.fromJson(await _request('POST', '/workout', body: r.toJson()));

  Future<List<Workout>> getAllWorkouts({String? level}) async {
    final data = await _request('GET', '/workouts',
            queryParams: level != null ? {'level': level} : null)
        as List?;
    return data?.map((e) => Workout.fromJson(e)).toList() ?? [];
  }

  Future<WorkoutDetail> getWorkoutDetail(int id) async => 
      WorkoutDetail.fromJson(await _request('GET', '/workouts/$id'));

  Future<List<Workout>> searchWorkouts(String query) async {
    final data = await _request('GET', '/workouts/search', queryParams: {'q': query}) as List?;
    return data?.map((e) => Workout.fromJson(e)).toList() ?? [];
  }

  Future<List<Workout>> getWorkoutsByCategory(String cat) async {
    final data = await _request('GET', '/workouts/category/$cat') as List?;
    return data?.map((e) => Workout.fromJson(e)).toList() ?? [];
  }

  // --- Health ---
  Future<HealthData?> getHealthData(String userId) async {
    final data = await _request('GET', '/health', queryParams: {'userId': userId});
    return data != null ? HealthData.fromJson(data) : null;
  }

  Future<void> updateHealthProfile(HealthUpdateParams p) async => 
      await _request('PUT', '/health', body: p.toJson());

  Future<void> updateQuickMetrics({
    required String userId,
    double? weight,
    double? height,
  }) async =>
      await _request('PUT', '/health/quick', body: {
        'userId': userId,
        if (weight != null) 'weight': weight,
        if (height != null) 'height': height,
      });

  Future<DailyStats?> getDailyStats(String userId, DateTime date) async {
    final data = await _request('GET', '/health/daily-stats',
        queryParams: {'userId': userId, 'date': date.toIso8601String()});
    return data != null ? DailyStats.fromJson(data) : null;
  }

  Future<void> saveDailyStats(DailyStats stats) async => 
      await _request('POST', '/health/daily-stats', body: stats.toJson());

  Future<List<BodyMetric>> getWeightHistory(String userId) async {
    final data = await _request('GET', '/health/weight-history/$userId') as List?;
    return data?.map((e) => BodyMetric.fromJson(e)).toList() ?? [];
  }

  Future<void> addWeight( String userId, double weight, double? bmi, DateTime date) async =>
    await _request('POST', '/health/weight', body: {
      'user_id': userId,
      'weight': weight,
      'bmi': bmi,
      'date': date.toIso8601String(),
    }
  );

  Future<void> deleteWeight(int id) async => await _request('DELETE', '/health/weight/$id');

  // --- Progress ---
  Future<ProgressUser?> getDailyProgress(String userId, DateTime date) async {
    final data = await _request('GET', '/progress/daily',
        queryParams: {'userId': userId, 'date': date.toIso8601String()});
    return data != null ? ProgressUser.fromJson(data) : null;
  }

  Future<void> updateActivityProgress({
    required String userId,
    required DateTime date,
    int? addWaterMl,
    int? addWaterGlasses,
    int? addSteps,
    double? addEnergy,
    int? addDuration,
    int? addWorkouts,
  }) async =>
      await _request('POST', '/progress/daily', body: {
        'user_id': userId,
        'date': date.toIso8601String(),
        'addWaterMl': addWaterMl,
        'addWaterGlasses': addWaterGlasses,
        'addSteps': addSteps,
        'addEnergy': addEnergy,
        'addDuration': addDuration,
        'addWorkouts': addWorkouts,
      });

  Future<List<WorkoutHistory>> getWorkoutHistory(String userId) async {
    final data = await _request('GET', '/progress/workout-history/$userId') as List?;
    return data?.map((e) => WorkoutHistory.fromJson(e)).toList() ?? [];
  }

  Future<void> logWorkout(WorkoutHistory history) async => 
      await _request('POST', '/progress/workout-log', body: history.toJson());

  Future<ProgressStats?> getProgressStats(String userId) async {
    final data = await _request('GET', '/progress/stats/$userId');
    return data != null ? ProgressStats.fromJson(data) : null;
  }

  // --- Avatar ---
  Future<void> updateAvatar(String userId, String? avatarUrl) async =>
      await _request('POST', '/user/avatar',
          body: {'user_id': userId, 'avatar_url': avatarUrl});

  // --- Exercises (New for proxy) ---
  Future<List<Exercise>> getExercises() async {
    // Implement or proxy to backend
    return [];
  }
}

class WorkoutGenerationRequest {
  final double weight;
  final double height;
  final String goal;
  WorkoutGenerationRequest({
    required this.weight,
    required this.height,
    required this.goal,
  });
  Map<String, dynamic> toJson() => {
    'weight': weight,
    'height': height,
    'goal': goal,
  };
}
