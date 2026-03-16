import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:supabase/supabase.dart' hide HttpMethod;
import 'package:workout_backend/repositories/workout_repository.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final workoutId = int.tryParse(id);
  if (workoutId == null) {
    return Response.json(
        statusCode: HttpStatus.badRequest, body: {'error': 'Invalid ID'},);
  }

  final supabase = context.read<SupabaseClient>();
  final repository = WorkoutRepository(supabase);

  try {
    final detail = await repository.getWorkoutDetail(workoutId);
    return Response.json(body: detail.toJson());
  } catch (e) {
    return Response.json(
        statusCode: HttpStatus.internalServerError,
        body: {'error': e.toString()},);
  }
}
