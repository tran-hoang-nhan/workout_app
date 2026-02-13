import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../config/supabase_config.dart';
import '../repositories/avatar_repository.dart';
import '../utils/app_error.dart';

class AvatarService {
  final AvatarRepository _repository;
  AvatarService({AvatarRepository? repository}): _repository = repository ?? AvatarRepository();

  Future<String> uploadAvatar({required String userId, required Uint8List bytes, required String fileName,}) async {
    try {
      debugPrint('AvatarService: Starting uploadAvatar for user: $userId');
      final response = await _repository.getProfileAvatar(userId);
      final oldAvatarUrl = response?['avatar_url'] as String?;
      debugPrint('AvatarService: Existing avatar URL: $oldAvatarUrl');
      debugPrint('AvatarService: Uploading bytes for file: $fileName');
      final storagePath = await _repository.uploadImageToStorage(userId: userId, bytes: bytes, fileName: fileName);
      final publicUrl = _repository.getPublicUrl(storagePath);
      debugPrint('AvatarService: New public URL: $publicUrl');
      await _repository.updateProfileAvatar(userId, publicUrl);
      debugPrint('AvatarService: DB updated successfully');

      final bucket = SupabaseConfig.storageUsersBucket;
      if (oldAvatarUrl != null && oldAvatarUrl.contains('$bucket/')) {
        debugPrint('AvatarService: Cleaning up old avatar from storage');
        try {
          final pathParts = oldAvatarUrl.split('$bucket/');
          if (pathParts.length > 1) {
             await _repository.deleteImage(pathParts[1]);
             debugPrint('AvatarService: Old avatar deleted: ${pathParts[1]}');
          }
        } catch (e) {
          debugPrint('AvatarService: Error cleaning up old avatar: $e');
        }
      }

      debugPrint('AvatarService: uploadAvatar completed successfully');
      return publicUrl;
    } catch (e, st) {
      throw handleException(e, st);
    }
  }

  Future<void> removeAvatar(String userId) async {
    try {
      debugPrint('AvatarService: Starting removeAvatar for user: $userId');
      final response = await _repository.getProfileAvatar(userId);
      final oldAvatarUrl = response?['avatar_url'] as String?;
      debugPrint('AvatarService: Existing avatar URL to remove: $oldAvatarUrl');
      await _repository.updateProfileAvatar(userId, null);
      final bucket = SupabaseConfig.storageUsersBucket;
      if (oldAvatarUrl != null && oldAvatarUrl.contains('$bucket/')) {
        final pathParts = oldAvatarUrl.split('$bucket/');
        if (pathParts.length > 1) {
          await _repository.deleteImage(pathParts[1]);
          debugPrint('AvatarService: File deleted from storage: ${pathParts[1]}');
        }
      }
      debugPrint('AvatarService: removeAvatar completed successfully');
    } catch (e, st) {
      throw handleException(e, st);
    }
  }
}