import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:shared/shared.dart';
import 'package:supabase/supabase.dart' hide HttpMethod;
import 'package:workout_backend/repositories/auth_repository.dart';
import 'package:workout_backend/repositories/health_repository.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final rawBody = await context.request.body();
  final body = json.decode(rawBody) as Map<String, dynamic>;
  final signUpParams =
      SignUpParams.fromJson(body['signUpParams'] as Map<String, dynamic>);
  final healthParams =
      HealthUpdateParams.fromJson(body['healthParams'] as Map<String, dynamic>);

  final supabase = context.read<SupabaseClient>();
  final authRepo = AuthRepository(supabase);
  final healthRepo = HealthRepository(supabase);

  try {
    // 1. Sign Up
    final authResponse = await authRepo.signUp(signUpParams);
    if (authResponse.user == null) {
      return Response.json(
          statusCode: HttpStatus.badRequest,
          body: {'error': 'Failed to create user'},);
    }

    // 2. Initialize Health Profile
    final healthParamsWithId = HealthUpdateParams(
      userId: authResponse.user!.id,
      age: healthParams.age,
      weight: healthParams.weight,
      height: healthParams.height,
      gender: healthParams.gender,
      activityLevel: healthParams.activityLevel,
      goal: healthParams.goal,
      dietType: healthParams.dietType,
      waterIntake: healthParams.waterIntake,
      injuries: healthParams.injuries,
      medicalConditions: healthParams.medicalConditions,
      allergies: healthParams.allergies,
      waterReminderEnabled: healthParams.waterReminderEnabled,
      waterReminderInterval: healthParams.waterReminderInterval,
    );
    await healthRepo.updateFullProfile(healthParamsWithId);

    return Response.json(
      body: {
        'user': authResponse.user?.toJson(),
        'session': authResponse.session?.toJson(),
      },
    );
  } catch (e) {
    return Response.json(
        statusCode: HttpStatus.internalServerError,
        body: {'error': e.toString()},);
  }
}
