import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:shared/shared.dart';
import 'package:supabase/supabase.dart' hide HttpMethod;
import 'package:workout_backend/repositories/exercise_repository.dart';

Future<Response> onRequest(RequestContext context) async {
  final supabase = context.read<SupabaseClient>();
  final repository = ExerciseRepository(supabase);

  if (context.request.method == HttpMethod.get) {
    try {
      final queryParams = context.request.uri.queryParameters;
      final muscleGroup = queryParams['muscle_group'];
      
      late final List<Exercise> exercises;
      if (muscleGroup != null) {
        exercises = await repository.getExercisesByMuscleGroup(muscleGroup);
      } else {
        exercises = await repository.getExercises();
      }
      
      return Response.json(body: exercises.map((e) => e.toJson()).toList());
    } catch (e) {
      return Response.json(
        statusCode: HttpStatus.internalServerError,
        body: {'error': e.toString()},
      );
    }
  }

  return Response(statusCode: HttpStatus.methodNotAllowed);
}
