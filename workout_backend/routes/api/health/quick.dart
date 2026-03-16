import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:supabase/supabase.dart' hide HttpMethod;
import 'package:workout_backend/repositories/health_repository.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.put) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final supabase = context.read<SupabaseClient>();
  final repository = HealthRepository(supabase);

  try {
    final rawBody = await context.request.body();
    final body = json.decode(rawBody) as Map<String, dynamic>;

    final userId = body['userId'] as String?;
    final weight = body['weight'] as num?;
    final height = body['height'] as num?;

    if (userId == null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'Missing userId'},
      );
    }

    await repository.updateQuickMetrics(
      userId: userId,
      weight: weight?.toDouble(),
      height: height?.toDouble(),
    );

    return Response(statusCode: HttpStatus.noContent);
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': e.toString()},
    );
  }
}
