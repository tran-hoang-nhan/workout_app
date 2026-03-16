import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:supabase/supabase.dart' hide HttpMethod;
import 'package:workout_backend/repositories/health_repository.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final supabase = context.read<SupabaseClient>();
  final repository = HealthRepository(supabase);

  if (context.request.method == HttpMethod.get) {
    try {
      final history = await repository.getWeightHistory(id);
      return Response.json(body: history.map((e) => e.toJson()).toList());
    } catch (e) {
      return Response.json(
          statusCode: HttpStatus.internalServerError,
          body: {'error': e.toString()},);
    }
  }

  return Response(statusCode: HttpStatus.methodNotAllowed);
}
