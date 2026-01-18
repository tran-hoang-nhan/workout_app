import 'package:flutter/foundation.dart';
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
        'gender': params.gender ?? 'male', // Mặc định để pass database check, sẽ update ở onboarding
        'date_of_birth': params.dateOfBirth?.toIso8601String().split('T')[0],
        'goal': params.goal ?? 'maintain',
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e, st) {
      throw handleException(e, st);
    }
  }

  Future<AppUser?> getUserProfile(String userId) async {
    try {
      final profile = await _supabase
          .from(SupabaseConfig.profilesTable)
          .select()
          .eq('id', userId)
          .maybeSingle();
      if (profile == null) return null;

      final health = await _supabase
          .from('health')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      final merged = Map<String, dynamic>.from(profile);
      if (health != null && health['height'] != null) {
        merged['height'] = (health['height'] as num).toDouble();
      }
      return AppUser.fromJson(merged);
     } catch (e, st) {
      throw handleException(e, st);
    }
  }

  Future<void> updateUserProfile(UpdateProfileParams params) async {
    try {
      final map = params.toUpdateMap();
      await _supabase
          .from(SupabaseConfig.profilesTable)
          .update(map)
          .eq('id', params.userId);

      if (params.height != null) {
        await _supabase.from('health').upsert({
          'user_id': params.userId,
          'height': params.height,
          'updated_at': DateTime.now().toIso8601String(),
        });
      }
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

  // Transaction: Sign up with profile creation
  Future<AppUser?> signUpWithTransaction(SignUpParams params) async {
    User? createdUser;
    try {
      final authResponse = await signUp(params);
      if (authResponse.user == null) {
        throw AppError('Failed to create auth user');
      }
      createdUser = authResponse.user;
      await createUserProfile(id: createdUser!.id, params: params);
      return await getUserProfile(createdUser.id);
    } catch (e, st) {
      if (createdUser != null) {
        try {
          await _deleteAuthUser(createdUser.id);
        } catch (deleteError) {
          debugPrint('⚠️ Failed to rollback auth user: $deleteError');
        }
      }
      throw handleException(e, st);
    }
  }

  Future<void> _deleteAuthUser(String userId) async {
    try {
      await _supabase.from(SupabaseConfig.profilesTable).delete().eq('id', userId);
    } catch (e, st) {
      throw handleException(e, st);
    }
  }
}
