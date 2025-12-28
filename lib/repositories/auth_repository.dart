import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/user.dart';
import '../models/auth.dart';
import '../utils/app_error.dart';

class AuthRepository {
  final SupabaseClient _supabase;
  AuthRepository({SupabaseClient? supabase}): _supabase = supabase ?? Supabase.instance.client;
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
  User? get currentUser => _supabase.auth.currentUser;
  Session? get currentSession => _supabase.auth.currentSession;

  Future<AuthResponse> signIn(SignInParams params) async {
    try {
      return await _supabase.auth.signInWithPassword(
        email: params.email,
        password: params.password,
      );
    } catch (e, st) {
      throw handleException(e, st);
    }
  }

  Future<AuthResponse> signUp(SignUpParams params) async {
    try {
      return await _supabase.auth.signUp(
        email: params.email,
        password: params.password,
        data: {'full_name': params.fullName},
      );
    } catch (e, st) {
      throw handleException(e, st);
    }
  }

  Future<void> signOut() async { 
    await _supabase.auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e, st) {
      throw handleException(e, st);
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      await _supabase.auth.updateUser( UserAttributes(password: newPassword), );
    } catch (e, st) {
      throw handleException(e, st);
    }
  }

  Future<void> createUserProfile({ required String id, required SignUpParams params, }) async {
    try {
      await _supabase.from(SupabaseConfig.profilesTable).insert({
        'id': id,
        'email': params.email,
        'full_name': params.fullName,
        'avatar_url': params.avatarUrl,
        'gender': params.gender,
        'date_of_birth': params.dateOfBirth?.toIso8601String().split('T')[0],
        'height': params.height,
        'goal': params.goal,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e, st) {
      throw handleException(e, st);
    }
  }

  Future<AppUser?> getUserProfile(String userId) async {
    try {
      final response = await _supabase.from(SupabaseConfig.profilesTable).select().eq('id', userId).maybeSingle();
      if (response == null) return null;
      return AppUser.fromJson(response);
     } catch (e, st) {
      throw handleException(e, st);
    }
  }

  Future<void> updateUserProfile(UpdateProfileParams params) async {
    try {
      await _supabase.from(SupabaseConfig.profilesTable).update(params.toUpdateMap()) .eq('id', params.userId);
    } catch (e, st) {
      throw handleException(e, st);
    }
  }

  Future<AuthResponse> verifyOTP({ required String email, required String token, required OtpType type,}) async {
    try {
      return await _supabase.auth.verifyOTP(email: email, token: token, type: type,);
    } catch (e, st) {
      throw handleException(e, st);
    }
  }

  Future<ResendResponse> resendOTP({ required String email, required OtpType type, }) async {
    try {
      return await _supabase.auth.resend(type: type, email: email, );
    } catch (e, st) {
      throw handleException(e, st);
    }
  }

  bool get isEmailVerified {
    final user = _supabase.auth.currentUser;
    return user?.emailConfirmedAt != null;
  }
}