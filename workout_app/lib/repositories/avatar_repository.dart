import '../services/api_client.dart';

class AvatarRepository {
  final ApiClient _apiClient;

  AvatarRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  Future<String> uploadImageToStorage({
    required String userId,
    required List<int> bytes,
    required String fileName,
  }) async {
    final response = await _apiClient.uploadAvatar(userId, bytes, fileName);
    return response['avatar_url'] as String;
  }

  // Backwards compatibility or if needed locally, but frontend should ideally use the URL from the profile
  String getPublicUrl(String path) {
    // This is now less relevant if the backend returns the full URL,
    // but we can return the path itself if it's already a full URL or handle accordingly.
    return path; 
  }

  Future<void> updateProfileAvatar(String userId, String? avatarUrl) async {
    await _apiClient.updateAvatar(userId, avatarUrl);
  }

  Future<void> deleteImage(String userId, String path) async {
    await _apiClient.deleteAvatar(userId, path);
  }
}
