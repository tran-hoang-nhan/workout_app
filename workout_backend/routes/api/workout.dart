import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:supabase/supabase.dart' hide HttpMethod;
import 'package:workout_backend/repositories/workout_repository.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final supabase = context.read<SupabaseClient>();
  final aiApiUrl = context.read<String?>();
  final repository = WorkoutRepository(supabase, aiApiUrl: aiApiUrl);

  try {
    final body = await context.request.json() as Map<String, dynamic>;

    final weight = (body['weight'] as num).toDouble();
    final height = (body['height'] as num).toDouble();
    final goal = body['goal'] as String;
    final requirement = body['requirement'] as String?;
    final dietType = body['diet_type'] as String;
    final medicalConditions =
        List<String>.from(body['medical_conditions'] as List);

    String? userId;
    try {
      final authHeader = context.request.headers['Authorization'] ?? context.request.headers['authorization'];
      if (authHeader != null && authHeader.startsWith('Bearer ')) {
        final token = authHeader.substring(7);
        final userResponse = await supabase.auth.getUser(token);
        userId = userResponse.user?.id;
      }
    } catch (_) {
      // Auth might be optional or fail, proceed with null userId
    }

    final workoutPlan = await repository.generateWorkoutSuggestion(
      userId: userId,
      weight: weight,
      height: height,
      goal: goal,
      dietType: dietType,
      medicalConditions: medicalConditions,
      requirement: requirement,
    );


    return Response.json(body: workoutPlan.toJson());
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': e.toString()},
    );
  }
}
