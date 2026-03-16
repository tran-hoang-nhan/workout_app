import 'package:shared/shared.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import '../services/api_client.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final SupabaseClient _supabase;

  AuthRepository({ApiClient? apiClient, SupabaseClient? supabase})
    : _apiClient = apiClient ?? ApiClient(),
      _supabase = supabase ?? Supabase.instance.client;

  AppUser? get currentUser {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;
    return AppUser(
      id: user.id,
      email: user.email ?? '',
      fullName: user.userMetadata?['full_name'] ?? '',
      createdAt: DateTime.tryParse(user.createdAt) ?? DateTime.now(),
    );
  }

  Stream<AuthState> get onAuthStateChange {
    return _supabase.auth.onAuthStateChange.map((state) {
      return AuthState(session: state.session, event: state.event);
    });
  }

  Future<Map<String, dynamic>> signIn(SignInParams params) async {
    final response = await _supabase.auth.signInWithPassword(
      email: params.email,
      password: params.password,
    );
    return {
      'user': response.user?.toJson(),
      'session': response.session?.toJson(),
    };
  }

  Future<Map<String, dynamic>> signUp(SignUpParams params) async {
    final response = await _supabase.auth.signUp(
      email: params.email,
      password: params.password,
      data: params.toJson(),
    );
    return {
      'user': response.user?.toJson(),
      'session': response.session?.toJson(),
    };
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  Future<Map<String, dynamic>> verifyOTP({
    required String email,
    required String token,
    required String type,
  }) async {
    return _apiClient.verifyOtp(email, token, type);
  }

  Future<void> resendOTP({required String email, required String type}) async {
    await _apiClient.resendOtp(email, type);
  }

  Future<AppUser?> getUserProfile(String userId) async {
    return _apiClient.getProfile(userId);
  }

  Future<void> updateProfile(String userId, UpdateProfileParams params) async {
    await _apiClient.updateProfile(userId, params);
  }

  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  Future<void> updatePassword(String password) async {
    await _supabase.auth.updateUser(UserAttributes(password: password));
  }
}
