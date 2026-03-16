import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:shared/shared.dart';
import 'package:supabase/supabase.dart' hide HttpMethod;
import 'package:workout_backend/repositories/auth_repository.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final supabase = context.read<SupabaseClient>();
  final repository = AuthRepository(supabase);

  if (context.request.method == HttpMethod.get) {
    try {
      final profile = await repository.getUserProfile(id);
      return Response.json(body: profile?.toJson());
    } catch (e) {
      return Response.json(
          statusCode: HttpStatus.internalServerError,
          body: {'error': e.toString()},);
    }
  }

  if (context.request.method == HttpMethod.put) {
    try {
      final body = await context.request.json();
      final params = UpdateProfileParams.fromJson(body as Map<String, dynamic>);

      await supabase.from('profiles').update({
        'full_name': params.fullName,
        if (params.gender != null) 'gender': params.gender,
        if (params.goal != null) 'goal': params.goal,
        if (params.dateOfBirth != null)
          'date_of_birth': params.dateOfBirth?.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', id);

      return Response(statusCode: HttpStatus.noContent);
    } catch (e) {
      return Response.json(
          statusCode: HttpStatus.internalServerError,
          body: {'error': e.toString()},);
    }
  }

  return Response(statusCode: HttpStatus.methodNotAllowed);
}
