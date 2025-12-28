import 'dart:io';
import 'package:path/path.dart' as p; 
import '../repositories/avatar_repository.dart';
import '../utils/app_error.dart';

class AvatarService {
  final AvatarRepository _repository;
  AvatarService({AvatarRepository? repository}): _repository = repository ?? AvatarRepository();

  Future<String> uploadAvatar({required String userId, required File imageFile,}) async {
    try {
      final fileExt = p.extension(imageFile.path);
      final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}$fileExt';
      final storagePath = await _repository.uploadImageToStorage(
        userId: userId,
        imageFile: imageFile,
        fileName: fileName,
      );
      final publicUrl = _repository.getPublicUrl(storagePath);
      await _repository.updateProfileAvatar(userId, publicUrl);
      return publicUrl;
    } catch (e, st) {
      throw handleException(e, st);
    }
  }

  Future<void> removeAvatar(String userId) async {
    try {
      await _repository.updateProfileAvatar(userId, null);
    } catch (e, st) {
      throw handleException(e, st);
    }
  }
}