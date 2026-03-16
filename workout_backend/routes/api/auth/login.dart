import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:shared/shared.dart';
import 'package:supabase/supabase.dart' hide HttpMethod;
import 'package:workout_backend/repositories/auth_repository.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final rawBody = await context.request.body();
  final body = json.decode(rawBody) as Map<String, dynamic>;
  final params = SignInParams.fromJson(body);

  final supabase = context.read<SupabaseClient>();
  final repository = AuthRepository(supabase);

  try {
    final response = await repository.signIn(params);
    return Response.json(
      body: {
        'user': response.user?.toJson(),
        'session': response.session?.toJson(),
      },
    );
  } catch (e) {
    return Response.json(
        statusCode: HttpStatus.unauthorized, body: {'error': e.toString()},);
  }
}
