import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';
import '../config/supabase_config.dart';
import '../models/user.dart';

class AuthService {
  final Logger _logger = Logger();
  late final SupabaseClient _supabase;

  AuthService() {
    _supabase = Supabase.instance.client;
  }

  /// Kiểm tra xem user có đăng nhập hay không
  bool get isAuthenticated => _supabase.auth.currentSession != null;

  /// Lấy user hiện tại
  AppUser? get currentUser {
    final session = _supabase.auth.currentSession;
    if (session == null) return null;

    return AppUser(
      id: session.user.id,
      email: session.user.email ?? '',
      fullName: '',
      createdAt: DateTime.now(),
    );
  }

  /// Đăng nhập bằng email và password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _logger.i('Attempting sign in with email: $email');
      
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      _logger.i('Sign in successful for user: ${response.user?.email}');
      
      // Eagerly fetch full profile after sign in
      if (response.user != null) {
        try {
          final profile = await getUserProfile(response.user!.id);
          _logger.i('Profile loaded after sign in: ${profile?.fullName}');
        } catch (e) {
          _logger.w('Could not load profile after sign in: $e');
        }
      }
      
      return response;
    } on AuthException catch (e) {
      _logger.e('Auth error during sign in: ${e.message}');
      rethrow;
    } catch (e) {
      _logger.e('Unexpected error during sign in: $e');
      rethrow;
    }
  }

  /// Đăng ký tài khoản mới (full profile)
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    String? avatarUrl,
    String? gender,
    DateTime? dateOfBirth,
    double? height,
    String? goal,
  }) async {
    try {
      _logger.i('Attempting sign up with email: $email');

      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );

      // Tạo complete profile trong bảng users
      if (response.user != null) {
        await _createUserProfile(
          id: response.user!.id,
          email: email,
          fullName: fullName,
          avatarUrl: avatarUrl,
          gender: gender,
          dateOfBirth: dateOfBirth,
          height: height,
          goal: goal,
        );
      }

      _logger.i('Sign up successful for user: ${response.user?.email}');
      return response;
    } on AuthException catch (e) {
      _logger.e('Auth error during sign up: ${e.message}');
      rethrow;
    } catch (e) {
      _logger.e('Unexpected error during sign up: $e');
      rethrow;
    }
  }

  /// Đăng xuất
  Future<void> signOut() async {
    try {
      _logger.i('Signing out user');
      await _supabase.auth.signOut();
      _logger.i('Sign out successful');
    } catch (e) {
      _logger.e('Error during sign out: $e');
      rethrow;
    }
  }

  /// Đặt lại mật khẩu
  Future<void> resetPassword(String email) async {
    try {
      _logger.i('Attempting password reset for email: $email');
      
      await _supabase.auth.resetPasswordForEmail(email);
      
      _logger.i('Password reset email sent to: $email');
    } on AuthException catch (e) {
      _logger.e('Auth error during password reset: ${e.message}');
      rethrow;
    } catch (e) {
      _logger.e('Unexpected error during password reset: $e');
      rethrow;
    }
  }

  

  /// Xác nhận email sau signup (nếu cần)
  Future<AuthResponse> verifyOTP({
    required String email,
    required String token,
    required OtpType type,
  }) async {
    try {
      _logger.i('Verifying OTP for email: $email');

      final response = await _supabase.auth.verifyOTP(
        email: email,
        token: token,
        type: type,
      );

      _logger.i('OTP verified successfully');
      return response;
    } on AuthException catch (e) {
      _logger.e('Auth error during OTP verification: ${e.message}');
      rethrow;
    } catch (e) {
      _logger.e('Unexpected error during OTP verification: $e');
      rethrow;
    }
  }

  /// Gửi lại email xác nhận (resend signup email)
  Future<void> resendSignupEmail(String email) async {
    try {
      _logger.i('Resending signup email to: $email');

      // Supabase automatically sends verification email
      // Nếu user muốn resend, có thể dùng resetPasswordForEmail hoặc
      // đăng ký lại với email đó
      _logger.i('Please ask user to check email or sign up again');
    } on AuthException catch (e) {
      _logger.e('Auth error during resend signup email: ${e.message}');
      rethrow;
    } catch (e) {
      _logger.e('Unexpected error during resend signup email: $e');
      rethrow;
    }
  }

  /// Xác nhận reset password (update password sau forgot)
  Future<void> updatePassword(String newPassword) async {
    try {
      _logger.i('Updating password for current user');

      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      _logger.i('Password updated successfully');
    } on AuthException catch (e) {
      _logger.e('Auth error during password update: ${e.message}');
      rethrow;
    } catch (e) {
      _logger.e('Unexpected error during password update: $e');
      rethrow;
    }
  }

  /// Check xem session có valid không
  bool get hasValidSession {
    final session = _supabase.auth.currentSession;
    return session != null && !session.isExpired;
  }

  /// Refresh session
  Future<AuthResponse?> refreshSession() async {
    try {
      _logger.i('Refreshing auth session');

      final response = await _supabase.auth.refreshSession();

      _logger.i('Session refreshed successfully');
      return response;
    } on AuthException catch (e) {
      _logger.e('Auth error during session refresh: ${e.message}');
      return null;
    } catch (e) {
      _logger.e('Unexpected error during session refresh: $e');
      return null;
    }
  }

  /// Tạo user profile trong database
  Future<void> _createUserProfile({
    required String id,
    required String email,
    required String fullName,
    String? avatarUrl,
    String? gender,
    DateTime? dateOfBirth,
    double? height,
    String? goal,
  }) async {
    try {
      _logger.i('Creating user profile for: $email');

      await _supabase.from(SupabaseConfig.profilesTable).insert({
        'id': id,
        'email': email,
        'full_name': fullName,
        'avatar_url': avatarUrl,
        'gender': gender,
        'date_of_birth': dateOfBirth?.toIso8601String().split('T')[0],
        'height': height,
        'goal': goal,
        'created_at': DateTime.now().toIso8601String(),
      });

      _logger.i('User profile created successfully');
    } catch (e) {
      _logger.e('Error creating user profile: $e');
      rethrow;
    }
  }

  /// Lấy user profile từ database
  Future<AppUser?> getUserProfile(String userId) async {
    try {
      _logger.i('Fetching user profile for: $userId');

      final response = await _supabase
          .from(SupabaseConfig.profilesTable)
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) {
        _logger.w('User profile not found for: $userId');
        return null;
      }

      return AppUser.fromJson(response);
    } catch (e) {
      _logger.e('Error fetching user profile: $e');
      rethrow;
    }
  }

  /// Cập nhật user profile
  Future<void> updateUserProfile({
    required String userId,
    String? fullName,
    String? avatarUrl,
    String? gender,
    DateTime? dateOfBirth,
    double? height,
    String? goal,
  }) async {
    try {
      _logger.i('Updating user profile for: $userId');

      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (fullName != null) updates['full_name'] = fullName;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
      if (gender != null) updates['gender'] = gender;
      if (dateOfBirth != null) updates['date_of_birth'] = dateOfBirth.toIso8601String().split('T')[0];
      if (height != null) updates['height'] = height;
      if (goal != null) updates['goal'] = goal;

      await _supabase
          .from(SupabaseConfig.profilesTable)
          .update(updates)
          .eq('id', userId);

      _logger.i('User profile updated successfully');
    } catch (e) {
      _logger.e('Error updating user profile: $e');
      rethrow;
    }
  }

  /// Stream để theo dõi trạng thái xác thực
  Stream<AuthState> get authStateStream {
    return _supabase.auth.onAuthStateChange;
  }
}
