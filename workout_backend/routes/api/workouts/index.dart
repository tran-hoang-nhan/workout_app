import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:shared/shared.dart';
import 'package:supabase/supabase.dart' hide HttpMethod;
import 'package:workout_backend/repositories/workout_repository.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final params = context.request.uri.queryParameters;
  final level = params['level'];

  final supabase = context.read<SupabaseClient>();
  final repository = WorkoutRepository(supabase);

  try {
    List<Workout> workouts;
    if (level != null) {
      workouts = await repository.getWorkoutsByLevel(level);
    } else {
      workouts = await repository.getAllWorkouts();
    }
    return Response.json(body: workouts.map((e) => e.toJson()).toList());
  } catch (e) {
    return Response.json(
        statusCode: HttpStatus.internalServerError,
        body: {'error': e.toString()},);
  }
}
