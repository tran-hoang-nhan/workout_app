import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:supabase/supabase.dart' hide HttpMethod;
import 'package:workout_backend/repositories/health_repository.dart';

Future<Response> onRequest(RequestContext context) async {
  final supabase = context.read<SupabaseClient>();
  final repository = HealthRepository(supabase);

  if (context.request.method == HttpMethod.post) {
    final body = Map<String, dynamic>.from(await context.request.json() as Map);
    try {
      await repository.addWeightRecord(
        userId: body['user_id'] as String,
        weight: (body['weight'] as num).toDouble(),
        bmi: (body['bmi'] as num?)?.toDouble(),
        date: DateTime.parse(body['date'] as String),
      );
      return Response(statusCode: HttpStatus.noContent);
    } catch (e) {
      return Response.json(
        statusCode: HttpStatus.internalServerError,
        body: {'error': e.toString()},
      );
    }
  }

  return Response(statusCode: HttpStatus.methodNotAllowed);
}
