import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:supabase/supabase.dart' hide HttpMethod;
import 'package:workout_backend/repositories/workout_repository.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final q = context.request.uri.queryParameters['q'];
  if (q == null) {
    return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'Missing query parameter q'},);
  }

  final supabase = context.read<SupabaseClient>();
  final repository = WorkoutRepository(supabase);

  try {
    final workouts = await repository.searchWorkouts(q);
    return Response.json(body: workouts.map((e) => e.toJson()).toList());
  } catch (e) {
    return Response.json(
        statusCode: HttpStatus.internalServerError,
        body: {'error': e.toString()},);
  }
}
