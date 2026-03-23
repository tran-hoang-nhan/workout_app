import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:supabase/supabase.dart' hide HttpMethod;
import 'package:workout_backend/repositories/auth_repository.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final body = await context.request.json() as Map<String, dynamic>;
  final password = body['password'] as String?;

  if (password == null) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'error': 'Password is required'},
    );
  }

  final supabase = context.read<SupabaseClient>();
  final repository = AuthRepository(supabase);

  try {
    await repository.updatePassword(password);
    return Response(statusCode: HttpStatus.noContent);
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': e.toString()},
    );
  }
}
