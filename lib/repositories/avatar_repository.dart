import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/app_error.dart';

class AvatarRepository {
  final SupabaseClient _supabase;
  AvatarRepository({SupabaseClient? supabase}): _supabase = supabase ?? Supabase.instance.client;
  
  Future<String> uploadImageToStorage({required String userId, required File imageFile, required String fileName,}) async {
    try {
      final path = '$userId/$fileName';
      await _supabase.storage.from('avatars').upload(path,imageFile,fileOptions: const FileOptions(cacheControl: '3600', upsert: true),);
      return path;
    } catch (e, st) {
      throw handleException(e, st);
    }
  }

  String getPublicUrl(String path) {
    return _supabase.storage.from('avatars').getPublicUrl(path);
  }

  Future<void> updateProfileAvatar(String userId, String? avatarUrl) async {
    try {
      await _supabase.from('profiles').upsert({'id': userId,'avatar_url': avatarUrl,'updated_at': DateTime.now().toIso8601String(),});
    } catch (e, st) {
      throw handleException(e, st);
    }
  }

  Future<void> deleteImage(String path) async {
    try {
      await _supabase.storage.from('avatars').remove([path]);
    } catch (e, st) {
      throw handleException(e, st);
    }
  }
}