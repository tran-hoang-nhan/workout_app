import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:supabase/supabase.dart' hide HttpMethod;

Future<Response> onRequest(RequestContext context, String id) async {
  final supabase = context.read<SupabaseClient>();

  if (context.request.method == HttpMethod.delete) {
    try {
      final recordId = int.tryParse(id);
      if (recordId == null) return Response(statusCode: HttpStatus.badRequest);

      await supabase.from('body_metrics').delete().eq('id', recordId);
      return Response(statusCode: HttpStatus.noContent);
    } catch (e) {
      return Response.json(
          statusCode: HttpStatus.internalServerError,
          body: {'error': e.toString()},);
    }
  }

  return Response(statusCode: HttpStatus.methodNotAllowed);
}
