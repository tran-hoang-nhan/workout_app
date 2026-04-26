import '../services/api_client.dart';

class AvatarRepository {
  final ApiClient _apiClient;
  AvatarRepository({ApiClient? apiClient}): _apiClient = apiClient ?? ApiClient();

  Future<String> uploadImageToStorage({required String userId, required List<int> bytes, required String fileName,}) async {
    final response = await _apiClient.uploadAvatar(userId, bytes, fileName);
    return response['avatar_url'] as String;
  }

  String getPublicUrl(String path) {
    return path; 
  }

  Future<void> updateProfileAvatar(String userId, String? avatarUrl) async {
    await _apiClient.updateAvatar(userId, avatarUrl);
  }

  Future<void> deleteImage(String userId, String path) async {
    await _apiClient.deleteAvatar(userId, path);
  }
}
