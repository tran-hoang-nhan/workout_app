import 'package:shared/shared.dart';
import '../services/api_client.dart';

class ProfileRepository {
  final ApiClient _apiClient;
  ProfileRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  Future<AppUser?> getFullUserProfile(String userId) async {
    return _apiClient.getProfile(userId);
  }

  Future<void> saveProfile({
    required String userId,
    required String fullName,
    String? gender,
    String? goal,
    DateTime? dateOfBirth,
  }) async {
    final params = UpdateProfileParams(
      userId: userId,
      fullName: fullName,
      gender: gender,
      goal: goal,
      dateOfBirth: dateOfBirth,
    );
    await _apiClient.updateProfile(userId, params);
  }
}
