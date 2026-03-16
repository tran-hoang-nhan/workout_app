import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:shared/shared.dart';
import 'package:supabase/supabase.dart' hide HttpMethod;
import 'package:workout_backend/repositories/health_repository.dart';

Future<Response> onRequest(RequestContext context) async {
  final supabase = context.read<SupabaseClient>();
  final repository = HealthRepository(supabase);

  if (context.request.method == HttpMethod.get) {
    final params = context.request.uri.queryParameters;
    final userId = params['userId'];
    if (userId == null) return Response(statusCode: HttpStatus.badRequest);

    try {
      final data = await repository.getHealthData(userId);
      return Response.json(body: data?.toJson());
    } catch (e) {
      return Response.json(
          statusCode: HttpStatus.internalServerError,
          body: {'error': e.toString()},);
    }
  }

  if (context.request.method == HttpMethod.put) {
    try {
      final rawBody = await context.request.body();
      final body = json.decode(rawBody) as Map<String, dynamic>;
      final params = HealthUpdateParams.fromJson(body);
      await repository.updateFullProfile(params);
      return Response(statusCode: HttpStatus.noContent);
    } catch (e) {
      return Response.json(
          statusCode: HttpStatus.internalServerError,
          body: {'error': e.toString()},);
    }
  }

  return Response(statusCode: HttpStatus.methodNotAllowed);
}
