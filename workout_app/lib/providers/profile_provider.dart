import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';
import '../repositories/profile_repository.dart';
import '../providers/auth_provider.dart';
import '../providers/avatar_provider.dart';
import '../providers/health_base_provider.dart';
import '../utils/app_error.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});

final fullUserProfileProvider = FutureProvider<AppUser?>((ref) async {
  final userIdAsync = await ref.watch(currentUserIdProvider.future);
  if (userIdAsync == null) return null;

  final profileRepo = ref.read(profileRepositoryProvider);
  return await profileRepo.getFullUserProfile(userIdAsync);
});

final editProfileControllerProvider =AsyncNotifierProvider<EditProfileController, void>(() {
  return EditProfileController();
});

class EditProfileController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> pickAndUploadAvatar() async {
    state = const AsyncValue.loading();
    try {
      await ref.read(avatarControllerProvider.notifier).pickAndUploadAvatar();
      final avatarState = ref.read(avatarControllerProvider);
      if (avatarState.hasError) {
        throw avatarState.error ?? Exception('Không thể cập nhật avatar');
      }

      ref.invalidate(currentUserProvider);
      ref.invalidate(fullUserProfileProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(handleException(e, st), st);
      return false;
    }
  }

  Future<bool> removeAvatar() async {
    state = const AsyncValue.loading();
    try {
      await ref.read(avatarControllerProvider.notifier).removeAvatar();
      final avatarState = ref.read(avatarControllerProvider);
      if (avatarState.hasError) {
        throw avatarState.error ?? Exception('Không thể xóa avatar');
      }

      ref.invalidate(currentUserProvider);
      ref.invalidate(fullUserProfileProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(handleException(e, st), st);
      return false;
    }
  }

  Future<bool> saveProfile({required String userId, required String fullName, String? gender, String? goal, DateTime? dateOfBirth,}) async {
    final trimmedName = fullName.trim();
    if (trimmedName.isEmpty) {
      state = AsyncValue.error(
        ValidationException('Vui lòng nhập tên'),
        StackTrace.current,
      );
      return false;
    }

    state = const AsyncValue.loading();
    try {
      await ref.read(profileRepositoryProvider).saveProfile(
        userId: userId,
        fullName: trimmedName,
        gender: gender,
        goal: goal,
        dateOfBirth: dateOfBirth,
      );
      ref.invalidate(currentUserProvider);
      ref.invalidate(fullUserProfileProvider);
      ref.invalidate(healthDataProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(handleException(e, st), st);
      return false;
    }
  }
}
