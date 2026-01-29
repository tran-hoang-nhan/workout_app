import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart';
import '../models/auth.dart';
import '../repositories/auth_repository.dart';
import '../utils/app_error.dart';

class AuthService {
  final AuthRepository _repository;
  AuthService({AuthRepository? repository}): _repository = repository ?? AuthRepository();
  Stream<AuthState> get authStateStream => _repository.authStateChanges;
  bool get isAuthenticated => _repository.currentSession != null;
  User? get currentUser => _repository.currentUser;

  Future<AppUser?> signIn(SignInParams params) async {
    final response = await _repository.signIn(params);
    if (response.user != null) {
      return await _repository.getUserProfile(response.user!.id);
    }
    return null;
  }

  Future<AppUser?> signUp(SignUpParams params) async {
    return await _repository.signUpWithTransaction(params);
  }

  Future<void> signOut() async {
    await _repository.signOut();
  }

  Future<void> resetPassword(String email, {String? redirectTo}) async {
    if (email.isEmpty) {
      throw ValidationException('Vui lòng nhập email');
    }
    if (!email.contains('@')) {
      throw ValidationException('Email không hợp lệ');
    }
    await _repository.resetPassword(email, redirectTo: redirectTo);
  }

  Future<void> verifyRecoveryOTP(String email, String token) async {
    if (token.isEmpty) {
      throw ValidationException('Vui lòng nhập mã xác nhận');
    }
    await _repository.verifyOTP(
      email: email,
      token: token,
      type: OtpType.recovery,
    );
  }

  Future<void> updatePassword(String newPassword, { String? confirmPassword,}) async {
    debugPrint('[AuthService] Validating password update request...');
    if (newPassword.isEmpty) {
      debugPrint('[AuthService] Validation failed: Password empty');
      throw ValidationException('Vui lòng nhập mật khẩu mới');
    }
    if (newPassword.length < 6) {
      debugPrint('[AuthService] Validation failed: Password too short');
      throw ValidationException('Mật khẩu phải có ít nhất 6 ký tự');
    }

    if (confirmPassword != null && newPassword != confirmPassword) {
      debugPrint('[AuthService] Validation failed: Passwords do not match');
      throw ValidationException('Mật khẩu xác nhận không khớp');
    }

    debugPrint('[AuthService] Passing request to repository...');
    await _repository.updatePassword(newPassword);
    debugPrint('[AuthService] Password update flow completed in repository.');
  }

  Future<void> updateUserProfile(UpdateProfileParams params) async {
    await _repository.updateUserProfile(params);
  }

  Future<AppUser?> getUserProfile(String userId) async {
    return await _repository.getUserProfile(userId);
  }
}
