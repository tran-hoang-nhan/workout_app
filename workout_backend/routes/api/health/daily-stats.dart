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
    final dateStr = params['date'];
    if (userId == null || dateStr == null) {
      return Response(statusCode: HttpStatus.badRequest);
    }

    try {
      final stats =
          await repository.getDailyStats(userId, DateTime.parse(dateStr));
      return Response.json(body: stats?.toJson());
    } catch (e) {
      return Response.json(
          statusCode: HttpStatus.internalServerError,
          body: {'error': e.toString()},);
    }
  }

  if (context.request.method == HttpMethod.post) {
    final body = await context.request.json();
    final stats = DailyStats.fromJson(body as Map<String, dynamic>);
    try {
      await repository.saveDailyStats(stats);
      return Response(statusCode: HttpStatus.noContent);
    } catch (e) {
      return Response.json(
          statusCode: HttpStatus.internalServerError,
          body: {'error': e.toString()},);
    }
  }

  return Response(statusCode: HttpStatus.methodNotAllowed);
}
