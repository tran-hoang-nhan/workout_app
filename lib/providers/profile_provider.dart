import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/profile_repository.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});

// Provider để lấy full user profile với health data
final fullUserProfileProvider = FutureProvider<AppUser?>((ref) async {
  final userIdAsync = await ref.watch(currentUserIdProvider.future);
  if (userIdAsync == null) return null;
  
  final profileRepo = ref.read(profileRepositoryProvider);
  return await profileRepo.getFullUserProfile(userIdAsync);
});

