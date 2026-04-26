import 'package:shared/shared.dart';
import 'package:supabase/supabase.dart';

class DuplicateEmailException implements Exception {
  const DuplicateEmailException([this.message = 'User already registered']);

  final String message;

  @override

  String toString() => message;
}

class AuthRepository {
  /// Creates an auth repository backed by Supabase.
  AuthRepository(this._supabase, {SupabaseClient? adminSupabase})
      : _adminSupabase = adminSupabase;
  final SupabaseClient _supabase;
  final SupabaseClient? _adminSupabase;

  String _normalizeEmail(String email) => email.trim().toLowerCase();

  Future<bool> isEmailRegistered(String email) async {
    final normalizedEmail = _normalizeEmail(email);
    final lookupClient = _adminSupabase ?? _supabase;
    final existing = await lookupClient
        .from('profiles')
        .select('id')
        .eq('email', normalizedEmail)
        .limit(1)
        .maybeSingle();
    return existing != null;
  }

  /// Signs in a user with email and password.
  Future<AuthResponse> signIn(SignInParams params) async {
    return _supabase.auth.signInWithPassword(
      email: params.email,
      password: params.password,
    );
  }

  /// Signs up a user and creates an initial profile row.
  Future<AuthResponse> signUp(SignUpParams params) async {
    final normalizedEmail = _normalizeEmail(params.email);
    final alreadyRegistered = await isEmailRegistered(normalizedEmail);
    if (alreadyRegistered) {
      throw const DuplicateEmailException();
    }

    final response = await _supabase.auth.signUp(
      email: normalizedEmail,
      password: params.password,
      data: {'full_name': params.fullName},
    );
    if (response.user != null) {
      await createUserProfile(
        id: response.user!.id,
        params: params,
        normalizedEmail: normalizedEmail,
      );
    }
    return response;
  }

  /// Creates a profile record for a newly registered user.
  Future<void> createUserProfile({
    required String id,
    required SignUpParams params,
    required String normalizedEmail,
  }) async {
    await _supabase.from('profiles').insert({
      'id': id,
      'email': normalizedEmail,
      'full_name': params.fullName,
      'avatar_url': params.avatarUrl,
      'gender': params.gender ?? 'male',
      'date_of_birth': params.dateOfBirth?.toIso8601String().split('T')[0],
      'goal': params.goal ?? 'maintain',
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  /// Gets a user profile and merges health metrics when available.
  Future<AppUser?> getUserProfile(String userId) async {
    final response = await _supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    if (response == null) return null;

    final healthResponse = await _supabase
        .from('health')
        .select('weight, height, age')
        .eq('user_id', userId)
        .maybeSingle();
    final userData = Map<String, dynamic>.from(response);
    if (healthResponse != null) {
      userData['weight'] = healthResponse['weight'];
      userData['height'] = healthResponse['height'];
      userData['age'] = healthResponse['age'];
    }
    return AppUser.fromJson(userData);
  }

  /// Updates editable user profile fields.
  Future<void> updateUserProfile(UpdateProfileParams params) async {
    final updates = <String, dynamic>{};
    if (params.fullName != null) updates['full_name'] = params.fullName;
    if (params.avatarUrl != null) updates['avatar_url'] = params.avatarUrl;
    if (params.gender != null) updates['gender'] = params.gender;
    if (params.dateOfBirth != null) {
      updates['date_of_birth'] =
          params.dateOfBirth!.toIso8601String().split('T')[0];
    }
    if (params.goal != null) updates['goal'] = params.goal;
    updates['updated_at'] = DateTime.now().toIso8601String();
    await _supabase.from('profiles').update(updates).eq('id', params.userId);
  }

  /// Sends a password reset email.
  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  /// Updates the user's password.
  Future<void> updatePassword(String password) async {
    await _supabase.auth.updateUser(UserAttributes(password: password));
  }
}
