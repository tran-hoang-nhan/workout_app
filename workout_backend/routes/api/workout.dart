import 'dart:convert';
import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:supabase/supabase.dart' hide HttpMethod;
import 'package:workout_backend/repositories/workout_repository.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final supabase = context.read<SupabaseClient>();
  final repository = WorkoutRepository(supabase);

  try {
    final body = await context.request.json() as Map<String, dynamic>;
    final encoder = JsonEncoder.withIndent('  ');
    print('[POST /api/workout] Request Body:');
    print(encoder.convert(body));

    final weight = (body['weight'] as num).toDouble();
    final height = (body['height'] as num).toDouble();
    final goal = body['goal'] as String;
    final requirement = body['requirement'] as String?;
    final dietType = body['diet_type'] as String;
    final medicalConditions =
        List<String>.from(body['medical_conditions'] as List);

    final workoutPlan = await repository.generateAndSaveWorkout(
      weight: weight,
      height: height,
      goal: goal,
      dietType: dietType,
      medicalConditions: medicalConditions,
      requirement: requirement,
    );

    print('[POST /api/workout] Generated Plan:');
    print(encoder.convert(workoutPlan.toJson()));

    return Response.json(body: workoutPlan.toJson());
  } catch (e) {
    print('[POST /api/workout] ERROR: $e');
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': e.toString()},
    );
  }
}
