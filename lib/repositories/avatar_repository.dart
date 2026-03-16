import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/api_client.dart';
import 'dart:typed_data';

class AvatarRepository {
  final ApiClient _apiClient;
  final SupabaseClient _supabase;

  AvatarRepository({ApiClient? apiClient, SupabaseClient? supabase})
    : _apiClient = apiClient ?? ApiClient(),
      _supabase = supabase ?? Supabase.instance.client;

  // Storage operations remain client-side as they are direct bucket interactions
  Future<String> uploadImageToStorage({
    required String userId,
    required Uint8List bytes,
    required String fileName,
  }) async {
    final path = '$userId/$fileName';
    await _supabase.storage
        .from('avatars')
        .uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
        );
    return path;
  }

  String getPublicUrl(String path) {
    return _supabase.storage.from('avatars').getPublicUrl(path);
  }

  Future<void> updateProfileAvatar(String userId, String? avatarUrl) async {
    await _apiClient.updateAvatar(userId, avatarUrl);
  }

  Future<void> deleteImage(String path) async {
    await _supabase.storage.from('avatars').remove([path]);
  }
}
