import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart' as shared;
import 'package:shared/shared.dart' show AppUser, SignInParams, SignUpParams, UpdateProfileParams;
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
  final authService = ref.watch(authServiceProvider);
  final initialUser = authService.currentUser?.id;
  yield initialUser;
  await for (final state in authService.authStateStream) {
    final userId = state.session?.user.id;
    yield userId;
  }
});

final currentUserProvider = FutureProvider<AppUser?>((ref) async {
  final userIdAsync = ref.watch(currentUserIdProvider).asData?.value;
  if (userIdAsync == null) {
    return null;
  }
  final authService = ref.read(authServiceProvider);
  final profile = await authService.getUserProfile(userIdAsync);
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
      if (userId == null) {
        throw StateError('User not authenticated');
      }
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

  Future<bool> updatePassword(String newPassword, { String? confirmPassword,}) async {
    if (newPassword.trim().isEmpty) {
      state = AsyncValue.error(
        ArgumentError('Mật khẩu không được để trống'),
        StackTrace.current,
      );
      return false;
    }

    if (confirmPassword != null && newPassword != confirmPassword) {
      state = AsyncValue.error(
        ArgumentError('Mật khẩu xác nhận không khớp'),
        StackTrace.current,
      );
      return false;
    }

    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(() async {
      final authService = ref.read(authServiceProvider);
      await authService.updatePassword(newPassword);
    });
    state = result;
    if (state.hasError) {
    }

    return !result.hasError;
  }
}
