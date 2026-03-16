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

  try {
    await repository.logWorkout(history);
    return Response(statusCode: HttpStatus.noContent);
  } catch (e) {
    return Response.json(
        statusCode: HttpStatus.internalServerError,
        body: {'error': e.toString()},);
  }
}
