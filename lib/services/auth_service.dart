import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart';
import '../models/auth.dart'; // Import các class Params
import '../repositories/auth_repository.dart';

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
    final response = await _repository.signUp(params);
    if (response.user != null) {
      await _repository.createUserProfile(
        id: response.user!.id,
        params: params, 
      );
      return await _repository.getUserProfile(response.user!.id);
    }
    return null;
  }

  Future<void> signOut() async {
    await _repository.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _repository.resetPassword(email);
  }

  Future<void> updatePassword(String newPassword) async {
    await _repository.updatePassword(newPassword);
  }

  Future<void> updateUserProfile(UpdateProfileParams params) async {
    await _repository.updateUserProfile(params);
  }

  Future<AppUser?> getUserProfile(String userId) async {
    return await _repository.getUserProfile(userId);
  }
}