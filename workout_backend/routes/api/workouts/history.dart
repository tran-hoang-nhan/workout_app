import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:supabase/supabase.dart' hide HttpMethod;
import 'package:workout_backend/repositories/workout_repository.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final supabase = context.read<SupabaseClient>();
  final repository = WorkoutRepository(supabase);

  try {
    String? userId;
    final authHeader = context.request.headers['Authorization'] ?? context.request.headers['authorization'];
    
    if (authHeader != null && authHeader.startsWith('Bearer ')) {
      final token = authHeader.substring(7);
      final userResponse = await supabase.auth.getUser(token);
      userId = userResponse.user?.id;
    }

    if (userId == null) {
      return Response(statusCode: HttpStatus.unauthorized);
    }

    final history = await repository.getAISuggestionsHistory(userId);
    return Response.json(body: history.map((e) => e.toJson()).toList());
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': e.toString()},
    );
  }
}
