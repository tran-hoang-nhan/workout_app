import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:supabase/supabase.dart' hide HttpMethod;
import 'package:workout_backend/repositories/progress_repository.dart';

Future<Response> onRequest(RequestContext context) async {
  final supabase = context.read<SupabaseClient>();
  final repository = ProgressRepository(supabase);

  if (context.request.method == HttpMethod.get) {
    final params = context.request.uri.queryParameters;
    final userId = params['userId'];
    final dateStr = params['date'];
    if (userId == null || dateStr == null) {
      return Response(statusCode: HttpStatus.badRequest);
    }

    try {
      final progress =
          await repository.getProgress(userId, DateTime.parse(dateStr));
      return Response.json(body: progress?.toJson());
    } catch (e) {
      return Response.json(
        statusCode: HttpStatus.internalServerError,
        body: {'error': e.toString()},
      );
    }
  }

  if (context.request.method == HttpMethod.post) {
    final body = Map<String, dynamic>.from(await context.request.json() as Map);
    try {
      await repository.updateActivityProgress(
        userId: body['user_id'] as String,
        date: DateTime.parse(body['date'] as String),
        addWaterMl: body['addWaterMl'] as int?,
        addWaterGlasses: body['addWaterGlasses'] as int?,
        addSteps: body['addSteps'] as int?,
        addEnergy: (body['addEnergy'] as num?)?.toDouble(),
        addDuration: body['addDuration'] as int?,
        addWorkouts: body['addWorkouts'] as int?,
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
