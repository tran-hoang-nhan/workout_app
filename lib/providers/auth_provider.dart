import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../models/user.dart';
import '../models/auth.dart';
import '../repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authServiceProvider = Provider<AuthService>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthService(repository: repo);
});

final authStateProvider = StreamProvider<bool>((ref) async* {
  final authService = ref.watch(authServiceProvider);
  yield authService.isAuthenticated;
  await for (final state in authService.authStateStream) {
    yield state.session != null;
  }
});

final currentUserIdProvider = StreamProvider<String?>((ref) async* {
  final authService = ref.watch(authServiceProvider);
  yield authService.currentUser?.id;
  await for (final state in authService.authStateStream) {
    final userId = state.session?.user.id;
    debugPrint(
      '[currentUserIdProvider] Auth Event: ${state.event}, User: $userId',
    );
    yield userId;
  }
});

final currentUserProvider = FutureProvider<AppUser?>((ref) async {
  final userIdAsync = await ref.watch(currentUserIdProvider.future);
  if (userIdAsync == null) return null;
  final authService = ref.read(authServiceProvider);
  return await authService.getUserProfile(userIdAsync);
});

final authControllerProvider = AsyncNotifierProvider<AuthController, void>(() {
  return AuthController();
});

class AuthController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> signIn(SignInParams params) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(authServiceProvider).signIn(params);
    });
  }

  Future<void> signUp(SignUpParams params) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(authServiceProvider).signUp(params);
    });
  }

  Future<void> signOut() async {
    await ref.read(authServiceProvider).signOut();
  }

  Future<void> updateProfile(UpdateProfileParams params) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(authServiceProvider).updateUserProfile(params);
      ref.invalidate(currentUserProvider);
    });
  }

  Future<void> resetPassword(String email) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // In a real app, you might want to configure a proper redirect URL
      // For now, we rely on the OTP flow primarily
      await ref.read(authServiceProvider).resetPassword(email);
    });
  }

  Future<bool> verifyRecoveryOTP(String email, String token) async {
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(() async {
      await ref.read(authServiceProvider).verifyRecoveryOTP(email, token);
    });
    state = result;
    return !result.hasError;
  }

  Future<void> updatePassword(
    String newPassword, {
    String? confirmPassword,
  }) async {
    debugPrint('[AuthController] updatePassword starting...');
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final authService = ref.read(authServiceProvider);
      await authService.updatePassword(
        newPassword,
        confirmPassword: confirmPassword,
      );
      debugPrint('[AuthController] updatePassword completed successfully.');
    });

    if (state.hasError) {
      debugPrint(
        '[AuthController] updatePassword failed with error: ${state.error}',
      );
    }
  }
}
