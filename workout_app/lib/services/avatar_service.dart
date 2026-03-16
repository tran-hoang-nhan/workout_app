import 'dart:typed_data';
import '../repositories/avatar_repository.dart';

class AvatarService {
  final AvatarRepository _repository;

  AvatarService({AvatarRepository? repository}): _repository = repository ?? AvatarRepository();

  Future<String> uploadAvatar({required String userId, required Uint8List bytes, required String fileName,}) async {
    // 1. Upload to storage
    final storagePath = await _repository.uploadImageToStorage(
      userId: userId,
      bytes: bytes,
      fileName: fileName,
    );
    final publicUrl = _repository.getPublicUrl(storagePath);
    
    // 2. Update profile URL via backend
    await _repository.updateProfileAvatar(userId, publicUrl);
    return publicUrl;
  }

  Future<void> removeAvatar(String userId) async {
    await _repository.updateProfileAvatar(userId, null);
  }
}
