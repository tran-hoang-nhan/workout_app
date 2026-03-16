import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:supabase/supabase.dart' hide HttpMethod;

Future<Response> onRequest(RequestContext context) async {
  final supabase = context.read<SupabaseClient>();

  if (context.request.method == HttpMethod.post) {
    final body =
        Map<String, dynamic>.from(await context.request.json() as Map);
    final userId = body['user_id'] as String;
    final avatarUrl = body['avatar_url'] as String?;

    try {
      await supabase.from('profiles').update({
        'avatar_url': avatarUrl,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
      return Response(statusCode: HttpStatus.noContent);
    } catch (e) {
      return Response.json(
          statusCode: HttpStatus.internalServerError,
          body: {'error': e.toString()},);
    }
  }

  return Response(statusCode: HttpStatus.methodNotAllowed);
}
