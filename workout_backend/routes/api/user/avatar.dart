import 'dart:io';
import 'dart:typed_data';
import 'package:dart_frog/dart_frog.dart';
import 'package:supabase/supabase.dart' hide HttpMethod;

Future<Response> onRequest(RequestContext context) async {
  final supabase = context.read<SupabaseClient>();

  if (context.request.method == HttpMethod.post) {
    try {
      final contentType = context.request.headers['content-type'] ?? '';
      if (contentType.contains('multipart/form-data')) {
        final formData = await context.request.formData();
        final file = formData.files['avatar'];
        final userId = formData.fields['user_id'];

        if (file == null || userId == null) {
          return Response.json(
            statusCode: HttpStatus.badRequest,
            body: {'error': 'Missing avatar file or user_id'},
          );
        }

        final bytes = await file.readAsBytes();
        final path = '$userId/${file.name}';

        // 1. Upload to storage (upsert)
        await supabase.storage.from('avatars').uploadBinary(
          path, Uint8List.fromList(bytes),
          fileOptions: const FileOptions(cacheControl: '3600', upsert: true),);

        // 2. Get public URL
        final publicUrl = supabase.storage.from('avatars').getPublicUrl(path);

        // 3. Update profile DB
        await supabase.from('profiles').update({
          'avatar_url': publicUrl,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', userId);

        return Response.json(body: {'avatar_url': publicUrl});
      } else {
        final body = Map<String, dynamic>.from(await context.request.json() as Map);
        final userId = body['user_id'] as String;
        final avatarUrl = body['avatar_url'] as String?;

        await supabase.from('profiles').update({
          'avatar_url': avatarUrl,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', userId);

        return Response(statusCode: HttpStatus.noContent);
      }
    } catch (e) {
      return Response.json(
        statusCode: HttpStatus.internalServerError,
        body: {'error': e.toString()},
      );
    }
  }

  if (context.request.method == HttpMethod.delete) {
    try {
      final queryParams = context.request.uri.queryParameters;
      final path = queryParams['path'];
      final userId = queryParams['user_id'];

      if (path == null || userId == null) {
        return Response.json(
          statusCode: HttpStatus.badRequest,
          body: {'error': 'Missing path or user_id'},
        );
      }

      // Remove from storage
      await supabase.storage.from('avatars').remove([path]);

      // Update profile DB
      await supabase.from('profiles').update({
        'avatar_url': null,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);

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
