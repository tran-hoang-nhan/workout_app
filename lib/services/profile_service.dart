import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/avatar_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/health_provider.dart';
import '../repositories/profile_repository.dart';
import '../utils/app_error.dart';

class ProfileService {
  final Ref _ref;
  final ProfileRepository _profileRepo;

  ProfileService(this._ref, this._profileRepo);

  Future<void> pickAndUploadAvatar() async {
    try {
      await _ref.read(avatarControllerProvider.notifier).pickAndUploadAvatar();
      
      final state = _ref.read(avatarControllerProvider);
      if (state.hasError) {
        throw handleException(state.error!);
      }

      // Refresh and wait for updated user data
      _ref.invalidate(currentUserProvider);
    } catch (e) {
      throw handleException(e);
    }
  }

  Future<void> removeAvatar() async {
    try {
      await _ref.read(avatarControllerProvider.notifier).removeAvatar();
      
      final state = _ref.read(avatarControllerProvider);
      if (state.hasError) {
        throw handleException(state.error!);
      }
    } catch (e) {
      throw handleException(e);
    }
  }

  Future<void> saveProfile({
    required String userId,
    required String fullName,
    String? gender,
    double? height,
    String? goal,
    double? weight,
    int? age,
  }) async {
    if (fullName.isEmpty) {
      throw ValidationException('Vui lòng nhập tên');
    }

    try {
      await _profileRepo.saveProfile(
        userId: userId,
        fullName: fullName,
        gender: gender,
        height: height,
        goal: goal,
        weight: weight,
        age: age,
      );
      
      // Invalidate để refresh data ở tất cả màn hình
      _ref.invalidate(currentUserProvider);
      _ref.invalidate(fullUserProfileProvider);
      _ref.invalidate(healthDataProvider);
    } catch (e) {
      throw handleException(e);
    }
  }
}

final profileServiceProvider = Provider<ProfileService>((ref) {
  final profileRepo = ref.watch(profileRepositoryProvider);
  return ProfileService(ref, profileRepo);
});
