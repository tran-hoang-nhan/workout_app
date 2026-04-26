import 'dart:convert';
import 'package:shared/shared.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import '../services/api_client.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final SupabaseClient _supabase;

  AuthRepository({ApiClient? apiClient, SupabaseClient? supabase}): _apiClient = apiClient ?? ApiClient(),_supabase = supabase ?? Supabase.instance.client;

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
    final response = await _apiClient.login(params);
    if (response['session'] != null) {
      await _updateSession(response['session'] as Map<String, dynamic>);
    }
    return response;
  }

  Future<Map<String, dynamic>> signUp(SignUpParams params) async {
    final response = await _apiClient.register(params);
    if (response['session'] != null) {
      await _updateSession(response['session'] as Map<String, dynamic>);
    }
    return response;
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  Future<Map<String, dynamic>> verifyOTP({required String email, required String token, required String type,}) async {
    final response = await _apiClient.verifyOtp(email, token, type);
    if (response['session'] != null) {
      await _updateSession(response['session'] as Map<String, dynamic>);
    }
    return response;
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
    await _apiClient.resetPassword(email);
  }

  Future<void> updatePassword(String password) async {
    await _apiClient.updatePassword(password);
  }

  Future<void> _updateSession(Map<String, dynamic> sessionData) async {
    final accessToken = sessionData['access_token'] as String?;

    if (accessToken != null) {
      try {
        await _supabase.auth.signOut(scope: SignOutScope.local);
        await _supabase.auth.recoverSession(json.encode(sessionData));
      } catch (_) {
        try {
          final minimalSession = Map<String, dynamic>.from(sessionData);
          minimalSession.remove('refresh_token');
          await _supabase.auth.recoverSession(json.encode(minimalSession));
        } catch (_) {
          try {
            await _supabase.auth.setSession(accessToken);
          } catch (_) {}
        }
      }
    }
  }
}
