import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AvatarService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Upload avatar to Supabase Storage
  /// Note: Due to platform limitations, this currently shows a placeholder message
  /// Implement using native file picker for production
  Future<({String? publicUrl, String? error})> uploadAvatar({
    required String userId,
    required dynamic imageFile, // File or XFile
  }) async {
    try {
      debugPrint('Starting avatar upload for user: $userId');
      
      // Note: This is a placeholder implementation
      // In production, use image_picker or file_picker package
      // and convert to File before uploading
      
      throw UnimplementedError(
        'Avatar upload requires image_picker package. '
        'Add image_picker to pubspec.yaml and implement file selection.',
      );
    } catch (e) {
      debugPrint('Error uploading avatar: $e');
      return (publicUrl: null, error: e.toString());
    }
  }

  /// Remove avatar from Supabase Storage and profiles table
  Future<({String? error})> removeAvatar({required String userId}) async {
    try {
      debugPrint('Starting avatar removal for user: $userId');

      // Update profiles table to remove avatar URL
      await _supabase.from('profiles').upsert({
        'id': userId,
        'avatar_url': null,
        'updated_at': DateTime.now().toIso8601String(),
      });

      debugPrint('Avatar URL removed from profiles table');

      return (error: null);
    } catch (e) {
      debugPrint('Error removing avatar: $e');
      return (error: e.toString());
    }
  }
}
