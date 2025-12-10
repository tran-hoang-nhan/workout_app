import 'package:supabase_flutter/supabase_flutter.dart';

class EmailConfirmationService {
  final SupabaseClient _supabaseClient;

  EmailConfirmationService({SupabaseClient? supabaseClient})
      : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  /// Xác nhận OTP từ email
  Future<void> verifyOTP({
    required String email,
    required String token,
    required OtpType type,
  }) async {
    try {
      await _supabaseClient.auth.verifyOTP(
        email: email,
        token: token,
        type: type,
      );
    } catch (e) {
      throw Exception('Lỗi xác nhận OTP: ${e.toString()}');
    }
  }

  /// Gửi lại email xác nhận
  Future<void> resendSignupEmail(String email) async {
    try {
      await _supabaseClient.auth.resend(
        type: OtpType.signup,
        email: email,
      );
    } catch (e) {
      throw Exception('Lỗi gửi lại email: ${e.toString()}');
    }
  }

  /// Kiểm tra xem email đã được xác nhận chưa
  Future<bool> isEmailVerified() async {
    try {
      final user = _supabaseClient.auth.currentUser;
      return user?.emailConfirmedAt != null;
    } catch (e) {
      throw Exception('Lỗi kiểm tra xác nhận email: ${e.toString()}');
    }
  }

  /// Lấy email của user hiện tại
  String? getCurrentUserEmail() {
    try {
      return _supabaseClient.auth.currentUser?.email;
    } catch (e) {
      throw Exception('Lỗi lấy email: ${e.toString()}');
    }
  }
}
