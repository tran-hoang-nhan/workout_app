import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:supabase/supabase.dart' hide HttpMethod;
import 'package:workout_backend/repositories/notification_repository.dart';

Future<Response> onRequest(RequestContext context) async {
  final supabase = context.read<SupabaseClient>();
  final repository = NotificationRepository(supabase);
  final userId = context.request.uri.queryParameters['userId'];

  if (userId == null) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'error': 'userId is required'},
    );
  }

  if (context.request.method == HttpMethod.get) {
    try {
      final notifications = await repository.getNotifications(userId);
      return Response.json(body: notifications.map((e) => e.toJson()).toList());
    } catch (e) {
      return Response.json(
        statusCode: HttpStatus.internalServerError,
        body: {'error': e.toString()},
      );
    }
  }

  return Response(statusCode: HttpStatus.methodNotAllowed);
}
