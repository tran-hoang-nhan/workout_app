import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:dotenv/dotenv.dart';
import 'package:shared/shared.dart';
import 'package:supabase/supabase.dart' hide HttpMethod;
import 'package:workout_backend/repositories/auth_repository.dart';
import 'package:workout_backend/repositories/health_repository.dart';

const _authOptions = AuthClientOptions(authFlowType: AuthFlowType.implicit);

class ConfigException implements Exception {
  const ConfigException(this.message);

  final String message;

  @override
  String toString() => message;
}

String _readAdminKeyOrThrow(DotEnv env) {
  final serviceRoleKey = env['SUPABASE_SERVICE_ROLE_KEY']?.trim();
  if (serviceRoleKey != null && serviceRoleKey.isNotEmpty) {
    return serviceRoleKey;
  }

  final secretKey = env['SUPABASE_SECRET_KEY']?.trim();
  if (secretKey != null && secretKey.isNotEmpty) {
    return secretKey;
  }

  throw const ConfigException(
    'Missing SUPABASE_SECRET_KEY (or SUPABASE_SERVICE_ROLE_KEY)',
  );
}

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

  try {
    final supabase = context.read<SupabaseClient>();
    final env = DotEnv(includePlatformEnvironment: true)..load();
    final url = env['SUPABASE_URL'] ?? '';
    if (url.isEmpty) {
      throw const ConfigException('Missing SUPABASE_URL');
    }
    final adminKey = _readAdminKeyOrThrow(env);
    final adminSupabase = SupabaseClient(
      url,
      adminKey,
      authOptions: _authOptions,
    );
    final authRepo = AuthRepository(supabase, adminSupabase: adminSupabase);
    final healthRepo = HealthRepository(supabase);

    // 1. Sign Up
    final authResponse = await authRepo.signUp(signUpParams);
    if (authResponse.user == null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'Failed to create user'},
      );
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
  } on DuplicateEmailException catch (e) {
    return Response.json(
      statusCode: HttpStatus.conflict,
      body: {'error': e.message, 'code': 'user_already_exists'},
    );
  } on ConfigException catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': e.message},
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': e.toString()},
    );
  }
}
