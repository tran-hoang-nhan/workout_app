import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/app_error.dart';

class AvatarRepository {
  final SupabaseClient _supabase;
  AvatarRepository({SupabaseClient? supabase}): _supabase = supabase ?? Supabase.instance.client;
  
  Future<String> uploadImageToStorage({required String userId, required Uint8List bytes, required String fileName,}) async {
    try {
      final path = '$userId/$fileName';
      debugPrint('AvatarRepository: Uploading image bytes to storage: $path');
      await _supabase.storage.from('avatars').uploadBinary(path,bytes,fileOptions: const FileOptions(cacheControl: '3600', upsert: true),);
      debugPrint('AvatarRepository: Image uploaded successfully');
      return path;
    } catch (e, st) {
      debugPrint('AvatarRepository Exception (uploadImageToStorage): $e');
      throw handleException(e, st);
    }
  }

  String getPublicUrl(String path) {
    return _supabase.storage.from('avatars').getPublicUrl(path);
  }

  Future<Map<String, dynamic>?> getProfileAvatar(String userId) async {
    try {
      debugPrint('AvatarRepository: Fetching profile avatar for user: $userId');
      return await _supabase.from('profiles').select('avatar_url').eq('id', userId).maybeSingle();
    } catch (e, st) {
      debugPrint('AvatarRepository Exception (getProfileAvatar): $e');
      throw handleException(e, st);
    }
  }

  Future<void> updateProfileAvatar(String userId, String? avatarUrl) async {
    try {
      debugPrint('AvatarRepository: Updating profile avatar URL in DB: $avatarUrl');
      await _supabase.from('profiles').update({
        'avatar_url': avatarUrl,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
      debugPrint('AvatarRepository: Profile updated successfully');
    } catch (e, st) {
      debugPrint('AvatarRepository Exception (updateProfileAvatar): $e');
      throw handleException(e, st);
    }
  }

  Future<void> deleteImage(String path) async {
    try {
      debugPrint('AvatarRepository: Deleting image from storage: $path');
      await _supabase.storage.from('avatars').remove([path]);
      debugPrint('AvatarRepository: Image deleted successfully');
    } catch (e, st) {
      debugPrint('AvatarRepository Exception (deleteImage): $e');
      throw handleException(e, st);
    }
  }
}