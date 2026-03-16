import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:supabase/supabase.dart' hide HttpMethod;

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final body = Map<String, dynamic>.from(await context.request.json() as Map);
  final email = body['email'] as String;
  final typeStr = body['type'] as String;

  final supabase = context.read<SupabaseClient>();

  try {
    await supabase.auth.resend(
      email: email,
      type: OtpType.values
          .firstWhere((e) => e.name == typeStr, orElse: () => OtpType.signup),
    );
    return Response(statusCode: HttpStatus.noContent);
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'error': e.toString()},
    );
  }
}
