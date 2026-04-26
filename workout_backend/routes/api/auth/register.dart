import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:dotenv/dotenv.dart';
import 'package:shared/shared.dart';
import 'package:supabase/supabase.dart' hide HttpMethod;
import 'package:workout_backend/repositories/auth_repository.dart';

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
  final params = SignUpParams.fromJson(body);

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
    final repository = AuthRepository(supabase, adminSupabase: adminSupabase);

    final response = await repository.signUp(params);
    return Response.json(
      body: {
        'user': response.user?.toJson(),
        'session': response.session?.toJson(),
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
      statusCode: HttpStatus.badRequest,
      body: {'error': e.toString()},
    );
  }
}
