import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/profile_repository.dart';
import '../services/profile_service.dart';
import '../models/user.dart';
import './auth_provider.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});

final profileServiceProvider = Provider<ProfileService>((ref) {
  final repo = ref.watch(profileRepositoryProvider);
  return ProfileService(repository: repo);
});

final profileStatsProvider = FutureProvider.autoDispose<UserStats?>((ref) async {
  final user = await ref.watch(currentUserProvider.future);
  if (user == null) return null;
  final service = ref.watch(profileServiceProvider);
  return await service.loadUserHealthData(user.id);
});

final profileControllerProvider = AsyncNotifierProvider<ProfileController, void>(() {
  return ProfileController();
});

class ProfileController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
  }

  Future<void> updateWeight(double newWeight) async {
    state = const AsyncValue.loading();
    final user = await ref.read(currentUserProvider.future);
    if (user == null) return;
    state = await AsyncValue.guard(() async {
      await ref.read(profileServiceProvider).updateWeight(user.id, newWeight);
      ref.invalidate(profileStatsProvider); 
    });
  }
}