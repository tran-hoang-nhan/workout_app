import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:supabase/supabase.dart' hide HttpMethod;
import 'package:workout_backend/repositories/progress_repository.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final supabase = context.read<SupabaseClient>();
  final repository = ProgressRepository(supabase);

  try {
    final stats = await repository.getProgressStats(id);
    if (stats == null) {
      return Response.json(body: {});
    }
    return Response.json(body: stats.toJson());
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': e.toString()},
    );
  }
}
