import 'package:dart_frog/dart_frog.dart';
import 'package:dotenv/dotenv.dart';
import 'package:supabase/supabase.dart' hide HttpMethod;

SupabaseClient? _supabaseClient;

Handler middleware(Handler handler) {
  return (context) async {
    final env = DotEnv(includePlatformEnvironment: true)..load();
    final url = env['SUPABASE_URL'] ?? '';
    final key = env['SUPABASE_ANON_KEY'] ?? '';
    _supabaseClient ??= SupabaseClient(url, key);

    if (context.request.method == HttpMethod.options) {
      return Response(
        statusCode: 204,
        headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
          'Access-Control-Allow-Headers': 'Origin, Content-Type, Authorization',
        },
      );
    }

    final authHeader = context.request.headers['Authorization'] ?? context.request.headers['authorization'];
    SupabaseClient client;

    if (authHeader != null && authHeader.startsWith('Bearer ')) {
      // Re-initialize client with user's access token
      final token = authHeader.substring(7);
      client = SupabaseClient(
        url,
        key,
        headers: {'Authorization': 'Bearer $token'},
      );
    } else {
      client = SupabaseClient(url, key);
    }

    final aiApiUrl = env['AI_API_URL'];
    final response = await handler
        .use(provider<SupabaseClient>((_) => client))
        .use(provider<String?>((_) => aiApiUrl))(context);
    return response.copyWith(
      headers: {
        ...response.headers,
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': 'Origin, Content-Type, Authorization',
      },
    );
  };
}
