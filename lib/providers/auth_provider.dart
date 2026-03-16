import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart' as shared;
import 'package:shared/shared.dart'
    show AppUser, SignInParams, SignUpParams, UpdateProfileParams;
import '../services/auth_service.dart';
import '../repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authServiceProvider = Provider<AuthService>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthService(repository: repo);
});

final authStateProvider = StreamProvider<shared.AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateStream;
});

final currentUserIdProvider = StreamProvider<String?>((ref) async* {
  debugPrint('[currentUserIdProvider] Initializing...');
  final authService = ref.watch(authServiceProvider);
  final initialUser = authService.currentUser?.id;
  debugPrint('[currentUserIdProvider] Initial user: $initialUser');
  yield initialUser;
  await for (final state in authService.authStateStream) {
    final userId = state.session?.user.id;
    debugPrint(
      '[currentUserIdProvider] Auth Event: ${state.event}, User: $userId',
    );
    yield userId;
  }
});

final currentUserProvider = FutureProvider<AppUser?>((ref) async {
  debugPrint('[currentUserProvider] Initializing...');
  final userIdAsync = await ref.watch(currentUserIdProvider.future);
  debugPrint('[currentUserProvider] Awaited currentUserIdProvider: $userIdAsync');
  if (userIdAsync == null) {
      debugPrint('[currentUserProvider] User is null, returning null.');
      return null;
  }
  final authService = ref.read(authServiceProvider);
  debugPrint('[currentUserProvider] Fetching profile for $userIdAsync');
  final profile = await authService.getUserProfile(userIdAsync);
  debugPrint('[currentUserProvider] Fetched profile: ${profile != null}');
  return profile;
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
      final userId = await ref.read(currentUserIdProvider.future);
      if (userId == null) return;
      await ref.read(authServiceProvider).updateUserProfile(userId, params);
      ref.invalidate(currentUserProvider);
    });
  }

  Future<void> resetPassword(String email) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
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
