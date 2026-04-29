import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:shared/shared.dart';
import 'package:supabase/supabase.dart' hide HttpMethod;
import 'package:workout_backend/repositories/progress_repository.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final body = await context.request.json();
  final history = WorkoutHistory.fromJson(body as Map<String, dynamic>);

  final supabase = context.read<SupabaseClient>();
  final repository = ProgressRepository(supabase);

  bool historyLogged = false;
  try {
    await repository.logWorkout(history);
    historyLogged = true;
  } catch (e) {
    print('[WorkoutLog] Failed to log detailed workout history: $e');
  }
  
  try {
    // Always update daily activity progress (calories, duration, etc.)
    await repository.updateActivityProgress(
      userId: history.userId,
      date: history.completedAt,
      addEnergy: history.totalCaloriesBurned,
      addDuration: history.durationSeconds,
      addWorkouts: 1,
    );
    
    return Response(statusCode: HttpStatus.noContent);
  } catch (e) {
    // If progress update fails, return error only if history also failed
    if (!historyLogged) {
      return Response.json(
        statusCode: HttpStatus.internalServerError,
        body: {'error': e.toString()},
      );
    }
    // If history succeeded, we still return success but maybe with a warning header?
    // For now, just return noContent since the primary goal is counting.
    return Response(statusCode: HttpStatus.noContent);
  }
}
