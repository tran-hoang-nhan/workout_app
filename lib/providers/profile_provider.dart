import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/profile_repository.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../services/profile_service.dart';
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

final editProfileControllerProvider = AsyncNotifierProvider<EditProfileController, void>(() {
  return EditProfileController();
});

class EditProfileController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}
  
  Future<bool> saveProfile({required String userId, required String fullName, String? gender, int? age, String? goal,}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      try {
        await ref.read(profileServiceProvider).saveProfile(
          userId: userId,
          fullName: fullName,
          gender: gender,
          age: age,
          goal: goal,
        );
      } catch (e, st) {
        throw handleException(e, st);
      }
    });
    return !state.hasError;
  }

  Future<bool> updateAvatar() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      try {
        await ref.read(profileServiceProvider).pickAndUploadAvatar();
      } catch (e, st) {
        throw handleException(e, st);
      }
    });
    return !state.hasError;
  }

  Future<bool> removeAvatar() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      try {
        await ref.read(profileServiceProvider).removeAvatar();
      } catch (e, st) {
        throw handleException(e, st);
      }
    });
    return !state.hasError;
  }
}

