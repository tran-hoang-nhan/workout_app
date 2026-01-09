import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/auth.dart';
import '../providers/auth_provider.dart';
import '../providers/avatar_provider.dart';
import '../utils/app_error.dart';

class ProfileService {
  final Ref _ref;

  ProfileService(this._ref);

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
  }) async {
    if (fullName.isEmpty) {
      throw ValidationException('Vui lòng nhập tên');
    }

    try {
      final params = UpdateProfileParams(
        userId: userId,
        fullName: fullName,
        gender: gender,
        height: height,
        goal: goal,
      );

      await _ref.read(authControllerProvider.notifier).updateProfile(params);
      
      final authState = _ref.read(authControllerProvider);
      if (authState.hasError) throw authState.error!;
    } catch (e) {
      throw handleException(e);
    }
  }
}

final profileServiceProvider = Provider<ProfileService>((ref) {
  return ProfileService(ref);
});
