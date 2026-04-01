import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:supabase/supabase.dart' hide HttpMethod;
import 'package:workout_backend/repositories/workout_repository.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  // Lấy parameter "cat" từ URL, vd: /category?cat=Toàn thân
  final category = context.request.uri.queryParameters['cat'];
  if (category == null || category.isEmpty) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'error': 'Missing query parameter cat'},
    );
  }

  final supabase = context.read<SupabaseClient>();
  final repository = WorkoutRepository(supabase);

  try {
    // Không cần Uri.decodeComponent vì context.request.uri.queryParameters đã tự động decode
    final workouts = await repository.getWorkoutsByCategory(category);
    return Response.json(body: workouts.map((e) => e.toJson()).toList());
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': e.toString()},
    );
  }
}
