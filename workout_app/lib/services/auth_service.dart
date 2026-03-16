import 'package:shared/shared.dart' as shared;
import 'package:shared/shared.dart'
    show AppUser, SignInParams, SignUpParams, UpdateProfileParams;
import '../repositories/auth_repository.dart';

class AuthService {
  final AuthRepository _repository;

  AuthService({AuthRepository? repository})
    : _repository = repository ?? AuthRepository();

  bool get isAuthenticated => _repository.currentUser != null;
  Stream<shared.AuthState> get authStateStream =>
      _repository.onAuthStateChange.map(
        (state) => shared.AuthState(session: state.session, event: state.event),
      );
  AppUser? get currentUser => _repository.currentUser;

  Future<AppUser?> signIn(SignInParams params) async {
    final response = await _repository.signIn(params);
    if (response['user'] != null) {
      return AppUser.fromJson(response['user'] as Map<String, dynamic>);
    }
    return null;
  }

  Future<AppUser?> signUp(SignUpParams params) async {
    final response = await _repository.signUp(params);
    if (response['user'] != null) {
      return AppUser.fromJson(response['user'] as Map<String, dynamic>);
    }
    return null;
  }

  Future<void> signOut() async {
    await _repository.signOut();
  }

  Future<AppUser?> getUserProfile(String userId) => _repository.getUserProfile(userId);

  Future<void> updateUserProfile(String userId, UpdateProfileParams params,) async {
    await _repository.updateProfile(userId, params);
  }

  Future<void> resetPassword(String email) async {
    await _repository.resetPassword(email);
  }

  Future<void> verifyRecoveryOTP(String email, String token) async {
    await _repository.verifyOTP(email: email, token: token, type: 'recovery');
  }

  Future<void> updatePassword(String password, { String? confirmPassword,}) async {
    await _repository.updatePassword(password);
  }
}
